; Inno Setup Script for MarkdownReader
; Version: 1.1.1
; Publisher: Sergio Righi

#define MyAppName "MarkdownReader"
#define MyAppVersion "1.1.1"
#define MyAppPublisher "Sergio Righi"
#define MyAppExeName "MarkdownReader.exe"
#define MyAppCopyright "© 2026 Sergio Righi"
#define MyAppDescription "Lightweight Markdown Reader for Windows"
#define MyAppId "{D8C8B1E1-4A59-4E62-8A2F-9A52378D8FE1}"

[Setup]
AppId={{D8C8B1E1-4A59-4E62-8A2F-9A52378D8FE1}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppCopyright={#MyAppCopyright}
DefaultDirName={code:GetDefaultInstallDir}
DefaultGroupName={#MyAppName}
DisableDirPage=no
DisableProgramGroupPage=yes
UsePreviousAppDir=yes
OutputDir=..\dist
OutputBaseFilename=MarkdownReader-{#MyAppVersion}-Setup
SetupIconFile=..\assets\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog commandline
ChangesAssociations=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\target\release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Registry]
; Register App Paths for execution by name
Root: HKA; Subkey: "Software\Microsoft\Windows\CurrentVersion\App Paths\{#MyAppExeName}"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Microsoft\Windows\CurrentVersion\App Paths\{#MyAppExeName}"; ValueType: string; ValueName: "Path"; ValueData: "{app}"; Flags: uninsdeletekey

; Register ProgID: MarkdownReader.Document
Root: HKA; Subkey: "Software\Classes\MarkdownReader.Document"; ValueType: string; ValueName: ""; ValueData: "Markdown Document"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\MarkdownReader.Document\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\MarkdownReader.Document\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""; Flags: uninsdeletekey

; Register OpenWithProgids for .md and .markdown
Root: HKA; Subkey: "Software\Classes\.md\OpenWithProgids"; ValueType: string; ValueName: "MarkdownReader.Document"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\.markdown\OpenWithProgids"; ValueType: string; ValueName: "MarkdownReader.Document"; ValueData: ""; Flags: uninsdeletevalue

; Capabilities registration for Windows 10/11 Default Apps
Root: HKA; Subkey: "Software\{#MyAppName}\Capabilities"; ValueType: string; ValueName: "ApplicationName"; ValueData: "{#MyAppName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\{#MyAppName}\Capabilities"; ValueType: string; ValueName: "ApplicationDescription"; ValueData: "{#MyAppDescription}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\{#MyAppName}\Capabilities\FileAssociations"; ValueType: string; ValueName: ".md"; ValueData: "MarkdownReader.Document"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\{#MyAppName}\Capabilities\FileAssociations"; ValueType: string; ValueName: ".markdown"; ValueData: "MarkdownReader.Document"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\RegisteredApplications"; ValueType: string; ValueName: "{#MyAppName}"; ValueData: "Software\{#MyAppName}\Capabilities"; Flags: uninsdeletevalue

[InstallDelete]
Type: files; Name: "{app}\unins001.*"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
begin
    if CurStep = ssPostInstall then
    begin
        // Remove stale duplicate registry key with extra closing brace if present
        RegDeleteKeyIncludingSubkeys(HKLM32, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{D8C8B1E1-4A59-4E62-8A2F-9A52378D8FE1}}_is1');
        RegDeleteKeyIncludingSubkeys(HKLM64, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{D8C8B1E1-4A59-4E62-8A2F-9A52378D8FE1}}_is1');
        RegDeleteKeyIncludingSubkeys(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{D8C8B1E1-4A59-4E62-8A2F-9A52378D8FE1}}_is1');
    end;
end;

function GetDefaultInstallDir(Param: String): String;
var
    InstallDir: String;
begin
    InstallDir := '';

    // 1. Check Current User Registry
    if RegQueryStringValue(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#MyAppId}_is1', 'InstallLocation', InstallDir) and (InstallDir <> '') then
    begin
        Result := InstallDir;
        Exit;
    end;
    if RegQueryStringValue(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#MyAppId}_is1', 'Inno Setup: App Path', InstallDir) and (InstallDir <> '') then
    begin
        Result := InstallDir;
        Exit;
    end;

    // 2. Check Local Machine (All Users) 64-bit Registry
    if IsWin64 and RegQueryStringValue(HKLM64, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#MyAppId}_is1', 'InstallLocation', InstallDir) and (InstallDir <> '') then
    begin
        Result := InstallDir;
        Exit;
    end;
    if IsWin64 and RegQueryStringValue(HKLM64, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#MyAppId}_is1', 'Inno Setup: App Path', InstallDir) and (InstallDir <> '') then
    begin
        Result := InstallDir;
        Exit;
    end;

    // 3. Check Local Machine (All Users) 32-bit Registry (WOW6432Node)
    if RegQueryStringValue(HKLM32, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#MyAppId}_is1', 'InstallLocation', InstallDir) and (InstallDir <> '') then
    begin
        Result := InstallDir;
        Exit;
    end;
    if RegQueryStringValue(HKLM32, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#MyAppId}_is1', 'Inno Setup: App Path', InstallDir) and (InstallDir <> '') then
    begin
        Result := InstallDir;
        Exit;
    end;

    // Default if not previously installed
    Result := ExpandConstant('{autopf}\{#MyAppName}');
end;
