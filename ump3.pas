unit ump3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Gliste2, ActnCtrls, ToolWin, ActnMan, ActnMenus, ActnColorMaps,
  StdCtrls, ExtCtrls, ActnList, XPStyleActnCtrls, StdActns, UPathDialog,
  ImgList, ComCtrls, Grids, MPlayer, XProgress, Gauges, mmsystem, registry,
  CoolTrayIcon, Menus, shellapi, UId3tag, Buttons, CustomizeDlg, strutils,
  LMDCustomComponent, LMDGlobalHotKey, dxCore, dxContainer, Exbar, usave, XPMan;


const Version   = '0.5 [beta 1.07.2] ';
      Neuigkeit = '';
      Datenbankversion='2';
      RegHauptPfad='Software\G-Software\Emat\0.58\';
      RegPlaylistenPfad= RegHauptPfad+ 'Playlisten\' ;
      RegEinstellungenPfad= RegHauptPfad+ 'Einstellungen\' ;
      MP3Player_Einleitung='Audiodateien, die zum Transfer bereit sind: ';

      //uk [Lautstärke des MediaP]
      MCI_SETAUDIO = $0873;
      MCI_DGV_SETAUDIO_VOLUME = $4002;
      MCI_DGV_SETAUDIO_ITEM = $00800000;
      MCI_DGV_SETAUDIO_VALUE = $01000000;
      MCI_DGV_STATUS_VOLUME = $4019;

Type
  TID3Tag = record
    ID: string[3];
    Titel: string[30];
    Artist: string[30];
    Album: string[30];
    Year: string[4];
    Comment: string[30];
    Genre: byte;
    dauer: longint; //in sekunden;
    sample: integer;
    bits: byte;
    vers: byte;
    layers: byte;
    ausgelesen: boolean;
end;

type TMp3Eintrag = record
      filename  : string[255];
      path      : string[255];
      size      : integer;
      anzeige   : boolean;
      dauer     : string[7];
      id3tag    : Tid3tag;
     end;

type TDatenbank=ARRAY OF TMp3Eintrag;

type TueberDatenbank=ARRAY OF TDatenbank;
     {
type Tplayliste = record              //Auch in Save ändern
       filename : string[255];
       path     : string[255];
       eintraege : integer;
      end;

type Tplaylisten = array of tplayliste;
       }
//uk [Lautstärke des MediaP]
type
  MCI_DGV_SETAUDIO_PARMS = record
    dwCallback: DWORD;
    dwItem: DWORD;
    dwValue: DWORD;
    dwOver: DWORD;
    lpstrAlgorithm: PChar;
    lpstrQuality: PChar;
  end;

//uk [Lautstärke des MediaP]
type
  MCI_STATUS_PARMS = record
    dwCallback: DWORD;
    dwReturn: DWORD;
    dwItem: DWORD;
    dwTrack: DWORD;
  end;

