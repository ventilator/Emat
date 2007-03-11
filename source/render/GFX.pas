unit GFX;

{
  GFX

  Orginal von Delphi-Praxis-User dizzy (Fabian)

  Edit by Der_Ventilator für Emat
    -Draw Vis Volume: Werte durch 128 geteilt
}    


interface

uses Classes, Types, SysUtils, GR32, GR32_Blend, GR32_Transforms, GR32_Filters,
     Graphics, bass, U_BassPlayer, Math;

type
  TVector = record
    x,y,z: Double;
    color: TColor32;
  end;

  TGrid = array[0..63, 0..63] of TVector;

  TDotSphere = class(TObject)
  private
    FDots      : array of TVector;
    FDrawDots  : array of TVector;
    FDotsWidth : Integer;
    FDotsHeight: Integer;
    FBaseRad   : Double;
    FMaxRad    : Double;
    FFFT       : TFFTDataLong;
    FFFTOld    : TFFTDataLong;
  public
    constructor Create(BaseRad, MaxRad: Double; DotsWidth, DotsHeight: Integer);
    procedure DrawSphere(out bmp: TBitmap32; Source: TBassplayer; color: TColor32; const xRot, yRot, zRot: Double);
  end;

procedure InitFFTGrid(bmp: TBitmap32);
procedure DrawVisGrid(var bmp: TBitmap32; const Source: TBassplayer; color: TColor32; xRot, yRot: Double);
procedure DrawVisWave(var bmp: TBitmap32; const Source: TBassplayer; color: TColor32);
procedure DrawVisWaveAlt(var bmp: TBitmap32; const Source: TBassplayer; color: TColor32);
procedure DrawVisFFTBMP(var bmp: TBitmap32; const Source: TBassplayer);
procedure DrawVisLightning(var bmp: TBitmap32; const Source: TBassplayer; color: TColor32);
procedure DrawVisSphere(var bmp: TBitmap32; Source: TBassplayer; color: TColor32; const xRot, yRot, zRot: Double);
procedure DrawVisVolume(var bmp: TBitmap32; const Source: TBassplayer);

procedure InitVanish(color: TColor32);
procedure VanishToBGColor(var bmp: TBitmap32);
procedure ChangeBrightness(var bmp: TBitmap32; amount: Integer);
procedure PrepareBMPRotation(const bmp: TBitmap32; alpha: Single);
procedure RotateBMP(out obmp: TBitmap32; const bmp: TBitmap32);
procedure Stretch(out obmp: TBitmap32; const bmp: TBitmap32);
procedure GlareBlur(out obmp: TBitmap32; const bmp: TBitmap32);

procedure HalftoneMask(out obmp: TBitmap32; const bmp: TBitmap32);

procedure InitScope(path: String);
procedure ApplyScope(var bmp: TBitmap32);


var
  buf            : TBitmap32;
  ScopeCanvasMask: TBitmap32;
  DarkenBMP      : TBitmap32;
  FFTBMP         : TBitmap32;
  FFTBMP_X       : Integer;
  i, m           : Integer;                 // just counters for initialization-part
  FFT            : TFFTData;
  FFTLong        : TFFTDataLong;
  dFFT           : array[0..512] of Double;
  OlddFFT        : array[0..512] of Double;
  WaveData       : TWaveData;
  WaveDataLong   : TWaveDataLong;
  bowArray       : array[0..256] of Double; // holds scaled cosine-values precalculated for the bent WaveVis
  lVol, rVol     : Double;
  FFTGrid        : TGrid;
  rg             : TGrid;
  xOff, yOff     : Double;
  rot1, rot2     : Double;
  DSphere        : TDotSphere;
  ta             : TAffineTransformation;
  tt             : TTransformation;

implementation

uses FKBassPlayer; //Wegen VisImagePath

//------------------------------------------------------------------------------
//------- Here comes the masterpiece *g*: The FFT-Grid.                 --------
//------- I actually don't know what i did IN DETAIL here, but i did my --------
//------- best to comment it as properly as possible.                   --------
// SECTION BEGIN ---------------------------------------------------------------
procedure InitFFTGrid(bmp: TBitmap32);
var
  x,  y : Integer;
  xo, yo: Double;
