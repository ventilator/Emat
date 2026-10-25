![Emat 0.80](<history/Emat 0.80.png>)

# EMAT
_Einfaches MP3-Ausmist-Tool_

## Hintergrund
Im Jahr 2004, meinem 12. Schuljahr, begann das Schülerprojekt Emat. Es war die erste „große“ Anwendung, in die mein Bruder und ich viele Abende am Computer investiert haben. Mehrere Dinge kamen zusammen: günstiger Internetzugang, Delphi-Foren und das Wissen aus dem Informatikunterricht, in dem wir den Umgang mit der IDE Delphi 7 PE und später Delphi 2005 lernten. Dazu kamen der Schmöker „Delphi Praxis“ und viel Zeit nach der Schule.

## Nutzen

* Ich wollte eine Winamp-Alternative, mit der man
  * in Spielen ein Overlay mit dem aktuellen Songtitel einblenden konnte,
  * in der Playlist direkt im Song spulen konnte und
  * einen Song mit ENTF direkt von der Festplatte löschen konnte.
* Ich wollte Spaß am Programmieren haben.

Diese Ziele wurden zu 100 % erreicht. Ein voller Erfolg!

## Archiv

Dieses Repo dokumentiert die Entwicklung anhand von Archiven, die auf alten Backups, in ZIP-Dateien und in alten Entwicklungs-VMs gefunden wurden. Wir waren Schüler und haben Code aus Foren zusammenkopiert. Das Archiv ist daher „so, wie es ist“ zu sehen – mit all seinen Bugs und wunderlichen Programmierparadigmen. Es ist und bleibt ein Schülerprojekt, das stark vom autodidaktischen Lernen geprägt war. Außerdem gab es Input von Freunden und aus Foren.

## Eckpunkte

Entwickelt unter:
* Windows 2000 (Schul PCs), später XP
* Delphi 7 PE, Delphi 2005 und 2010 (Bildungslizenzen aus der Uni)

![Development OS](<history/Development OS.png>)

## Aktueller Stand
![Emat 0.81](<history/Emat 0.81.png>)

Die Entwicklung zog sich über zwei bis drei Jahre und war ein sportlicher Ausgleich zwischen Abiprüfungen und Zivildienst. Mit Beginn meines Studiums wurde die Entwicklung weitgehend eingestellt: Die Software war _gut genug_, und das Studium ging vor.

Es gab einzelne Experimente mit Delphi 2005:

![Development Delphi 2005](<history/Development Delphi 2005.png>)

![Development Delphi 2005 IDE](<history/Development Delphi 2005 IDE.png>)

und mit Delphi 2010:
![Development Delphi 2010](<history/Development Delphi 2010.png>)
Die zugehörige Lizenz war allerdings nur kurzzeitig über die Uni verfügbar und ist längst abgelaufen.
![Development Delphi 2010 unusable in 2026](<history/Development Delphi 2010 unusable in 2026.png>)
Trotzdem lässt sich das Projekt noch in einer alten Windows-XP-VM kompilieren, deren Uhr stehen geblieben ist.
![Development Delphi 2010 still compiles in 2026](<history/Development Delphi 2010 still compiles in 2026.png>)

## Historie

### 0.25

Die Playliste bestand aus Dutzenden von Scrollbars, die den Songtitel als Beschriftung hatten.
![Emat 0.25](<history/Emat 0.25.png>)


### 0.50
![Emat 0.50](<history/Emat 0.50.png>)
Bunte Icons, mit Photoshop 6 erstellt, und erste Experimente mit einer selbst geschriebenen Komponente: einer Playliste mit eingebauter Fortschrittsanzeige.

### 0.75
![Emat 0.75](<history/Emat 0.75.png>)
Desktop-Overlay und Themes

### 0.80
Unterstützung für Winamp-Milkdrop-Visualisierungen und allerlei Spielereien wie Binäruhren.
Screenshot siehe oben.


## Ende

Es wird keine weitere Entwicklung geben. Das Projekt ist längst abgeschlossen, und die dabei gesammelten Erfahrungen sind in mein Arbeitsleben eingeflossen. Es war und ist ein Bildungsprojekt.

## Lazarus-Port — Version 0.90 (EmAIt)

Der Delphi-Quelltext läuft jetzt unter **Lazarus 4.8 / FPC 3.2.2 (i386-win32)**.
Der Port ist ein erster lauffähiger Stand: Die Anwendung startet, zeigt die
TBX-Oberfläche, lädt Playlisten und spielt MP3s über die BASS-DLL ab.

