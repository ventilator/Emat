unit ump3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ToolWin, ActnList, clipbrd, jpeg, StdCtrls, StdActns, ExtCtrls,
  ImgList, ComCtrls, Grids, mmsystem, ActnColorMaps, registry,  Menus, shellapi,
  Buttons, CustomizeDlg, ExtDlgs, strutils,  LMDGlobalHotKey, XPMan, ActnMan,
  commontypes,
  
  TB2Dock,TBXDkPanels, TB2Toolbar, TB2Item, TBX, TBXExtItems, TB2Common,
  TB2ExtItems, TBXLists, TBXToolPals, TBXStatusBars, TBXAcroTheme,
  TBXSentimoTheme, TBXAthenXTheme, TBXMonaiTheme, TBXMonaiXPTheme, TBXRomaTheme,
  TBXOffice11XPTheme, TBXOfficeKTheme, TBXOffice11AdaptiveTheme, TBXNexosTheme,
  TBXNexos2Theme, TBXNexos3Theme, TBXNexos4Theme, TBXNexos5Theme,
  TBXOfficeCTheme, TBXTristanTheme, TBXTristan2Theme, TBXOffice2003Theme,
  TBXXitoTheme, TBXNewDefaultTheme, TBXNewOfficeXPTheme, TBXEosTheme,
  TBXEMoneyTheme, TBXAthenTheme, TBXSwitcher, TBXThemes, TBXMDI, TBXProgressBar,

  LMDControl, LMDBaseControl, LMDBaseGraphicControl, LMDBaseLabel,
  LMDCustomLabel, LMDLabel, bass, LMDContainerComponent, LMDBaseDialog,
  LMDDirDlg, LMDCustomComponent,

  CoolTrayIcon, Exbar,

  udatenbank, usave, uspieler, ulang, uincex, bassplayer, Uliste;


const Version   = '0.75.65-D2k5testbuilt';
      maxVolume = 255;
      Anzahl_TBXDockablePanel = 7;
      Anzahl_TBXToolbars      = 3;
      PlaylistExt = '.epl';
      VISSETTINGS = 'Aussehen.ini';
      WALLPAPER   = 'hintergrund.jpg';
      GENERALSETTINGS = 'Emat.ini';

      

type TAktiv = record
      Liste     : integer;
      SpielendeListe : integer;
      SpielendesElement : integer;
      Spielt            : boolean;
     end;

