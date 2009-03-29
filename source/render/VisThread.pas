unit VisThread;

{
  VisThread

  Orginal von Delphi-Praxis-User dizzy (Fabian)

  Edit von Der_Ventilator für Emat
    -THREAD_SLEEP_TIME für geringere CPU-Last
}

interface

uses Windows, Classes, SysUtils, Math, GR32, GR32_Filters, U_Bassplayer, GFX, Bass,
     Dialogs;

const
  THREAD_SLEEP_TIME = 10;   //ehem. 5

type
  PBitmap32 = ^TBitmap32;
  TVisThread = class(TThread)
  private
    FRotateBlurFactor: Double;
    FBGColor: TColor32;
    FColor: TColor32;
    procedure setBGColor(value: TColor32);
    procedure setRotateBlurFactor(value: Double);
    procedure DrawScopeToScreenC;
  protected
    procedure Execute; override;
  public
    showVolumeVis,
    showWaveVis,
    showFFTVis,
    showSphereVis,
    showLightningVis,
    showFFTBMP,
    doColorCycle,
    doRotateBlur,
    doGlareBlur,
    doZoomBlur,
    doVanish,
    doHalftoneMask     : Boolean;
    xRot, yRot, zRot   : Double;
    XRotDir            : Double;
    YRotDir            : Double;
    ZRotDir            : Double;
    rr, rg, rb         : array[1..4] of Double;
    rAdd, gAdd, bAdd   : array[1..4] of Double;
    bmpA, bmpB, bmpC   : TBitmap32;
    Echo               : TBitmap32;
    Display            : PBitmap32;
    Frame, Ref         : TBitmap32;
    Transporting       : Boolean;
    Player             : TBassplayer;
    PlayerStoppedHandler: procedure of object;
    constructor Create(BGCol, VisCol: TColor32; Path: String);
    destructor Destroy; override;
    property RotateBlurFactor: Double   read FRotateBlurFactor write setRotateBlurFactor;
    property bgColor         : TColor32 read FBGColor          write setBGColor;
  end;

implementation
{ TVisThread }

uses FKBassPlayer; //Wegen VisImagePath

constructor TVisThread.Create(BGCol, VisCol: TColor32; Path: String);
var
  HLight, Mask: TBitmap32;
begin
  inherited Create(true);

  Priority := tpIdle;
  FColor := BGCol;

  bmpA               := TBitmap32.Create;
  bmpA.Width         := 400;
  bmpA.Height        := 400;
//  bmpA.StretchFilter := sfLinear;
  bmpA.DrawMode      := dmBlend;

  bmpB               := TBitmap32.Create;
  bmpB.Width         := 400;
  bmpB.Height        := 400;
//  bmpB.StretchFilter := sfLinear;
  bmpB.DrawMode      := dmBlend;

  bmpC               := TBitmap32.Create;
  bmpC.Width         := 400;
  bmpC.Height        := 400;
//  bmpC.StretchFilter := sfLinear;
  bmpC.DrawMode      := dmBlend;

  Echo               := TBitmap32.Create;
  Echo.Width         := 400;
  Echo.Height        := 400;
