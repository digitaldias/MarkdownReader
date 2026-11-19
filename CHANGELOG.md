# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1.1] — 2026-11-19

### Fixed
* **Live Reload / Auto-Update:** Normalized Windows UNC verbatim path prefixes (`\\?\`) in `DocumentTab::from_file`, CLI initial path handling, and WebView tab path matching (`updateTabContentByPath` / `addOrActivateTab`) so external file edits reload the open tab reliably.

---

## [1.1.0] — 2026-10-27

### Added
* **Live Reload / File Watcher:** Automatic file monitoring using native Windows `ReadDirectoryChangesW` (`notify-debouncer-mini`), reloading content seamlessly when files are modified externally.
* **Scroll Preservation on Reload:** Viewport scroll position is preserved without jumping to the top when files are updated.
* **GitHub Alerts / Callouts Support:** Beautiful formatting for `[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]`, `[!CAUTION]` (with Portuguese localized tags `[!NOTA]`, `[!DICA]`, `[!AVISO]`, `[!CUIDADO]`, `[!COMENTARIO]`) with dedicated SVG icons and colored cards.

### Changed
* **Window Title:** Fixed clean title bar displaying `"Markdown Reader"`, keeping file names on individual document tabs.
* **Blockquote & Comments Styling:** Refined text contrast (`#cbd5e1`) and Prism code comment visibility (`#8b949e`).

---

## [1.0.0] — 2026-09-22

### Added
* **Native Windows Viewer:** High-performance, lightweight Markdown viewer built in Rust with Microsoft Edge WebView2.
* **Multi-Tab Interface:** Single WebView2 architecture supporting multiple document tabs with independent scroll preservation.
* **Tab Drag & Drop:** Horizontal tab reordering with smooth visual feedback.
* **Keyboard Navigation:** <kbd>Ctrl</kbd>+<kbd>Tab</kbd> / <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Tab</kbd> for tab switching, <kbd>Ctrl</kbd>+<kbd>W</kbd> to close tab, <kbd>Ctrl</kbd>+<kbd>O</kbd> to open files.
* **Single-Instance IPC:** Windows Named Pipe IPC forwarding new document requests from Windows Explorer into the running instance.
* **Rich Markdown Engine:** Pulldown-cmark parser supporting GFM tables, task lists, blockquotes, footnotes, strikethrough, and headers.
* **Relative Image Resolution:** Custom local asset protocol (`mdasset://`) automatically resolving relative images across directory structures, special characters, spaces, and accented paths.
* **Offline Syntax Highlighting:** Embedded PrismJS bundle with language badges and dedicated copy buttons for 15+ programming languages.
* **Offline Mermaid Diagrams:** Local SVG diagram generation supporting flowcharts, sequence diagrams, class diagrams, state diagrams, ER diagrams, Gantt charts, mindmaps, and git graphs with lazy initialization.
* **In-Page Search:** Built-in find UI (<kbd>Ctrl</kbd>+<kbd>F</kbd>) with match highlighting and forward/backward stepping.
* **Windows Window State:** Automatic multi-monitor aware position and size persistence in `%APPDATA%\MarkdownReader\config.json`.
* **Portable Distribution:** Standalone executable requiring zero installation.
* **Inno Setup Installer:** Clean Windows installer supporting per-user or system installation, Start Menu shortcut, and non-intrusive `.md` / `.markdown` file associations.
