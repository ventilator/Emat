unit mainU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,bass,BassVis, Menus, ActnList, ExtCtrls, ComCtrls, StdCtrls;

const
   WM_ENDMUSIC = WM_USER+400; //Message for Syncronize

type
  //Helptype for Playlisthandling
  TSongType = (stNone,stStream,stMusic);
  //Helpclass for handling Songinfos of the songs in
  //the playlist.
  TSong = class(TObject)
  Public
     SongType : TSongType;
     filename : string;
     info : TBASSVIS_INFO;
     Constructor Create;
     Destructor Destroy;override;
     procedure MakeSongType;
     procedure MakeInfos;
  end;
  //Mainform of the example
  Tfrmain = class(TForm)
    mm: TMainMenu;
    almain: TActionList;
    acselsonique: TAction;
    acselwinamp: TAction;
    Plugins1: TMenuItem;
    SelectSoniquePlugin1: TMenuItem;
    SelectWinampPlugin1: TMenuItem;
    acshowversion: TAction;
    N1: TMenuItem;
    ShowbassvisVersion1: TMenuItem;
    sbmain: TStatusBar;
    GroupBox1: TGroupBox;
    Splitter1: TSplitter;
    Panel1: TPanel;
    pdisplay: TPanel;
    ppoptions: TPanel;
    Splitter2: TSplitter;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    lbsongs: TListBox;
    add: TButton;
    od: TOpenDialog;
    Button4: TButton;
    Timer1: TTimer;
    Button5: TButton;
    Button6: TButton;
    rbrecord: TRadioButton;
    rbstream: TRadioButton;
    gbdevice: TGroupBox;
    cbodevlist: TComboBox;
    lblsource: TLabel;
    Label1: TLabel;
    edlvl: TEdit;
    udlvl: TUpDown;
    rgview: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acselsoniqueExecute(Sender: TObject);
    procedure acshowversionExecute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure acselwinampExecute(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure pdisplayResize(Sender: TObject);
    procedure addClick(Sender: TObject);
    procedure lbsongsDblClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure lbsongsClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure rbrecordClick(Sender: TObject);
    procedure rbstreamClick(Sender: TObject);
    procedure cbodevlistChange(Sender: TObject);
    procedure edlvlChange(Sender: TObject);
    procedure pdisplayMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private-Deklarationen }
    visparam : TBASSVIS_PARAM;//Instanzeinformation of the current Plugin
    PluginList : TStrings;//List for Plugins
    modulelist : TStrings;//List for Modules of the Plugin only Winamp
    PluginItem : integer;//itemindex of the Pluginlist
    Moduleitem : integer;//Itemindex of the Module
    exec : TBASSVIS_EXEC;//Paramrecord for ExecutePlugin
    isRecording:boolean; //Flag if source is recording
    function GetPluginsPath(Caption:string;def:string=''):string;
    procedure SetStatus(P1:String='';p2:string='');
    function GetcurrentSong:TSong;
    function InitDefs:boolean;
    function StoreDefs:boolean;
    procedure MyMessage(var msg:TMessage);message WM_ENDMUSIC;//Sync via Windows-Message-System
    procedure HandlePluginChange(start:boolean=false);//Action when plugin has to change
    procedure ShowHideDeviceOptions(DoShow:boolean=FALSE);
    procedure InitDeviceCombo;
  public
    { Public-Deklarationen }
    source:DWORD;//HSTREAM or HMUSIC
    mysny : HSYNC;//Synchandle
    procedure Play;//Playing an entry of the Playlist
    Procedure Pause;//Pause the playback
    procedure Stop;//Stop playback
    Procedure PlayNext;//Play the next track on the Playlist
    Procedure PlayPrev;//Play prev track on the Playlist
    procedure ResetTimePanel;//Reset the playingtime display
    Procedure SyncPluginInfos;//Set the infos of the current song to the plugin

  end;