begin
  xOff := (bmp.Width/2);
  yOff := (bmp.Height/2);
  xo := (length(FFTGrid)/2);
  yo := (length(FFTGrid[0])/2);
  for y := 0 to length(FFTGrid[0])-1 do
  begin
    for x := 0 to length(FFTGrid)-1 do
    begin
      FFTGrid[x,y].x := (x - xo)*4;
      FFTGrid[x,y].y := (y - yo)*4;
      FFTGrid[x,y].z := 0;
      FFTGrid[x,y].color := Color32(0,0,0,0);
    end;
  end;
end;

procedure DrawVisGrid(var bmp: TBitmap32; const Source: TBassplayer; color: TColor32; xRot, yRot: Double);

  procedure Rotate(const g: TGrid; out o: TGrid; x,y,z: Double);
  var
    sinX, cosX,
    sinY, cosY,
    sinZ, cosZ : Double;
    xx, yy     : Integer;
    sx, sy, sz : Double;
  begin
    sinX := sin(x);
    sinY := sin(y);
    sinZ := sin(z);
    cosX := cos(x);
    cosY := cos(y);
    cosZ := cos(z);
// I didn't choose the following procedure for this, because 'sincos' wants
// parameters to be type of Extended, which is several times slower than Double
// And the FPU will thank me for that :)
//    sincos(x, sinX, cosX);
//    sincos(y, sinY, cosY);
//    sincos(z, sinZ, cosZ);
    for yy := 0 to length(g[0])-1 do
    begin
      for xx := 0 to length(g)-1 do
      begin
        sx := g[xx,yy].x;
        sy := g[xx,yy].y;
        sz := g[xx,yy].z;
        o[xx,yy].x := sx*(cosY*cosZ)                - sy*(cosY*sinZ)                + sz*(sinY);
        o[xx,yy].y := sx*(sinX*sinY*cosZ+cosX*sinZ) - sy*(sinX*sinY*sinZ-cosX*cosZ) - sz*(sinX*cosY);
        o[xx,yy].z := 0;
        o[xx,yy].color := 0;
      end;
    end;
  end;

var
  x, y     : Integer;
  i, m     : Integer;
  m2       : Integer;
  c        : Integer;
  r,g,b,a  : Integer;
  half, len: Integer;
  cSub     : Double;
  nZ       : Double;
