program test_bass;
{ Pruefstand: laedt bass.dll + BASS-Addons und oeffnet Testdateien direkt
  (ohne Emat-Oberflaeche). Zeigt Kanal, Laenge, Status, BASS-Fehlercode.
  Aufruf im Ordner mit bass.dll, test.mp3, test.wma. }
{$mode delphi}{$H+}

uses
  SysUtils, bass;

const
  FileNames: array[0..2] of string = ('test.mp3', 'test.wma', 't1.wma');

function ActiveText(H: HSTREAM): string;
begin
  case BASS_ChannelIsActive(H) of
    BASS_ACTIVE_STOPPED: Result := 'stopped';
    BASS_ACTIVE_PLAYING: Result := 'playing';
    BASS_ACTIVE_STALLED: Result := 'stalled';
    BASS_ACTIVE_PAUSED : Result := 'paused';
  else
    Result := '?';
  end;
end;

var
  I: Integer;
  H: HSTREAM;
  Info: BASS_CHANNELINFO;
  Len: Int64;
  Plugin: HPLUGIN;

begin
  WriteLn('bass.dll version : $', IntToHex(BASS_GetVersion, 8));
  if not BASS_Init(-1, 44100, 0, 0, nil) then
  begin
    WriteLn('BASS_Init failed, error=', BASS_ErrorGetCode);
    Halt(1);
  end;
  WriteLn('BASS_Init        : ok');

  Plugin := BASS_PluginLoad('basswma.dll', 0);
  WriteLn('basswma.dll      : handle=', Plugin, ' err=', BASS_ErrorGetCode);
  Plugin := BASS_PluginLoad('bassflac.dll', 0);
  WriteLn('bassflac.dll     : handle=', Plugin, ' err=', BASS_ErrorGetCode);

  for I := 0 to High(FileNames) do
  begin
    WriteLn('--- ', FileNames[I], ' (exists=', FileExists(FileNames[I]), ')');
    H := BASS_StreamCreateFile(False, PChar(FileNames[I]), 0, 0, 0);
    if H = 0 then
    begin
      WriteLn('  StreamCreateFile failed, err=', BASS_ErrorGetCode);
      Continue;
    end;
    FillChar(Info, SizeOf(Info), 0);
    BASS_ChannelGetInfo(H, Info);
    Len := BASS_ChannelGetLength(H);
    WriteLn('  channel=', H, ' freq=', Info.freq, ' chans=', Info.chans,
            ' ctype=', Info.ctype, ' secs=', BASS_ChannelBytes2Seconds(H, Len):0:2);
    BASS_ChannelPlay(H, False);
    Sleep(900);
    WriteLn('  after 900ms      : ', ActiveText(H));
    BASS_StreamFree(H);
  end;

  BASS_Free;
  WriteLn('done');
end.
