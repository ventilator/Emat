unit FKBassPlayer;

{
  FKBassplayer

  Orginal von Delphi-Praxis-User dizzy (Fabian)

  Edit by Der_Ventilator für Emat

   -Vis abschaltbar
   -VisImagePath
}

interface

uses Windows, Messages, Classes, Bass, U_BassPlayer, GR32, GR32_Blend, GR32_Filters,
      GFX, VisThread;

const VisImagePath = 'visimages\';

type
  TFKBassPlayer = class(TObject)
  private
    VisThread : TVisThread;
    VisAktive : boolean;

    FIsPlaying: Boolean;
    FPath     : String;
    FOwner    : HWND;
    FDisplay  : PBitmap32;
    FColor    : TColor32;
    // Vis-Options
    FshowVolumeVis,
    FshowWaveVis,
    FshowFFTVis,
    FshowSphereVis,
    FshowLightningVis,
    FshowFFTBMP,
    FdoColorCycle,
    FdoRotateBlur,
    FdoGlareBlur,
    FdoZoomBlur,
    FdoVanish,
    FdoHalftoneMask: Boolean;
    procedure PlayerHasStopped;
    procedure ShowSplashScreen;
    procedure SetFshowVolumeVis(val: Boolean);
    procedure SetFshowWaveVis(val: Boolean);
    procedure SetFshowFFTVis(val: Boolean);
    procedure SetFshowSphereVis(val: Boolean);
    procedure SetFshowLightningVis(val: Boolean);
    procedure SetFshowFFTBMP(val: Boolean);
    procedure SetFdoColorCycle(val: Boolean);
    procedure SetFdoRotateBlur(val: Boolean);
    procedure SetFdoGlareBlur(val: Boolean);
    procedure SetFdoZoomBlur(val: Boolean);
    procedure SetFdoVanish(val: Boolean);
    procedure SetFdoHalftoneMask(val: Boolean);
  public
    Bassplayer: TBassPlayer;
    function  GetMainVolume: Byte;
    procedure SetMainVolume(val: Byte);
    function  GetPosition: Double;
    procedure SetPosition(val: Double);
    function  GetLength: Double;
    procedure PlayFile(FileName: String);
    procedure Stop;
    procedure Pause;
    procedure Resume;
    constructor Create(Handle: HWND; SelfPath: String; Display: PBitmap32; Color: TColor32; AktivateVis:boolean=true);
    destructor Destroy; override;
    property Color            : TColor32 read FColor            write FColor;
    property Volume           : Byte     read GetMainVolume     write SetMainVolume;
    property Position         : Double   read GetPosition       write SetPosition;
    property LengthInSec      : Double   read GetLength;
    property IsPlaying        : Boolean  read FIsPlaying;
    property showVolumeVis    : Boolean  read FshowVolumeVis    write SetFshowVolumeVis;
    property showWaveVis      : Boolean  read FshowWaveVis      write SetFshowWaveVis;
    property showFFTVis       : Boolean  read FshowFFTVis       write SetFshowFFTVis;
    property showSphereVis    : Boolean  read FshowSphereVis    write SetFshowSphereVis;
    property showLightningVis : Boolean  read FshowLightningVis write SetFshowLightningVis;
    property showFFTBMP       : Boolean  read FshowFFTBMP       write SetFshowFFTBMP;
    property doColorCycle     : Boolean  read FdoColorCycle     write SetFdoColorCycle;
    property doRotateBlur     : Boolean  read FdoRotateBlur     write SetFdoRotateBlur;
    property doGlareBlur      : Boolean  read FdoGlareBlur      write SetFdoGlareBlur;
    property doZoomBlur       : Boolean  read FdoZoomBlur       write SetFdoZoomBlur;
    property doVanish         : Boolean  read FdoVanish         write SetFdoVanish;
    property doHalftoneMask   : Boolean  read FdoHalftoneMask   write SetFdoHalftoneMask;

    procedure VisPause;
    procedure VisResume;

  end;

const
  WM_BASSPLAYERSTOPPED = WM_USER + 1614;

implementation

{ TFKBassPlayer }

procedure TFKBassPlayer.ShowSplashScreen;
begin
  // Display Splash-Screen
  VisThread.bmpA.LoadFromFile(FPath+visimagepath+'logo01.bmp');

  ApplyScope(VisThread.bmpA);
  FDisplay^.Clear(Color);
  VisThread.Frame.DrawTo(FDisplay^);
  VisThread.bmpA.DrawTo(FDisplay^);
  VisThread.Ref.DrawTo(FDisplay^);
end;

constructor TFKBassPlayer.Create(Handle: HWND; SelfPath: String;
                  Display: PBitmap32; Color: TColor32; AktivateVis:boolean=true);

begin
  // Set environment
  FOwner := Handle;
  FColor := Color;
  FDisplay := Display;
  Bassplayer := TBassPlayer.Create(Handle);
  FPath := SelfPath;

  VisAktive:=AktivateVis;

  if VisAktive then
  begin

  // Prepare VisualThread
  InitScope(FPath);
  VisThread := TVisThread.Create(Color, Color32(0,16,64,16), FPath);
  VisThread.Display := FDisplay;
  VisThread.Player := Bassplayer;
  VisThread.RotateBlurFactor := 1.5;
  VisThread.Priority := tpIdle;

  ShowSplashScreen;

  // Assign Method that handles automatic stopping of Sound
  VisThread.PlayerStoppedHandler := PlayerHasStopped;
  end;
