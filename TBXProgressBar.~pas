{*******************************************************************************
  Author      : Wojciech Dobrowolski (bromba@swidnik.com.pl)
  Created     : February 6 2004 (Delphi 5)
  Version     : 0.1
  Components  : TTBXProgressBar

  Information:
    Very easy for use :-)
*******************************************************************************}
        //CLGMOD
unit TBXProgressBar;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, TBX, TBXUtils, TBXThemes;

type
  TTBXProgressBar = class(TGraphicControl)
  private
    { Private declarations }
    TempBmp: TBitmap;
    ButBmp: TBitmap;
    FAltMode: boolean;
    FShowPosText: boolean;
    FPercentage: boolean;
    FPosition: integer;
    FMax: integer;
    FMin: integer;
    FPosTextPrefix: string;
    FPosTextSuffix: string;
    procedure SetMax(const Value: integer);
    procedure SetMin(const Value: integer);
    procedure SetPercentage(const Value: boolean);
    procedure SetPosition(const Value: integer);
    procedure SetPosTextPrefix(const Value: string);
    procedure SetPosTextSuffix(const Value: string);
    procedure SetShowPosText(const Value: boolean);
    procedure CMFontChanged(var Message: TMessage); message CM_FontChanged;
  protected
    { Protected declarations }
    procedure Paint; override;
    procedure Resize; override;
  public
    { Public declarations }
    Caption : String;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddPosition(APos: integer);
  published
    { Published declarations }
    property Max: integer read FMax write SetMax default 100;
    property Min: integer read FMin write SetMin default 0;
    property AltMode: boolean read FAltMode write FAltMode;
    property Percentage: boolean read FPercentage write SetPercentage;
    property Position: integer read FPosition write SetPosition;
    property PosTextPrefix: string read FPosTextPrefix write SetPosTextPrefix;
    property PosTextSuffix: string read FPosTextSuffix write SetPosTextSuffix;
    property ShowPosText: boolean read FShowPosText write SetShowPosText;
    property Align;
    property Font;
    property ParentShowHint;
    property ShowHint;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Toolbar2000', [TTBXProgressBar]);
end;

{ TTBXProgressBar }

procedure TTBXProgressBar.AddPosition(APos: integer);
begin
  Position := Position + APos;
end;

procedure TTBXProgressBar.CMFontChanged(var Message: TMessage);
begin
  TempBmp.Canvas.Font.Assign(Self.Font);
  Paint;
end;

constructor TTBXProgressBar.Create(AOwner: TComponent);
begin
  inherited;
  fPosition := 0;
  fMin := 0;
  fMax := 100;
  fPosTextSuffix := '';
  fPosTextPrefix := '';
  fPercentage := False;

  TempBmp := TBitmap.Create;
  TempBmp.PixelFormat:= pf24bit;
  ButBmp := TBitmap.Create;
  ButBmp.PixelFormat:= pf24bit;
  ButBmp.Width:= 10;
end;

destructor TTBXProgressBar.Destroy;
begin
  FreeAndNil(TempBmp);
  FreeAndNil(ButBmp);
  inherited;
end;

procedure TTBXProgressBar.Paint;
var
  info: TTBXItemInfo;
  R: TRect;
  Len: integer;
  Percent: Extended;
  ACap: string;
begin
  TempBmp.Width := Width;
  TempBmp.Height := Height;
  ButBmp.Height := Height;

  with TempBmp do
  begin
    FillChar(info, SizeOf(TTBXItemInfo), 0);

    info.ViewType := TVT_NORMALTOOLBAR or TVT_EMBEDDED;
    info.ItemOptions := IO_APPACTIVE or IO_TOOLBARSTYLE;
    info.Enabled := True;
    info.Pushed := True;
    info.Selected := False;
    info.HoverKind := hkNone;
    info.ImageShown := True;
    if Not AltMode then
      CurrentTheme.PaintButton(Canvas, Canvas.ClipRect, info)
    else // rmk
    begin
      CurrentTheme.PaintButton(ButBmp.Canvas, Rect(0,0,10,Height), info);
      Canvas.CopyRect(Canvas.ClipRect,ButBmp.Canvas,Rect(4,0,5,Height));
      Canvas.Pen.Color:= ButBmp.Canvas.Pixels[4,0];
      Canvas.Brush.Style:= bsClear;
      Canvas.Rectangle(Canvas.ClipRect);
    end;

    Len := FMax - FMin;
    if FMax = FMin then
      Percent := 0 else
      Percent := (fPosition - FMin) / Len;
    r := Canvas.ClipRect;
    r.Right := Round(Width * Percent);

    info.Selected := False;
    info.Pushed := False;
    info.HoverKind := hkMouseHover;
    info.ImageShown := True;

    if not AltMode then
      CurrentTheme.PaintButton(Canvas, r, info)
    else // rmk
    begin
      CurrentTheme.PaintButton(ButBmp.Canvas, Rect(0,0,10,Height), info);
      Canvas.CopyRect(r,ButBmp.Canvas,Rect(4,0,5,Height));
      Canvas.Pen.Color:= ButBmp.Canvas.Pixels[4,0];
      Canvas.Brush.Style:= bsClear;
      Canvas.Rectangle(r);
    end;

    if FPercentAge then
      ACap := IntToStr(Round(Percent * 100))
    else
      aCap := Caption;

    if FShowPosText then
      ACap := fPosTextPrefix + ACap + fPosTextSuffix;

    Canvas.Font := Font;
    with Canvas do
    begin
      Brush.Style := bsClear;
      TextOut((Width - TextWidth(Acap)) div 2, (Height - TextHeight(Acap)) div 2, Acap);
    end;

    Canvas.Brush.Style := bsSolid;
  end;
  Canvas.CopyMode := cmSrcCopy;
  canvas.draw(0, 0, TempBmp);
end;

procedure TTBXProgressBar.Resize;
begin
  inherited;
end;

procedure TTBXProgressBar.SetMax(const Value: integer);
begin
  if FMax = Value then exit;
  FMax := Value;
  Paint;
end;

procedure TTBXProgressBar.SetMin(const Value: integer);
begin
  if FMin = Value then exit;
  FMin := Value;
  Paint;
end;

procedure TTBXProgressBar.SetPercentage(const Value: boolean);
begin
  if FPercentage = Value then exit;
  FPercentage := Value;
  Paint;
end;

procedure TTBXProgressBar.SetPosition(const Value: integer);
begin
  if FPosition = Value then exit;
  if Value > FMax then FPosition := FMax
  else
    if Value < FMin then FPosition := FMin
    else
      FPosition := Value;
  Paint;
end;

procedure TTBXProgressBar.SetPosTextPrefix(const Value: string);
begin
  if FPosTextPrefix = Value then exit;
  FPosTextPrefix := Value;
  Paint;
end;

procedure TTBXProgressBar.SetPosTextSuffix(const Value: string);
begin
  if FPosTextSuffix = Value then exit;
  FPosTextSuffix := Value;
  Paint;
end;

procedure TTBXProgressBar.SetShowPosText(const Value: boolean);
begin
  if FShowPosText = Value then exit;
  FShowPosText := Value;
  Paint;
end;

end.

