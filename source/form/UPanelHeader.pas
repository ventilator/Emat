unit UPanelHeader;

{ Compact, themed LCL header bar for TTBXDockablePanel instances.
  Provides a reliable 'x' close button and a '...' dock-position menu
  (Top / Bottom / Left / Right / Float) since TB2_TBX non-client-area
  titlebars and drag-and-drop are inactive in LCL Win32. }

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, StdCtrls, Buttons, Menus, Graphics,
  TB2Dock, TBXDkPanels, ULangMgr;

type
  TPanelHeaderBar = class(TPanel)
  private
    FTargetPanel: TTBXDockablePanel;
    FDockTop: TTBXMultiDock;
    FDockBottom: TTBXMultiDock;
    FDockLeft: TTBXMultiDock;
    FDockRight: TTBXMultiDock;
    FLblTitle: TLabel;
    FBtnMenu: TSpeedButton;
    FBtnClose: TSpeedButton;
    FPopup: TPopupMenu;
    FMITop: TMenuItem;
    FMIBottom: TMenuItem;
    FMILeft: TMenuItem;
    FMIRight: TMenuItem;
    FMIFloat: TMenuItem;
    FMIClose: TMenuItem;
    FOnPanelClosed: TNotifyEvent;
    procedure DoCloseClick(Sender: TObject);
    procedure DoMenuClick(Sender: TObject);
    procedure DoDockTop(Sender: TObject);
    procedure DoDockBottom(Sender: TObject);
    procedure DoDockLeft(Sender: TObject);
    procedure DoDockRight(Sender: TObject);
    procedure DoFloat(Sender: TObject);
    procedure MoveToDock(ADock: TTBXMultiDock);
  public
    constructor CreateForPanel(AOwner: TComponent; APanel: TTBXDockablePanel;
      ADockTop, ADockBottom, ADockLeft, ADockRight: TTBXMultiDock;
      AOnClosed: TNotifyEvent);
    procedure RefreshTitleAndLanguage;
    procedure ApplyThemeColors(BgColor, TextColor: TColor);
  end;

implementation

constructor TPanelHeaderBar.CreateForPanel(AOwner: TComponent; APanel: TTBXDockablePanel;
  ADockTop, ADockBottom, ADockLeft, ADockRight: TTBXMultiDock;
  AOnClosed: TNotifyEvent);
var
  Sep: TMenuItem;
begin
  inherited Create(AOwner);
  FTargetPanel := APanel;
  FDockTop := ADockTop;
  FDockBottom := ADockBottom;
  FDockLeft := ADockLeft;
  FDockRight := ADockRight;
  FOnPanelClosed := AOnClosed;

  Align := alTop;
  Height := 22;
  BevelOuter := bvNone;
  BorderStyle := bsNone;
  Caption := '';
  Color := clBtnFace;

  FBtnMenu := TSpeedButton.Create(Self);
  FBtnMenu.Parent := Self;
  FBtnMenu.Align := alRight;
  FBtnMenu.Width := 22;
  FBtnMenu.Flat := True;
  FBtnMenu.Caption := '⋮';
  FBtnMenu.Font.Style := [fsBold];
  FBtnMenu.ShowHint := True;
  FBtnMenu.OnClick := DoMenuClick;

  FBtnClose := TSpeedButton.Create(Self);
  FBtnClose.Parent := Self;
  FBtnClose.Align := alRight;
  FBtnClose.Left := 1000; // rightmost: [Title ... ⋮ ×]
  FBtnClose.Width := 22;
  FBtnClose.Flat := True;
  FBtnClose.Caption := '×';
  FBtnClose.Font.Style := [fsBold];
  FBtnClose.ShowHint := True;
  FBtnClose.OnClick := DoCloseClick;

  FLblTitle := TLabel.Create(Self);
  FLblTitle.Parent := Self;
  FLblTitle.Align := alClient;
  FLblTitle.Layout := tlCenter;
  FLblTitle.AutoSize := False;
  FLblTitle.Font.Style := [fsBold];
  FLblTitle.BorderSpacing.Left := 6;

  FPopup := TPopupMenu.Create(Self);
  FMITop := TMenuItem.Create(FPopup);
  FMITop.OnClick := DoDockTop;
  FPopup.Items.Add(FMITop);

  FMIBottom := TMenuItem.Create(FPopup);
  FMIBottom.OnClick := DoDockBottom;
  FPopup.Items.Add(FMIBottom);

  FMILeft := TMenuItem.Create(FPopup);
  FMILeft.OnClick := DoDockLeft;
  FPopup.Items.Add(FMILeft);

  FMIRight := TMenuItem.Create(FPopup);
  FMIRight.OnClick := DoDockRight;
  FPopup.Items.Add(FMIRight);

  FMIFloat := TMenuItem.Create(FPopup);
  FMIFloat.OnClick := DoFloat;
  FPopup.Items.Add(FMIFloat);

  Sep := TMenuItem.Create(FPopup);
  Sep.Caption := '-';
  FPopup.Items.Add(Sep);

  FMIClose := TMenuItem.Create(FPopup);
  FMIClose.OnClick := DoCloseClick;
  FPopup.Items.Add(FMIClose);

  RefreshTitleAndLanguage;
  Parent := APanel;
