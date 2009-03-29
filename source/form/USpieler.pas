unit USpieler;

interface

uses  sysutils, ExtCtrls, dialogs, ShellAPI, forms, messages,

      fkbassplayer, bass, u_bassplayer, GR32;

const
  MAXVISMODE  =   8;
  BASS_RENDER =   0;
  MAX_VOLUME  = 255;
  AUTO_VOLUME_SPEED_MS = 12;
type
  TWeiterschaltenEvent = procedure of object;

type
  TBassInfo = record
     Channel : cardinal;
  end;

type
  TAktiv = record
    Renderkern    : integer;
    Pause         : boolean;
    BassVisOutput : byte;
    BassInfo      : TBassInfo;
    Volume        : integer;
    OldVolume     : integer; //fürs AutoVolumeIn/Decrease
   end;

type
  TSpieler = class (TObject)

 private
    FWeiterSchalten : TWeiterschaltenEvent;


    procedure EQInit;
    procedure BassPlayerAbspielfehler;
    procedure SpielenEnde(Sender:TObject);
    function GetBassPlayLength(Filename: string): integer;

 //   procedure WMBassPlayerStop(var Message: TMessage); message WM_BASSPLAYERSTOPPED;
 //   die message erreicht den owner, und der ist fmp3 bzw. dessen handle, was der
 //   spieler nicht hat.
 public
    FKBassPlayer  : TFKBassPlayer;
    eqwert      : array [1..10] of integer;
    constructor Create (AktivateVis:boolean=true);
    function ZustaendigerRenderKern(Dateiendung:string):integer;
    function Spiele(FileName: string): boolean;
    procedure Spule(Prozent: real);
    procedure EQSetWerte;
    procedure Pause;
    procedure Stop;
    procedure SetVolume(Volume: integer);
    function GetPosition: double;
    procedure SetPosition(position: cardinal);
    function GetLength: cardinal;
    function GetDauer(FileName: string): cardinal;
    destructor Destroy; override;
    procedure SpectrumResize;
    procedure SetBassVisMode(Mode: byte; Aktivate:boolean);

    procedure SetBassVisPause;
    procedure SetBassVisResume;

    function GetVolume : integer;

    procedure AutoVolumeDecrease;
    procedure AutoVolumeIncrease;
    function GetPauseState : boolean;
 published
    property OnWeiterschalten: TWeiterschaltenEvent
      read FWeiterschalten write FWeiterschalten;
 end;



implementation

uses ump3;

var
      Aktiv         : TAktiv;
      Abspielfehler : boolean;

constructor TSpieler.Create (AktivateVis:boolean=true);
  begin
    Aktiv.Pause := false;

    fmp3.I32_Vis.Bitmap.SetSize(400,400);

    FKBassPlayer := TFKBassPlayer.Create(fmp3.Handle,
                                       ExtractFilePath(Application.Exename),
                                       @fmp3.I32_Vis.Bitmap,
                                       Color32(fmp3.I32_Vis.Color),
                                       AktivateVis);
  end;

destructor TSpieler.Destroy;
begin
   FKBassplayer.Free;
end;


procedure TSpieler.SpectrumResize;
begin
{ Spectrum.Resize(fmp3.PBSpectrum.Width,fmp3.PBSpectrum.Height);
 OcilloScope := TOcilloScope.Create(fmp3.PBSpectrum.Width,fmp3.PBSpectrum.Height);
 fmp3.SetColor; }
end;

procedure TSpieler.SpielenEnde(Sender:Tobject);
begin
  if Assigned(OnWeiterschalten) then OnWeiterschalten;
end;

{procedure TSpieler.WMBassPlayerStop(var Message: TMessage);
begin
  SpielenEnde(nil);
end;}


procedure TSpieler.SetBassVisPause;
begin
  FKBassplayer.VisPause;
end;


procedure TSpieler.SetBassVisResume;
begin
  FKBassplayer.VisResume;
end;


function TSpieler.ZustaendigerRenderKern(Dateiendung:string):integer;
begin
  result:=-1;

  Dateiendung := ansilowercase(Dateiendung); //uk

  //Kann kein Set verwenden wegen ".";

  if (Dateiendung='.mp3') or (Dateiendung='.wma') or (Dateiendung='.ogg')
    or (Dateiendung='.wav') or (Dateiendung='.cda') or (Dateiendung='.ac3')
    or (Dateiendung='.mp2') or (Dateiendung='.mpa') or (Dateiendung='.aac')
    or (Dateiendung='.mp4') or (Dateiendung='.m4a') or (Dateiendung='.flac')
    then result:=BASS_RENDER;

  if (Dateiendung='.exe') or (Dateiendung='.cmd') or (Dateiendung='.bat')
    then result:=2;  //obsolet
