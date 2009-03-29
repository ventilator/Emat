unit ump3;

{
  EMAT - Einfaches Mp3 Ausmist Tool

  (c) 2004-2006 Clemens & David Grünewald

  Compilierbar mit Delphi 2005 PE und den zusätzlichen Komponenten
   -TB2k 2.0.15 und TBX 2.1 incl TBXProgressBar und dem Skinmanager
   -LMD FreeEdition 9.0 für D2k5
   -CoolTrayIcon 1.0
   -Image32 1.6

  Danke für die Unterstützung von delphi-praxis.net
}



interface

uses
  Windows, Messages, FileCtrl, SysUtils, Variants, Classes, Graphics, Controls,
  Dialogs, ToolWin, ActnList, clipbrd, jpeg, StdCtrls, StdActns, ExtCtrls,
  ImgList, ComCtrls, Grids, mmsystem, registry,  Menus, shellapi, Forms,
  Buttons,  ExtDlgs, strutils, XPMan, TlHelp32,

  TBX, TB2Dock, TBXDkPanels, TB2Toolbar, TB2Item, TBXExtItems, TB2Common,
  TB2ExtItems, TBXLists, TBXToolPals, TBXSwitcher, TBXThemes, TBXMDI,
  TBXProgressBar, TBXStatusBars,

  LMDControl, LMDBaseControl, LMDBaseGraphicControl, LMDBaseLabel,
  LMDCustomLabel, LMDLabel, LMDContainerComponent, LMDBaseDialog,
  LMDCustomComponent, LMDCustomControl, LMDCustomPanel,
  LMDCustomBevelPanel, LMDSimplePanel, LMDGraphicControl, LMDShadowFill,
  LMDWndProcComponent,

  CoolTrayIcon, GR32_Image, UnitWDBIPCDemoObj,
  bass,

  u_bassplayer,                                                       
  udatenbank, usave, uspieler, ulang, uincex, uliste, GListe2, ustatus,
  LMDOneInstance, LMDBaseEdit, LMDCustomEdit, LMDCustomBrowseEdit,
  LMDCustomFileEdit, LMDFileOpenEdit, LMDFill, LMDCustomComboBox;


const
  Version     = '0.80.16';
  FormCaption = '';
  maxVolume   = 100;
  Anzahl_TBXDockablePanel = 14;
  PlaylistExt     = '.epl';
  VISSETTINGS     = 'Aussehen.ini';
  WALLPAPER       = 'images\hintergrund.jpg';
  DIRNAMEPLAYLIST = 'Playlist\';
  GENERALSETTINGS = 'Emat.ini';
  HELPFILE        = 'emat.rtf';

  {
    Gliste.Tag2 Definition

    0 = Standard (alle anderen Glisten)
    1 = Playlistenliste
    2 = History/Verlauf
    3 = Favoriten   
  }

const
  WM_BASSPLAYERSTOPPED = WM_USER + 1614;

const
   APPCOMMAND_MEDIA_NEXTTRACK      = $B0000; // 720896;
   APPCOMMAND_MEDIA_PREVIOUSTRACK  = $C0000; // 786432;
   APPCOMMAND_MEDIA_STOP           = $D0000; // 851968;
   APPCOMMAND_MEDIA_PLAY_PAUSE     = $E0000; // 917504;

type
   TAktiv = record
     Liste             : integer;
     SpielendeListe    : integer;
     SpielendesElement : integer;
     Spielt            : boolean;
     MarkierteListe    : integer;
     MarkiertesElement : integer;
     SpielenderTitel   : string;
     MarkiertesElementDir   : string;
     ScreenText_Text        : string;
     ScreenText_Titellaenge : string;
     ScreenText_TextWidth,
     ScreenText_TextHeight: integer;
     ScreenText_Album,
     ScreenText_Dauer,
     ScreenText_Jahr      : string;
     ScreenText_isTitle   : boolean;
     MainColor            : TColor;
     Shuffelrange         : integer;
     SelDirPath           : string;
   end;

type
  TFmp3 = class(TForm)
    ILSymbolleiste: TImageList;
    SaveD: TSaveDialog;
    OpenD: TOpenDialog;
    TrayIcon: TCoolTrayIcon;
    TBXMultiDock1: TTBXMultiDock;
    TBXMultiDock2: TTBXMultiDock;
    TBXMultiDock3: TTBXMultiDock;
    TBXMultiDock4: TTBXMultiDock;
    TBXDockablePanel2: TTBXDockablePanel;
    TBXDockablePanel3: TTBXDockablePanel;
    TBXDockablePanel5: TTBXDockablePanel;
    TBXDockablePanel6: TTBXDockablePanel;
    LTitel_old: TLabel;
    SpielerTimer: TTimer;
    ihintergrund: TImage;
    TBXDockablePanel7: TTBXDockablePanel;
    ILanimation: TImageList;
    Tanimation: TTimer;
    TBXPBar: TTBXProgressBar;
    Ttaskbarscroller: TTimer;
    TBXDock1: TTBXDock;
    TBXDock2: TTBXDock;
    TBXDock3: TTBXDock;
    TBXDock4: TTBXDock;
    TBXToolbar1: TTBXToolbar;
    TBXSubmenuItem7: TTBXSubmenuItem;
    TBXInewplaylist: TTBXItem;
    TBXIclose: TTBXItem;
    TBXSubmenuItem12: TTBXSubmenuItem;
    TBXIhelp: TTBXItem;
    TBXSeparatorItem15: TTBXSeparatorItem;
    TBXIwebseite: TTBXItem;
    TBXOpenplaylist: TTBXItem;
    TBXLabel1: TTBXLabel;
    TBXPageScroller1: TTBXPageScroller;
    TBXAPStyle: TTBXAlignmentPanel;
    TBXLabel2: TTBXLabel;
    TBXCBscrolltitle: TTBXCheckBox;
    TBXCBtrayicon: TTBXCheckBox;
    TBXCBtaskbuttton: TTBXCheckBox;
    TBXCBmintotray: TTBXCheckBox;
    TBXSeparatorItem2: TTBXSeparatorItem;
    TBXSubmenuItem2: TTBXSubmenuItem;
    TBXMDIWindowItem2: TTBXMDIWindowItem;
    TBXSeparatorItem14: TTBXSeparatorItem;
    TBXIreset: TTBXItem;
    TBXLabel4: TTBXLabel;
    TBXCBhud: TTBXCheckBox;
    TBXIupdates: TTBXItem;
    TBXPopupMenu3: TTBXPopupMenu;
    TBXSeparatorItem1: TTBXSeparatorItem;
    TBXPM_Ltitel: TTBXPopupMenu;
    TBXIopenfolder: TTBXItem;
    TBXIcopypath: TTBXItem;
    TBXImarkinlist: TTBXItem;
    TBXDockablePanel1: TTBXDockablePanel;
    IEQ: TPaintBox;
    TBXAlignmentPanel2: TTBXAlignmentPanel;
    TBXAlignmentPanel3: TTBXAlignmentPanel;
    TBXAlignmentPanel6: TTBXAlignmentPanel;
    TBXAlignmentPanel4: TTBXAlignmentPanel;
    TBXPM_GPlaylisten: TTBXPopupMenu;
    TBXI_DelFromList: TTBXItem;
    TBXI_DelFormHDD: TTBXItem;
    TBXLabel5: TTBXLabel;
    TBXLink1: TTBXLink;
    OpenPD: TOpenPictureDialog;
    ActionList1: TActionList;
    Aopenlist: TAction;
    Aclose: TAction;
    Atile: TAction;
    Acascade: TAction;
    Adefault: TAction;
    Aanimation: TAction;
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
    TBXLink2: TTBXLink;
    ODMedia: TOpenDialog;
    TBXCBSysHKey: TTBXCheckBox;
    TBXCBSearchAutoPlay: TTBXCheckBox;
    TBXDockablePanel8: TTBXDockablePanel;
    TClock: TTimer;
    TBXPBVolume: TTBXProgressBar;
    TBXSeparatorItem4: TTBXSeparatorItem;
    TBXItem14: TTBXItem;
    TBXIspeichernunter: TTBXItem;
    TBXIsavelist: TTBXItem;
    TBXItem17: TTBXItem;
    TBXItem18: TTBXItem;
    TBXI_RescanFolders: TTBXItem;
    TBXPMbackcolor: TTBXPopupMenu;
    TBXCPback: TTBXColorPalette;
    TBXSIspezial: TTBXSubmenuItem;
    TBXItem16: TTBXItem;
    TBXItem19: TTBXItem;
    TBXItem20: TTBXItem;
    TBXMDIHandler1: TTBXMDIHandler;
    TBXItem22: TTBXItem;
    TBXIcloselist: TTBXItem;
    TBXVisPause: TTBXButton;
    TBXButton4: TTBXButton;
    TBXAlignmentPanel5: TTBXAlignmentPanel;
    TBXDockablePanel4: TTBXDockablePanel;
    TBXItem6: TTBXItem;
    TBXItem5: TTBXItem;
    TBXSeparatorItem5: TTBXSeparatorItem;
    TBXSeparatorItem6: TTBXSeparatorItem;
    TBXSeparatorItem7: TTBXSeparatorItem;
    TBXPageScroller5: TTBXPageScroller;
    Etitel: TEdit;
    TBXPageScroller2: TTBXPageScroller;
    TBXAlignmentPanel7: TTBXAlignmentPanel;
    TBXSeparatorItem9: TTBXSeparatorItem;
    Aalwaysontop: TAction;
    TBXAPplaylistList: TTBXAlignmentPanel;
    TBXDockablePanel9: TTBXDockablePanel;
    TBXAlignmentPanel8: TTBXAlignmentPanel;
    Icover: TImage;
    TBXPMsearch: TTBXPopupMenu;
    TBXItem8: TTBXItem;
    TBXDockablePanel10: TTBXDockablePanel;
    TBXAPhistory: TTBXAlignmentPanel;
    TBXPMVisualisierung: TTBXPopupMenu;
    TBXIvis1: TTBXItem;
    TBXIvis2: TTBXItem;
    TBXIvis3: TTBXItem;
    TBXIvis4: TTBXItem;
    TBXIvis5: TTBXItem;
    TBXIvis6: TTBXItem;
    TBXIvis7: TTBXItem;
    TBXIvis8: TTBXItem;
    TBXIvis9: TTBXItem;
    TBXIvis10: TTBXItem;
    TBXIvis11: TTBXItem;
    TBXIvis12: TTBXItem;
    TBXSeparatorItem10: TTBXSeparatorItem;
    TBXSeparatorItem11: TTBXSeparatorItem;
    TBXPMHistory: TTBXPopupMenu;
    TBXIHistoryPlay: TTBXItem;
    TBXCBvis: TTBXCheckBox;
    TBXDockablePanel11: TTBXDockablePanel;
    TBXAPfavorit: TTBXAlignmentPanel;
    TBXLabel6: TTBXLabel;
    TBXLabel7: TTBXLabel;
    TBXCB_AutoOSD: TTBXCheckBox;
    Mosdexenames: TMemo;
    TBXAlignmentPanel1: TTBXAlignmentPanel;
    CbArtist: TTBXCheckBox;
    TBXAlignmentPanel9: TTBXAlignmentPanel;
    CBComment: TTBXCheckBox;
    TBXAlignmentPanel10: TTBXAlignmentPanel;
    CBGenre: TTBXCheckBox;
    TBXAlignmentPanel11: TTBXAlignmentPanel;
    TBXAlignmentPanel12: TTBXAlignmentPanel;
    CBAlbum: TTBXCheckBox;
    LEalbum: TLabeledEdit;
    LEgenere: TLabeledEdit;
    LEartist: TLabeledEdit;
    TBXAlignmentPanel13: TTBXAlignmentPanel;
    TBXAlignmentPanel14: TTBXAlignmentPanel;
    cbtitle: TTBXCheckBox;
    LETitle: TLabeledEdit;
    LEcomment: TLabeledEdit;
    TBXAlignmentPanel15: TTBXAlignmentPanel;
    TBXBSaveID3: TTBXButton;
    TBXAlignmentPanel16: TTBXAlignmentPanel;
    TBXAlignmentPanel17: TTBXAlignmentPanel;
    CBYear: TTBXCheckBox;
    LEyear: TLabeledEdit;
    LETrack: TLabeledEdit;
    CBTrack: TTBXCheckBox;
    TBXIback: TTBXItem;
    TBXIstop: TTBXItem;
    TBXIpause: TTBXItem;
    TBXIplay: TTBXItem;
    TBXInext: TTBXItem;
    TBXIShuffle: TTBXItem;
    TBXItem4: TTBXItem;
    Esuche: TTBXComboBoxItem;
    TBXItem7: TTBXItem;
    TBXItem9: TTBXItem;
    TBXI_ScreenText: TTBXCheckBox;
    TBXIselect_cols: TTBXItem;
    TBXSeparatorItem12: TTBXSeparatorItem;
    Label1: TLabel;
    TBXAlignmentPanel18: TTBXAlignmentPanel;
    Mpath: TMemo;
    I32_Vis: TImage32;
    TBXAPclock0: TTBXAlignmentPanel;
    PH1: TLMDSimplePanel;
    PH3: TLMDSimplePanel;
    PH4: TLMDSimplePanel;
    PH5: TLMDSimplePanel;
    PM1: TLMDSimplePanel;
    PM2: TLMDSimplePanel;
    PM3: TLMDSimplePanel;
    PM4: TLMDSimplePanel;
    PM5: TLMDSimplePanel;
    PM6: TLMDSimplePanel;
    PS1: TLMDSimplePanel;
    PS2: TLMDSimplePanel;
    PS3: TLMDSimplePanel;
    PS4: TLMDSimplePanel;
    PS5: TLMDSimplePanel;
    PS6: TLMDSimplePanel;
    PH2: TLMDSimplePanel;
    TBinClock: TTimer;
    TBXDockablePanel12: TTBXDockablePanel;
    TBXDockablePanel13: TTBXDockablePanel;
    TBXAlignmentPanel19: TTBXAlignmentPanel;
    PH0: TLMDSimplePanel;
    TBXSubmenuItem3: TTBXSubmenuItem;
    TBXItem10: TTBXItem;
    TBXI_RemoveDir: TTBXItem;
    TBXI_DelInvalideItems: TTBXItem;
    TBXDockablePanel15: TTBXDockablePanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    TBXButton1: TTBXButton;
    TBXButton2: TTBXButton;
    TBXCheckBox1: TTBXCheckBox;
    TBXLabel9: TTBXLabel;
    BitBtn1: TBitBtn;
    Edit1: TEdit;
    TBXI_Queue_Items: TTBXItem;
    TBXPM_Favorit: TTBXPopupMenu;
    TBXI_Queue_Item_Fav: TTBXItem;
    TBXCBCoverSearch: TTBXCheckBox;
    TBXB_HighPriority: TTBXCheckBox;
    TBXSubmenuItem1: TTBXSubmenuItem;
    TBXSeparatorItem3: TTBXSeparatorItem;
    TBXMDIWindowItem1: TTBXMDIWindowItem;
    ScreenText_refresher: TTimer;
    LMDFGradientCover: TLMDFill;
    TBXPMcover: TTBXPopupMenu;
    TBXIopencover: TTBXItem;
    TBXIopencoverdir: TTBXItem;
    LMDFBinClock: TLMDFill;
    TBXDockablePanel14: TTBXDockablePanel;
    TBXTdeloptions: TTBXToolbar;
    TBXItem13: TTBXItem;
    TBX_del_play_item: TTBXItem;
    TBXI_HDDLoeschmodus2: TTBXRadioButton;
    TBControlItem1: TTBControlItem;
    TBXI_HDDLoeschmodus: TTBXRadioButton;
    TBControlItem2: TTBControlItem;
    TBXSeparatorItem8: TTBXSeparatorItem;
    TBXItem11: TTBXItem;
    TBXPM_MetaInfo: TTBXPopupMenu;
    ActionList2: TActionList;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    TBXItem12: TTBXItem;
    TBXItem15: TTBXItem;
    TBXItem21: TTBXItem;
    TBXItem23: TTBXItem;
    TBXSeparatorItem13: TTBXSeparatorItem;
    TBXAlignmentPanel20: TTBXAlignmentPanel;
    TBXPB_shuffle: TTBXProgressBar;
    TBXSeparatorItem16: TTBXSeparatorItem;
    TBXLI_ShuffleRange: TTBXLabelItem;
    TBXCheckBox2: TTBXCheckBox;
    TBXCBAutoSave: TTBXCheckBox;
    TBXItem24: TTBXItem;
    procedure TBXItem24Click(Sender: TObject);
    procedure TBXPB_shuffleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TBXPB_shuffleMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TBXPB_shuffleMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TBXItem11Click(Sender: TObject);
    procedure TBXIopencoverdirClick(Sender: TObject);
    procedure TBXIopencoverClick(Sender: TObject);
    procedure IcoverClick(Sender: TObject);
    procedure ScreenText_refresherTimer(Sender: TObject);
    procedure TBXI_ScreenTextChange(Sender: TObject);
    procedure TBXB_HighPriorityChange(Sender: TObject);
    procedure TBXPM_FavoritPopup(Sender: TObject);
    procedure TBXPMHistoryPopup(Sender: TObject);
    procedure TBXI_Queue_Item_FavClick(Sender: TObject);
    procedure TBXI_Queue_ItemsClick(Sender: TObject);
    procedure LETitleKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TBXDockablePanel8VisibleChanged(Sender: TObject);
    procedure TBXI_DelInvalideItemsClick(Sender: TObject);
    procedure TBXI_RemoveDirClick(Sender: TObject);
    procedure TBXItem10Click(Sender: TObject);
    procedure LEcommentChange(Sender: TObject);
    procedure LEgenereChange(Sender: TObject);
    procedure LEyearChange(Sender: TObject);
    procedure LETrackChange(Sender: TObject);
    procedure LEalbumChange(Sender: TObject);
    procedure LEartistChange(Sender: TObject);
    procedure LETitleChange(Sender: TObject);
    procedure TBinClockTimer(Sender: TObject);
    procedure TBXIselect_colsClick(Sender: TObject);
    procedure TBXI_ScreenTextClick(Sender: TObject);
    procedure TScreenTextTimer(Sender: TObject);
    procedure TBXIHistoryPlayClick(Sender: TObject);
    procedure TBXItem32Click(Sender: TObject);
    procedure TBXIvis12Click(Sender: TObject);
    procedure TBXItem8Click(Sender: TObject);
    procedure EsucheChange(Sender: TObject; const Text: string);
    procedure TBXCBscrolltitleChange(Sender: TObject);
    procedure TBXCBmintotrayChange(Sender: TObject);
    procedure TBXCBtrayiconChange(Sender: TObject);
    procedure TrayIconMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AalwaysontopExecute(Sender: TObject);
    procedure AcloseExecute(Sender: TObject);
    procedure TBXItem4Click(Sender: TObject);
    procedure TBXItem7Click(Sender: TObject);
    procedure AopenlistExecute(Sender: TObject);
    procedure TBXPBarMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure EtitelDblClick(Sender: TObject);
    procedure TBXDockablePanel6Resize(Sender: TObject);
    procedure TBXItem5Click(Sender: TObject);
    procedure TBXItem6Click(Sender: TObject);
    procedure EtitelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TBXButton4Click(Sender: TObject);
    procedure TBXVisPauseClick(Sender: TObject);
    procedure TBXButton1Click(Sender: TObject);
    procedure TBXIcloselistClick(Sender: TObject);
    procedure OpenDFolderChange(Sender: TObject);
    procedure SaveDFolderChange(Sender: TObject);
    procedure TBXSubmenuItem7Click(Sender: TObject);
    procedure GH_hudKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TBXIhelpClick(Sender: TObject);
    procedure TBXItem22Click(Sender: TObject);
    procedure TBXItem20Click(Sender: TObject);
    procedure TBXItem19Click(Sender: TObject);
    procedure TBXItem16Click(Sender: TObject);
    procedure TBXCPbackChange(Sender: TObject);
    procedure TBXI_RescanFoldersClick(Sender: TObject);
    procedure TBXItem14Click(Sender: TObject);
    procedure TBXSubmenuItem1Click(Sender: TObject);
    procedure TBXItem18Click(Sender: TObject);
    procedure TBXItem17Click(Sender: TObject);
    procedure TBXIspeichernunterClick(Sender: TObject);
    procedure TBXIsavelistClick(Sender: TObject);
    procedure TBXPBVolumeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TBXPBVolumeMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TBXPBVolumeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TClockTimer(Sender: TObject);
    procedure PBarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TrayIconDblClick(Sender: TObject);
    procedure TBXIBeenden1Click(Sender: TObject);
    procedure TrayIconMinimizeToTray(Sender: TObject);

    procedure GHK_pauseKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GHK_nachherKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GHK_leiserKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GHK_lauterKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

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
    procedure TBXCBtaskbutttonChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
 //   procedure TBXToolbar1Close(Sender: TObject);
    procedure TBXIopenfolderClick(Sender: TObject);
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
    procedure AnewlistExecute(Sender: TObject);
    procedure AnextExecute(Sender: TObject);
    procedure AplayExecute(Sender: TObject);
    procedure AcascadeExecute(Sender: TObject);
    procedure AtileExecute(Sender: TObject);
    procedure AdefaultExecute(Sender: TObject);
    procedure AanimationExecute(Sender: TObject);
    procedure AlogoExecute(Sender: TObject);
    procedure AwebsiteExecute(Sender: TObject);
    procedure AupdateExecute(Sender: TObject);
    procedure AshuffleExecute(Sender: TObject);
    procedure ADelFromHDDExecute(Sender: TObject);
    procedure ADelFromListExecute(Sender: TObject);
    procedure AmarkinlistExecute(Sender: TObject);
    procedure AprevExecute(Sender: TObject);
    procedure ApauseExecute(Sender: TObject);
    procedure AstopExecute(Sender: TObject);
    procedure TBXLink2Click(Sender: TObject);
    procedure TBXLink1Click(Sender: TObject);
    procedure GHKRestartKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LMDpathMouseEnter(Sender: TObject);
    procedure LMDpathMouseExit(Sender: TObject);
    procedure LMDpathClick(Sender: TObject);
    procedure TBXIbackClick(Sender: TObject);
    procedure TBXItem13Click(Sender: TObject);
    procedure GH_DelKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TBX_del_play_itemClick(Sender: TObject);
    procedure MarkInList;
    procedure GStyleDoppelClick(Index :integer; Shift: TShiftState);
    procedure GHistory_KeyDown(Key:word;Shift:tshiftstate);
  private
    procedure WMBassPlayerStop(var Message: TMessage); message WM_BASSPLAYERSTOPPED;
    procedure Weiterschalten;
    procedure Zurueckschalten;
    procedure EQDraw;
    procedure Pause;
    procedure TBXAnordnungReset;
    function ErstesZeichenHintenDran(Text: string): string;
    procedure DockablePanelMenuErstellen;
    procedure TBX_DP_ItemClick(Sender: TObject);
    procedure ScreenText(Text: string; isTitle:boolean=false);
    procedure WMDROPFILES (var Msg: TMessage); message WM_DROPFILES;
 //   procedure TBX_TB_ItemClick(Sender: TObject);
 //   procedure ToolbarMenuErstellen;
    procedure ResetEQ;
    procedure MinimizeETitelPath(path: string);
    procedure OeffnePlayliste;
    procedure SuchfeldLoeschen(NeuerText: string = '');
    procedure SuchFeldMarkieren;
    procedure ShowOrHideFLaut;
    procedure WMQueryEndSession (var M: TWMQueryEndSession);
      message WM_QUERYENDSESSION;
    procedure GPlayListenDblClick(index: integer);
    procedure SetCover(dir: string; id: integer = 1);
    procedure SetCover_Next;
    procedure PlaylistenListeAdd(Dateiname: string);
    procedure AppDeaktivate(Sender : TObject);
    procedure AppAktivate(Sender : TObject);
    procedure GHistoryDoppelClick(Index :integer);
    procedure GFavoritDoppelClick(Index :integer);
    procedure MediaKey (Var aMSG: tMessage); message WM_APPCOMMAND;
{    procedure DrawTexttoDesktop(Text: String);
    function  IsExeRunning(ExeNames: Tstrings): boolean;
}    procedure HistoryDragOver ( Sender, Source:Tobject; x,y: integer;
                                State: TDragState; var accept:boolean);
    procedure History_DragItemInsert(Source: TObject; SourcePosition,
                                     SourceID:integer; Target: TObject;
                                     TargetPosition, TargetID: integer);
    procedure History_DragItemMove(Source: TObject; SourcePosition,
                                     SourceID:integer; Target: TObject;
                                     TargetPosition, TargetID: integer);
    procedure History_DeleteItem(Index:integer);
    procedure WriteText(TransText: string);
    procedure ClearScreenText;

    {
    function KeyboardHookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
    function UninstallHook: Boolean; stdcall;
    function InstallHook(Hwnd: Cardinal): Boolean; stdcall;
    }
    { Private-Deklarationen }
  public
    Spieler     : TSpieler;
    Aktiv       : Taktiv;
    Datenbank   : TDatenbank;
    FPlaylisten : array of TFPlayliste;
    tbxinfo: TTBXItemInfo;
    Speicherpfad : string;
    GPlayListen, GHistory, GStyle, GFavorit: TGListe2;
    procedure SetColor;
    function extractrealfilename(filename: string): string;
    { Public-Deklarationen }
    ///////0.75

    procedure Spule (Prozent :real);
    procedure ZeichneFortschritt(prozent: real; total: integer);
    procedure ErzeugeNeuePlayliste;
    procedure DatenbankListeAusgeben( ListenNummer:integer;
                                      SuchFeldAktualisieren:boolean=true;
                                      HistoryUndFavoritenNeuBerechnen:boolean=true );
    function  ListeLaden( DateiName: string ): boolean;
    procedure Suche(ListenNummer: integer; Text: string);
    procedure ElementMarkieren (ListenNummer,ElementNummer:integer);
    procedure ListeSpeichernUnter(ListenNummer:integer);
    procedure Stop;
    function DauerZuString(SpielDauer:int64;NurStundenUndMinuten:boolean=false):string;
    procedure GoToUrl(url: string);
    procedure Fehler(Meldung: string);
    procedure ElementLoeschen(ListenNummer, ElementNummer: integer);
    function Spiele(ListenNummer, ElementNummer: integer;
      ClearHistoryStatus: boolean=false; DoNotHistory:boolean=false):boolean;
    procedure Umbenennen(ListenNummer, ElementNummer: integer);
    procedure AddFiles(ListenNummer:integer; Files: TStringlist);
    procedure ListeAnfuegenOrdner;
    procedure SetListsInAktive(exceptList: integer);
    procedure OpenFolderAndMarkFile(FileName: string);
    function filesizetostr(int: real): string;
    procedure Delay(Milliseconds: Integer);
    procedure SetVolume(prozent: real);
    function GetVolume: real;
    procedure EnableMenues(Enable: boolean = true);
    procedure ListeSchliessenundSpeichern(ListenNummer:integer);
    procedure ListeSpeichern(ListenNummer:integer);
    procedure ErzeugeNeueApplauncherListe;
    procedure ParameterOpen(var Parameter:TStringlist);
    procedure ZeitmessungStart;
    function  ZeitmessungStopp:int64;
    procedure Zeitmessung2Start;
    function  Zeitmessung2Stopp:int64;
    procedure DrawGradient(const Canvas: TCanvas; Color1, Color2: TColor; Rect: TRect);
    procedure DeleteSelectedItems;
    procedure UpdateFStatus(FileName:string; FileCounter:integer);
    //Zeigt das Statusfenster und deaktiviert die Hauptform
    procedure InitFStatus;
    //Zeigt auch die Progressbar
    procedure StartFStatus(FileCount: integer);
    //Ändert nur den Text (ohne Prograssbar)
    procedure UpdateTextFStatus(ShowText:string; ShowCaption:string='');
    //Reaktiviert die Hauptform
    procedure HideFStatus;
    //Erhöht die Lautstärke um 5%
    procedure IncVolume;
    //Vermindert die Lautstärke um 5%
    procedure DecVolume;
    //Verschiebt Dateien und auch Verzeichnisse in den Papierkorb
    function DeleteFileToRecycleBin(const AFile: string): boolean;
    //Rechnet die Shufflestärke aus und speichert sie in Aktiv.Shufflerange
    procedure CalculateAndShowShufflerange;

    //Ruft einen Orderauswahldialog auf. Achtung: Braucht noch Fehlerbehandlung wenn abbruch gedrückt wird
    function SelDirectory(startverzeichnis:string):string;
