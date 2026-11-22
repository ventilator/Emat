unit ULangMgr;

{ Runtime German / English localization manager for Emat.
  Persists [Allgemein] Language=de|en in custom\Emat.ini and translates
  main menus, dockable panels, settings controls, and helper dialogs live. }

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Menus, IniFiles,
  TB2Dock, TB2Item, TB2Toolbar, TBX, TBXDkPanels, TBXExtItems;

type
  TEmatLang = (langDE, langEN);

var
  CurrentLang: TEmatLang = langDE;

function Tr(const DE, EN: string): string;
function LoadLanguageSetting(const IniPath: string): TEmatLang;
procedure SaveLanguageSetting(const IniPath: string; Lang: TEmatLang);
procedure ApplyLanguageToForm(AForm: TForm; Lang: TEmatLang);

implementation

type
  TTransPair = record
    DE: string;
    EN: string;
  end;

const
  // Caption mapping (exact German -> English, preserving & accelerators)
  CAP_MAP: array[0..78] of TTransPair = (
    (DE: '&Datei'; EN: '&File'),
    (DE: '&Ansicht'; EN: '&View'),
    (DE: '&Fenster'; EN: '&Window'),
    (DE: '&Extras'; EN: '&Tools'),
    (DE: 'Extras'; EN: 'Tools'),
    (DE: '&?'; EN: '&Help'),
    (DE: 'Spezial'; EN: 'Special'),
    (DE: 'Neue Playliste'; EN: 'New Playlist'),
    (DE: 'Playliste öffnen'; EN: 'Open Playlist'),
    (DE: 'Playliste speichern'; EN: 'Save Playlist'),
    (DE: 'Playliste speichern unter...'; EN: 'Save Playlist As...'),
    (DE: 'Playliste schließen'; EN: 'Close Playlist'),
    (DE: 'Beenden'; EN: 'Exit'),
    (DE: 'Hilfe'; EN: 'Help'),
    (DE: 'Webseite'; EN: 'Website'),
    (DE: 'Info'; EN: 'About'),
    (DE: 'Zurücksetzen'; EN: 'Reset Layout'),
    (DE: 'Equalizer'; EN: 'Equalizer'),
    (DE: 'Visualisierung'; EN: 'Visualization'),
    (DE: 'Visualisierung einrichten'; EN: 'Open Visualization'),
    (DE: 'Playlisten'; EN: 'Playlists'),
    (DE: 'Einstellungen'; EN: 'Settings'),
    (DE: 'Schnelleinstellungen'; EN: 'Quick Settings'),
    (DE: 'Verlauf'; EN: 'History'),
    (DE: 'Zuletzt gespielt'; EN: 'Recently Played'),
    (DE: 'Favoriten'; EN: 'Favorites'),
    (DE: 'Meist gespielt'; EN: 'Most Played'),
    (DE: 'Cover'; EN: 'Cover Art'),
    (DE: 'Themes'; EN: 'Themes'),
    (DE: 'Stile'; EN: 'Themes'),
    (DE: 'Style'; EN: 'Themes'),
    (DE: 'Aussehen'; EN: 'Appearance'),
    (DE: 'Metainformation'; EN: 'Metadata'),
    (DE: 'Metainformationen'; EN: 'Metadata'),
    (DE: 'Suche'; EN: 'Search'),
    (DE: 'Log for Debugging'; EN: 'Debug Log'),
    (DE: 'Steuerung'; EN: 'Controls'),
    (DE: 'Lautstärke'; EN: 'Volume'),
    (DE: 'Abspielfortschritt'; EN: 'Playback Progress'),
    (DE: 'Ordner neu einlesen'; EN: 'Rescan Folders'),
    (DE: 'Ungültige Einträge entfernen'; EN: 'Remove Invalid Entries'),
    (DE: 'Playlisten nebeneinander'; EN: 'Tile Playlists Vertically'),
    (DE: 'Playlisten untereinander'; EN: 'Tile Playlists Horizontally'),
    (DE: 'Playlisten überlappend'; EN: 'Cascade Playlists'),
    (DE: 'OSD-Einstellungen...'; EN: 'OSD Settings...'),
    (DE: 'Tragbares Gerät synchronisieren...'; EN: 'Sync Portable Device...'),
    (DE: 'Sprache / Language'; EN: 'Language / Sprache'),
    (DE: 'Taskleiste und Tray'; EN: 'Taskbar & Tray'),
    (DE: 'Taskleisteneintrag'; EN: 'Taskbar Button'),
    (DE: 'Taskleistenschaltfläche'; EN: 'Show Taskbar Button'),
    (DE: 'Scrollen des Titels'; EN: 'Scroll Track Title'),
    (DE: 'Titel in Taskleiste scrollen'; EN: 'Scroll Title in Taskbar'),
    (DE: 'Trayicon'; EN: 'Tray Icon'),
    (DE: 'Tray-Icon anzeigen'; EN: 'Show Tray Icon'),
    (DE: 'Trayicon anzeigen'; EN: 'Show Tray Icon'),
    (DE: 'In Tray minimieren'; EN: 'Minimize to Tray'),
    (DE: 'In den Tray minimieren'; EN: 'Minimize to Tray'),
    (DE: 'Verschiedenes'; EN: 'Miscellaneous'),
    (DE: 'Eindeutige Suchtreffer sofort spielen'; EN: 'Auto-play single search match'),
    (DE: 'Suche nach .jpg Cover'; EN: 'Search for .jpg cover art'),
    (DE: 'Cover automatisch suchen'; EN: 'Auto-Search Cover Art'),
    (DE: 'Emat mit hoher Priorität ausführen'; EN: 'Run Emat with high priority'),
    (DE: 'Hohe Priorität'; EN: 'High Process Priority'),
    (DE: 'Titelanzeige'; EN: 'Title Display (OSD)'),
    (DE: 'Info-Anzeige in allen Anwendungen'; EN: 'Show OSD over all apps'),
    (DE: 'Unbenannte Playlisten speichern'; EN: 'Auto-save unnamed playlists'),
    (DE: 'Playlisten automatisch speichern'; EN: 'Auto-Save Playlists'),
    (DE: 'Hintergrund'; EN: 'Background'),
    (DE: 'Hintergrundfarbe wählen...'; EN: 'Choose background color...'),
    (DE: 'Hintergrundbild laden...'; EN: 'Load background image...'),
    (DE: 'Systemweite Hotkeys'; EN: 'Global Hotkeys'),
    (DE: 'Systemweite Hot-Keys'; EN: 'Global Hotkeys'),
    (DE: 'Sek. vom Anfang entfernen'; EN: 'Trim sec. from start'),
    (DE: 'Sek. vom Ende entfernen'; EN: 'Trim sec. from end'),
    (DE: 'Anfang und Ende beschneiden'; EN: 'Trim start and end'),
    (DE: 'Titel beim Löschen nur aus der Liste entfernen'; EN: 'Remove from list only on Delete'),
    (DE: 'Titel auch in den Papierkorb verschieben'; EN: 'Also move file to Recycle Bin'),
    (DE: 'Löschen von Festplatte erlauben'; EN: 'Allow Deleting Files from Disk'),
    (DE: 'Anwenden'; EN: 'Apply')
  );