end;

function TSpieler.Spiele ( FileName: string ):boolean;
begin
  Result:=false;
  Aktiv.Renderkern := ZustaendigerRenderKern(extractfileext(filename));
  Aktiv.Pause:= false;

  case Aktiv.Renderkern of
  0: //BASS
    begin
       FKBassplayer.PlayFile( FileName );
       Result:=true;
    end;
  1: //Bass_FX
     begin
        BASS_StreamFree(Aktiv.BassInfo.Channel);

        Aktiv.BassInfo.Channel:=
         BASS_StreamCreateFile(false, pChar(Filename), 0, 0, 0);

        if Aktiv.BassInfo.Channel <> 0
        then BASS_ChannelPlay(Aktiv.BassInfo.Channel, true);

        Result:=true;
     end;

  2: //Applauncher
     begin
       ShellExecute(Application.Handle,'open',pchar(FileName),'',pchar(extractfilepath(FileName)),1);
       Result:=true;
     end;
  end;
end;

procedure TSpieler.Stop;
begin
  case Aktiv.Renderkern of
  0: //BASS
    begin
      FKBassPlayer.Stop;
    end;
  3: //BassDllDynamic
     begin
   //   fmp3.BassDll.Stop;
     end;
  end;

end;

procedure TSpieler.Spule (Prozent:real);
begin
  case Aktiv.Renderkern of
  0: //BASS
    begin
      if prozent<0 then prozent:=0;
      if prozent>1 then prozent:=1;
      //AutoVolumeDecrease;
     { aktiv.OldVolume:=aktiv.Volume;
      setvolume(0);  }
      SetPosition(round(prozent*GetLength));
      //AutoVolumeIncrease;
    end;
  3: //BassDllDynamic
     begin
   //   fmp3.BassDll.Position:=round(prozent*fmp3.bassdll.SongLength);
     end;
  end;
end;


procedure TSpieler.AutoVolumeDecrease;
var i,k : integer;
begin
  k:=getvolume div 10;
  Aktiv.OldVolume := aktiv.Volume;

  for i:=0 to 10 do
  begin
    setvolume(getvolume-k);
    fmp3.delay(AUTO_VOLUME_SPEED_MS);
  end;

end;


procedure TSpieler.AutoVolumeIncrease;
var i,k:integer;
begin
  k:=aktiv.OldVolume div 10;

  for i:=0 to 10 do
  begin
    setvolume(getvolume+k);
    fmp3.delay(AUTO_VOLUME_SPEED_MS);
  end;

end;


procedure TSpieler.Pause;
begin
  case Aktiv.Renderkern of
  0: //BASS
    begin
      if Aktiv.Pause
      then
      begin
       FKBassplayer.Resume; 
       Aktiv.Pause := not Aktiv.Pause;
      end
      else
      begin
       FKBassplayer.Pause;
       Aktiv.Pause := not Aktiv.Pause;
      end;
    end;
  3: //BassDllDynamic
    begin
    {  if Aktiv.Pause
      then
      begin
       fmp3.BassDll.Play;

       Aktiv.Pause := not Aktiv.Pause;
      end
      else
      begin
       fmp3.BassDll.Pause;
      end;}
    end;
  end;
end;


function TSpieler.GetPauseState : boolean;
begin
  result:=aktiv.Pause;
end;


procedure TSpieler.SetVolume(Volume:integer);
begin
  case Aktiv.Renderkern of
  0: //BASS {von 0 bis 255}
    begin
     if volume<0   then  volume:=0;
     if volume>MAX_VOLUME then volume:=MAX_VOLUME;

     FKBassplayer.Volume := Volume;
     aktiv.Volume := Volume;
    end;
  3: //BassDllDynamic
     begin
 //     fmp3.BassDll.Volume:= Volume;
     end;
  end;

  Aktiv.Volume:= Volume;
end;


function TSPieler.GetVolume : integer;
begin
  Result:= Aktiv.Volume;
end;

function TSpieler.GetDauer(FileName:string):cardinal;
begin
  Result := 0;
  case Aktiv.Renderkern of
  0: //BASS
    begin
      try
        Result := GetBassPlayLength(Filename) div 1000;
      except
        fmp3.Fehler('Die Länge des Mediums '+FileName+
                    ' konnte nicht zuverlässig ermittelt werden');
      end;
    end;
  end;