end;

//function DezToX(dez, bas: Cardinal): String;

var
  Fmp3        : TFmp3;
  Save        : TSave;
  basshandle  : HWND;
  SearchRec: TSearchRec; //uk | Cover suchen
  BmpGradient_Clock: TBitMap;
  mHandle: THandle;

implementation


uses Ustart, Ulaut;

{$R *.dfm}

var
  noTBXsave  : boolean = false;
  minimiert  : boolean = false;
  EQtaste    : boolean = false;
  CreateDone : boolean = false;
  volumeMouseDown : boolean = false;
  shuffleMouseDown: boolean = false;
  iconnummer : integer = 1;
  Stoppuhr,Stoppuhr2   : int64;

//  hookhandle, mywindowhandle   : cardinal;

procedure TFmp3.Spule(Prozent :real);
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
  if (Aktiv.SpielendeListe = Aktiv.MarkierteListe)
    and (Aktiv.MarkiertesElement = Aktiv.SpielendesElement)
  then Stop;

  Datenbank.RenameItem(ListenNummer,ElementNummer);
  DatenbankListeAusgeben(ListenNummer);

  if (Aktiv.SpielendeListe = Aktiv.MarkierteListe)
    and (Aktiv.MarkiertesElement = Aktiv.SpielendesElement)
  then Spiele(Aktiv.SpielendeListe,Aktiv.SpielendesElement);
end;

procedure TFmp3.Zurueckschalten;
begin
  if DatenBank.ListeExists(Aktiv.Liste) then
    Spiele(Aktiv.Liste,Datenbank.GetPreviousElementNummer(Aktiv.Liste));
end;

procedure TFmp3.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) then
  begin
   case key of
     Ord('Z') : Zurueckschalten;
     Ord('P') : Spiele(Aktiv.SpielendeListe,Aktiv.SpielendesElement);
     Ord('W') : Weiterschalten;
     Ord('F') : SuchFeldMarkieren;
     Ord('E') : FPlaylisten[Aktiv.Liste].Addfile;
     Ord('D') : ListeAnfuegenOrdner;
     Ord('S') : ListeSpeichern(Aktiv.Liste);
     226 {<}  : SuchfeldLoeschen;
     220 {^}  : TBXItem4Click(Fmp3);
     vk_F5    : TBXI_RescanFoldersClick(fmp3);
     vk_Space : Pause;
     vk_Add   : TBXPBVolume.Position := TBXPBVolume.Position + 20;
     vk_Subtract : TBXPBVolume.Position := TBXPBVolume.Position - 20;
   end;
   if (ssCtrl in Shift) then
   begin
     case key of
       Ord('S') : ListeSpeichernUnter(Aktiv.Liste);
     end;
   end;
  end
  else
   case key of
     vk_Play  : Spiele(Aktiv.SpielendeListe,Aktiv.SpielendesElement);
     vk_F1    : Fstart.Show;
   end;

end;

 {
var oDemoObj : TWDB_IPCDemoObj;

function Tfmp3.InstallHook(Hwnd: Cardinal): Boolean; stdcall;
begin
  Result := False;
  if HookHandle = 0 then begin
    //Erstmal Hook installieren
    HookHandle := SetWindowsHookEx(WH_SHELL, @KeyboardHookProc, HInstance, 0);
    //Uebergebenes Fensterhandle sichern
    MyWindowHandle := Hwnd;
    oDemoObj := TWDB_IPCDemoObj.Create('NempNochEinMP3Player');
    oDemoObj.MainWindow := Hwnd;
    oDemoObj.HookHandle := HookHandle;
    Result := True;
    showmessage('Installiert ' + inttostr(HookHandle) + ' ' + inttostr(MyWindowHandle));
  end;
end;

function Tfmp3.UninstallHook: Boolean; stdcall;
begin
  Result := UnhookWindowsHookEx(oDemoObj.HookHandle);
end;

function Tfmp3.KeyboardHookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  oDemoObj := TWDB_IPCDemoObj.Create('NempNochEinMP3Player');
  case nCode < 0 of
    FALSE: 
      begin 
        if (lparam = APPCOMMAND_MEDIA_NEXTTRACK) 
            or (lparam = APPCOMMAND_MEDIA_PREVIOUSTRACK) 
            or (lparam = APPCOMMAND_MEDIA_STOP) 
            or (lparam = APPCOMMAND_MEDIA_PLAY_PAUSE) 
        then 
        begin 
          SendMessage(oDemoObj.MainWindow,WM_APPCOMMAND,wparam,lParam); 
          //showmessage('Abgefangen ' + inttostr(oDemoObj.HookHandle) + ' ' + inttostr(oDemoObj.MainWindow)); 
          Result := 1; 
        end 
        else 
          Result := CallNextHookEx(oDemoObj.HookHandle, nCode, wParam, lParam); 
      end; 
    else 
      Result := CallNextHookEx(oDemoObj.HookHandle, nCode, wParam, lParam); 
  end; 
end;
 }

function TFmp3.ExtractRealFilename(filename :string) :string;
begin
  Result:=Copy(Filename, 0, length(Filename)-length( ExtractFileExt(Filename) ))
end;

