# Emat-Port — offene Punkte

Stand: 0.90 (EmAIt), Lazarus 4.8 / FPC 3.2.2 i386, BASS 2.4.17.
Erledigt: Oberfläche mit TBX-Themes, Playlist laden/speichern, MP3 **und** WMA
über bass.dll + basswma, OSD, Equalizer-FX-Kette, Winamp-Input-Plugins aus.

Die Liste ist als Auswahl gedacht: jeder Punkt steht für sich, mit Aufwand und
dem, was dafür konkret zu tun ist.

## 1. Milkdrop / Visualisierung (groß, ~1–2 Tage)

> Details, Aufrufketten und Risiken: `docs/recherche-milkdrop-und-docking.md`

Der Host ist noch da: `source/TBASSPlayer/VisDrive2.pas` ist ein vollständiger
Winamp-Vis-Host (inkl. Milkdrop-2-Sonderfällen über `wa_ipc.pas`), und
`Plugins/vis_milk2.dll` + `Plugins/Milkdrop2/` mit Presets liegen im Repo.
Abgeklemmt wurde er an drei Stellen:

1. `TSpieler.VisConfig` ist ein leerer Stub („Winamp-Visualisierung entfernt").
   Es fehlt der Aufruf von `Start_Vis(...)` aus `VisDrive2`.
2. `TBASSPlayer.Create` lädt `VisDrawer.dll` (Rahmenfenster um die Vis) — die
   DLL ist **nicht** im Repo. Ohne sie muss `MyembedWindow` als Elternfenster
   direkt ein Panel der Form benutzen.
3. Die FFT-Daten liefert `TVisDataThread` (vorhanden); `FOnNewFFTData` muss
   gesetzt und `TimerFFT` gestartet werden, sonst bekommt Milkdrop keine Daten.

Vorgehen: `Start_Vis('vis_milk2.dll', HandleEinesPanels)` mit gesetztem
`FOnNewFFTData` probieren, dann die IPC-Antworten in `VisWindowProc`
durchgehen (Milkdrop fragt Playlist/Titel ab). Fallback, falls DX9-Rendering im
LCL-Fenster nicht will: eigenes Top-Level-Fenster als Parent.

## 2. MarkInList — Access Violation (klein, ~1 h)

Beim Laden der offenen Listen stürzt `fmp3.MarkInList` mit einer AV ab
(Adresse in `TControl.ChangeBounds`). Aktuell in `Usave.pas` mit try/except
abgefangen und geloggt, d. h. der laufende Titel wird in der Liste **nicht**
markiert. Ursache ist das Setzen von Bounds/Selection am TBX-MDI-Grid während
des Ladens; vermutlich wird die Liste vor dem ersten `Realign` angefasst.

## 3. Equalizer-Bedienung prüfen (klein, ~1 h)

Die FX-Kette steht (Log: `EQ attached: … h=<handle> g=0.0` für alle 10 Bänder,
`BASS_FX_DX8_PARAMEQ` auf dem PlayChannel). Offen ist nur die Bedienung: das
Equalizer-Dockpanel ist im ausgelieferten Layout nicht sichtbar, und die
Slider-Routine (`fmp3` Zeile ~1878/1910) muss einmal mit der Maus geprüft
werden. Ausserdem: `FPlaylisten`/`MarkInList`-AV kann das Öffnen des Panels
stören.

## 4. Alte Playlist-Engine (`gliste2.pas`) (mittel, ~4 h)

Die Playlist ist eine handgezeichnete Grid-Komponente mit eingebautem
Fortschrittsbalken. Läuft, ist aber die Quelle der AVs oben. Ersatz:
`TVirtualStringGrid` (LazUtils/Grids) oder `TListView` mit OwnerDraw; der
Fortschrittsbalken wird dann pro Zeile gezeichnet. Optik bleibt gleich.

## 5. Themes ohne Glyphen (klein, ~2 h)

Sechs Projekt-Themes (Miranda, Monai, Relifer, SolarizedLight, Tristan2,
Zezio) haben ihre `TBXGLYPHS`-Imagestrips nicht portiert — Toolbar-Icons
fehlen dort. Entweder Strips als `TImageList` nachliefern oder diese Themes
aus der Auswahl nehmen.

## 6. Winamp-Input-Plugins wirklich löschen (mittel, ~3 h)

Sie sind abgeschaltet (`EMAT_WINAMP_INPUT = False` in `USpieler.pas`,
`FPluginReady := False` in `BASSPlayer.pas`), aber `PluginCtrl.pas`,
`ioplug.pas`, `wa_ipc.pas`, `WasabiAPI.pas` werden weiterhin mitkompiliert.
Sauber wäre, sie samt aller `Channel_Plugin`-Zweige zu entfernen — Achtung:
`wa_ipc.pas`/`WasabiAPI.pas` werden auch von Milkdrop (Punkt 1) gebraucht,
also erst nach dessen Entscheidung.

## 7. Kleinkram (je < 1 h)

- `Emat.exe` ist aus dem Repo genommen (Build-Artefakt), `.gitignore` ergänzt.
- `tests/test_bass.lpr` ist ein Prüfstand für bass.dll/Addons; die
  Testdateien und DLL-Kopien darin gehören nicht ins Repo (siehe .gitignore).
- OSD: Position/Größe sind fest (80 % Bildschirmhöhe, max. 55 % Breite);
  Feineinstellung im Einstellungsdialog wäre nett (Schriftgröße, Dauer,
  Bildschirmwahl).
- `Aktiv.ScreenText_Dauer` ist beim ersten Titel manchmal leer — Dauer wird
  erst nach dem Öffnen gesetzt.
- Die Log-Datei `debug.log` neben der Exe wächst unbegrenzt (kein Rotate).
- `bbass_fx.dll` (Equalizer/Echo/Reverb/Flanger) wird geladen, Echo/Reverb/
  Flanger sind aber nirgends in der Oberfläche erreichbar.

## 8. Dockable Panels durch LCL-Docking ersetzen (optional, ~2–3 Tage)

Die TBX-Panels laufen im Port; ein Ersatz ist reine Architektur-/Optikfrage.
`AnchorDocking` (`C:/lazarus/components/anchordocking/anchordocking.lpk`) ist
lokal vorhanden und kann Formen *und* Controls andocken, mit Tab-Seiten und
Layout-Persistenz. Details, Alternativen (LCL-DragDock, EasyDockMgr) und ein
Migrationsplan stehen in `docs/recherche-milkdrop-und-docking.md`. Kurz:
erst ein Panel als Form herauslösen, Machbarkeit/Optik prüfen, dann alle 14.