end;

///////////////////////////////////EQ///////////////////////////////////////////
procedure TSpieler.EQInit;
var i:integer;
begin
  for i:=1 to 10 do
  eqwert[i]:=0;

  EQSetWerte;
//  Bassplayer.SoundEffects:=[Equalizer];
end;

procedure TSpieler.EQSetWerte;
var i: integer;
begin
for i:=1 to 10 do
// Bassplayer.SetAEQGain(i,eqwert[i]);
end;
////////////////////////////////////////////////////////////////////////////////

procedure TSpieler.BassPlayerAbspielfehler;
begin
  Abspielfehler:=true;
end;

function TSpieler.GetPosition: double;
begin
  Result:=0;
  case Aktiv.Renderkern of
  0: //BASS
    begin
      Result:=FKBassplayer.GetPosition;
    end;
  3: //BassDllDynamic
     begin
 //     Result:=fmp3.BassDll.Position;
     end;
  end;
end;

procedure TSpieler.SetPosition(position: cardinal);
begin
  case Aktiv.Renderkern of
  0: //BASS
    begin
      FKBassplayer.SetPosition(position);
    end;
  3: //BassDllDynamic
    begin
  //    fmp3.BassDll.Position:=Position;
    end;
  end;
end;

function TSpieler.GetLength: cardinal;
begin
  Result:=1;
  case Aktiv.Renderkern of
  0: //BASS
    begin
     Result:=round(FKBassplayer.GetLength);
    end;
  3: //BassDllDynamic
    begin
//      Result:=fmp3.BassDll.Position;
    end;
  end;
  if Result=0 then Result:=1; //Verhindert evtl. Div. durch Null 
end;


function TSpieler.GetBassPlayLength(Filename: string) : integer;
var
   basspl    : TBassplayer;
begin
   result:=0;

   basspl:=TBassplayer.Create(fmp3.Handle);

   basspl.setFileToPlay(filename);

   result:=round(basspl.length)*1000;

   basspl.freewithoutbassfree:=true;
   basspl.free;
end;


procedure TSpieler.SetBassVisMode(Mode: byte; Aktivate:boolean);
begin
  case Mode of
     0: FKBassPlayer.doColorCycle     := Aktivate;
     1: FKBassPlayer.showVolumeVis    := Aktivate;
     2: FKBassPlayer.doHalftoneMask   := Aktivate;
     3: FKBassPlayer.showFFTBMP       := Aktivate;
     4: FKBassPlayer.showSphereVis    := Aktivate;
     5: FKBassPlayer.showFFTVis       := Aktivate;
     6: FKBassPlayer.showLightningVis := Aktivate;
     7: FKBassPlayer.showWaveVis      := Aktivate;
     8: FKBassPlayer.doRotateBlur     := Aktivate;
     9: FKBassPlayer.doGlareBlur      := Aktivate;
    10: FKBassPlayer.doZoomBlur       := Aktivate;
    11: FKBassPlayer.doVanish         := Aktivate;
  end;
end;



  {
procedure TSpieler.ExecuteFile(const AFilename: String;
                 AParameter, ACurrentDir: String; AWait: Boolean;
                 AOnWaitProc: TExecuteWaitEvent=nil);
var
  si: TStartupInfo;
  pi: TProcessInformation;
  bTerminate: Boolean;
begin
  bTerminate := False;

  if Length(ACurrentDir) = 0 then
    ACurrentDir := ExtractFilePath(AFilename);

  if AnsiLastChar(ACurrentDir) = '\' then
    Delete(ACurrentDir, Length(ACurrentDir), 1);

  FillChar(si, SizeOf(si), 0);
  with si do begin
    cb := SizeOf(si);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := SW_NORMAL;
  end;

  FillChar(pi, SizeOf(pi), 0);
  AParameter := Format('"%s&" %s', [AFilename, TrimRight(AParameter)]);

  if CreateProcess(Nil, PChar(AParameter), Nil, Nil, False,
                   CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
                   NORMAL_PRIORITY_CLASS, Nil, PChar(ACurrentDir), si, pi) then
  try
    if AWait then
      while WaitForSingleObject(pi.hProcess, 50) <> Wait_Object_0 do
      begin
        if Assigned(AOnWaitProc) then
        begin
          AOnWaitProc(pi, bTerminate);
          if bTerminate then
            TerminateProcess(pi.hProcess, Cardinal(-1));
        end;

        Application.ProcessMessages;
      end;
  finally
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
  end;
end;
      }

end.

