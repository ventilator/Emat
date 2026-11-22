# Emat (Windows 11 x64) — Full Function Test Plan

## Test Corpus (`tests\classical\`)
10 short (15s) Public Domain / CC classical tracks downloaded from **Wikimedia Commons** (see `tests\classical\SOURCES.md` for full attribution & licenses), spanning **6 audio formats** (`OGG`, `MP3`, `FLAC`, `M4A/AAC`, `WMA`, `WAV`), **German umlauts** in folder names, file names, and tags, plus a sample `cover.jpg` and ready-to-load `tests\classical\classical.m3u8`.

| # | Track Path (relative to `tests\classical\`) | Format | BASS Decoder | Automated x64 Decode |
|---|---|---|---|---|
| 1 | `Johann Sebastian Bach\Das Wohltemperierte Klavier\01_Bach_Präludium.ogg` | OGG | `bass.dll` | **PASS** (15.00s) |
| 2 | `Johann Sebastian Bach\Sinfonien\02_Bach_Sinfonia.mp3` | MP3 | `bass.dll` | **PASS** (15.00s) |
| 3 | `Wolfgang Amadeus Mozart\Klaviersonaten\03_Mozart_Sonate.mp3` | MP3 | `bass.dll` | **PASS** (14.99s) |
| 4 | `Wolfgang Amadeus Mozart\Sinfonien & Ouvertüren\04_Mozart_Ouvertüre.flac` | FLAC | `bassflac.dll` | **PASS** (15.00s) |
| 5 | `Ludwig van Beethoven\Klaviersonaten\05_Beethoven_Für_Elise.mp3` | MP3 + `cover.jpg` | `bass.dll` | **PASS** (15.00s) |
| 6 | `Ludwig van Beethoven\Sinfonien\06_Beethoven_Sinfonie.m4a` | M4A (AAC) | `bass_aac.dll` | **PASS** (15.02s) |
| 7 | `Frédéric Chopin\Etüden & Préludes\07_Chopin_Etüde.flac` | FLAC | `bassflac.dll` | **PASS** (15.00s) |
| 8 | `Frédéric Chopin\Etüden & Préludes\08_Chopin_Walzer.wma` | WMA | `basswma.dll` | **PASS** (15.00s) |
| 9 | `Antonio Vivaldi\Die vier Jahreszeiten\09_Vivaldi_Frühling.wav` | WAV | `bass.dll` | **PASS** (15.00s) |
| 10 | `Antonio Vivaldi\Die vier Jahreszeiten\10_Vivaldi_Herbst.ogg` | OGG | `bass.dll` | **PASS** (15.00s) |

---

## Automated Verification Results (Executed on Windows 11 x64)

| ID | Automated Check | Result | Notes |
|---|---|---|---|
| A1 | Release x64 build (`build-release.bat`) | **PASS** | Produces `Emat.exe` (x64) + `release\Emat-*-win64.zip` + `.sha256` |
| A2 | x64 BASS + add-on DLL loading (`basswma`, `bassflac`, `bass_aac`, `bass_ac3`) | **PASS** | All 4 add-ons load cleanly (`*.ac3;*.aac;*.m4a;*.m4b;*.mp4;*.flac;*.fla;*.oga;*.ogg;`) |
| A3 | 10/10 classical tracks x64 BASS decode + float PCM output | **PASS** | All 10 tracks open with `BASS_UNICODE` (umlauts intact) and return valid float PCM |
| A4 | Live `Emat.exe "tests\classical\classical.m3u8"` launch + `EMAT_VIS=1` | **PASS** | Loads `.m3u8` directly (fixed `ParameterOpen` extension check), 10-band EQ + 17 presets, `projectM: 949 Presets gefunden`, `glewInit=0`, `800x600` |
| A5 | Clean close via `WM_CLOSE` to main window | **PASS** | `CleanCloseExited=True`, `ExitCode=0`, zero Access Violation dialogs, zero `startup_error.txt` |
| I1 | Interactive GUI: First-start menu bar contrast (`TBXAluminumTheme`, `TBX-Theme=0`) | **PASS** | Fixed LCL `Canvas.TextRect` in `TBXAluminumTheme` / `TBXDefaultTheme` / `TBXStripesTheme` / `TBXMonaiXPTheme` / `TBXRomaTheme`; verified **197 dark text pixels** at `x=5..190, y=32..60` on first start without hover |
| I2 | Interactive GUI: Double-click playback + 10-band EQ + inline progress + Favorites | **PASS** | Double-clicked `06_Beethoven_Sinfonie.m4a` (`bass_aac.dll`); verified 10 DX8 EQ bands attached, inline progress bar moving, Favorites count incremented, window title updated |
| I3 | Interactive GUI: Layered click-through OSD (`TEmatOSD`) | **PASS** | Verified `EmatOSD` window visible and rendered track title + `0:15` duration |
| I4 | Interactive GUI: projectM v4 OpenGL 3.3 Core window | **PASS** | Verified `Emat - projectM: Rovastar + Zylot - Narell's Fever` rendering live OpenGL visuals at 800×600 |
| I5 | Interactive GUI: Panel header bars (`⋮ ×`) + contrast | **PASS** | Verified crisp contrasting titles and `[⋮ ×]` button order on every dockable panel |
| I6 | Interactive GUI: English UI (`Language=en`) | **PASS** | Verified all menus, panel titles (`Cover Art`, `Settings`, `Quick Settings`, `Most Played`, `Playback Progress`, `Volume`, `Debug Log`), and settings checkboxes/labels render in English |

