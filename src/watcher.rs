use notify_debouncer_mini::{new_debouncer, notify::RecursiveMode, DebounceEventResult, Debouncer};
use std::collections::{HashMap, HashSet};
use std::path::{Path, PathBuf};
use std::sync::{Arc, Mutex};
use std::time::Duration;
use tao::event_loop::EventLoopProxy;
use crate::ipc::UserEvent;

pub fn normalize_path(path: &Path) -> PathBuf {
    let canonical = path.canonicalize().unwrap_or_else(|_| path.to_path_buf());
    let s = canonical.to_string_lossy();
    let clean = s.trim_start_matches(r"\\?\").trim_start_matches(r"\??\");
    PathBuf::from(clean)
}

pub struct FileWatcher {
    debouncer: Debouncer<notify_debouncer_mini::notify::RecommendedWatcher>,
    watched_files: Arc<Mutex<HashSet<PathBuf>>>,
    watched_dirs: HashMap<PathBuf, usize>,
}

impl FileWatcher {
    pub fn new(proxy: EventLoopProxy<UserEvent>) -> Result<Self, Box<dyn std::error::Error>> {
        let watched_files = Arc::new(Mutex::new(HashSet::<PathBuf>::new()));
        let files_clone = Arc::clone(&watched_files);

        let debouncer = new_debouncer(Duration::from_millis(250), move |res: DebounceEventResult| {
            if let Ok(events) = res {
                let active_files = match files_clone.lock() {
                    Ok(guard) => guard,
                    Err(poisoned) => poisoned.into_inner(),
                };

                for event in events {
                    let norm = normalize_path(&event.path);
                    let norm_lower = norm.to_string_lossy().to_lowercase();

                    for watched in active_files.iter() {
                        let watched_lower = watched.to_string_lossy().to_lowercase();
                        if norm_lower == watched_lower {
                            let _ = proxy.send_event(UserEvent::FileModified(watched.clone()));
                            break;
                        }
                    }
                }
            }
        })?;

        Ok(Self {
            debouncer,
            watched_files,
            watched_dirs: HashMap::new(),
        })
    }

    pub fn watch_file(&mut self, path: &Path) {
        let normalized = normalize_path(path);
        let mut set = match self.watched_files.lock() {
            Ok(guard) => guard,
            Err(poisoned) => poisoned.into_inner(),
        };

        if set.insert(normalized.clone()) {
            if let Some(parent) = normalized.parent() {
                let parent_buf = parent.to_path_buf();
                let count = self.watched_dirs.entry(parent_buf.clone()).or_insert(0);
                if *count == 0 {
                    let _ = self.debouncer.watcher().watch(&parent_buf, RecursiveMode::NonRecursive);
                }
                *count += 1;
            }
        }
    }

    pub fn unwatch_file(&mut self, path: &Path) {
        let normalized = normalize_path(path);
        let mut set = match self.watched_files.lock() {
            Ok(guard) => guard,
            Err(poisoned) => poisoned.into_inner(),
        };

        if set.remove(&normalized) {
            if let Some(parent) = normalized.parent() {
                let parent_buf = parent.to_path_buf();
                if let Some(count) = self.watched_dirs.get_mut(&parent_buf) {
                    if *count > 0 {
                        *count -= 1;
                        if *count == 0 {
                            let _ = self.debouncer.watcher().unwatch(&parent_buf);
                            self.watched_dirs.remove(&parent_buf);
                        }
                    }
                }
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_normalize_path() {
        let p = Path::new("Cargo.toml");
        let norm = normalize_path(p);
        assert!(!norm.to_string_lossy().starts_with(r"\\?\"));
        assert!(norm.to_string_lossy().ends_with("Cargo.toml"));
    }

    #[test]
    fn test_watcher_watch_and_unwatch() {
        use tao::platform::windows::EventLoopBuilderExtWindows;
        let mut builder = tao::event_loop::EventLoopBuilder::<UserEvent>::with_user_event();
        builder.with_any_thread(true);
        let event_loop = builder.build();
        let proxy = event_loop.create_proxy();
        let mut watcher = FileWatcher::new(proxy).expect("FileWatcher creation failed");

        let target = Path::new("Cargo.toml");
        watcher.watch_file(target);

        let norm = normalize_path(target);
        {
            let set = watcher.watched_files.lock().unwrap();
            assert!(set.contains(&norm));
        }

        watcher.unwatch_file(target);
        {
            let set = watcher.watched_files.lock().unwrap();
            assert!(!set.contains(&norm));
        }
    }
}
