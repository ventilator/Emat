unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Bass, BassVis, ExtCtrls, StdCtrls, ComCtrls, FileCtrl, WinampMsg,
  StrUtils;

type
  TfrmMain = class(TForm)
    Button3:      TButton;
    Button1:      TButton;
    Button2:      TButton;
    Label3:       TLabel;
    TrackBar1:    TTrackBar;
    Label4:       TLabel;
    TrackBar2:    TTrackBar;
    Label5:       TLabel;
    TrackBar3:    TTrackBar;
    ListBox1:     TListBox;
    Label2:       TLabel;
    VisTimer1:    TTimer;
    Button4:      TButton;
    GroupBox1:    TGroupBox;
    Label6:       TLabel;
    lblWHandle:   TLabel;
    Label7:       TLabel;
    lblPHandle:   TLabel;
    GroupBox2:    TGroupBox;
    Button5:      TButton;
    Button6:      TButton;
    InfoTimer1:   TTimer;
    Edit1:        TEdit;
    Label8:       TLabel;
    lblGenHandle: TLabel;
    lblCounter:   TLabel;
    Label10:      TLabel;
    Panel1:       TPanel;
    CheckBox2:    TCheckBox;
    GroupBox3:    TGroupBox;
    Label1:       TLabel;
    Label9:       TLabel;
    TrackBar4:    TTrackBar;
    ComboBox1:    TComboBox;
    ComboBox2:    TComboBox;
    GroupBox4:    TGroupBox;
    optGen:       TRadioButton;
    optPanel:     TRadioButton;
    optDefault:   TRadioButton;
    lblLevel: TLabel;
    Label11: TLabel;
    lblRenderT: TLabel;
    TrackBar5: TTrackBar;
    procedure TrackBar5Change(Sender: TObject);
    procedure optGenClick(Sender: TObject);
    procedure optDefaultClick(Sender: TObject);
    procedure optPanelClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ComboBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure VisTimer1Timer(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure InfoTimer1Timer(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Delay(Milliseconds: Integer);
  private
    { Private declarations }
    chan:    HRECORD;
    vislist: TStringList;
    modlist: TStringList;
  public

  end;

var
  frmMain:     TfrmMain;
  hWndWinAMP:  DWORD;
  MediaTitle:  TCaption;
  hWndGen:     DWORD;
  RCounter:    DWORD;
  PluginDir:   string;
  vischan:     HVIS;
  lHwndParent: Hwnd;

implementation

uses frmGen;

{$R *.dfm}

// recording callback
function RecordCallback(handle: HRECORD; buffer: Pointer; length: DWORD;
  user: DWORD): BOOL; stdcall;
begin
  Result := True; // keep recording
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  i:  DWORD;
  it: integer;

begin

  // check the correct BASS was loaded
  if (HIWORD(BASS_GetVersion) <> BASSVERSION) then
  begin
    MessageBox(0, 'An incorrect version of BASS.DLL was loaded', nil, MB_ICONERROR);
    Halt;
  end;

  if not BASS_RecordInit(0) then
  begin
    MessageBox(0, 'Cant initialize device', 'Error', 0);
    Halt;
  end;

  chan := BASS_RecordStart(44100, 1, BASS_SAMPLE_MONO, nil, 0);
  if (chan = 0) then
  begin
    MessageBox(0, 'Cant start recording', 'Error', 0);
    Halt;
  end;

  i := 0;
  while (BASS_RecordGetInputName(i) <> nil) do
  begin
    ComboBox1.Items.Add(BASS_RecordGetInputName(i));
    i := i + 1;
  end;

  ComboBox1.ItemIndex := 0;
  it := BASS_RecordGetInput(ComboBox1.ItemIndex);
  TrackBar4.Position := LoWord(it);
  TrackBar5.Position := 25;
  TrackBar1.Position := 3;

  // create an invisible list with all the vis filenames
  vislist := TStringList.Create;
  modlist := TStringList.Create;

end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  vislist.Free;
  modlist.Free;

  // NEVER forget to free the resources...
  BASS_WINAMPVIS_Free(vischan, 0);
  BASS_RecordFree;
end;

procedure TfrmMain.VisTimer1Timer(Sender: TObject);
begin
  // try to render our vis
  // if none loaded, then it wont do anything...
  BASS_WINAMPVIS_Render(vischan, chan);
end;


procedure TfrmMain.ComboBox1Click(Sender: TObject);
var
  i:  integer;
  it: integer;
begin
  // change current record input
  for i := 0 to ComboBox1.Items.Count - 1 do
    if (i = ComboBox1.ItemIndex) then
      BASS_RecordSetInput(i, BASS_INPUT_ON)
    else
      BASS_RecordSetInput(i, BASS_INPUT_OFF);

  it := BASS_RecordGetInput(ComboBox1.ItemIndex);
  TrackBar4.Position := LoWord(it);
end;

procedure TfrmMain.Button3Click(Sender: TObject);
var
  i, x     : integer;
  tmpvis   : HVIS;
  tmpname  : string;
  DefName  : string;
  flist    : TStringList;

begin

  ListBox1.Clear;
  
  if not SelectDirectory('Select Winamp Visualization dir', 'desktop', PluginDir) then
    exit;

  // create temp list for new list of vis
  flist := TStringList.Create;

  // find out vis plugins
  flist.CommaText := BASS_VIS_FindPlugins(PChar(PluginDir),
    BASS_VIS_FIND_WINAMP or BASS_VIS_FIND_RECURSIVE or BASS_VIS_FIND_COMMALIST);

  // add the new ones at the end of both lists
  for i := 0 to flist.Count - 1 do
  begin
    x      := 0;
    tmpvis := BASS_WINAMPVIS_CreateVis(PChar(flist[i]), x, BASS_VIS_NOINIT, 0, False, 0);
    while (tmpvis <> 0) do
    begin
      tmpname := BASS_WINAMPVIS_GetName(tmpvis);
      if not (tmpname = DefName) then
      begin
        vislist.Add(flist[i]);
        ListBox1.Items.Add(tmpname);
        DefName := tmpname;
      end;

      BASS_WINAMPVIS_Free(tmpvis, 0);

      Inc(x);
      tmpvis := BASS_WINAMPVIS_CreateVis(PChar(flist[i]), x, BASS_VIS_NOINIT,
        0, False, 0);
    end;
  end;

  flist.Free;
  ListBox1.ItemIndex := 0;
  ListBox1Click(Sender);
  frmMain.Button1.Enabled := True;
  frmMain.Button2.Enabled := True;
  frmMain.Button4.Enabled := True;

end;

procedure TfrmMain.Button1Click(Sender: TObject);

var
  ISPlaying: DWORD;
  Bufferlength: integer;
  Buffer: array [0..MAX_PATH] of char;

begin
  // check if we have something selected on the list
  if (ListBox1.ItemIndex >= 0) and (ListBox1.ItemIndex < ListBox1.Count) then
  begin
    // create our new plugin
    if optPanel.Checked or optGen.Checked = True then
    begin
      vischan := BASS_WINAMPVIS_CreateVis(PChar(vislist[ListBox1.ItemIndex]),
        StrToInt(modlist[ComboBox2.ItemIndex]), 0, frmMain.Handle, True, 0);
    end
    else if optDefault.Checked = True then
    begin
      vischan := BASS_WINAMPVIS_CreateVis(PChar(vislist[ListBox1.ItemIndex]),
        StrToInt(modlist[ComboBox2.ItemIndex]), 0, frmMain.Handle, False, 0);
    end;

    if vischan <> 0 then
    begin
      hWndWinAMP := 0;
      // Get HWND from Winamp Dummy Window
      repeat
        hWndWinAMP := BASS_WINAMPVIS_GetAmpHwnd;
      until hWndWinAMP <> 0;

      if optPanel.Checked = True then
      begin
        //Give D3D Plugin time for Render
        repeat
          hWndGen := BASS_WINAMPVIS_GetGenHwnd;
          Inc(RCounter);
          lblCounter.Caption := IntToStr(RCounter);
        until (hWndGen <> 0) or (RCounter = 32000); //ms

        if hWndGen <> 0 then
        begin
          lHwndParent := GetWindow(hWndGen, GW_CHILD);
          Windows.SetParent(lHwndParent, Panel1.Handle);
          MoveWindow(lHwndParent, 5, 5, Panel1.Width - 10, Panel1.Height - 10, True);
        end;
      end;

      if optGen.Checked = True then
      begin
        //Give D3D Plugin time for Render
        repeat
          hWndGen := BASS_WINAMPVIS_GetGenHwnd;
          Inc(RCounter);
          lblCounter.Caption := IntToStr(RCounter);
        until (hWndGen <> 0) or (RCounter = 32000); //ms

        if hWndGen <> 0 then
        begin
          //read Caption from Plugin
          Bufferlength := GetWindowTextLength(hWndGen);
          GetWindowText(hWndGen, Buffer, Bufferlength + 1);
          // load skin/setting/position
          frm_Gen.FormShow(Sender);
          //set String
          frm_Gen.picTopText.Width :=
            frm_Gen.GetBitArray(LeftStr(Buffer, Bufferlength)) + 15;
          //Form Gen resizen
          frm_Gen.FormResize(Sender);

          //Set Width/Height on 'frm_Gen.PBack'
          lHwndParent := GetWindow(hWndGen, GW_CHILD);
          if lHwndParent <> 0 then
          begin
            Windows.SetParent(lHwndParent, frm_Gen.PBack.handle);
            MoveWindow(lHwndParent, 0, 0, frm_Gen.PBack.Width, frm_Gen.PBack.Height, True);
          end;
          //Skin show
          frm_Gen.Show;
        end;
      end;

      // SendMessage Playing Status
      SendMessage(hWndWinAMP, WM_COMMAND, WINAMP_BUTTON2, 0);

      // Check IsPlaying
      ISPlaying := SendMessage(hWndWinAMP, WM_WA_IPC, 0, IPC_ISPLAYING);

      // Result 1 RenderTimer activate
      if ISPlaying = 1 then
      begin
        Edit1.Text := 'Hmmmmm was is`sen nu? Playing';

        InfoTimer1.Enabled := True;
        VisTimer1.Enabled  := True;
      end;

      lblWHandle.Caption   := IntToStr(hWndWinAMP);
      lblPHandle.Caption   := IntToStr(BASS_WINAMPVIS_GetVisHwnd);
      lblGenHandle.Caption := IntToStr(BASS_WINAMPVIS_GetGenHwnd);
      Button1.Enabled      := False;
      Button5.Enabled      := True;
      Button6.Enabled      := True;
    end;
  end;
end;

procedure TfrmMain.Button2Click(Sender: TObject);

begin
  RCounter := 0;
  if hWndWinAMP <> 0 then
  begin
    // Timer disabled
    VisTimer1.Enabled  := False;
    InfoTimer1.Enabled := False;

    // Check for GenHwnd
    // and move Visualize Window back to Dummy GenWindow
    repeat
      hWndGen := BASS_WINAMPVIS_GetGenHwnd;
      Inc(RCounter);
      lblCounter.Caption := IntToStr(RCounter);
    until (hWndGen <> 0) or (RCounter = 32000); //ms

    if hWndGen <> 0 then
    begin
      if frm_Gen.Visible = True then
      begin
        lHwndParent := GetWindow(frm_Gen.PBack.Handle, GW_CHILD);
      end else
        lHwndParent := GetWindow(Panel1.Handle, GW_CHILD);

      if lHwndParent <> 0 then
        // Plugin back to Dummy GenWindow.
        Windows.SetParent(lHwndParent, hWndGen);
    end;

    if frm_Gen.Visible = True then
    begin
      frm_Gen.Hide;
      frm_Gen.Close;
      frm_Gen.FormDestroy(Sender);
      Delay(150);
    end;

    BASS_WINAMPVIS_Free(VisChan, 0);
    vischan := 0;

    Button1.Enabled := True;
    Edit1.Text      := 'stopped nix mehr';
    lblCounter.Caption := IntToStr(0);
    lblWHandle.Caption := IntToStr(0);
    lblPHandle.Caption := IntToStr(0);
    lblGenHandle.Caption := IntToStr(0);
  end;
end;



procedure TfrmMain.TrackBar1Change(Sender: TObject);
begin
  BASS_VIS_SetConfig(BASS_VIS_CONFIG_FFTAMP, TrackBar1.Position);
end;



procedure TfrmMain.TrackBar2Change(Sender: TObject);
begin
  BASS_VIS_SetConfig(BASS_VIS_CONFIG_FFT_SKIPCOUNT, TrackBar2.Position);
end;



procedure TfrmMain.TrackBar3Change(Sender: TObject);
begin
  BASS_VIS_SetConfig(BASS_VIS_CONFIG_WAVE_SKIPCOUNT, TrackBar3.Position);
end;



procedure TfrmMain.TrackBar4Change(Sender: TObject);
begin
  BASS_RecordSetInput(ComboBox1.ItemIndex, BASS_INPUT_LEVEL or TrackBar4.Position);
  lblLevel.Caption := IntToStr(TrackBar4.Position);
end;



procedure TfrmMain.TrackBar5Change(Sender: TObject);
begin
  VisTimer1.Interval := TrackBar5.Position;
  LblRenderT.Caption := IntToStr(TrackBar5.Position);
end;



procedure TfrmMain.Button4Click(Sender: TObject);
var
  tmpvis: HVIS;
begin

  tmpvis := BASS_WINAMPVIS_CreateVis(PChar(vislist[ListBox1.ItemIndex]),
    StrToInt(modlist[ComboBox2.ItemIndex]),
    BASS_VIS_NOINIT, 0, False, 0);
  BASS_WINAMPVIS_Config(tmpvis);

end;



procedure TfrmMain.Button5Click(Sender: TObject);
var
  ISPlaying: DWORD;

begin

  // SendMessage Playing Status Stop
  SendMessage(hWndWinAMP, WM_COMMAND, WINAMP_BUTTON4, 0);

  // Check Status
  ISPlaying := SendMessage(hWndWinAMP, WM_WA_IPC, 0, IPC_ISPLAYING);
  if ISPlaying = 0 then
  begin
    Edit1.Text := 'stopped hihihihihi no render !!!!';
  end;
end;

procedure TfrmMain.Button6Click(Sender: TObject);
var
  ISPlaying: DWORD;

begin
  // Get HWND from Winamp Dummy Window
  repeat
    hWndWinAMP := BASS_WINAMPVIS_GetAmpHwnd;
  until hWndWinAMP <> 0;

  // SendMessage Playing Status Play
  SendMessage(hWndWinAMP, WM_COMMAND, WINAMP_BUTTON2, 0);

  // Check Status
  ISPlaying := SendMessage(hWndWinAMP, WM_WA_IPC, 0, IPC_ISPLAYING);

  if ISPlaying = 1 then
  begin
    Edit1.Text := 'Playing hehehehehe !!!!';
    InfoTimer1.Enabled := True;
    VisTimer1.Enabled := True;
  end;
end;


procedure TfrmMain.InfoTimer1Timer(Sender: TObject);
begin
  if MediaTitle <> '' then
    BASS_WINAMPVIS_SetChanInfo(vischan, PAnsiChar(MediaTitle),
      PAnsiChar(MediaTitle), 250, 1800, 7, 20);
end;

procedure TfrmMain.ListBox1Click(Sender: TObject);
var
  ModuleName: string;
  module:     integer;
  tmpvis:     HVIS;

begin

  ComboBox2.Clear;

  module := 0;
  repeat
    tmpvis     := BASS_WINAMPVIS_CreateVis(PChar(vislist[ListBox1.ItemIndex]),
      module, BASS_VIS_NOINIT, 0, False, 0);
    ModuleName := BASS_WINAMPVIS_GetModuleName(tmpvis);

    if tmpvis <> 0 then
    begin
      ComboBox2.Items.Add(ModuleName);
      modlist.Add(IntToStr(module));
    end;

    BASS_WINAMPVIS_Free(tmpvis, 0);
    Inc(module);

  until tmpvis = 0;
  ComboBox2.ItemIndex := 0;

end;


procedure TfrmMain.Delay(Milliseconds: Integer);
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
      if Application.Terminated then Exit; 
      Milliseconds := Tick - GetTickcount; 
    end; 
  finally 
    CloseHandle(Event); 
  end; 
end;


procedure TfrmMain.optDefaultClick(Sender: TObject);
begin
  // Terminate Plugin
  frmMain.Button2Click(Sender);
  // Wait befor new Plugin run.
  Delay(200);

  frmMain.Button1Click(Sender);
  // Wait new Plugin initialized
  Delay(200);
  // Play
  frmMain.Button6Click(Sender);
end;

procedure TfrmMain.optGenClick(Sender: TObject);
begin
  // Terminate Plugin
  frmMain.Button2Click(Sender);
  // Wait befor new Plugin run.
  Delay(200);

  frmMain.Button1Click(Sender);
  // Wait new Plugin initialized
  Delay(200);
  // Play
  frmMain.Button6Click(Sender);
end;

procedure TfrmMain.optPanelClick(Sender: TObject);
begin
  // Terminate Plugin
  frmMain.Button2Click(Sender);
  // Wait befor new Plugin run.
  Delay(200);

  frmMain.Button1Click(Sender);
  // Wait new Plugin initialized
  Delay(200);
  // Play
  frmMain.Button6Click(Sender);
end;

procedure TfrmMain.Edit1Change(Sender: TObject);
begin
  MediaTitle := Edit1.Text;
end;

end.