var
  frmain: Tfrmain;


implementation
uses
  displayU,
  inifiles,
  filectrl,
  listselect;
{$R *.dfm}

const
   cSonique = 0;
   cWinamp = 1;
   DefPluginPaths : array[0..1] of String = ('','');
   cTimeFormat = '%.2d:%.2d:%.2d';



//Callback for handle play/pause/stop buttons in an plugin
procedure MyCallBack(NewState: TPlaystate);stdcall;
begin
  case newstate of
    psPlay : frmain.Play;
    psStop : frmain.stop;
    psPause: frmain.pause;
    psGetPlaylistPos : frmain.PlayPrev;
    psSetPlaylistPos : frmain.playNext;
  end;

end;

//Helperfunction for formating a time for the GUI
function SecondsToTime(secs:cardinal):string;
var
  HH,MM : cardinal;

begin
  hh := secs DIV 3600;
  secs := secs MOD 3600;
  MM := secs div 60;
  secs := secs mod 60;
  result := format(cTimeFormat,[HH,MM,secs]);
end;

//Selecting an Sonique-Plugin
procedure Tfrmain.acselsoniqueExecute(Sender: TObject);
var
  path : string;
  x,y,w,h : integer;
  container : HWND;

begin
  HandlePluginChange(FALSE);
  visparam.Kind := BASSVISKIND_SONIQUE; //IMPORTANT !!! Let BASSVIS alway know witch kind of Plugin we want to use
  path := GetPluginsPath('Select Plugindirectory for Sonique Plugins',DefPluginPaths[0]);
  if (path = '') then exit;
  
  DefPluginpaths[0] := path;
  //Get the list of Plugins and let the user choose
  pluginlist.clear;
  pluginlist.CommaText := BASSVIS_FindPlugins(BASSVISKIND_SONIQUE,pchar(path),BASS_VIS_FIND_SONIQUE or BASS_VIS_FIND_RECURSIVE);
  Pluginitem := SelectFromList('Select a Plugin',Pluginlist);
  if (PluginItem > -1) then
  begin
    //IMPORTANT !!! Initalization of the Plugin
    if not BASSVIS_INIT(visparam.Kind,application.Handle,handle) then
    begin
       Messagedlg('Can not initialize bassvis',mtError,[mbok],0);
       Pluginitem := -1;
       visparam.Kind := BASSVISKIND_NONE;
       exit;
    end;
    fillchar(exec,sizeof(exec),0);
    //Know examine where the user want to display the plugin
    x := 0;
    y := 0;
    w := 0;
    h := 0;
    container := 0;
    if (rgview.ItemIndex = 0) then
    begin
      if (frmdisplay.Visible) then
        frmdisplay.hide;
      container := pdisplay.handle;
      x := 5;
      y := 5;
      w := pdisplay.Width-10;
      h := pdisplay.Height-10;
    end;
    if (rgview.itemindex = 1) then
    begin
      if (not frmdisplay.visible) then
           frmdisplay.Show;
      x := 0;
      y := 0;
      w := frmdisplay.Width;
      h := frmdisplay.height;
      container := frmdisplay.Handle;
    end;
    //Set the nessesary informations for the start of the plugin
    exec.AMP_SON_Pluginfile := Pchar(pluginlist.Strings[pluginitem]);
    exec.SON_ConfigFile := Pchar(Extractfilepath(pluginlist.strings[pluginitem])+'vis.ini');
    exec.SON_Flags := 0;
    exec.Width := w;
    exec.Height := h;
    exec.Top := x;
    exec.Left := y;
    exec.SON_PaintHandle := container;
    BASSVIS_EXECUTEPLUGIN(@exec,visparam);
    //sets the handle for viewing the plugin
    BASSVIS_SetVisPort(@visparam,visparam.VisWinHandle,container,x,y,w,h);
    //Needet to Sonique plugins, to view the visualization correctly
    BASSVIS_Resize(@visparam,x,y,w,h);
    HandlePluginChange(TRUE);
    SetStatus('Active',BASSVIS_GetPluginName(@visparam));
  end;
