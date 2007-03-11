unit rmkGradient;

interface

uses
  Windows, Messages, Graphics, Types;

type
  TGradDir = (tGLeftRight, tGTopBottom);

procedure GradientGlass(const Canvas: TCanvas; const ARect: TRect;
  const Aqua: Boolean; const Direction: TGradDir);
procedure GradientFill(const Canvas: TCanvas; const ARect: TRect;
  const StartColor, EndColor: TColor;
  const Direction: TGradDir);


implementation

procedure GradientGlass(const Canvas: TCanvas; const ARect: TRect;
  const Aqua: Boolean; const Direction: TGradDir);
var
  GSize: Integer;
  rc1, rc2, gc1, gc2, bc1, bc2, rc3, gc3, bc3, rc4, gc4, bc4,
    r, g, b, y1, Counter, i, d1, d2, d3: Integer;

  Brush: HBrush;
begin
  if Aqua then
  begin
    rc1 := $f0; rc2 := $80; rc3 := $70; rc4 := $B0;
    gc1 := $f8; gc2 := $B0; gc3 := $E8; gc4 := $FF;
    bc1 := $FF; bc2 := $E0; bc3 := $F0; bc4 := $FF;
  end else
  begin
    rc1 := $F8; rc2 := $d8; rc3 := $f0; rc4 := $F8;
    gc1 := $F8; gc2 := $d8; gc3 := $f0; gc4 := $F8;
    bc1 := $F8; bc2 := $d8; bc3 := $f0; bc4 := $F8;
  end;

  if Direction = tGTopBottom then
  begin
    GSize := (ARect.Bottom - ARect.Top) - 1;
    y1 := GSize div 3;
    d1 := y1;
    d2 := y1 + y1;
    for i := 0 to y1 do
    begin
      r := rc1 + (((rc2 - rc1) * (i)) div y1);
      g := gc1 + (((gc2 - gc1) * (i)) div y1);
      b := bc1 + (((bc2 - bc1) * (i)) div y1);
      if r < 0 then r := 0 else if r > 255 then r := 255;
      if g < 0 then g := 0 else if g > 255 then g := 255;
      if b < 0 then b := 0 else if b > 255 then b := 255;
      Brush := CreateSolidBrush(
        RGB(r, g, b));
      Windows.FillRect(Canvas.Handle, Rect(ARect.Left, ARect.Top + i, ARect.Right, ARect.Top + i + 1), Brush);
      DeleteObject(Brush);
    end;

    for i := y1 to d2 do
    begin
      r := rc2 + (((rc3 - rc2) * (i - d1)) div y1);
      g := gc2 + (((gc3 - gc2) * (i - d1)) div y1);
      b := bc2 + (((bc3 - bc2) * (i - d1)) div y1);
      if r < 0 then r := 0 else if r > 255 then r := 255;
      if g < 0 then g := 0 else if g > 255 then g := 255;
      if b < 0 then b := 0 else if b > 255 then b := 255;
      Brush := CreateSolidBrush(
        RGB(r, g, b));
      Windows.FillRect(Canvas.Handle, Rect(ARect.Left, ARect.Top + i, ARect.Right, ARect.Top + i + 1), Brush);
      DeleteObject(Brush);
    end;

    for i := d2 to GSize do
    begin
      r := rc3 + (((rc4 - rc3) * (i - d2)) div y1);
      g := gc3 + (((gc4 - gc3) * (i - d2)) div y1);
      b := bc3 + (((bc4 - bc3) * (i - d2)) div y1);
      if r < 0 then r := 0 else if r > 255 then r := 255;
      if g < 0 then g := 0 else if g > 255 then g := 255;
      if b < 0 then b := 0 else if b > 255 then b := 255;
      Brush := CreateSolidBrush(
        RGB(r, g, b));
      Windows.FillRect(Canvas.Handle, Rect(ARect.Left, ARect.Top + i, ARect.Right, ARect.Top + i + 1), Brush);
      DeleteObject(Brush);
    end;
  end else
  begin
    GSize := (ARect.Right - ARect.Left) - 1;
    y1 := GSize div 3;
    d1 := y1;
    d2 := y1 + y1;
    for i := 0 to y1 do
    begin
      r := rc1 + (((rc2 - rc1) * (i)) div y1);
      g := gc1 + (((gc2 - gc1) * (i)) div y1);
      b := bc1 + (((bc2 - bc1) * (i)) div y1);
      if r < 0 then r := 0 else if r > 255 then r := 255;
      if g < 0 then g := 0 else if g > 255 then g := 255;
      if b < 0 then b := 0 else if b > 255 then b := 255;
      Brush := CreateSolidBrush(
        RGB(r, g, b));
      Windows.FillRect(Canvas.Handle, Rect(ARect.Left + i, ARect.Top, ARect.Left + i + 1, ARect.Bottom), Brush);
      DeleteObject(Brush);
    end;
    for i := y1 to d2 do
    begin
      r := rc2 + (((rc3 - rc2) * (i - d1)) div y1);
      g := gc2 + (((gc3 - gc2) * (i - d1)) div y1);
      b := bc2 + (((bc3 - bc2) * (i - d1)) div y1);
      if r < 0 then r := 0 else if r > 255 then r := 255;
      if g < 0 then g := 0 else if g > 255 then g := 255;
      if b < 0 then b := 0 else if b > 255 then b := 255;
      Brush := CreateSolidBrush(
        RGB(r, g, b));
      Windows.FillRect(Canvas.Handle, Rect(ARect.Left + i, ARect.Top, ARect.Left + i + 1, ARect.Bottom), Brush);
      DeleteObject(Brush);
    end;
    for i := d2 to GSize do
    begin
      r := rc3 + (((rc4 - rc3) * (i - d2)) div y1);
      g := gc3 + (((gc4 - gc3) * (i - d2)) div y1);
      b := bc3 + (((bc4 - bc3) * (i - d2)) div y1);
      if r < 0 then r := 0 else if r > 255 then r := 255;
      if g < 0 then g := 0 else if g > 255 then g := 255;
      if b < 0 then b := 0 else if b > 255 then b := 255;
      Brush := CreateSolidBrush(
        RGB(r, g, b));
      Windows.FillRect(Canvas.Handle, Rect(ARect.Left + i, ARect.Top, ARect.Left + i + 1, ARect.Bottom), Brush);
      DeleteObject(Brush);
    end;
  end;
