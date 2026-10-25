unit USpieler;

interface

uses  sysutils, ExtCtrls, dialogs, ShellAPI, forms, messages, classes, 

      bass, u_bassplayer,

      //Bassplayer 2.10
      bassplayer,

      udatenbank;

const
  { Port: Winamp-Input-Plugins (in_mp3.dll u.s.w.) sind abgeschaltet.
    Auf True setzen, um den alten Host wieder zu aktivieren. }
  EMAT_WINAMP_INPUT = False;
  MAXVISMODE  =   8;
  BASS_RENDER =   0;
  MAX_VOLUME  = 255;
  AUTO_VOLUME_SPEED_MS = 12;
  MAX_ERROR_COUNT = 30;      //Anzahl der Titel, nachdem die Wiedergabe im wiederholten Fehlerfall gestoppt wird
  MAX_EQ_GAINS = 9;
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
    SupportedExtensions : TStringlist;   
    Volume        : integer;
    OldVolume     : integer; //fürs AutoVolumeIn/Decrease
    ErrorCount    : integer; //Zählt erfolglose Abspielversuche
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
    BassPlayer1  : TBassPlayer;
    eqwert       : array [0..MAX_EQ_GAINS] of integer;
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
    procedure VisConfig;
    procedure GetStreamInfo(FileName: string; var myID3: TID3Tag);

 published
    property OnWeiterschalten: TWeiterschaltenEvent
      read FWeiterschalten write FWeiterschalten;
 end;



implementation

uses ump3, PluginCtrl;   // GetProgDir

var
      Aktiv         : TAktiv;
      Abspielfehler : boolean;


