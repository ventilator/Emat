unit U_BassPlayer;

interface

uses
  bass, Windows, dialogs, Classes, StdCtrls, SysUtils, mmsystem;


type
  WAVHDR = packed record
    riff:  array[0..3] of Char;
    len: DWord;
    cWavFmt: array[0..7] of Char;
    dwHdrLen: DWord;
    wFormat: Word;
    wNumChannels: Word;
    dwSampleRate: DWord;
    dwBytesPerSec: DWord;
    wBlockAlign: Word;
    wBitsPerSample: Word;
    cData: array[0..3] of Char;
    dwDataLen: DWord;
  end;

  TFFTData = array[0..256] of Single;

  TBand = record
    par : BASS_FXPARAMEQ; // band of eq
    hnd : HFX; // band handle
  end;

  TBassPlayer = class
  private
    { Private declarations }


    WaveHdr: WAVHDR;  // WAV header
    recordchannel:   HRECORD;	// recording channel
    isrecording: boolean;
    EQenable: boolean;

    Modus: integer; //1= normal 2=mod Musik
    startmodplaytime: integer;
    procedure setvolume(volume: byte); //0 bis 100
    function getvolume: byte;
    function getposition: integer;
    procedure setposition(position: integer);
    function getlength: integer;        //in sekunden
    function getRightPeak: dword;
    function getLeftPeak: dword;
    function getstatus: integer;
    function getCPUusage: Single;
  public
  channel: HSTREAM; //Emat mod (war private)
    //Sachen für Equliser
    EQBand: array [1..10] of TBand;
    procedure updateEQ(Band1, Band2, Band3, Band4, Band5, Band6, Band7, Band8, Band9, Band10: integer);
    procedure initEQ;
    procedure removeEQ;

    constructor create(mainwindowhandle: HWND);
    destructor destroy; override;

    //Methoden fürs Internetradio
    function playNetStream(url: string): boolean;
    procedure getnetStreamInfo(ErgebnisListe: TStrings);

    //Methoden zum aufnehmen
    procedure startrecording(input: integer;filename: string);
    procedure stoprecording;
    function getDatasize: int64;
    procedure setrecordvolume(input: integer;volume: integer);
    procedure initCombobox(Combobox: TCombobox);
    procedure ComboBoxChange(Sender: TObject);

    function play(filename: string): boolean;
    procedure stop;
    procedure pause;
    procedure resume;
    property CPUusage: Single read getCPUusage;
    property volume: byte read getvolume write setvolume;    //0 bis 100
    property position: integer read getposition write setposition;{in sekunden}
    property length: integer read getlength;
    property RightPeak: dword read getRightPeak;   {von 0 bis 128}
    property LeftPeak: dword read getLeftPeak;     {von 0 bis 128}
    function getfftdata: TFFTData;
    property status: integer read getstatus; //STOPPED = 0   PLAYING = 1   STALLED = 2   PAUSED  = 3
    { Public declarations }
  end;

implementation

var
  WaveStream: TFileStream;//muss leider global deklariert werden wegen callback Funktion

function TBassPlayer.getfftdata: TFFTData;
begin
  if (BASS_ChannelGetData(Channel, @Result, BASS_DATA_FFT512) = 2048) = false then
  begin
    ZeroMemory(@Result, SizeOf(Result));
  end;
end;

function TBassPlayer.getstatus: integer;
begin //STOPPED = 0   PLAYING = 1   STALLED = 2   PAUSED  = 3
  result := BASS_ChannelIsActive(channel);
end;

function TBassPlayer.getRightPeak: dword;
begin
  result := HIWORD(BASS_ChannelGetLevel(channel));
end;

function TBassPlayer.getLeftPeak: dword;
begin
  result := LOWORD(BASS_ChannelGetLevel(channel));
end;

function TBassPlayer.getCPUusage: Single;
begin
  result:= BASS_GetCPU;
end;

function TBassPlayer.getvolume: byte;
begin
  IF Modus = 1 then result := BASS_GetConfig(BASS_CONFIG_GVOL_STREAM);
  IF Modus = 2 then result := BASS_MusicGetVolume(channel,0);
end;

procedure TBassPlayer.setvolume(volume: byte);
var
  Anzahlchannels,i: integer;
begin
  IF Modus = 1 then BASS_SetConfig(BASS_CONFIG_GVOL_STREAM,volume);
  IF Modus = 2 then
  begin
    Anzahlchannels := 0;
    while (BASS_MusicGetVolume(channel,Anzahlchannels)<>-1) do inc(Anzahlchannels);
    for i:=0 to Anzahlchannels do BASS_MusicSetVolume(channel,i,volume);
  end;
end;

function TBassPlayer.getposition: integer;
var
  uptime: integer;
begin
  IF Modus = 1 then result := round(BASS_ChannelBytes2Seconds(channel,BASS_ChannelGetPosition(channel)));
  IF Modus = 2 then
  begin
    uptime:= timegettime;
    result := (uptime - startmodplaytime) div 1000;
  end;
end;

procedure TBassPlayer.setposition(position: integer);
var
  pos: dword;