type
  TFmp3 = class(TForm)
    ILSymbolleiste: TImageList;
    SaveD: TSaveDialog;
    OpenD: TOpenDialog;
    TrayIcon: TCoolTrayIcon;
    GHK_vorher: TLMDGlobalHotKey;
    GHK_pause: TLMDGlobalHotKey;
    GHK_nachher: TLMDGlobalHotKey;
    GHK25: TLMDGlobalHotKey;
    GHK50: TLMDGlobalHotKey;
    GHK75: TLMDGlobalHotKey;
    GHK100: TLMDGlobalHotKey;
    BassTimer: TTimer;
    PBSpectrum: TPaintBox;
    TBXMultiDock1: TTBXMultiDock;
    TBXMultiDock2: TTBXMultiDock;
    TBXMultiDock3: TTBXMultiDock;
    TBXMultiDock4: TTBXMultiDock;
    TBXDockablePanel2: TTBXDockablePanel;
    TBXDockablePanel3: TTBXDockablePanel;
    TBXDockablePanel4: TTBXDockablePanel;
    TBXLartist: TTBXLabel;
    TBXLcomment: TTBXLabel;
    TBXLdauer: TTBXLabel;
    TBXLgenere: TTBXLabel;
    TBXLTitel: TTBXLabel;
    TBXLyear: TTBXLabel;
    TBXLalbum: TTBXLabel;
    TBXDockablePanel5: TTBXDockablePanel;
    TBXDockablePanel6: TTBXDockablePanel;
    TBVolume: TTrackBar;
    LTitel: TTBXLink;
    LTitel_old: TLabel;
    SpielerTimer: TTimer;
    ihintergrund: TImage;
    LMDGHKShuffle: TLMDGlobalHotKey;
    TBXSwitcher1: TTBXSwitcher;
    TBXDockablePanel7: TTBXDockablePanel;
    LBthemes: TListBox;
    ILanimation: TImageList;
    Tanimation: TTimer;
    TBXPBar: TTBXProgressBar;
    Ttaskbarscroller: TTimer;
    TBXPopupMenu1: TTBXPopupMenu;
    TBXIvorheriger: TTBXItem;
    TBXIPause1: TTBXItem;
    TBXInchsterTitel1: TTBXItem;
    TBXIShuffle1: TTBXItem;
    N2_OLD: TTBXSeparatorItem;
    TBXIBeenden1: TTBXItem;
    TBXDock1: TTBXDock;
    TBXDock2: TTBXDock;
    TBXDock3: TTBXDock;
    TBXDock4: TTBXDock;
    TBXToolbar2: TTBXToolbar;
    TBXIstop: TTBXItem;
    TBXIplay: TTBXItem;
    TBXInext: TTBXItem;
    TBXIback: TTBXItem;
    TBXIpause: TTBXItem;
    TBXToolbar1: TTBXToolbar;
    TBXSubmenuItem7: TTBXSubmenuItem;
    TBXInewplaylist: TTBXItem;
    TBXIclose: TTBXItem;
    TBXSubmenuItem10: TTBXSubmenuItem;
    TBXIani: TTBXItem;
    TBXSubmenuItem12: TTBXSubmenuItem;
    TBXIhelp: TTBXItem;
    TBXIinfo: TTBXItem;
    TBXIlogo: TTBXItem;
    TBXSeparatorItem15: TTBXSeparatorItem;
    TBXIwebseite: TTBXItem;
    TBXSeparatorItem16: TTBXSeparatorItem;
    TBXItem53: TTBXItem;
    TBXOpenplaylist: TTBXItem;
    TBXLabel1: TTBXLabel;
    TBXPageScroller1: TTBXPageScroller;
    TBXAlignmentPanel1: TTBXAlignmentPanel;
    TBXPageScroller2: TTBXPageScroller;
    TBXPageScroller3: TTBXPageScroller;
    TBXLabel2: TTBXLabel;
    TBXCBscrolltitle: TTBXCheckBox;
    TBXLabel3: TTBXLabel;
    TBXCBtrayicon: TTBXCheckBox;
    TBXCBtaskbuttton: TTBXCheckBox;
    TBXCBmintotray: TTBXCheckBox;
    TBXSeparatorItem2: TTBXSeparatorItem;
    TBXSubmenuItem2: TTBXSubmenuItem;
    TBXMDIWindowItem2: TTBXMDIWindowItem;
    TBXSeparatorItem14: TTBXSeparatorItem;
    TBXSubmenuItem1: TTBXSubmenuItem;
    TBXIreset: TTBXItem;
    TBXSubmenuItem3: TTBXSubmenuItem;
    TBXLabel4: TTBXLabel;
    TBXCBhud: TTBXCheckBox;
    ListBox1: TListBox;
    TBXIShuffle: TTBXItem;
    TBXIupdates: TTBXItem;
    TBXPopupMenu2: TTBXPopupMenu;
    TBXSubmenuItem4: TTBXSubmenuItem;
    TBXSubmenuItem5: TTBXSubmenuItem;
    TBXPopupMenu3: TTBXPopupMenu;
    TBXSeparatorItem1: TTBXSeparatorItem;
    TBXPM_Ltitel: TTBXPopupMenu;
    TBXIopenfolder: TTBXItem;
    TBXIcopypath: TTBXItem;
    TBXImarkinlist: TTBXItem;
    TBXToolbar3: TTBXToolbar;
    TBXI_HDDLoeschmodus: TTBXItem;
    TBXDockablePanel1: TTBXDockablePanel;
    IEQ: TPaintBox;
    TBXAlignmentPanel2: TTBXAlignmentPanel;
    TBXAlignmentPanel3: TTBXAlignmentPanel;
    TBXAlignmentPanel6: TTBXAlignmentPanel;
    TBXAlignmentPanel4: TTBXAlignmentPanel;
    TBXPM_Listbox1: TTBXPopupMenu;
    TBXI_DelFromList: TTBXItem;
    TBXI_DelFormHDD: TTBXItem;
    FileOpenD: TOpenDialog;
    TBXLabel5: TTBXLabel;
    TBXLink1: TTBXLink;
    OpenPD: TOpenPictureDialog;
    TBXPMEQ: TTBXPopupMenu;
    TBXI_reseteq: TTBXItem;
    ActionList1: TActionList;
    Aopenlist: TAction;
    Aclose: TAction;
    Atile: TAction;
    Acascade: TAction;
    Adefault: TAction;
    Aanimation: TAction;
    Ahelp: TAction;
    Ainfo: TAction;
    Alogo: TAction;
    Awebsite: TAction;
    Aupdate: TAction;
    Anext: TAction;
    Aplay: TAction;
    Astop: TAction;
    Apause: TAction;
    Aprev: TAction;
    Ashuffle: TAction;
    Ahdddel: TAction;
    Anewlist: TAction;
    ILpath: TImageList;
    ADelFromHDD: TAction;
    ADelFromList: TAction;
    Action1: TAction;
    Acopypath: TAction;
    Amarkinlist: TAction;
    WindowTileHorizontal1: TWindowTileHorizontal;
    WindowTileVertical1: TWindowTileVertical;
    WindowCascade1: TWindowCascade;
    TBXItem1: TTBXItem;
    TBXItem2: TTBXItem;
    TBXItem3: TTBXItem;
    TBXPMvis: TTBXPopupMenu;
    Aspectrum0: TAction;
    Aspectrum1: TAction;
    AocilloScope0: TAction;
    AocilloScope1: TAction;
    AocilloScope2: TAction;
    AcircleScope1: TAction;
    AcircleScope2: TAction;
    AcircleScope0: TAction;
    TBXItem5: TTBXItem;
    TBXItem6: TTBXItem;
    TBXItem7: TTBXItem;
    TBXItem8: TTBXItem;
    TBXItem9: TTBXItem;
    TBXItem10: TTBXItem;
    TBXItem11: TTBXItem;
    TBXItem12: TTBXItem;
    TBXLink2: TTBXLink;
    ColorD: TColorDialog;
    LMDpath: TLMDLabel;
    GHKRestart: TLMDGlobalHotKey;
    TBXItem4: TTBXItem;
    TBXItem13: TTBXItem;
    ODMedia: TOpenDialog;
    GH_Del: TLMDGlobalHotKey;
    TBX_del_play_item: TTBXItem;
    TBXCBSysHKey: TTBXCheckBox;
    TBXCBSearchAutoPlay: TTBXCheckBox;
    PathD: TLMDDirDlg;
    procedure PBarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TBVolumeChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AZeigeInfoExecute(Sender: TObject);
    procedure LBPLDblClick(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure TBXIBeenden1Click(Sender: TObject);
    procedure TrayIconMinimizeToTray(Sender: TObject);

    procedure AweckerExecute(Sender: TObject);
    procedure GHK_pauseKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GHK_nachherKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GHK100KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GHK25KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GHK50KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GHK75KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DateialsWecktonverwendenClick(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);

    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure IEQerMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure IEQerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure IEQerMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer); 
    procedure SpielerTimerTimer(Sender: TObject);
    procedure TBXIBeendenClick(Sender: TObject);
    procedure LMDGHKShuffleKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LBthemesClick(Sender: TObject);
    procedure TBXIPause1Click(Sender: TObject);
    procedure TBXIvorherigerClick(Sender: TObject);
    procedure TBXInchsterTitel1Click(Sender: TObject);
    procedure TBXDockablePanel6MouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TBXIcopypathClick(Sender: TObject);
    procedure TanimationTimer(Sender: TObject);
    procedure TBXIAnmiation1Click(Sender: TObject);
    procedure TBXItem23Click(Sender: TObject);
    procedure TtaskbarscrollerTimer(Sender: TObject);
    procedure TBXCBmintotrayChange(Sender: TObject);
    procedure TBXCBtaskbutttonChange(Sender: TObject);
    procedure TBXCBtrayiconChange(Sender: TObject);
    procedure TBXCBscrolltitleChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TBXToolbar1Close(Sender: TObject);
    procedure AtitelmarkierenClick(Sender: TObject);
    procedure TBXIopenfolderClick(Sender: TObject);
    procedure LTitelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure TBXDockablePanel1Close(Sender: TObject);
    procedure IEQMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure IEQMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure IEQPaint(Sender: TObject);
    procedure IEQMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TBXDockablePanel1Resize(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TBXDockablePanel2Resize(Sender: TObject);
    procedure GHK_vorherKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OpenPDClose(Sender: TObject);
    procedure TBXI_reseteqClick(Sender: TObject);
    procedure AnewlistExecute(Sender: TObject);
    procedure AnextExecute(Sender: TObject);
    procedure AplayExecute(Sender: TObject);
    procedure AopenlistExecute(Sender: TObject);
    procedure AcloseExecute(Sender: TObject);
    procedure AcascadeExecute(Sender: TObject);
    procedure AtileExecute(Sender: TObject);
    procedure AdefaultExecute(Sender: TObject);
    procedure AanimationExecute(Sender: TObject);
    procedure AhelpExecute(Sender: TObject);
    procedure AinfoExecute(Sender: TObject);
    procedure AlogoExecute(Sender: TObject);
    procedure AwebsiteExecute(Sender: TObject);
    procedure AupdateExecute(Sender: TObject);
    procedure AshuffleExecute(Sender: TObject);
    procedure ADelFromHDDExecute(Sender: TObject);
    procedure ADelFromListExecute(Sender: TObject);
    procedure AmarkinlistExecute(Sender: TObject);
    procedure AhdddelExecute(Sender: TObject);
    procedure AprevExecute(Sender: TObject);
    procedure ApauseExecute(Sender: TObject);
    procedure AstopExecute(Sender: TObject);
    procedure PBSpectrumMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Aspectrum0Execute(Sender: TObject);
    procedure TBXLink2Click(Sender: TObject);
    procedure TBXLink1Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure GHKRestartKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LMDpathMouseEnter(Sender: TObject);
    procedure LMDpathMouseExit(Sender: TObject);
    procedure LMDpathClick(Sender: TObject);
    procedure TBXIbackClick(Sender: TObject);
    procedure TBXItem4Click(Sender: TObject);
    procedure TBXItem13Click(Sender: TObject);
    procedure GH_DelKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TBX_del_play_itemClick(Sender: TObject);
  private
    procedure Weiterschalten;

    procedure Zurueckschalten;

    procedure EQDraw;
    procedure Pause;
    procedure TBXAnordnungReset;
    function ErstesZeichenHintenDran(Text: string): string;
    procedure DockablePanelMenuErstellen;
    procedure TBX_DP_ItemClick(Sender: TObject);
    procedure ScreenText(Text: string);
    procedure WMDROPFILES (var Msg: TMessage); message WM_DROPFILES;
    procedure TBX_TB_ItemClick(Sender: TObject);

    procedure ToolbarMenuErstellen;
    procedure MarkInList;
    procedure ResetEQ;

    function DeleteFileToRecycleBin(const AFile: string): boolean;


    { Private-Deklarationen }
  public
    Spieler     : TSpieler;
    Aktiv       : Taktiv;
    Datenbank   : TDatenbank;
    FPlaylisten : array of TFPlayliste;
    ScreenOutdone: boolean;
    tbxinfo: TTBXItemInfo;
    procedure SetColor;
    function extractrealfilename(filename: string): string;
    { Public-Deklarationen }
    ///////0.75

     procedure Spule (Prozent :real);
     procedure ZeichneFortschritt(prozent: real; total: integer);
     procedure ErzeugeNeuePlayliste;
     procedure DatenbankListeAusgeben( ListenNummer : integer);
     function  ListeLaden( DateiName: string ): boolean;
     procedure Suche(ListenNummer: integer; Text: string);
     procedure ElementMarkieren (ListenNummer,ElementNummer:integer);
     procedure ListeSpeichern(ListenNummer:integer);
     procedure Stop;
     function  DauerZuString(SpielDauer: integer): string;
     procedure GoToUrl(url: string);
     procedure Fehler(Meldung: string);
     procedure ElementLoeschen(ListenNummer, ElementNummer: integer);
     function Spiele(ListenNummer, ElementNummer: integer;
      SetPrevElementNummer: boolean=true):boolean;
     procedure Umbenennen(ListenNummer, ElementNummer: integer);
     procedure AddFiles(ListenNummer: integer;Files: TStringlist);
     procedure ListeAnfuegenOrdner;
     procedure SetListsInAktive(exceptList: integer);
     procedure OpenFolderAndMarkFile(FileName: string);
     function filesizetostr(int: real): string;
     procedure Delay(Milliseconds: Integer);
  end;

var
  Fmp3        : TFmp3;
  Save        : TSave;
  basshandle  : HWND;

implementation


uses UInfo, Ustart, Ulaut, Uscreenout;

{$R *.dfm}

var
  Weckton, Speicherpfad: string;
  noTBXsave  : boolean = false;
  minimiert  : boolean = false;
  EQtaste    : boolean = false;
  CreateDone : boolean = false;
  iconnummer : integer=1;
  handCursor: HCURSOR;

procedure TFMp3.Spule(Prozent :real);
begin
  Spieler.Spule( prozent );
end;

function TFmp3.filesizetostr(int:real):string;
begin
  result:=Format('%.0n', [int]);
end;  

procedure TFmp3.PBarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 Spule(x/TBXPBar.Width);
end;


procedure TFmp3.Umbenennen(ListenNummer,ElementNummer:integer);
begin
  if (Aktiv.SpielendeListe=ListenNummer) and (Aktiv.SpielendesElement=ElementNummer)
  then Weiterschalten;
  Datenbank.RenameItem(ListenNummer,ElementNummer);
  DatenbankListeAusgeben(ListenNummer);
end;


procedure TFmp3.Zurueckschalten;
begin
Spiele(Aktiv.Liste,Datenbank.GetPreviousElementNummer(Aktiv.Liste),false);
end;

procedure TFmp3.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if (ssShift in Shift) then
 case key of
 Ord('B') : Zurueckschalten;
 Ord('S') : Stop;
 Ord('P') : Spiele(Aktiv.SpielendeListe,Aktiv.SpielendesElement);
 Ord('N') : Weiterschalten;
 Ord('F') : fmp3.FPlaylisten[Aktiv.Liste].ES.SetFocus;
 vk_Space : Pause;
 end;


 case key of
 vk_play  : Spiele(Aktiv.SpielendeListe,Aktiv.SpielendesElement);
 vk_add   : Tbvolume.Position:=Tbvolume.Position+20;
 vk_subtract : Tbvolume.Position:=Tbvolume.Position-20;
 Ord('J') : fmp3.FPlaylisten[Aktiv.Liste].ES.SetFocus;
 end;

end;

function TFmp3.ExtractRealFilename(filename :string) :string; 
begin
  Result:=Copy(Filename, 0, length(Filename)-length( ExtractFileExt(Filename) ))
end;


procedure TFmp3.FormClose(Sender: TObject; var Action: TCloseAction);
var i:integer;
begin
  Stop;

  for i:=0 to High(FPlaylisten) do
  begin
   if Datenbank.Mp3DatenMeta[i].offen
   then
    begin
     if Datenbank.Mp3DatenMeta[i].SpeicherPfad<>''
     then Datenbank.ListeSpeichern(Datenbank.Mp3DatenMeta[i].SpeicherPfad,i)
     else
        begin
         if
          MessageDlg(Format(SAVEPLS, [FPlaylisten[i].Caption]),
                                 mtConfirmation, [mbYes, mbNo], 0) = mrYes
         then
          begin
            ListeSpeichern(i);
          end;
        end;
    end;
  end;

  Save.S_OffenePlaylisten;
  Save.S_Einstellungen;
  Save.CloseIniFile;
  if not noTBXsave then TBIniSavePositions(Self,Speicherpfad+VISSETTINGS, '');
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


procedure TFmp3.TrayIconDblClick(Sender: TObject);
begin
  if minimiert
    then
      begin
        Application.Restore;
        Application.MainForm.Show;

        with Screen do  //Animation von Bernd Hikele
        DrawAnimatedRects(Handle,3,Rect(Width-20, Height, Width-10, Height),
                                BoundsRect);
        minimiert:=false;
      end
    else
      begin
        Application.Minimize;

        with Screen do  //Animation von Bernd Hikele
        DrawAnimatedRects(Handle,3,BoundsRect,Rect(Width-20, Height, Width-10,
                                Height));
        minimiert:=true;
      end;
end;

procedure TFmp3.TBXIBeenden1Click(Sender: TObject);
begin
 close;
end;

procedure TFmp3.TrayIconMinimizeToTray(Sender: TObject);
begin
minimiert:=true;
end;

procedure TFmp3.AweckerExecute(Sender: TObject);
begin
ShellExecute(Application.Handle, 'open' ,PChar('Wecker.exe'), nil, nil, sw_ShowNormal);
end;

procedure TFmp3.GHK100KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if fmp3.TBXCBSysHKey.Checked then
 TBVolume.Position:=maxVolume;
end;

procedure TFmp3.GHK25KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if fmp3.TBXCBSysHKey.Checked then
    TBVolume.Position:=round(maxVolume*0.25)
end;

procedure TFmp3.GHK50KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if fmp3.TBXCBSysHKey.Checked then
   TBVolume.Position:=round(maxVolume*0.5)
end;

procedure TFmp3.GHK75KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if fmp3.TBXCBSysHKey.Checked then
  TBVolume.Position:=round(maxVolume*0.75)
end;




procedure TFmp3.DateialsWecktonverwendenClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open' ,PChar('Wecker.exe'), PChar('"'+weckton+'"'), nil, sw_ShowNormal);
end;

procedure TFmp3.TrayIconClick(Sender: TObject);
begin
flaut.Left:=Mouse.CursorPos.X;
flaut.Top:=Screen.Height-flaut.height-30;
flaut.Show;
flaut.BringToFront;
end;

               //Fortschrittliches Element nach oben/unten scrollen
procedure TFmp3.MarkInList;       //uk name
begin
 FPlaylisten[Aktiv.SpielendeListe].BringToFront;

 if FPlaylisten[Aktiv.SpielendeListe].GListe1.fortschrittlichesElement>0
 then
 begin

 if FPlaylisten[Aktiv.SpielendeListe].GListe1.fortschrittlichesElement>5
 then
   if FPlaylisten[Aktiv.SpielendeListe].GListe1.fortschrittlichesElement
   >=(FPlaylisten[Aktiv.SpielendeListe].GListe1.liste.l0.Count-1)
   -FPlaylisten[Aktiv.SpielendeListe].GListe1.GetZeilen-5
   then FPlaylisten[Aktiv.SpielendeListe].GListe1.ersterEintrag:=
          (FPlaylisten[Aktiv.SpielendeListe].GListe1.liste.l0.Count-1)+1
          -FPlaylisten[Aktiv.SpielendeListe].GListe1.GetZeilen-5
   else  FPlaylisten[Aktiv.SpielendeListe].GListe1.ersterEintrag:=
          FPlaylisten[Aktiv.SpielendeListe].GListe1.fortschrittlichesElement-5
 else
   FPlaylisten[Aktiv.SpielendeListe].GListe1.ersterEintrag:=0;


 FPlaylisten[Aktiv.SpielendeListe].GListe1.markiertesElement:=
        FPlaylisten[Aktiv.SpielendeListe].GListe1.fortschrittlichesElement;
 ElementMarkieren(Aktiv.SpielendeListe,
                  strtoint(FPlaylisten[Aktiv.SpielendeListe].GListe1.Liste.Nummer
                  [FPlaylisten[Aktiv.SpielendeListe].GListe1.fortschrittlichesElement]));
 FPlaylisten[Aktiv.SpielendeListe].GListe1.Draw;

 end;
end;

procedure TFmp3.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 CanClose:=CreateDone;
end;


////////////////////////////////////////////////////////////////////////////////
//EMAT 0.75 RECOEDED ///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function TFmp3.Spiele( ListenNummer, ElementNummer : integer; SetPrevElementNummer:boolean=true):boolean;
 var Medium,ShownMediumName: string;
begin
  Result:=false;
  if Datenbank.GetMediumFullFileName( ListenNummer, ElementNummer , Medium)
    then
      begin
      //  Spieler.SetVolume(Tbvolume.Position);   //Bassplayer behält Volume
        if Spieler.Spiele( Medium )
          then
            begin
              Result:=true;
              if SetPrevElementNummer then
              Datenbank.SetPreviousElementNummer(ListenNummer,Aktiv.SpielendesElement);
              //Bug wenn liste gewechselt wurde
              Aktiv.SpielendesElement:=ElementNummer;
              Aktiv.SpielendeListe:=ListenNummer;
              Aktiv.Spielt:=true;
              LTitel.Caption:=Medium;
              LTitel.Hint:=Medium;
              ShownMediumName:=Datenbank.GetEintragfuerSpalte(0,ListenNummer,
                Datenbank.ElementNummerZuArrayIndex(ListenNummer,ElementNummer));
              Application.Title:=ShownMediumName+TASKBARSEP;
              TrayIcon.Hint:=ShownMediumName;
              ScreenText(ShownMediumName);
              Ttaskbarscroller.Enabled:=true;
              FPlaylisten[ListenNummer].Gliste1.fortschrittlichesElement
              := Datenbank.GetGListenIndex(ListenNummer,ElementNummer);
              FPlaylisten[ListenNummer].Gliste1.fortschritt:=0;

              if Datenbank.GetMediumPlayLength(ListenNummer,ElementNummer)=''
              then    //Dann müsste auch id3 undefiniert sein
               begin
                Datenbank.SetMediumPlayLength(ListenNummer,ElementNummer,
                                        DauerZuString(Spieler.GetDauer(Medium)));
                Datenbank.LeseId3(ListenNummer,ElementNummer);
                DatenbankListeAusgeben(ListenNummer);
               end;   
            end
          else
            begin       //als else vielleicht rot hinterlegen
              Weiterschalten;
            end;
      end;

end;

procedure TFmp3.ErzeugeNeuePlayliste;
begin
 SetLength(FPlaylisten,High(FPlaylisten)+2);
 FPlaylisten[High(FPlaylisten)]:=TFPlayListe.Create(self);
 FPlaylisten[High(FPlaylisten)].ListenNummer:=High(FPlaylisten);
 FPlaylisten[High(FPlaylisten)].Gliste1.Tag :=High(FPlaylisten);
 Aktiv.Liste:=High(FPlaylisten);
 Datenbank.AddNeueListe;
end;

procedure TFmp3.ListeAnfuegenOrdner;
begin
  if PathD.Execute
  then
   begin
    Datenbank.OrdnerAnListeAnhaengen(PathD.Path,Aktiv.Liste);
    DatenbankListeAusgeben(Aktiv.Liste);
   end;
end;

procedure TFmp3.DatenbankListeAusgeben ( ListenNummer:integer );
var i,markiert,fortschritt,ersterEintrag,Files : Integer;
    FilesSize : Int64;
begin
  if Datenbank.ListeExists(ListenNummer)
  then
   begin
     if Fplaylisten[ ListenNummer ].Gliste1.markiertesElement>=0
       then markiert:=strtoint( Fplaylisten[ ListenNummer ].Gliste1.liste.Nummer[
                         Fplaylisten[ ListenNummer ].Gliste1.markiertesElement ])
       else markiert:=-1;

     if Fplaylisten[ ListenNummer ].Gliste1.fortschrittlichesElement>=0
       then fortschritt:= strtoint(Fplaylisten[ ListenNummer ].Gliste1.liste.Nummer[
                  Fplaylisten[ ListenNummer ].Gliste1.fortschrittlichesElement ])
       else fortschritt:=-1;           

     ersterEintrag:=Fplaylisten[ ListenNummer ].Gliste1.ersterEintrag;

     Fplaylisten[ ListenNummer ].Gliste1.ListenReset;

     FilesSize:=0;
     Files:=0;
      for i:=0 to High( Datenbank.MP3Daten[ ListenNummer ] ) do
        begin
        if Datenbank.MP3Daten[ ListenNummer, i].anzeige
        then
          begin
            Fplaylisten[ ListenNummer ].Gliste1.Add(
            Datenbank.MP3Daten[ ListenNummer,i].Nummer,
            false,  //Markierungsflag für spätere Verwendung
            Datenbank.GetEintragfuerSpalte(Fplaylisten[ ListenNummer ].TBXCBI0.ItemIndex,ListenNummer,i),
            Datenbank.GetEintragfuerSpalte(Fplaylisten[ ListenNummer ].TBXCBI1.ItemIndex,ListenNummer,i),
            Datenbank.GetEintragfuerSpalte(Fplaylisten[ ListenNummer ].TBXCBI2.ItemIndex,ListenNummer,i),
            Datenbank.GetEintragfuerSpalte(Fplaylisten[ ListenNummer ].TBXCBI3.ItemIndex,ListenNummer,i),
            Datenbank.GetEintragfuerSpalte(Fplaylisten[ ListenNummer ].TBXCBI4.ItemIndex,ListenNummer,i));

            inc(FilesSize, Datenbank.MP3Daten[ ListenNummer,i].size);
            inc(Files);

            if Datenbank.MP3Daten[ListenNummer,i].Nummer=markiert
              then Fplaylisten[ ListenNummer ].Gliste1.markiertesElement:=
                             (Fplaylisten[ ListenNummer ].Gliste1.liste.l0.Count-1);
            if Datenbank.MP3Daten[ListenNummer,i].Nummer=fortschritt
              then Fplaylisten[ ListenNummer ].Gliste1.fortschrittlichesElement:=
                             (Fplaylisten[ ListenNummer ].Gliste1.liste.l0.Count-1);
        end;
    end;

  Fplaylisten[ ListenNummer ].Gliste1.ersterEintrag:=ersterEintrag;
  Fplaylisten[ ListenNummer ].Gliste1.Draw;
  Fplaylisten[ ListenNummer ].Caption:=extractrealfilename(extractfilename(
                            Datenbank.Mp3DatenMeta[ListenNummer].SpeicherPfad));
  Fplaylisten[ ListenNummer ].ES.Text:=
                            Datenbank.Mp3DatenMeta[ListenNummer].SuchText;
  Fplaylisten[ ListenNummer ].TBXStatusBar1.Panels[0].Caption := Format(
    CPLSTITELS, [Files]);  //uk
  Fplaylisten[ ListenNummer ].TBXStatusBar1.Panels[1].Caption := Format(
    CPLSMB, [round(FilesSize/(1024*1024))]);
    end;
end;



procedure Tfmp3.ZeichneFortschritt(prozent:real; total:integer);
begin
  if Datenbank.ListeExists(Aktiv.SpielendeListe)
  then Fplaylisten[ Aktiv.SpielendeListe ].Gliste1.SetFortschritt(prozent);
  TBXPbar.Caption := DauerZuString(total);
  TBXPBar.Position:= round(prozent*TBXPBar.Max);
end;

function Tfmp3.DauerZuString(SpielDauer:integer):string;
begin
  SpielDauer:=SpielDauer div 1000;
  Result:=inttostr(SpielDauer div 60)+':'+(format('%.2d',[SpielDauer mod 60]));
end;


procedure TFmp3.ListeSpeichern(ListenNummer:integer);
begin
  if Datenbank.Mp3DatenMeta[ListenNummer].Speicherpfad=''
  then
    begin
     if fmp3.SaveD.Execute
     then
      begin
{        if SaveD.FileName=''     //ExecuteEreignis...
        then begin
              fmp3.Fehler(NOFILENAME);
              exit;
             end; }
        Datenbank.Mp3DatenMeta[ListenNummer].Speicherpfad:=SaveD.FileName;
      end;
    end;

  Datenbank.ListeSpeichern( Datenbank.Mp3DatenMeta[ListenNummer].Speicherpfad,
                                                                 ListenNummer);

  Fplaylisten[ ListenNummer ].Caption:=extractfilename
  (extractrealfilename(Datenbank.Mp3DatenMeta[ListenNummer].Speicherpfad));
end;

function TFmp3.ListeLaden(DateiName: string):boolean;
begin
  Result := FileExists(DateiName); //uk
  ErzeugeNeuePlayliste;
  Datenbank.ListeAnfuegen( DateiName, Aktiv.Liste);
   //AnzeigeSpaltenfestlegung
   fmp3.Fplaylisten[ High(Datenbank.Mp3DatenMeta) ].TBXCBI0.ItemIndex:=
          Datenbank.Mp3DatenMeta[High(Datenbank.Mp3DatenMeta)].AnzeigeSpalten[0];
   fmp3.Fplaylisten[ High(Datenbank.Mp3DatenMeta) ].TBXCBI1.ItemIndex:=
           Datenbank.Mp3DatenMeta[High(Datenbank.Mp3DatenMeta)].AnzeigeSpalten[1];
   fmp3.Fplaylisten[ High(Datenbank.Mp3DatenMeta) ].TBXCBI2.ItemIndex:=
           Datenbank.Mp3DatenMeta[High(Datenbank.Mp3DatenMeta)].AnzeigeSpalten[2];
   fmp3.Fplaylisten[ High(Datenbank.Mp3DatenMeta) ].TBXCBI3.ItemIndex:=
           Datenbank.Mp3DatenMeta[High(Datenbank.Mp3DatenMeta)].AnzeigeSpalten[3];
   fmp3.Fplaylisten[ High(Datenbank.Mp3DatenMeta) ].TBXCBI4.ItemIndex:=
           Datenbank.Mp3DatenMeta[High(Datenbank.Mp3DatenMeta)].AnzeigeSpalten[4];
   fmp3.Fplaylisten[ High(Datenbank.Mp3DatenMeta) ].Caption:=
                            extractfilename(fmp3.extractrealfilename(dateiname));
  ////////////////// Suchfunktion->suchstring laden

  DatenbankListeAusgeben( Aktiv.Liste );
  if Listbox1.Items.IndexOf(Dateiname)=-1
    then Listbox1.Items.Add( DateiName );
end;


procedure TFmp3.SpielerTimerTimer(Sender: TObject);

begin
  if Spieler.Getlength>0
    then ZeichneFortschritt(Spieler.Getposition/Spieler.Getlength,
                                                          Spieler.GetPosition);

 {if Spieler.Bassplayer.position>=Spieler.Bassplayer.Playlength
 then Weiterschalten;}
end;

procedure TFmp3.TBXIBeendenClick(Sender: TObject);
begin
  close;
end;

procedure TFmp3.Weiterschalten;
var zuspielendes  : integer;
begin
  if Datenbank.ListeExists(Aktiv.SpielendeListe)
    then
    begin
     if not Datenbank.GetNextElementNummer(Aktiv.SpielendeListe,zuspielendes)
     then
      begin

        if TBxIShuffle.Checked
        then
            zuspielendes:=random(FPlaylisten[aktiv.SpielendeListe].Gliste1.
                                                               liste.l0.count)
        else
         begin
           if FPlaylisten[Aktiv.SpielendeListe].GListe1.fortschrittlichesElement=
                    (FPlaylisten[Aktiv.SpielendeListe].GListe1.liste.l0.Count-1)
             then zuspielendes:=0
             else zuspielendes:=FPlaylisten[aktiv.SpielendeListe].Gliste1.
                                                    fortschrittlichesElement + 1;
         end;


      Spiele( Aktiv.SpielendeListe,strtoint(FPlaylisten[aktiv.SpielendeListe].
                                            Gliste1.liste.nummer[zuspielendes]) );
      FPlaylisten[aktiv.SpielendeListe].Gliste1.
                                       fortschrittlichesElement:=zuspielendes;
      end
      else //GetNextElementNummer
      begin
        Spiele( Aktiv.SpielendeListe, zuspielendes );
        FPlaylisten[aktiv.SpielendeListe].Gliste1.fortschrittlichesElement:=
        Datenbank.GetGListenIndex(aktiv.SpielendeListe, zuspielendes )
      end;
    end;
end;

procedure Tfmp3.Suche (ListenNummer:integer; Text: string);
begin
  Datenbank.Suche(ListenNummer,Text);
  DatenbankListeAusgeben(ListenNummer);
  if (TBXCBSearchAutoPlay.Checked) and
                          (FPlaylisten[ListenNummer].Gliste1.Liste.l0.Count=1)
  then Spiele(ListenNummer,strtoint(FPlaylisten[ListenNummer].Gliste1.Liste.Nummer[0]));
end;

//////////Graphische EQ-Ausgabe/////////////////////////////////////////////////
procedure TFmp3.IEQerMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  EQtaste:=false;
  Spieler.EQSetWerte;
  EQDraw;
end;

//Graphische EQ-Ausgabe/////////////////////////////////////////////////////////
procedure TFmp3.IEQMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  EQTaste:=true;
end;

procedure TFmp3.IEQMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  EQtaste:=false;
  Spieler.EQSetWerte;
  EQDraw;
end;

procedure TFmp3.IEQPaint(Sender: TObject);
begin
EQDraw;
end;

procedure TFmp3.IEQMouseMove(Sender: TObject; Shift: TShiftState; X,
          Y: Integer);
  var
    schrittweite,
    aktiverRand1, aktiverRand2, aktivesZentrum, neuerEQwert: integer;
begin
  if EQtaste
    then
      begin
        schrittweite:=ieq.width div 11;
        aktiverRand1:=((schrittweite div 2)-4);
        aktiverRand2:=((schrittweite div 2)+4);
        aktivesZentrum:= (x mod schrittweite)-schrittweite div 2;

        if (aktivesZentrum>=aktiverRand1) and (aktivesZentrum<=aktiverRand2)
          then
            begin
              neuerEQwert:=round((30*y/ieq.height-15)*-1);
              if neuerEQwert>15 then neuerEQwert:=15;
              if neuerEQwert<-15 then neuerEQwert:=-15;
              if ((x div schrittweite+1)>=1) and ((x div schrittweite+1)<=10)
              then Spieler.eqwert[x div schrittweite+1]:=neuerEQwert;
              EQdraw;
            end;
        end;
end;

procedure TFmp3.IEQerMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  EQtaste:=true;
end;

procedure TFmp3.IEQerMouseMove(Sender: TObject; Shift: TShiftState; X,
          Y: Integer);
  var
    schrittweite,
    aktiverRand1, aktiverRand2, aktivesZentrum, neuerEQwert: integer;
begin
  if EQtaste
    then
      begin
        schrittweite:=ieq.width div 11;
        aktiverRand1:=((schrittweite div 2)-4);
        aktiverRand2:=((schrittweite div 2)+4);
        aktivesZentrum:= (x mod schrittweite)-schrittweite div 2;

        if (aktivesZentrum>=aktiverRand1) and (aktivesZentrum<=aktiverRand2)
          then
            begin
              neuerEQwert:=round((30*y/ieq.height-15)*-1);
              if  neuerEQwert>15 then  neuerEQwert:=15;     //Bugpreventing
              if   neuerEQwert<-15 then  neuerEQwert:=-15;  //
              Spieler.eqwert[x div schrittweite+1]:=neuerEQwert;
              EQdraw;
            end;
        end;
end;

procedure TFmp3.EQDraw;
var schrittweite,i : integer;
    puffer         : TBitmap;
begin
  puffer:=TBitmap.Create;
  puffer.Width:=IEQ.Width;
  puffer.Height:=IEQ.Height;

  puffer.Canvas.Brush.Color:=CurrentTheme.GetItemImageBackground(tbxinfo);
  puffer.Canvas.Pen.Color:=clBlack;
  puffer.Canvas.Rectangle(0,0,puffer.width,puffer.height);
  puffer.Canvas.Brush.Color:=CurrentTheme.GetItemTextColor(tbxinfo);
  schrittweite:=puffer.width div 11;
  for i:=0 to 9 do
  begin
  puffer.Canvas.Rectangle(i*schrittweite+schrittweite div 2,
                       puffer.height-round (((spieler.eqwert[i+1]+15))/30*
                       puffer.height),(i+1)*schrittweite-3+schrittweite div 2,
                       puffer.height);
  end;
  
IEQ.Canvas.Draw(0,0,puffer);

puffer.Free;
end;
////////////////////////////////////////////////////////////////////////////////


procedure TFmp3.Pause;
begin
  Spieler.Pause;
  Aktiv.Spielt:=false;
  ScreenText(PAUSECAPTION);
end;

procedure TFmp3.Stop;
begin
  Spieler.Stop;
  Aktiv.Spielt:=false;

  LTitel.Caption:='';
  LTitel.Hint:='';
  TrayIcon.Hint:='';
  TBXPbar.PosTextPrefix:=' ';
  TBXPbar.Position:=0;
  Ttaskbarscroller.Enabled:=false;
  Application.Title:=EMATTITLE;
  ScreenText(STOPCAPTION); 
end;

procedure TFmp3.GHK_pauseKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if fmp3.TBXCBSysHKey.Checked then
  Pause;
end;

procedure TFmp3.GHK_nachherKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if fmp3.TBXCBSysHKey.Checked then
  Weiterschalten;
end;

procedure TFmp3.LMDGHKShuffleKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if fmp3.TBXCBSysHKey.Checked then
  Ashuffle.Execute;
end;

procedure TFmp3.LBthemesClick(Sender: TObject);
begin
  TBXSetTheme(LBthemes.Items[LBthemes.ItemIndex]);
  SetColor;
end;

procedure TFmp3.TBXIPause1Click(Sender: TObject);
begin
  pause;
end;

procedure TFmp3.TBXIvorherigerClick(Sender: TObject);
begin
  Zurueckschalten;
end;

procedure TFmp3.TBXInchsterTitel1Click(Sender: TObject);
begin
  Weiterschalten;
end;

procedure TFmp3.TBXDockablePanel6MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Fehler(inttostr(x));
end;

procedure Tfmp3.ElementMarkieren (ListenNummer,ElementNummer:integer);
var id3tag  : tid3tag;
    pfad    : string;
    flag    : boolean;
begin
  flag:=false;
  
  Datenbank.GetMediumFullFileName (ListenNummer,ElementNummer,pfad);

  if Datenbank.GetMediumPlayLength(ListenNummer,ElementNummer)=''
  then
    begin
      Datenbank.SetMediumPlayLength(ListenNummer,ElementNummer,
                                DauerZuString(Spieler.GetDauer(pfad)) );
      flag:=true;
    end;

  id3tag := Datenbank.GetMediumId3Tag(ListenNummer, ElementNummer);

  if id3tag.ausgelesen = false  //wma? ist immer falsch                  //uk
    then
     begin
     Datenbank.LeseId3(ListenNummer, ElementNummer);
     flag:=true;
     end;

  if flag then DatenbankListeAusgeben(ListenNummer);

 { TBXLalbum.Visible := true;
  TBXLartist.Visible := true;
  TBXLbitrate.Visible := true;
  TBXLcomment.Visible := true;
  TBXLdauer.Visible := true;
  TBXLgenere.Visible := true;
  TBXLLpath.Visible := true;
  TBXLsample.Visible := true;
  TBXLtitel.Visible := true;
  TBXLversion.Visible := true;
  TBXLyear.Visible := true;    }


  if id3tag.Titel<>''
    then TBXLtitel.Caption := id3tag.Titel
    else TBXLtitel.Caption :='';

  if id3tag.Artist<>''
    then TBXLartist.Caption := id3tag.Artist
    else TBXLartist.Caption := '';

  if id3tag.Album<>''
    then TBXLalbum.Caption := id3tag.Album
    else TBXLalbum.Caption := '';

  if id3tag.Year<>''
    then TBXLyear.Caption := id3tag.Year
    else TBXLyear.Caption := '';

  if id3tag.Comment<>''
    then TBXLcomment.Caption := id3tag.Comment
    else TBXLcomment.Caption := '';

  if id3tag.genre<>''
    then TBXLgenere.Caption := id3tag.Genre
    else TBXLgenere.Caption := '';

   TBXLdauer.Caption := LENGTHCAPTION + inttostr(ID3Tag.dauer div 60)+':'
                              +(format('%.2d',[ID3Tag.dauer mod 60]));
    LMDpath .Caption := pfad;
    LMDpath.Hint := pfad;
end;

procedure TFmp3.TBXAnordnungReset;
begin
 if MessageDlg(RESETSETTINGS, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  if DeleteFile(Speicherpfad+VISSETTINGS)
  then begin noTBXsave:=true; end
  else Fehler (Format(DEL_FALSE,[Speicherpfad])+VISSETTINGS);
end;

  //Lautstärkeregelung
procedure TFmp3.TBVolumeChange(Sender: TObject);
begin
Spieler.SetVolume(Tbvolume.Position);
Flaut.TBTrayVolume.Position:=maxVolume-TBVolume.Position;
TBVolume.Hint:=VOLUMECAPTION+inttostr(round(TBVolume.Position/maxVolume*100))+'%)';
FLaut.TBXDockablePanel1.Caption:=TBVolume.Hint;
end;


procedure TFmp3.TBXIcopypathClick(Sender: TObject);
begin
  Clipboard.AsText:=Ltitel.Caption;
end;


procedure TFmp3.TanimationTimer(Sender: TObject);
begin
if not TBXCBtrayicon.Checked then exit;
(* ^^ uk Damit das Trayicon unsichtbar belibt, wenn man es in den Einstellungen
abgestellt hat ;-)  *)
  Trayicon.IconIndex:=iconnummer;
  inc(iconnummer);
  if iconnummer=ILanimation.Count
    then
      begin
        trayIcon.Icon:=Application.Icon;
        iconnummer:=1;
        Tanimation.Enabled:=false;
      end;
end;


procedure TFmp3.TBXIAnmiation1Click(Sender: TObject);
begin
Tanimation.Enabled:=true;
end;


procedure TFmp3.TBXItem23Click(Sender: TObject);
begin
  TBXAnordnungReset;
end;


procedure TFmp3.TtaskbarscrollerTimer(Sender: TObject);
begin
  if SpielerTimer.Enabled
   then
     if TBXCBscrolltitle.Checked
       then Application.Title:=ErstesZeichenHintenDran(Application.Title)
   else
    begin
      Ttaskbarscroller.Enabled:=false;     
    end;
end;


function TFmp3.ErstesZeichenHintenDran(Text: string):string;
begin
 result:=copy(Text,2,length(Text))+Text[1];
end;


procedure TFmp3.SetColor;
var i: integer;
begin
 try
  tbxinfo.ViewType := TVT_NORMALTOOLBAR or TVT_EMBEDDED;     //aus der TBX
  tbxinfo.ItemOptions := IO_APPACTIVE or IO_TOOLBARSTYLE;    //ProgressBar
  tbxinfo.Enabled := True;
  tbxinfo.Pushed := True;
  tbxinfo.Selected := False;
  tbxinfo.HoverKind := hkNone;
  tbxinfo.ImageShown := True;


  for i:=0 to High(FPlaylisten) do
    begin
      FPlaylisten[i].Gliste1.cltext := 16777215-colortorgb(
        CurrentTheme.GetItemImageBackground(tbxinfo)); //CurrentTheme.GetItemTextColor(tbxinfo);
      FPlaylisten[i].Gliste1.clhintergrund :=
        CurrentTheme.GetItemImageBackground(tbxinfo);
      FPlaylisten[i].Gliste1.SetMainColor(CurrentTheme.GetItemTextColor(tbxinfo));
    end;

  Application.HintColor:=CurrentTheme.GetItemColor(tbxinfo);

  EQDraw;

  Spieler.Spectrum.BackColor := CurrentTheme.GetItemImageBackground(tbxinfo);
  Spieler.Spectrum.Pen := CurrentTheme.GetItemTextColor(tbxinfo);
  Spieler.Spectrum.Peak := clBlack;

  Spieler.OcilloScope.BackColor := CurrentTheme.GetItemImageBackground(tbxinfo);
  Spieler.OcilloScope.Pen := CurrentTheme.GetItemTextColor(tbxinfo);

  Spieler.CircleScope.BackColor := CurrentTheme.GetItemImageBackground(tbxinfo);
  Spieler.CircleScope.Pen := CurrentTheme.GetItemTextColor(tbxinfo);

  except Fehler(SETCOLORERROR);
  end;
end;


procedure TFmp3.DockablePanelMenuErstellen;   //uk
var
  TBXItem: TTBXItem;
  i       : integer;
begin
  try
    for i := 1 to Anzahl_TBXDockablePanel do
      begin
        TBXItem:=TTBXItem.Create(fmp3);
        TBXItem.Name:='TBX_DP_Item'+inttostr(i);
        TBXItem.Caption:=(FindComponent('TBXDockablePanel'+IntToStr(i)) as TTBXDockablePanel).Caption;
        TBXItem.Checked:=(FindComponent('TBXDockablePanel'+IntToStr(i)) as TTBXDockablePanel).Visible;
        TBXItem.OnClick:=TBX_DP_ItemClick;
        TBXItem.Tag:=i;
        TBXSubmenuItem1.Add(TBXItem);
        (FindComponent('TBXDockablePanel'+IntToStr(i)) as TTBXDockablePanel).Tag:=i;
      end;
  except
    Fehler(Format(MENUEERROR, [PANELCAPTION]));
  end;
end;


procedure TFmp3.TBX_DP_ItemClick(Sender: TObject);   //uk
begin
  (Sender as TTBXItem).Checked := not (Sender as TTBXItem).Checked;
  (FindComponent('TBXDockablePanel' + IntToStr((Sender as TTBXItem).Tag))
    as TTBXDockablePanel).Visible := (Sender as TTBXItem).Checked;
end;


procedure TFmp3.TBXCBmintotrayChange(Sender: TObject);
begin
  if TBXCBmintotray.Checked
    then TBXCBtrayicon.Checked := true;
  TrayIcon.MinimizeToTray := TBXCBmintotray.State = cbChecked;
end;


procedure TFmp3.TBXCBtaskbutttonChange(Sender: TObject);
begin
  if TBXCBtaskbuttton.State = cbChecked
    then
      begin
        TrayIcon.ShowTaskbarIcon;
        TBXCBmintotray.Checked := true;
      end
    else
      begin
        TrayIcon.HideTaskbarIcon;
        TBXCBscrolltitle.Checked := false;
        TBXCBtrayicon.Checked := true;
        TBXCBmintotray.Checked := true;
      end;
end;


procedure TFmp3.TBXCBtrayiconChange(Sender: TObject);
begin
  if TBXCBtrayicon.State = cbChecked
    then
      begin
        TrayIcon.IconVisible := true;
        TBXCBtaskbuttton.Enabled := true;
        TBXCBmintotray.Enabled := true;
      end
    else
      begin
        TrayIcon.IconVisible := false;
        TBXCBtaskbuttton.Checked := true;
        TBXCBmintotray.Checked := false;
      end;
end;


procedure TFmp3.TBXCBscrolltitleChange(Sender: TObject);
begin
  if TBXCBscrolltitle.State = cbChecked
    then
      begin
        Ttaskbarscroller.Enabled := true;
        TBXCBtaskbuttton.Checked := true;
      end;
end;


procedure TFmp3.FormShow(Sender: TObject);
var i:integer;
    Parameter : TStringlist;
    flag : boolean;
begin
  if not CreateDone
  then
    begin
    try
      Foutput.LMDLabel1.Font.Size:=Screen.Height div 40;
      Foutput.Label1.Canvas.Font:=Foutput.LMDLabel1.Font;
      ScreenText(EMATTITLE);

      Save.L_Einstellungen;
      Save.L_OffenePlaylisten;
      SetColor;

      TrayIcon.Hint:=EMATTITLE;
      Tanimation.Enabled:=true;

      DockablePanelMenuErstellen;
      ToolbarMenuErstellen;
    except
      Fehler(STARTUPERROR);
    end;

    if paramcount>=1 then
      begin
        flag:=false;
        Parameter:=TStringlist.Create;
        for i:=1 to paramcount do
          begin
          //Playliste
          if ExtractFileExt(paramstr(i))=PlayListExt
          then ListeLaden(paramstr(i));
          //Ordner
          if DirectoryExists(paramstr(i))
          then
           begin
             ErzeugeNeuePlayListe;
             Datenbank.OrdnerAnListeAnhaengen(paramstr(i),Aktiv.Liste);
             DatenbankListeAusgeben(Aktiv.Liste);
           end;
          //MP3
          if Spieler.ZustaendigerRenderKern(ExtractFileExt(paramstr(i)))>=0
          then
           begin
           Parameter.Add(paramstr(i));
           flag:=true;
           end;
          end;
        if flag then
        begin
        ErzeugeNeuePlayListe;
        AddFiles(Aktiv.Liste,Parameter);
        end;
        Parameter.Free;
      end;

    CreateDone := true;
  end;
end;


procedure TFmp3.ScreenText(Text: string);   //uk  //fixed
begin
  if TBXCBhud.Checked
  then
  begin
  Foutput.LMDLabel1.Caption:=Text;
  Foutput.Left:=Foutput.Width div 2 - Foutput.Label1.Canvas.TextWidth(Text) div 2;
//  Foutput.LMDLabel1.Top:=Foutput.Height - Foutput.LMDLabel1.Height*2;

  Screenoutdone:=true;
  Foutput.Timer1.Enabled:=true;
  ShowWindow(Foutput.Handle, SW_SHOWNOACTIVATE);
 // Foutput.Show;
  end;
end;

procedure TFmp3.WMDROPFILES (var Msg: TMessage);
var i, anzahl, size: integer;
  Dateiname: PChar;
begin
  inherited;
  Dateiname:='';
  anzahl := DragQueryFile(Msg.WParam, $FFFFFFFF, Dateiname, 255);
  for i := 0 to (anzahl - 1) do
  begin
    size := DragQueryFile(Msg.WParam, i , nil, 0) + 1;
    Dateiname:= StrAlloc(size);
    DragQueryFile(Msg.WParam,i , Dateiname, size);

    if ExtractFileExt(Dateiname)=PlaylistExt then ListeLaden(Dateiname); //uk
  
       
    StrDispose(Dateiname);
  end;
  DragFinish(Msg.WParam);
end;

procedure TFmp3.GoToUrl(url: string);
begin
  if MessageDlg(Format(GOURL, [url]),mtInformation,[mbYes,mbNo],0)=mrYes
    then ShellExecute(Application.Handle, 'open',PChar(url), nil, nil, SW_ShowNormal);
end;

procedure TFmp3.Fehler(Meldung: string);
begin
  MessageDlg(Meldung,mtError,[mbOK],0);
end;

procedure TFmp3.ToolbarMenuErstellen;   //uk
var
  TBXItem: TTBXItem;
  i       : integer;
begin
  try
    for i := 1 to Anzahl_TBXToolbars do
      begin
        TBXItem:=TTBXItem.Create(fmp3);
        TBXItem.Name:='TBX_TB_Item_Liste'+inttostr(i);
        TBXItem.Caption:=(FindComponent('TBXToolbar'+IntToStr(i)) as TTBXToolbar).Caption;
        TBXItem.Checked:=(FindComponent('TBXToolbar'+IntToStr(i)) as TTBXToolbar).Visible;
        TBXItem.OnClick:=TBX_TB_ItemClick;
        TBXItem.Tag:=i;
        TBXSubmenuItem5.Add(TBXItem);
        (FindComponent('TBXToolbar'+IntToStr(i)) as TTBXToolbar).Tag:=i;
      end;
  except
    Fehler(Format(MENUEERROR, [TOOLBARCAPTION]));
  end;
end;

procedure TFmp3.TBX_TB_ItemClick(Sender: TObject);   //uk
begin
  (Sender as TTBXItem).Checked:=not (Sender as TTBXItem).Checked;
  (FindComponent( 'TBXToolbar'+IntToStr((Sender as TTBXItem).Tag)) as TTBXToolbar).Visible:=
    (Sender as TTBXItem).Checked;
end;

procedure TFmp3.TBXToolbar1Close(Sender: TObject);
begin
try
  (FindComponent('TBX_TB_Item_Liste'+IntToStr((Sender as TTBXToolbar).Tag)) as TTBXItem).Checked:=false;
except
  Fehler(CHEKEDERROR);
end;
end;


procedure TFmp3.AtitelmarkierenClick(Sender: TObject);
begin
 LTitel.OnClick(fmp3);
end;

procedure TFmp3.ElementLoeschen(ListenNummer,ElementNummer:integer);
var FullFileName : string;
    flag         : boolean;
    markiert,ArrayIndex : integer;
begin
  flag:=false;
  if Datenbank.EintragExists(ListenNummer,ElementNummer,ArrayIndex)
  then
  begin
   if (TBXI_HDDLoeschmodus.Checked) then
    if Datenbank.GetMediumFullFileName(ListenNummer,ElementNummer,FullFileName)
    then
      begin
        if (Aktiv.SpielendeListe=ListenNummer)
        and (Aktiv.SpielendesElement=ElementNummer)
        then Weiterschalten;
        flag:=DeleteFileToRecycleBin(FullFileName);
        if not flag then fehler(Format(DEL_FALSE, [fullfilename]));
      end;

    if (flag) or (not TBXI_HDDLoeschmodus.Checked) then
    begin
     Datenbank.DeleteItem(ListenNummer,ElementNummer);
     markiert:=FPlaylisten[ListenNummer].Gliste1.markiertesElement;
     DatenbankListeAusgeben(ListenNummer);
     Fplaylisten[ListenNummer].Gliste1.markiertesElement:=markiert;
     Fplaylisten[ListenNummer].Gliste1.Draw;
    end;
  end;
end;

function TFmp3.DeleteFileToRecycleBin(const AFile: string): boolean;
var
  Operation: TSHFileOpStruct;
begin
  with Operation do
  begin
    Wnd := Application.Handle;
    wFunc := FO_DELETE;
    pFrom := PChar(AFile +#0);
    pTo := Nil;
    { in den Papierkorb verschieben / keine
      Sicherheitsabfrage }
    fFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION;
  end;
  Result := SHFileOperation(Operation) = 0;
end;

procedure TFmp3.TBXIopenfolderClick(Sender: TObject);
begin
  OpenFolderAndMarkFile(Ltitel.Caption);
end;

procedure TFmp3.OpenFolderAndMarkFile(FileName: string);
begin
  if FileExists(FileName)
    then ShellExecute(GetDesktopWindow, 'open', 'Explorer', PChar(
      '/select, "' + FileName +'"'), nil, SW_SHOWNORMAL);
end;

procedure TFmp3.LTitelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Ltitel.Caption=''
    then exit;
  if Button=mbleft
    then MarkInList
    else TBXPM_Ltitel.Popup(Mouse.CursorPos.X,Mouse.CursorPos.Y);
end;

procedure TFmp3.FormCreate(Sender: TObject);
begin
try
  CreateDone := false;
  Randomize;
  Aktiv.Liste:=-1;
  Aktiv.SpielendeListe:=-1;
  Aktiv.SpielendesElement:=-1;

  Speicherpfad:=extractfilepath( application.ExeName )+'custom\';
  ForceDirectories(Speicherpfad);

  TBIniLoadPositions(Self,Speicherpfad+VISSETTINGS, '');

{  if not BASS_Init(1, 44100, 0, Application.Handle, nil)
  then  fehler(BASS_INIT_ERROR);    }
        //Anstatt bassplayer...

  Spieler:=TSpieler.Create;
  Spieler.OnWeiterschalten:=Weiterschalten;

  Save:=TSave.Create( Speicherpfad+GENERALSETTINGS);

  SetLength(FPlaylisten,0);
  Datenbank:=TDatenbank.Create;

  fmp3.caption:=FORMTITLE+Version;
  Application.Title:=EMATTITLE;
//  Fmp3.DoubleBuffered:=true;

  OpenD.Filter:='Emat Playlist (*'+PlaylistExt+')|*'+PlaylistExt;
  SaveD.Filter:=OpenD.Filter;
  SaveD.DefaultExt:=PlaylistExt;
  
        //TBX-Themes einbinden
  GetAvailableTBXThemes(LBthemes.Items);

        //Hand-Cursor aus Windows uk
  handCursor := LoadCursor(0, IDC_HAND);
  if handCursor <> 0 then Screen.Cursors[crHandPoint] := handCursor;

  DragAcceptFiles(Fmp3.Handle, true);//Drag&Drop von Win in die PlaylistListbox
except
  Fehler(STARTUPERROR);
end;
end;

procedure TFmp3.TBXDockablePanel1Close(Sender: TObject);
begin
try
  (FindComponent('TBX_DP_Item'+IntToStr((Sender as TTBXDockablePanel).Tag)) as TTBXItem).Checked:=false;
except
  Fehler(CHEKEDERROR);
end;
end;

procedure TFmp3.TBXDockablePanel1Resize(Sender: TObject);
begin
if CreateDone then EQDraw;
end;

procedure TFmp3.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = vk_delete
    then ADelFromList.Execute;
end;

procedure TFmp3.TBXDockablePanel2Resize(Sender: TObject);
begin
 if CreateDone
   then Spieler.SpectrumResize;
end;

procedure TFmp3.GHK_vorherKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if fmp3.TBXCBSysHKey.Checked then
 ZurueckSchalten;
end;

procedure TFmp3.AddFiles(ListenNummer:integer;Files:TStringlist);
var i:integer;
begin
  if files.Count>0
  then
  begin
    for i:=0 to files.Count-1 do
      Datenbank.AddFile(ListenNummer,files[i]);
  //  Files.Free;
    DatenbankListeAusgeben(ListenNummer);
  end;
end;


procedure TFmp3.OpenPDClose(Sender: TObject);
begin
  ihintergrund.Visible := false;//Es gibt nichts wie "Refresh", das funktioniert
  ihintergrund.Visible := true; //Also erzwinge ich so das Zeichnen | uk ;-)
end;

procedure TFmp3.ResetEQ;           //uk
var
  i: integer;
begin
  for i := 1 to High(fmp3.Spieler.eqwert) do
    fmp3.Spieler.eqwert[i] := 0;
  Spieler.EQSetWerte;
  EQDraw;
end;

procedure TFmp3.TBXI_reseteqClick(Sender: TObject);
begin
  ResetEQ;
end;

procedure TFmp3.AnewlistExecute(Sender: TObject);
begin
  ErzeugeNeuePlayliste;
end;

procedure TFmp3.AnextExecute(Sender: TObject);
begin
  Weiterschalten;
end;

procedure TFmp3.AplayExecute(Sender: TObject);
begin
  Spiele(Aktiv.SpielendeListe,Aktiv.SpielendesElement);
end;

procedure TFmp3.AopenlistExecute(Sender: TObject);
begin
  if OpenD.Execute
    then ListeLaden(OpenD.FileName);
end;

procedure TFmp3.AcloseExecute(Sender: TObject);
begin
  close;
end;

procedure TFmp3.AcascadeExecute(Sender: TObject);
begin
  Cascade;
end;

procedure TFmp3.AtileExecute(Sender: TObject);
begin
  Tile;
end;

procedure TFmp3.AdefaultExecute(Sender: TObject);
begin
  TBXAnordnungReset;
end;

procedure TFmp3.AanimationExecute(Sender: TObject);
begin
  Tanimation.Enabled := true;
end;

procedure TFmp3.AhelpExecute(Sender: TObject);
begin
  Finfo.Show;
  Finfo.ItemClick(finfo, 4);
end;

procedure TFmp3.AinfoExecute(Sender: TObject);
begin
  Finfo.Show;
  Finfo.ItemClick(finfo, 0);  
end;

procedure TFmp3.AlogoExecute(Sender: TObject);
begin
  Fstart.Position := poMainFormCenter;
  Fstart.Showmodal;
end;

procedure TFmp3.AwebsiteExecute(Sender: TObject);
begin
  GoToUrl(Website);
end;

procedure TFmp3.AupdateExecute(Sender: TObject);
begin
  GoToUrl(Updatepage);
end;

procedure TFmp3.AshuffleExecute(Sender: TObject);
begin
  if Ashuffle.Checked
    then
      begin
        Ashuffle.Checked := false;
        Ashuffle.Caption := SHUFFLE_ON;
        ScreenText(SHUFFLE_ON);
      end
    else
      begin
        Ashuffle.Checked := true;
        Ashuffle.Caption := SHUFFLE_OFF;
        ScreenText(SHUFFLE_OFF);
      end;
end;

procedure TFmp3.ADelFromHDDExecute(Sender: TObject);
begin
  if DeleteFileToRecycleBin(ListBox1.Items[ListBox1.ItemIndex])
  then
    Listbox1.Items.Delete( Listbox1.ItemIndex )
  else
    Fehler(Format(DEL_FALSE, [ ListBox1.Items[ ListBox1.ItemIndex ] ]));
end;

procedure TFmp3.ADelFromListExecute(Sender: TObject);
begin
  if Listbox1.ItemIndex>=0 then
  Listbox1.Items.Delete( Listbox1.ItemIndex );
end;

procedure TFmp3.AmarkinlistExecute(Sender: TObject);
begin
  MarkInList; 
end;

procedure TFmp3.AhdddelExecute(Sender: TObject);
begin
{if TBXI_HDDLoeschmodus.Checked
  then MessageDlg(HDD_DEL, mtWarning, [mbOk], 0);    }
end;

procedure TFmp3.AprevExecute(Sender: TObject);
begin
  Zurueckschalten;
end;

procedure TFmp3.ApauseExecute(Sender: TObject);
begin
  Pause;
end;

procedure TFmp3.AstopExecute(Sender: TObject);
begin
  Stop;
end;

procedure TFmp3.PBSpectrumMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  mode: integer;
begin
  if Button = mbLeft
    then
      begin
        mode := PBspectrum.Tag;
        incex(mode, MAXVISMODE);
        PBspectrum.Tag := mode;
        Spieler.SetBassVisOutput(mode)
      end;
end;


procedure TFmp3.Aspectrum0Execute(Sender: TObject);
begin
  Spieler.SetBassVisOutput((Sender as TAction).Tag);
end;


procedure TFmp3.SetListsInAktive(exceptList:integer);
var i : integer;
begin
  for i:=0 to High(Fplaylisten) do
  begin
    if Datenbank.ListeExists(i)
    then
     begin
       FPlaylisten[i].Gliste1.aktiv:=(i=exceptList);
       if (i<>exceptList) then FPlaylisten[i].Gliste1.fortschrittlichesElement:=-1;
       FPlaylisten[i].Gliste1.Draw;
     end;
  end;
end;
procedure TFmp3.TBXLink2Click(Sender: TObject);
begin
  if OpenPD.Execute
    then ihintergrund.Picture.LoadFromFile(OpenPD.FileName);
end;

procedure TFmp3.TBXLink1Click(Sender: TObject);
begin
  ColorD.Color := fmp3.Color;
  if ColorD.Execute
    then
      begin
        fmp3.Color := ColorD.Color;
        fmp3.Hide;    //sonst gibt es kein refresh...
        fmp3.Show;
      end;

end;

procedure TFmp3.ListBox1DblClick(Sender: TObject);
begin
  ListeLaden( ListBox1.Items[ ListBox1.ItemIndex ] )
end;

procedure TFmp3.GHKRestartKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if fmp3.TBXCBSysHKey.Checked then
  Spule(0);
end;

procedure TFmp3.LMDpathMouseEnter(Sender: TObject);
begin
 (Sender as TLMDLabel).Font.Style := [fsunderline];
end;

procedure TFmp3.LMDpathMouseExit(Sender: TObject);
begin
 (Sender as TLMDLabel).Font.Style := [];
end;

procedure TFmp3.LMDpathClick(Sender: TObject);
begin
  OpenFolderAndMarkFile(LMDpath.Caption);
end;

procedure TFmp3.TBXIbackClick(Sender: TObject);
begin
  Zurueckschalten;
end;

procedure TFmp3.TBXItem4Click(Sender: TObject);
begin
  MessageDlg(HDD_DEL, mtinformation, [mbok], -1);
end;

procedure TFmp3.TBXItem13Click(Sender: TObject);
begin
  //markiertes Element löschen
  if FPlaylisten[Aktiv.Liste].Gliste1.markiertesElement>-1
  then  fmp3.ElementLoeschen(Aktiv.Liste,
          strtoint(FPlaylisten[Aktiv.Liste].Gliste1.Liste.Nummer[
                FPlaylisten[Aktiv.Liste].Gliste1.markiertesElement]));
end;

procedure TFmp3.GH_DelKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if fmp3.TBXCBSysHKey.Checked then
  TBX_del_play_itemClick(Sender);
end;

procedure TFmp3.TBX_del_play_itemClick(Sender: TObject);
begin
  //spielendes Element löschen
  fmp3.ElementLoeschen(Aktiv.SpielendeListe,Aktiv.SpielendesElement);
end;


procedure TFmp3.Delay(Milliseconds: Integer); 
var 
  Tick: DWord; 
  Event: THandle; 
begin 
  Event := CreateEvent(nil, False, False, nil); 
  try 
    Tick := GetTickCount + DWord(Milliseconds); 
    while (Milliseconds > 0) and 
          (MsgWaitForMultipleObjects(1, Event, False, Milliseconds, QS_ALLINPUT) <> WAIT_TIMEOUT) do 
    begin 
      Application.ProcessMessages; 
      Milliseconds := Tick - GetTickcount; 
    end; 
  finally 
    CloseHandle(Event); 
  end; 
end;



end.
