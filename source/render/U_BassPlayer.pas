unit U_BassPlayer;

{
  U_BassPlayer

  Orginal von Delphi-Praxis-User dizzy (Fabian)

  Bearbeitet von Der_Ventilator für Emat

    - Unterstützung für bass.dll ver. 2.2
    - Pluginsystem
    - (GetLength Abfragesicherung)
}


interface

uses bass, Windows, dialogs, SysUtils, ComCtrls;
 

type
  TFFTData = array[0..512] of float;
  TFFTDataLong = array[0..2048] of float;
  TWaveData = array[0..2048] of smallint;
  TWaveDataLong = array[0..8192] of smallint;
  TBassPlayer = class
  private
    { Private declarations }
    channel: HCHANNEL;
    FFilename: string;
    procedure setvolume(volume: byte); {0 bis 100}
    procedure setposition(position: float);
    function getvolume: byte;
    function getposition: float;
    function getlength: float; {in Sekunden}
    function getRightPeak: dword;
    function getLeftPeak: dword;
  public
    freewithoutbassfree: boolean;

    constructor create(mainwindowhandle: HWND);
    destructor Destroy; override;
    function play: boolean;
    procedure setFileToPlay(filename: string);
    function getfftdata: TFFTData;
    function getfftdatalong: TFFTDataLong;
    function getwavedata: TWaveData;
    function getwavedatalong: TWaveDataLong;
    function getstatus: byte;
    procedure stop;
    procedure pause;
    procedure resume;

    property volume: byte read getvolume write setvolume;
    property position: float read getposition write setposition;{in sekunden}
    property length: float read getlength;
    property RightPeak: dword read getRightPeak;   {von 0 bis 128}
    property LeftPeak: dword read getLeftPeak;     {von 0 bis 128}
    property filename: string read FFilename;
    property status: byte read getstatus; //STOPPED = 0   PLAYING = 1   STALLED = 2   PAUSED  = 3
    { Public declarations }
  end;

implementation

function TBassPlayer.getfftdata: TFFTData;
begin
  if (BASS_ChannelGetData(Channel, @Result, BASS_DATA_FFT512 or BASS_DATA_FFT_INDIVIDUAL) = 2048) = false then
  begin
    ZeroMemory(@Result, SizeOf(Result));
  end;
end;

function TBassplayer.getfftdatalong: TFFTDataLong;
begin
  BASS_ChannelGetData(Channel, @Result, BASS_DATA_FFT2048 or BASS_DATA_FFT_INDIVIDUAL);
end;

function TBassPlayer.getwavedata: TWaveData;
begin
  Bass_ChannelGetData(Channel, @result, 2048);
end;

function TBassPlayer.getwavedatalong: TWaveDataLong;
begin
  Bass_ChannelGetData(Channel, @result, 8192);
end;

function TBassPlayer.getstatus: byte;
var
  zspeicher: dword;
begin //STOPPED = 0   PLAYING = 1   STALLED = 2   PAUSED  = 3
  zspeicher := BASS_ChannelIsActive(channel);
  if (zspeicher<100) then result := zspeicher
  else result := 0;

  {Damit es keien Probleme mit DWord und byte gibt}
end;

function TBassPlayer.getRightPeak: dword;
begin
 // result := HIWORD(BASS_ChannelGetLevel(channel));
  result := round(HIWORD(BASS_ChannelGetLevel(channel)));
 //wir teilen durch 256, weil bass 2.2 anscheinend den peak 256 mal so groß als 2.0
 // ausgibt (Schätzwert!)
end;

function TBassPlayer.getLeftPeak: dword;
begin
 // result := LOWORD(BASS_ChannelGetLevel(channel));
  result := round(LOWORD(BASS_ChannelGetLevel(channel)));
end;

function TBassPlayer.getvolume: byte;
begin
  result := BASS_GetConfig(BASS_CONFIG_GVOL_STREAM);
end;

procedure TBassPlayer.setvolume(volume: byte);
begin
  BASS_SetConfig(BASS_CONFIG_GVOL_STREAM, volume)
end;


function TBassPlayer.getposition: float;
begin
   result := BASS_ChannelBytes2Seconds(channel,BASS_ChannelGetPosition(channel));
end;

procedure TBassPlayer.setposition(position: float);
begin
  BASS_ChannelSetPosition(Channel,BASS_ChannelSeconds2Bytes(Channel, position));
end;

function TBassPlayer.getlength: float;
begin
  result:=0;
  if BASS_ChannelIsActive(channel)=1 then
  result := BASS_ChannelBytes2Seconds(channel,BASS_ChannelGetLength(channel));