begin
  r := 0;
  g := 0;
  b := 0;
  FFT := Source.getfftdata;
  cSub := 512 / length(FFTGrid);

  // Makes the Y-Values of the grid shift one grid-point away from the middle,
  // and decreases the Y-Value in respect to their distance to the middle-line
  // to let it appear "falling"
  // Also makes the Color more transparent (in a way that it'll be fully
  // transparent when the Value reaches the border -> "cSub" is for that)
  for y := 0 to length(FFTGrid[0])-1 do
  begin
    { process the leftmost part of the grid }
    for x := 0 to (length(FFTGrid) div 2)-1 do
    begin
      a := AlphaComponent(FFTGrid[x+1,y].color);
      if a > 0 then
      begin
        a := trunc(a-cSub);
        r := RedComponent  (FFTGrid[x+1,y].color);
        g := GreenComponent(FFTGrid[x+1,y].color);
        b := BlueComponent (FFTGrid[x+1,y].color);
        if a < 0 then a := 0;
      end;
      FFTGrid[x,y].color := Color32(r,g,b,a);

      nZ := FFTGrid[x+1,y].z;
      if nZ > 1 then
      begin
        nZ := nZ - abs(FFTGrid[x-1,y].x)/30;
        if nZ < 0 then nZ := 0;
      end
      else nZ := 0;
      FFTGrid[x,y].z := nZ;
    end;

    { process the rightmost part of the grid }
    for x := length(FFTGrid)-1 downto (length(FFTGrid) div 2) do
    begin
      a := AlphaComponent(FFTGrid[x-1,y].color);
      if a > 0 then
      begin
        a := trunc(a-cSub);
        r := RedComponent  (FFTGrid[x-1,y].color);
        g := GreenComponent(FFTGrid[x-1,y].color);
        b := BlueComponent (FFTGrid[x-1,y].color);
        if a < 0 then a := 0;
      end;
      FFTGrid[x,y].color := Color32(r,g,b,a);

      nZ := FFTGrid[x-1,y].z;
      if nZ > 1 then
      begin
        nZ := nZ - abs(FFTGrid[x-1,y].x)/30;
        if nZ < 0 then nZ := 0;
      end
      else nZ := 0;
      FFTGrid[x,y].z := nZ;
    end;
  end;

  //----------------------------------------------------------------------------

  // Here the two new middle lines are prepared.
  // Colorbrightness depends on the FFT-Values.
  // If a new value is lower than the former one at a grid-point, the old value
  // is just decreased by a constant value (here: 1), to make the vis more
  // smooth. If the new value is greater, then it is taken "as is" to keep
  // the vis accurate.
  // A little tricky here:
  // There are 2 middle lines (at index 31 and 32), and the FFT-Data in the
  // array is left-right-interleaved - meaning that all even indeces belong to
  // the left channel, and all odd ones to the right channel.
  // To keep this possible in just one loop, the line-index is given by the
  // variable "len" (name does not match it's function anymore :\ ), which will
  // be "31" for all even indeces, and "32" for all odd ones.
  // This is the meaning of "len := half + (i mod 2);" right after the "repeat".
  // (half is 31 here, because the grid-array has 64 elements in x-extent.
  // Thus the real half would be 31.5, and we, as you know, want to alter
  // between 31 and 32, and the index "31.5" doesn't even exist ;))
  // Another thing:
  // "i" starts with "6" because 0 and 1 contain channel-volume, and 2..5
  // represent very low frequencies that are usually very loud and thus would
  // result in very outstanding grid-points, what didn't really look good ;)
  // "m" represents the y-index of the grid, but is divided by 2 in the loop,
  // because we need the same y-index two times: one for the left-channel-data,
  // and again for the right-channel-data.
  i := 6;
  m := 0;
  half := 31;
  repeat
    len := half + (i mod 2);
    m2 := m div 2;

    c := trunc(FFT[i]*1024);
    if c > 255 then c := 255;
    r := RedComponent(color) + c;
    g := GreenComponent(color) + c;
    b := BlueComponent(color) + c;
    if r > 255 then r := 255;
    if g > 255 then g := 255;
    if b > 255 then b := 255;
    if AlphaComponent(FFTGrid[len, m2].color) > c+10 then
      FFTGrid[len, m2].color := Color32(r,g,b,AlphaComponent(FFTGrid[len, m2].color)-10)
    else
      FFTGrid[len, m2].color := Color32(r,g,b,c);

    nZ:= FFT[i]*300;
    if FFTGrid[len, m2].z > nZ then
      FFTGrid[len, m2].z := FFTGrid[len, m2].z - 1
    else
      FFTGrid[len, m2].z := nZ;

    inc(i);
    inc(m);
  until (m > length(FFTGrid[0])*2-1);

  //----------------------------------------------------------------------------

  // rotate the entire grid by the specified angles
  Rotate(FFTGrid, rg, yRot, 0, xRot);

  //----------------------------------------------------------------------------

  // finally draw the grid to the bitmap given as var-paramenter
  // with respect to the offsets calculated by the procedure "InitFFTGrid",
  // and 30 pixels lower, just because it looks better :)
  for y := 0 to length(FFTGrid[0])-2 do
  begin
    for x := 0 to length(FFTGrid)-2 do
    begin
      bmp.LineFS(rg[x,y  ].x+xOff,
                 rg[x,y  ].y+yOff+30,
                 rg[x,y+1].x+xOff,
                 rg[x,y+1].y+yOff+30,
                 FFTGrid[x,y].color);

      bmp.LineFS(rg[x  ,y].x+xOff,
                 rg[x  ,y].y+yOff+30,
                 rg[x+1,y].x+xOff,
                 rg[x+1,y].y+yOff+30,
                 FFTGrid[x,y].color);
    end;
  end;
end;
//******************************************************************************
//******* The FFT-Grid *********************************************************
// END OF SECTION **************************************************************

{______________________________________________________________________________}

//------------------------------------------------------------------------------
//------- The Wave-Form-Visual -------------------------------------------------
// SECTION BEGIN ---------------------------------------------------------------
procedure DrawVisWave(var bmp: TBitmap32; const Source: TBassplayer; color: TColor32);
var
  i, k          : Integer;
  r, g, b       : Integer;
  l1, l2, r1, r2: Double;
  c1, c2        : Integer;