end;

//The same as above for Winamp-Plugins; additional we can choose the module of a Plugin if available
procedure Tfrmain.acselwinampExecute(Sender: TObject);
var
  path : string;
  container : HWND;
  x,y,w,h : integer;
  count : integer;
begin
  HandlePluginChange(FALSE);
  visparam.Kind := BASSVISKIND_WINAMP;
  visparam.vishandle := 0;
  path := GetPluginsPath('Select Plugindirectory for Sonique Plugins',defpluginpaths[1]);
  if (path = '') then exit;  
  defpluginpaths[1] := path;
  pluginlist.clear;
  pluginlist.CommaText := BASSVIS_FindPlugins(BASSVISKIND_WINAMP,pchar(path),BASS_VIS_FIND_WINAMP or BASS_VIS_FIND_RECURSIVE);
  Pluginitem := SelectFromList('Select a Plugin',Pluginlist);
  if (PluginItem > -1) then
  begin
    if not BASSVIS_INIT(BASSVISKIND_WINAMP,application.Handle,handle) then
    begin
       Messagedlg('Can not initialize bassvis',mtError,[mbok],0);
       Pluginitem := -1;
       visparam.Kind := BASSVISKIND_NONE;
       exit;
    end;
    count := BASSVIS_GetModulePresetCount(@visparam,Pchar(pluginlist.Strings[pluginitem]));
    if (count > 1) then
    begin
      modulelist.clear;
      modulelist.CommaText := BASSVIS_GetModulePresetNameList(@visparam,Pchar(pluginlist.Strings[pluginitem]));
      moduleitem := SelectFromList('Module of Plugin',modulelist);
      if (moduleitem = -1) then
        moduleitem := 0;
    end
    else
      ModuleItem := 0;
    fillchar(exec,sizeof(exec),0);
    exec.AMP_SON_Pluginfile := Pchar(pluginlist.Strings[pluginitem]);
    exec.SON_ConfigFile := '';
    exec.AMP_Moduleindex := Moduleitem;
    exec.AMP_UseOwnW1 := ord(true);
    exec.AMP_UseOwnW2 := ord(true);
    container := 0;
    w := 0;
    h := 0;
    x := 0;
    y := 0;
    if rgview.ItemIndex = 0 then
    begin
       if (frmdisplay.Visible) then
         frmdisplay.hide;
       x := pdisplay.left;
       y := pdisplay.top;
       w := pdisplay.width;
       h := pdisplay.height;
       Container := pdisplay.handle;
    end;
    if (rgview.ItemIndex = 1) then
    begin
      x := 0;
      y := 0;
      w := frmdisplay.width;
      h := frmdisplay.height;
      if (not frmdisplay.Visible) then

      frmdisplay.Show;
      container := frmdisplay.Handle;
    end;
    if (rgview.itemindex = 2) then
    begin
      x := 0;
      y := 0;
      w := 0;
      h := 0;
      container := 0;
      exec.AMP_UseOwnW1 := ord(FALSE);
    end;
    exec.SON_PaintHandle := container;
    BASSVIS_EXECUTEPLUGIN(@exec,visparam);
    if (container <> 0) and (ord(exec.AMP_UseOwnW1) = ord(TRUE)) then
      BASSVIS_SetVisPort(@visparam,visparam.VisWinHandle,container,x,y,w,h);
    HandlePluginChange(TRUE);
    SetStatus('Active',BASSVIS_GetPluginName(@visparam));
  end;
end;

procedure Tfrmain.acshowversionExecute(Sender: TObject);
var
  ver : pchar;
begin
  ver := BassVis_GetVersion;
  messagedlg(ver,mtInformation,[mbok],0);
end;