end;


procedure TBassPlayer.setFileToPlay(filename: string);
begin
  if BASS_ChannelIsActive(channel)=1 then
  begin
    BASS_StreamFree(channel);
  end;
  FFilename := filename;

  channel:= BASS_StreamCreateFile(False, PChar(filename), 0, 0, BASS_STREAM_AUTOFREE or BASS_SAMPLE_FX);
end;

function TBassPlayer.play: boolean;
begin
  result := BASS_ChannelPlay(channel, false);
end;

procedure TBassPlayer.stop;
begin
  BASS_StreamFree(channel);
end;

procedure TBassPlayer.pause;
begin
  BASS_ChannelPause(channel);
end;

procedure TBassPlayer.resume;
begin
  BASS_ChannelPlay(channel,false);
end;

constructor TBassPlayer.create(mainwindowhandle: HWND);
var i    : integer;
    sRec : TSearchRec;

  fd: TWin32FindData;
  fh: THandle;
  plug: HPLUGIN;
  Info: PBass_PluginInfo;
  s: string;
  a: integer;
  ListItem: TListItem;

begin
  inherited create;

  // init bass
  if BASS_GetVersion <> 33751042 then//33751042= bass.dll version 2.3  MAKELONG(2,2) = 2.2; k.A. was das heißt
  begin
    showmessage('Leider konnte Emat nicht gestartet werden, da es die bass.dll in Version 2.2 benötigt.');
    Halt;
  end;

  if not Bass_Init(-1, 44100, 0, mainwindowhandle, nil) then
  begin    {das wird bei jedem Hinzufügen aufgerufen um Dateilänge mittels Bass.dll zu ermitteln
    showmessage('Das Audiowiedergabesystem konnte leider nicht gestartet werden.'+#13+
                 'Emat wird sich jetzt beenden.');
    Halt;  }
  end;

  //Plugins laden
//  // Set The OpenDialog Filter to the Bass build In Formats
//  Open1.Filter :=
//    'BASS built-in *.mp3;*.mp2;*.mp1;*.ogg;*.wav;*.aif)\0*.mp3;*.mp2;*.mp1;*.ogg;*.wav;*.aif' + '|'
//    + '*.mp3;*.mp2;*.mp1;*.ogg;*.wav*;*.aif';

  // get the Modules from the currentDirectory
  fh := FindFirstFile(PChar('plugins\'+ 'bass*.dll'), fd);
  if (fh <> INVALID_HANDLE_VALUE) then
  try
    repeat
      plug := BASS_PluginLoad(pchar('plugins\'+fd.cFileName), 0);
      if Plug <> 0 then
      begin
        Info := BASS_PluginGetInfo(Plug); // get plugin info to add to the file selector filter...
        for a := 0 to Info.formatc - 1 do
        begin
  //        // Set The OpenDialog additional, to the supported PlugIn Formats
  //        open1.Filter := Open1.Filter + '|' + Info.Formats[a].name + ' ' + '(' +
  //          Info.Formats[a].exts + ') , ' + fd.cFileName + '|' + Info.Formats[a].exts;
          // Lets Show in the Listview the supported Formats

          if (Info.Formats[a].name <> nil) then
            if (a = 0) then
              s :=Info.Formats[a].name
            else
              s := s + ',' + Info.Formats[a].name;
        end;
  {      ListItem := ListView_PlugIns.Items.Add;
        ListItem.Caption := fd.cFileName;
        ListItem.SubItems.Add(s);               }
      end;
    until FindNextFile(fh, fd) = false;
  finally
    Windows.FindClose(fh);
  end;

{  if Listview_PlugIns.Items.Count = 0 then
  begin
    ListItem := ListView_PlugIns.Items.Add;
    ListItem.SubItems.Add('no plugins found - visit the BASS webpage to get some');
  end;  }

  //
{  Bass22.dll PluginLoadCode
  // plugin loaded...
  i := FindFirst('plugins\'+'bass*.dll', faAnyFile, sRec);
  while i = 0 do
  begin
    //if sRec.Name<>'bass.dll' then
    BASS_PluginLoad(pchar('plugins\'+sRec.Name));
    i := FindNext(sRec);
  end;
  FindClose(sRec);
  //
 }
  freewithoutbassfree:=false;
end;


destructor TBassPlayer.destroy;
begin
  Bass_streamFree(channel);
  if not freewithoutbassfree
  then
    begin
      BASS_Stop;
      BASS_Free;
      BASS_PluginFree(0);
    end;
  inherited destroy;
end;

end.