begin
  WaveData := Source.getwavedata;
  i := 0;
  k := 0;
  l1 := 100 + bowArray[k];
  r1 := 300 - bowArray[k];
  repeat
    // [sample] + [yOffset] + [bow (to get the line "round")]
    l2 := (WaveData[i+2] div 512) + 100 + bowArray[k];
    r2 := (WaveData[i+3] div 512) + 300 - bowArray[k];

    c1 := abs(WaveData[i+2] div 128); // same as l2, but absolute and *4
    c2 := abs(WaveData[i+3] div 128); // same as r2, but absolute and *4

    r := RedComponent(color)   + c1;
    g := GreenComponent(color) + c1;
    b := BlueComponent(color)  + c1;
    if r > 255 then r := 255;
    if g > 255 then g := 255;
    if b > 255 then b := 255;
    bmp.LineFS(i, l1, i+2, l2, Color32(r,g,b));

    r := RedComponent(color)   + c2;
    g := GreenComponent(color) + c2;
    b := BlueComponent(color)  + c2;
    if r > 255 then r := 255;
    if g > 255 then g := 255;
    if b > 255 then b := 255;
    bmp.LineFS(i, r1, i+2, r2, Color32(r,g,b));
    inc(i, 2);
    inc(k);
    l1 := l2;
    r1 := r2;
  until i >= Length(WaveData)-3;
end;
//******************************************************************************
//******* The Wave-Form-Visual *************************************************
// END OF SECTION **************************************************************

{______________________________________________________________________________}

//------------------------------------------------------------------------------
//------- The Wave-Form-Visual (alternative) -----------------------------------
//------- The wave-data here is "squashed" by a factor of 4 so the vis ---------
//------- displays roundabout a 4 times longer time-period than the    ---------
//------- other Wave-Form-Visual                                       ---------
// SECTION BEGIN ---------------------------------------------------------------
procedure DrawVisWaveAlt(var bmp: TBitmap32; const Source: TBassplayer; color: TColor32);
var
  i, m, k       : Integer;
  r, g, b       : Integer;
  l1, l2, r1, r2: Double;
  c1, c2        : Integer;
begin
  WaveDataLong := Source.getwavedatalong;
  i := 0;
  m := 0;
  k := 0;
  l1 := 100+bowArray[0];
  r1 := 300-bowArray[0];
  repeat
    // [sample] + [yOffset] + [bow (to get the line "round")]
    l2 := (WaveDataLong[i+8] div 512) + 100 + bowArray[k];
    r2 := (WaveDataLong[i+9] div 512) + 300 - bowArray[k];

    c1 := abs(WaveDataLong[i+8] div 128); // same as l2, but absolute and *4
    c2 := abs(WaveDataLong[i+9] div 128); // same as r2, but absolute and *4

    r := RedComponent(color)   + c1;
    g := GreenComponent(color) + c1;
    b := BlueComponent(color)  + c1;
    if r > 255 then r := 255;
    if g > 255 then g := 255;
    if b > 255 then b := 255;
    bmp.LineFS(m, l1, m+2, l2, Color32(r,g,b));

    r := RedComponent(color)   + c2;
    g := GreenComponent(color) + c2;
    b := BlueComponent(color)  + c2;
    if r > 255 then r := 255;
    if g > 255 then g := 255;
    if b > 255 then b := 255;
    bmp.LineFS(m, r1, m+2, r2, Color32(r,g,b));
    inc(i, 8);
    inc(m, 2);
    inc(k);
    l1 := l2;
    r1 := r2;
  until i >= Length(WaveDataLong)-9;
end;
//******************************************************************************
//******* The Wave-Form-Visual (alternative) ***********************************
// END OF SECTION **************************************************************

{______________________________________________________________________________}

//------------------------------------------------------------------------------
//------- The FFT-Bitmap -------------------------------------------------------
// SECTION BEGIN ---------------------------------------------------------------
procedure DrawVisFFTBMP(var bmp: TBitmap32; const Source: TBassplayer);
var
  i, m1, m2 : Integer;
  r, g, a, t: Integer;
begin
  // 27x26 is origin;
  FFTLong := Source.getfftdatalong;
  i := 2;
  m1 := 347 div 2;
  m2 := 347 div 2 + 1;
  repeat
    r := trunc(FFTLong[i  ]*2048);
    g := trunc(FFTLong[i+1]*2048);
    if r > 255 then r := 255;
    if g > 255 then g := 255;
    a := (r+g) div 2;
    FFTBMP.PixelS[FFTBMP_X, m1] := Color32(r, g, 0, a);
    t := r;
    r := g;
    g := t;
    FFTBMP.PixelS[FFTBMP_X, m2] := Color32(r, g, 0, a);
    inc(i,2);
    dec(m1);
    inc(m2);
  until m1 < 0;
  inc(FFTBMP_X);
  if FFTBMP_X > 347 then FFTBMP_X := 0;
  FFTBMP.DrawTo(bmp, 27, 26);
end;
//******************************************************************************
//******* The FFT-Bitmap *******************************************************
// END OF SECTION **************************************************************