type
  TFmp3 = class(TForm)
    LESuche: TLabeledEdit;
    ClMap: TXPColorMap;
    AMMB: TActionMainMenuBar;
    ATB: TActionToolBar;
    PathD: TPathDialog;
    ILSymbolleiste: TImageList;
    MediaP: TMediaPlayer;
    Timer: TTimer;
    GVolume: TGauge;
    TBVolume: TTrackBar;
    LTitel: TLabel;
    PBar: TXProgress;
    SaveD: TSaveDialog;
    OpenD: TOpenDialog;
    Timer1: TTimer;
    TrayIcon: TCoolTrayIcon;
    PMtray: TPopupMenu;
    Pause1: TMenuItem;
    vorheriger: TMenuItem;
    nchsterTitel1: TMenuItem;
    Shuffle1: TMenuItem;
    Beenden1: TMenuItem;
    AManager: TActionManager;
    AddOrdner: TAction;
    ASpielen: TAction;
    AShuffle: TAction;
    AStopp: TAction;
    Anext: TAction;
    Apre: TAction;
    APause: TAction;
    PlsSpeichern: TAction;
    PlsLaden: TAction;
    ListeAnhaengen: TAction;
    AZeigeInfo: TAction;
    AListClear: TAction;
    AZeigeSplash: TAction;
    Awebseite: TAction;
    Asettings: TAction;
    ALoeschmodus: TAction;
    Aclose: TAction;
    Abug: TAction;
    Awecker: TAction;
    PMliste: TPopupMenu;
    DateialsWecktonverwenden: TMenuItem;
    Dateiabspielen1: TMenuItem;
    Aumbennen: TMenuItem;
    ASort: TAction;
    ADauerAuslesen: TAction;
    Splitter: TSplitter;
    AFarbresret: TAction;
    GHK_vorher: TLMDGlobalHotKey;
    GHK_pause: TLMDGlobalHotKey;
    GHK_nachher: TLMDGlobalHotKey;
    GHK25: TLMDGlobalHotKey;
    GHK50: TLMDGlobalHotKey;
    GHK75: TLMDGlobalHotKey;
    GHK100: TLMDGlobalHotKey;
    Aupdate: TAction;
    PMtitel: TPopupMenu;
    AExplorer: TMenuItem;
    Atitelmarkieren: TMenuItem;
    Timer2: TTimer;
    Aanmation: TAction;
    Anmiation1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    GBliste1: TGroupBox;
    GBliste2: TGroupBox;
    ASplitt: TAction;
    Amp3playerzeige: TAction;
    dxCbottom: TdxContainer;
    dxCright: TdxContainer;
    GbListe: TdxContainer;
    dxCbar: TdxContainer;
    Blueimg: TImage;
    Splitter1: TSplitter;
    AFindDoppel: TAction;
    GBsuche: TGroupBox;
    Asuchfeldfocus: TAction;
    Ahilfe: TAction;
    PMsidebar: TPopupMenu;
    AListeAusSidbarLoeschen: TAction;
    AListeAusSidbarLoeschen1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure AddOrdnerExecute(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure AnextExecute(Sender: TObject);
    procedure PBarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ASpielenExecute(Sender: TObject);
    procedure APauseExecute(Sender: TObject);
    procedure AStoppExecute(Sender: TObject);
    procedure PlsSpeichernExecute(Sender: TObject);
    procedure PlsLadenExecute(Sender: TObject);
    procedure ListeAnhaengenExecute(Sender: TObject);
    procedure TBVolumeChange(Sender: TObject);
    procedure LESucheChange(Sender: TObject);
    procedure ApreExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AZeigeInfoExecute(Sender: TObject);
    procedure LBPLDblClick(Sender: TObject);
    procedure AListClearExecute(Sender: TObject);
    procedure AZeigeSplashExecute(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure Beenden1Click(Sender: TObject);
    procedure AwebseiteExecute(Sender: TObject);
    procedure AShuffleExecute(Sender: TObject);
    procedure AsettingsExecute(Sender: TObject);
    procedure ALoeschmodusExecute(Sender: TObject);
    procedure LTitelMouseLeave(Sender: TObject);
    procedure LTitelMouseEnter(Sender: TObject);
    procedure TrayIconMinimizeToTray(Sender: TObject);
    procedure AcloseExecute(Sender: TObject);
    procedure AbugExecute(Sender: TObject);
    procedure AweckerExecute(Sender: TObject);
    procedure AumbennenClick(Sender: TObject);
    procedure ASortExecute(Sender: TObject);
    procedure ADauerAuslesenExecute(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure AFarbresretExecute(Sender: TObject);
    procedure GHK_pauseKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GHK_nachherKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GHK_vorherKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GHK100KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GHK25KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GHK50KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GHK75KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AupdateExecute(Sender: TObject);
    procedure PBarChange(Sender: TObject);
    procedure AExplorerClick(Sender: TObject);
    procedure AtitelmarkierenClick(Sender: TObject);
    procedure DateialsWecktonverwendenClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure AanmationExecute(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure GBliste1Enter(Sender: TObject);
    procedure GBliste2Enter(Sender: TObject);
    procedure ASplittExecute(Sender: TObject);
    procedure SplitterMoved(Sender: TObject);
    procedure Amp3playerzeigeExecute(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);

    procedure AFindDoppelExecute(Sender: TObject);
    procedure LESucheKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AsuchfeldfocusExecute(Sender: TObject);
    procedure AhilfeExecute(Sender: TObject);
    procedure LTitelClick(Sender: TObject);

  private
    procedure ErschaffeGliste;
    procedure GetFilesInDirectory(ADirectory, AMask: String; ARekursiv: Boolean);
    function  unterstuezteDatei(endung: string): boolean;
    procedure ArrayZuListe;
    procedure Weiterschalten;
    procedure ArrayLaden(Dateiname: string);
    procedure ArraySpeichern(Dateiname: string);
    procedure Umbennenen(Index: integer);
    procedure Zurueckschalten;
    function  ListenIndexZuArrayIndex(Index: integer): integer;
    procedure LadeReg; 
    procedure SpeicherRegLetztePlaylist;
    function ArrayIndexZulistenIndex(Index: integer): integer;
    procedure ArrayLeeren;
    procedure LoescheArrayElement(index: integer);
    procedure ListenRechtsKlick(index, x, y: integer);
    procedure ArraySortieren;
    procedure ArraySortierenTausch(var a, b: TMp3Eintrag);
    procedure DauerAuslesen(index: integer);
    procedure ErschaffeGliste2;
    procedure GlisteKeyDown(Key:word; Shift:tshiftstate);
    procedure Gliste2DragOver(Sender, Source: Tobject; x, y: integer;
      State: TDragState; var accept: boolean);
    procedure Gliste2DragDrop(Sender, Source: Tobject; x, y: integer);
    procedure SetMPVolume(MP: TMediaPlayer; Volume: Integer);
    procedure SammelPlaylistNamen(plsname: string);
    procedure ErstelleRegNeu;
    procedure Suche(Name: string;teilmengenseparator:integer);
    procedure Liste1Aktiv(Sender:TObject);
    procedure Liste2Aktiv(Sender:TObject);
    function ListenIndexZuArrayIndex_Mp3Daten(Index: integer): integer;
    procedure ErstelleRegPlaylistenNeu;
    procedure LoeschePlaylistenReg;
    function DatensatzInArray(Daten: Tmp3Eintrag;
      ArrayIndex: integer): boolean;
    procedure RelativeListenteilung;
    procedure ItemClick(Sender: TObject; Id: Integer);
    procedure Playlistenlisteausgeben;
    function filesizetostr(int: real): string;
    procedure FindeDoppelteMedien;


    { Private-Deklarationen }
  public
    procedure Spiele(index: integer);
    procedure Spule(prozent: real);
    procedure Loeschen;
    procedure SetColor;
    procedure ElementMarkieren(markiert:integer);
    function extractrealfilename(filename: string): string;
    procedure Sidebarskin;
    { Public-Deklarationen }
  end;

var
  Fmp3: TFmp3;
  GListe: ^TGliste2;
  GListe1, GListe2: TGliste2;
  Mp3s: TDatenbank;
  Mp3Daten: TueberDatenbank;
  Reg: TRegistry;
  Playlisten :TPlaylisten;
  ID3 :TID3;
  FExBar: TExBar;
  Save: TSave;
implementation

uses UInfo, Ustart, Uoption, Ubug, Uwarte, Ulaut, ump3player, Uvideo;

{$R *.dfm}
var letzterTitel, aktuellerTitel, aktuellePlayliste, aktuellGeladeneListe,
    Weckton,Sidebarpfad,Suchpuffer0,Suchpuffer1 :string;
    minimiert, shuffle : boolean;
    defektIndex,aktiveListe,iconnummer :integer;
    listenaufteilung : real;

procedure TFmp3.FormCreate(Sender: TObject);

begin
  Application.ShowMainForm:=false;
  trayicon.Icon:=Application.Icon;

  Save:=TSave.Create('Emat.ini');
  GListe:=@Gliste1;
  aktiveListe:=0;

  SetLength(Mp3Daten,2);    //Zwei Überplaylisten
  SetLength(Mp3Daten[0],0);
  SetLength(Mp3Daten[1],0);

  caption:='Emat '+Version+'| Einfaches Mp3 Ausmist-Tool | '+Neuigkeit;
  Application.Title:=fmp3.Caption; //uk
  Fmp3.DoubleBuffered:=true;
  PBar.Caption:='';
  Iconnummer:=25; //uk
  OpenD.Filter:='Emat Playlist (*.EmatPls'+Datenbankversion+')|*.EmatPls'+Datenbankversion;
  SaveD.Filter:=OpenD.Filter;
  SaveD.DefaultExt:='.EmatPls'+Datenbankversion;

  randomize;                                  //uk damit Shuffle geht

  ErschaffeGliste;
  ErschaffeGliste2;

  SetLength(playlisten,0);

  LadeReg;
  gbliste1.width:=gbliste.Width;

  id3:=tid3.Create;

  minimiert:=false;


  SetLength(Mp3Daten[0],High(Mp3s)+1);           //1. Überliste füllen
  Mp3Daten[0]:=Mp3s;

  
  listenaufteilung:=0.5;

  //sidebar uk
  FExBar := TExBar.Create(Self);
  with FExBar do
   begin
    BeginUpdate;
    SetSkin(BlueImg.Picture.Bitmap);
    GroupIcons := ILSymbolleiste;
    ItemIcons := ILSymbolleiste;
    Parent := dxCbar;
    Align := alclient;
    PopupMenu := PMsidebar;
    OnMenuItemClick := ItemClick;

    ExGroups.Add('Playlisten').AddMenuItem('Liste laden... (Strg+O)','',0,22);
    ExGroups.Add('Metainformationen');
    
    EndUpdate;
   end;

  playlisten:=save.L_Playlisten;
  Playlistenlisteausgeben;
end;

procedure TFmp3.Liste1Aktiv(Sender:TObject);
var i:integer;
begin
if aktiveListe<>0 then
begin
   SetLength(Mp3Daten[1],High(Mp3s)+1);
   for i:=0 to high(mp3s) do
   Mp3Daten[1,i]:=Mp3s[i];
   SetLength(Mp3s,High(Mp3Daten[0])+1);
   for i:=0 to High(Mp3Daten[0]) do
   Mp3s[i]:=Mp3Daten[0,i];
   Gliste.aktiv:=false;
   Gliste.Draw;
   Gliste:=@Gliste1;
   Gliste.aktiv:=true;
   ArrayZuListe;
   aktiveListe:=0;
   Suchpuffer1:=LESuche.text;
   LESuche.text:=Suchpuffer0;


end;
end;


procedure TFmp3.Liste2Aktiv(Sender:TObject);
var i:integer;
begin
if aktiveListe<>1 then
begin
   SetLength(Mp3Daten[0],High(Mp3s)+1);
   for i:=0 to high(mp3s) do
   Mp3Daten[0,i]:=Mp3s[i];
   SetLength(Mp3s,High(Mp3Daten[1])+1);
   for i:=0 to High(Mp3Daten[1]) do
   Mp3s[i]:=Mp3Daten[1,i];
   Gliste.aktiv:=false;
   Gliste.Draw;
   Gliste:=@Gliste2;
   Gliste.aktiv:=true;
   ArrayZuListe;
   aktiveListe:=1;
   Suchpuffer0:=LESuche.text;
   LESuche.text:=Suchpuffer1;

end;
end;

procedure TFmp3.ErschaffeGliste;

begin
  GListe1:=TGliste2.create(fmp3);
  GListe1.Initialisize(40,90);
  GListe1.Parent:=GBListe1;
  GListe1.Align:=alclient;
  GListe1.OnRechtsklick:=ListenRechtsKlick;
  Gliste1.OnKeyDown:=GlisteKeyDown;
  Gliste1.OnDoppelklick:=Spiele;
  Gliste1.OnSpulen:=Spule;
  Gliste1.OnElementMarkieren:=ElementMarkieren;
  Gliste1.OnEnter:=Liste1Aktiv;
  Gliste1.aktiv:=true;
end;

procedure TFmp3.ErschaffeGliste2;
  begin
  Gliste2:=TGliste2.create(fmp3);
  GListe2.Initialisize(40,90);
  GListe2.Align:=alclient;
  GListe2.Parent:=GBListe2;
  GListe2.OnDragOver:=Gliste2DragOver;
  Gliste2.OnDragDrop:=Gliste2DragDrop;
  GListe2.OnRechtsklick:=ListenRechtsKlick;
  Gliste2.OnKeyDown:=GlisteKeyDown;
  Gliste2.OnDoppelklick:=Spiele;
  Gliste2.OnSpulen:=Spule;
  Gliste2.OnElementMarkieren:=ElementMarkieren;
  Gliste2.OnEnter:=Liste2Aktiv;
  Gliste2.aktiv:=false;
  end;

procedure TFmp3.GlisteKeyDown(Key:word;Shift:tshiftstate);
begin
  case key of
  vk_delete: Loeschen;
  vk_return : aspielenexecute(fmp3);
  vk_space : ApauseExecute(fmp3);
  end;

end;

procedure TFmp3.LadeReg;
var FavListe: string;
begin
  Reg := TRegistry.Create;

  try
  if Reg.OpenKey(RegHauptPfad,false) then begin

       FavListe:=Reg.ReadString('Letzteliste'); 
       if (FavListe<>'') and (FileExists(FavListe)) then
       begin
          ArrayLaden( FavListe );
          aktuellePlayliste:=FavListe;
       end;
    //   LadeRegPlaylistenListe;

  end else begin

    ErstelleRegNeu;

  end;

  except
   Reg.DeleteKey(RegHauptPfad);
   if messagedlg('Es tut mir leid, sie müssen Emat neustarten.',mtwarning,[mbok,mbignore],0)=mrok then halt;
  end;
  Reg.CloseKey;
end;



procedure TFmp3.ErstelleRegNeu;
begin
    Reg.DeleteKey('Software\G-Software\Emat\');
    Reg.OpenKey(reghauptpfad,true);
    Reg.CloseKey;
    ErstelleRegPlaylistenNeu;
end;

procedure TFmp3.ErstelleRegPlaylistenNeu;
begin
    Reg.DeleteKey(RegPlaylistenPfad);
    Reg.OpenKey(regplaylistenpfad,true);
    Reg.WriteInteger('Playlisten',0);
    Reg.CloseKey;
end;

procedure TFmp3.LoeschePlaylistenReg;
begin
  messagedlg('Fehler: Registryzugriff auf Playlistenliste fehlerhaft'+#13+
              'Die Playlistenhistory wird leider gelöscht'
              ,mtwarning,[mbok],0);
  try Reg.CloseKey
  finally
  Reg := TRegistry.Create;
  Reg.DeleteKey('RegPlaylistenPfad');
  Reg.CloseKey;
  ErstelleRegPlaylistenNeu;
  end;
end;

procedure TFmp3.SammelPlaylistNamen( plsname:string );
var i     : integer;
    flag  : boolean;
begin
 flag:=true;
 for i:=0 to high(playlisten) do
 begin
  if (playlisten[i].path+playlisten[i].filename)=plsname then
  begin
  playlisten[i].eintraege:=High(mp3s)+1;                       //experimentell
  flag:=false;
  break;
  end;
 end;

 if flag then
 begin
  SetLength(playlisten,high(playlisten)+2);
  playlisten[high(playlisten)].filename:=extractfilename(plsname);
  playlisten[high(playlisten)].path:=extractfilepath(plsname);
  playlisten[high(playlisten)].eintraege:=High(mp3s)+1;

  Playlistenlisteausgeben;
 end;

end;

procedure TFmp3.Playlistenlisteausgeben;
var i    : integer;
begin
  FExbar.BeginUpdate;
  Fexbar.ExGroups.Delete(0);
  Fexbar.ExGroups.Add('Playlisten'(*, true*)).AddMenuItem('Liste laden... (Strg+O)','',0,22);
  //Fexbar.ExGroups[1].GroupIconIndex := 10;
  Fexbar.ExGroups.Exchange(0,1);

  for i:=0 to high(playlisten) do
  begin
    FExbar.ExGroups[0].AddMenuItem(extractrealfilename(playlisten[i].filename)+' ('+
                        inttostr(playlisten[i].eintraege)+')','',i+10,-1);
  end;
  FExbar.EndUpdate;
  FExbar.Repaint;
end;



procedure TFmp3.SpeicherRegLetztePlaylist;
begin
   Reg.OpenKey(RegHauptPfad,false);
   Reg.WriteString( 'Letzteliste' , aktuellePlayliste );
   Reg.WriteInteger('Left',Left);
   Reg.WriteInteger('Top',Top);
   Reg.WriteInteger('Width',Width);
   Reg.WriteInteger('Height',Height);


   Reg.CloseKey;
end;

procedure TFmp3.SetColor;
begin

  Clmap.SelectedColor:=Clmap.Color;
  PBar.BackgroundColor:=ClMap.Color;
  PBar.BarColor:=clblack;
  fmp3player.Progress.BackgroundColor:=ClMap.Color;
  fmp3player.Progress.BarColor:=clblack;
  PBar.GradientColor:=ClMap.Color;
  GVolume.ForeColor:=ClMap.SelectedColor;
  
  Gliste1.clscrollbar:=ClMap.Color;
  Gliste1.clmouseover:=ClMap.Color;
  Gliste1.clfortschritt:=ClMap.Color;
  Gliste1.clscrollbar2:=ClMap.Color;
  Gliste1.clfortschrittrahmen:=Clblack;

  Gliste2.clscrollbar:=ClMap.Color;
  Gliste2.clmouseover:=ClMap.Color;
  Gliste2.clfortschritt:=ClMap.Color;
  Gliste2.clscrollbar2:=ClMap.Color;
  Gliste2.clfortschrittrahmen:=Clblack;

  Application.HintColor:=ClMap.Color;


  //Schriftfarbe ändern                 uk
 Fmp3.Font.Color:=ClMap.FontColor;
 Fsettings.Font.Color:=ClMap.FontColor;
 Fbug.Font.Color:=ClMap.FontColor;
 Fstart.Font.Color:=ClMap.FontColor;
 Finfo.Font.Color:=ClMap.FontColor;
 Fwarte.Font.Color:=ClMap.FontColor;
 Fmp3player.Font.Color:=ClMap.FontColor;
 Gliste1.cltext:=ClMap.FontColor;
 Gliste2.cltext:=ClMap.FontColor;


//Fensterfarbe ändern                  uk
 Fmp3.Color:=ClMap.Color;
 Fsettings.Color:=ClMap.Color;
 Fbug.Color:=ClMap.Color;
 Fwarte.Color:=ClMap.Color;
 Flaut.Color:=ClMap.Color;
 Fmp3player.Color:=ClMap.Color;
 TBvolume.SetFocus;  //wegen dem bug mit der color ausenrum
 LEsuche.SetFocus;    //und zurück auf's suchfeld geht aber nur beim ersten mal...

//Schriftart
 Fmp3.Font.Name:=fsettings.LMDFontCombo.SelectedFont;
 Fsettings.Font.Name:=fsettings.LMDFontCombo.SelectedFont;
 Fbug.Font.Name:=fsettings.LMDFontCombo.SelectedFont;
 Fstart.LVersion.Font.Name:=fsettings.LMDFontCombo.SelectedFont;
 Finfo.Font.Name:=fsettings.LMDFontCombo.SelectedFont;
 Fwarte.Font.Name:=fsettings.LMDFontCombo.SelectedFont;
 Fmp3player.Font.Name:=fsettings.LMDFontCombo.SelectedFont;
 Fexbar.Font.Name:=fsettings.LMDFontCombo.SelectedFont;

 Gliste1.schriftart:=fsettings.LMDFontCombo.SelectedFont;
 Gliste2.schriftart:=fsettings.LMDFontCombo.SelectedFont;
 Fexbar.Font.Name:=fsettings.LMDFontCombo.SelectedFont;

 Sidebarskin;
end;


procedure TFMp3.ArraySpeichern(Dateiname:string);
  var Datei: file of TMp3Eintrag;
      i:integer;
begin
  Liste1Aktiv(fmp3);                                 //vielleicht später ändern
  AssignFile(Datei,Dateiname);
   try
      Rewrite(Datei)
   except
      showmessage('Dateizugriffsfehler');
      exit;
   end;
   Reset(Datei);
   for i:=0 to High(Mp3s) do
   Write(Datei,MP3s[i]);

   CloseFile(Datei);

   SammelPlaylistNamen(dateiname);
end;

procedure TFMP3.ArrayLaden( Dateiname:string );   //eigentlich Array anhängen
  var Datei: file of TMp3Eintrag;
      i:integer;
begin
  if fileexists( dateiname ) then begin

  AssignFile(Datei,Dateiname);
  Reset(Datei);

  for i:=0 to FileSize(Datei)-1 do begin

    SetLength(Mp3s,High(Mp3s)+2);      //Array vergrößern
    Read(Datei,Mp3s[High(Mp3s)]);      //in letztes Element reinschreiben
    Mp3s[High(Mp3s)].anzeige:=true;    //und anzeigen
  end;

  ArrayZuListe;

  end else begin
    showmessage(' Die angegebene Playliste existiert nicht. ' +#13+ '[Emat 0.5 beta]');

  end;
end;


procedure TFmp3.AddOrdnerExecute(Sender: TObject);

begin
  if PathD.Execute then begin

    GetFilesInDirectory(PathD.PathName,'*.*',true);
    ArrayZuListe;
    //ADauerAuslesenExecute(fmp3);
  end;


end;

procedure TFmp3.GetFilesInDirectory(ADirectory: string; AMask: String; ARekursiv: Boolean);
var
  SR: TSearchRec;

begin

  if (ADirectory<>'') and (ADirectory[length(ADirectory)]<>'\') then
    ADirectory:=ADirectory+'\';

  if (FindFirst(ADirectory+AMask,faAnyFile-faDirectory,SR)=0) then begin
    repeat
      if (SR.Name<>'.') and (SR.Name<>'..') and (SR.Attr<>faDirectory) then
              begin
                //Daten dem dyn. Array zuweisen
                if unterstuezteDatei(ExtractFileExt(SR.Name)) then begin

                SetLength(Mp3s,High(Mp3s)+2);  //Array vergrößern

                Mp3s[High(Mp3s)].filename:=SR.Name;
                Mp3s[High(Mp3s)].path:=ADirectory;
                Mp3s[High(Mp3s)].size:=SR.Size;
                Mp3s[High(Mp3s)].anzeige:=true;
                end
              end

    until FindNext(SR)<>0;
    FindClose(SR);
  end;

  if ARekursiv then
    if (FindFirst(ADirectory+'*.*',faDirectory,SR)=0) then
    begin
      repeat
        if (SR.Name<>'.') and (SR.Name<>'..') then
          GetFilesInDirectory(ADirectory+SR.Name,AMask,True);
      until FindNext(SR)<>0;
      FindClose(SR);
    end;

end;

function TFmp3.unterstuezteDatei(endung:string):boolean;
begin
  endung:=lowercase(endung);              //großgeschriebene Dateiendungenen würden sonst nicht mitausglesen
  result:=false;
  if (endung = '.mp3') or                 //Aufzählungstyp erforderlich
     (endung = '.wma') or                 //aber nicht anwendbar, weil
     (endung = '.mid') or                 //Punkte in Mengentypen so einfach nicht akzeptiert
     (endung = '.wav') or                 //werden
     (endung = '.wave') or             //sicherlich!   noch nie gesehen, aber uk
     (endung = '.mpg') or
     (endung = '.mpeg') or
     (endung = '.avi')
  then result:=true;

end;

procedure TFmp3.ArrayZuListe;
var i:integer;
begin
 GListe.ListenReset;
 {Gliste.markiertesElement:=0;
 Gliste.fortschrittlichesElement:=0;    }


 FOR i:=0 TO High(Mp3s) DO
 begin
   IF Mp3s[i].anzeige
   then
   GListe.Add( Mp3s[i].dauer , extractrealfilename ( Mp3s[i].Filename ) ,filesizetostr (Mp3s[i].size) );
   end;

 GListe.Draw;
end;

procedure TFmp3.Spiele(index:integer);
  var medium, endung, TextNeu: string;
      dauer,tempfortschritt: integer;
begin
  index:=ListenIndexZuArrayIndex(index);

 if Mp3s[index].dauer='defekt'
  then
  begin
    if defektIndex=index then
      begin
      showmessage('Alle Medien in Ihrer Playliste sind leider mit Emat'+#13+
                'inkompatibel und keines kann daher abgespielt werden.');
      exit;
      end;
    if defektIndex=-1
    then defektIndex:=index;

    weiterschalten
  end
 else
  begin
  defektIndex:=-1;

  medium:=Mp3s[index].path+Mp3s[index].filename;

  if fileexists(medium) then
  begin

  if letzterTitel<>MediaP.FileName then
    letzterTitel:=MediaP.Filename;

  MediaP.FileName:=medium;
  MediaP.Open;

  SetMPVolume(MediaP, TBVolume.Position);

  endung:=ExtractFileExt(medium);                //uk
  if (endung='.mpg') or                          //uk
     (endung='.mpeg') or                         //uk
     (endung='.avi')                             //uk
   then
   begin
    Fvideo.Caption:=MediaP.FileName;               //uk
    MediaP.Display:=fvideo.panel1;                 //uk
    MediaP.DisplayRect:=Fvideo.Panel1.ClientRect;  //uk
    Fvideo.Caption:='Emat-Videofenster ['+extractrealfilename( extractfilename (medium) ) +']';
    Fvideo.Show;
   end                               //uk
   else Fvideo.Hide;                             //uk

  MediaP.Play;

  Timer.Enabled:=true;

  TextNeu:=Medium;
  while Ltitel.Canvas.TextWidth(TextNeu)>pbar.Left+pbar.Width-Ltitel.Canvas.TextWidth('...') do
    begin
    TextNeu:=copy(TextNeu,2,Length(textNeu));

    end;

  if length(medium)<>length(textneu)
  then LTitel.Caption:='...'+TextNeu
  else LTitel.Caption:=TextNeu;


  LTitel.Hint:=Medium+#13'Linksklick: Markieren'+#13+'Rechtsklick: Explorer am Speicherort öffnen';

  aktuellerTitel:=Medium;

  Trayicon.Hint:='Emat ['+extractrealfilename( extractfilename (medium) ) +']'; //uk
  Application.Title:=Trayicon.Hint;                                             //uk

  GListe.SetFortschrittlichesElement( ArrayIndexZuListenIndex (index) );

  ElementMarkieren(GListe.fortschrittlichesElement);

  if mp3s[index].dauer='' then
  begin
    dauer:=MediaP.Length div 1000;
    mp3s[index].dauer:= inttostr(dauer div 60)+':'+(format('%.2d',[dauer mod 60]));
    tempfortschritt:=gliste.fortschrittlichesElement;           //optimale Lösung?
    ArrayZuListe;
    gliste.fortschrittlichesElement:=tempfortschritt;
  end;

  end
  else begin
  Weiterschalten;
  end;

  end;
end;

procedure TFMp3.Spule(prozent:real);
begin
 MediaP.Position:=round(MediaP.Length*prozent);
 MediaP.Play;
 PBar.Position:=round(prozent*100);
end;

procedure TFmp3.Weiterschalten;
begin
 if shuffle then  begin
   spiele( random ( GListe.liste.Count ) );

 end else begin
    if GListe.fortschrittlichesElement=GListe.liste.Count-1
    then  Spiele( 0 )
    else  Spiele( GListe.fortschrittlichesElement + 1 );

  end;
end;

function TFmp3.filesizetostr(int:real):string;
begin
  result:=Format('%.0n', [int]);
end;

procedure TFmp3.TimerTimer(Sender: TObject);
var fortschritt:real;
    seklaenge:integer;
begin
   try

   if MediaP.Error<>0 then Weiterschalten;

   fortschritt:= MediaP.Position / MediaP.Length;
   Gliste.SetFortschritt(fortschritt);

   PBar.Position:=round(fortschritt*100);
   seklaenge:=trunc(MediaP.Position/1000);
   PBar.Caption:=inttostr(seklaenge div 60)+':'+(format('%.2d',[seklaenge mod 60]));

   if MediaP.Position >= MediaP.Length
   then Weiterschalten;

   except
   MediaP.Close;
   Weiterschalten;
   end;
end;

procedure TFmp3.FormResize(Sender: TObject);
begin
if not ASplitt.Checked
 then
  begin
   GBliste1.width:=GBliste.clientwidth;

  end
 else
  begin
   RelativeListenteilung;

  end;
end;


procedure TFmp3.AnextExecute(Sender: TObject);
begin
   Weiterschalten;
end;

procedure TFmp3.PBarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if Timer.Enabled then begin
 Spule(x/PBar.Width);
 end;

end;

procedure TFmp3.ASpielenExecute(Sender: TObject);
begin
  Spiele (Gliste.markiertesElement);
end;

procedure TFmp3.APauseExecute(Sender: TObject);
begin
   MediaP.Pause;
end;


procedure TFmp3.AStoppExecute(Sender: TObject);
begin
 try
   MediaP.Close;
 finally                                     //braucht man das wirklich?
   GListe.SetFortschritt(0);
   GListe.fortschrittlichesElement:=-1;
   Timer.Enabled:=false;
   PBar.Caption:='';         //uk
   LTitel.Caption:='';       //uk
   aktuellerTitel:='';
   Application.Title:=fmp3.Caption; //uk
 end;


end;

procedure TFmp3.PlsSpeichernExecute(Sender: TObject);
begin
  if SaveD.Execute then begin
    ArraySpeichern(SaveD.FileName);
    SammelPlaylistNamen(SaveD.FileName);
  end;
end;

procedure TFmp3.PlsLadenExecute(Sender: TObject);
begin
 if OpenD.Execute then
  begin
   SetLength(Mp3s,0);
   ArrayLaden(OpenD.FileName);
   aktuellePlayliste:=OpenD.FileName;
   SammelPlaylistNamen(OpenD.FileName);
  end;

end;

procedure TFmp3.ListeAnhaengenExecute(Sender: TObject);
begin
 if OpenD.Execute then
  begin
   ArrayLaden(OpenD.FileName);
  end;
end;


//uk [für Latutstärke des MediaP]
procedure TFmp3.SetMPVolume(MP: TMediaPlayer; Volume: Integer);
  { Volume: 0 - 1000 }
var 
  p: MCI_DGV_SETAUDIO_PARMS; 
begin 
  { Volume: 0 - 1000 } 
  p.dwCallback := 0;
  p.dwItem := MCI_DGV_SETAUDIO_VOLUME; 
  p.dwValue := Volume; 
  p.dwOver := 0; 
  p.lpstrAlgorithm := nil; 
  p.lpstrQuality := nil; 
  mciSendCommand(MP.DeviceID, MCI_SETAUDIO, 
    MCI_DGV_SETAUDIO_VALUE or MCI_DGV_SETAUDIO_ITEM, Cardinal(@p)); 
end; 


function TFmp3.ListenIndexZuArrayIndex(Index:integer):integer;
  var j,zaehler:integer;
begin
  zaehler:=-1;
  j:=-1;
  repeat
    inc(j);
    if j>high(Mp3s) then begin showmessage('Fehler [Listenende erreicht->erstes Element gewählt]'); result:=0; exit end;
    if Mp3s[j].anzeige then inc(zaehler);
 until zaehler=index;

 result:=j;
end;
    //Weil OnDragDrop das OnEnter Ereignis auslöst kann das normale nicht genutzt werden
function TFmp3.ListenIndexZuArrayIndex_Mp3Daten(Index:integer):integer;
  var j,zaehler:integer;
begin
  zaehler:=-1;
  j:=-1;
  repeat
    inc(j);
    if Mp3Daten[0,j].anzeige then inc(zaehler);
 until zaehler=index;

 result:=j;
end;

function TFmp3.ArrayIndexZulistenIndex (Index:integer) :integer;
  var i,zaehler:integer;
begin
 zaehler:=-1;

 for i:=0 to index do begin
 if Mp3s[i].anzeige then inc(zaehler);
 end;

 result:=zaehler;
end;

procedure TFmp3.Umbennenen(Index:integer);
var  altname,neuname,endung:string;
     datei:file;
     i:integer;
begin               
  i:=ListenIndexZuArrayIndex(Index);

  altname:=Mp3s[i].path + Mp3s[i].filename;
  endung:=ExtractFileExt(Mp3s[i].Filename);
  neuname:=extractrealfilename ( Mp3s[i].Filename );

if inputquery('Umbenenner','Neuer Dateiname:',neuname) then
  begin
  try assignfile( datei , altname );
      rename( datei , Mp3s[i].path+neuname+endung );
      Mp3s[i].filename:=neuname+endung
  except
     MessageDlg('Die Datei "'+ altname +'" konnte nicht umbenannt werden.' ,
                mtWarning , [mbOk] , 0 );
  end;
  ArrayZuListe;
  if fsettings.cbplaylistsave.checked then
  ArraySpeichern ( aktuellgeladeneListe );
  end;

end;



procedure TFmp3.TBVolumeChange(Sender: TObject);
begin
//Quelle: http://www.swissdelphicenter.ch/de/showcode.php?id=618

Flaut.TBTrayVolume.Position:=1000-TBVolume.Position;
TBVolume.Hint:='Lautstärke ('+inttostr(TBVolume.Position div 10)+'%)';


SetMPVolume(MediaP, TBVolume.Position);
GVolume.Progress:=TBVolume.Position;
end;

procedure TFmp3.LESucheChange(Sender: TObject);
var i:integer;
    name:string;
begin
    for i:=0 to high(mp3s) do
    Mp3s[i].anzeige:=true;

    name:=(sender as TLabeledEdit).text;
    name:=trim(name);
    name:=name+' ';
              //Leerzeichen siehe unten (um Ende zu markieren)
    if name <> ' '
    then Suche(Name,1);

    ArrayZuListe;
    GListe.ersterEintrag:=0;

    GListe.fortschrittlichesElement:=-1;
    for i:=0 to high(mp3s) do
    begin
     if ((mp3s[i].path+mp3s[i].filename)=aktuellerTitel) and (mp3s[i].anzeige)
     then GListe.fortschrittlichesElement:=ArrayIndexZuListenIndex(i);
    end;

end;

procedure TFmp3.Suche(Name:string;teilmengenseparator:integer);
var i,leerzeichenpos:integer;
    aktuellerName:string;
begin
  aktuellerName:='';
  leerzeichenpos:=posex(' ',name,teilmengenseparator);

  if (leerzeichenpos>0) and (leerzeichenpos<length(name))
  then
    begin
      suche(name,posex(' ',name,teilmengenseparator)+1);
      i:=teilmengenseparator;
       repeat
        aktuellerName:=aktuellerName+name[i];
        inc(i)
       until (name[i]=' ');
    end
  else
   begin
   i:=teilmengenseparator;
    repeat
      aktuellerName:=aktuellerName+name[i];
      inc(i)
    until (name[i]=' ');
   end;

//  showmessage('suche nach: "'+aktuellername+'" mit separator '+inttostr(teilmengenseparator));
  aktuellerName:=trim(aktuellerName);

  for i:=0 to high(mp3s) do
  begin
    if ( pos( ansiuppercase( AktuellerName ) ,
         ansiuppercase( extractrealfilename ( Mp3s[i].Filename ) )) =0 )
         and
       ( pos( ansiuppercase( AktuellerName ) ,
         ansiuppercase( extractrealfilename ( Mp3s[i].Path ) )) =0 )
    then
       Mp3s[i].anzeige:=false;

  end;


end;

procedure TFmp3.ApreExecute(Sender: TObject);
begin
   Zurueckschalten; 
end;

procedure TFmp3.Zurueckschalten;
var i:integer;
begin
    for i:=0 to high(mp3s) do begin

    if pos( ansiuppercase( letzterTitel ) , ansiuppercase( mp3s[i].path + mp3s[i].filename) )>0
    then begin
      Spiele(i);
      break;
    end;

    end;

end;

procedure TFmp3.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 case key of
 vk_f9 : Apre.Execute;
 vk_f10: AStopp.Execute;
 vk_f11: APause.Execute;
 vk_f12: ANext.Execute;
 74    : Asuchfeldfocus.Execute //uk
 end;
end;

function TFmp3.extractrealfilename(filename :string) :string;

begin
  Result:= Copy( Filename , 0 , length(Filename)-length( ExtractFileExt(Filename) ) )
end;

procedure TFmp3.FormPaint(Sender: TObject);
begin
GListe.Draw;
end;

procedure TFmp3.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Liste1Aktiv(fmp3);
  ArraySpeichern(aktuellePlayListe);
  SpeicherRegLetztePlaylist;
  save.S_Playlisten(playlisten);
end;

procedure TFmp3.AZeigeInfoExecute(Sender: TObject);
begin
 FInfo.Show;
end;

procedure TFmp3.LBPLDblClick(Sender: TObject);     
begin            {
  if fsettings.cbplaylistsave.Checked then ArraySpeichern( aktuellePlayListe );
  ArrayLeeren;
  SetLength(Mp3s,0);
  ArrayLaden( Playlisten[ LBPL.ItemIndex ] );
  aktuellePlayliste:=Playlisten[ LBPL.ItemIndex ];  }
end;

procedure TFmp3.AListClearExecute(Sender: TObject);
begin
 ArrayLeeren;
end;

procedure TFmp3.ArrayLeeren;
begin
  SetLength(Mp3s,0);
  aktuellePlayliste:='zurück.EmatPls2';
  GListe.ListenReset;
  GListe.Draw;
end;

procedure TFmp3.AZeigeSplashExecute(Sender: TObject);
begin
 Fstart.showmodal; 
end;



procedure TFmp3.Timer1Timer(Sender: TObject);
begin
 timer1.Enabled:=false;
 fstart.ShowModal;

 Fsettings.EinstellungenLaden;
 timer2.Enabled:=true;
 gbliste1.width:=gbliste.Clientwidth;
 
end;

procedure TFmp3.TrayIconDblClick(Sender: TObject);
begin
  if minimiert then begin
  Application.Restore;
  Application.MainForm.Show;

         //Animation von Bernd Hikele
  with Screen do DrawAnimatedRects(Handle,3,Rect(Width-20, Height, Width-10, Height),BoundsRect);

  minimiert:=false;


  end else begin

  Application.Minimize;
       //Animation von Bernd Hikele
  with Screen do DrawAnimatedRects(Handle,3,BoundsRect,Rect(Width-20, Height, Width-10, Height));

  minimiert:=true;

  end;
end;

procedure TFmp3.Beenden1Click(Sender: TObject);
begin
close;
end;

procedure TFmp3.AwebseiteExecute(Sender: TObject);
begin
 ShellExecute(Application.Handle, 'open',PChar('http://www.g-software.de.gg'), nil, nil, SW_ShowNormal);
end;

procedure TFmp3.AShuffleExecute(Sender: TObject);
begin
if shuffle
 then begin
  shuffle:=false;
  AShuffle.Checked:=false;
  AShuffle.Caption:='Shuffle [aus]';
  Shuffle1.Checked:=false;
 end else begin
   shuffle:=true;
   AShuffle.Checked:=true;
   AShuffle.Caption:='Shuffle [an]';
   Shuffle1.Checked:=true;
 end;

end;

procedure TFmp3.AsettingsExecute(Sender: TObject);
begin
 Fsettings.showmodal; 
end;

procedure TFmp3.LoescheArrayElement ( index:integer );
 var i:integer;
begin
 for i:=index to high( Mp3s ) do
 begin
   Mp3s[i] := Mp3s[i+1];
 end;
 SetLength ( Mp3s , High (Mp3s) );
end;

procedure TFmp3.Loeschen;
var zuloeschendes:integer;
begin

   zuloeschendes:= ListenIndexZuArrayIndex ( GListe.markiertesElement );

   if ALoeschmodus.Checked then begin
    if DeleteFile( MP3s [ zuloeschendes ].path + MP3s [ zuloeschendes ].filename )
      then begin
        LoescheArrayElement ( zuloeschendes );
        ArraySpeichern (aktuellePlayListe );
      end
      else
        MessageDlg( MP3s [ zuloeschendes ].path + MP3s [ zuloeschendes ].filename + ' konnte nicht gelöscht werden ',
        mtwarning, [mbOK] , 0);
   end else begin
    LoescheArrayElement ( zuloeschendes );
    if fsettings.cbplaylistsave.Checked then
    ArraySpeichern (aktuellePlayListe );
   end;

   ArrayZuListe;

end;

procedure TFmp3.ALoeschmodusExecute(Sender: TObject);
begin
  ALoeschmodus.Checked := not ALoeschmodus.Checked ;
  if ALoeschmodus.Checked then
  MessageDlg('Mit Aktivierung des HDD-Löschmoduses werden alle Dateien,'#13+
             'die Sie aus der Liste löschen,'#13+
             'von der Festplatte gelöscht werden!'
             ,mtwarning,[mbok],0);
end;

procedure TFmp3.LTitelMouseLeave(Sender: TObject);
begin
 LTitel.Font.Style:=[];       //uk
end;

procedure TFmp3.LTitelMouseEnter(Sender: TObject);
begin
 LTitel.Font.Style:=[fsUnderline];       //uk
end;

procedure TFmp3.TrayIconMinimizeToTray(Sender: TObject);
begin
minimiert:=true;
end;


procedure TFmp3.AcloseExecute(Sender: TObject);
begin
close;
end;

procedure TFmp3.AbugExecute(Sender: TObject);
begin
 Fbug.Showmodal;
end;

procedure Tfmp3.ElementMarkieren( markiert:integer );
begin
 markiert:= ListenIndexZuArrayIndex(markiert);

 Weckton:=mp3s[markiert].path+mp3s[markiert].filename;       //eingeschoben, uk
 Sidebarpfad:=mp3s[markiert].path;                           //eingeschoben, uk

 if extractfileext( mp3s[markiert].filename )='.mp3' then
  begin
    if mp3s[markiert].id3tag.ausgelesen=false then
    begin
      id3.Lese( mp3s[markiert].path+mp3s[markiert].filename);
      with mp3s[markiert] do
      begin
        id3tag.ID := id3.ID3Tag.ID;
        id3tag.Titel := Trim( id3.ID3Tag.Titel );
        id3tag.Artist := Trim( id3.ID3Tag.Artist );
        id3tag.Album := Trim( id3.ID3Tag.Album );
        id3tag.Year := Trim( id3.ID3Tag.Year );
        id3tag.Comment := Trim( id3.ID3Tag.Comment );
        id3tag.Genre := id3.ID3Tag.Genre;
        id3tag.dauer := id3.ID3Tag.dauer;
        id3tag.sample := id3.ID3Tag.sample;
        id3tag.bits := id3.ID3Tag.bits;
        id3tag.vers := id3.ID3Tag.vers;
        id3tag.layers := id3.ID3Tag.layers;

        id3tag.ausgelesen:=true;
      end;
    end;
  end;

 with mp3s[markiert] do
    begin
    with FExBar do
     begin
     BeginUpdate;

     ExGroups.Delete(1);       //Alten Eintrag löschen
      with ExGroups.Add('Metainformationen') do
       begin
        if id3tag.Titel='' then else AddLine(id3tag.Titel, Clmap.FontColor, [fsBold], True);
        if id3tag.Artist='' then else AddLine(id3tag.Artist, Clmap.FontColor, [], True);
        if id3tag.Album='' then else AddLine(id3tag.Album, Clmap.FontColor, [], True);
        if id3tag.Year='' then else AddLine(id3tag.Year, Clmap.FontColor, [], True);
        if path='' then else AddMenuItem(path, path, 1, 1);
        if id3tag.Comment='' then else AddLine(id3tag.Comment, Clmap.FontColor, [], True);

        AddLine('Genre: '+inttostr(id3tag.Genre), Clmap.FontColor, [], True);
        AddLine('Sample: '+inttostr(id3tag.sample), Clmap.FontColor, [], True);
        AddLine('Bitrate: '+inttostr(id3tag.bits), Clmap.FontColor, [], True);
        AddLine('Version: '+inttostr(id3tag.vers), Clmap.FontColor, [], True);
        AddLine('Layer: '+inttostr(id3tag.layers), Clmap.FontColor, [], True);
        AddLine('Dauer: '+inttostr(ID3Tag.dauer div 60)+':'+(format('%.2d',[ID3Tag.dauer mod 60])), Clmap.FontColor, [], True);
       end;
     EndUpdate;
     Repaint;
    end;
 end;



end;


procedure TFmp3.AweckerExecute(Sender: TObject);
begin
ShellExecute(Application.Handle, 'open' ,PChar('Wecker.exe'), nil, nil, sw_ShowNormal);
end;

procedure TFmp3.ListenRechtsKlick(index, x,y : integer);
begin
PMliste.Popup(mouse.CursorPos.x,mouse.CursorPos.y);                     //uk
end;

procedure TFmp3.AumbennenClick(Sender: TObject);
begin
 umbennenen( gliste.markiertesElement );
end;

procedure TFmp3.ArraySortieren;
var i,j,pos: integer;
begin
  begin
  for I := 0 to High(Mp3s)-1 do
  begin
    Pos := I;
    for J := I+1 to High(Mp3s) do
        if Mp3s[J].filename < Mp3s[Pos].filename
            then Pos := J;

    ArraySortierenTausch( Mp3s[Pos], Mp3s[I] );
  end;
end;
  ArrayZuListe;
end;

procedure TFmp3.ArraySortierenTausch (var a, b: TMp3Eintrag);
var c: TMp3Eintrag;
begin
  c:=a;
  a:=b;
  b:=c;
end;

procedure TFmp3.ASortExecute(Sender: TObject);
begin
 ArraySortieren;
end;

procedure TFmp3.ADauerAuslesenExecute(Sender: TObject);
var i:integer;
begin
  MessageDlg('Das Auslesen der Einräge kann -besonders bei großen Listen- mehrere Minuten dauern.'+#13+'Wenn Sie während des Vorgangs nichts tun, kann sich dieser möglicherweiße beschleunigen.',mtInformation,[mbOk],0);   //uk

  fwarte.PBwarte.Tag:=0;
  fwarte.show;
  fwarte.pbwarte.max:=high(mp3s);
  AStoppExecute(fmp3);

  for i:=0 to high(mp3s) do
  begin
    if mp3s[i].dauer='' then try DauerAuslesen(i) except mp3s[i].dauer:='defekt' end;
    fwarte.pbwarte.Position:=i;
    application.ProcessMessages;
    if Fwarte.PBwarte.Tag=1 then break;            //uk
    end;
  fwarte.close;

  ArrayZuListe;
  PlsSpeichernExecute(fmp3);
end;


procedure TFmp3.DauerAuslesen(index:integer);
var dauer:integer;

begin
     MediaP.FileName:= mp3s[index].path + mp3s[index].filename;
     try
     MediaP.Open;
     dauer:=MediaP.Length div 1000;
     mp3s[index].dauer:= inttostr(dauer div 60)+':'+(format('%.2d',[dauer mod 60]));
     finally
     MediaP.Close;
     end;
end;

procedure TFmp3.Gliste2DragOver ( Sender, Source:Tobject; x,y: integer;
                                   State: TDragState; var accept:boolean);
begin
  if Source = Gliste1 then accept:=true;
end;

procedure TFmp3.Gliste2DragDrop ( Sender, Source:Tobject; x,y: integer);
 var Daten: TMp3Eintrag;
begin
  if Source = Gliste1 then
  begin
   Daten:=Mp3Daten[0,ListenIndexZuArrayIndex_Mp3Daten(Gliste1.markiertesElement)];
   if not DatensatzInArray(Daten,1) then
   begin
    SetLength(Mp3Daten[1],High(Mp3Daten[1])+2);
    Mp3Daten[1,High(Mp3Daten[1])]:=Daten;
    Liste2Aktiv(fmp3);
    Liste1Aktiv(fmp3);
   end
  else MessageDlg('Dieser Eintrag befindet sich leider bereits in der Liste'+#13+
                  'und kann nicht noch einmal hinzugefügt werden.',mtinformation,[mbok],0);
  end;                                   
end;

function TFmp3.DatensatzInArray(Daten:Tmp3Eintrag;ArrayIndex:integer):boolean;
var flag:boolean;
    i:integer;
begin
  flag:=false;
  if high(mp3daten[ArrayIndex])>0 then
  begin
  i:=0;

  repeat
  if (daten.path+daten.filename)=mp3daten[ArrayIndex,i].path+mp3daten[ArrayIndex,i].filename
  then flag:=true;
  inc(i);
  until (flag) or (i=high(mp3daten[ArrayIndex])+1);

  result:=flag;
  end;
end;

procedure TFmp3.Button2Click(Sender: TObject);
begin
showmessage(aktuellertitel);
end;

procedure TFmp3.AFarbresretExecute(Sender: TObject);
begin
SetColor;
end;

procedure TFmp3.GHK_pauseKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  APauseExecute(fmp3);
end;

procedure TFmp3.GHK_nachherKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 AnextExecute(fmp3);
end;

procedure TFmp3.GHK_vorherKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 Apreexecute(fmp3);
end;

procedure TFmp3.GHK100KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
TBVolume.Position:=1000;
end;

procedure TFmp3.GHK25KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
TBVolume.Position:=250;
end;

procedure TFmp3.GHK50KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
TBVolume.Position:=500;
end;

procedure TFmp3.GHK75KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
TBVolume.Position:=750;
end;


procedure TFmp3.AupdateExecute(Sender: TObject);
begin
ShellExecute(Application.Handle, 'open',PChar('http://www.ematupdate.de.gg'), nil, nil, SW_ShowNormal);
end;

procedure TFmp3.PBarChange(Sender: TObject);
begin
 if PBar.Position > 48                  //uk {
  then PBar.Font.Color:= clwhite
  else PBar.Font.Color:= clblack;

 if PBar.Position > 67
  then PBar.Font.Color:= clblack;       //uk }
end;



procedure TFmp3.AExplorerClick(Sender: TObject);
begin
ShellExecute(0, Nil, PChar('explorer.exe'), Pchar(extractfilepath(aktuellerTitel)), Pchar(''), SW_NORMAL);
end;

procedure TFmp3.AtitelmarkierenClick(Sender: TObject);
begin
 if GListe.fortschrittlichesElement>5
 then
   if Gliste.fortschrittlichesElement>gliste.liste.Count-gliste.GetZeilen-5
   then Gliste.ersterEintrag:=gliste.liste.Count-gliste.GetZeilen-5
   else  GListe.ersterEintrag:=Gliste.fortschrittlichesElement-5
 else
   GListe.ersterEintrag:=0;


 Gliste.markiertesElement:=GListe.fortschrittlichesElement;
 ElementMarkieren(ListenIndexZuArrayIndex(GListe.fortschrittlichesElement));  //uk für ID3-Tag Auslesung
 GListe.Draw;
end;

procedure TFmp3.DateialsWecktonverwendenClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open' ,PChar('Wecker.exe'), PChar('"'+weckton+'"'), nil, sw_ShowNormal);
end;

procedure TFmp3.Timer2Timer(Sender: TObject);
begin
trayicon.IconIndex:=iconnummer;
inc(iconnummer);
if iconnummer=32
 then
  begin
   trayIcon.Icon:=Application.Icon;
   iconnummer:=25;
   Timer2.Enabled:=false;

  end;
end;

procedure TFmp3.AanmationExecute(Sender: TObject);
begin
Timer2.Enabled:=true;
end;

procedure TFmp3.TrayIconClick(Sender: TObject);
begin

flaut.Left:=Mouse.CursorPos.X;
flaut.Top:=Screen.Height-flaut.height-27;   //uk | -27 ist noob, aber wie hoch
                                            //ist die taskbar bei anderen Styles?
flaut.Show;

end;

procedure TFmp3.GBliste1Enter(Sender: TObject);
begin
Liste1Aktiv(fmp3);
end;

procedure TFmp3.GBliste2Enter(Sender: TObject);
begin
Liste2Aktiv(fmp3);
end;

procedure TFmp3.ASplittExecute(Sender: TObject);
begin
if ASplitt.Checked
 then
  begin
   GBliste1.width:=GBliste.clientwidth;
   ASplitt.Checked:=false;
  end
 else
  begin
   RelativeListenteilung;
   ASplitt.Checked:=true;
  end;
end;

procedure Tfmp3.RelativeListenteilung;
begin
  gbliste1.Width:=round(listenaufteilung*gbliste.Width);
end;
 
procedure TFmp3.SplitterMoved(Sender: TObject);
begin
Listenaufteilung:=Gbliste1.Width/gbliste.Width;
end;

procedure TFmp3.Amp3playerzeigeExecute(Sender: TObject);
begin
 fmp3player.ErstelleMp3PlayerListe;
 fmp3player.show;
end;


procedure TFmp3.Splitter1Moved(Sender: TObject);
begin
if not ASplitt.Checked
 then
  begin
   GBliste1.width:=GBliste.clientwidth;

     end
 else
  begin
   RelativeListenteilung;

  end;
end;

procedure TFmp3.ItemClick(Sender: TObject; Id: Integer); //uk
begin

  if id=0 then PlsLadenExecute(fmp3);
  if id=1 then ShellExecute(Application.Handle, 'open',PChar(sidebarpfad), nil, nil, SW_ShowNormal);

  if id>=10 then
  begin
    ArraySpeichern(aktuellePlayliste);
    ArrayLeeren;
    ArrayLaden(playlisten[id-10].path+playlisten[id-10].filename);
  end;
end;

procedure TFmp3.Sidebarskin;                    //uk{
var bild :TBitmap;
begin
  bild:=TBitmap.Create;
  bild.Height:=Blueimg.Height;
  bild.Width:=Blueimg.Width;
  bild.Canvas.Draw(0,0,blueimg.Picture.Bitmap);

  bild.Canvas.Brush.Color:=Fmp3.Color;

  bild.Canvas.FillRect(rect(1,1,5,5));
  bild.Canvas.FillRect(rect(1,25,5,30));

  blueimg.Canvas.Draw(0,0,bild);

  Fexbar.BeginUpdate;
  Fexbar.SetSkin(BlueImg.Picture.Bitmap);

  Fexbar.EndUpdate;
  Fexbar.Repaint;

end;                                               //uk }



procedure TFmp3.AFindDoppelExecute(Sender: TObject);
begin
  FindeDoppelteMedien;
end;


procedure TFMp3.FindeDoppelteMedien;
 var i,k   : integer;
     flag    : boolean;
begin
 if Listenaufteilung>0.95 then Listenaufteilung:=0.5;
 RelativeListenteilung;

 SetLength(Mp3Daten[1],0);

 for i:=0 to high(mp3s) do
   begin
     if mp3s[i].anzeige then
       begin
          flag:=false;
          for k:=0 to high(mp3s) do
            begin
              if (mp3s[i].size = mp3s[k].size) and (k<>i) then
               begin
                 SetLength(Mp3Daten[1],High(Mp3Daten[1])+2);
                 Mp3Daten[1,High(Mp3Daten[1])]:=mp3s[k];
                 flag:=true;
               end;
            end;
          if flag then
          begin
           SetLength(Mp3Daten[1],High(Mp3Daten[1])+2);
           Mp3Daten[1,High(Mp3Daten[1])]:=mp3s[i];
          end;
       end;
   end;
  Liste2Aktiv(fmp3);
  ArrayZuListe;
end;

procedure TFmp3.LESucheKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if LESuche.Text='' then else
      if Key=vk_return then
        begin
          Weiterschalten;
          Gliste.SetFocus;
        end;
end;



procedure TFmp3.AsuchfeldfocusExecute(Sender: TObject);  //uk
begin
 LEsuche.SetFocus;
end;

procedure TFmp3.AhilfeExecute(Sender: TObject);
begin
Finfo.ItemClick(finfo,6);
Finfo.Show;
end;

procedure TFmp3.LTitelClick(Sender: TObject);
begin
Atitelmarkierenclick(fmp3); //uk
end;

end.