procedure TFmp3.FormClose(Sender: TObject; var Action: TCloseAction);
var i:integer;
begin
  Hide;

  //Alle Timer beenden
  Tanimation.Enabled:=false;
  SpielerTimer.Enabled:=false;
  Ttaskbarscroller.Enabled:=false;

  for i:=0 to High(FPlaylisten) do
  begin
   if Datenbank.Mp3DatenMeta[i].offen
   then
   begin
     if Datenbank.Mp3DatenMeta[i].FileName=''
       then
          begin
            if TBXCBAutoSave.Checked
            then
              begin
                Datenbank.CreateFileNameForPlaylist(i,ExtractFilePath(Application.ExeName)
                                            +DirNamePlaylist);
              end
            else
             if MessageDlg(SAVEPLS, mtConfirmation, [mbYes, mbNo], 0) = mrYes
             then fmp3.ListeSpeichernUnter(i);
     end;
     ListeSpeichern(i);
    end;
   end;

   Save.S_OffenePlaylisten;         //Damit Spielstatus abgespeichert wird
   Stop;

   for i:=0 to High(FPlaylisten) do
   begin
     ListeSchliessenUndSpeichern(i);
   end;


  Save.S_Einstellungen;
  Save.CloseIniFile;

  if not noTBXsave then TBIniSavePositions(Self,Speicherpfad+VISSETTINGS, '');

  Spieler.Free;
  BmpGradient_Clock.Free;
end;


procedure TFmp3.TrayIconDblClick(Sender: TObject);
begin
  if minimiert
    then
      begin
        flaut.Visible:=false;
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


procedure TFmp3.GHK_leiserKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if fmp3.TBXCBSysHKey.Checked then
    DecVolume;
end;

procedure TFmp3.GHK_lauterKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if fmp3.TBXCBSysHKey.Checked then
    begin
      IncVolume;
    end;
end;


procedure Tfmp3.IncVolume;
begin
  if TBXPBVolume.Position mod 5 <>0
   then SetVolume((TBXPBVolume.Position+5-TBXPBVolume.Position mod 5)/100)
   else SetVolume((TBXPBVolume.Position+5)/100);
end;


procedure Tfmp3.DecVolume;
begin
  if TBXPBVolume.Position mod 5 <>0
    then SetVolume((TBXPBVolume.Position-TBXPBVolume.Position mod 5)/100)
    else SetVolume((TBXPBVolume.Position-5)/100);
end;

               //Fortschrittliches Element nach oben/unten scrollen
procedure TFmp3.MarkInList;       //uk name
begin
 FPlaylisten[Aktiv.SpielendeListe].BringToFront;

 if FPlaylisten[Aktiv.SpielendeListe].GListe1.fortschrittlichesElement>=0
 then
 begin

  if FPlaylisten[Aktiv.SpielendeListe].GListe1.fortschrittlichesElement>5
  then
   if FPlaylisten[Aktiv.SpielendeListe].GListe1.fortschrittlichesElement
   >=(FPlaylisten[Aktiv.SpielendeListe].GListe1.liste.l0.Count-1)
   -FPlaylisten[Aktiv.SpielendeListe].GListe1.GetZeilen-5
   then FPlaylisten[Aktiv.SpielendeListe].GListe1.ersterEintrag:=
          (FPlaylisten[Aktiv.SpielendeListe].GListe1.liste.l0.Count-1)+1
          -FPlaylisten[Aktiv.SpielendeListe].GListe1.GetZeilen
   else  FPlaylisten[Aktiv.SpielendeListe].GListe1.ersterEintrag:=
          FPlaylisten[Aktiv.SpielendeListe].GListe1.fortschrittlichesElement-5
  else
   FPlaylisten[Aktiv.SpielendeListe].GListe1.ersterEintrag:=0;

  if FPlaylisten[Aktiv.SpielendeListe].GListe1.markiertesElement<>
          FPlaylisten[Aktiv.SpielendeListe].GListe1.fortschrittlichesElement
  then
  begin
   FPlaylisten[Aktiv.SpielendeListe].GListe1.markiertesElement:=
          FPlaylisten[Aktiv.SpielendeListe].GListe1.fortschrittlichesElement;
   ElementMarkieren(Aktiv.SpielendeListe,
                    strtoint(FPlaylisten[Aktiv.SpielendeListe].GListe1.Liste.Nummer
                    [FPlaylisten[Aktiv.SpielendeListe].GListe1.fortschrittlichesElement]));
   end;
 FPlaylisten[Aktiv.SpielendeListe].GListe1.Draw;
 end;
end;

procedure TFmp3.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 CanClose:=CreateDone;
end;


function TFmp3.Spiele( ListenNummer, ElementNummer : integer; ClearHistoryStatus:boolean=false;
                                     DoNotHistory:boolean=false):boolean;
 var Medium,ShownMediumName,Spieldauer: string;
     GListenIndex : integer;
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
              Datenbank.IncPlayCounter(ListenNummer, ElementNummer);

              Spieldauer:= DauerZuString(Spieler.GetLength);
              Datenbank.SetMediumPlayLength(ListenNummer,ElementNummer,
                Spieldauer);

              if Spieler.ZustaendigerRenderKern(ExtractfileExt(Medium))<>2
              then
               begin

                  ShownMediumName:=Datenbank.GetEintragFuerSpalte(0,ListenNummer,
                    Datenbank.ElementNummerZuArrayIndex(ListenNummer,ElementNummer));

                  Aktiv.SpielendesElement:=ElementNummer;
                  Aktiv.SpielendeListe:=ListenNummer;
                  Aktiv.Spielt:=true;
                  Aktiv.SpielenderTitel := ShownMediumName;


                  Application.Title:=ShownMediumName+TASKBARSEP;
                  TrayIcon.Hint:=ShownMediumName;

                  //OSD-Ausgabe
                  Aktiv.ScreenText_Album:= Datenbank.GetValue(ListenNummer,ElementNummer,7);
                  Aktiv.ScreenText_Jahr := Datenbank.GetValue(ListenNummer,ElementNummer,8);
                  Aktiv.ScreenText_Dauer := Spieldauer;
                  ScreenText(ShownMediumName,true);
                  //



                  Fmp3.Caption := Aktiv.SpielenderTitel + ' — ' + FORMTITLE+Version+FormCaption;

                  MinimizeETitelPath(Medium);
                  ETitel.Hint:=Medium;

                  //SetFortschrittliches Element
                  GListenIndex:=Datenbank.GetGListenIndex(ListenNummer,ElementNummer);
                  if GListenIndex <> -1 then
                  begin
                    FPlaylisten[ListenNummer].Gliste1.fortschrittlichesElement
                    := GListenIndex;
                    FPlaylisten[ListenNummer].Gliste1.fortschritt:=0;
                  end;

                  //Timer
                  Ttaskbarscroller.Enabled:=true;
                  if not SpielerTimer.Enabled then
                  SpielerTimer.Enabled:=true;


                  //History
                  if ClearHistoryStatus then
                    Datenbank.ClearHistoryStatus(ListenNummer);

                  if not DoNotHistory then
                  Datenbank.SetHistory(ListenNummer,ElementNummer);


                  //Such-History
                  if (Esuche.Text<>'') and not (FPlaylisten[ListenNummer].Gliste1.Liste.l0.Count=1)
                                     { and (Esuche.Strings.IndexOf(Esuche.Text)=-1)}
                  then
                  begin
                    if Esuche.Strings.Count > 0 then
                    begin
                      if Esuche.Strings.IndexOf(Esuche.Text)<>-1
                      then Esuche.Strings.Delete(Esuche.Strings.IndexOf(Esuche.Text));

                       begin
                        ESuche.Strings.Insert(0,ESuche.Text);

                        while Esuche.Strings.Count >= 30 do
                          Esuche.Strings.Delete(Esuche.Strings.Count - 1);
                       end


                    end
                    else
                      Esuche.Strings.Add(Esuche.Text);
                  end;

                  //seit .97 unnötig [evtl id3Tag auslesen]
                  if Datenbank.GetMediumPlayLength(ListenNummer,ElementNummer)=''
                  then    //Dann müsste auch id3 undefiniert sein
                   begin
                    Datenbank.SetMediumPlayLength(ListenNummer,ElementNummer,
                                            DauerZuString(Spieler.GetDauer(Medium)));
                    Datenbank.LeseId3(ListenNummer,ElementNummer);
                 //   DatenbankListeAusgeben(ListenNummer);
                   end;
               end;
              DatenbankListeAusgeben(ListenNummer);
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
 FPlaylisten[High(FPlaylisten)]:=TFPlayListe.Create(fmp3);
 FPlaylisten[High(FPlaylisten)].ListenNummer:=High(FPlaylisten);
 FPlaylisten[High(FPlaylisten)].Gliste1.Tag :=High(FPlaylisten);
 Aktiv.Liste:=High(FPlaylisten);
 Datenbank.AddNeueListe;
 SetColor;
 DatenbankListeAusgeben(Aktiv.Liste);
end;


procedure TFmp3.ListeAnfuegenOrdner;
var dir:string;
begin
if Datenbank.ListeExists(Aktiv.Liste)
 then
 begin
  dir:=OpenD.InitialDir;
  if (SelectDirectory(SELDIR_ADD_DIR,'',dir))
  then
   begin
    if (DirectoryExists(dir)) then
    begin
      Zeitmessung2Start;

      InitFStatus;

      Datenbank.OrdnerAnListeAnhaengen(dir,Aktiv.Liste);

      fmp3.FPlaylisten[Aktiv.Liste].TBXStatusBar1.Panels[4].Caption:=
        'Hinzufügezeit: '+inttostr(round(fmp3.Zeitmessung2Stopp/1000))+' s';

      DatenbankListeAusgeben(Aktiv.Liste);

      HideFStatus;
    end
    else
      Fehler('Ein ungültiges Verzeichnis wurde angegeben.');
   end;
  end;
end;

procedure TFMp3.InitFStatus;
begin
  FStatus.TBXPB.Position := 0;
  FStatus.TBXPB.Hide;
  FStatus.LName.Caption:='';
  fmp3.enabled:=false;
  FStatus.Show;
end;


procedure Tfmp3.HideFStatus;
begin
  fmp3.Enabled:=true;
  FStatus.Hide;
end;

procedure tfmp3.UpdateTextFStatus(ShowText:string; ShowCaption:string='');
begin
  FStatus.LName.Caption:=ShowText;
  if ShowCaption = ''
  then
    FStatus.LTitel.Caption:='Es werden Medien der Playliste hinzugefügt...'
  else
    FStatus.LTitel.Caption:=ShowCaption;
  Application.ProcessMessages;
end;


procedure TFmp3.StartFStatus(FileCount: integer);
begin
  FStatus.TBXPB.Max := FileCount;
  FStatus.TBXPB.PosTextSuffix := ' / ' + inttostr(FileCount);
  FStatus.TBXPB.Show;
  FStatus.LTitel.Caption:='Es werden Medien der Playliste hinzugefügt...';
  Application.ProcessMessages;
end;


procedure tfmp3.UpdateFStatus(FileName:string; FileCounter: integer);
begin
  if filecounter <= FStatus.TBXPB.max
  then FStatus.TBXPB.Position:=FileCounter
  else FStatus.TBXPB.Position:=FStatus.TBXPB.max;

  FStatus.TBXPB.Caption:=inttostr(FileCounter);
  FStatus.LName.Caption  :=FileName;
  Application.ProcessMessages;
end;

procedure TFmp3.DatenbankListeAusgeben ( ListenNummer:integer;
                   SuchFeldAktualisieren:boolean=true;  //Wegen DragDrop Bug
                   HistoryUndFavoritenNeuBerechnen:boolean=true );  //u.U. zeitintensiv

var i, markiert, ersterEintrag, Files, ArrayIndex : Integer;
    FilesSize : Int64;
    SearchDirs: TStringList;
begin
  Zeitmessungstart;

  if Datenbank.ListeExists(ListenNummer)
  then
   begin

     markiert:=Fplaylisten[ ListenNummer ].Gliste1.GetSelectet_ID;

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
            false,  //Markierungsflag
            Datenbank.GetEintragfuerSpalte(Datenbank.Mp3DatenMeta[ ListenNummer ].
                                              AnzeigeSpalten[0],ListenNummer,i),
            Datenbank.GetEintragfuerSpalte(Datenbank.Mp3DatenMeta[ ListenNummer ].
                                              AnzeigeSpalten[1],ListenNummer,i),
            Datenbank.GetEintragfuerSpalte(Datenbank.Mp3DatenMeta[ ListenNummer ].
                                              AnzeigeSpalten[2],ListenNummer,i),
            Datenbank.GetEintragfuerSpalte(Datenbank.Mp3DatenMeta[ ListenNummer ].
                                              AnzeigeSpalten[3],ListenNummer,i),
            Datenbank.GetEintragfuerSpalte(Datenbank.Mp3DatenMeta[ ListenNummer ].
                                              AnzeigeSpalten[4],ListenNummer,i));

            inc(FilesSize, Datenbank.MP3Daten[ ListenNummer,i].size);
            inc(Files);


            if Datenbank.Mp3Daten[ListenNummer,i].Nummer=markiert
              then Fplaylisten[ ListenNummer ].Gliste1.markiertesElement:=
                             (Fplaylisten[ ListenNummer ].Gliste1.liste.l0.Count-1);
            if (Datenbank.MP3Daten[ListenNummer,i].Nummer=aktiv.SpielendesElement)
                  and (ListenNummer=Aktiv.SpielendeListe)
              then Fplaylisten[ ListenNummer ].Gliste1.fortschrittlichesElement:=
                             (Fplaylisten[ ListenNummer ].Gliste1.liste.l0.Count-1);
        end;
    end;

  //Neue Shufflerange berechnen und ausgeben
  CalculateAndShowShufflerange;

  for i := 0 to 4 do
  begin
    Fplaylisten[ ListenNummer ].Gliste1.col_minimizename[i] :=
      Datenbank.Mp3DatenMeta[ ListenNummer ].AnzeigeSpalten[i] = 12;
  end;

  Fplaylisten[ ListenNummer ].TBXCBI0.ItemIndex:=
           Datenbank.Mp3DatenMeta[ ListenNummer ].AnzeigeSpalten[0];
  Fplaylisten[ ListenNummer ].TBXCBI1.ItemIndex:=
           Datenbank.Mp3DatenMeta[ ListenNummer ].AnzeigeSpalten[1];
  Fplaylisten[ ListenNummer ].TBXCBI2.ItemIndex:=
           Datenbank.Mp3DatenMeta[ ListenNummer ].AnzeigeSpalten[2];
  Fplaylisten[ ListenNummer ].TBXCBI3.ItemIndex:=
           Datenbank.Mp3DatenMeta[ ListenNummer ].AnzeigeSpalten[3];
  Fplaylisten[ ListenNummer ].TBXCBI4.ItemIndex:=
           Datenbank.Mp3DatenMeta[ ListenNummer ].AnzeigeSpalten[4];

  Fplaylisten[ ListenNummer ].Gliste1.ersterEintrag:=ersterEintrag;
  Fplaylisten[ ListenNummer ].Gliste1.Draw;
  Fplaylisten[ ListenNummer ].Caption:=extractrealfilename(extractfilename(
                            Datenbank.Mp3DatenMeta[ListenNummer].FileName));

   if (SuchFeldAktualisieren) and (ListenNummer=aktiv.Liste)
   then
     begin
       fmp3.Esuche.Text := Datenbank.Mp3DatenMeta[ListenNummer].SuchText;
     end;

  Fplaylisten[ ListenNummer ].TBXStatusBar1.Panels.Items[0].Caption := Format(
    CPLSTITELS, [Files]);  //uk
  Fplaylisten[ ListenNummer ].TBXStatusBar1.Panels.Items[1].Caption := Format(
    CPLSMB, [round(FilesSize/(1024*1024))]);
  Fplaylisten[ ListenNummer ].TBXStatusBar1.Panels.Items[2].Caption :=
    'Spielzeit: '+DauerZuString(datenbank.GetPlayLengthOfAllFiles(ListenNummer),true);

  if HistoryUndFavoritenNeuBerechnen
  then
  begin
  //History   //Zeitintensiv
    GHistory.ListenReset;
    Datenbank.VerifyHistory(ListenNummer);
    for i := 0 to High(Datenbank.Mp3DatenMeta[ListenNummer].history) do
    begin
      if Datenbank.GetArrayIndex(ListenNummer,
                 Datenbank.Mp3DatenMeta[ListenNummer].history[i], ArrayIndex)
      then
        GHistory.Add(Datenbank.Mp3DatenMeta[ListenNummer].history[i],
          i=Datenbank.Mp3DatenMeta[ListenNummer].historyposition,
          Datenbank.GetEintragfuerSpalte(0,ListenNummer,
            Datenbank.ElementNummerZuArrayIndex(ListenNummer,
            Datenbank.Mp3DatenMeta[ListenNummer].history[i])),
          '','','','');
    end;
    GHistory.Draw;
  //

  //Favoriten
    GFavorit.ListenReset;
    Datenbank.GetFavoritItems(ListenNummer,100,GFavorit.liste.l1,
                                               GFavorit.liste.nummer,
                                               GFavorit.liste.l0 );
    for i:=0 to GFavorit.liste.l1.Count-1 do
      begin
        GFavorit.liste.l2.Add('');
        GFavorit.liste.l3.Add('');
        GFavorit.liste.l4.Add('');
        GFavorit.liste.markiert.Add('false');
      end;

    GFavorit.Draw;

    if ListenNummer=Aktiv.SpielendeListe then
    GFavorit.SetSelected(Aktiv.SpielendesElement);
  //
  end;

  //SearchDir Hint aktualisieren
  SearchDirs:=TStringList.Create;
  Datenbank.GetSearchDir(ListenNummer,SearchDirs);
  TBXI_RescanFolders.Hint:=SearchDirs.Text;

  SetCover(Aktiv.MarkiertesElementDir);

  FPLaylisten[ListenNummer].TBXStatusBar1.Panels[3].Caption:=
  (inttostr(zeitmessungstopp)+' ms Ausgabe');

  end;