{______________________________________________________________________________}

//------------------------------------------------------------------------------
//------- Lightning Visual -----------------------------------------------------
// SECTION BEGIN ---------------------------------------------------------------
{ How does it work?
  This is very simple. The Waveforms that are taken to draw the WaveVisual are
  here starting in the center of the bitmap, and are randomly rotated.
  Because of the rotation the code actually does not look so simple, but the
  idea is ;)
  Additionally the Waveform is scaled: The smaller the more near it is to the
  center.
  Color gets brighter with higher volume, as everywhere else here :)           }
procedure DrawVisLightning(var bmp: TBitmap32; const Source: TBassplayer; color: TColor32);
var
  Cx, Cy,
  Dx, Dy,
  Fx, Fy,
  d, w,
  x1, x2, y1, y2, vl,
  CosR1, SinR1,
  CosR2, SinR2: Double;
  i           : Integer;
const
  pi2: Double = 6.283; // 2*pi
begin
  if Source.LeftPeak+Source.RightPeak > 32 then
  begin
    WaveData := Source.getwavedata;
    Cx := bmp.Width/2;
    Cy := bmp.Height/2;
    if random(10) = 0 then rot1 := random*pi2;
    if random(10) = 0 then rot2 := random*pi2;
    CosR1 := cos(rot1)*10;
    SinR1 := sin(rot1)*10;
    CosR2 := cos(rot2)*10;
    SinR2 := sin(rot2)*10;

    // Draw Channel 1
    Dx := Cx+CosR1;
    Dy := Cy+SinR1;
    x1 := Cx;
    y1 := Cy;
    i  := 0;
    repeat
      Fx := Dx-Cx;
      Fy := Dy-Cy;
      vl := sqrt(sqr(Fx)+sqr(Fy));
      d  := vl / 128;
      w  := (WaveData[i] / 128)*d;
      x2 := Dx+(Fy / vl)*w;
      y2 := Dy-(Fx / vl)*w;
      bmp.LineFS(x1, y1, x2, y2, Lighten(color, i*3));
      x1 := x2;
      y1 := y2;
      Dx := Dx + CosR1;
      Dy := Dy + SinR1;
      inc(i, 4);
    until i >= 80;

    // Draw Channel 2
    Dx := Cx+CosR2;
    Dy := Cy+SinR2;
    x1 := Cx;
    y1 := Cy;
    i  := 1;
    repeat
      Fx := Dx-Cx;
      Fy := Dy-Cy;
      vl := sqrt(sqr(Fx)+sqr(Fy));
      d  := vl / 128;
      w  := (WaveData[i] / 128)*d;
      x2 := Dx+(Fy / vl)*w;
      y2 := Dy-(Fx / vl)*w;
      bmp.LineFS(x1, y1, x2, y2, Lighten(color, i*3));
      x1 := x2;
      y1 := y2;
      Dx := Dx + CosR2;
      Dy := Dy + SinR2;
      inc(i, 4);
    until i >= 80;
  end;
end;
//******************************************************************************
//******* Lightning Visual *****************************************************
// END OF SECTION **************************************************************

{______________________________________________________________________________}

//------------------------------------------------------------------------------
//------- Dot-Sphere Visual ----------------------------------------------------
// SECTION BEGIN ---------------------------------------------------------------
procedure DrawVisSphere(var bmp: TBitmap32; Source: TBassplayer; color: TColor32; const xRot, yRot, zRot: Double);
begin
  DSphere.DrawSphere(bmp, Source, color, xRot, yRot, zRot);
end;
//******************************************************************************
//******* Dot-Sphere Visual ****************************************************
// END OF SECTION **************************************************************

{______________________________________________________________________________}

//------------------------------------------------------------------------------
//------- The Volume-Bars ------------------------------------------------------
// SECTION BEGIN ---------------------------------------------------------------
{ How does it work?
  At first the volumes is "smoothed". This is done by checking whether the new
  volume is lower or greater than the former one.
  If it is lower, then not the actual new vlomue is taken, but the former one
  slightly decreased.
  If it is greater, the value is just taken "as is".
  The resulting volume-values are taken to calculate an angle between 0 and
  (3/4)*pi.
  (Pi would make a 180°-turn, and i didn't want the bars to clap together at
  max-volume -> thus i took (3/4)*pi.)
  The channel-volume is also the base for calculating the colors. Low volume
  produces green color, and the higher the volume gets, the more the color turns
  into red.
  Then when drawing the bars, i use a loop that draws the lines for all volumes
  that are lower or equal to the actual value, because just drawing the line
  for the actual value wouldn't result in "bars" but simple two dancing lines...
  The constant numbers in the drawing-routines are depending on where the bars
  should appear, and how large the inner and outer ellipse should be.
  (They are constant here because it is faster.)                               }