end;

destructor TFKBassPlayer.Destroy;
begin
  if VisAktive then
  begin
    if (not VisThread.Suspended) then
    begin
      VisThread.Terminate;
      VisThread.WaitFor;
    end;
    VisThread.free;
  end;
  Bassplayer.free;
end;


procedure TFKBassPlayer.VisPause;
begin
  if (FIsPlaying) and (VisAktive) then
  begin
    VisThread.Suspend;
  end;
end;


procedure TFKBassPlayer.VisResume;
begin
  if (FIsPlaying) and (VisAktive) then
  begin
    VisThread.Resume;
  end;
end;


procedure TFKBassPlayer.Pause;
begin
  if FIsPlaying then
  begin
    if VisAktive then
    VisThread.Suspend;

    Bassplayer.pause;
    FIsPlaying := false;
  end;
end;


procedure TFKBassPlayer.PlayerHasStopped;
begin
  if VisAktive then
  begin
    VisThread.Suspend;
  //  ShowSplashScreen;
  end;

  FIsPlaying := false;
  SendMessage(FOwner, WM_BASSPLAYERSTOPPED, 0, 0);
end;

procedure TFKBassPlayer.PlayFile(FileName: String);
begin
  if FIsPlaying then
  begin
    FIsPlaying := false;
    if VisAktive then
     begin
      VisThread.Suspend;
     end;
    Bassplayer.stop;
  end;
  Bassplayer.setFileToPlay(FileName);
  Bassplayer.play;
  FIsPlaying := true;
  if VisAktive then  VisThread.Resume;
end;

procedure TFKBassPlayer.Resume;
begin
  if not FIsPlaying then
  begin
    Bassplayer.resume;
    FIsPlaying := true;
    if VisAktive then VisThread.Resume;
  end;
end;

procedure TFKBassPlayer.Stop;
begin
  if FIsPlaying then
  begin
    FIsPlaying := false;
    if VisAktive then VisThread.Suspend;
    Bassplayer.stop;
    if VisAktive then ShowSplashScreen;
  end;
end;

procedure TFKBassPlayer.SetFdoColorCycle(val: Boolean);
begin
  FdoColorCycle := val;
  if VisAktive then VisThread.doColorCycle := val;
end;

procedure TFKBassPlayer.SetFdoGlareBlur(val: Boolean);
begin
  FdoGlareBlur := val;
  if VisAktive then VisThread.doGlareBlur := val;
end;

procedure TFKBassPlayer.SetFdoHalftoneMask(val: Boolean);
begin
  FdoHalftoneMask := val;
  if VisAktive then VisThread.doHalftoneMask := val;
end;

procedure TFKBassPlayer.SetFdoRotateBlur(val: Boolean);
begin
  FdoRotateBlur := val;
  if VisAktive then VisThread.doRotateBlur := val;
end;

procedure TFKBassPlayer.SetFdoVanish(val: Boolean);
begin
  FdoVanish := val;
  if VisAktive then VisThread.doVanish := val;
end;

procedure TFKBassPlayer.SetFdoZoomBlur(val: Boolean);
begin
  FdoZoomBlur := val;
  if VisAktive then VisThread.doZoomBlur := val;
end;

procedure TFKBassPlayer.SetFshowFFTBMP(val: Boolean);
begin
  FshowFFTBMP := val;
  if VisAktive then VisThread.showFFTBMP := val;
end;

procedure TFKBassPlayer.SetFshowFFTVis(val: Boolean);
begin
  FshowFFTVis := val;
  if VisAktive then VisThread.showFFTVis := val;
end;

procedure TFKBassPlayer.SetFshowLightningVis(val: Boolean);
begin
  FshowLightningVis := val;
  if VisAktive then VisThread.showLightningVis := val;
end;

procedure TFKBassPlayer.SetFshowSphereVis(val: Boolean);
begin
  FshowSphereVis := val;
  if VisAktive then VisThread.showSphereVis := val;
end;

procedure TFKBassPlayer.SetFshowVolumeVis(val: Boolean);
begin
  FshowVolumeVis := val;
  if VisAktive then VisThread.showVolumeVis := val;
end;

procedure TFKBassPlayer.SetFshowWaveVis(val: Boolean);
begin
  FshowWaveVis := val;
  if VisAktive then VisThread.showWaveVis := val;
end;

function TFKBassPlayer.GetMainVolume: Byte;
begin
  result := Bassplayer.volume;
end;

procedure TFKBassPlayer.SetMainVolume(val: Byte);
begin
  Bassplayer.volume := val;
end;

function TFKBassPlayer.GetPosition: Double;
begin
  result := Bassplayer.Position;
end;

procedure TFKBassPlayer.SetPosition(val: Double);
begin
  if VisAktive then VisThread.Transporting := true;
  Bassplayer.position := val;
  if VisAktive then VisThread.Transporting := false;
end;

function TFKBassPlayer.GetLength: Double;
begin
  result := Bassplayer.length;
end;

end.