end;


procedure Tfmp3.CalculateAndShowShufflerange;
begin
  if Datenbank.ListeExists(Aktiv.Liste) then
  begin
    Aktiv.Shuffelrange := round(fplaylisten[Aktiv.Liste].Gliste1.liste.l0.Count*
                          TBXPB_shuffle.Position/100);
    TBXLI_ShuffleRange.Caption := 'Shufflestärke: '+ char(177) + ' ' +
                                   inttostr(Aktiv.Shuffelrange) + ' Titel';
  end;
end;


procedure Tfmp3.ZeichneFortschritt(prozent: real; total:integer);
begin
  if Datenbank.ListeExists(Aktiv.SpielendeListe)
  then Fplaylisten[ Aktiv.SpielendeListe ].Gliste1.SetFortschritt(prozent);
  TBXPbar.Caption := DauerZuString(total);
  TBXPBar.Position:= round(prozent*TBXPBar.Max);
  Flaut.TBXPBfortschritt.Caption := DauerZuString(total) + ' | ' + Aktiv.SpielenderTitel;
  Flaut.TBXPBfortschritt.Position:= round(prozent*Flaut.TBXPBfortschritt.Max);
end;

function Tfmp3.DauerZuString(SpielDauer:int64;NurStundenUndMinuten:boolean=false):string;
begin
  if SpielDauer<0 then SpielDauer:=0;

  Result:=inttostr(SpielDauer div 60)+':'+(format('%.2d',[SpielDauer mod 60]));

  //Spieldauer wird in Minten übergeben
  if NurStundenUndMinuten then
   begin
     SpielDauer:=SpielDauer div 60;
     if Spieldauer<100
     then
       Result:=inttostr(SpielDauer)+ ' min'
     else
       if Spieldauer<240
       then Result:=inttostr(SpielDauer div 60)+':'+(format('%.2d',[SpielDauer mod 60])) + ' h'
       else
         if Spieldauer<3000
         then Result :=inttostr(round(SpielDauer / 60))+ ' Std'
         else
           Result :=inttostr(round(SpielDauer / 60 /24))+ ' Tage';
   end;

end;


procedure TFmp3.ListeSpeichernUnter(ListenNummer:integer);
begin
 if Datenbank.ListeExists(ListenNummer)
 then
     if fmp3.SaveD.Execute
     then
      begin
        Datenbank.Mp3DatenMeta[ListenNummer].FileName:=SaveD.FileName;
        Datenbank.SavePlaylist( SaveD.FileName,ListenNummer);

        Fplaylisten[ ListenNummer ].Caption:=extractfilename
        (extractrealfilename(Datenbank.Mp3DatenMeta[ListenNummer].FileName));

        PlaylistenListeAdd(SaveD.FileName);
      end;
end;


procedure TFmp3.ListeSchliessenundSpeichern(ListenNummer:integer);

begin
 if Datenbank.ListeExists(ListenNummer)
 then
 begin
  if fmp3.Aktiv.SpielendeListe=ListenNummer then fmp3.Stop;

  if Datenbank.Mp3DatenMeta[ListenNummer].FileName=''
  then
    begin
        if MessageDlg(SAVEPLS, mtConfirmation, [mbYes, mbNo], 0) = mrYes
        then fmp3.ListeSpeichernUnter(ListenNummer);
      Datenbank.ListeSchliessen(ListenNummer,false);//Wurde schon gespeichert oder auch nicht
      GHistory.ListenReset;
    end
  else
   Datenbank.ListeSchliessen(ListenNummer,true);
 end;
end;

procedure TFmp3.ListeSpeichern(ListenNummer:integer);
begin
 if Datenbank.ListeExists(ListenNummer)
 then
  if Datenbank.Mp3DatenMeta[ListenNummer].FileName=''
  then
      ListeSpeichernUnter(ListenNummer)
  else
      Datenbank.SavePlaylist(Datenbank.Mp3DatenMeta[ListenNummer].FileName,
                                ListenNummer);
end;


function TFmp3.ListeLaden(DateiName: string):boolean;
var i:integer;
begin
  Result:=false;
  if FileExists(DateiName)
  then
    begin
      for i:=0 to High(Datenbank.Mp3DatenMeta) do
        begin
          if (Datenbank.Mp3DatenMeta[i].FileName = DateiName)
              and (Datenbank.Mp3DatenMeta[i].offen)
          then
           begin
             FPlaylisten[i].BringToFront;
             Result:=true;
             break;
           end;
        end;

      if not Result then
      begin
        ErzeugeNeuePlayliste;
        Datenbank.LoadPlaylist( DateiName, Aktiv.Liste);

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


        DatenbankListeAusgeben( Aktiv.Liste );

        PlaylistenlisteAdd(DateiName);

        Result:=true;
      end;
    end;
end;

procedure TFmp3.PlaylistenListeAdd(Dateiname: string);
begin
  if GPlaylisten.Liste.l0.IndexOf(Dateiname)=-1
   then GPlaylisten.Add(0,false,DateiName,'','','','');
   GPlaylisten.Draw;
end;


procedure TFmp3.SpielerTimerTimer(Sender: TObject);
var temp1:real;
    temp2:integer;