procedure DrawVisVolume(var bmp: TBitmap32; const Source: TBassplayer);
var
  lv, rv    : Double;
  m         : Double;
  c         : Integer;
  sinM, cosM: Extended;
const
  step: Double = 0.02;
begin
  lv := Source.LeftPeak  div 175;
  rv := Source.RightPeak div 175;
  if lv > 128 then lv := 0;
  if rv > 128 then rv := 0;
  lv := 0.018407769*lv; // := 0.005859375*lv*pi;  // := (lv / 128)*(pi/4)*3;  <--- is same
  rv := 0.018407769*rv; // := 0.005859375*rv*pi;  // := (rv / 128)*(pi/4)*3;  <--- is same

  if lv < lVol then
    lVol := lVol - 0.125
  else
    lVol := lv;

  if rv < rVol then
    rVol := rVol - 0.125
  else
    rVol := rv;

  m := 0;
  repeat
    c := trunc(108.2253613*m); // := trunc(340*m / pi); <--- // := trunc((m * 255) / ((3/4)*pi));  <--- is same
    sincos(m, sinM, cosM);
    bmp.LineF(200+120*-sinM,
              200+150* cosM,
              200+180*-sinM,
              200+180* cosM,
              Color32(c,255-c,32));
    m := m + step;
  until m > lVol;

  m := step;
  repeat
    c := trunc(108.2253613*m); // := trunc(340*m / pi); <--- // := trunc((m * 255) / ((3/4)*pi));  <--- is same
    sincos(m, sinM, cosM);
    bmp.LineF(200-120*-sinM,
              200+150* cosM,
              200-180*-sinM,
              200+180* cosM,
              Color32(c,255-c,32));
    m := m + step;
  until m > rVol;
end;
//******************************************************************************
//******* The Volume-Bars ******************************************************
// END OF SECTION **************************************************************

{______________________________________________________________________________}

//------------------------------------------------------------------------------
//------- Blur and other FX ----------------------------------------------------
// SECTION BEGIN ---------------------------------------------------------------
procedure InitVanish(color: TColor32);
begin
  DarkenBMP.Clear(color);
end;

procedure VanishToBGColor(var bmp: TBitmap32);
begin
  DarkenBMP.DrawTo(bmp);
end;

procedure ChangeBrightness(var bmp: TBitmap32; amount: Integer);  // Now replaced by VanishToBGColor as I
var i: Integer;                                                   // wanted other colors than black possible
    p: PColor32;                                                  // for the background. Thus its actually
begin                                                             // unused now.
  p := bmp.PixelPtr[0,0];
  for i := 0 to bmp.Width*bmp.Height-1 do
  begin
    p^ := Lighten(p^, amount);
    inc(p);
  end;
end;

procedure PrepareBMPRotation(const bmp: TBitmap32; alpha: Single);
begin
  ta.Clear;
  tt.SrcRect := FloatRect(0, 0, bmp.Width-1, bmp.Height-1);
  ta.Rotate(bmp.Width/2, bmp.Height/2, alpha);
end;

procedure RotateBMP(out obmp: TBitmap32; const bmp: TBitmap32);
begin
  Transform(obmp, bmp, tt);
end;

procedure Stretch(out obmp: TBitmap32; const bmp: TBitmap32);
begin
  bmp.DrawTo(obmp, Rect(0,0,bmp.Width-1,bmp.Height-1), Rect(5,5,bmp.Width-6,bmp.Height-6));
end;

procedure GlareBlur(out obmp: TBitmap32; const bmp: TBitmap32);
var
  x, y: Integer;
  Cx, Cy: Double;
  Dx, Dy: Double;
begin
  bmp.OuterColor := DarkenBMP.Pixel[1,1];
  Cx := bmp.Width/2;
  Cy := bmp.Height/2;
  for y := 0 to bmp.Height-1 do
  begin
    Dy := y-Cy;
    for x := 0 to bmp.Width-1 do
    begin
      Dx := x-Cx;
      obmp.PixelS[x, y] := CombineReg(bmp.PixelS[round(Cx+Dx*1.1),
                                                 round(Cy+Dy*1.1)],
                                      bmp.PixelS[round(Cx+Dx*0.9),
                                                 round(Cy+Dy*0.9)],
                                                 127);
      EMMS;
    end;
  end;