end;

procedure TPanelHeaderBar.RefreshTitleAndLanguage;
begin
  if FTargetPanel <> nil then
    FLblTitle.Caption := FTargetPanel.Caption;
  FBtnClose.Hint := Tr('Panel schließen', 'Close Panel');
  FBtnMenu.Hint := Tr('Panel verschieben (Oben/Unten/Links/Rechts)', 'Move Panel (Top/Bottom/Left/Right)');
  FMITop.Caption := Tr('Oben andocken', 'Dock Top');
  FMIBottom.Caption := Tr('Unten andocken', 'Dock Bottom');
  FMILeft.Caption := Tr('Links andocken', 'Dock Left');
  FMIRight.Caption := Tr('Rechts andocken', 'Dock Right');
  FMIFloat.Caption := Tr('Schwebend (Abdocken)', 'Float (Undock)');
  FMIClose.Caption := Tr('Schließen', 'Close');
end;

procedure TPanelHeaderBar.ApplyThemeColors(BgColor, TextColor: TColor);
var
  BgRGB, TxtRGB: LongInt;
  BgLum, TxtLum: Integer;
begin
  if (BgColor = clNone) or (BgColor = clDefault) then BgColor := clBtnFace;
  if (TextColor = clNone) or (TextColor = clDefault) then TextColor := clBtnText;
  BgRGB := ColorToRGB(BgColor);
  TxtRGB := ColorToRGB(TextColor);
  BgLum := (Red(BgRGB) * 299 + Green(BgRGB) * 587 + Blue(BgRGB) * 114) div 1000;
  TxtLum := (Red(TxtRGB) * 299 + Green(TxtRGB) * 587 + Blue(TxtRGB) * 114) div 1000;
  if Abs(BgLum - TxtLum) < 85 then
  begin
    if BgLum > 128 then TextColor := clBlack else TextColor := clWhite;
  end;
  Color := BgColor;
  FLblTitle.Font.Color := TextColor;
  FBtnMenu.Font.Color := TextColor;
  FBtnClose.Font.Color := TextColor;
  Invalidate;
end;

procedure TPanelHeaderBar.MoveToDock(ADock: TTBXMultiDock);
begin
  if (FTargetPanel = nil) or (ADock = nil) then Exit;
  FTargetPanel.CurrentDock := ADock;
  FTargetPanel.Visible := True;
  ADock.Visible := True;
end;

procedure TPanelHeaderBar.DoCloseClick(Sender: TObject);
begin
  if FTargetPanel <> nil then
    FTargetPanel.Visible := False;
  if Assigned(FOnPanelClosed) then
    FOnPanelClosed(FTargetPanel);
end;

procedure TPanelHeaderBar.DoMenuClick(Sender: TObject);
var
  P: TPoint;
begin
  if FTargetPanel <> nil then
  begin
    FMITop.Checked := (not FTargetPanel.Floating) and (FTargetPanel.CurrentDock = FDockTop);
    FMIBottom.Checked := (not FTargetPanel.Floating) and (FTargetPanel.CurrentDock = FDockBottom);
    FMILeft.Checked := (not FTargetPanel.Floating) and (FTargetPanel.CurrentDock = FDockLeft);
    FMIRight.Checked := (not FTargetPanel.Floating) and (FTargetPanel.CurrentDock = FDockRight);
    FMIFloat.Checked := FTargetPanel.Floating;
  end;
  P := FBtnMenu.ClientToScreen(Point(0, FBtnMenu.Height));
  FPopup.Popup(P.X, P.Y);
end;

procedure TPanelHeaderBar.DoDockTop(Sender: TObject);
begin
  MoveToDock(FDockTop);
end;

procedure TPanelHeaderBar.DoDockBottom(Sender: TObject);
begin
  MoveToDock(FDockBottom);
end;

procedure TPanelHeaderBar.DoDockLeft(Sender: TObject);
begin
  MoveToDock(FDockLeft);
end;

procedure TPanelHeaderBar.DoDockRight(Sender: TObject);
begin
  MoveToDock(FDockRight);
end;

procedure TPanelHeaderBar.DoFloat(Sender: TObject);
begin
  if FTargetPanel <> nil then
    FTargetPanel.CurrentDock := nil;
end;

end.