//  Echo.StretchFilter := sfLinear;
  Echo.DrawMode      := dmBlend;
  Echo.MasterAlpha   := 128;

  Frame  := TBitmap32.Create;
  HLight := TBitmap32.Create;
  Ref    := TBitmap32.Create;
  Mask   := TBitmap32.Create;
  {Scopeframe}
  Mask.LoadFromFile(path+visimagepath+'scopemask.bmp');
  Frame.LoadFromFile(path+visimagepath+'scopeframe.bmp');
  Frame.DrawMode := dmBlend;
  IntensityToAlpha(Frame, Mask);
  {Glass-Highlight}
  Mask.LoadFromFile(path+visimagepath+'glassmask.bmp');
  HLight.DrawMode := dmBlend;
  HLight.LoadFromFile(path+visimagepath+'glass.bmp');
  IntensityToAlpha(HLight, Mask);
  {Glass-Reflection}
  Mask.LoadFromFile(path+visimagepath+'glass2mask.bmp');
  Ref.DrawMode := dmBlend;
  Ref.LoadFromFile(path+visimagepath+'glass2.bmp');
  IntensityToAlpha(Ref, Mask);
  Mask.Free;
  {Combine Highlight and Reflection}
  HLight.DrawTo(Ref);
  HLight.Free;

  bmpA.Clear(VisCol);
  FBGColor := VisCol;
  InitVanish(FBGColor);

  InitFFTGrid(bmpA);
  xRot := 0.1;
  yRot := 0.1;
  zRot := 0.1;
  XRotDir := 0.1;
  YRotDir := 0.1;
  ZRotDir := 0.1;
  rr[1] := 255;
  rg[1] :=  63;
  rb[1] :=   0;
  rr[2] :=   0;
  rg[2] := 255;
  rb[2] := 128;
  rr[3] := 128;
  rg[3] :=   0;
  rb[3] := 196;
  rr[4] :=  64;
  rg[4] := 255;
  rb[4] :=  64;
  rAdd[1] := 1.20;
  gAdd[1] := 1.25;
  bAdd[1] := 1.15;
  rAdd[2] := 1.20;
  gAdd[2] := 1.25;
  bAdd[3] := 1.15;
  rAdd[3] := 1.20;
  gAdd[4] := 1.25;
  bAdd[4] := 1.15;

  showVolumeVis    := false;
  showWaveVis      := false;
  showFFTVis       := false;
  showSphereVis    := false;
  showLightningVis := false;
  showFFTBMP       := false;
  doColorCycle     := false;
  doRotateBlur     := false;
  doGlareBlur      := false;
  doZoomBlur       := false;
  doVanish         := false;
  doHalftoneMask   := false;

  Transporting := false;
end;

destructor TVisThread.Destroy;
begin
  bmpA.Free;
  bmpB.Free;
  bmpC.Free;
  Echo.Free;
  Frame.Free;
  Ref.Free;
end;

procedure TVisThread.setRotateBlurFactor(value: Double);
begin
  FRotateBlurFactor := value;
  PrepareBMPRotation(bmpA, FRotateBlurFactor);
end;

procedure TVisThread.DrawScopeToScreenC;
begin
  Display^.BeginUpdate;
  Display^.Clear(FColor);
  Frame.DrawTo(Display^);
  bmpC.DrawTo(Display^);
  Ref.DrawTo(Display^);
  Display^.EndUpdate;
  Display^.Changed;
end;

procedure SwapBmps(var a, b: TBitmap32);
var
  t: TBitmap32;
begin
  t := a;
  a := b;
  b := t;
end;

procedure TVisThread.Execute;
var
  gVol, i: Integer;
const
  pi2: Double = 6.2831853;
