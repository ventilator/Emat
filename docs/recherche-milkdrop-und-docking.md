# Recherche: Milkdrop und Ersatz für die TBX-Dockable-Panels

Stand 0.90 (EmAIt). Nur Recherche — nichts davon ist implementiert.

---

# 1. Milkdrop zum Laufen bringen

## Was schon im Repo liegt

| Baustein | Zustand |
|---|---|
| `Plugins/vis_milk2.dll` | vorhanden, Winamp-Vis-Plugin (exportiert `winampVisGetHeader`) |
| `Plugins/Milkdrop2/` + `milk2.ini`, `milk2_adapters.txt` | Presets und Konfiguration vorhanden |
| `source/TBASSPlayer/VisDrive2.pas` | **vollständiger Winamp-Vis-Host** (~1600 Zeilen, portiert): lädt die DLL, holt `winampVisGetHeader`, füllt `spectrumData`/`waveformData` (2048er-FFT über `BASS_ChannelGetData`), stellt ein Fake-Winamp-Fenster (`CLASSNAME_WINAMP = 'Winamp v1.2x'`) bereit und beantwortet die Wasabi-IPCs, die Milkdrop 2 abfragt (`IPC_GETPLAYLISTFILEW`, `IPC_GETPLAYLISTTITLEW`, …) |
| `source/TBASSPlayer/wa_ipc.pas`, `WasabiAPI.pas` | IPC- und Wasabi-Strukturen, ebenfalls portiert |
| `TVisDataThread` in `BASSPlayer.pas` | liefert FFT/Waveform in den Shared-Memory-Puffer, den `VisDrive2` liest |

Der Host ist also nicht das Problem — er ist nur **abgeklemmt**.

## Was genau fehlt (drei Stellen)