function Tr(const DE, EN: string): string;
begin
  if CurrentLang = langEN then
    Result := EN
  else
    Result := DE;
end;

function TranslateCaption(const S: string; Lang: TEmatLang): string;
var
  i: Integer;
begin
  Result := S;
  for i := Low(CAP_MAP) to High(CAP_MAP) do
  begin
    if Lang = langEN then
    begin
      if SameText(S, CAP_MAP[i].DE) then
      begin
        Result := CAP_MAP[i].EN;
        Exit;
      end;
    end
    else
    begin
      if SameText(S, CAP_MAP[i].EN) then
      begin
        Result := CAP_MAP[i].DE;
        Exit;
      end;
    end;
  end;
end;

function LoadLanguageSetting(const IniPath: string): TEmatLang;
var
  Ini: TIniFile;
  Code: string;
begin
  Result := langDE;
  if not FileExists(IniPath) then Exit;
  try
    Ini := TIniFile.Create(IniPath);
    try
      Code := LowerCase(Trim(Ini.ReadString('Allgemein', 'Language', 'de')));
      if Code = 'en' then
        Result := langEN
      else
        Result := langDE;
    finally
      Ini.Free;
    end;
  except
  end;
  CurrentLang := Result;
end;

procedure SaveLanguageSetting(const IniPath: string; Lang: TEmatLang);
var
  Ini: TIniFile;
begin
  CurrentLang := Lang;
  if not DirectoryExists(ExtractFilePath(IniPath)) then Exit;
  try
    Ini := TIniFile.Create(IniPath);
    try
      if Lang = langEN then
        Ini.WriteString('Allgemein', 'Language', 'en')
      else
        Ini.WriteString('Allgemein', 'Language', 'de');
    finally
      Ini.Free;
    end;
  except
  end;
end;

procedure ApplyLanguageToForm(AForm: TForm; Lang: TEmatLang);
var
  i: Integer;
  C: TComponent;
begin
  CurrentLang := Lang;
  if AForm = nil then Exit;
  for i := 0 to AForm.ComponentCount - 1 do
  begin
    C := AForm.Components[i];
    if C is TTBCustomItem then
      TTBCustomItem(C).Caption := TranslateCaption(TTBCustomItem(C).Caption, Lang)
    else if C is TTBXDockablePanel then
      TTBXDockablePanel(C).Caption := TranslateCaption(TTBXDockablePanel(C).Caption, Lang)
    else if C is TTBXCheckBox then
      TTBXCheckBox(C).Caption := TranslateCaption(TTBXCheckBox(C).Caption, Lang)
    else if C is TTBXRadioButton then
      TTBXRadioButton(C).Caption := TranslateCaption(TTBXRadioButton(C).Caption, Lang)
    else if C is TTBXLabel then
      TTBXLabel(C).Caption := TranslateCaption(TTBXLabel(C).Caption, Lang)
    else if C is TTBXButton then
      TTBXButton(C).Caption := TranslateCaption(TTBXButton(C).Caption, Lang)
    else if C is TLabel then
      TLabel(C).Caption := TranslateCaption(TLabel(C).Caption, Lang)
    else if C is TCheckBox then
      TCheckBox(C).Caption := TranslateCaption(TCheckBox(C).Caption, Lang)
    else if C is TRadioButton then
      TRadioButton(C).Caption := TranslateCaption(TRadioButton(C).Caption, Lang)
    else if C is TButton then
      TButton(C).Caption := TranslateCaption(TButton(C).Caption, Lang);
  end;
  for i := 0 to AForm.ComponentCount - 1 do
    if AForm.Components[i] is TTBCustomToolbar then
      TTBCustomToolbar(AForm.Components[i]).Invalidate;
end;

end.