//Adding a song to the playlist; TSongclass is needed for handling different types of songs
procedure Tfrmain.addClick(Sender: TObject);
var
  item : TSong;
  i : integer;
  inf : String;

begin
  if od.execute then
  begin
    for I := 0 to od.Files.count - 1 do
    begin
      item := TSong.Create;
      inf := ExtractFileName(od.Files.strings[i]);
      item.info.Songfile := pchar(od.files.strings[i]);
      item.filename := od.files.Strings[i];
      item.MakeSongType;
      item.MakeInfos;
      lbsongs.Items.AddObject(inf,item);
    end;
  end;
end;

//Play-Button
procedure Tfrmain.Button1Click(Sender: TObject);
begin
  play;
end;
//Stop-Button
procedure Tfrmain.Button2Click(Sender: TObject);
begin
  Stop;
end;

//Pause-Button
procedure Tfrmain.Button4Click(Sender: TObject);
begin
  pause;
end;
//Prev-Track-Button
procedure Tfrmain.Button5Click(Sender: TObject);
begin
  playprev;
end;

//Next-Track-Button
procedure Tfrmain.Button6Click(Sender: TObject);
begin
  PlayNext;
end;
//Changing Volume of the recording-channel
procedure Tfrmain.cbodevlistChange(Sender: TObject);
var
  opt : DWORD;
  lvl : WORD;

begin
  opt := BASS_RECORDGetInput(cbodevlist.ItemIndex);
  lvl := LoWord(opt);
  udlvl.Position := lvl;
  BASS_RecordSetInput(cbodevlist.itemindex,BASS_INPUT_ON);
end;
//Changing Volume of the recording-channel
procedure Tfrmain.edlvlChange(Sender: TObject);
var
  err : integer;
  vl : WORD;

begin
  val(trim(edlvl.text),vl,err);
  if (err = 0) then
     BASS_RecordSetInput(cbodevlist.itemindex,BASS_INPUT_LEVEL OR VL);
end;

//Initialzation of BASS and setting default values
procedure Tfrmain.FormCreate(Sender: TObject);
begin
  initdefs;
  if not (bass_init(-1,44100,0,handle,nil)) then
  begin
    Messagedlg('can not init bass.dll',mterror,[mbok],0);
    application.Terminate;
  end;
  BASS_START;
  BASS_RECORDINIT(-1);
  fillchar(visparam,sizeof(visparam),0);
  PluginList := TStringlist.create;
  modulelist := TStringlist.create;
  source := 0;
  isRecording := FALSE;
  ShowHideDeviceOptions(FALSE);
  initDeviceCombo;
  BASSVIS_WINAMP_SetStateCallback(MyCallBack);
  ResetTimePanel;
end;

//Free all things
procedure Tfrmain.FormDestroy(Sender: TObject);
begin
  StoreDefs;
  BASSVIS_WINAMP_RemoveCallback;
  if (visparam.vishandle <> 0) then
     BASSVIS_Quit(@visparam);
  bass_free;
  pluginlist.free;
  modulelist.free;
end;

//Getting the selected Song or the first if non is selected
function Tfrmain.GetcurrentSong: TSong;
begin
  fillchar(result,sizeof(result),0);
  if (lbsongs.Items.Count > 0) then
  begin
    if (lbsongs.ItemIndex > -1) then
      result := TSong(lbsongs.items.objects[lbsongs.itemindex])
    else
    begin
      lbsongs.itemindex := 0;
      result := TSong(lbsongs.items.objects[0]);
    end;
  end;
end;

//Selecting the Path to the Plugin-Files
function Tfrmain.GetPluginsPath(Caption: string;def:string=''): string;
var
  dir : string;

