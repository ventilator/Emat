//Deutsche Sprache für Emat | uk

unit Ulang;

interface

resourcestring
//Captions
  TASKBARSEP = ' — ';
  ARTISTSEP  = ' – ';
  SHUFFLE_ON = 'Shuffle: Aus';
  SHUFFLE_OFF= 'Shuffle: An';
  PAUSECAPTION = 'Pause';
  EMATTITLE    = 'Emat';
  STOPCAPTION  = 'Stopp';
  SAMPLECAPTION  = 'Sample: ' ;
  BITRATECAPTION = 'Bitrate: ';
  VERSIONCAPTION = 'Version: ';
  LENGTHCAPTION  = 'Dauer (ID3): ';
  LAYERCAPTION   = 'Layer: ';
  VOLUMECAPTION  = 'Lautstärke (';
  FORMTITLE = 'Emat ';
  PANELCAPTION   = 'Panelee';
  TOOLBARCAPTION = 'Menüleisten';
  RENAMECAPTION  = 'Umbennen';
  NEWFILENAMECAPTION = 'Neuer Dateiname:';
  CPLSTITELS = ' %d Titel';
  CPLSMB = '%d MB';
  CPLSPlAYLENGTH = '%d Dauer';
  ALWAYSONTOP_OFF = 'Immer im Vordergrund [An]';
  ALWAYSONTOP_ON = 'Immer im Vordergrund [Aus]';
  SELDIR = 'Bitte wählen Sie das Verzeichnis (Ordner) aus, in das die angezeigten Medien kopiert werden sollen.';
  SELDIR_ADD_DIR = 'Bitte wählen Sie ein Verzeichnis aus, dessen Inhalt Sie der Playliste hinzufügen möchten.';

//ERRORS
  DEL_FALSE = '"%s" konnte nicht gelöscht werden.';
  DEL_TRUE = '"%s" wurde erfolgreich gelöscht.';
  SETCOLORERROR = 'Set Color - TBX-Info Error.';
  MENUEERROR  = 'Fehler beim Erstellen der %s-Menüleiste.';
  STARTUPERROR  = 'Emat wurde nicht einwandfrei initialisiert und könnte somit '+
                    'nicht richtig funktionieren.';
  CHEKEDERROR   = 'Fehler beim Ändern des Checked-Status.';
  SAVESETTINGSERROR = 'Fehler beim Speichern der Einstellungen.';
  DIRNOTFOUND = 'Pfad nicht gefunden';
  BASS_INIT_ERROR = 'Das Bass.dll Subsystem konnte nicht initialisiert werden.'+sLineBreak
                   +'Vielleicht kein Audiotreiber geladen?'+sLineBreak
                   +'Die Audiowiederabe kann eingeschränkt sein.';
  HELPFILENOTFOUND = 'Hilfedatei wurde nicht gefunden.';
  ONLYRUNONETIME = 'Emat kann nur einmal gestartet werden.';

//CONFIRMATIONS
  SAVEPLS = 'Soll die Playliste gespeichert werden?';
  SAVEAPPLAUNCHER = 'Soll die Applauncherliste gespeichert werden?';
  GOURL   = 'Es wird nun die url "%s" in Ihrem Browser aufgerufen,'+sLineBreak+
              'dabei werden keinerlei Informationen an G-Software übermittelt.'+
              sLineBreak+'Wollen Sie diesen Vorgang fortsetzen?';
  RESETSETTINGS = 'Wollen Sie wirklich die visuellen Einstellungen der Paneele'+
                    ' sowie der Symbolleisten zurücksetzen?'+sLineBreak+'Wenn '+
                    'ja, müssen Sie Emat anschließend neustarten.';

  NEWPLAYLIST  = 'In eine Playliste können Musikdateien (.mp3, .wma, .ogg, .wav, ...) hinzugefügt werden. Durch einen Doppelklick auf einen Eintrag wird der Titel abgespielt.';
  NEWAPPLAUNCH = 'In eine "Applauncher-Liste" können ausführbare Dateien (.exe, .bat, .cmd, ...) hinzugefügt werden. Durch einen Doppelkick auf einen Eintrag wird die Datei ausgeführt.';

//WARNINGS
  PLSNOTCOMP = 'Die Playliste "%s" wurde mit einer anderen Version vom Emat '+
               'erstellt und ist zu dieser nicht kompatibel.';
  PLSNOTLOAD = 'Die Playliste "%s" ist defekt oder konnte nicht korrekt '+
                 'geladen werden.';
  PLSNOTFOUND  = 'Die Playliste "%s" konnte nicht gefunden werden.';
  FILENOTFOUND = 'Die Datei "%s" konnte nicht gefunden werden.';
  UNABLETORENAME  = 'Die Datei "%s" konnte nicht umbenannt werden.';
  MISSINGFILENAME = 'Es wurde kein Dateiname angegeben.'+sLineBreak+'Bitte '+
                      'Speicherort und Dateinamen angeben.';
  NOFILENAME = 'Kein Dateiname angegeben; Operation abgebrochen.';
  PLSNOTSAVED= 'Die Playliste konnte nicht in "%s" gespeichert werden';

//WEB
  WEBSITE = 'https://github.com/ventilator/Emat';
  UPDATEPAGE = 'http://www.ematupdate.de.gg';

implementation

end.
