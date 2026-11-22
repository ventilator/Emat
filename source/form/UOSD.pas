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
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, StdCtrls, Spin,
  IniFiles, LCLIntf, LCLType, Windows, ULangMgr;

type
  TOSDPosition = (osdBottom, osdTop, osdCenter, osdTopRight);

  { TEmatOSD - the overlay window. Create once, then call ShowOSD. }
  TEmatOSD = class(TForm)
  private
    FTitle: string;
    FSubTitle: string;
    FDuration: string;
    FRed: Boolean;
    FHideAt: QWord;
    FTimer: TTimer;
    FFontSize: Integer;          // 0 = Auto, else 12..72
    FDisplayDurationMs: Integer; // default 5000 ms
    FOSDPosition: TOSDPosition;  // default osdBottom
    FMonitorIndex: Integer;      // -1 = Primary, 0..MonitorCount-1
    FOpacity: Byte;              // 80..255, default 245
    function  ActiveMonitorRect: TRect;
    procedure TimerTick(Sender: TObject);
    procedure DoPaint(Sender: TObject);
    function  TextFontSize(const S: string): Integer;
    procedure LayoutForText;
  protected
    procedure CreateWnd; override;
    procedure DoShow; override;
  public
    constructor CreateNewOSD(AOwner: TComponent);
    procedure LoadSettings(const IniPath: string);
    procedure SaveSettings(const IniPath: string);
    procedure ShowConfigDialog(AOwner: TComponent; const IniPath: string);
    { Shows Title (large), SubTitle (album/year) and Duration, and hides again
      after AMilliseconds (<=0 uses DisplayDurationMs). ARed uses red colours. }
    procedure ShowOSD(const ATitle, ASubTitle, ADuration: string;
      ARed: Boolean; AMilliseconds: Integer = 0);
    procedure HideOSD;
    property FontSize: Integer read FFontSize write FFontSize;
    property DisplayDurationMs: Integer read FDisplayDurationMs write FDisplayDurationMs;
    property OSDPosition: TOSDPosition read FOSDPosition write FOSDPosition;
    property MonitorIndex: Integer read FMonitorIndex write FMonitorIndex;
    property Opacity: Byte read FOpacity write FOpacity;
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
  FFontSize := 0;
  FDisplayDurationMs := 5000;
  FOSDPosition := osdBottom;
  FMonitorIndex := -1;
  FOpacity := 245;

  AlphaBlend := True;
  AlphaBlendValue := FOpacity;
  DoubleBuffered := True;
  OnPaint := DoPaint;

  FTimer := TTimer.Create(Self);
  FTimer.Interval := 60;
  FTimer.Enabled := False;
  FTimer.OnTimer := TimerTick;
end;

function TEmatOSD.ActiveMonitorRect: TRect;
begin
  if (FMonitorIndex >= 0) and (FMonitorIndex < Screen.MonitorCount) then
    Result := Screen.Monitors[FMonitorIndex].WorkareaRect
  else if Screen.PrimaryMonitor <> nil then
    Result := Screen.PrimaryMonitor.WorkareaRect
  else
    Result := Classes.Rect(0, 0, Screen.Width, Screen.Height);
end;

procedure TEmatOSD.LoadSettings(const IniPath: string);
var
  Ini: TIniFile;
  P, Op: Integer;
begin
  if not FileExists(IniPath) then Exit;
  try
    Ini := TIniFile.Create(IniPath);
    try
      FFontSize := Ini.ReadInteger('OSD', 'FontSize', 0);
      if (FFontSize < 0) or (FFontSize > 72) then FFontSize := 0;
      FDisplayDurationMs := Ini.ReadInteger('OSD', 'DurationMs', 5000);
      if FDisplayDurationMs < 1000 then FDisplayDurationMs := 1000;
      if FDisplayDurationMs > 30000 then FDisplayDurationMs := 30000;
      P := Ini.ReadInteger('OSD', 'Position', Ord(osdBottom));
      if (P >= Ord(Low(TOSDPosition))) and (P <= Ord(High(TOSDPosition))) then
        FOSDPosition := TOSDPosition(P);
      FMonitorIndex := Ini.ReadInteger('OSD', 'MonitorIndex', -1);
      Op := Ini.ReadInteger('OSD', 'Opacity', 245);
      if Op < 80 then Op := 80;
      if Op > 255 then Op := 255;
      FOpacity := Byte(Op);
    finally
      Ini.Free;
    end;
  except
  end;