end;

//******************************************************************************
//******* Blur and other FX ****************************************************
// END OF SECTION **************************************************************

{______________________________________________________________________________}

//------------------------------------------------------------------------------
//------- Raster-Overlay -------------------------------------------------------
// SECTION BEGIN ---------------------------------------------------------------
procedure HalftoneMask(out obmp: TBitmap32; const bmp: TBitmap32);
var
  x, y: Integer;
  yEven: Boolean;
begin
  for y := 0 to bmp.Height-1 do
  begin
    yEven := (y mod 2) = 0;
    for x := 0 to bmp.Width-1 do
    begin
      if (x mod 2 = 0) and yEven then
        obmp.PixelS[x,y] := Lighten(bmp.PixelS[x,y], -64)
      else
        obmp.PixelS[x,y] := bmp.PixelS[x,y];
    end;
  end;
end;
//******************************************************************************
//******* Raster-Overlay *******************************************************
// END OF SECTION **************************************************************

{______________________________________________________________________________}

//------------------------------------------------------------------------------
//------- Applies the round mask to the vis-bitmap, so it fits the viewport ----
// SECTION BEGIN ---------------------------------------------------------------
procedure InitScope(path: String);
begin
  ScopeCanvasMask.LoadFromFile(path+visimagepath+'scopecanvasmask.bmp');
end;

procedure ApplyScope(var bmp: TBitmap32);
begin
  IntensityToAlpha(bmp, ScopeCanvasMask);
end;
//******************************************************************************
//******* Applies the round mask to the vis-bitmap, so it fits the viewport ****
// END OF SECTION **************************************************************

{______________________________________________________________________________}
{______________________________________________________________________________}


{ TDotSphere }
{ Class for making the SphereVis. This was pretty much "Try and Error", although
  i knew what i wanted to see in the end :)
  Some trigonometry and vector operations in here. Basic idea is:
  A sphere of dots (vectors from shpere-center) is made, with a base-radius.
  Then the FFT-Data from BASS.DLL is taken to modify the vector-lengths
  according to the values of the FFT-Data, and a sort of MaxRadius. (Often more,
  because i didn't find out the maximum output of BASS's FFT. It was more
  designed to look good, than beeing mathematically correct.)
  Further on i wanted the low frequencies to affect the "equator". They will
  mostly produce the highest values, so the result looks a little bit like
  a galaxy (not too much, i know :) ).
  That was the part with most of try & error in it, because the creation-order
  of the vectors is quite... odd *g*. I'm glad i made it with iterating the
  dot-array lineary. That was crutial for making it fast enough!               }

constructor TDotSphere.Create(BaseRad, MaxRad: Double; DotsWidth, DotsHeight: Integer);
var
  i, m: Integer;
  a, b: Double;
begin
  SetLength(FDots, DotsWidth*DotsHeight);
  SetLength(FDrawDots, DotsWidth*DotsHeight);
  FDotsWidth  := DotsWidth;
  FDotsHeight := DotsHeight;
  FBaseRad := BaseRad;
  FMaxRad  := MaxRad;
  a := (2*pi)/(DotsWidth);
  b := (2*pi)/(DotsHeight);
  for i := 0 to DotsHeight-1 do
  begin
    for m := 0 to DotsWidth-1 do
    begin
      FDots[i*DotsWidth + m].x := BaseRad*sin(m*a)*cos(i*b);
      FDots[i*DotsWidth + m].y := BaseRad*sin(i*b);
      FDots[i*DotsWidth + m].z := BaseRad*cos(m*a)*cos(i*b);

// Alternative Shapes
//      FDots[i*DotsWidth + m].x := BaseRad*cos(i*a)*sin(m*a);
//      FDots[i*DotsWidth + m].y := BaseRad*cos(m*a)*sin(i*b);
//      FDots[i*DotsWidth + m].z := BaseRad*sin(m*a)*cos(m*b);

//      FDots[i*DotsWidth + m].x := BaseRad*cos(m*a)*cos(i*b);
//      FDots[i*DotsWidth + m].y := BaseRad*sin(m*a)*cos(i*b);
//      FDots[i*DotsWidth + m].z := BaseRad*sin(m*a)*sin(i*b);

