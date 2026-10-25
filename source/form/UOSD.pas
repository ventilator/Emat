unit UOSD;
{ Port: On-Screen-Display as a layered, click-through LCL form.

  The Delphi version drew straight into the desktop DC (GetWindowDC(0) +
  InvalidateRect) and repainted it on a 100 ms timer so other windows would not
  wipe it. That only worked because the OSD was drawn on top of everything and
  repainted eagerly; it broke with hardware accelerated windows, needed the
  "red display for 3D games" special case, and drew ANSI text.

  This implementation uses a borderless, always-on-top, click-through window
  (WS_EX_LAYERED or WS_EX_TRANSPARENT or WS_EX_NOACTIVATE) that the LCL paints
  with its own UTF-8 aware canvas. Nothing is drawn on the desktop DC, input is
  never stolen, and the OSD disappears by itself. }

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, LCLIntf, LCLType,
  Windows;

type
  { TEmatOSD - the overlay window. Create once, then call ShowOSD. }
  TEmatOSD = class(TForm)
  private
    FTitle: string;
    FSubTitle: string;
    FDuration: string;
    FRed: Boolean;
    FHideAt: QWord;
    FTimer: TTimer;
    procedure TimerTick(Sender: TObject);
    procedure DoPaint(Sender: TObject);
    function  TextFontSize(const S: string): Integer;
    procedure LayoutForText;
  protected
    procedure CreateWnd; override;
    procedure DoShow; override;
  public
    constructor CreateNewOSD(AOwner: TComponent);
    { Shows Title (large), SubTitle (album/year) and Duration, and hides again
      after AMilliseconds. ARed uses the red "3D game" colours. }
    procedure ShowOSD(const ATitle, ASubTitle, ADuration: string;
      ARed: Boolean; AMilliseconds: Integer = 5000);
    procedure HideOSD;
  end;

implementation

const
  OSD_FONT = 'Arial';
  OSD_PAD_X = 34;
  OSD_PAD_Y = 22;
  OSD_FADE  = 700;      // ms of fade-out at the end