end;

procedure TEmatOSD.SaveSettings(const IniPath: string);
var
  Ini: TIniFile;
begin
  if not DirectoryExists(ExtractFilePath(IniPath)) then Exit;
  try
    Ini := TIniFile.Create(IniPath);
    try
      Ini.WriteInteger('OSD', 'FontSize', FFontSize);
      Ini.WriteInteger('OSD', 'DurationMs', FDisplayDurationMs);
      Ini.WriteInteger('OSD', 'Position', Ord(FOSDPosition));
      Ini.WriteInteger('OSD', 'MonitorIndex', FMonitorIndex);
      Ini.WriteInteger('OSD', 'Opacity', FOpacity);
    finally
      Ini.Free;
    end;
  except
  end;
end;

type
  TOSDConfigHelper = class
    OSD: TEmatOSD;
    SEFont: TSpinEdit;
    SEDur: TSpinEdit;
    CBPos: TComboBox;
    CBMon: TComboBox;
    SEOp: TSpinEdit;
    procedure ApplyToOSD;
    procedure OnTestClick(Sender: TObject);
  end;

procedure TOSDConfigHelper.ApplyToOSD;
begin
  OSD.FontSize := SEFont.Value;
  OSD.DisplayDurationMs := SEDur.Value * 1000;
  if (CBPos.ItemIndex >= 0) and (CBPos.ItemIndex <= Ord(High(TOSDPosition))) then
    OSD.OSDPosition := TOSDPosition(CBPos.ItemIndex);
  OSD.MonitorIndex := CBMon.ItemIndex - 1;
  OSD.Opacity := Byte(SEOp.Value);
end;

procedure TOSDConfigHelper.OnTestClick(Sender: TObject);
begin
  ApplyToOSD;
  OSD.ShowOSD('Emat OSD Vorschau', 'Interpret - Album (2026)', '03:45', False, 0);
end;

procedure TEmatOSD.ShowConfigDialog(AOwner: TComponent; const IniPath: string);
var
  Dlg: TForm;
  Helper: TOSDConfigHelper;
  Lbl: TLabel;
  BtnTest, BtnOK, BtnCancel: TButton;
  i: Integer;