begin
  while not Terminated do
  begin

    if (Player.getStatus <> BASS_ACTIVE_STOPPED) and (Player.getStatus <> BASS_ACTIVE_PAUSED)
    then
    begin
      if doColorCycle then
      begin
        // We have 4 colors to cycle, each consisting of red, green and blue.
        // This makes it a bit more to calculate...
        for i := 1 to 4 do
        begin
          rr[i] := rr[i] + rAdd[i];
          rg[i] := rg[i] + gAdd[i];
          rb[i] := rb[i] + bAdd[i];
          if (rr[i] > 255) or (rr[i] < 0) then rAdd[i] := rAdd[i] * -1;
          if (rg[i] > 255) or (rg[i] < 0) then gAdd[i] := gAdd[i] * -1;
          if (rb[i] > 255) or (rb[i] < 0) then bAdd[i] := bAdd[i] * -1;
        end;
      end;

      // Blur / Vanish
      if not (doRotateBlur or doGlareBlur or doZoomBlur or doVanish) then
      begin
        // if no BlurFX is chosen, don't actually draw "dry", but do kind of a
        // very fast "Vanish" to keep a slight echo of the former Image. Looks
        // a lot better :-)
        bmpA.Clear(bgColor);
        Echo.DrawTo(bmpA);
      end
      else
      begin
        if doRotateBlur then
        begin
          RotateBMP(bmpB, bmpA);
          SwapBmps(bmpB, bmpA);
        end;
        if doGlareBlur then
        begin
          GlareBlur(bmpB, bmpA);
          SwapBmps(bmpB, bmpA);
        end;
        if doZoomBlur then
        begin
          Stretch(bmpB, bmpA);
          SwapBmps(bmpB, bmpA);
        end;
        if doVanish then
        begin
          VanishToBGColor(bmpA);
        end;
      end;

      // FX-Generators
      if showFFTBMP       then DrawVisFFTBMP   (bmpA, Player);
      if showSphereVis    then DrawVisSphere   (bmpA, Player, Color32(trunc(rr[1]),trunc(rg[1]),trunc(rb[1])), xRot, yRot, zRot);
      if showLightningVis then DrawVisLightning(bmpA, Player, Color32(trunc(rr[2]),trunc(rg[2]),trunc(rb[2])));
      if showFFTVis       then DrawVisGrid     (bmpA, Player, Color32(trunc(rr[3]),trunc(rg[3]),trunc(rb[3])), xRot, yRot);
      if showWaveVis      then DrawVisWaveAlt  (bmpA, Player, Color32(trunc(rr[4]),trunc(rg[4]),trunc(rb[4])));

      // Overlays
      if doHalftoneMask then HalftoneMask(bmpC, bmpA) else bmpC.Assign(bmpA);
      if showVolumeVis  then DrawVisVolume(bmpC, Player);

      // Scopemask
      ApplyScope(bmpA); // Vis will kind of "flicker" when dot applying the Scope-Mask to bmpA
      ApplyScope(bmpC);

       // Save Echo-Image for visual improvement when no BlurFX is on
      if not (doRotateBlur or doGlareBlur or doZoomBlur or doVanish) then bmpA.DrawTo(Echo);

      // Draw back
      synchronize(DrawScopeToScreenC);

      // Make Thread not consume 100% of CPU-Time
      Sleep(THREAD_SLEEP_TIME);

      // Rotation-Variables for "FFTVis" (The Grid) and "SphereVis"
      if showFFTVis or showSphereVis then
      begin
        // Fetch total Volume
        gVol := Player.LeftPeak + Player.RightPeak;

        if gVol > 0 then
        begin
          XRotDir := (gVol / 1500) * Sign(XRotDir);
          YRotDir := (gVol / 1500) * Sign(YRotDir);
          ZRotDir := (gVol / 1500) * Sign(ZRotDir);
        end;
        if gVol > 230 then XRotDir := XRotDir * -1;
        if gVol > 240 then YRotDir := YRotDir * -1;
        if gVol > 235 then ZRotDir := ZRotDir * -1;
        xRot := xRot + XRotDir;
        yRot := yRot + YRotDir;
        zRot := zRot + ZRotDir;
        if xRot > pi2 then xRot := xRot - pi2;
        if xRot < 0   then xRot := xRot + pi2;
        if yRot > pi2 then yRot := yRot - pi2;
        if yRot < 0   then yRot := yRot + pi2;
        if zRot > pi2 then zRot := zRot - pi2;
        if zRot < 0   then zRot := zRot + pi2;
      end;                                   
    end // if Player.getStatus <> 0 then ...
    else
      if not Transporting then synchronize(PlayerStoppedHandler);
  end;
end;


procedure TVisThread.setBGColor(value: TColor32);
begin
  FBGColor := value;
  InitVanish(FBGColor);
end;

end.