---

## Interactive Function Test Plan

### 1. Startup, Menu Contrast & Lifecycle
- [ ] **T1.1 First-start menu bar contrast**: Launch `Emat.exe` — verify `&Datei / &Ansicht / &Fenster / &Extras / &?` are immediately legible (dark contrasting text, not white) without hovering.
- [ ] **T1.2 Clean shutdown**: Click the window `×` button (or `Datei → Beenden`) — verify Emat closes immediately with no Access Violation dialog and no leftover `Emat.exe` in Task Manager.

### 2. Multi-Format Audio Playback & Transport
- [ ] **T2.1 Load corpus**: Open `tests\classical\classical.m3u8` via `Datei → Playliste öffnen` (or drag-and-drop `tests\classical\` folder onto Emat). Verify all 10 tracks appear with intact umlauts (`Präludium`, `Ouvertüre`, `Für Elise`, `Frédéric Chopin`, `Etüde`, `Frühling`).
- [ ] **T2.2 Format playback**: Double-click and listen to at least one track of each format: `.ogg` (#1), `.mp3` (#2/#5), `.flac` (#4/#7), `.m4a` (#6), `.wma` (#8), `.wav` (#9).
- [ ] **T2.3 Transport controls**: Test Play, Pause, Resume, Stop, Next, Previous, Shuffle, Repeat, Volume slider, Mute, and inline progress-bar seeking directly inside the playlist row.

### 3. Playlists, Search, Sorting & Modern Formats
- [ ] **T3.1 Natural sorting**: Sort playlist by Title / Artist / Path (A→Z and Z→A); verify tracks `01..10` sort naturally and empty-list sort does not crash.
- [ ] **T3.2 Live search & MarkInList**: Type `Elise` or `Ouvertüre` in search box, backspace characters (verify UTF-8 backspace works), clear search, click active title / `MarkInList` — verify active track scrolls into view and highlights without AV.
- [ ] **T3.3 UTF-8 JSON v2 save/reload**: Save playlist via `Datei → Playliste speichern unter...` as `tests\classical\test_v2.epl` (and `.json`). Verify file is readable UTF-8 JSON (`"version": 2`), close playlist, reopen it — verify all 10 tracks, umlauts, and play counts persist.
- [ ] **T3.4 M3U8 export/import**: Save as `tests\classical\export.m3u8`, reopen in Emat (and optionally VLC/foobar2000) — verify all 10 tracks load.
- [ ] **T3.5 Legacy binary `.epl` compatibility**: Open `Playlist\wma.epl` — verify legacy CP1252 binary playlists still load cleanly without corrupting strings.
- [ ] **T3.6 History & Favorites**: Play 3+ tracks, verify `Verlauf` (History) records them and `Prev` navigates back without out-of-bounds errors; verify `Meist gespielt` (Favorites) increments play count.

### 4. Metadata (ID3) & Cover Art
- [ ] **T4.1 Metadata display**: Select track #5 (`05_Beethoven_Für_Elise.mp3`) — verify Artist, Album, Title, Genre, Year, Duration populate in the Metadata panel.
- [ ] **T4.2 Cover Art & Gradient**: Play track #5 (`Ludwig van Beethoven\Klaviersonaten\05_Beethoven_Für_Elise.mp3`) — verify `cover.jpg` displays in the Cover panel. Switch to track #1 (no cover) — verify the themed gradient backdrop (`LMDFGradientCover`) paints cleanly and updates when switching themes.

### 5. Equalizer
- [ ] **T5.1 EQ Panel & Presets**: Open `Fenster → Equalizer`, select several presets from the dropdown (17 presets), verify audio tone changes.
- [ ] **T5.2 Direct Click & Drag**: Click directly on an EQ band bar (`IEQMouseDown`) and drag vertically (`IEQMouseMove`) — verify the bar updates immediately on click and applies on release without division-by-zero errors.

### 6. Visualizations (projectM v4 & Embedded 2D Spectrum)
- [ ] **T6.1 projectM v4 window**: Click `Visualisierung einrichten` (Settings panel) while playing track #5 or #9 — verify OpenGL 3.3 window opens and reacts to live audio.
- [ ] **T6.2 projectM controls**: Test `Right`/`N` (Next preset), `Left`/`P` (Prev), `R` (Random), `L` (Lock — check window title `[Gesperrt]`), `F11` / double-click (Fullscreen toggle), `Esc` (exit fullscreen), right-click context menu, and close/reopen to verify saved window position in `Emat.ini`.
- [ ] **T6.3 Embedded 2D Spectrum**: Open `Fenster → Visualisierung` (`TBXDockablePanel2`) while playing — verify 32-band themed bar spectrum with peak-hold animates smoothly; click inside the panel to toggle to stereo waveform mode and back.

### 7. OSD & OSD Configuration
- [ ] **T7.1 Track-change OSD**: Switch tracks and verify the click-through layered OSD appears without stealing focus.
- [ ] **T7.2 OSD Settings dialog**: Open `Extras → OSD-Einstellungen...`, change Font Size, Duration, Position (`Top` / `Center` / `Top Right` / `Bottom`), Monitor, and Opacity, click **Test OSD**, click **OK**, restart Emat, and verify settings persisted in `custom\Emat.ini`.

### 8. Panels, MDI Arrangement & Themes
- [ ] **T8.1 Panel `×` close button**: Click `×` on any dockable panel header — verify panel hides and its checkmark clears in `&Fenster`. Re-enable it via `&Fenster`.
- [ ] **T8.2 Panel `⋮` dock menu**: Click `⋮` on a panel header and test **Oben andocken (Top)**, **Unten andocken (Bottom)**, **Links andocken (Left)**, **Rechts andocken (Right)**, and **Schwebend (Float)**.
- [ ] **T8.3 MDI arrangement**: Open 2 playlists (e.g., `classical.m3u8` + a new playlist), test `&Fenster → Playlisten nebeneinander`, `Playlisten untereinander`, and `Playlisten überlappend`.
- [ ] **T8.4 Themes**: Double-click several themes in the `Style` panel — verify toolbar icons are present (all 28 themes have glyphs), menu text stays readable, and panel headers + cover gradient + 2D spectrum re-theme immediately.

### 9. System Integration (Tray, Taskbar & Hotkeys)
- [ ] **T9.1 Minimize-to-Tray**: Enable `In den Tray minimieren` in Settings, minimize Emat — verify window hides to tray; double-click tray icon to restore. Toggle `Taskleisteneintrag` to verify taskbar button hide/show.
- [ ] **T9.2 Windows 11 Taskbar Media Controls**: Hover over Emat's Windows 11 taskbar icon — verify **Prev (`|<`)**, **Play/Pause (`>`/`||`)**, and **Next (`>|`)** thumbnail buttons appear, click each to verify track control, and confirm the Play/Pause icon toggles live.
- [ ] **T9.3 Global Hotkeys**: Enable `Systemweite Hotkeys`, focus another window (e.g., Notepad), press configured hotkeys (`Ctrl+F1`..`Ctrl+F12`) to verify Next/Prev/Play/Pause/Volume work globally.

### 10. Portable Device Sync & English Translation
- [ ] **T10.1 Portable Device Sync**: Open `Extras → Tragbares Gerät synchronisieren...`, choose a temporary folder (e.g., `C:\Temp\emat-sync-test`), check `Unterordner nach Interpret\Album anlegen` + `Bereits vorhandene Dateien überspringen` + `M3U8-Playliste erstellen`, click **Kopieren** — verify all 10 tracks copy into `Artist\Album\` subfolders with `Emat.m3u8`, and a second run skips all 10 existing files.
- [ ] **T10.2 English Translation**: Select `Extras → Sprache / Language → English` — verify main menus (`&File`, `&View`, `&Window`, `&Tools`, `&Help`), panel headers (`Dock Top/Bottom/Left/Right`, `Close`), OSD Settings dialog, and Portable Sync dialog switch to English immediately. Restart Emat and verify English persists (`Language=en` in `custom\Emat.ini`), then switch back to `Deutsch` if desired.