constructor TSpieler.Create (AktivateVis:boolean=true);
var
  myBassAddonlist: TBassAddonlist;
  myBassAddonInfo: TBassAddonInfo;
  I: Integer;
  PluginEntryNumber: integer;

  //Für Addonsuche
  ADirectory: string;
  AMask: String;
  ARekursiv: Boolean;
  SR: TSearchRec;

  begin
    //inherited Create;   nötig? nicht nötig?

    Aktiv.Pause := false;
    Aktiv.ErrorCount:=0;

    Bassplayer1:=TBassplayer.Create(fmp3);
    // Port: BASS dekodiert MP3/OGG selbst - keine Winamp-Input-Plugins im ersten Lauf
    Bassplayer1.PluginFirst:=false;
    Bassplayer1.SingleChannel:=True;

    //Lade Plugins            1
    try       

       if BassPlayer1.PlayerReady then
       begin
       // Load bass_ac3.dll to support Dolby Digital AC-3 stream.
        if FileExists(GetProgDir + 'Plugins\bass\bass_ac3.dll')
        then
           begin
             myBassAddonInfo:=BassPlayer1.BASSAddonLoad(GetProgDir + 'Plugins\bass\bass_ac3.dll');
             Fmp3.Log(myBassAddonInfo.Name+' Addon geladen.')             
           end
        else
           fmp3.Log('bass_ac3.dll nicht gefunden');

        // Load bass_aac.dll to support AAC, AAC+ stream.
         if FileExists(GetProgDir + 'Plugins\bass\bass_aac.dll')
         then
           begin
             myBassAddonInfo:=BassPlayer1.BASSAddonLoad(GetProgDir + 'Plugins\bass\bass_aac.dll');
             Fmp3.Log(myBassAddonInfo.Name+' Addon geladen.')             
           end
         else
            fmp3.Log('bass_aac.dll nicht gefunden');

        //LoadFlac
         if FileExists(GetProgDir + 'Plugins\bass\bassflac.dll')
         then
           begin
            myBassAddonInfo:=BassPlayer1.BASSAddonLoad(GetProgDir + 'Plugins\bass\bassflac.dll');
            Fmp3.Log(myBassAddonInfo.Name+' Addon geladen.')
           end
         else
            fmp3.Log('bassflac.dll nicht gefunden');

        //Loadfx
         if FileExists(GetProgDir + 'Plugins\bass\bass_fx.dll')
           then
           begin
             myBassAddonInfo:=BassPlayer1.BASSAddonLoad(GetProgDir + 'Plugins\bass\bass_fx.dll');
             Fmp3.Log(myBassAddonInfo.Name+' Addon geladen.')
           end
           else fmp3.Log('bass_fx.dll nicht gefunden');


         if EMAT_WINAMP_INPUT and BassPlayer1.CanUsePlugin
         then
           begin

              ADirectory :=GetProgDir + 'Plugins\';
              AMask      :='in_*.dll';
              ARekursiv  := false;

              if (ADirectory<>'') and (ADirectory[length(ADirectory)-1]<>'\')
              then ADirectory:=ADirectory+'\';

              if (FindFirst(ADirectory+AMask,faAnyFile-faDirectory,SR)=0)
              then
               begin
                repeat
                  if (SR.Name<>'.') and (SR.Name<>'..') and (SR.Attr<>faDirectory) then
                          begin
                            //fmp3.log(sr.Name);

                            PluginEntryNumber:=-1;

                            //PluginEntryNumber:=LoadWinampPlugin(GetProgDir + 'Plugins\winamp\in_mp3.dll');
                            //Plugins müssen im Plugins-Ordner liegen
                            PluginEntryNumber:=LoadWinampPlugin(sr.Name);
                            Fmp3.Log(sr.Name+'gefunden und geladen unter Referenz: '+inttostr(PluginEntryNumber));
                          end
                            //


                until FindNext(SR)<>0;
                sysutils.FindClose(SR);
              end;
              { Plugins in unterordnern läd der Bassplayer eh nicht
              if ARekursiv then
                if (FindFirst(ADirectory+'*.*',faDirectory,SR)=0) then
                begin
                  repeat
                    if (SR.Name<>'.') and (SR.Name<>'..') then

                  until FindNext(SR)<>0;
                  sysutils.FindClose(SR);
                end;
               }

              {statische Methode, durch Ordnerdursuchen ersetzt
             PluginEntryNumber:=-1;

             if FileExists(GetProgDir + 'Plugins\in_mp3.dll')
              then
              begin
                //PluginEntryNumber:=LoadWinampPlugin(GetProgDir + 'Plugins\winamp\in_mp3.dll');
                //Plugins müssen im Plugins-Ordner liegen
                PluginEntryNumber:=LoadWinampPlugin('in_mad.dll');
                Fmp3.Log('in_mp3.dll geladen unter Nummer: '+inttostr(PluginEntryNumber));
              end
              else fmp3.Log('in_mp3.dll nicht gefunden');

             PluginEntryNumber:=-1;

             if FileExists(GetProgDir + 'Plugins\in_midi.dll')
              then
              begin
                //Plugins müssen im Plugins-Ordner liegen
                PluginEntryNumber:=LoadWinampPlugin('in_midi.dll');
                Fmp3.Log('in_midi.dll geladen unter Nummer: '+inttostr(PluginEntryNumber));
              end
              else fmp3.Log('in_midi.dll nicht gefunden');
              }
             //Port: BASS dekodiert direkt (keine Winamp-Input-Plugins)
             BassPlayer1.PluginFirst:=false;
           end
           else
           begin
             fmp3.Log('Bassplayer kann keine Winampplugins laden.');
           end;
      end;

    except
      Fmp3.Fehler('Entschuldigung, beim Laden der Bass-Addons ist ein Fehler aufgetreten.');
    end;
    
   {
  //Log  
  myBassAddonList:=Bassplayer1.GetBASSAddonList;
  for I := 0 to High(myBassAddonList) do
    begin //Läuft in eine Zugriffsverletzung       
      //fmp3.log('Bassaddon "'+myBassAddonList[i].Name+'" geladen. Version: '+ inttostr(myBassAddonList[i].Version) );
    end;    }

    //Log
    if Bassplayer1.BASSWMAReady
    then fmp3.Log('WMA Plugin geladen')
    else fmp3.Log('WMA Plugin nicht geladen');

    if Bassplayer1.BASSAACReady
    then fmp3.Log('AAC Plugin geladen')
    else fmp3.Log('AAC Plugin nicht geladen');

    if Bassplayer1.BASSCDReady
    then fmp3.Log('CDR Plugin geladen')
    else fmp3.Log('CDR Plugin nicht geladen');

    if Bassplayer1.BASSMIDIReady
    then fmp3.Log('MIDI Plugin geladen')
    else fmp3.Log('MIDI Plugin nicht geladen');

    fmp3.Log('Verfügbare Erweiterungen durch Addons: '+Bassplayer1.BASSAddonExts);
    fmp3.Log('Verfügbare Erweiterungen durch Plugins: '+Bassplayer1.PluginFileExts);
    fmp3.Log('Verfügbare Erweiterungen durch Bass: '+Bassplayer1.NativeFileExts);
    fmp3.Log('Version des Basssystems: '+Bassplayer1.BuildDateStr);
    //Log Ende

    //Erstelle Liste der Fileextensions (*.Endung)
    Aktiv.SupportedExtensions:=TStringlist.Create;
    Aktiv.SupportedExtensions.Delimiter:=';';     
    Aktiv.SupportedExtensions.DelimitedText:=Aktiv.SupportedExtensions.Text+';'+Bassplayer1.BASSAddonExts;
    Aktiv.SupportedExtensions.DelimitedText:=Aktiv.SupportedExtensions.Text+';'+Bassplayer1.PluginFileExts;
    Aktiv.SupportedExtensions.DelimitedText:=Aktiv.SupportedExtensions.Text+';'+Bassplayer1.NativeFileExts;
    //Fmp3.Log(Aktiv.SupportedExtensions.Text);
    

    EQInit;

    //Event zuweisen
    Bassplayer1.OnPlayEnd:=SpielenEnde;

    //Gegen Skipping Issues
    //http://www.un4seen.com/forum/?topic=9436.msg83546#msg83546
    Bassplayer1.SingleChannel:=True;
end;


destructor TSpieler.Destroy;
begin
   //Do not call Destroy of Bassplayer, free does this for you
   Bassplayer1.Free;
   inherited Destroy;
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
  //FKBassplayer.VisPause;
end;


procedure TSpieler.SetBassVisResume;
begin
  //FKBassplayer.VisResume;
end;


function TSpieler.ZustaendigerRenderKern(Dateiendung:string):integer;
var index: Integer;
begin
  result:=-1;

  Dateiendung := '*'+ansilowercase(Dateiendung);  
  index := Aktiv.SupportedExtensions.IndexOf(Dateiendung);
                             
  if index>-1 then result:=BASS_RENDER;

  if extendedDebugLogInfo then
  begin
    Fmp3.Log(Dateiendung +' Renderkern: '+ IntToStr(result)+' Pos: '+inttostr(index));  
    fmp3.Log(Aktiv.SupportedExtensions.text);
  end;
  
{
Verfügbare Erweiterungen durch Addons: *.ac3;*.aac;*.m4a;*.mp4;*.flac;*.fla;*.oga;*.ogg;
Verfügbare Erweiterungen durch Plugins: keine
Verfügbare Erweiterungen durch Bass: *.wav;*.mp1;*.mp2;*.mp3;*.ogg;*.aiff*.mo3;*.it;*.xm;*.s3m;*.mtm;*.mod;*.umx;*.cda;*.wma;*.asf;
}
 { 
  //Kann kein Set verwenden wegen ".";

  if (Dateiendung='.mp3') or (Dateiendung='.wma') or (Dateiendung='.ogg')
    or (Dateiendung='.wav') or (Dateiendung='.cda') or (Dateiendung='.ac3')
    or (Dateiendung='.mp2') or (Dateiendung='.mpa') or (Dateiendung='.aac')
    or (Dateiendung='.mp4') or (Dateiendung='.m4a') or (Dateiendung='.flac')
    then result:=BASS_RENDER;

  if (Dateiendung='.exe') or (Dateiendung='.cmd') or (Dateiendung='.bat')
    then result:=2;  //obsolet      }
end;

function TSpieler.Spiele ( FileName: string ):boolean;

begin
  Result:=false;
  Aktiv.Renderkern := ZustaendigerRenderKern(extractfileext(filename));
  Aktiv.Pause:= false;

  case Aktiv.Renderkern of
  0: //BASS
    begin
       if not Bassplayer1.PlayerReady then
       begin
         fmp3.stop;
         fmp3.log('Bassplayer ist nicht bereit');
         fmp3.fehler('Leider konnte der Titel nicht abgespielt werden.'+#13+#10+
               'Überprüfen Sie bitte, ob der Datenträger oder die Soundkarte verfügbar ist.')
       end;

       if FileExists(FileName) then
       begin
         Result:=Bassplayer1.Open(FileName);
       end
       else
       begin
         Result := False;
         fmp3.Log(FileName + ' could not be found and hence was not played.');
       end;
       if Result
       then
         begin
           Bassplayer1.Play;
           aktiv.errorcount:=0;
           fmp3.log('Benutze Winamp-Plugin zum Dekodieren: '+booltostr(bassplayer1.DecodingByPlugin,True));
         end
       else
         begin
           if aktiv.ErrorCount>MAX_ERROR_COUNT then
             begin
               fmp3.Stop;
               MessageDlg('Leider konnten die letzten '+inttostr(MAX_ERROR_COUNT)+
               ' Titel (u.a. '+FileName+') nicht abgespielt werden und daher wird die Wiedergabe gestoppt.'+#13+#10+
               'Überprüfen Sie bitte, ob der Datenträger oder die Soundkarte verfügbar ist.', mtError, [mbOK], 0);
               abort;
             end;
           inc(aktiv.errorcount);
         end;
       //Result:=true;
    end;
  1: //Bass_FX
     begin

     end;

  2: //Applauncher
     begin

     end;
  end;
end;

procedure TSpieler.Stop;
begin
  case Aktiv.Renderkern of
  0: //BASS
    begin
      Bassplayer1.Stop;
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
       Bassplayer1.Pause(false);
       Aktiv.Pause := not Aktiv.Pause;
      end
      else
      begin
       Bassplayer1.Pause(true);
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

     Bassplayer1.Volume:=volume;

     aktiv.Volume := Volume;
    end;
  3:
     begin

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
        //Result:=Bassplayer1.PlayLength;
        //Result := GetBassPlayLength(Filename) div 1000;
        Result:=1;
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
    myEqBands:TEQBands;
begin
  myEqBands:=Bassplayer1.EQBands;

  fmp3.log('EQ Bänder: '+inttostr(myEQBands.Bands));

  Bassplayer1.SoundEffects:=Bassplayer1.SoundEffects+[Equalizer];

  for i:=0 to 9 do
  eqwert[i]:=0;

  EQSetWerte;
//  Bassplayer1.SoundEffects:=[Equalizer];
end;

procedure TSpieler.EQSetWerte;
var i: integer;
    success     : boolean;
begin
success:=true;
if not Bassplayer1.DX8EffectReady
then fmp3.Fehler('Equalizer benötigt mind. DirectX 8');


for i:=0 to MAX_EQ_GAINS do
  if not Bassplayer1.SetAEQGain(i,eqwert[i])
  then success:=false;// else showmessage('hurrawy');

  fmp3.Log('EQ: '+Bassplayer1.EQDebugInfo);

//if not success then fmp3.Fehler('EQ Werte konnten nicht gesetzt werden');

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
      Result:=Bassplayer1.Position / 1000;
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
      //Bassplayer1 erwartet Position in ms
      Bassplayer1.Position:=position*1000;
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
     //Wandelt ankommende Millisekunden in Sekunden um
     Result:=round(Bassplayer1.PlayLength / 1000);
    end;
  end;
  if Result=0 then Result:=1; //Verhindert evtl. Div. durch Null (Warum?)
end;


function TSpieler.GetBassPlayLength(Filename: string) : integer;
var
   basspl    : TBassplayer;
begin
   result:=-42;
    {
   basspl:=TBassplayer.Create(fmp3.Handle);

   basspl.setFileToPlay(filename);

   result:=round(basspl.length)*1000;

   basspl.freewithoutbassfree:=true;
   basspl.free;   }
end;


procedure TSpieler.VisConfig;
begin
  //Bassplayer1.ShowVisWindow;  (Winamp-Visualisierung entfernt)
end;


procedure TSpieler.GetStreamInfo(FileName: string; var myID3:TID3Tag);

var myStreamInfo:TStreamInfo;
    mySupportedBy:TSupportedBy;


begin
  Bassplayer1.GetStreamInfo(FileName,myStreamInfo,mySupportedBy);

  myid3.Titel   :=myStreamInfo.Title;
  myid3.Artist  :=myStreamInfo.Artist;
  myid3.Album   :=myStreamInfo.Album;
  myid3.Year    :=myStreamInfo.Year;
  myid3.Genre   :=myStreamInfo.Genre;
  myid3.Comment :=myStreamInfo.Comment;
  myid3.Track   :=myStreamInfo.Track;
  myid3.dauer   :=myStreamInfo.Duration;



  myid3.ausgelesen:=true;
  
  if extendedDebugLogInfo 
  then
    begin
      if WinampPlugin = mySupportedBy then
      fmp3.Log('Decodiert von Winamp');

      if Both = mySupportedBy then
      fmp3.Log('Decodiert von beiden');

      if BASSNative = mySupportedBy then
      fmp3.Log('Decodiert von BASSNative');

      if none = mySupportedBy then
      fmp3.Log('Decodiert von niemandem');
    end;
end;


procedure TSpieler.SetBassVisMode(Mode: byte; Aktivate:boolean);
begin        {
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
  end;  }
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