begin
  IF Modus = 1 then BASS_ChannelSetPosition(Channel,BASS_ChannelSeconds2Bytes(Channel, position));
  IF Modus = 2 then
  begin
    //BASS_MusicFree(channel);
    //pos:=
    //seektime := position;
    startmodplaytime := timegettime-(position*1000);
    pos := position or $FFFF0000;
    BASS_MusicPlayEx(channel,pos,BASS_MUSIC_RAMP or BASS_MUSIC_CALCLEN,false);
  end;
end;

function TBassPlayer.getlength: integer;
begin
  IF Modus = 1 then result := round(BASS_ChannelBytes2Seconds(channel,BASS_StreamGetLength(channel)));
  IF Modus = 2 then result := round(BASS_ChannelBytes2Seconds(channel,BASS_MusicGetLength(channel,true)));
end;

function TBassPlayer.play(filename: string): boolean;
var
  i: integer;
begin
  If BASS_ChannelIsActive(channel)=1 then
  begin
    IF Modus = 1 then BASS_StreamFree(channel);
    IF Modus = 2 then BASS_MusicFree(channel);
  end;

  IF (UpperCase(ExtractFileExt(FileName)) = '.MO3') or (UpperCase(ExtractFileExt(FileName)) = '.IT') or (UpperCase(ExtractFileExt(FileName)) = '.XM') or (UpperCase(ExtractFileExt(FileName)) = '.S3M') or (UpperCase(ExtractFileExt(FileName)) = '.MTM')or (UpperCase(ExtractFileExt(FileName)) = '.MOD') or (UpperCase(ExtractFileExt(FileName)) = '.UMX') then
  begin   //mod musik
    channel := BASS_MusicLoad(False, PChar(FileName), 0, 0, BASS_MUSIC_RAMP or BASS_MUSIC_CALCLEN, 0);
    result := BASS_MusicPlay(channel);
    startmodplaytime := timegettime;
    Modus := 2
  end
  else
  begin //wav/MP3 usw
    channel:=BASS_StreamCreateFile(False,PChar(filename),0,0, BASS_STREAM_AUTOFREE);
    result := BASS_StreamPlay(channel,false,0);
    Modus := 1;
  end;

  IF EQenable then
  begin
    for i:= low(EQBand) to high(EQBand) do
    begin
      EQBand[i].hnd := BASS_ChannelSetFX(channel, BASS_FX_PARAMEQ);  //Set the EQ objects to the stream
    end;

     //Apply EQ Settings to song
    for i:= low(EQBand) to high(EQBand) do
    begin
      //BASS_FXSetParameters(EQBand[i].hnd, @EQBand[i].par);
      IF not BASS_FXSetParameters(EQBand[i].hnd, @EQBand[i].par) then {showmessage('bass.dll meldet EQ-fehler') };
    end;
  end;

end;

function TBassPlayer.playNetStream(url: string): boolean;
begin
  If BASS_ChannelIsActive(channel)=1 then
  begin
    IF Modus = 1 then BASS_StreamFree(channel);
    IF Modus = 2 then BASS_MusicFree(channel);
  end;

  channel:= BASS_StreamCreateURL(PChar(url), 0, BASS_STREAM_META, nil, 0 );
  IF channel= 0 then showmessage('Das kann nicht abgespielt werden.');
  result := BASS_StreamPlay(channel,false,0);
end;

procedure TBassPlayer.stop;
begin
  BASS_ChannelPause(channel);
  IF Modus = 1 then position := 0;
end;

procedure TBassPlayer.pause;
begin
  BASS_ChannelPause(channel);
end;

procedure TBassPlayer.resume;
begin
  BASS_ChannelResume(channel);
end;

constructor TBassPlayer.create(mainwindowhandle: HWND);
begin
  inherited create;;
  if BASS_GetVersion() <> MAKELONG(2,0) then
  begin
    showmessage('Falsche Version der bass.dll(benötigt wird 2.0)');
    Halt;
  end;
  BASS_Init(1, 44100, 0, mainwindowhandle,nil);

  if not BASS_RecordInit(0) then
  begin
    BASS_RecordFree;
    BASS_Free();
    MessageDlg('Cannot start default recording device!', mtError, [mbOk], 0);
    halt;
  end;

  Modus :=1;

  EQenable := false;
  
  isrecording := false;
end;


destructor TBassPlayer.destroy;
begin
  BASS_RecordFree;

  Bass_streamFree(channel);
  BASS_MusicFree(channel);

  BASS_Stop;
  BASS_Free;
  inherited destroy;
end;

// This is called while recording audio
function RecordingCallback(Handle: HRECORD; buffer: Pointer; length, user: DWord): boolean; stdcall;
begin
  // Copy new buffer contents to the memory buffer
  WaveStream.Write(buffer^, length);
  //Allow recording to continue
  Result := True;
end;


procedure TBassPlayer.startrecording(input: integer;filename: string);
var
  i: Integer;