begin
  Dlg := TForm.CreateNew(AOwner);
  Helper := TOSDConfigHelper.Create;
  try
    Helper.OSD := Self;
    Dlg.Caption := Tr('OSD-Einstellungen', 'OSD Settings');
    Dlg.BorderStyle := bsDialog;
    Dlg.Position := poScreenCenter;
    Dlg.ClientWidth := 340;
    Dlg.ClientHeight := 240;

    Lbl := TLabel.Create(Dlg);
    Lbl.Parent := Dlg; Lbl.SetBounds(16, 18, 150, 20);
    Lbl.Caption := Tr('Schriftgröße (0 = Auto):', 'Font Size (0 = Auto):');
    Helper.SEFont := TSpinEdit.Create(Dlg);
    Helper.SEFont.Parent := Dlg; Helper.SEFont.SetBounds(180, 14, 140, 24);
    Helper.SEFont.MinValue := 0; Helper.SEFont.MaxValue := 72;
    Helper.SEFont.Value := FFontSize;

    Lbl := TLabel.Create(Dlg);
    Lbl.Parent := Dlg; Lbl.SetBounds(16, 52, 150, 20);
    Lbl.Caption := Tr('Anzeigedauer (Sek.):', 'Display Duration (sec):');
    Helper.SEDur := TSpinEdit.Create(Dlg);
    Helper.SEDur.Parent := Dlg; Helper.SEDur.SetBounds(180, 48, 140, 24);
    Helper.SEDur.MinValue := 1; Helper.SEDur.MaxValue := 30;
    Helper.SEDur.Value := FDisplayDurationMs div 1000;

    Lbl := TLabel.Create(Dlg);
    Lbl.Parent := Dlg; Lbl.SetBounds(16, 86, 150, 20);
    Lbl.Caption := Tr('Position:', 'Position:');
    Helper.CBPos := TComboBox.Create(Dlg);
    Helper.CBPos.Parent := Dlg; Helper.CBPos.SetBounds(180, 82, 140, 24);
    Helper.CBPos.Style := csDropDownList;
    Helper.CBPos.Items.Add(Tr('Unten (Mitte)', 'Bottom (Center)'));
    Helper.CBPos.Items.Add(Tr('Oben (Mitte)', 'Top (Center)'));
    Helper.CBPos.Items.Add(Tr('Mitte', 'Center'));
    Helper.CBPos.Items.Add(Tr('Oben Rechts', 'Top Right'));
    Helper.CBPos.ItemIndex := Ord(FOSDPosition);

    Lbl := TLabel.Create(Dlg);
    Lbl.Parent := Dlg; Lbl.SetBounds(16, 120, 150, 20);
    Lbl.Caption := 'Monitor:';
    Helper.CBMon := TComboBox.Create(Dlg);
    Helper.CBMon.Parent := Dlg; Helper.CBMon.SetBounds(180, 116, 140, 24);
    Helper.CBMon.Style := csDropDownList;
    Helper.CBMon.Items.Add(Tr('Primär', 'Primary'));
    for i := 0 to Screen.MonitorCount - 1 do
      Helper.CBMon.Items.Add('Monitor ' + IntToStr(i + 1));
    if (FMonitorIndex + 1 >= 0) and (FMonitorIndex + 1 < Helper.CBMon.Items.Count) then
      Helper.CBMon.ItemIndex := FMonitorIndex + 1
    else
      Helper.CBMon.ItemIndex := 0;

    Lbl := TLabel.Create(Dlg);
    Lbl.Parent := Dlg; Lbl.SetBounds(16, 154, 150, 20);
    Lbl.Caption := Tr('Deckkraft (80-255):', 'Opacity (80-255):');
    Helper.SEOp := TSpinEdit.Create(Dlg);
    Helper.SEOp.Parent := Dlg; Helper.SEOp.SetBounds(180, 150, 140, 24);
    Helper.SEOp.MinValue := 80; Helper.SEOp.MaxValue := 255;
    Helper.SEOp.Value := FOpacity;

    BtnTest := TButton.Create(Dlg);
    BtnTest.Parent := Dlg; BtnTest.SetBounds(16, 196, 90, 28);
    BtnTest.Caption := 'Test OSD';
    BtnTest.OnClick := Helper.OnTestClick;

    BtnOK := TButton.Create(Dlg);
    BtnOK.Parent := Dlg; BtnOK.SetBounds(144, 196, 84, 28);
    BtnOK.Caption := 'OK';
    BtnOK.ModalResult := mrOk;
    BtnOK.Default := True;

    BtnCancel := TButton.Create(Dlg);
    BtnCancel.Parent := Dlg; BtnCancel.SetBounds(236, 196, 84, 28);
    BtnCancel.Caption := Tr('Abbrechen', 'Cancel');
    BtnCancel.ModalResult := mrCancel;
    BtnCancel.Cancel := True;

    if Dlg.ShowModal = mrOk then
    begin
      Helper.ApplyToOSD;
      SaveSettings(IniPath);
    end;
  finally
    Helper.Free;
    Dlg.Free;
  end;
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
  Base, MonW, MonH: Integer;
  MR: TRect;
begin
  MR := ActiveMonitorRect;
  MonW := MR.Right - MR.Left;
  MonH := MR.Bottom - MR.Top;
  if FFontSize > 0 then
    Base := FFontSize
  else
  begin
    Base := MonH div 28;
    if Base < 14 then Base := 14;
    if Base > 56 then Base := 56;
  end;
  Canvas.Font.Name := OSD_FONT;
  Canvas.Font.Size := Base;
  Result := Base;
  if (S <> '') and (Canvas.TextWidth(S) > 0) then
  begin
    Result := Round(Base * ((MonW * 0.55) / Canvas.TextWidth(S)));
    if Result > Base then Result := Base;
    if Result < 12 then Result := 12;
  end;