constructor TEmatOSD.CreateNewOSD(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Caption := 'EmatOSD';   // not shown (borderless), used to find the window
  BorderStyle := bsNone;
  BorderIcons := [];
  FormStyle := fsStayOnTop;
  ShowInTaskbar := stNever;
  Position := poDesigned;
  Color := clBlack;
  AlphaBlend := True;
  AlphaBlendValue := 250;
  DoubleBuffered := True;
  OnPaint := DoPaint;

  FTimer := TTimer.Create(Self);
  FTimer.Interval := 60;
  FTimer.Enabled := False;
  FTimer.OnTimer := TimerTick;
end;

procedure TEmatOSD.CreateWnd;
var
  Ex: Integer;
begin
  inherited CreateWnd;
  { click-through, never activate, no taskbar button }
  Ex := GetWindowLong(Handle, GWL_EXSTYLE);
  Ex := Ex or WS_EX_LAYERED or WS_EX_TRANSPARENT or WS_EX_NOACTIVATE
           or WS_EX_TOOLWINDOW;
  SetWindowLong(Handle, GWL_EXSTYLE, Ex);
end;

procedure TEmatOSD.DoShow;
begin
  inherited DoShow;
  { a form that must never take focus }
  ShowWindow(Handle, SW_SHOWNOACTIVATE);
end;

function TEmatOSD.TextFontSize(const S: string): Integer;
var
  Base: Integer;
begin
  { same rule as the Delphi code: scale with the screen, but never wider than
    90% of the screen width }
  Base := Screen.Height div 28;
  if Base < 14 then Base := 14;
  if Base > 56 then Base := 56;
  Canvas.Font.Name := OSD_FONT;
  Canvas.Font.Size := Base;
  Result := Base;
  if (S <> '') and (Canvas.TextWidth(S) > 0) then
  begin
    Result := Round(Base * ((Screen.Width * 0.55) / Canvas.TextWidth(S)));
    if Result > Base then Result := Base;
    if Result < 12 then Result := 12;
  end;
end;

procedure TEmatOSD.LayoutForText;
var
  W, H, TitleH, SubH, DurW: Integer;
begin
  Canvas.Font.Name := OSD_FONT;
  Canvas.Font.Size := TextFontSize(FTitle);
  Canvas.Font.Style := [fsBold];
  W := Canvas.TextWidth(FTitle);
  TitleH := Canvas.TextHeight(FTitle);

  SubH := 0;
  if FSubTitle <> '' then
  begin
    Canvas.Font.Size := (Canvas.Font.Size * 2) div 3;
    Canvas.Font.Style := [];
    if Canvas.TextWidth(FSubTitle) > W then W := Canvas.TextWidth(FSubTitle);
    SubH := Canvas.TextHeight(FSubTitle) + 8;
  end;

  DurW := 0;
  if FDuration <> '' then
  begin
    Canvas.Font.Size := (TextFontSize(FTitle) * 2) div 3;
    Canvas.Font.Style := [];
    DurW := Canvas.TextWidth(FDuration) + 24;
  end;

  if W + OSD_PAD_X * 2 + DurW > Screen.Width then
    W := Screen.Width - OSD_PAD_X * 2 - DurW;

  Width  := W + OSD_PAD_X * 2;
  Height := TitleH + SubH + OSD_PAD_Y * 2;

  Left := (Screen.Width - Width) div 2;
  Top  := Round(Screen.Height * 0.80) - Height div 2;
end;

procedure TEmatOSD.ShowOSD(const ATitle, ASubTitle, ADuration: string;
  ARed: Boolean; AMilliseconds: Integer);
begin
  FTitle := ATitle;
  FSubTitle := ASubTitle;
  FDuration := ADuration;
  FRed := ARed;

  AlphaBlendValue := 250;
  LayoutForText;
  if not Visible then Show;
  { position/size may have been clamped by the window manager }
  Invalidate;
  Update;
  BringToFront;

  FHideAt := GetTickCount64 + QWord(AMilliseconds);
  FTimer.Enabled := True;
end;

procedure TEmatOSD.HideOSD;
begin
  FTimer.Enabled := False;
  if Visible then Hide;
  AlphaBlendValue := 250;
end;

procedure TEmatOSD.TimerTick(Sender: TObject);
var
  Now_: QWord;
  Left_: Int64;
begin
  Now_ := GetTickCount64;
  if Now_ >= FHideAt then
  begin
    HideOSD;
    Exit;
  end;
  Left_ := Int64(FHideAt - Now_);
  if Left_ < OSD_FADE then
    AlphaBlendValue := Round(250 * (Left_ / OSD_FADE))
  else
    AlphaBlendValue := 250;
end;

procedure TEmatOSD.DoPaint(Sender: TObject);
var
  R: TRect;
  TitleCol, SubCol: TColor;
begin
  Canvas.Brush.Color := clBlack;
  Canvas.FillRect(ClientRect);
  R := ClientRect;
  Canvas.Brush.Color := clBlack;
  Canvas.Pen.Color := clBlack;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 40, 40);

  if FRed then
  begin
    TitleCol := clRed;
    SubCol := clWhite;
  end
  else
  begin
    TitleCol := clLime;
    SubCol := clSilver;
  end;

  Canvas.Brush.Style := bsClear;
  Canvas.Font.Name := OSD_FONT;
  Canvas.Font.Style := [fsBold];
  Canvas.Font.Size := TextFontSize(FTitle);
  Canvas.Font.Color := TitleCol;
  Canvas.TextOut(OSD_PAD_X, OSD_PAD_Y, FTitle);

  if FSubTitle <> '' then
  begin
    Canvas.Font.Style := [];
    Canvas.Font.Size := (Canvas.Font.Size * 2) div 3;
    Canvas.Font.Color := SubCol;
    Canvas.TextOut(OSD_PAD_X, OSD_PAD_Y + Canvas.TextHeight(FTitle) + 8, FSubTitle);
  end;

  if FDuration <> '' then
  begin
    Canvas.Font.Style := [];
    Canvas.Font.Size := (TextFontSize(FTitle) * 2) div 3;
    Canvas.Font.Color := TitleCol;
    Canvas.TextOut(Width - OSD_PAD_X - Canvas.TextWidth(FDuration),
                   OSD_PAD_Y - Canvas.TextHeight(FDuration) - 4, FDuration);
  end;

  Canvas.Brush.Style := bsSolid;
end;

end.