### Bauen

`bass.dll` ist 32 Bit, deshalb braucht der Build den i386-Compiler
(`C:\FPC\3.2.2\bin\i386-win32\ppc386.exe`). Reihenfolge:

```
# 1. TBX-Paket (Ersatz für Toolbar2000 + TBX)
cd third_party/TB2_TBX
lazbuild --compiler=C:/FPC/3.2.2/bin/i386-win32/ppc386.exe --pcp=C:/lazarus --ws=win32 tbx_d7.lpk

# 2. Anwendung
lazbuild --compiler=C:/FPC/3.2.2/bin/i386-win32/ppc386.exe --pcp=C:/lazarus --ws=win32 Emat.lpi
```

Die LCL muss für i386-win32 gebaut sein (`lcl/units/i386-win32`).
`Emat.exe` erwartet `bass.dll` im Programmverzeichnis.

### Was ersetzt wurde

* **Toolbar2000 + TBX** → `third_party/TB2_TBX` (`tbx_d7.lpk`), der
  Lazarus-Port derselben Bibliothek. Menüs, Docks, Themes und Statusleisten
  sind damit wieder originalgetreu vorhanden.
* **LMD-Tools, GR32-Visualisierung, Vis-Plugin-Host, MBDrawer** → entfernt;
  die betroffenen Fenster und Aufrufe sind raus, der Rest nutzt LCL-Standard-
  komponenten.

### Was deaktiviert ist (erster Lauf)

* **Winamp-Input-Plugins** (`Plugins/winamp/in_mp3.dll` …): MP3/OGG werden
  direkt von BASS dekodiert (`Bassplayer1.PluginFirst := False`).
* **Modale Fehlerdialoge** der Player-Unit schreiben ins Debug-Log, damit der
  Start nicht blockiert.
* **Binäruhr, Visualisierung, OSD-Sonderfälle**: vorhanden, aber ungetestet.

### Technische Punkte des Ports

* Alle Quellen sind **UTF-8** (vorher CP1252) — sonst erscheinen Umlaute im
  UI als Kästchen.
* BASS bekommt Dateipfade als **UTF-16 mit `BASS_UNICODE`**; die ANSI-Variante
  scheitert an Umlauten in Pfaden (`BASS_ERROR_FILEOPEN`).
* `AllocateHWnd` muss `LclIntf.AllocateHWnd` sein — die RTL-Version aus
  `Classes` stürzt ab.
* `DELPHI_2007_BELOW` ist projektweit definiert (AnsiString-Semantik).
* Die `.lfm`-Dateien sind aus den `.dfm`-Dateien erzeugt; nicht mehr benötigte
  Delphi-Properties (`TransparentColor` u. a.) wurden entfernt.

## Lizenz

Emat steht unter der **GNU General Public License, Version 2** (siehe
`COPYING.txt`).

### BASS ist nicht GPL

Das Programm nutzt die Audio-Bibliotheken von **un4seen developments**
(`bass.dll`, `basswma.dll`), die **nicht** unter der GPL stehen. Sie werden
unverändert mitgeliefert; ihre Nutzung und Weitergabe richtet sich
ausschließlich nach der Lizenz von un4seen (kostenlos für nicht-kommerzielle
Nutzung, https://www.un4seen.com/). Die GPL von Emat erstreckt sich nicht auf
diese Dateien. Die vollständigen Hinweise stehen in `LICENSE-NOTICE.txt` und
liegen jedem Release-Zip bei.

Wer die DLLs nicht mitliefern möchte, kann `bass.dll` im Programmverzeichnis
durch eine eigene Kopie ersetzen — der Rest des Programms ist davon unberührt.

## Release bauen

```bat
build-release.bat
```

Baut das Paket `third_party/TB2_TBX/tbx_d7.lpk`, danach Emat im Build-Modus
`Release` (`-g- -Xs -O2`, ca. 5 MB statt 53 MB) und packt
`release/Emat-<Tag>-win32.zip` samt SHA256. Die Versionsnummer kommt aus
`git describe` und landet über `source/form/emversion.inc` im Fenstertitel.
Auf GitHub läuft derselbe Weg über `.github/workflows/release.yml`: Tag
pushen (`git push github v0.90-dev-freepascal-port`) und das Release
erscheint mit Zip als Download.
