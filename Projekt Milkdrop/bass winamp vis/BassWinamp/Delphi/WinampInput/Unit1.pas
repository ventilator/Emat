unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileCtrl, Bass, BassWinamp, ExtCtrls;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    ScrollBar1: TScrollBar;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    Button5: TButton;
    Button6: TButton;
    Timer1: TTimer;
    Button7: TButton;
    Button8: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ScrollBar1Scroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
  private
    { Private declarations }
    Channel: HSTREAM;
    PluginCount: Integer;
    lstPlugins: array[0..255] of HPLUGIN;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  // Reset plugin count to zero
  PluginCount := 0;
  // Reset all the plugin handles to zero
  for i := 0 to 255 do
    lstPlugins[i] := 0;

  // Our usual Bass stuff
  BASS_Init(1, 44100, 0, Form1.Handle, nil);
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  // Free previous chan in case it was created...
  // Make sure you free the channels, otherwise some
  // plugins will freeze your APP...
  BASS_StreamFree(Channel);

  // Unload all previously loaded plugins
  for i := 0 to PluginCount - 1 do
    BASS_WINAMP_UnloadPlugin(lstPlugins[i]);

  // Free bass
  BASS_Free;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i: Integer;
  sDir: String;
  fList: TStringList;
  TmpPlugin: HPLUGIN;
begin
  // check if we have the plugin handle list already maxed out
  if (PluginCount = 256) then
    Exit;

  // choose the dir to search
  if SelectDirectory('Select directory to search for input plugins', 'DESKTOP', sDir) = False then
    Exit;

  fList := TStringList.Create;

  fList.CommaText := BASS_WINAMP_FindPlugins(PChar(sDir), BASS_WINAMP_FIND_INPUT or BASS_WINAMP_FIND_RECURSIVE or BASS_WINAMP_FIND_COMMALIST);

  for i := 0 to fList.Count - 1 do
  begin
    // load our plugin
    TmpPlugin := BASS_WINAMP_LoadPlugin(PChar(fList[i]));
    // check if a valid handle was returned
    if (TmpPlugin <> 0) then
    begin
      // add the new plugin as our last one in the list
      lstPlugins[PluginCount] := TmpPlugin;
      // increment our plugin count
      PluginCount := PluginCount + 1;

      // add the name to the list box
      ListBox1.Items.Add(StrPas(BASS_WINAMP_GetName(TmpPlugin)));
    end;
  end;

  fList.Free;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  // open plugin's config window
  if (ListBox1.ItemIndex >= 0) and (ListBox1.ItemIndex < ListBox1.Items.Count) then
    BASS_WINAMP_ConfigPlugin(lstPlugins[ListBox1.ItemIndex], Form1.Handle);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  // display plugin's about
  if (ListBox1.ItemIndex >= 0) and (ListBox1.ItemIndex < ListBox1.Items.Count) then
    BASS_WINAMP_AboutPlugin(lstPlugins[ListBox1.ItemIndex], Form1.Handle);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i: Integer;
  FileExtentions: PChar;
begin
  // Free previous chan
  BASS_StreamFree(Channel);

  OpenDialog1.Filter := '';
  for i := 0 to PluginCount - 1 do
  begin
    // Filter Name|*.fil|Filter Name2|*.fil2
    FileExtentions := BASS_WINAMP_GetExtentions(lstPlugins[i]);
    while (FileExtentions^ <> #0) do
    begin
      OpenDialog1.Filter := OpenDialog1.Filter + FileExtentions + '|';
      FileExtentions := PChar(FileExtentions + Length(FileExtentions) + 1);
    end;
  end;
  // open file
  if (not OpenDialog1.Execute) then
    Exit;

  // Create our stream, just like a regular BASS_StreamCreateFile
  Channel := BASS_WINAMP_StreamCreate(PChar(OpenDialog1.FileName), BASS_SAMPLE_FLOAT);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  // The rest is just like any other regular stream
  if (BASS_ChannelIsActive(Channel) = BASS_ACTIVE_PLAYING) then
    BASS_ChannelPause(Channel)
  else if (BASS_ChannelIsActive(Channel) = BASS_ACTIVE_PAUSED) then
    BASS_ChannelPlay(Channel, False);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  // The rest is just like any other regular stream
  BASS_ChannelStop(Channel);
  BASS_StreamFree(Channel);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  Pos, Len: Integer;
begin
  // The rest is just like any other regular stream
  Pos := Trunc(BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetPosition(Channel)));
  Len := Trunc(BASS_ChannelBytes2Seconds(Channel, BASS_StreamGetLength(Channel)));

  if (Pos < 0) then
    Pos := 0;
  if (Len < 0) then
    Len := 0;

  Label1.Caption := IntToStr(Pos) + ' / ' + IntToStr(Len);

  if (BASS_ChannelIsActive(Channel) = BASS_ACTIVE_STOPPED) then
    Label1.Caption := Label1.Caption + ' (Stopped)'
  else if (BASS_ChannelIsActive(Channel) = BASS_ACTIVE_PLAYING) then
    Label1.Caption := Label1.Caption + ' (Playing)'
  else if (BASS_ChannelIsActive(Channel) = BASS_ACTIVE_STALLED) then
    Label1.Caption := Label1.Caption + ' (Stalled)'
  else if (BASS_ChannelIsActive(Channel) = BASS_ACTIVE_PAUSED) then
    Label1.Caption := Label1.Caption + ' (Paused)';

  ScrollBar1.Max := Len;
  ScrollBar1.Position := Pos;
end;

procedure TForm1.ScrollBar1Scroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  if (ScrollCode = scEndScroll) then
  begin
    // The rest is just like any other regular stream
    BASS_ChannelSetPosition(Channel, BASS_ChannelSeconds2Bytes(Channel, ScrollPos));
    Timer1.Enabled := True;
  end
  else
    Timer1.Enabled := False;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  BASS_WINAMP_InfoDlg(PChar(OpenDialog1.FileName), Form1.Handle);
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  BASS_ChannelPreBuf(Channel);
  BASS_ChannelPlay(Channel, True);
end;

end.