end;

procedure GradientFill(const Canvas: TCanvas; const ARect: TRect;
  const StartColor, EndColor: TColor;
  const Direction: TGradDir);
var
  rc1, rc2, gc1, gc2, bc1, bc2, Counter, GSize: Integer;
  Brush: HBrush;
begin
  rc1 := GetRValue(ColorToRGB(StartColor));
  gc1 := GetGValue(ColorToRGB(StartColor));
  bc1 := GetBValue(ColorToRGB(StartColor));
  rc2 := GetRValue(ColorToRGB(EndColor));
  gc2 := GetGValue(ColorToRGB(EndColor));
  bc2 := GetBValue(ColorToRGB(EndColor));

  if Direction = tGTopBottom then begin
    GSize := (ARect.Bottom - ARect.Top) - 1;
    for Counter := 0 to GSize do
    begin
      Brush := CreateSolidBrush(
        RGB(Byte(rc1 + (((rc2 - rc1) * (Counter)) div GSize)),
        Byte(gc1 + (((gc2 - gc1) * (Counter)) div GSize)),
        Byte(bc1 + (((bc2 - bc1) * (Counter)) div GSize))));
      Windows.FillRect(Canvas.Handle, Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom - Counter), Brush);
      DeleteObject(Brush);
    end;
  end else begin
    GSize := (ARect.Right - ARect.Left) - 1;
    for Counter := 0 to GSize do
    begin
      Brush := CreateSolidBrush(
        RGB(Byte(rc1 + (((rc2 - rc1) * (Counter)) div GSize)),
        Byte(gc1 + (((gc2 - gc1) * (Counter)) div GSize)),
        Byte(bc1 + (((bc2 - bc1) * (Counter)) div GSize))));
      Windows.FillRect(Canvas.Handle, Rect(ARect.Left, ARect.Top, ARect.Right - Counter, ARect.Bottom), Brush);
      DeleteObject(Brush);
    end;
  end;
end;

end.