begin
 { try
    if Spieler.Getlength>1
      then ZeichneFortschritt(Spieler.Getposition/Spieler.Getlength,
                                                  round(Spieler.GetPosition*1000));

    if (Spieler.FKBassPlayer.Bassplayer.getstatus=0)
    then Weiterschalten;

    except //showmessage('[Fehler: SpielerTimer]');     }
    temp1:=0;
    temp2:=0;

    if Spieler.Getlength>1
    then
      begin
         try
           temp1:=Spieler.Getposition/Spieler.Getlength
         except showmessage('[Fehler: SpielerTimer->temp1]')  end;

         try
           temp2:=round(Spieler.GetPosition);
         except showmessage('[Fehler: SpielerTimer->temp2]')  end;


         ZeichneFortschritt(temp1,temp2);
      end;

    if (Spieler.FKBassPlayer.Bassplayer.getstatus=0)
    then Weiterschalten;

 //   except //showmessage('[Fehler: SpielerTimer]');
 // end;
end;

procedure TFmp3.TBXIBeendenClick(Sender: TObject);
begin
  close;
end;

procedure TFmp3.Weiterschalten;
var zuspielendes  : integer;
    untereSchranke, obereSchranke: integer;
begin
  if not Datenbank.ListeExists(Aktiv.SpielendeListe) then
    begin
      if Datenbank.ListeExists(Aktiv.Liste) then
        begin
          Aktiv.SpielendeListe:=Aktiv.Liste;
          //Zur Fehlervermeidung beim Listenwechsel der spielenden Liste
          Aktiv.SpielendesElement:=-1;
        end;
    end;

  if Datenbank.ListeExists(Aktiv.SpielendeListe)
    then
    begin
     if (not Datenbank.GetNextElementNummer(Aktiv.SpielendeListe,zuspielendes))
     then
     if (FPlaylisten[aktiv.SpielendeListe].Gliste1.liste.l0.count = 0)
      then stop
      else
      begin

        if TBxIShuffle.Checked
        then
        begin
            untereSchranke:=FPlaylisten[Aktiv.SpielendeListe].GListe1.fortschrittlichesElement
                            - Aktiv.Shuffelrange div 2;
            if untereSchranke<0 then untereSchranke:=0;

            obereSchranke:=FPlaylisten[Aktiv.SpielendeListe].GListe1.fortschrittlichesElement
                            + Aktiv.Shuffelrange div 2;
            if obereSchranke>FPlaylisten[Aktiv.SpielendeListe].GListe1.liste.l0.Count-1
            then obereSchranke:=FPlaylisten[Aktiv.SpielendeListe].GListe1.liste.l0.Count-1;

            zuspielendes := untereSchranke + random(obereSchranke - untereSchranke);

        end
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
      end
      else //GetNextElementNummer
      begin
        Spiele( Aktiv.SpielendeListe, zuspielendes );
      end;
    end;
end;

procedure Tfmp3.Suche (ListenNummer:integer; Text: string);
begin
  //FPlaylisten[Aktiv.Liste].Gliste1.ersterEintrag := 0;

  ZeitmessungStart;

  Datenbank.Search(ListenNummer,Text);

  FPlaylisten[Aktiv.Liste].TBXStatusBar1.Panels[4].Caption
    :=inttostr(ZeitmessungStopp)+' ms Suchzeit';

  DatenbankListeAusgeben(ListenNummer,true,false);

  if (TBXCBSearchAutoPlay.Checked) and
     (FPlaylisten[ListenNummer].Gliste1.Liste.l0.Count=1) and
     (listenNummer=aktiv.SpielendeListe) //Nur wenn bereits aus dieser Liste gespielt wird
  then
    begin
    //  if
    //  then
       begin
       if strtoint(FPlaylisten[ListenNummer].Gliste1.Liste.nummer[0])<>aktiv.spielendesElement
         then Spiele(ListenNummer,strtoint(FPlaylisten[ListenNummer].Gliste1.Liste.Nummer[0]));
       end;
 //     else
 //    Spiele(ListenNummer,strtoint(FPlaylisten[ListenNummer].Gliste1.Liste.Nummer[0]));
    end;

  //Markiert erstes Element (falls nicht vorher schon eines markiert war)
  if (FPlaylisten[ListenNummer].Gliste1.Liste.l0.Count>0)
   and (FPlaylisten[ListenNummer].Gliste1.markiertesElement<>-1)
  then
    begin
      FPlaylisten[ListenNummer].Gliste1.markiertesElement:=0;
      FPlaylisten[ListenNummer].Gliste1.Draw;
    end;

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
  Aktiv.Spielt:=Spieler.GetPauseState;
  ScreenText(PAUSECAPTION);
end;

procedure TFmp3.Stop;
begin
  Spieler.Stop;
  Aktiv.Spielt:=false;
  SpielerTimer.Enabled:=false;

  ETitel.Text:='';
  ETitel.Hint:='';
  TrayIcon.Hint:='';
  TBXPbar.Position:=0;
  TBXPbar.Hint := '';
  TBXPbar.Caption := '';
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
    FullFileName    : string;

begin
//  if  (Aktiv.MarkierteListe <> ListenNummer) or
//      (Aktiv.MarkiertesElement <> ElementNummer)
//  then
  begin
  //if Datenbank.EintragExists(ListenNummer,ElementNummer)

  //Aus irgendeinem Grund gibt es Liste und Markierte Liste
  Aktiv.Liste          := ListenNummer;
  Aktiv.MarkierteListe := ListenNummer;
  Aktiv.MarkiertesElement := ElementNummer;

  id3tag := Datenbank.GetMediumId3Tag(ListenNummer, ElementNummer);
  Datenbank.GetMediumFullFileName(ListenNummer, ElementNummer, FullFileName);


    //Was sollen diese blöde ifs? Einfach direkt zuweisen...
  if id3tag.Titel<>''
    then LEtitle.Text := id3tag.Titel
    else LEtitle.Text :='';

  if id3tag.Artist<>''
    then LEartist.Text := id3tag.Artist
    else LEartist.Text := '';

  if id3tag.Album<>''
    then LEalbum.Text := id3tag.Album
    else LEalbum.Text := '';

  if id3tag.Year<>''
    then LEyear.Text := id3tag.Year
    else LEyear.Text := '';

 { if id3tag.Track<>''
    then }LETrack.Text := inttostr(id3tag.Track);
 {   else LETrack.Text := '';   }

  if id3tag.Comment<>''
    then LEcomment.Text := id3tag.Comment
    else LEcomment.Text := '';

  if id3tag.genre<>''
    then LEgenere.Text := id3tag.Genre
    else LEgenere.Text := '';

  //Reset der Haken
  cbtitle.Checked:=false;
  cbartist.Checked:=false;
  cbalbum.Checked:=false;
  cbtrack.Checked:=false;
  cbyear.Checked:=false;
  cbgenre.Checked:=false;
  cbcomment.Checked:=false;

  Mpath.Text := FullFileName;
  Mpath.Hint := FullFileName;

  SetCover(ExtractFilePath(FullFileName));
  Application.ProcessMessages;

  end;
end;

procedure TFmp3.SetCover(dir: string; id: integer = 1); //uk
var
  Covers: TStringList;
  i: integer;
  procedure GetFilesInDirectory(Directory: String; const Mask: String;
                                List: TStrings;
                                WithSubDirs, ClearList: Boolean);
    procedure ScanDir(const Directory: String);
    var
      SR: TSearchRec;
    begin
      if FindFirst(Directory + Mask, faAnyFile - faDirectory, SR) = 0 then try
        repeat
          List.Add(Directory + SR.Name)
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;

      if WithSubDirs then begin
        if FindFirst(Directory + '*.*', faAnyFile, SR) = 0 then try
          repeat
            if (SR.Attr = faDirectory) and
               (SR.Name <> '.') and (SR.Name <> '..') then
              ScanDir(Directory + SR.Name + '\');
          until FindNext(SR) <> 0;
        finally
          FindClose(SR);
        end;
      end;
    end;
  begin
    List.BeginUpdate;
    try
      if ClearList then
        List.Clear;
      if Directory = '' then Exit;
      if Directory[Length(Directory)] <> '\' then
        Directory := Directory + '\';
      ScanDir(Directory);
    finally
      List.EndUpdate;
    end;
  end;
begin
  Covers := TStringList.Create;

  GetFilesInDirectory(dir, '*.jpg', Covers, false, true);

  Aktiv.MarkiertesElementDir := dir;

  if Covers.Count > 0 then
  begin
    if Covers.Count < id then id := 1;
    if ICover.Hint = Covers[id - 1] then exit;

    ICover.Picture.LoadFromFile(Covers[id - 1]);
    ICover.Hint := Covers[id - 1];

    ICover.Visible := true;
    LMDFGradientCover.Visible := false;
    i := id;
    IncEx(i, Covers.Count);
    ICover.Tag := id;

    TBXDockablePanel9.Caption := Format('Cover (%d/%d)', [id, Covers.Count]);
  end
  else
  begin
    LMDFGradientCover.Visible := true;
    ICover.Visible := false;
    ICover.Hint := '';
    TBXDockablePanel9.Caption := 'Cover';
  end;
end;

procedure TFmp3.SetCover_Next;     //uk
begin
  SetCover(Aktiv.MarkiertesElementDir, ICover.Tag + 1);
end;

procedure TFmp3.TBXAnordnungReset;
begin
 if MessageDlg(RESETSETTINGS, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  if DeleteFile(Speicherpfad+VISSETTINGS)
  then begin noTBXsave:=true; end
  else Fehler (Format(DEL_FALSE,[Speicherpfad])+VISSETTINGS);
end;

procedure TFmp3.TBXIcopypathClick(Sender: TObject);
begin
  Clipboard.AsText:=Etitel.Hint;
end;


procedure TFmp3.TanimationTimer(Sender: TObject);
begin
try
if TBXCBtrayicon.Checked then
 begin
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
except showmessage('[Fehler: AnimationsTimer]');end;
end;


procedure TFmp3.TBXIAnmiation1Click(Sender: TObject);
begin
Tanimation.Enabled:=true;
end;


procedure TFmp3.TBXItem23Click(Sender: TObject);
begin
  if TBXPM_MetaInfo.PopupComponent is TLabeledEdit then
   ESuche.Text:=(TBXPM_MetaInfo.PopupComponent as TLabeledEdit).Text;
end;


procedure TFmp3.TtaskbarscrollerTimer(Sender: TObject);
begin
  try
    if SpielerTimer.Enabled
    then
    begin
      if TBXCBscrolltitle.Checked
      then
      begin
        Application.Title := ErstesZeichenHintenDran(Application.Title);
      end;
    end
    else
    begin
      Ttaskbarscroller.Enabled:=false;
    end;
  except
    Fehler('[TaskbarScrollerTimer]');
  end;
end;


function TFmp3.ErstesZeichenHintenDran(Text: string):string;
begin
 result:=copy(Text,2,length(Text))+Text[1];
end;


procedure TFmp3.SetColor;
  var i: integer;
      BinClockColor: TColor;
begin
  try
    tbxinfo.ViewType := TVT_NORMALTOOLBAR or TVT_EMBEDDED;
    tbxinfo.ItemOptions := IO_APPACTIVE or IO_TOOLBARSTYLE;
    tbxinfo.Enabled := false;
    tbxinfo.Pushed := false;
    tbxinfo.HoverKind := hkNone;
    tbxinfo.ImageShown := false;
    tbxinfo.Selected := true;

    for i := 0 to High(FPlaylisten) do
    begin
      if Datenbank.ListeExists(i)
      then
      begin
        FPlaylisten[i].Gliste1.clhintergrund := CurrentTheme.GetItemImageBackground(tbxinfo);
        FPlaylisten[i].Gliste1.clhintergrund2:= CurrentTheme.GetItemTextColor(tbxinfo);
        FPlaylisten[i].StringGrid.FixedColor := CurrentTheme.GetItemImageBackground(tbxinfo);

        FPlaylisten[i].Gliste1.SetMainColor(CurrentTheme.GetItemtextColor(tbxinfo));
        FPlaylisten[i].Gliste1.clmarkiert := clWhite;
        FPlaylisten[i].Gliste1.clmouseover := CurrentTheme.GetItemTextColor(tbxinfo);
        FPlaylisten[i].StringGrid.Color := CurrentTheme.GetItemTextColor(tbxinfo);
      end;
    end;

    GPlaylisten.clhintergrund := CurrentTheme.GetItemImageBackground(tbxinfo);
    GPlaylisten.clhintergrund2:= CurrentTheme.GetItemTextColor(tbxinfo);
    GPlaylisten.SetMainColor(CurrentTheme.GetItemtextColor(tbxinfo));
    GPlaylisten.clmarkiert := clWhite;
    GPlaylisten.clmouseover := CurrentTheme.GetItemTextColor(tbxinfo);

    GHistory.clhintergrund := CurrentTheme.GetItemImageBackground(tbxinfo);
    GHistory.clhintergrund2:= CurrentTheme.GetItemTextColor(tbxinfo);
    GHistory.SetMainColor(CurrentTheme.GetItemtextColor(tbxinfo));
    GHistory.clmarkiert := clWhite;
    GHistory.clmouseover := CurrentTheme.GetItemTextColor(tbxinfo);

    GStyle.clhintergrund := CurrentTheme.GetItemImageBackground(tbxinfo);
    GStyle.clhintergrund2:= CurrentTheme.GetItemTextColor(tbxinfo);
    GStyle.SetMainColor(CurrentTheme.GetItemtextColor(tbxinfo));
    GStyle.clmarkiert := clWhite;
    GStyle.clmouseover := CurrentTheme.GetItemTextColor(tbxinfo);

    GFavorit.clhintergrund := CurrentTheme.GetItemImageBackground(tbxinfo);
    GFavorit.clhintergrund2:= CurrentTheme.GetItemTextColor(tbxinfo);
    GFavorit.SetMainColor(CurrentTheme.GetItemtextColor(tbxinfo));
    GFavorit.clmarkiert := clWhite;
    GFavorit.clmouseover := CurrentTheme.GetItemTextColor(tbxinfo);

    Application.HintColor := CurrentTheme.GetItemColor(tbxinfo);

    EQDraw;


    //BinClock
    Aktiv.MainColor:=CurrentTheme.GetItemTextColor(tbxinfo);

    BinClockColor:=(CurrentTheme.GetItemTextColor(tbxinfo) + clblack) div 2;

    PS1.Color:=BinClockColor;
    PS2.Color:=BinClockColor;
    PS3.Color:=BinClockColor;
    PS4.Color:=BinClockColor;
    PS5.Color:=BinClockColor;
    PS6.Color:=BinClockColor;

    PM1.Color:=BinClockColor;
    PM2.Color:=BinClockColor;
    PM3.Color:=BinClockColor;
    PM4.Color:=BinClockColor;
    PM5.Color:=BinClockColor;
    PM6.Color:=BinClockColor;

    PH0.Color:=BinClockColor;
    PH1.Color:=BinClockColor;
    PH2.Color:=BinClockColor;
    PH3.Color:=BinClockColor;
    PH4.Color:=BinClockColor;
    PH5.Color:=BinClockColor;


    LMDFBinClock.FillObject.Gradient.Color :=  CurrentTheme.GetItemImageBackground(tbxinfo);
    LMDFBinClock.FillObject.Gradient.EndColor := CurrentTheme.GetItemTextColor(tbxinfo);



    LMDFGradientCover.FillObject.Gradient.Color :=  CurrentTheme.GetItemImageBackground(tbxinfo);
    LMDFGradientCover.FillObject.Gradient.EndColor := CurrentTheme.GetItemTextColor(tbxinfo);

 {   with BmpGradient_Clock do
    begin
      Width := TBXDockablePanel8.Width;
      Height := TBXDockablePanel8.Height - TBXButton3.Height;
      DrawGradient( Canvas, CurrentTheme.GetItemImageBackground(tbxinfo),
        CurrentTheme.GetItemTextColor(tbxinfo), Rect(0,0,Width, Height));
    end;
 }

  except
    Fehler(SETCOLORERROR);
  end;
end;


procedure TFmp3.DockablePanelMenuErstellen;   //uk
var
  TBXItem: TTBXItem;
  i: integer;

  done: boolean;
  Dummy, Dummy2, id: string;
  Items, Items2: TStringlist;
begin
  try
    TBXSubmenuItem1.Clear;
    Items := TStringlist.Create;
    Items2:= TStringList.Create;

    //Sortieren

    for i := 1 to Anzahl_TBXDockablePanel do
    begin  //Captionsliste
      Items.Add((FindComponent('TBXDockablePanel'+IntToStr(i)) as
                                                    TTBXDockablePanel).Caption);
           //Namensliste
      Items2.Add((FindComponent('TBXDockablePanel'+IntToStr(i)) as
                                                       TTBXDockablePanel).Name);
    end;


    repeat
      done := true;
      for i := 0 to Items.Count - 2 do
        if Items[i] > Items[i + 1] then
        begin
          Dummy := Items[i];
          Items[i] := Items[i + 1];
          Items[i + 1] := Dummy;

          Dummy2 := Items2[i];
          Items2[i] := Items2[i + 1];
          Items2[i + 1] := Dummy2;

          done := false;
        end;
    until done;





    //Erstellen
    for i := 1 to Items.Count - 1 do
    begin
      TBXItem:=TTBXItem.Create(fmp3);
      id := Copy(Items2[i],17,19);

      TBXItem.Name:='TBX_DP_Item'+id;


      TBXItem.Caption:=Items[i];
      TBXItem.Checked:=(FindComponent('TBXDockablePanel'+id) as TTBXDockablePanel).Visible;
      TBXItem.OnClick:=TBX_DP_ItemClick;
      TBXItem.Tag:=strtoint(id);
      TBXSubmenuItem1.Add(TBXItem);
      (FindComponent('TBXDockablePanel'+id) as TTBXDockablePanel).Tag:=strtoint(id);
    end;
  except
    Fehler(Format(MENUEERROR, [PANELCAPTION]));
  end;
end;

procedure TFmp3.TBX_DP_ItemClick(Sender: TObject);   //uk
begin
  (Sender as TTBXItem).Checked := not (Sender as TTBXItem).Checked;
  (FindComponent('TBXDockablePanel' + IntToStr((Sender as TTBXItem).Tag)) as
    TTBXDockablePanel).Visible := (Sender as TTBXItem).Checked;
end;


procedure TFmp3.TBXCBtaskbutttonChange(Sender: TObject);
begin
  if TBXCBtaskbuttton.Checked then
  begin
    Trayicon.ShowTaskbarIcon;
  end else
  begin
    Trayicon.HideTaskbarIcon;
    TBXCBtrayicon.Checked := true;
    TBXCBmintotray.Checked := true;
    TBXCBscrolltitle.Checked := false;
  end;
end;


procedure TFmp3.FormShow(Sender: TObject);
var i:integer;
    Parameter : TStringlist;
begin
  if not CreateDone
  then
    begin
    try

      Save.L_Einstellungen;
      Save.L_OffenePlaylisten;
      SetColor;

      TrayIcon.Hint:=EMATTITLE;
      Tanimation.Enabled:=true;

      DockablePanelMenuErstellen;

      Spieler.SpectrumResize;
    except
      Fehler(STARTUPERROR);
    end;

    if paramcount>=1 then
      begin

        Parameter:=TStringlist.Create;
        for i:=1 to paramcount do
        Parameter.Add(paramstr(i));

        ParameterOpen(Parameter);

        Parameter.Free;
      end;

      if not high(fmp3.Datenbank.Mp3Daten) = 0 then
      begin
        fmp3.ErzeugeNeuePlayliste;
   //     fmp3.ListeAnfuegenOrdner;
      end;

    CreateDone := true;

  end;
end;


procedure TFMp3.ParameterOpen(var Parameter:TStringlist);
var newlist : boolean;
    i    : integer;
begin

  for i:=0 to parameter.Count-1 do
  begin
    //Playlisten
    if ExtractFileExt(Parameter[i])=PlayListExt
    then ListeLaden(Parameter[i]);
  end;

  newlist:=MessageDlg('Sollen die Titel der aktuellen Playliste hinzugefügt werden?'+#13+#10+
    'Bei "Nein" wird eine neue Playliste erstellt.', mtConfirmation, [mbYes, mbNo], 0)=mryes;
    
  for i:=0 to parameter.Count-1 do
  begin

    //Ordner
    if DirectoryExists(Parameter[i])
    then
     begin
       if (not newlist) or (aktiv.Liste = -1) then
        begin
          ErzeugeNeuePlayListe;
          newlist:=true;
        end;

       Datenbank.OrdnerAnListeAnhaengen(Parameter[i],Aktiv.Liste);
     end;
    //MP3
    if Spieler.ZustaendigerRenderKern(ExtractFileExt(Parameter[i]))>=0
    then
     begin
       if not newlist then
        begin
          ErzeugeNeuePlayListe;
          newlist:=true;
        end;

       Datenbank.AddFile(Aktiv.Liste,Parameter[i]);

     end;
  end;

  if newlist
  then
    DatenbankListeAusgeben(Aktiv.Liste)
  else
    //Aus unbekanntem Grund werden beim DragDrop leere, ungültige Einträge erzeugt
    Datenbank.DeleteInvalidItems(aktiv.liste);
end;

procedure TFmp3.WriteText(TransText: string);

var
  MyHand: HWND;
  MyDc: HDC;
  MyCanvas: TCanvas;
  FONTDIVISOR, FontSize_Text, FontSize_Titellaenge : integer;
  Textposition, Rahmendicke : Tpoint;
  Album_Year  : string;
  Write_AlbumYear : boolean;
begin
try
  MyHand := GetDesktopWindow;
  MyDc := GetWindowDC(MyHand);
  MyCanvas := TCanvas.Create;
  MyCanvas.Handle := MyDC;
  BeginPath(MyCanvas.Handle);
  SetBkMode(MyCanvas.Handle,TRANSPARENT);
  EndPath(MyCanvas.Handle);

  FONTDIVISOR:=15;


  MyCanvas.Font.Color := clLime;
  MyCanvas.Font.Name := 'Arial'; //Fmp3.Font.Name;
  MyCanvas.Font.Size := Screen.Height div FONTDIVISOR;

  // Schriftgröße festlegen
  FontSize_Text := round(MyCanvas.Font.Size * ( (Screen.Width * 0.9) / MyCanvas.TextWidth(Transtext) ));

  if(FontSize_Text > Screen.Height div FONTDIVISOR)
   then FontSize_Text := Screen.Height div FONTDIVISOR;

  FontSize_Titellaenge:=Screen.Height div (FONTDIVISOR*2);
  //



  //Bestimmen ob Album_Year existiert
  if Aktiv.ScreenText_isTitle then
  begin
    Write_AlbumYear:=true;
    Album_Year:='';
    if Aktiv.ScreenText_isTitle
    then
      if Aktiv.ScreenText_Album=''
      then
        if Aktiv.ScreenText_Jahr=''
        then Write_AlbumYear:=false
        else Album_Year:=Aktiv.ScreenText_Jahr
      else
        if Aktiv.ScreenText_Jahr=''
        then Album_Year := Aktiv.ScreenText_Album
        else Album_Year := Aktiv.ScreenText_Album + ' ('+ Aktiv.ScreenText_Jahr + ')';
  end
  else Write_AlbumYear:=false;
  //

  MyCanvas.Font.Size:=FontSize_Text;

  Aktiv.ScreenText_TextWidth := MyCanvas.TextWidth(Transtext);
  Aktiv.ScreenText_TextHeight := MyCanvas.TextHeight(Transtext);


  //Überprüfen ob Album oder Text länger ist
  if  Write_AlbumYear then
  begin
    MyCanvas.Font.Size:=FontSize_Titellaenge;

    if Aktiv.ScreenText_TextWidth < MyCanvas.TextWidth(Album_Year)
    then  Aktiv.ScreenText_TextWidth := MyCanvas.TextWidth(Album_Year);

    MyCanvas.Font.Size:=FontSize_Text;
  end;


  Textposition.X:=Screen.Width div 2 - Aktiv.ScreenText_TextWidth div 2;
  Textposition.Y:=round(Screen.Height * 0.8)-Aktiv.ScreenText_TextHeight div 2;

  Rahmendicke.X:=15;
  Rahmendicke.Y:=10;

  //Schwarzer Ramen
  MyCanvas.Brush.Color:=clblack;
  if (Aktiv.ScreenText_isTitle) and (Write_AlbumYear)
  then
  MyCanvas.RoundRect(Textposition.X - Rahmendicke.X,
                     Textposition.Y - Rahmendicke.Y,
                     Textposition.X
                       +Aktiv.ScreenText_TextWidth+Rahmendicke.X,
                     Textposition.Y
                       +Aktiv.ScreenText_TextHeight+Rahmendicke.Y+50,
                     40,40 )

  else
  MyCanvas.RoundRect(Textposition.X - Rahmendicke.X,
                     Textposition.Y - Rahmendicke.Y,
                     Textposition.X
                       +Aktiv.ScreenText_TextWidth+Rahmendicke.X,
                     Textposition.Y
                       +Aktiv.ScreenText_TextHeight+Rahmendicke.Y,
                     40,40 );
  //

  //Schwarzer Rahmen für die Zeit
  if Aktiv.ScreenText_isTitle then
    begin
      MyCanvas.RoundRect(Textposition.X
                       +Aktiv.ScreenText_TextWidth+Rahmendicke.X - 20,
                     Textposition.Y - 50,
                     Textposition.X
                       +Aktiv.ScreenText_TextWidth+Rahmendicke.X - 168,
                     Textposition.Y + 20,
                     40,40 );
    end;

  //Titel schreiben
  MyCanvas.Font.Color := clLime;

  MyCanvas.TextOut(Textposition.X,
                   Textposition.Y,
                   TransText);


  if Aktiv.ScreenText_isTitle then
    begin
      MyCanvas.Font.Size := Screen.Height div (FONTDIVISOR*2);

      MyCanvas.TextOut(Textposition.X - Rahmendicke.X
                       +Aktiv.ScreenText_TextWidth-Rahmendicke.X - 20 -  MyCanvas.TextWidth(aktiv.ScreenText_Dauer),
                   Textposition.Y - MyCanvas.TextHeight(aktiv.ScreenText_Dauer),
                   aktiv.ScreenText_Dauer);

      if Write_AlbumYear
      then
      MyCanvas.TextOut(Textposition.X,
                       Textposition.Y+Aktiv.ScreenText_TextHeight+8,
                       Album_Year);
    end;


  ReleaseDC(handle, MyDC);
except
  ScreenText_refresher.Enabled:=false;
  Fehler('Es ist ein Fehler beim Zeichnen des OSD aufgetreten'+#13+'Bei anhaltenden Problemen bitte das OSD deaktivieren');
end;
end;


procedure TFmp3.ScreenText(Text: string; isTitle:boolean=false);   //uk
begin
  if TBXCBhud.Checked then
  begin
    if ScreenText_refresher.Enabled then
    begin
      ScreenText_refresher.Enabled := false;
      ClearScreenText;
    end;

    Aktiv.ScreenText_Text := Text;
    Aktiv.ScreenText_isTitle := isTitle;
    ScreenText_refresher.Tag := GetTickCount;
    ScreenText_refresher.Enabled := true;
  end;
end;

procedure TFmp3.ClearScreenText;
var
  PMyRect: PRect;
  MyRect: TRect;
begin
  MyRect.Left:=200;
  myRect.Top:=200;
  myrect.Bottom:=750;
  myrect.Right:=500;
  pmyrect:=@myrect;

  //redrawwindow(0,pmyrect,0,0);
  {
  MyRect.TopLeft.X := 5;
  MyRect.TopLeft.Y := 6;
  MyRect.BottomRight.X := 300;
  MyRect.BottomRight.Y := 300;
  MyRect.Left := Screen.Width div 2 - Aktiv.ScreenText_TextWidth div 2;
  MyRect.Top  :=   Screen.Height - Aktiv.ScreenText_TextHeight * 4;
  MyRect.Right := Screen.Width div 2 + Aktiv.ScreenText_TextWidth div 2;
  MyRect.Bottom := Screen.Height - Aktiv.ScreenText_TextHeight * 4;  }
 // InvalidateRect(0, pMyRect, false);

  try
    if InvalidateRect(0, PMyRect, false)=false then Fehler('InvalidateRect returns ErrorCode');
  except
    Fehler('Es ist ein Fehler beim Zeichnen des OSD aufgetreten'+#13+'Bei anhaltenden Problemen bitte das OSD deaktivieren');
  end;
end;

procedure TFmp3.WMDROPFILES (var Msg: TMessage);
var i, anzahl, size: integer;
  Dateiname: PChar;
  Parameter  : TStringlist;
begin
  inherited;
  Dateiname := '';
  anzahl := DragQueryFile(Msg.WParam, $FFFFFFFF, Dateiname, 255);

  Parameter:=TStringlist.Create;
  for i := 0 to (anzahl - 1) do
  begin
    size := DragQueryFile(Msg.WParam, i , nil, 0) + 1;
    Dateiname:= StrAlloc(size);
    DragQueryFile(Msg.WParam,i , Dateiname, size);
    Parameter.Add(Dateiname);
    StrDispose(Dateiname);
  end;
  DragFinish(Msg.WParam);

  ParameterOpen(Parameter);
  Parameter.Free;
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

{procedure TFmp3.ToolbarMenuErstellen;   //uk
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
}

procedure TFmp3.ElementLoeschen(ListenNummer,ElementNummer:integer);
var FullFileName : string;
    flag         : boolean;
    ArrayIndex : integer;
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
  OpenFolderAndMarkFile(Etitel.Hint);
end;

procedure TFmp3.OpenFolderAndMarkFile(FileName: string);
begin
  if FileExists(FileName)
    then ShellExecute(GetDesktopWindow, 'open', 'Explorer', PChar(
      '/select, "' + FileName +'"'), nil, SW_SHOWNORMAL);
end;

procedure TFmp3.FormCreate(Sender: TObject);
var
  Styles: TStringList;
  i: integer;
begin
try
  CreateDone := false;

  Randomize;

  fmp3.caption:=FORMTITLE+Version+FormCaption;
  Application.Hint := FORMTITLE+Version;
  Application.Title:=EMATTITLE;

  Aktiv.Liste            :=-1;
  Aktiv.SpielendeListe   :=-1;
  Aktiv.SpielendesElement:=-1;
  Aktiv.MarkierteListe   :=-1;
  Aktiv.MarkiertesElement:=-1;

  TBXPBVolume.Max            := maxVolume;

  BmpGradient_Clock := TBitMap.Create;

  GStyle               := TGListe2.Create(TBXAPStyle);
  GStyle.Parent        := TBXAPStyle;
  GStyle.SingleColMode := true;
  GStyle.Align         := alClient;
  GStyle.rand[0]       := 5;
  GStyle.aktiv         := true;
  GStyle.Resize;
  GStyle.col_minimizename[0] := true;
  GStyle.OnElementMarkieren  := GStyleDoppelClick;

  Speicherpfad:=extractfilepath( application.ExeName )+'custom\';
  ForceDirectories(Speicherpfad);

  EnableMenues(false);

  TBIniLoadPositions(Self,Speicherpfad+VISSETTINGS, '');

  Save:=TSave.Create( Speicherpfad+GENERALSETTINGS);

  Spieler:=TSpieler.Create (Save.LoadVisSetting);
  Spieler.OnWeiterschalten:=Weiterschalten;

  SetLength(FPlaylisten,0);
  Datenbank:=TDatenbank.Create;

//  Fmp3.DoubleBuffered:=true;

  OpenD.Filter:='Emat-Playliste / Applauncher (*'+PlaylistExt+')|*'+PlaylistExt;
  SaveD.Filter:=OpenD.Filter;
  SaveD.DefaultExt:=PlaylistExt;

        //TBX-Themes einbinden
  Styles := TStringList.Create;
  GetAvailableTBXThemes(Styles);
  for i := 0 to Styles.Count - 1 do
  begin
    GStyle.Add(i, false, Styles.Strings[i],'','','','');
  end;

  DragAcceptFiles(Fmp3.Handle, true);

  GPlaylisten := TGListe2.Create(TBXAPplaylistList);
  GPlaylisten.Parent := TBXAPplaylistList;
  GPlaylisten.SingleColMode := true;
  GPlaylisten.Align := alClient;
  GPlaylisten.rand[0] := 5;
  GPlaylisten.aktiv := true;
  GPlaylisten.Resize;
  GPlaylisten.OnDoppelklick := GPlaylistenDblClick;
  GPlaylisten.PopupMenu := TBXPM_GPlaylisten;
  GPlaylisten.col_minimizename[0] := true;

  GHistory         := TGListe2.Create(TBXAPHistory);
  GHistory.Parent  := TBXAPHistory;
  GHistory.SingleColMode := true;
  GHistory.Align   := alClient;
  GHistory.rand[0] := 5;
  GHistory.aktiv   := true;
  GHistory.Resize;
  GHistory.OnDoppelklick       := GHistoryDoppelClick;
  GHistory.Hint :='Mit Alt + Linksklick auf die Playliste Medien einreihen';
  GHistory.PopupMenu           := TBXPMHistory;
  GHistory.Tag2 := 2;
  GHistory.OnDragItemInsert := History_DragItemInsert;
  GHistory.OnDragOver       := HistoryDragOver;
  GHistory.OnItemMove       := History_DragItemMove;
  GHistory.OnKeyDown        := GHistory_KeyDown;

  GFavorit         := TGListe2.Create(TBXAPfavorit);
  GFavorit.Parent  := TBXAPfavorit;
//  GFavorit.SingleColMode := true;
  GFavorit.Align   := alClient;                         
  GFavorit.rand[0] := 5;
  GFavorit.rand[1] := 42;
  GFavorit.rand[2] := 1000;
  GFavorit.aktiv   := true;
  GFavorit.Resize;
  GFavorit.OnDoppelklick       := GFavoritDoppelClick;
  GFavorit.Hint:='Die meistgespielten Titel';
  GFavorit.PopupMenu           := TBXPM_Favorit;
  GFavorit.LineMoving := true;
  GFavorit.Tag2       := 3;


  Application.OnActivate:= fmp3.AppAktivate;
  Application.OnDeactivate:=fmp3.AppDeaktivate;
  Application.OnMinimize:=fmp3.AppDeaktivate;

//  LMDDDMp3Player.CaptionTitle:=SELDIR;

   {
  hookhandle:=0;
  InstallHook(application.Handle);
   }
except
  Fehler(STARTUPERROR);
end;
end;


procedure TFmp3.WMBassPlayerStop(var Message: TMessage);
 begin
    Weiterschalten;
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

procedure TFmp3.AddFiles(ListenNummer:integer; Files: TStringlist);
var
  i:integer;
begin
  if files.Count>0
  then
  begin
    for i:=0 to files.Count-1 do
      Datenbank.AddFile(ListenNummer,files[i]);
  //  Files.Free;
    EsucheChange(Fmp3, Esuche.Text);
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
  if Spieler.GetPauseState
  then Pause
  else Spiele(Aktiv.SpielendeListe,Aktiv.SpielendesElement);
end;

procedure TFmp3.OeffnePlayliste;
begin
  if OpenD.Execute
    then ListeLaden(OpenD.FileName);
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
        //Ashuffle.Caption := SHUFFLE_ON;

        ScreenText(SHUFFLE_ON);
      end
    else
      begin
        Ashuffle.Checked := true;
        //Ashuffle.Caption := SHUFFLE_OFF;

        ScreenText(SHUFFLE_OFF);
      end;
end;

procedure TFmp3.ADelFromHDDExecute(Sender: TObject);
begin
  if GPlaylisten.markiertesElement<>-1 then
  if DeleteFileToRecycleBin(GPlaylisten.Liste.l0[GPlaylisten.markiertesElement])
  then
    GPlaylisten.Liste.l0.Delete( GPlaylisten.markiertesElement )
  else
    Fehler(Format(DEL_FALSE, [ GPlaylisten.Liste.l0[ GPlaylisten.markiertesElement ] ]));
end;

procedure TFmp3.ADelFromListExecute(Sender: TObject);
begin
  if GPlaylisten.markiertesElement>=0 then
  GPlaylisten.Liste.l0.Delete( GPlaylisten.markiertesElement );
end;

procedure TFmp3.AmarkinlistExecute(Sender: TObject);
begin
  MarkInList; 
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

procedure TFmp3.SetListsInAktive(exceptList:integer);
var i : integer;
begin
  for i:=0 to High(Fplaylisten) do
  begin
    if Datenbank.ListeExists(i)
    then
     begin
       FPlaylisten[i].Gliste1.aktiv:=(i=exceptList);
      // if (i<>exceptList) then FPlaylisten[i].Gliste1.fortschrittlichesElement:=-1;
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
  TBXCPback.Color := Color;
  TBXPMbackcolor.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
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
  OpenFolderAndMarkFile(mpath.Text);
end;

procedure TFmp3.TBXIbackClick(Sender: TObject);
begin
  Zurueckschalten;
end;

procedure TFmp3.TBXItem13Click(Sender: TObject);
begin
  //markiertes Element löschen
  DeleteSelectedItems;
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


procedure TFmp3.TClockTimer(Sender: TObject);
begin(*
   function GetColor(w : word):tcolor;
   begin
     if w<>0 then result:=Spieler.Spectrum.BackColor else result:=clbtnface;
   end;


var Time : TSystemTime;
    Sec, Min, H : String;
    Zeit: string;
    BmpText, BmpBinClock: TBitMap;
    SpaceV, SpaceH, Height_Block, Width_Block, i, BinZeit: integer;

begin
  case TBXButton3.Tag of
    1:
    begin
      Zeit := FormatDateTime('hh:nn', now);
    end;
    2:
    begin
      Zeit := FormatDateTime('hh:nn:ss', now);
    end;
  end;

  if TBXButton3.Tag > 1 then
  begin
    with BmpText do
    begin
      BmpText := TBitMap.Create;
      Width := Canvas.TextWidth(Zeit);
      Height := Canvas.TextHeight(Zeit);

      Canvas.Pen.Color := clWhite;
      Canvas.Brush.Color := clWhite;
      Canvas.Rectangle(0, 0, Width,Height);
      Canvas.Pen.Color := clBlack;

      Canvas.TextOut(0, 0, Zeit);
      Transparent := true;
      TransparentColor := clWhite;
    end;

    with TBXDockablePanel8 do
    begin
      Canvas.Draw(0,0,BmpGradient_Clock);
      Canvas.Draw(BmpGradient_Clock.Width div 2 - BmpText.Width div 2,
                  BmpGradient_Clock.Height div 2 - BmpText.Height div 2,BmpText)
    end;
    BmpText.Free;
  end else
  begin
    with BmpBinClock do
    begin
      BmpBinClock := TBitMap.Create;
      Width := BmpGradient_Clock.Width;
      Height := BmpGradient_Clock.Height;
      Canvas.Pen.Color := clWhite;
      Canvas.Brush.Color := clWhite;
      Canvas.Rectangle(0, 0, Width,Height);
      Transparent := true;
      TransparentColor := clWhite;


      Zeit := DezToX(StrToInt(FormatDateTime('hhnnss', now)), 2);

    end;

    with TBXDockablePanel8 do
    begin
      Canvas.Draw(0,0,BmpGradient_Clock);
      Canvas.Draw(0,0,BmpBinClock);
    end;
    BmpText.Free;
  end;

 (*

    Sec:=Time.wSecond;
    PS1.Color:=(GetColor( Sec div 32 ));
    PS2.Color:=(GetColor( Sec mod 32 div 16 ));
    PS3.Color:=(GetColor( Sec mod 32 mod 16 div 8));
    PS4.Color:=(GetColor( Sec mod 32 mod 16 mod 8 div 4));
    PS5.Color:=(GetColor( Sec mod 32 mod 16 mod 8 mod 4 div 2));
    PS6.Color:=(GetColor( Sec mod 32 mod 16 mod 8 mod 4 mod 2));

    Min:=Time.wMinute;
    PM1.Color:=(GetColor( Min div 32 ));
    PM2.Color:=(GetColor( Min mod 32 div 16 ));
    PM3.Color:=(GetColor( Min mod 32 mod 16 div 8));
    PM4.Color:=(GetColor( Min mod 32 mod 16 mod 8 div 4));
    PM5.Color:=(GetColor( Min mod 32 mod 16 mod 8 mod 4 div 2));
    PM6.Color:=(GetColor( Min mod 32 mod 16 mod 8 mod 4 mod 2));

    H:=Time.wHour;
    PH1.Color:=(GetColor( H div 16 ));
    PH2.Color:=(GetColor( H mod 16 div 8));
    PH3.Color:=(GetColor( H mod 16 mod 8 div 4));
    PH4.Color:=(GetColor( H mod 16 mod 8 mod 4 div 2));
    PH5.Color:=(GetColor( H mod 16 mod 8 mod 4 mod 2));    *)
end;

procedure TFmp3.SetVolume(prozent: real);
begin
  if prozent > 0.99 then prozent := 1;
  if prozent < 0.01 then prozent := 0;

  TBXPBVolume.Position := round(maxVolume * prozent);
  TBXPBVolume.PosTextPrefix := VOLUMECAPTION + inttostr(round(TBXPBVolume.Position / maxVolume * 100)) + '%)';

  Flaut.TBXPBVolume_Tray.Position := TBXPBVolume.Position;
  Flaut.TBXPBVolume_Tray.PosTextPrefix := TBXPBVolume.PosTextPrefix;

  ScreenText('Lautstärke: '+inttostr(TBXPBVolume.Position)+'%');

  Spieler.SetVolume(TBXPBVolume.Position);
end;

function TFmp3.GetVolume: real; //uk | Lautstärke in Prozent
begin
  Result := TBXPBVolume.Position / maxVolume;
end;

procedure TFmp3.TBXPBVolumeMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  volumeMouseDown := true;
  SetVolume(X / TBXPBVolume.Width);
end;

procedure TFmp3.TBXPBVolumeMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if volumeMouseDown then SetVolume(X / TBXPBVolume.Width);
end;

procedure TFmp3.TBXPBVolumeMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  volumeMouseDown := false;
end;

procedure TFmp3.TBXIsavelistClick(Sender: TObject);
begin  
  ListeSpeichern(Aktiv.Liste);
end;

procedure TFmp3.TBXIspeichernunterClick(Sender: TObject);
begin
   ListeSpeichernUnter(Aktiv.Liste);
end;

procedure TFmp3.TBXItem17Click(Sender: TObject);
begin
  ListeAnfuegenOrdner
end;

procedure TFmp3.TBXItem18Click(Sender: TObject);
begin
 if Datenbank.ListeExists(Aktiv.Liste)
 then
  FPlaylisten[Aktiv.Liste].Addfile;
end;

procedure TFmp3.TBXSubmenuItem1Click(Sender: TObject);
begin
  DockablePanelMenuErstellen;
end;

procedure TFmp3.TBXItem14Click(Sender: TObject);
begin
  (FindComponent('TBX_DP_Item7') as TTBXItem).Click;
end;

procedure TFmp3.TBXI_RescanFoldersClick(Sender: TObject);
begin
 if Datenbank.ListeExists(Aktiv.Liste)
 then
   begin
     InitFstatus;
     Datenbank.RescanFolders(Aktiv.Liste);
     EsucheChange(fmp3, fmp3.Esuche.Text);
     HideFStatus;
   end;
end;

procedure TFmp3.TBXCPbackChange(Sender: TObject);
begin
  Color := TBXCPback.Color;
  Visible := false;    //sonst gibt es kein refresh...uk
  Visible := true;
end;

procedure TFmp3.TBXItem16Click(Sender: TObject);
var Quellliste:integer;
begin           
  if (Datenbank.ListeExists(Aktiv.Liste)) and
     (MessageDlg('Das Suchen nach doppelten Musikdateien kann unter Umständen sehr lange dauern und Emat könnte den Anschein erwecken, abgestürzt zu sein. Bitte auf Festplattenaktivität achten.'+#13+#10+''+#13+#10+'Vorgang fortsetzen?', mtConfirmation, [mbYes, mbNo], 0)=mrYes)
  then
  begin
    Quellliste:= Aktiv.Liste;
    ErzeugeNeuePlayliste;
    Datenbank.KopiereDoppelteMedienInAndereListe(Quellliste,High(FPlaylisten));
    DatenbankListeAusgeben(High(FPlaylisten));
  end;
end;  

procedure TFmp3.TBXItem19Click(Sender: TObject);
begin
  if Datenbank.ListeExists(Aktiv.Liste) then
  FPlaylisten[Aktiv.Liste].ListenEintraegeAuslesen;
end;

procedure TFmp3.TBXItem20Click(Sender: TObject);
begin
 if Datenbank.ListeExists(Aktiv.Liste) then
 FPlaylisten[Aktiv.Liste].AngezeigteMedienKopieren;
end;

procedure TFmp3.TBXItem22Click(Sender: TObject);
begin
  if Datenbank.ListeExists(Aktiv.Liste) then
  begin
    Datenbank.Sort(Aktiv.Liste, 20); //Spezialsortierung
    DatenbankListeAusgeben(Aktiv.Liste);
  end;  
end;

procedure TFmp3.TBXIhelpClick(Sender: TObject);
begin
  Fstart.Show;
end;

procedure TFmp3.GH_hudKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
//  var ArrayIndex: integer;
begin
{ if Datenbank.EintragExists(Aktiv.SpielendeListe,Aktiv.SpielendesElement,ArrayIndex)
 then
 ScreenText(Datenbank.GetEintragfuerSpalte(0,Aktiv.SpielendeListe,ArrayIndex));   }
 ScreenText(Aktiv.SpielenderTitel,true);
end;

procedure TFmp3.EnableMenues(Enable: boolean = true);
begin
  TBXIsavelist.Enabled := Enable;
  TBXIcloselist.Enabled := Enable;
  TBXIspeichernunter.Enabled := Enable;
  TBXSIspezial.Enabled := Enable;
  TBXI_RescanFolders.Enabled := Enable;
  TBXItem17.Enabled := Enable;
  TBXItem18.Enabled := Enable;
  TBXIstop.Enabled := Enable;
  TBXInext.Enabled := Enable;
  TBXIpause.Enabled := Enable;
  TBXIplay.Enabled := Enable;
  TBXIback.Enabled := Enable;
  TBXIshuffle.Enabled := Enable;
  TBXItem4.Enabled := Enable;
  Esuche.Enabled := Enable;
  TBXItem7.Enabled := Enable;
  TBXItem9.Enabled := Enable;
  TBXI_HDDLoeschmodus.Enabled := Enable;
  TBXItem13.Enabled := Enable;
  TBX_del_play_item.Enabled := Enable;
  TBXIselect_cols.Enabled := Enable;
end;


procedure TFmp3.TBXSubmenuItem7Click(Sender: TObject);
begin
  TBXItem14.Checked := (FindComponent('TBX_DP_Item7') as TTBXItem).Checked;

  if Datenbank.ListeExists(Aktiv.Liste)
  then
    begin
      TBXItem18.ImageIndex := 26;
      TBXItem17.ImageIndex := 7;
    end;
end;

procedure TFmp3.SaveDFolderChange(Sender: TObject);
begin
   OpenD.InitialDir:=SaveD.InitialDir;
end;

procedure TFmp3.OpenDFolderChange(Sender: TObject);
begin
  SaveD.InitialDir := OpenD.InitialDir;
end;

procedure TFmp3.TBXIcloselistClick(Sender: TObject);
begin
  FPlaylisten[Aktiv.Liste].Close;
end;

//Folgender Code wird auch beim MultiSelected Löschen verwendet
procedure TFmp3.TBXButton1Click(Sender: TObject);
var Items : TStringList;
    i     : integer;

begin
  if Datenbank.ListeExists(aktiv.Liste) then
  begin
  Items:= TStringList.Create;
  if not FPlaylisten[Aktiv.MarkierteListe].Gliste1.GetMultiSelectetItems_ID(Items)
       //Wenn nichts per Multiselect markiert ist
  then Items.Add(inttostr(Aktiv.MarkiertesElement));


  for i:=0 to Items.Count-1 do
  begin
    if (Aktiv.SpielendeListe = Aktiv.MarkierteListe)
      and (strtoint(Items[i]) = Aktiv.SpielendesElement)
    then Stop;


    Datenbank.SaveId3(LEtitle.Text,LEartist.Text,LEalbum.Text,LEyear.Text,
                        LEcomment.Text,LEgenere.Text,LETrack.Text,
                        CBtitle.Checked,CBartist.Checked,CBalbum.Checked,
                        CByear.Checked,CBcomment.Checked,CBgenre.Checked,
                        CBtrack.Checked,
                        Aktiv.MarkierteListe,strtoint(Items[i]));


    if (Aktiv.SpielendeListe = Aktiv.MarkierteListe)
      and (strtoint(Items[i]) = Aktiv.SpielendesElement)
    then Spiele(Aktiv.SpielendeListe,strtoint(Items[i]));
  end;

  DatenbankListeAusgeben(Aktiv.MarkierteListe);

  //Reset der Haken
  cbtitle.Checked:=false;
  cbartist.Checked:=false;
  cbalbum.Checked:=false;
  cbtrack.Checked:=false;
  cbyear.Checked:=false;
  cbgenre.Checked:=false;
  cbcomment.Checked:=false;
  end;
end;


procedure TFmp3.TBXVisPauseClick(Sender: TObject);
begin
  if TBXVisPause.Tag=0
  then
    begin
      Spieler.SetBassVisPause;
      TBXVisPause.Tag:=1;
    end
  else
    begin
      Spieler.SetBassVisResume;
      TBXVisPause.Tag:=0;
    end;
end;


procedure TFmp3.TBXButton4Click(Sender: TObject);
begin
  ResetEQ;
end;

procedure TFmp3.EtitelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Etitel.Hint <> ''
   then
    if Button = mbleft
     then MarkInList
     else TBXPM_Ltitel.Popup(Mouse.CursorPos.X,Mouse.CursorPos.Y);
  HideCaret(ETitel.Handle);
end;


procedure TFmp3.ErzeugeNeueApplauncherListe;
begin
  ErzeugeNeuePlayliste;

  Datenbank.SetPlaylistMode(High(FPlaylisten),2);

  Datenbank.Mp3DatenMeta[High(FPlaylisten)].AnzeigeSpalten[0]:=14;
  Datenbank.Mp3DatenMeta[High(FPlaylisten)].AnzeigeSpalten[1]:=0;
  Datenbank.Mp3DatenMeta[High(FPlaylisten)].AnzeigeSpalten[2]:=12;
  Datenbank.Mp3DatenMeta[High(FPlaylisten)].AnzeigeSpalten[3]:=14;
  Datenbank.Mp3DatenMeta[High(FPlaylisten)].AnzeigeSpalten[4]:=14;

  DatenbankListeAusgeben( High(FPlaylisten) );
end;

procedure TFmp3.ZeitmessungStart;
begin
   Stoppuhr:=GetTickcount;
end;

function TFmp3.ZeitmessungStopp:int64;
begin
   Result:=GetTickcount-Stoppuhr;
end;

procedure TFmp3.Zeitmessung2Start;
begin
   Stoppuhr2:=GetTickcount;
end;

function TFmp3.Zeitmessung2Stopp:int64;
begin
   Result:=GetTickcount-Stoppuhr2;
end;

procedure TFmp3.TBXItem6Click(Sender: TObject);
   var i,ListenNummer : integer;
begin
  if Datenbank.ListeExists(Aktiv.Liste)
   then
begin
try
   ListenNummer:=fmp3.Aktiv.Liste; //schwammig

   if fmp3.Datenbank.ListeExists(ListenNummer)
   then
   begin
     i:=0;
     fmp3.Fplaylisten[ ListenNummer ].TBXAlignmentPanel2.Visible := true;
 //ukuk    fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Caption:='Lese...';
     repeat
       fmp3.Datenbank.LeseId3(ListenNummer,
                          fmp3.Datenbank.Mp3Daten[ListenNummer,i].Nummer);

       fmp3.Datenbank.SetMediumPlayLength(ListenNummer,
            fmp3.Datenbank.Mp3Daten[ListenNummer,i].Nummer,
            fmp3.DauerZuString(fmp3.Spieler.GetDauer(
            fmp3.Datenbank.Mp3Daten[ListenNummer,i].path+
            fmp3.Datenbank.Mp3Daten[ListenNummer,i].filename )));

       if (i mod AusleseIntervall)=0
         then
           begin
             fmp3.DatenbankListeAusgeben(ListenNummer);
//ukuk             fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Max :=
//ukuk                                High(fmp3.Datenbank.Mp3Daten[ListenNummer]);
                                //Es könnten mehr geworden sein
//ukuk             fmp3.Fplaylisten[ListenNummer].TBXPBauslesen.Position := i;
           end;

       inc(i);
     until (i=High(fmp3.Datenbank.Mp3Daten[ListenNummer])+1);

     fmp3.DatenbankListeAusgeben(ListenNummer);
//ukuk     fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Caption:='';
     fmp3.Fplaylisten[ ListenNummer ].TBXAlignmentPanel2.Visible := false;
   end;
except
 begin
  showmessage('[Fehler]');
 end;
end;
end;
end;

procedure TFmp3.TBXItem5Click(Sender: TObject);
begin
 if Datenbank.ListeExists(Aktiv.Liste) then
 Fplaylisten[aktiv.Liste].CopyThread.execute;
end;

procedure TFmp3.MinimizeETitelPath(path: string);
begin
  Etitel.Text := MinimizeName(path, Canvas, Etitel.Width);
end;

procedure TFmp3.TBXDockablePanel6Resize(Sender: TObject);
begin
  MinimizeETitelPath(Etitel.Hint);
end;

procedure TFmp3.EtitelDblClick(Sender: TObject);
begin
  Etitel.SelectAll;
end;

procedure TFmp3.TBXPBarMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  TBXPBar.Hint := Format('Zu %s spulen.', [DauerZuString(round(X / TBXPbar.Width * Spieler.GetLength))]);
end;

procedure TFmp3.AopenlistExecute(Sender: TObject);
begin
  OeffnePlayliste;
end;

procedure TFmp3.SuchfeldLoeschen(NeuerText: string = '');
begin
  Esuche.Text := NeuerText;
end;

procedure TFmp3.TBXItem7Click(Sender: TObject);
begin
  SuchfeldLoeschen;
  if aktiv.Liste=aktiv.SpielendeListe
  then  EtitelMouseDown(fmp3,mbleft,[],0,0);
end;

procedure TFmp3.TBXItem4Click(Sender: TObject);
var
  id3tag: Tid3tag;
  ArrayIndex: integer;
begin
  if (Datenbank.ListeExists(Aktiv.SpielendeListe)) and (Datenbank.EintragExists(Aktiv.SpielendeListe, Aktiv.SpielendesElement, ArrayIndex)) then
  begin
    id3tag := Datenbank.GetMediumId3Tag(Aktiv.SpielendeListe, Aktiv.SpielendesElement);
    ESuche.Text := id3tag.Artist;
  end;
end;

procedure TFmp3.SuchFeldMarkieren;
begin
   Esuche.Click;
end;

procedure TFmp3.AcloseExecute(Sender: TObject);
begin
 close;
end;

procedure TFmp3.AalwaysontopExecute(Sender: TObject);
begin
  if Aalwaysontop.Checked
  then
  begin
    flaut.FormStyle := fsNormal;
    Aalwaysontop.Caption := ALWAYSONTOP_ON;
    Aalwaysontop.Checked := false;
  end
  else
  begin
    flaut.FormStyle := fsStayOnTop;
    Aalwaysontop.Caption := ALWAYSONTOP_OFF;
    Aalwaysontop.Checked := true;
  end;
end;

procedure TFmp3.ShowOrHideFLaut;
var
  H: HWnd;
  Rect: TRect;
begin
  if Flaut.Visible
  then Flaut.Visible := false  
  else
  begin
    flaut.visible:=true;
   // ShowWindow(Flaut.Handle, SW_SHOW);
   // flaut.bringtofront;
  //  Flaut.Visible := true;
    H:= FindWindow('Shell_TrayWnd', nil);
    if H<>0 then
    begin
      GetWindowRect(H, Rect);
      Flaut.Top := Rect.Top - Flaut.Height;
    end
    else
    begin
      Flaut.Top := Screen.Height - Flaut.Height;
    end;
    Flaut.BringToFront;
  end;

  Flaut.Left := Screen.Width - Flaut.Width;

end;

procedure TFmp3.TrayIconMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then ShowOrHideFLaut;
end;

procedure TFmp3.WMQueryEndSession (var M: TWMQueryEndSession);  //Wenn Shutdown
begin
  inherited;
  M.Result := 1; //Damit wird das Herunterfahren bestätigt
  close;
end;

procedure TFmp3.TBXCBtrayiconChange(Sender: TObject);
begin
  if not TBXCBtrayicon.Checked then
  begin
    TBXCBtaskbuttton.Checked := true;
    TBXCBmintotray.Checked := false;
  end;

  if not TBXCBtaskbuttton.Checked then
  begin
    TBXCBmintotray.Checked := true;
  end;
  Trayicon.IconVisible := TBXCBtrayicon.Checked;
end;

procedure TFmp3.TBXCBmintotrayChange(Sender: TObject);
begin
  if not TBXCBmintotray.Checked then
  begin
    TBXCBtaskbuttton.Checked
  end;
  TBXCBtrayicon.Checked := true;
  Trayicon.MinimizeToTray := TBXCBmintotray.Checked;
end;

procedure TFmp3.TBXCBscrolltitleChange(Sender: TObject);
begin
  if not TBXCBscrolltitle.Checked then
  begin
    Application.Title := Aktiv.SpielenderTitel + ' — ';
  end else
  begin
    TBXCBtaskbuttton.Checked := true;
  end;
end;

procedure TFmp3.GPlayListenDblClick(index: integer);
begin
  if GPlaylisten.markiertesElement<>-1
  then ListeLaden( GPlaylisten.Liste.l0[ GPlaylisten.markiertesElement ] )
end;

procedure TFmp3.EsucheChange(Sender: TObject; const Text: string);
begin
  if (CreateDone) and (Datenbank.ListeExists(Aktiv.Liste))
   then
    begin
     Suche(Aktiv.Liste, text);
    end;
end;

procedure TFmp3.TBXItem8Click(Sender: TObject);
begin
  Esuche.Strings.Clear;
end;


procedure TFmp3.AppDeaktivate(Sender : TObject);
begin
  if fmp3.Aalwaysontop.Checked
  then
    begin
     flaut.FormStyle:=fsstayontop;
     flaut.BringToFront;
    end;
end;

procedure TFmp3.AppAktivate(Sender : TObject);
begin
  flaut.Visible:=false;
end;

procedure TFMp3.DrawGradient(const Canvas: TCanvas; Color1, Color2: TColor; Rect: TRect);
var
  Y, R, G, B: Integer;
  RColor1, GColor1, BColor1: Integer;
  RColor2, GColor2, BColor2: Integer;
begin
  Color1:=ColorToRGB(Color1);
  Color2:=ColorToRGB(Color2);

  RColor1:=GetRValue(Color1);
  GColor1:=GetGValue(Color1);
  BColor1:=GetBValue(Color1);

  RColor2:=GetRValue(Color2);
  GColor2:=GetGValue(Color2);
  BColor2:=GetBValue(Color2);

  Canvas.Pen.Width:=1;
  Canvas.Pen.Style:=psInsideFrame;

  for Y:=Rect.Top to Rect.Bottom-1 do
  begin
    R:=Round(RColor1 + ((RColor2 - RColor1) * Y / (Rect.Bottom - Rect.Top)));
    G:=Round(GColor1 + ((GColor2 - GColor1) * Y / (Rect.Bottom - Rect.Top)));
    B:=Round(BColor1 + ((BColor2 - BColor1) * Y / (Rect.Bottom - Rect.Top)));

    Canvas.Brush.Color:=RGB(R, G, B);
    Canvas.FillRect(Classes.Rect(Rect.Left, Y, Rect.Right, Y+1));
  end;
end;

procedure TFmp3.GHistoryDoppelClick(Index :integer);
begin
  if Datenbank.ListeExists(Aktiv.Liste)
  then
    begin
      Spiele(Aktiv.Liste,strtoint(GHistory.liste.Nummer[index]),false,true);
      Datenbank.Mp3DatenMeta[Aktiv.Liste].historyposition:=index;
      DatenbankListeAusgeben(aktiv.liste);    //Könnte eingespart werden
    end;
end;


procedure TFmp3.HistoryDragOver ( Sender, Source:Tobject; x,y: integer;
                                   State: TDragState; var accept:boolean);
begin
  accept:= (Source is TGliste2) and ((Source as TGliste2).Tag2>0);
end;


procedure TFmp3.History_DragItemInsert(Source: TObject; SourcePosition,
                                     SourceID:integer; Target: TObject;
                                     TargetPosition, TargetID: integer);
var
    HistoryPosition: integer;
begin
  if Datenbank.ListeExists(aktiv.Liste) then
  begin
    GHistory.ItemInsert(TargetPosition,
                        SourceID,
                        false,
                        Datenbank.GetEintragfuerSpalte(0,Aktiv.Liste,
                          Datenbank.ElementNummerZuArrayIndex(Aktiv.Liste,
                          SourceID)),
                        '','','','');
    Ghistory.Draw;

    if not GHistory.GetFirstMultiSelectedItem(HistoryPosition)
     then HistoryPosition:=0;


    Datenbank.History_RebuiltfromStringList(aktiv.Liste,GHistory.liste.Nummer,
                          HistoryPosition);

{
  if Datenbank.ListeExists(aktiv.Liste) then
  begin
    Datenbank.History_QueueItem(aktiv.Liste,SourceID,TargetPosition);
    DatenbankListeAusgeben(aktiv.Liste);  }
  end;  
end;


procedure TFmp3.History_DragItemMove(Source: TObject; SourcePosition,
                                     SourceID:integer; Target: TObject;
                                     TargetPosition, TargetID: integer);

var
    HistoryPosition: integer;
begin
  if Datenbank.ListeExists(aktiv.Liste) then
  begin
    GHistory.ItemMove(sourceposition,targetposition);
    Ghistory.Draw;

    if not GHistory.GetFirstMultiSelectedItem(HistoryPosition)
     then HistoryPosition:=0;


    Datenbank.History_RebuiltfromStringList(aktiv.Liste,GHistory.liste.Nummer,
                          HistoryPosition);
 { //Folgender instabiler Code wurde durch obigen Ersetzt
    if SourcePosition>TargetPosition
    then
      begin
        Datenbank.History_DeleteItem(aktiv.Liste,SourcePosition);
        Datenbank.History_QueueItem(aktiv.Liste,SourceID,TargetPosition)
      end
    else
      begin
        Datenbank.History_QueueItem(aktiv.Liste,SourceID,TargetPosition);
        Datenbank.History_DeleteItem(aktiv.Liste,SourcePosition);
      end;

    DatenbankListeAusgeben(aktiv.Liste);
 } end;
end;


procedure TFmp3.GHistory_KeyDown(Key:word;Shift:tshiftstate);
begin

  if (key = vk_delete) then
    History_DeleteItem(GHistory.markiertesElement)

end;


procedure Tfmp3.History_DeleteItem(Index:integer);

var
    HistoryPosition: integer;
begin
  if (Datenbank.ListeExists(aktiv.Liste)) and (Index<>-1) then
  begin
      //Aktuelle HistroyPosition finden und wieder setzen
    if not GHistory.GetFirstMultiSelectedItem(HistoryPosition)
     then HistoryPosition:=0;

    GHistory.ItemDelete(GHistory.markiertesElement);

    Ghistory.Draw;

    Datenbank.History_RebuiltfromStringList(aktiv.Liste,GHistory.liste.Nummer,
                          HistoryPosition);
  end;
end;


procedure TFmp3.GFavoritDoppelClick(Index :integer);
var ElementNummer : integer;
begin
  if Datenbank.ListeExists(Aktiv.Liste)
  then
    begin
      ElementNummer := strtoint(GFavorit.liste.Nummer[index]);
      Spiele(Aktiv.Liste,ElementNummer,false,false);
      GFavorit.SetSelected(ElementNummer);
    end;
end;

procedure TFmp3.GStyleDoppelClick(Index :integer; Shift: TShiftState);
begin
  if Index < 0 then Index := 0;
  TBXSetTheme(GStyle.Liste.l0[Index]);
  SetColor;
end;


procedure TFmp3.TBXIvis12Click(Sender: TObject);

begin
  Spieler.SetBassVisMode((Sender as TTBXItem).HelpContext,
                          (Sender as TTBXItem).Checked); 
end;

procedure TFmp3.TBXItem32Click(Sender: TObject);
begin
 showmessage(floattostr(spieler.GetPosition));
end;

procedure TFmp3.TBXIHistoryPlayClick(Sender: TObject);
begin
 if Datenbank.ListeExists(Aktiv.Liste) and (GHistory.markiertesElement<>-1)
 then
   begin
     Spiele(Aktiv.Liste,strtoint(GHistory.Liste.nummer[GHistory.markiertesElement]));
   end;
end;


procedure TFmp3.MediaKey (Var aMSG: tMessage);
begin

  case aMSG.LParam of
    APPCOMMAND_MEDIA_NEXTTRACK     :
    begin
      Weiterschalten;
      aMsg.Result := 1;
    end;
    APPCOMMAND_MEDIA_PREVIOUSTRACK :
    begin
      Zurueckschalten;
      aMsg.Result := 1;
    end;
    APPCOMMAND_MEDIA_STOP          :
    begin
      Stop;
      aMsg.Result := 1;
    end;
    APPCOMMAND_MEDIA_PLAY_PAUSE    :
    begin 	
      Pause;
      aMsg.Result := 1; 	
    end;
  {  APPCOMMAND_VOLUME_DOWN         :
    begin

    end;
    APPCOMMAND_VOLUME_MUTE         :
    begin

    end;
    APPCOMMAND_VOLUME_UP           :
    begin

    end;  }
  end; 	
end;


{procedure TFmp3.DrawTexttoDesktop(Text: String);
var
 DCanvas: TCanvas;
 DHandle: HWND;
begin
 DHandle:=GetDC(0);
 if DHandle<>0 then
 begin
   try
     DCanvas:=TCanvas.Create;
     try
       DCanvas.Handle:=DHandle;
       DCanvas.Font.Color:=clRed;
       DCanvas.Font.Size:=30;
       DCanvas.Brush.Style:=bsClear;
       DCanvas.TextOut(10, 80, Text);
     finally
       DCanvas.Free;
     end;
    finally
      if ReleaseDc(0, DHandle)<>1 then
        RaiseLastOSError;
    end;
 end
 else
   RaiseLastOSError;
end;
}

procedure TFmp3.TScreenTextTimer(Sender: TObject);
begin
(*  inc(Aktiv.ScreenTextCounter);
  DrawTexttoDesktop(Aktiv.ScreenText);

  if Aktiv.ScreenTextCounter>200 then TScreenText.Enabled:=false;
*)
end;



procedure TFmp3.TBXI_ScreenTextClick(Sender: TObject);
begin

end;

//Ähnlicher Code wie beim Speichern des id3-tags (ohne Medium.Stopp)
procedure TFmp3.DeleteSelectedItems;
var Items : TStringList;
    i,markiert,markiert_id,ListenNummer  : integer;

begin
  ListenNummer:=Aktiv.Liste;

  if Datenbank.ListeExists(ListenNummer) then
  begin
    Items:= TStringList.Create;
    if not FPlaylisten[ListenNummer].Gliste1.GetMultiSelectetItems_ID(Items)
         //Wenn nichts per Multiselect markiert ist
    then Items.Add(inttostr(Aktiv.MarkiertesElement));


    for i:=0 to Items.Count-1 do
    begin

      ElementLoeschen(ListenNummer,strtoint(Items[i]));

    end;

   markiert   :=FPlaylisten[ListenNummer].Gliste1.GetSelectet;
   markiert_id:=FPlaylisten[ListenNummer].Gliste1.GetSelectet_ID;

   DatenbankListeAusgeben(ListenNummer);

   Fplaylisten[ListenNummer].Gliste1.markiertesElement:=markiert;
   Fplaylisten[ListenNummer].Gliste1.Draw;

   if markiert_id<>-1 then
     ElementMarkieren(ListenNummer,markiert_id);
end;
end;

{function TFmp3.IsExeRunning(ExeNames: Tstrings): boolean;
var
  h: THandle;
  p: TProcessEntry32;
  i: integer;
begin
  Result := False;

  p.dwSize := SizeOf(p);
  h := CreateToolHelp32Snapshot(TH32CS_SnapProcess, 0);
  try
    Process32First(h, p);
    repeat
      for i := 0 to ExeNames.Count -1 do
      begin
        Result := AnsiUpperCase(Trim(ExeNames[i])) = AnsiUpperCase(p.szExeFile);
        if Result then break;
      end;
    until Result or (not Process32Next(h, p));
  finally
    CloseHandle(h);
  end;
end;
}

procedure TFmp3.TBXIselect_colsClick(Sender: TObject);
begin
  if Datenbank.ListeExists(Aktiv.Liste) then
  begin
    Fplaylisten[ Aktiv.Liste ].TBXAlignmentPanel3.Visible := not
      Fplaylisten[ Aktiv.Liste ].TBXAlignmentPanel3.Visible;

    Fplaylisten[ Aktiv.Liste ].TBXI_SpaltenWaehlen.Checked:=
      Fplaylisten[ Aktiv.Liste ].TBXAlignmentPanel3.Visible;

    TBXIselect_cols.Checked:=
      Fplaylisten[ Aktiv.Liste ].TBXAlignmentPanel3.Visible;
  end;
end;


function DezToX(dez, bas: Cardinal): String;
const
zahlen: array[0..15] of Char =
  ('0', '1', '2', '3', '4', '5', '6', '7',
   '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
begin
If (Bas>16) OR (bas<2) Then Begin
   MessageDlg('Unzulässige Zahlenbasis:'+IntToStr(bas),mtWarning,[mbOK],0);
   Abort; // Damit auch nachfolgende Routinen abgebrochen werden
End;
if dez <> 0 then
  Result := DezToX(dez div bas, bas) + zahlen[dez mod bas]
else
  Result := '';
end;


procedure TFmp3.TBinClockTimer(Sender: TObject);

   function GetColor(w : word):tcolor;
   begin
     if w<>0 then result:=aktiv.MainColor else result:=clbtnface;
   end;


var Time : TSystemTime;
    Sec, Min, H : byte;

begin
    GetLocalTime(time);

    Sec:=Time.wSecond;
    PS1.Color:=(GetColor( Sec div 32 ));
    PS2.Color:=(GetColor( Sec mod 32 div 16 ));
    PS3.Color:=(GetColor( Sec mod 32 mod 16 div 8));
    PS4.Color:=(GetColor( Sec mod 32 mod 16 mod 8 div 4));
    PS5.Color:=(GetColor( Sec mod 32 mod 16 mod 8 mod 4 div 2));
    PS6.Color:=(GetColor( Sec mod 32 mod 16 mod 8 mod 4 mod 2));

    Min:=Time.wMinute;
    PM1.Color:=(GetColor( Min div 32 ));
    PM2.Color:=(GetColor( Min mod 32 div 16 ));
    PM3.Color:=(GetColor( Min mod 32 mod 16 div 8));
    PM4.Color:=(GetColor( Min mod 32 mod 16 mod 8 div 4));
    PM5.Color:=(GetColor( Min mod 32 mod 16 mod 8 mod 4 div 2));
    PM6.Color:=(GetColor( Min mod 32 mod 16 mod 8 mod 4 mod 2));

    H:=Time.wHour;
    PH0.Color:=(GetColor( 0 ));
    PH1.Color:=(GetColor( H div 16 ));
    PH2.Color:=(GetColor( H mod 16 div 8));
    PH3.Color:=(GetColor( H mod 16 mod 8 div 4));
    PH4.Color:=(GetColor( H mod 16 mod 8 mod 4 div 2));
    PH5.Color:=(GetColor( H mod 16 mod 8 mod 4 mod 2));
end;


procedure TFmp3.LETitleChange(Sender: TObject);
begin
  cbtitle.Checked:=true;
end;

procedure TFmp3.LEartistChange(Sender: TObject);
begin
  cbartist.Checked:=true;
end;

procedure TFmp3.LEalbumChange(Sender: TObject);
begin
  cbalbum.Checked:=true;
end;

procedure TFmp3.LETrackChange(Sender: TObject);
begin
  cbtrack.Checked:=true;
end;

procedure TFmp3.LEyearChange(Sender: TObject);
begin
  cbyear.Checked:=true;
end;

procedure TFmp3.LEgenereChange(Sender: TObject);
begin
  cbgenre.Checked:=true;
end;

procedure TFmp3.LEcommentChange(Sender: TObject);
begin
  cbcomment.Checked:=true;
end;

procedure TFmp3.TBXItem10Click(Sender: TObject);
begin
  Datenbank.CopyAllFilesToANewListSortedbyNummberOfFilesofFolder;
end;

procedure TFmp3.TBXI_RemoveDirClick(Sender: TObject);
begin
  Datenbank.RemoveEmptyFolders(aktiv.Liste);
end;

procedure TFmp3.TBXI_DelInvalideItemsClick(Sender: TObject);
begin
  Datenbank.DeleteInvalidItems(aktiv.liste);
  DatenbankListeAusgeben(aktiv.Liste);
end;

procedure TFmp3.TBXDockablePanel8VisibleChanged(Sender: TObject);
begin
  TBinClock.Enabled:=TBXDockablePanel8.Visible;
end;

procedure TFmp3.LETitleKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = vk_return then
    //Änderungen Speichern Knopf
    TBXButton1Click(fmp3);
end;

procedure TFmp3.TBXI_Queue_ItemsClick(Sender: TObject);
begin
  if Datenbank.ListeExists(aktiv.liste) then
  begin
    Datenbank.History_QueueItem(Aktiv.liste,strtoint(GHistory.liste.Nummer[GHistory.markiertesElement]));
    DatenbankListeAusgeben(aktiv.liste);
  end;  
end;

procedure TFmp3.TBXI_Queue_Item_FavClick(Sender: TObject);
begin
  if Datenbank.ListeExists(aktiv.liste) then
  begin
    Datenbank.History_QueueItem(Aktiv.liste,strtoint(GFavorit.liste.Nummer[GFavorit.markiertesElement]));
    DatenbankListeAusgeben(aktiv.liste);
  end;
end;

procedure TFmp3.TBXPMHistoryPopup(Sender: TObject);
var
  i: integer;
  enable: boolean;
begin
  enable := GHistory.markiertesElement <> -1;
  for i := 0 to TBXPMHistory.Items.Count - 1 do
  begin
    TBXPMHistory.Items.Items[i].Enabled := enable;
  end;
end;  

procedure TFmp3.TBXPM_FavoritPopup(Sender: TObject);
var
  i: integer;
  enable: boolean;
begin
  enable := GFavorit.markiertesElement <> -1;
  for i := 0 to TBXPM_Favorit.Items.Count - 1 do
  begin
    TBXPM_Favorit.Items.Items[i].Enabled := enable;
  end;
end;

procedure TFmp3.TBXB_HighPriorityChange(Sender: TObject);
var
  Priorclass:integer;
begin
  if TBXB_HighPriority.Checked
  then Priorclass:= HIGH_PRIORITY_CLASS
  else Priorclass:= NORMAL_PRIORITY_CLASS;

  if not SetPriorityClass(GetCurrentProcess,PriorClass)
    then Fehler('Das System konnte zeitkritische Änderungen nicht übernehmen');
end;

procedure TFmp3.TBXI_ScreenTextChange(Sender: TObject);
begin
  TBXCB_AutoOSD.Checked:=false;
end;

procedure TFmp3.ScreenText_refresherTimer(Sender: TObject);
begin
  if abs(GetTickCount) - ScreenText_refresher.Tag > 2000 then
    begin
      ClearScreenText;
      ScreenText_refresher.Enabled := false;
    end
  else
    begin
      WriteText(Aktiv.ScreenText_Text);
    end;
end;

procedure TFmp3.IcoverClick(Sender: TObject);
begin
  SetCover_Next;
end;

procedure TFmp3.TBXIopencoverClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open',PChar(ICover.Hint), nil, nil, SW_ShowNormal);
end;

procedure TFmp3.TBXIopencoverdirClick(Sender: TObject);
begin
  OpenFolderAndMarkFile(ICover.Hint);
end;

procedure TFmp3.TBXItem11Click(Sender: TObject);
var
  ArrayIndex : integer;
  FileName : string;
begin
  if (Datenbank.EintragExists(Aktiv.Liste, GFavorit.GetSelectet_ID, ArrayIndex)) then
  begin
    Datenbank.GetMediumFullFileName(Aktiv.Liste,GFavorit.GetSelectet_ID,FileName);
    ESuche.Text:=ExtractFilePath(FileName)+' '+ExtractFileName(FileName);
  end;
end;

procedure TFmp3.TBXPB_shuffleMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shuffleMouseDown := false;
end;

procedure TFmp3.TBXPB_shuffleMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if shuffleMouseDown
  then
  begin
    TBXPB_shuffle.Position := round(100 * X / TBXPB_shuffle.Width);
    CalculateAndShowShufflerange;
  end;
end;

procedure TFmp3.TBXPB_shuffleMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shuffleMouseDown := true;
  TBXPB_shuffle.Position := round(100 * X / TBXPB_shuffle.Width);
  CalculateAndShowShufflerange;
end;


function TFmp3.SelDirectory(startverzeichnis:string):string;
var
  Dir: String;
begin
  SelectDirectory('Select a directory', '', Dir);
  aktiv.SelDirPath:=Dir;
  result:=Dir;
end;


procedure TFmp3.TBXItem24Click(Sender: TObject);
var i,Anzahl,MilliSekunden:integer;
    ElementeProSekunde : double;
begin
  if Datenbank.ListeExists(Aktiv.Liste)
  then
    begin
    ZeitmessungStart;
    for i:=0 to 149 do
    Datenbank.Search(Aktiv.Liste,'Madonna Music; Red Hot');

    Anzahl:=Datenbank.GetLengthOfList(Aktiv.Liste);
    MilliSekunden:=ZeitmessungStopp;
    ElementeProSekunde:= Anzahl*150/Millisekunden*1000;

    Datenbank.GetLengthOfList(Aktiv.Liste);
    Showmessage('Die 150x Suche von '+inttostr(Anzahl)+
                  ' Elementen dauerte '+inttostr(MilliSekunden)+' ms.'+#13
                  + 'Das sind pro Sekunde: '+FloatToStr(ElementeProSekunde));

    Datenbank.Search(Aktiv.Liste,ESuche.Text);
    end;
end;

initialization //uk | Um zu verhindern, dass Emat mehrmals gestartet wird,
               //aber es trozdem möglich ist, wenn Delphi läuft, um auch während
               //des Programmierens mit Emat Musik hören zu können.

  if FindWindow('TAppBuilder', nil) <= 0 then
  begin
    mHandle := CreateMutex(nil,True,'Emat');
    if GetLastError = ERROR_ALREADY_EXISTS then
    begin
      ShowWindow( Application.Handle, SW_HIDE );
      SetWindowLong( Application.Handle, GWL_EXSTYLE,
                     GetWindowLong(Application.Handle, GWL_EXSTYLE) or
                      WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
      ShowWindow( Application.Handle, SW_SHOW );
      MessageDlg(ONLYRUNONETIME, mtError, [mbOk], -1);
      Halt;
    end;
  end;

finalization
if mHandle <> 0 then CloseHandle(mHandle)

end.