end;

procedure TEmatOSD.LayoutForText;
var
  W, TitleH, SubH, DurW, MonW, MonH: Integer;
  MR: TRect;
begin
  MR := ActiveMonitorRect;
  MonW := MR.Right - MR.Left;
  MonH := MR.Bottom - MR.Top;

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
    DurW := Canvas.TextWidth(FDuration) + 28;
  end;

  if W + DurW + OSD_PAD_X * 2 > MonW - 32 then
    W := MonW - 32 - OSD_PAD_X * 2 - DurW;
  if W < 100 then W := 100;

  Width  := W + DurW + OSD_PAD_X * 2;
  Height := TitleH + SubH + OSD_PAD_Y * 2;

  case FOSDPosition of
    osdTop: begin
      Left := MR.Left + (MonW - Width) div 2;
      Top  := MR.Top + Round(MonH * 0.12);
    end;
    osdCenter: begin
      Left := MR.Left + (MonW - Width) div 2;
      Top  := MR.Top + (MonH - Height) div 2;
    end;
    osdTopRight: begin
      Left := MR.Right - Width - 32;
      Top  := MR.Top + 32;
    end;
    else begin // osdBottom
      Left := MR.Left + (MonW - Width) div 2;
      Top  := MR.Top + Round(MonH * 0.80) - Height div 2;
    end;
  end;
end;

procedure TEmatOSD.ShowOSD(const ATitle, ASubTitle, ADuration: string;
  ARed: Boolean; AMilliseconds: Integer);
var
  DurMs: Integer;
begin
  FTitle := ATitle;
  FSubTitle := ASubTitle;
  FDuration := ADuration;
  FRed := ARed;

  DurMs := AMilliseconds;
  if DurMs <= 0 then
    DurMs := FDisplayDurationMs;

  AlphaBlendValue := FOpacity;
  LayoutForText;
  if not Visible then Show;
  { position/size may have been clamped by the window manager }
  Invalidate;
  Update;
  BringToFront;

  FHideAt := GetTickCount64 + QWord(DurMs);
  FTimer.Enabled := True;
end;

procedure TEmatOSD.HideOSD;
begin
  FTimer.Enabled := False;
  if Visible then Hide;
  AlphaBlendValue := FOpacity;
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
    AlphaBlendValue := Round(FOpacity * (Left_ / OSD_FADE))
  else
    AlphaBlendValue := FOpacity;
end;

procedure TEmatOSD.DoPaint(Sender: TObject);
var
  R: TRect;
  TitleCol, SubCol: TColor;
  TitleFontSz, TitleH, DurY: Integer;
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
  TitleFontSz := TextFontSize(FTitle);
  Canvas.Font.Size := TitleFontSz;
  Canvas.Font.Color := TitleCol;
  TitleH := Canvas.TextHeight(FTitle);
  Canvas.TextOut(OSD_PAD_X, OSD_PAD_Y, FTitle);

  if FSubTitle <> '' then
  begin
    Canvas.Font.Style := [];
    Canvas.Font.Size := (TitleFontSz * 2) div 3;
    Canvas.Font.Color := SubCol;
    Canvas.TextOut(OSD_PAD_X, OSD_PAD_Y + TitleH + 8, FSubTitle);
  end;

  if FDuration <> '' then
  begin
    Canvas.Font.Style := [];
    Canvas.Font.Size := (TitleFontSz * 2) div 3;
    Canvas.Font.Color := TitleCol;
    DurY := OSD_PAD_Y + (TitleH - Canvas.TextHeight(FDuration)) div 2;
    if DurY < OSD_PAD_Y then DurY := OSD_PAD_Y;
    Canvas.TextOut(Width - OSD_PAD_X - Canvas.TextWidth(FDuration), DurY, FDuration);
  end;

  Canvas.Brush.Style := bsSolid;
end;

end.