begin
  //File Stream
  WaveStream := TFileStream.Create(filename,fmCreate);


  if WaveStream.Size > 0 then
  begin	// free old recording
    BASS_StreamFree(channel);
  end;

  // generate header for WAV file
  WaveHdr.riff := 'RIFF';
  WaveHdr.len := 36;
  WaveHdr.cWavFmt := 'WAVEfmt ';
  WaveHdr.dwHdrLen := 16;
  WaveHdr.wFormat := 1;
  WaveHdr.wNumChannels := 2;
  WaveHdr.dwSampleRate := 44100;
  WaveHdr.wBlockAlign := 4;
  WaveHdr.dwBytesPerSec := 176400;
  WaveHdr.wBitsPerSample := 16;
  WaveHdr.cData := 'data';
  WaveHdr.dwDataLen := 0;

  WaveStream.Write(WaveHdr, SizeOf(WAVHDR));
  i := 0;
  while BASS_RecordSetInput(i, BASS_INPUT_OFF) do
  begin
    i := i + 1;
  end;
  BASS_RecordSetInput(input, BASS_INPUT_ON);

  // start recording @ 44100hz 16-bit stereo
  recordchannel := BASS_RecordStart(44100, 0, @RecordingCallback, 0);
  if recordchannel = 0 then
  begin
    MessageDlg('Couldn''t start recording!', mtError, [mbOk], 0);
    WaveStream.Free;
  end;

  isrecording:= true;
end;

procedure TBassPlayer.stoprecording;
var
  i: integer;
begin
  BASS_ChannelStop(recordchannel);

  // complete the WAV header
  WaveStream.Position := 4;
  i := WaveStream.Size - 8;
  WaveStream.Write(i, 4);
  i := i - $24;
  WaveStream.Position := 40;
  WaveStream.Write(i, 4);
  WaveStream.Position := 0;
  // create a stream from the recorded data
  //channel := BASS_StreamCreateFile(false, pchar(FRecordfilename), 0, WaveStream.Size, 0);

  {if channel = 0 then
  begin
    MessageDlg('Error creating stream from recorded data!', mtError, [mbOk], 0);
  end;}
  WaveStream.Free;
end;

function TBassPlayer.getDatasize: int64;
begin
  IF isrecording then
  begin
    result:= WaveStream.Size
  end
  else
  begin
    result:=0;
  end;
end;

procedure TBassPlayer.setrecordvolume(input: integer;volume: integer);
begin
  BASS_RecordSetInput(input, BASS_INPUT_LEVEL or volume);
end;

procedure TBassPlayer.initEQ;
var
  i: integer;
begin

  for i:= low(EQBand) to high(EQBand) do
  begin
    EQBand[i].hnd := BASS_ChannelSetFX(channel, BASS_FX_PARAMEQ);  //Set the EQ objects to the stream
    EQBand[i].par.fBandwidth := 18;
    EQBand[i].par.fGain := 0;   //Wert zwichen -15 und 15
  end;

  EQBand[1].par.fCenter := 80;
  EQBand[2].par.fCenter := 170;
  EQBand[3].par.fCenter := 310;
  EQBand[4].par.fCenter := 600;
  EQBand[5].par.fCenter := 1000;
  EQBand[6].par.fCenter := 3000;
  EQBand[7].par.fCenter := 6000;
  EQBand[8].par.fCenter := 10000;
  EQBand[9].par.fCenter := 12000;
  EQBand[10].par.fCenter := 14000;

  //Apply EQ Settings to song
  for i:= low(EQBand) to high(EQBand) do
  begin
    //BASS_FXSetParameters(EQBand[i].hnd, @EQBand[i].par);
    BASS_FXSetParameters(EQBand[i].hnd, @EQBand[i].par);
  end;

  EQenable:=true;
end;

procedure TBassPlayer.removeEQ;
var
  i: integer;
begin
  for i:= low(EQBand) to high(EQBand) do
  begin
    BASS_ChannelRemoveFX(channel, EQBand[i].hnd);
  end;
  
  EQenable:=false;
end;

procedure TBassPlayer.updateEQ(Band1, Band2, Band3, Band4, Band5, Band6, Band7, Band8, Band9, Band10: integer);
var
  i: integer;
begin
  IF self.status=0 then exit; //PLayer im stop modus also nicht verändern
  EQBand[1].par.fgain := Band1;
  EQBand[2].par.fgain := Band2;
  EQBand[3].par.fgain := Band3;
  EQBand[4].par.fgain := Band4;
  EQBand[5].par.fgain := Band5;
  EQBand[6].par.fgain := Band6;
  EQBand[7].par.fgain := Band7;;
  EQBand[8].par.fgain := Band8;
  EQBand[9].par.fgain := Band9;
  EQBand[10].par.fgain := Band10;


  /// Update Band Settings
  for i:= low(EQBand) to high(EQBand) do
  begin
    IF not BASS_FXSetParameters(EQBand[i].hnd, @EQBand[i].par) then showmessage('bass.dll meldet EQupdatefehler')
  end;
end;

procedure TBassPlayer.ComboBoxChange(Sender: TObject);
begin

end;

procedure TBassPlayer.getnetStreamInfo(ErgebnisListe: TStrings);
begin

end;

procedure TBassPlayer.initCombobox(Combobox: TCombobox);
begin

end;

end.