//      FDots[i*DotsWidth + m].x := BaseRad*cos(m*a)*sin(i*b);
//      FDots[i*DotsWidth + m].y := BaseRad*cos(i*b);
//      FDots[i*DotsWidth + m].z := BaseRad*sin(m*a)*cos(i*b);
    end;
  end;
end;

procedure TDotSphere.DrawSphere(out bmp: TBitmap32; Source: TBassplayer; color: TColor32; const xRot, yRot, zRot: Double);
var
  C: TVector;
  i: Integer;
  sinX, cosX,
  sinY, cosY,
  sinZ, cosZ : Double;
  h: Integer;
  sx, sy, sz: Double;
  fact: Double;
  ind: Integer;
  d: Double;
begin
  FFFT := Source.getfftdatalong;
  C.x := bmp.Width/2;
  C.y := bmp.Height/2;
  C.z := 0;
  sinX := sin(xRot);
  sinY := sin(yRot);
  sinZ := sin(zRot);
  cosX := cos(xRot);
  cosY := cos(yRot);
  cosZ := cos(zRot);
  d := 16*(FMaxRad-FBaseRad);
  h := (Length(FDrawDots) div 2)-1;


  for i := 0 to h do
  begin
    ind := 2*i+16;

    if FFFT[ind] < FFFTOld[ind] then
      FFFT[ind] := FFFTOld[ind]-0.001;

    fact := FFFT[ind]*d;
    FDrawDots[i].x := FDots[i].x + (FDots[i].x/FBaseRad)*fact;
    FDrawDots[i].y := FDots[i].y + (FDots[i].y/FBaseRad)*fact;
    FDrawDots[i].z := FDots[i].z + (FDots[i].z/FBaseRad)*fact;
  end;

  for i := h+1 to Length(FDrawDots)-1 do
  begin
    ind := 2*(i-h+1)+17;
    if FFFT[ind] < FFFTOld[ind] then
      FFFT[ind] := FFFTOld[ind]-0.001;

    fact := FFFT[ind]*d;
    FDrawDots[i].x := FDots[i].x + (FDots[i].x/FBaseRad)*fact;
    FDrawDots[i].y := FDots[i].y + (FDots[i].y/FBaseRad)*fact;
    FDrawDots[i].z := FDots[i].z + (FDots[i].z/FBaseRad)*fact;
  end;

  for i := 0 to Length(FDrawDots)-1 do
  begin
    sx := FDrawDots[i].x;
    sy := FDrawDots[i].y;
    sz := FDrawDots[i].z;
    FDrawDots[i].x := sx*( cosY*cosZ)                - sy*(cosY*sinZ)                + sz*(sinY);
    FDrawDots[i].y := sx*( sinX*sinY*cosZ+cosX*sinZ) - sy*(sinX*sinY*sinZ-cosX*cosZ) - sz*(sinX*cosY);
    FDrawDots[i].z := sx*(-cosX*sinY*cosZ+sinX*sinZ) + sy*(cosX*sinY*sinZ+sinX*cosZ) + sz*(cosX*cosY);
    FDrawDots[i].color := Lighten(color, trunc(FDrawDots[i].z*3));
    bmp.PixelS[round(FDrawDots[i].x+C.x),round( FDrawDots[i].y+C.y)] := FDrawDots[i].color;
  end;

  Move(FFFT[0], FFFTOld[0], Length(FFFT)*SizeOf(Float));
end;

{______________________________________________________________________________}
{______________________________________________________________________________}


initialization
  buf  := TBitmap32.Create;
  buf.DrawMode := dmBlend;
  FFTBMP := TBitmap32.Create;
  FFTBMP.DrawMode := dmBlend;
  FFTBMP.Width := 347;
  FFTBMP.Height := 347;
  FFTBMP.Clear(Color32(0,0,0,0));
  FFTBMP_X := 0;
  ScopeCanvasMask := TBitmap32.Create;
  DarkenBMP := TBitmap32.Create;
  DarkenBMP.Width  := 400;
  DarkenBMP.Height := 400;
  DarkenBMP.DrawMode := dmBlend;
  ta := TAffineTransformation.Create;
  tt := ta;
  m := 0;
  for i := 0 to 256 do
  begin
    bowArray[i] := (cos((200-m)/100) * 50);
    inc(m,2);
  end;
  DSphere := TDotSphere.Create(30, 150, 40, 50);

finalization
  buf.Free;
  FFTBMP.Free;
  ScopeCanvasMask.Free;
  DarkenBMP.Free;
  ta.Free;
  DSphere.Free;

end.