1. **`TSpieler.VisConfig` ist ein leerer Stub** (`USpieler.pas`, „Winamp-Visualisierung entfernt"). Es fehlt der Aufruf von `VisDrive2.Start_Vis(...)`:
   ```pascal
   Start_Vis(VisPlugin: string;      // 'Plugins\vis_milk2.dll'
             ModuleNum: integer;     // 0
             EmbedHandle: HWND;      // Elternfenster für die Vis!!
             UseGenVisDrawer: boolean;  // bei uns False
             EMBEDSwitch: TVisEMBEDSwitchMode;
             PlayerModeId: integer;
             ChannelIs: TChannelAttrb): integer;
   ```
   `SetBasicParams(MainWin, MsgHandle, StatusHwnd, ShareMem, Priority, LockFlag, VisDrawerDLL)` muss vorher einmal gelaufen sein (macht `TBASSPlayer.Create` schon, nur mit `VisDrawerDLLHandle = 0`).

2. **Die Rahmen-DLL `VisDrawer.dll` fehlt im Repo.** Im Original zeichnete sie den Winamp-ähnlichen Fensterrahmen um die Vis und lieferte das EMBED-Fenster. Ohne sie gibt es zwei Wege:
   - **(a) eigenes Elternfenster**: irgendein `TPanel`/`TTBXAlignmentPanel` der Form als `EmbedHandle` übergeben und `UseGenVisDrawer = False`. Milkdrop erzeugt dann über den `embedWindowState`-Callback (`MyembedWindow` in `VisDrive2.pas`, Zeile ~654) sein eigenes Kindfenster in diesem Panel. Das ist der kleinste Weg.
   - **(b) `VisDrawer.dll` auftreiben** (war eine Beigabe des TBASSPlayer-Projekts, nicht im Archiv) — nur nötig, wenn man den Winamp-Rahmen inkl. Titelleiste/Werkzeugleiste will.

3. **Die Datenquelle muss laufen**: `TBASSPlayer.FOnNewFFTData` ist der Auslöser für `TimerFFT`; zusätzlich muss `TVisDataThread.SetChannelInfo(...)` (passiert in `Play`) und `VisDataThread.Ready` stimmen. In `Play` steht der FFT-Timer nur an, wenn `Assigned(FOnNewFFTData)` — der Port setzt das Ereignis nirgends, deshalb gibt es auch keine Vis-Daten.

## Risiken / was man einplanen muss

- **Milkdrop 2 rendert mit Direct3D 9 in seinem eigenen Thread.** Es erwartet ein Fenster mit gültigem `HWND` und bekommt seine Größe über `WM_SIZE`. In einem LCL-Panel funktioniert das meist, kann aber bei Repaint/Docking flackern.
- **Milkdrop verhält sich wie ein Winamp-Plugin**: es fragt Version, Playlist, Titel, Playstatus per IPC ab und **beendet sich selbst**, wenn es keine Antwort bekommt. `VisDrive2` beantwortet das bereits — wenn etwas fehlt, sieht man es daran, dass das Vis-Fenster schwarz bleibt.
- **Display-Modi**: Milkdrop kann Desktop- oder Vollbild-Modus schalten und **zerstört dabei sein Fenster** (`WM_DESTROY`, im Code Zeile ~276 kommentiert). `VisDrive2` fängt das ab — beim Testen nicht wundern, wenn das Panel kurz leer ist.
- **Threading**: `TVisDataThread` + Vis-Thread + Milkdrop-Thread. `VisDrive2` arbeitet mit einer `TCriticalSection`; `SetBasicParams` muss diese Sperre bekommen, sonst gibt es Datenrennen.
- **32 Bit**: `vis_milk2.dll` ist i386 (wie bass.dll) — passt zum i386-Build.

## Vorschlag Ablauf (Aufwand ~1–2 Tage inkl. Debuggen)

1. Ein `TPanel` (oder das vorhandene Dock-Panel „Visualisierung", `TBXDockablePanel2`) als Elternfenster reservieren, `Handle` erzeugen lassen.
2. In `TSpieler` eine Methode `VisStarten(PanelHandle)`:
   `SetBasicParams(...)` → `Start_Vis(GetProgDir+'Plugins\vis_milk2.dll', 0, PanelHandle, False, NewStart, 0, ChannelAttrb)`.
3. `Bassplayer1.OnNewFFTData := <Methode>` setzen und in `Play` den `TimerFFT` starten lassen (macht der Code schon, sobald das Ereignis gesetzt ist).
4. Testen mit `vis_test5.dll`/`vis_vsoscilloscope.dll` (liegen auch in `Plugins/`) — die sind einfacher als Milkdrop und zeigen sofort, ob FFT/Fenster stimmen. Erst danach `vis_milk2.dll`.
5. `VisConfig` (Button „Visualisierung einrichten") auf `ShowVisWindow` bzw. Milkdrops eigenes Konfig-Fenster legen.
6. Aufräumen: `Stop_Vis2` beim Beenden (steht in `BASSPlayer.Destroy` schon drin, aber hinter `FGPPluginReady`).

**Fallback**, falls Milkdrop im Panel nicht will: eigenes Top-Level-Fenster (`BorderStyle=bsNone`) als `EmbedHandle`, das man frei positionieren/auf Vollbild schalten kann. Das entspricht eher dem Original-Verhalten (Vis als eigenes Fenster).

---

# 2. Ersatz für die TBX-Dockable-Panels

## Ist-Stand

Die Panels sind `TTBXDockablePanel` in `TTBXMultiDock` (aus `TB2_TBX`), mit TBX-gezeichneten Kopfzeilen, Tab-Gruppen, Andocken an allen Seiten, Minimieren und Merken der Position. **Das funktioniert im Port** — die Frage ist nur, ob man es später durch LCL-Bordmittel ersetzen will (um die TBX-Abhängigkeit zu reduzieren).

## Was Lazarus dafür anbietet

Es gibt zwei Modelle (siehe wiki.freepascal.org/Docking):

| Lösung | Wo | Was sie kann |
|---|---|---|
| **AnchorDocking** (`components/anchordocking/anchordocking.lpk`) | **ist in dieser Lazarus-Installation vorhanden** (`C:\lazarus\components\anchordocking`) | Formen *oder Controls* andocken, Splitters automatisch, Andocken an allen Seiten **und als Tab-Seite**, Kopfzeilen mit Drag, Minimieren, **Layout speichern/laden** (XML über `AnchorDockStorage`), Multi-Monitor, `TAnchorDockHostSite` |
| **Delphi-kompatibles DragDock** (LCL `TDockManager`/`TDockTree` + `TDockTabSet`) | LCL-Kern | VCL-ähnlich: `DockSite`, `OnDockDrop`, `ManualDock`; Tab-Andocken nur mit zusätzlicher `TDockTabSet`; **kein** Layout-Speichern, keine Kopfzeilen (muss man selbst bauen) |
| **EasyDockMgr** (`examples/easydockmgr`) | Beispielcode | historisch, minimal, wird nicht mehr gepflegt |

AnchorDocking ist die einzige Lösung, die funktional an TBX heranreicht (Tab-Gruppen + Layout-Persistenz) und sie ist **ohne Download** verfügbar.

## Was beim Umstieg verloren geht / Arbeit macht

- **Optik**: TBX zeichnet Kopfzeilen im gewählten Theme. AnchorDocking bringt eigene, schlichte Kopfzeilen (anpassbar über `TAnchorDockPanel.Header*`, aber nicht themebar wie TBX).
- **Panelinhalt umziehen**: jedes `TTBXDockablePanel` wird zu einer eigenen `TForm` (AnchorDocking dockt Formen) oder zu einem `TAnchorDockHostSite`-Control. Die ~14 Panels in `ump3.lfm` (Einstellungen, Equalizer, Cover, Playlisten, Log, Metainformation, Schnelleinstellungen, …) müssen einzeln umgehängt werden — inklusive aller `Visible`-Umschaltungen im Code (`TBXDockablePanel*VisibleChanged`, Menüpunkte).
- **Persistenz**: TBX speichert die Dockposition derzeit *nicht* (nur Fenstergröße/Position der Playlist-Fenster in `Emat.ini`). Mit AnchorDocking käme Layout-Speichern neu dazu (Feature-Gewinn).
- **Mischbetrieb**: TBX-Toolbars/Menüs bleiben in jedem Fall — TBX ist nicht nur Docking, sondern die ganze Menü-/Toolbar-Engine. Ein Docking-Ersatz entfernt also nur einen Teil der TBX-Nutzung; der `tbx_d7`-Port bleibt nötig.

## Empfehlung

**Kurzfristig: nichts tun.** Das TBX-Docking läuft im Port, und ein Umstieg kostet Tage für reine Optik/Architektur.

**Wenn die TBX-Abhängigkeit wirklich reduziert werden soll**, ist die Reihenfolge:
1. `AnchorDocking`-Paket einbinden (`anchordocking.lpk` als Anforderung ins `.lpi`) und **ein** unkritisches Panel (z. B. „Log for Debugging") als Form herauslösen → Machbarkeit + Optik prüfen.
2. Wenn das passt: Panels schrittweise, eines pro Commit, umziehen; die `Visible`-Logik über eine kleine Fassade (`procedure ZeigePanel(Id; Sichtbar: boolean)`) entkoppeln, damit der Code nicht an TBX-Namen klebt.
3. Layout-Speichern über `AnchorDockStorage` an `Emat.ini`/eigene XML-Datei hängen.

Aufwand grob: 1 Panel ~1 h, alle 14 Panels inkl. Sonderfälle (Schnelleinstellungen mit eigenen Controls, Metainformation mit PageScroller) ~2–3 Tage.

## Quellen

- https://wiki.freepascal.org/Docking — Überblick über die zwei Andock-Modelle
- https://wiki.freepascal.org/Anchor_Docking — Features, `anchordocking.lpk`, Beispiel `components/anchordocking/miniide/miniide1.lpi`
- lokal: `C:\lazarus\components\anchordocking\anchordocking.lpk`

---

# 3. Nachtrag: Menüleiste zeichnet die Beschriftungen nicht (offen)

Symptom: Die Einträge `Datei / Ansicht / Fenster / Extras / ?` sind unsichtbar,
solange die Maus nicht über dem jeweiligen Eintrag steht.

Bereits ausgeschlossen (alles auf dem Branch `feature/milkdrop-docking` geprüft):

| Test | Ergebnis |
|---|---|
| Theme wechseln (TBX-Theme 22 → 0) | keine Änderung → nicht theme-spezifisch |
| `DrawText`-Shim durch die alte ANSI-Variante ersetzen | keine Änderung → nicht der UTF-8-Shim |
| Fenster-Resize (vollständiger Repaint) | keine Änderung → kein „nie invalidiert"-Problem |
| `ItemTransparency = itDisable` | keine Änderung |
| `Font.Color` der Toolbar fest auf Schwarz | keine Änderung |
| `DisplayMode = nbdmImageAndText` an der Toolbar | Eigenschaft existiert nicht (`EReadError`) |

Messungen mit temporären Logs (wieder entfernt):

- `TTBXItemViewer.Paint` **wird** für `&Datei` durchlaufen, `IsCaptionShown = 1`,
  `ToolbarStyle = 1`, `ClientAreaRect = (0,0,52,23)`, `Font.Height = -13`.
- `TBXUtils.DrawText` wird für `&Datei` **mit** echten Flags aufgerufen
  (`0x100005` = `DT_CENTER|DT_VCENTER|DT_HIDEPREFIX`, `0x100400` beim Messen) —
  der Text wird also tatsächlich gezeichnet.
- Textfarbe am DC: `GetTextColor = 0` (schwarz) — bei allen Captions, auch bei
  denen, die sichtbar sind.
- `Canvas.Font.Color` ist beim Zeichnen **`clDefault` (`$20000000`)**, obwohl die
  Toolbar im LFM `Font.Color = clWindowText` hat — TBX setzt die Farbe über
  `Canvas.Font := GetFont; DoAdjustFont(...)` zurück.

Die Theme-Patches (siehe Commit: 15 Stellen behandeln jetzt zusätzlich
`clDefault` neben `clNone`) sind korrekt, beheben das Symptom aber nicht.

Nächste sinnvolle Schritte:

1. In `TBXUtils.DrawText` (String-Overload) zusätzlich `WindowFromDC(DC)` und
   `GetClipBox(DC)` loggen: Ist der DC ein Fenster-DC oder ein Speicher-DC, und
   ist der Clipbereich für die Caption leer?
2. Falls Speicher-DC: den Blit in `tb2/TB2Item.pas:5485`
   (`BitBlt(DrawToDC, ...)`) prüfen — dort wird ein Double-Buffer-Paint
   zurückkopiert. Wenn dieser Blit scheitert, verschwinden genau die Teile, die
   im Buffer gezeichnet wurden (Captions), während Fenster-DC-Zeichnungen
   (Icons) bleiben.
3. Danach ggf. in `TTBXItemViewer.Paint` die Caption direkt nach dem Blit neu
   zeichnen (Workaround) bis die eigentliche Ursache klar ist.