begin
  result := '';
  dir := def;
  if SelectDirectory(caption,'.\',dir) then
    result := dir;
end;

//Start/Stop Plugin and handel the current active channel so plugin will automaticaly start vis when playing/recording
procedure Tfrmain.HandlePluginChange(start:boolean=FALSE);
begin
  if not (start) then
  begin
    if (visparam.VisHandle <> 0) then
    begin
      BASSVIS_QUIT(@visparam);
      isRecording := FALSE;
    end;
  end
  else
  begin
    if not isRecording and (rbrecord.Checked) then
    begin
      BASS_RECORDINIT(-1);
      BASSVIS_SetPlayState(@visparam,psPlay);
      isRecording := BASSVIS_StartRecord(@visparam,44100,2);
    end
    else
    begin
      if not isRecording then
      begin
        if (BASS_CHANNELISACTIVE(SOURCE) = BASS_ACTIVE_PLAYING) then
        begin
          BASSVIS_SetPlayState(@visparam,psPlay);
          BASSVIS_RenderChannel(@visparam,source);
        end;
      end;
    end;
  end;
end;

//Load default values from a ini-file if available
function Tfrmain.InitDefs: boolean;
var
  ini : TIniFile;
  fn : string;

begin
  fn := ChangeFileExt(application.exename,'.ini');
  ini := TIniFile.Create(fn);
  DefPluginPaths[0] := ini.ReadString('PLUGINS','soniquepath','');
  DefPluginPaths[1] := ini.ReadString('PLUGINS','winamppath','');
  ini.free;
  result := TRUE;
end;

//Initialise the device selection for recording
procedure Tfrmain.InitDeviceCombo;
var
  erg : PCHAR;
  inp : Integer;
  lvl : WORD;
  opt : DWORD;
begin
  cboDevlist.items.clear;
  inp := 0;
  erg := BASS_RecordGetInputName(inp);
  while (erg <> NIL) do
  begin
    cboDevlist.Items.Append(erg);
    INC(inp);
    erg := BASS_RecordGetInputName(inp);
  end;
  if cboDevlist.items.Count >0 then
  begin
     cbodevlist.ItemIndex := 0;
     OPT := BASS_RecordGetInput(0);
     lvl := LoWord(opt);
     udLVL.Position := lvl;
  end;
end;

//stop song, if single clicked on a playlisentry
procedure Tfrmain.lbsongsClick(Sender: TObject);
begin
  stop;
end;

//start song (and stop prev. song) on doubleclick on an entry
procedure Tfrmain.lbsongsDblClick(Sender: TObject);
begin
  stop;
  play;
end;

//Handle the Sync-Message
procedure Tfrmain.MyMessage(var msg: TMessage);
begin
  playnext;
end;

//Pause song or resume song if it was paused
procedure Tfrmain.Pause;
begin
  if (BASS_CHANNELISACTIVE(source) = BASS_ACTIVE_PLAYING) then
  begin
    BASS_CHANNELPAUSE(source);
    if not isRecording then
      BASSVIS_SetPlayState(@visparam,psPause);
  end
  else
  begin
    if (BASS_CHANNELISACTIVE(source) = BASS_ACTIVE_PAUSED) then
    begin
      BASS_CHANNELPLAY(source,FALSE);
      if not isRecording then
        BASSVIS_SetPlayState(@visparam,psPlay);
    end;
  end;
end;

//Handle the click on the plugin for Sonique (config-window);Winamp automaticaly handle this
procedure Tfrmain.pdisplayMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  BASSVIS_Config(@visparam);
end;

//if we display the plugin on the panel, we need to do this
procedure Tfrmain.pdisplayResize(Sender: TObject);
var
 hlp : TBASSVIS_PARAM;
begin
  if (visparam.vishandle <> 0) then
  begin
    if Visparam.Kind = BASSVISKIND_WINAMP then
    begin
      hlp.Kind := BASSVISKIND_WINAMP;
      hlp.vishandle := pdisplay.handle;
      BASSVIS_Resize(@hlp,5,5,pdisplay.Width-10,pdisplay.height-10);
    end
    else
      BASSVIS_Resize(@visparam,5,5,pdisplay.Width-10,pdisplay.height-10);
  end;
end;

//Start playback a song of the playlist and start visualisation
procedure Tfrmain.Play;
var
 err : integer;
 song : TSong;
begin
  song := GetcurrentSong;
  if (length(song.info.Songfile)=0) then exit;
  
  source := 0;
  if (song.SongType = stStream) then
    source := BASS_STREAMCREATEFILE(FALSE,pchar(song.filename),0,0,BASS_STREAM_AUTOFREE);
  if (song.SongType = stMusic) then
    source := BASS_MusicLoad(false,pchar(song.filename),0,0,BASS_MUSIC_PRESCAN,0);
  if (source <> 0) then
  begin
    mysny := BASS_ChannelSetSync(source,BASS_SYNC_END or BASS_SYNC_MESSAGE,0,pointer(WM_ENDMUSIC),1);
    BASS_CHANNELPLAY(source,TRUE);
    if (visparam.VisHandle <> 0) and not IsRecording then
    begin
      BASSVIS_SetInfo(@visparam,@song.info);
      BASSVIS_RENDERCHANNEL(@visparam,source);
      if (BASSVIS_SetPlayState(@Visparam,psIsPlaying) <> ord (PsPlay)) then
        BASSVIS_SetPlayState(@visparam,psPlay);
    end;
  end
  else
  begin
    err := BASS_ERRORGETCODE;
    messagedlg('Error on start playback. Code: '+IntToStr(err),mterror,[mbOk],0);
  end;
end;

//Start playback the next song of the playlist and start visualisation
procedure Tfrmain.PlayNext;
var
  curidx : integer; //Itemindex internal because Listbox.itemindex can't be greater than count;
begin
  stop;
  curidx := lbSongs.itemindex;
  if (curidx < 0) then
    curidx := 0;
  if curidx > -1 then
    curidx := curidx+1;
  if (curidx > lbsongs.Items.Count-1) then
    curidx := 0;
  lbsongs.itemindex := curidx;
  Play;
end;

//Start playback the prev song of the playlist and start visualisation
procedure Tfrmain.PlayPrev;
var
  curidx : integer;
begin
  stop;
  curidx := lbsongs.itemindex;
  if (curidx = 0) then
    curidx := lbsongs.Items.count-1
  else
  begin
    if curidx > 0 then
      curidx := curidx-1;
  end;
  lbsongs.ItemIndex := curidx;
  Play;
end;

//Start recording and start vis. of the recordingchannel
procedure Tfrmain.rbrecordClick(Sender: TObject);
begin
  ShowHideDeviceOptions(TRUE);
  if (not IsRecording) and (visparam.VisHandle <> 0) then
  begin
     BASSVIS_StartRecord(@visparam,44100,2);
     BASSVIS_SetPlayState(@visparam,psPlay);
  end;
end;

//start direct vis of a song
procedure Tfrmain.rbstreamClick(Sender: TObject);
begin
  ShowHideDeviceOptions(FALSE);
end;

//Just for reset the view of the time in the statusbar
procedure Tfrmain.ResetTimePanel;
begin
  sbmain.panels[2].text := SecondsTotime(0)+' From '+SecondsToTime(0);
end;

//setting the infos for the statusbar
procedure Tfrmain.SetStatus(P1, p2: string);
begin
  sbmain.Panels[0].Text := p1;
  sbmain.panels[1].Text := p2;
  sbmain.Invalidate;
end;

//Handle additional Infos for Recording if selected
procedure Tfrmain.ShowHideDeviceOptions(DoShow: boolean);
begin
  gbdevice.Visible := DoShow;
end;

//Stop Playback and visualization
procedure Tfrmain.Stop;
var
  song : TSong;

begin
  if not isRecording then
  begin
    BASSVIS_SetPlayState(@visparam,psStop);
  end;
    BASS_ChannelStop(source);
    BASS_ChannelRemoveSync(source,mysny);
    song := GetcurrentSong;
    if (song.SongType = stStream) then
      BASS_StreamFree(source);
    if (song.SongType = stMusic) then
      BASS_MusicFree(source);
    ResetTimePanel;
end;

//Save the last used paths to the ini
function Tfrmain.StoreDefs: boolean;
var
  ini : TInifile;

begin
  ini := TIniFile.create(ChangeFileExt(application.exename,'.ini'));
  ini.WriteString('PLUGINS','soniquepath',DefPluginPaths[0]);
  ini.WriteString('PLUGINS','winamppath',DefPluginPaths[1]);
  ini.Free;
  result := TRUE;
end;


//Setting the Songinformation to the plugin
procedure Tfrmain.SyncPluginInfos;
var
  song : TSong;
begin
  if (visparam.VisHandle <> 0) and not IsRecording then
  begin
    song := GetCurrentSong;
    BASSVIS_SetInfo(@visparam,@song.info);
  end;
end;

//Handle playingtimes to statusbar and Plugin
procedure Tfrmain.Timer1Timer(Sender: TObject);
var
  song : tSong;
  cur : cardinal;
  b : int64;
begin
  if not IsRecording then
  begin
    if (BASS_CHANNELISACTIVE(source) = BASS_ACTIVE_PLAYING) then
    begin
      song := GetCurrentSong;
      b := BASS_ChannelGetPosition(source);
      cur := trunc(BASS_CHANNELBytes2Seconds(source,b));
      song.info.pos := cur*1000;
      sbmain.Panels[2].Text := SecondsToTime(cur)+' From '+SecondsToTime(song.info.Duration);
      syncPluginInfos;
    end;
  end;
end;


{ TSong }
//Just the implementation of the TSong-Helper-Class
constructor TSong.Create;
begin
  fillchar(info,sizeof(info),0);
  Songtype := stNone;
end;

destructor TSong.Destroy;
begin
  inherited;
end;

procedure TSong.MakeInfos;
var
  m : DWORD;
  bi : BASS_CHANNELINFO;
begin
  m := 0;
  fillchar(bi,sizeof(bi),0);
  if (songtype = stMusic) then
    m := BASS_MusicLoad(false,info.songfile,0,0,BASS_MUSIC_PRESCAN,0);
  if (songtype = stStream) then
     m := BASS_STREAMCREATEFILE(FALSE,info.SongFile,0,0,BASS_STREAM_PRESCAN);
  if (m <> 0) then
  begin
    BASS_CHANNELGetInfo(m,bi);
    info.SongTitle := pchar(ExtractFileName(info.songfile));
    info.pos := 0;
    info.len := trunc(BASS_CHANNELBYTES2SECONDS(m,BASS_CHANNELGETLENGTH(m)));
    info.PlaylistPos := 0;
    info.Playlistlen := 0;
    info.SampleRate := bi.freq;
    info.BitRate := bi.origres;
    info.Duration := trunc(BASS_CHANNELBYTES2SECONDS(m,BASS_CHANNELGETLENGTH(m)));
    info.Channels := bi.chans;
  end;
  if (songtype = stMusic) then
    BASS_MusicFree(m);
  if (songtype = stStream) then
    BASS_STREAMFREE(m);
end;

procedure TSong.MakeSongType;
var
  ext : String;

begin
  songtype := stNone;
  ext := Uppercase(ExtractFileExt(info.songfile));
  if (ext = '.MP3') or (ext = '.MP2') or (ext = '.MP1') or
     (ext = '.OGG') or (ext = '.WAV') or (ext = '.AIFF') then
    SongType := stStream;
  if (ext = '.MO3') or (ext = '.S3M') or (ext = '.MOD') or
     (ext = '.XM') or (ext = '.IT') or (ext = '.MTM') or
     (ext = '.UMX') then
    songType := stMusic;
end;

end.
