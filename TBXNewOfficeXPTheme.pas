unit TBXNewOfficeXPTheme;

// v0.3: XP Silver Theme bug fix, updated with newer version of TBX
//       Theme renamed, from NewOfficeXPTheme to NewOfficeXP from requests to keep naming universal

// v0.2: TBXDockablePanel bug fixed, + Dockable Panel now lools like WinXP
//
//       Toolbar Color problem fixed: Lighter color did not suit these toolbars,
//       unlike the original XP theme, which is ok

// NewOfficeXPTheme, a modification by Rob van der Linde of the original
// OfficeXP theme bundled with TBX 2.0 Beta 3

// TBX Package
// Copyright 2001-2002 Alex A. Denisov. All Rights Reserved
// See TBX.chm for license and installation instructions
//
// $Id: TBXNewOfficeXPTheme.pas,v 0.3 2004/03/15 16:57:59 Robvdl $

interface

uses
  Windows, Messages, Graphics, TBXThemes, TBXDefaultTheme, ImgList;

{*$DEFINE ALTERNATIVE_DISABLED_STYLE} // remove the asterisk to change appearance of disabled images
{*$DEFINE SMALL_CLOSE_BUTTON} // remove the asterisk for smaller close button size

type
  TItemPart = (ipBody, ipText, ipFrame);
  TBtnItemState = (bisNormal, bisDisabled, bisSelected, bisPressed, bisHot,
    bisDisabledHot, bisSelectedHot, bisPopupParent);
  TMenuItemState = (misNormal, misDisabled, misHot, misDisabledHot);
  TWinFramePart = (wfpBorder, wfpCaption, wfpCaptionText);
  TWinFrameState = (wfsActive, wfsInactive);

  TTBXNewOfficeXPTheme = class(TTBXTheme)
  private
    procedure TBXSysCommand(var Message: TMessage); message TBX_SYSCOMMAND;
  protected
    { View/Window Colors }
    MenubarColor: TColor;
    ToolbarColor: TColor;
    PopupColor: TColor;
    DockPanelColor: TColor;

    PopupFrameColor: TColor;
    WinFrameColors: array [TWinFrameState, TWinFramePart] of TColor;
    PnlFrameColors: array [TWinFrameState, TWinFramePart] of TColor;
    MenuItemColors: array [TMenuItemState, TItemPart] of TColor;
    BtnItemColors: array [TBtnItemState, TItemPart] of TColor;

    { Other Colors }
    DragHandleColor: TColor;
    PopupSeparatorColor: TColor;
    ToolbarSeparatorColor: TColor;
    IconShadowColor: TColor;
    StatusPanelFrameColor: TColor;

    procedure SetupColorCache; virtual;
  protected
    { Internal Methods }
    function GetPartColor(const ItemInfo: TTBXItemInfo; ItemPart: TItemPart): TColor;
    function GetBtnColor(const ItemInfo: TTBXItemInfo; ItemPart: TItemPart): TColor;
  public
    constructor Create(const AName: string); override;
    destructor Destroy; override;

    { Metrics access}
    function  GetBooleanMetrics(Index: Integer): Boolean; override;
    function  GetImageOffset(Canvas: TCanvas; const ItemInfo: TTBXItemInfo; ImageList: TCustomImageList): TPoint; override;
    function  GetIntegerMetrics(Index: Integer): Integer; override;
    function  GetItemColor(const ItemInfo: TTBXItemInfo): TColor; override;
    function  GetItemTextColor(const ItemInfo: TTBXItemInfo): TColor; override;
    function  GetItemImageBackground(const ItemInfo: TTBXItemInfo): TColor; override;
    procedure GetMargins(MarginID: Integer; out Margins: TTBXMargins); override;
    function  GetPopupShadowType: Integer; override;
    procedure GetViewBorder(ViewType: Integer; out Border: TPoint); override;
    function  GetViewColor(AViewType: Integer): TColor; override;
    procedure GetViewMargins(ViewType: Integer; out Margins: TTBXMargins); override;

    { Painting routines }
    procedure PaintBackgnd(Canvas: TCanvas; const ADockRect, ARect, AClipRect: TRect; AColor: TColor; Transparent: Boolean; AViewType: Integer); override;
    procedure PaintButton(Canvas: TCanvas; const ARect: TRect; const ItemInfo: TTBXItemInfo); override;
    procedure PaintCaption(Canvas: TCanvas; const ARect: TRect; const ItemInfo: TTBXItemInfo; const ACaption: string; AFormat: Cardinal; Rotated: Boolean); override;
    procedure PaintCheckMark(Canvas: TCanvas; ARect: TRect; const ItemInfo: TTBXItemInfo); override;
    procedure PaintChevron(Canvas: TCanvas; ARect: TRect; const ItemInfo: TTBXItemInfo); override;
    procedure PaintDock(Canvas: TCanvas; const ClientRect, DockRect: TRect; DockPosition: Integer); override;
    procedure PaintDockPanelNCArea(Canvas: TCanvas; R: TRect; const DockPanelInfo: TTBXDockPanelInfo); override;
    procedure PaintDropDownArrow(Canvas: TCanvas; const ARect: TRect; const ItemInfo: TTBXItemInfo); override;
    procedure PaintEditButton(Canvas: TCanvas; const ARect: TRect; var ItemInfo: TTBXItemInfo; ButtonInfo: TTBXEditBtnInfo); override;
    procedure PaintEditFrame(Canvas: TCanvas; const ARect: TRect; var ItemInfo: TTBXItemInfo; const EditInfo: TTBXEditInfo); override;
    procedure PaintFloatingBorder(Canvas: TCanvas; const ARect: TRect; const WindowInfo: TTBXWindowInfo); override;
    procedure PaintFrame(Canvas: TCanvas; const ARect: TRect; const ItemInfo: TTBXItemInfo); override;
    procedure PaintImage(Canvas: TCanvas; ARect: TRect; const ItemInfo: TTBXItemInfo; ImageList: TCustomImageList; ImageIndex: Integer); override;
    procedure PaintMDIButton(Canvas: TCanvas; ARect: TRect; const ItemInfo: TTBXItemInfo; ButtonKind: Cardinal); override;
    procedure PaintMenuItem(Canvas: TCanvas; var ARect: TRect; var ItemInfo: TTBXItemInfo); override;
    procedure PaintMenuItemFrame(Canvas: TCanvas; const ARect: TRect; const ItemInfo: TTBXItemInfo); override;
    procedure PaintPageScrollButton(Canvas: TCanvas; const ARect: TRect; ButtonType: Integer; Hot: Boolean); override;
    procedure PaintPopupNCArea(Canvas: TCanvas; R: TRect; const PopupInfo: TTBXPopupInfo); override;
    procedure PaintSeparator(Canvas: TCanvas; ARect: TRect; ItemInfo: TTBXItemInfo; Horizontal, LineSeparator: Boolean); override;
    procedure PaintToolbarNCArea(Canvas: TCanvas; R: TRect; const ToolbarInfo: TTBXToolbarInfo); override;
    procedure PaintGlyph(Canvas: TCanvas; R: TRect; Kind, State: Integer); override;
    procedure PaintStatusBar(Canvas: TCanvas; R: TRect; Part: Integer); override;
  end;

implementation

{$R tbx_newglyphs.res}

uses TBXUtils, TBXUxThemes, TB2Common, TB2Item, Classes, Controls, Commctrl, TBX, Forms;

var
  StockImgList: TImageList;
  CounterLock: Integer;

procedure InitializeStock;
begin
  StockImgList := TImageList.Create(nil);
  StockImgList.Handle := ImageList_LoadBitmap(HInstance, 'TBXNEWGLYPHS', 16, 0, clWhite);
end;

procedure FinalizeStock;
begin
  StockImgList.Free;
end;

{ TTBXNewOfficeXPTheme }

function TTBXNewOfficeXPTheme.GetBooleanMetrics(Index: Integer): Boolean;
begin
  case Index of
    TMB_OFFICEXPPOPUPALIGNMENT:    Result := True;
    TMB_EDITCAPTIONINDENTED:       Result := True;
    TMB_EDITHEIGHTEVEN:            Result := False;
    TMB_PAINTDOCKBACKGROUND:       Result := USE_THEMES;
    TMB_SOLIDTOOLBARS:             Result := False;
  else
    Result := False;
  end;
end;

function TTBXNewOfficeXPTheme.GetIntegerMetrics(Index: Integer): Integer;
const
  DEFAULT = -1;
begin
  case Index of
    TMI_SPLITBTN_ARROWWIDTH:         Result := 12;

    TMI_DROPDOWN_ARROWWIDTH:         Result := 8;
    TMI_DROPDOWN_ARROWMARGIN:        Result := 3;

    TMI_MENU_VMARGIN:                Result := 3;
    TMI_MENU_HMARGIN:                Result := 1;
    TMI_MENU_IMGTEXTSPACE:           Result := 0;
    TMI_MENU_LCAPTIONMARGIN:         Result := 8;
    TMI_MENU_RCAPTIONMARGIN:         Result := 3;
    TMI_MENU_SEPARATORSIZE:          Result := 3;
    TMI_MENU_MDI_DW:                 Result := 2;
    TMI_MENU_MDI_DH:                 Result := 2;

    TMI_LINE_SPACING:                Result := 6;

    TMI_TLBR_SEPARATORSIZE:          Result := DEFAULT;

    TMI_EDIT_FRAMEWIDTH:             Result := 1;
    TMI_EDIT_TEXTMARGINHORZ:         Result := 2;
    TMI_EDIT_TEXTMARGINVERT:         Result := 2;
    TMI_EDIT_MENUMIDWIDTH:           Result := 0;
    TMI_EDIT_BTNWIDTH:               Result := 14;
  else
    Result := DEFAULT;
  end;
end;

function TTBXNewOfficeXPTheme.GetViewColor(AViewType: Integer): TColor;
begin
  Result := clBtnFace;
  if (AViewType and VT_TOOLBAR) = VT_TOOLBAR then
  begin
    if (AViewType and TVT_MENUBAR) = TVT_MENUBAR then Result := MenubarColor
    else Result := ToolbarColor;
  end
  else if (AViewType and VT_POPUP) = VT_POPUP then
  begin
    if (AViewType and PVT_LISTBOX) = PVT_LISTBOX then Result := clWindow
    else Result := PopupColor;
  end
  else if (AViewType and VT_DOCKPANEL) = VT_DOCKPANEL then Result := DockPanelColor;
end;

function TTBXNewOfficeXPTheme.GetBtnColor(const ItemInfo: TTBXItemInfo; ItemPart: TItemPart): TColor;
const
  BFlags1: array [Boolean] of TBtnItemState = (bisDisabled, bisDisabledHot);
  BFlags2: array [Boolean] of TBtnItemState = (bisSelected, bisSelectedHot);
  BFlags3: array [Boolean] of TBtnItemState = (bisNormal, bisHot);
var
  B: TBtnItemState;
  Embedded: Boolean;
begin
  with ItemInfo do
  begin
    Embedded :=  (ViewType and VT_TOOLBAR = VT_TOOLBAR) and
      (ViewType and TVT_EMBEDDED = TVT_EMBEDDED);
    if not Enabled then B := BFlags1[HoverKind = hkKeyboardHover]
    else if ItemInfo.IsPopupParent then
      B := bisPopupParent
    else if Pushed then B := bisPressed
    else if Selected then B := BFlags2[HoverKind <> hkNone]
    else B := BFlags3[HoverKind <> hkNone];
    Result := BtnItemColors[B, ItemPart];
    if Embedded then
    begin
      if (ItemPart = ipBody) and (Result = clNone) then Result := ToolbarColor;
      if ItemPart = ipFrame then
      begin
        if Selected then Result := clWindowFrame
        else if (Result = clNone) then Result := clBtnShadow;
      end;
    end;
  end;
end;

function TTBXNewOfficeXPTheme.GetPartColor(const ItemInfo: TTBXItemInfo; ItemPart: TItemPart): TColor;
const
  MFlags1: array [Boolean] of TMenuItemState = (misDisabled, misDisabledHot);
  MFlags2: array [Boolean] of TMenuItemState = (misNormal, misHot);
  BFlags1: array [Boolean] of TBtnItemState = (bisDisabled, bisDisabledHot);
  BFlags2: array [Boolean] of TBtnItemState = (bisSelected, bisSelectedHot);
  BFlags3: array [Boolean] of TBtnItemState = (bisNormal, bisHot);
var
  IsMenuItem, Embedded: Boolean;
  M: TMenuItemState;
  B: TBtnItemState;
begin
  with ItemInfo do
  begin
    IsMenuItem := ((ViewType and PVT_POPUPMENU) = PVT_POPUPMENU) and
      ((ItemOptions and IO_TOOLBARSTYLE) = 0);
    Embedded := ((ViewType and VT_TOOLBAR) = VT_TOOLBAR) and
      ((ViewType and TVT_EMBEDDED) = TVT_EMBEDDED);
    if IsMenuItem then
    begin
      if not Enabled then M := MFlags1[HoverKind = hkKeyboardHover]
      else M := MFlags2[HoverKind <> hkNone];
      Result := MenuItemColors[M, ItemPart];
    end
    else
    begin
      if not Enabled then B := BFlags1[HoverKind = hkKeyboardHover]
      else if ItemInfo.IsPopupParent then B := bisPopupParent
      else if Pushed then B := bisPressed
      else if Selected then B := BFlags2[HoverKind <> hkNone]
      else B := BFlags3[HoverKind <> hkNone];
      Result := BtnItemColors[B, ItemPart];
      if Embedded and (Result = clNone) then
      begin
      if ItemPart = ipBody then Result := ToolbarColor;
      if ItemPart = ipFrame then Result := clBtnShadow;
      end;
    end;
  end;
end;

function TTBXNewOfficeXPTheme.GetItemColor(const ItemInfo: TTBXItemInfo): TColor;
begin
  Result := GetPartColor(ItemInfo, ipBody);
  if Result = clNone then Result := GetViewColor(ItemInfo.ViewType);
end;

function TTBXNewOfficeXPTheme.GetItemTextColor(const ItemInfo: TTBXItemInfo): TColor;
begin
  Result := GetPartColor(ItemInfo, ipText);
end;

function TTBXNewOfficeXPTheme.GetItemImageBackground(const ItemInfo: TTBXItemInfo): TColor;
begin
  Result := GetBtnColor(ItemInfo, ipBody);
  if Result = clNone then Result := GetViewColor(ItemInfo.ViewType);
end;

procedure TTBXNewOfficeXPTheme.GetViewBorder(ViewType: Integer; out Border: TPoint);
const
  XMetrics: array [Boolean] of Integer = (SM_CXDLGFRAME, SM_CXFRAME);
  YMetrics: array [Boolean] of Integer = (SM_CYDLGFRAME, SM_CYFRAME);
var
  Resizable: Boolean;

  procedure SetBorder(X, Y: Integer);
  begin
    Border.X := X;
    Border.Y := Y;
  end;

begin
  if (ViewType and VT_TOOLBAR) = VT_TOOLBAR then
  begin
    if (ViewType and TVT_FLOATING) = TVT_FLOATING then
    begin
      Resizable := (ViewType and TVT_RESIZABLE) = TVT_RESIZABLE;
      Border.X := GetSystemMetrics(XMetrics[Resizable]) - 1;
      Border.Y := GetSystemMetrics(YMetrics[Resizable]) - 1;
    end
    else SetBorder(2, 2);
  end
  else if (ViewType and VT_POPUP) = VT_POPUP then
  begin
    if (ViewType and PVT_POPUPMENU) = PVT_POPUPMENU then Border.X := 1
    else Border.X := 2;
    Border.Y := 2;
  end
  else if (ViewType and VT_DOCKPANEL) = VT_DOCKPANEL then
  begin
    if (ViewType and DPVT_FLOATING) = DPVT_FLOATING then
    begin
      Resizable := (ViewType and DPVT_RESIZABLE) = DPVT_RESIZABLE;
      Border.X := GetSystemMetrics(XMetrics[Resizable]) - 1;
      Border.Y := GetSystemMetrics(YMetrics[Resizable]) - 1;
    end
    else SetBorder(2, 2);
  end
  else SetBorder(0, 0);
end;

procedure TTBXNewOfficeXPTheme.GetMargins(MarginID: Integer; out Margins: TTBXMargins);
begin
  with Margins do
    case MarginID of
      MID_TOOLBARITEM:
        begin
          LeftWidth := 2;
          RightWidth := 2;
          TopHeight := 2;
          BottomHeight := 2;
        end;
      MID_STATUSPANE:
        begin
          LeftWidth := 1;
          RightWidth := 3;
          TopHeight := 1;
          BottomHeight := 1;
        end;
    else
      LeftWidth := 0;
      RightWidth := 0;
      TopHeight := 0;
      BottomHeight := 0;
    end;
end;

procedure TTBXNewOfficeXPTheme.PaintBackgnd(Canvas: TCanvas; const ADockRect, ARect, AClipRect: TRect;
  AColor: TColor; Transparent: Boolean; AViewType: Integer);
var
  Brush: HBrush;
  R: TRect;
begin
  if not Transparent then
  begin
    Brush := CreateSolidBrush(ColorToRGB(AColor));
    IntersectRect(R, ARect, AClipRect);
    FillRect(Canvas.Handle, R, Brush);
    DeleteObject(Brush);
  end;
end;

procedure TTBXNewOfficeXPTheme.PaintCaption(Canvas: TCanvas;
  const ARect: TRect; const ItemInfo: TTBXItemInfo; const ACaption: string;
  AFormat: Cardinal; Rotated: Boolean);
var
  R: TRect;
begin
  with ItemInfo, Canvas do
  begin
    R := ARect;
    Brush.Style := bsClear;
    if Font.Color = clNone then Font.Color := GetPartColor(ItemInfo, ipText);
    if not Rotated then Windows.DrawText(Handle, PChar(ACaption), Length(ACaption), R, AFormat)
    else DrawRotatedText(Handle, ACaption, R, AFormat);
    Brush.Style := bsSolid;
  end;
end;

procedure TTBXNewOfficeXPTheme.PaintCheckMark(Canvas: TCanvas; ARect: TRect; const ItemInfo: TTBXItemInfo);
var
  X, Y: Integer;
begin
  X := (ARect.Left + ARect.Right) div 2 - 2;
  Y := (ARect.Top + ARect.Bottom) div 2 + 1;
  Canvas.Pen.Color := GetBtnColor(ItemInfo, ipText);
  Canvas.Polyline([Point(X-2, Y-2), Point(X, Y), Point(X+4, Y-4),
    Point(X+4, Y-3), Point(X, Y+1), Point(X-2, Y-1), Point(X-2, Y-2)]);
end;

procedure TTBXNewOfficeXPTheme.PaintChevron(Canvas: TCanvas; ARect: TRect; const ItemInfo: TTBXItemInfo);
const
  Pattern: array[Boolean, 0..15] of Byte = (
    ($CC, 0, $66, 0, $33, 0, $66, 0, $CC, 0, 0, 0, 0, 0, 0, 0),
    ($88, 0, $D8, 0, $70, 0, $20, 0, $88, 0, $D8, 0, $70, 0, $20, 0));
var
  R2: TRect;
  Bmp: TBitmap;
begin
  R2 := ARect;
  PaintButton(Canvas, ARect, ItemInfo);
  if not ItemInfo.IsVertical then
  begin
    R2.Top := 4;
    R2.Bottom := R2.Top + 5;
    Inc(R2.Left, 2);
    R2.Right := R2.Left + 8;
  end
  else
  begin
    R2.Left := R2.Right - 9;
    R2.Right := R2.Left + 5;
    Inc(R2.Top, 2);
    R2.Bottom := R2.Top + 8;
  end;
  Bmp := TBitmap.Create;
  try
    Bmp.Handle := CreateBitmap(8, 8, 1, 1, @Pattern[ItemInfo.IsVertical]);
    Canvas.Brush.Color := GetPartColor(ItemInfo, ipText);
    SetTextColor(Canvas.Handle, clBlack);
    SetBkColor(Canvas.Handle, clWhite);
    with R2 do BitBlt(Canvas.Handle, Left, Top, Right - Left,
      Bottom - Top, Bmp.Canvas.Handle, 0, 0, ROP_DSPDxax);
  finally
    Bmp.Free;
  end;
end;

procedure TTBXNewOfficeXPTheme.PaintEditButton(Canvas: TCanvas; const ARect: TRect;
  var ItemInfo: TTBXItemInfo; ButtonInfo: TTBXEditBtnInfo);
var
  BtnDisabled, BtnHot, BtnPressed, Embedded: Boolean;
  R, BR: TRect;
  X, Y: Integer;
  SaveItemInfoPushed: Boolean;
begin
  R := ARect;
  Embedded := ((ItemInfo.ViewType and VT_TOOLBAR) = VT_TOOLBAR) and
    ((ItemInfo.ViewType and TVT_EMBEDDED) = TVT_EMBEDDED);

  InflateRect(R, 1, 1);
  Inc(R.Left);
  with Canvas do
    if ButtonInfo.ButtonType = EBT_DROPDOWN then
    begin
      BtnDisabled := (ButtonInfo.ButtonState and EBDS_DISABLED) <> 0;
      BtnHot := (ButtonInfo.ButtonState and EBDS_HOT) <> 0;
      BtnPressed := (ButtonInfo.ButtonState and EBDS_PRESSED) <> 0;
      if not BtnDisabled then
      begin
        if BtnPressed or BtnHot or Embedded then PaintButton(Canvas, R, ItemInfo)
        else if (ItemInfo.ViewType and VT_TOOLBAR) = VT_TOOLBAR then
        begin
          R := ARect;
          if not Embedded then
          begin
            FrameRectEx(Canvas, R, clWindow);
            Pen.Color := clWindow;
          end
          else Pen.Color := GetBtnColor(ItemInfo, ipFrame);
          MoveTo(R.Left - 1, R.Top); LineTo(R.Left - 1, R.Bottom);
        end;
      end;
      PaintDropDownArrow(Canvas, R, ItemInfo);
    end
    else if ButtonInfo.ButtonType = EBT_SPIN then
    begin
      BtnDisabled := (ButtonInfo.ButtonState and EBSS_DISABLED) <> 0;
      BtnHot := (ButtonInfo.ButtonState and EBSS_HOT) <> 0;

      { Upper button }
      BR := R;
      BR.Bottom := (R.Top + R.Bottom + 1) div 2;
      BtnPressed := (ButtonInfo.ButtonState and EBSS_UP) <> 0;
      SaveItemInfoPushed := ItemInfo.Pushed;
      ItemInfo.Pushed := BtnPressed;
      if not BtnDisabled then
      begin
        if BtnPressed or BtnHot or Embedded then PaintButton(Canvas, BR, ItemInfo)
        else if (ItemInfo.ViewType and VT_TOOLBAR) = VT_TOOLBAR then
        begin
          BR.Left := ARect.Left; BR.Top := ARect.Top; BR.Right := ARect.Right;
          if not Embedded then
          begin
            FrameRectEx(Canvas, BR, clWindow);
            Pen.Color := clWindow;
          end
          else Pen.Color := GetBtnColor(ItemInfo, ipFrame);
          MoveTo(BR.Left - 1, BR.Top); LineTo(BR.Left - 1, BR.Bottom);
        end;
      end;
      X := (BR.Left + BR.Right) div 2;
      Y := (BR.Top + BR.Bottom - 1) div 2;
      Pen.Color := GetPartColor(ItemInfo, ipText);
      Brush.Color := Pen.Color;
      Polygon([Point(X - 2, Y + 1), Point(X + 2, Y + 1), Point(X, Y - 1)]);

      { Lower button }
      BR := R;
      BR.Top := (R.Top + R.Bottom) div 2;
      BtnPressed := (ButtonInfo.ButtonState and EBSS_DOWN) <> 0;
      ItemInfo.Pushed := BtnPressed;
      if not BtnDisabled then
      begin
        if BtnPressed or BtnHot or Embedded then PaintButton(Canvas, BR, ItemInfo)
        else if (ItemInfo.ViewType and VT_TOOLBAR) = VT_TOOLBAR then
        begin
          BR.Left := ARect.Left; BR.Bottom := ARect.Bottom; BR.Right := ARect.Right;
          if not Embedded then
          begin
            FrameRectEx(Canvas, BR, clWindow);
            Pen.Color := clWindow;
          end
          else Pen.Color := GetBtnColor(ItemInfo, ipFrame);
          MoveTo(BR.Left - 1, BR.Top); LineTo(BR.Left - 1, BR.Bottom);
        end;
      end;
      X := (BR.Left + BR.Right) div 2;
      Y := (BR.Top + BR.Bottom) div 2;
      Pen.Color := GetPartColor(ItemInfo, ipText);
      Brush.Color := Pen.Color;
      Polygon([Point(X - 2, Y - 1), Point(X + 2, Y - 1), Point(X, Y + 1)]);

      ItemInfo.Pushed := SaveItemInfoPushed;
    end;
end;

procedure TTBXNewOfficeXPTheme.PaintEditFrame(Canvas: TCanvas;
  const ARect: TRect; var ItemInfo: TTBXItemInfo; const EditInfo: TTBXEditInfo);
var
  R: TRect;
  W: Integer;
  Embedded: Boolean;
begin
  R := ARect;
  PaintFrame(Canvas, R, ItemInfo);
  W := EditFrameWidth;
  InflateRect(R, -W, -W);
  Embedded := ((ItemInfo.ViewType and VT_TOOLBAR) = VT_TOOLBAR) and
    ((ItemInfo.ViewType and TVT_EMBEDDED) = TVT_EMBEDDED);
  if not (ItemInfo.Enabled or Embedded) then
    FrameRectEx(Canvas, R, BtnItemColors[bisDisabled, ipText]);

  with EditInfo do if RightBtnWidth > 0 then Dec(R.Right, RightBtnWidth - 2);

  if ItemInfo.Enabled then
  begin
    if ((ItemInfo.ViewType and VT_TOOLBAR) <> VT_TOOLBAR) and
      (GetPartColor(ItemInfo, ipFrame) = clNone) then
      FrameRectEx(Canvas, R, ToolbarColor)
    else
    begin
      Canvas.Brush.Color := clWindow;
      Canvas.FrameRect(R);
    end;
  end;
  InflateRect(R, -1, -1);
  if ItemInfo.Enabled then
  begin
    Canvas.Brush.Color := clWindow;
    Canvas.FillRect(R);
    if ((ItemInfo.ViewType and VT_TOOLBAR) <> VT_TOOLBAR) and
      (GetPartColor(ItemInfo, ipFrame) = clNone) then
    begin
      Canvas.Brush.Color := ToolbarColor;
      R := ARect;
      InflateRect(R, -1, -1);
      Canvas.FrameRect(R);
    end;
  end;

  with EditInfo do if LeftBtnWidth > 0 then Inc(R.Left, LeftBtnWidth - 2);

  if EditInfo.RightBtnWidth > 0 then
  begin
    R := ARect;
    InflateRect(R, -W, -W);
    R.Left := R.Right - EditInfo.RightBtnWidth;
    PaintEditButton(Canvas, R, ItemInfo, EditInfo.RightBtnInfo);
  end;
end;

procedure TTBXNewOfficeXPTheme.PaintDropDownArrow(Canvas: TCanvas;
  const ARect: TRect; const ItemInfo: TTBXItemInfo);
var
  X, Y: Integer;
begin
  with ARect, Canvas do
  begin
    X := (Left + Right) div 2;
    Y := (Top + Bottom) div 2 - 1;
    Pen.Color := GetPartColor(ItemInfo, ipText);
    Brush.Color := Pen.Color;
    if ItemInfo.IsVertical then Polygon([Point(X, Y + 2), Point(X, Y - 2), Point(X - 2, Y)])
    else Polygon([Point(X - 2, Y), Point(X + 2, Y), Point(X, Y + 2)]);
  end;
end;

procedure TTBXNewOfficeXPTheme.PaintButton(Canvas: TCanvas; const ARect: TRect; const ItemInfo: TTBXItemInfo);
var
  R: TRect;
begin
  with ItemInfo, Canvas do
  begin
    R := ARect;
    if ((ItemOptions and IO_DESIGNING) <> 0) and not Selected then
    begin
      Brush.Color := GetNearestColor(Handle, MixColors(clBtnShadow, clBtnFace, 100));
      if ComboPart = cpSplitRight then Dec(R.Left);
      FrameRect(R);
    end
    else
    begin
      FrameRectEx(Canvas, R, GetBtnColor(ItemInfo, ipFrame), True);
      if (ComboPart = cpSplitLeft) and IsPopupParent then Inc(R.Right);
      if ComboPart = cpSplitRight then Dec(R.Left);
      FillRectEx(Canvas, R, GetBtnColor(ItemInfo, ipBody));
    end;
    if ComboPart = cpSplitRight then PaintDropDownArrow(Canvas, R, ItemInfo);
  end;
end;

procedure TTBXNewOfficeXPTheme.PaintFloatingBorder(Canvas: TCanvas; const ARect: TRect; const WindowInfo: TTBXWindowInfo);
const
  SPI_GETGRADIENTCAPTIONS = $1008;
  DC_GRADIENT = $20;
  ActiveCaptionFlags: array [Boolean] of Integer = (0, DC_ACTIVE);
  GradientCaptionFlags: array [Boolean] of Integer = (0, DC_GRADIENT);
  CaptionBkColors: array [Boolean, Boolean] of Integer =
    ((COLOR_INACTIVECAPTION, COLOR_ACTIVECAPTION),
    (COLOR_GRADIENTINACTIVECAPTION, COLOR_GRADIENTACTIVECAPTION));
  ButtonStateFlags: array [Boolean] of Integer = (0, DFCS_PUSHED);
var
  R, R2: TRect;
  DC: HDC;
  Flags: Integer;
  Gradient, ShowCloseBtn: Boolean;
  B: BOOL;
begin
  DC := Canvas.Handle;

  with WindowInfo do
    if not USE_THEMES then
    begin
      R := ARect;
      if (WRP_BORDER and RedrawPart) <> 0 then
      begin
        R2 := R;
        with FloatingBorderSize do InflateRect(R2, -X, -Y);
        SaveDC(DC);
        with R2 do ExcludeClipRect(DC, Left, Top, Right, Bottom);
        Windows.DrawEdge(DC, R, EDGE_RAISED, BF_RECT or BF_MIDDLE);
        RestoreDC(DC, -1);
      end;

      if not WindowInfo.ShowCaption then Exit;
      Gradient := SystemParametersInfo(SPI_GETGRADIENTCAPTIONS, 0, @B, 0) and B;
      ShowCloseBtn := (CDBS_VISIBLE and CloseButtonState) <> 0;
      R := GetTBXCloseButtonRect(WindowInfo, True);

      if (WRP_CAPTION and RedrawPart) <> 0 then
      begin
        if ShowCloseBtn then
        begin
          SaveDC(DC);
          with R do ExcludeClipRect(DC, Left, Top, Right, Bottom);
        end;
        R2 := GetTBXCaptionRect(WindowInfo, True, ShowCloseBtn);
        DrawCaption(ParentHandle, DC, R2, DC_TEXT or DC_SMALLCAP or
          ActiveCaptionFlags[Active] or GradientCaptionFlags[Gradient]);
        if ShowCloseBtn then RestoreDC(DC, -1);
        R2 := GetTBXCaptionRect(WindowInfo, True, False);
        R2.Top := R2.Bottom;
        Inc(R2.Bottom);
        FillRect(DC, R2, GetSysColorBrush(COLOR_BTNFACE));
      end;

      if ShowCloseBtn then
      begin
        R2 := R;
        InflateRect(R2, -2, -2);
        if (WRP_CAPTION and RedrawPart) <> 0 then
        begin
          SaveDC(DC);
          with R2 do ExcludeClipRect(DC, Left, Top, Right, Bottom);
          FillRect(DC, R, GetSysColorBrush(CaptionBkColors[Gradient, WindowInfo.Active]));
          RestoreDC(DC, -1);
        end;
        if (WRP_CLOSEBTN and RedrawPart) <> 0 then
          DrawFrameControl(DC, R2, DFC_CAPTION, DFCS_CAPTIONCLOSE or
            ButtonStateFlags[(CDBS_PRESSED and CloseButtonState) <> 0]);
      end;
    end
    else { Use WindowsXP visual styles }
    begin
      if (WRP_BORDER and RedrawPart) <> 0 then
      begin
        if Active then Flags := FS_ACTIVE else Flags := FS_INACTIVE;
        R := ARect;
        R.Top := R.Bottom - FloatingBorderSize.Y;
        DrawThemeBackground(WINDOW_THEME, DC, WP_SMALLFRAMEBOTTOM, Flags, R, nil);
        R.Top := ARect.Top;
        R.Bottom := R.Top + FloatingBorderSize.Y;
        {if WindowInfo.ShowCaption then} { TODO : how to paint a captionless window frame }
          Inc(R.Bottom, GetSystemMetrics(SM_CYSMCAPTION));
        DrawThemeBackground(WINDOW_THEME, DC, WP_SMALLCAPTION, Flags, R, nil);
        R.Top := R.Bottom;
        R.Bottom := ARect.Bottom - FloatingBorderSize.Y;
        R.Right := R.Left + FloatingBorderSize.X;
        DrawThemeBackground(WINDOW_THEME, DC, WP_SMALLFRAMELEFT, Flags, R, nil);
        R.Right := ARect.Right;
        R.Left := R.Right - FloatingBorderSize.X;
        DrawThemeBackground(WINDOW_THEME, DC, WP_SMALLFRAMERIGHT, Flags, R, nil);
      end;

      if not ShowCaption then Exit;

      { Get the caption area }
      R := ARect;
      with FloatingBorderSize do InflateRect(R, -X, -Y);
      Dec(R.Bottom, ClientHeight);

      if (WRP_CAPTION and RedrawPart) <> 0 then
      begin
        R2 := R;
        if ((CDBS_VISIBLE and CloseButtonState) <> 0) and ((WRP_CLOSEBTN and RedrawPart) <> 0) then
          Dec(R2.Right, GetSystemMetrics(SM_CYSMCAPTION));

        Canvas.Font.Assign(SmCaptionFont);
        if Active then Canvas.Font.Color := clCaptionText
        else Canvas.Font.Color := clInactiveCaptionText;
        Canvas.Brush.Style := bsClear;

       { This is strange... the DrawThemeText function refuses to work...
         Use standard API...   }
        DrawText(Canvas.Handle, WindowInfo.Caption, -1, R2,
          DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS or DT_HIDEPREFIX);

        Canvas.Brush.Style := bsSolid;
      end;

      if (CDBS_VISIBLE and CloseButtonState) <> 0 then
      begin
        Dec(R.Bottom);
        R.Left := R.Right - R.Bottom + R.Top;
        InflateRect(R, -2, -2);
        if (CDBS_PRESSED and CloseButtonState) <> 0 then Flags := CBS_PUSHED
        else if (CDBS_HOT and CloseButtonState) <> 0 then Flags := CBS_HOT
        else Flags := CBS_NORMAL;
        DrawThemeBackground(WINDOW_THEME, DC, WP_SMALLCLOSEBUTTON, Flags, R, nil);
      end;
    end;
end;

procedure TTBXNewOfficeXPTheme.PaintFrame(Canvas: TCanvas; const ARect: TRect;
  const ItemInfo: TTBXItemInfo);
var
  R: TRect;
begin
  R := ARect;
  FrameRectEx(Canvas, R, GetPartColor(ItemInfo, ipFrame), True);
  FillRectEx(Canvas, R, GetPartColor(ItemInfo, ipBody));
end;

function TTBXNewOfficeXPTheme.GetImageOffset(Canvas: TCanvas;
  const ItemInfo: TTBXItemInfo; ImageList: TCustomImageList): TPoint;
begin
  Result.X := 0;
  if not (ImageList is TTBCustomImageList) then
    with ItemInfo do
      if Enabled and (HoverKind <> hkNone) and
      not (Selected or Pushed and not IsPopupParent) then
      Result.X := -1;
  Result.Y := Result.X
end;

procedure TTBXNewOfficeXPTheme.PaintImage(Canvas: TCanvas; ARect: TRect;
  const ItemInfo: TTBXItemInfo; ImageList: TCustomImageList; ImageIndex: Integer);
var
  HiContrast: Boolean;
begin
  with ItemInfo do
  begin
    if ImageList is TTBCustomImageList then
    begin
      TTBCustomImageList(ImageList).DrawState(Canvas, ARect.Left, ARect.Top,
        ImageIndex, Enabled, (HoverKind <> hkNone), Selected);
      Exit;
    end;

{$IFNDEF ALTERNATIVE_DISABLED_STYLE}
    HiContrast := IsDarkColor(GetItemImageBackground(ItemInfo), 64);

    if not Enabled then
    begin
      DrawTBXIconFlatShadow(Canvas, ARect, ImageList, ImageIndex,
        BtnItemColors[bisDisabled, ipText]);
    end
    else if Selected or Pushed or (HoverKind <> hkNone) then
    begin
      if not (Selected or Pushed and not IsPopupParent) then
      begin
        OffsetRect(ARect, 1, 1);
        DrawTBXIconFullShadow(Canvas, ARect, ImageList, ImageIndex, IconShadowColor);
        OffsetRect(ARect, -2, -2);
      end;
      DrawTBXIcon(Canvas, ARect, ImageList, ImageIndex, HiContrast);
    end
    else if HiContrast or TBXHiContrast or TBXLoColor then
      DrawTBXIcon(Canvas, ARect, ImageList, ImageIndex, HiContrast)
    else
      HighlightTBXIcon(Canvas, ARect, ImageList, ImageIndex, clWindow, 178);
{$ELSE}
    HiContrast := ColorIntensity(GetItemImageBackground(ItemInfo)) < 80;
    if not Enabled then
    begin
      if not HiContrast then
        DrawTBXIconShadow(Canvas, ARect, ImageList, ImageIndex, 0)
      else
        DrawTBXIconFlatShadow(Canvas, ARect, ImageList, ImageIndex, clBtnShadow);
    end
    else if Selected or Pushed or (HoverKind <> hkNone) then
    begin
      if not (Selected or Pushed and not IsPopupParent) then
      begin
        DrawTBXIconShadow(Canvas, ARect, ImageList, ImageIndex, 1);
        OffsetRect(ARect, 1, 1);
        DrawTBXIconShadow(Canvas, ARect, ImageList, ImageIndex, 1);
        OffsetRect(ARect, -2, -2);
      end;
      DrawTBXIcon(Canvas, ARect, ImageList, ImageIndex, HiContrast);
    end
    else if HiContrast or TBXHiContrast or TBXLoColor then
      DrawTBXIcon(Canvas, ARect, ImageList, ImageIndex, HiContrast)
    else
      HighlightTBXIcon(Canvas, ARect, ImageList, ImageIndex, clWindow, 178);
{$ENDIF}
  end;
end;

procedure TTBXNewOfficeXPTheme.PaintMDIButton(Canvas: TCanvas; ARect: TRect;
  const ItemInfo: TTBXItemInfo; ButtonKind: Cardinal);
var
  Index: Integer;
  X, Y: Integer;
  Bmp: TBitmap;
begin
  PaintButton(Canvas, ARect, ItemInfo);
  with ARect do
  begin
    X := (Left + Right - StockImgList.Width) div 2;
    Y := (Top + Bottom - StockImgList.Height) div 2;
  end;
  case ButtonKind of
    DFCS_CAPTIONMIN: Index := 2;
    DFCS_CAPTIONRESTORE: Index := 3;
    DFCS_CAPTIONCLOSE: Index := 0;
  else
    Exit;
  end;
  Bmp := TBitmap.Create;
  Bmp.Monochrome := True;
  StockImgList.GetBitmap(Index, Bmp);
  Canvas.Brush.Color := GetPartColor(ItemInfo, ipText);
  SetTextColor(Canvas.Handle, clBlack);
  SetBkColor(Canvas.Handle, clWhite);
  BitBlt(Canvas.Handle, X, Y, StockImgList.Width, StockImgList.Height,
    Bmp.Canvas.Handle, 0, 0, ROP_DSPDxax);
  Bmp.Free;
end;

procedure TTBXNewOfficeXPTheme.PaintMenuItemFrame(Canvas: TCanvas;
  const ARect: TRect; const ItemInfo: TTBXItemInfo);
var
  R: TRect;
begin
  R := ARect;
  if (ItemInfo.ViewType and PVT_TOOLBOX) <> PVT_TOOLBOX then with Canvas do
  begin
    R.Right := R.Left + ItemInfo.PopupMargin + 2;
    Brush.Color := ToolbarColor;
    FillRect(R);
    Inc(R.Left);
    R.Right := ARect.Right - 1;
  end;
  PaintFrame(Canvas, R, ItemInfo);
end;

procedure TTBXNewOfficeXPTheme.PaintMenuItem(Canvas: TCanvas; var ARect: TRect;
  var ItemInfo: TTBXItemInfo);
var
  R: TRect;
  X, Y: Integer;
  ArrowWidth: Integer;
  ClrText: TColor;

  procedure DrawArrow(AColor: TColor);
  begin
    Canvas.Pen.Color := AColor;
    Canvas.Brush.Color := AColor;
    Canvas.Polygon([Point(X, Y - 3), Point(X, Y + 3), Point(X + 3, Y)]);
  end;

begin
  with Canvas, ItemInfo do
  begin
    ArrowWidth := GetSystemMetrics(SM_CXMENUCHECK);
    PaintMenuItemFrame(Canvas, ARect, ItemInfo);
    ClrText := GetPartColor(ItemInfo, ipText);
    R := ARect;

    if (ItemOptions and IO_COMBO) <> 0 then
    begin
      X := R.Right - ArrowWidth - 1;
      if not ItemInfo.Enabled then Pen.Color := ClrText
      else if HoverKind = hkMouseHover then Pen.Color := GetPartColor(ItemInfo, ipFrame)
      else Pen.Color := PopupSeparatorColor;
      MoveTo(X, R.Top + 1);
      LineTo(X, R.Bottom - 1);
    end;

    if (ItemOptions and IO_SUBMENUITEM) <> 0 then
    begin
      Y := ARect.Bottom div 2;
      X := ARect.Right - ArrowWidth * 2 div 3 - 1;
      DrawArrow(ClrText);
    end;

    InflateRect(ARect, -1, -1);

    if Selected and Enabled then
    begin
      R := ARect;
      R.Left := ARect.Left + 1;
      R.Right := R.Left + ItemInfo.PopupMargin - 2;
      FrameRectEx(Canvas, R, GetBtnColor(ItemInfo, ipFrame), True);
      FillRectEx(Canvas, R, GetBtnColor(ItemInfo, ipBody));
    end;
  end;
end;

procedure TTBXNewOfficeXPTheme.PaintPopupNCArea(Canvas: TCanvas; R: TRect; const PopupInfo: TTBXPopupInfo);
var
  PR: TRect;
begin
  with Canvas do
  begin
    Brush.Color := PopupFrameColor;
    FrameRect(R);
    InflateRect(R, -1, -1);
    Brush.Color := PopupColor;
    FillRect(R);

    if not IsRectEmpty(PopupInfo.ParentRect) then
    begin
      PR := PopupInfo.ParentRect;
      if not IsRectEmpty(PR) then with PR do
      begin
        Pen.Color := ToolbarColor;
        if Bottom = R.Top then
        begin
          if Left <= R.Left then Left := R.Left - 1;
          if Right >= R.Right then Right := R.Right + 1;
          MoveTo(Left + 1, Bottom - 1);
          LineTo(Right - 1, Bottom- 1);
        end
        else if Top = R.Bottom then
        begin
          if Left <= R.Left then Left := R.Left - 1;
          if Right >= R.Right then Right := R.Right + 1;
          MoveTo(Left + 1, Top);
          LineTo(Right - 1, Top);
        end;
        if Right = R.Left then
        begin
          if Top <= R.Top then Top := R.Top - 1;
          if Bottom >= R.Bottom then Bottom := R.Bottom + 1;
          MoveTo(Right - 1, Top + 1);
          LineTo(Right - 1, Bottom - 1);
        end
        else if Left = R.Right then
        begin
          if Top <= R.Top then Top := R.Top - 1;
          if Bottom >= R.Bottom then Bottom := R.Bottom + 1;
          MoveTo(Left, Top + 1);
          LineTo(Left, Bottom - 1);
        end;
      end;
    end;
  end;
end;

procedure TTBXNewOfficeXPTheme.PaintSeparator(Canvas: TCanvas; ARect: TRect;
  ItemInfo: TTBXItemInfo; Horizontal, LineSeparator: Boolean);
var
  IsToolbox: Boolean;
  R: TRect;
begin
  { Note: for blank separators, Enabled = False }
  with ItemInfo, ARect, Canvas do
  begin
    if Horizontal then
    begin
      IsToolbox := (ViewType and PVT_TOOLBOX) = PVT_TOOLBOX;
      if ((ItemOptions and IO_TOOLBARSTYLE) = 0) and not IsToolBox then
      begin
        R := ARect;
        R.Right := ItemInfo.PopupMargin + 2;
        Brush.Color := ToolbarColor;
        FillRect(R);
        Inc(Left, ItemInfo.PopupMargin + 9);
        Pen.Color := PopupSeparatorColor;
      end
      else
        Pen.Color := ToolbarSeparatorColor;
      Top := Bottom div 2;
      if Enabled then
      begin
        MoveTo(Left, Top); LineTo(Right, Top);
      end;
    end
    else if Enabled then
    begin
      Left := Right div 2;
      DrawLineEx(Canvas, Left, Top, Left, Bottom, ToolbarSeparatorColor);
    end;
  end;
end;

procedure DrawButtonBitmap(Canvas: TCanvas; R: TRect; Color: TColor);
const
{$IFNDEF SMALL_CLOSE_BUTTON}
  Pattern: array [0..15] of Byte =
    ($C3, 0, $66, 0, $3C, 0, $18, 0, $3C, 0, $66, 0, $C3, 0, 0, 0);
{$ELSE}
  Pattern: array [0..15] of Byte =
    (0, 0, $63, 0, $36, 0, $1C, 0, $1C, 0, $36, 0, $63, 0, 0, 0);
{$ENDIF}
var
  Bmp: TBitmap;
  W, H: Integer;
  Index: Integer;
begin
  Bmp := TBitmap.Create;
  try
    Bmp.Handle := CreateBitmap(8, 8, 1, 1, @Pattern);
    Index := SaveDC(Canvas.Handle);
    Canvas.Brush.Color  := Color;
    SetTextColor(Canvas.Handle, clBlack);
    SetBkColor(Canvas.Handle, clWhite);
    W := 8;
    H := 7;
    with R do
    begin
      BitBlt(Canvas.Handle, (Left + Right - W + 1) div 2, (Top + Bottom - H) div 2, W, H,
        Bmp.Canvas.Handle, 0, 0, ROP_DSPDxax);
    end;
    RestoreDC(Canvas.Handle, Index);
  finally
    Bmp.Free;
  end;
end;

procedure TTBXNewOfficeXPTheme.PaintToolbarNCArea(Canvas: TCanvas; R: TRect; const ToolbarInfo: TTBXToolbarInfo);
const
  DragHandleSizes: array [Boolean, DHS_DOUBLE..DHS_SINGLE] of Integer = ((9, 0, 6), (14, 14, 14));
  DragHandleOffsets: array [Boolean, DHS_DOUBLE..DHS_SINGLE] of Integer = ((2, 0, 2), (3, 0, 5));
  GripperPart: array [Boolean] of Cardinal = (RP_GRIPPER, RP_GRIPPERVERT);
var
  Sz: Integer;
  R2: TRect;
  Flags: Cardinal;
  Z: Integer;
//  SaveColor: TColor;
//  SaveStyle: TBrushStyle;
  BtnVisible, Horz, CloseButtondown, CloseButtonHover: Boolean;
  Col1: TColor;
  Red, Green, Blue: Byte;

  procedure DrawButtonBitmap;
  const
    ROP_DSPDxax = $00E20746;
    Pattern: array [0..15] of Byte =
      (0, 0, $CC, 0, $78, 0, $30, 0, $78, 0, $CC, 0, 0, 0, 0, 0);
  var
    Bmp: TBitmap;
    W, H: Integer;
    OldBrush: HBRUSH;
  begin
    Bmp := TBitmap.Create;
    try
      Bmp.Handle := CreateBitmap(8, 8, 1, 1, @Pattern);
      SetTextColor(Canvas.Handle, clBlack);
      SetBkColor(Canvas.Handle, clWhite);
      OldBrush := SelectObject(Canvas.Handle, GetSysColorBrush(COLOR_BTNTEXT));
      W := 7;
      H := 7;
      with R2 do
        BitBlt(Canvas.Handle, (Left + Right - W + 1) div 2, (Top + Bottom - H) div 2, W, H,
          Bmp.Canvas.Handle, 0, 0, ROP_DSPDxax);
      SelectObject(Canvas.Handle, OldBrush);
    finally
      Bmp.Free;
    end;
  end;

begin
//  SaveColor := Canvas.Brush.Color;
//  SaveStyle := Canvas.Brush.Style;

  Canvas.FillRect(R);

  { Border }
  if USE_THEMES then
  begin
{    if ToolbarInfo.BorderStyle = bsSingle then
      DrawThemeEdge(TOOLBAR_THEME, Canvas.Handle, RP_BAND, 0, R,
        BDR_RAISEDINNER, BF_RECT or BF_ADJUST, @R);}
    if ToolbarInfo.BorderStyle = bsSingle then with Canvas do
    begin
//      Windows.DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_RECT or BF_ADJUST);
      Pen.Color := clBtnHighlight;
      MoveTo(0, 0);
      LineTo(R.Right - 1, 0);
      MoveTo(0, 0);
      LineTo(0, R.Bottom - 1);
      Col1 := MixColors(clBtnFace, clBlack, 235);
      Red := GetRValue(Col1);
      Green := GetGValue(Col1) - 3;
      Blue := GetBValue(Col1) - 9;
      Col1 := RGB(Red, Green, Blue);
      if (Col1 <> $BDD2D8) and (Col1 <> $C7C9CD) then Col1 := clBtnShadow; // very crude :-) but works
      Pen.Color := Col1;
      MoveTo(R.Right - 1, 0);
      LineTo(R.Right - 1, R.Bottom);
      MoveTo(0, R.Bottom - 1);
      LineTo(R.Right, R.Bottom - 1);
    end;
  end
  else
  begin
    if ToolbarInfo.BorderStyle = bsSingle then
      Windows.DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_RECT or BF_ADJUST);
  end;

  if not ToolbarInfo.AllowDrag then Exit;

  BtnVisible := (ToolbarInfo.CloseButtonState and CDBS_VISIBLE) <> 0;
  Sz := GetTBXDragHandleSize(ToolbarInfo);
  if (USE_THEMES) and (ToolbarInfo.DragHandleStyle = DHS_SINGLE) then Inc(Sz, 2);
  Horz := not ToolbarInfo.IsVertical;
  if Horz then R.Right := R.Left + Sz
  else R.Bottom := R.Top + Sz;

  { Drag handle area }
  if ToolbarInfo.DragHandleStyle <> DHS_NONE then
  begin
    if USE_THEMES then
    begin
      R2 := R;
      if BtnVisible then
        if Horz then Inc(R2.Top, Sz - 1)
        else Dec(R2.Right, Sz - 1);

      if Horz then
      begin
        R2.Left := (R2.Left + R2.Right - 6) div 2;
        R2.Right := R2.Left + 6;
        if R2.Bottom - R2.Top + 1 < 25 then Dec(R2.Bottom);
        if R2.Bottom - R2.Top + 1 = 49 then Dec(R2.Bottom, 2); // crude, but it works
      end
      else
      begin
        R2.Top := (R2.Top + R2.Bottom - 6) div 2;
        R2.Bottom := R2.Top + 6;
        Dec(R2.Right);
      end;
      DrawThemeBackground(REBAR_THEME, Canvas.Handle,
        GripperPart[ToolbarInfo.IsVertical], 0, R2, nil)
    end
    else
    begin
      R2 := R;
      if Horz then
      begin
        Inc(R2.Left, DragHandleOffsets[BtnVisible, ToolbarInfo.DragHandleStyle]);
        if BtnVisible then Inc(R2.Top, Sz - 2);
        R2.Right := R2.Left + 3;
        InflateRect(R2, 0, -1);
      end
      else
      begin
        Inc(R2.Top, DragHandleOffsets[BtnVisible, ToolbarInfo.DragHandleStyle]);
        if BtnVisible then Dec(R2.Right, Sz - 2);
        R2.Bottom := R2.Top + 3;
        InflateRect(R2, -1, 0);
      end;

      Windows.DrawEdge(Canvas.Handle, R2, BDR_RAISEDINNER, BF_RECT);
      Canvas.Pixels[R2.Left, R2.Bottom - 1] := clBtnHighlight;
      if ToolbarInfo.DragHandleStyle = DHS_DOUBLE then
      begin
        if Horz then OffsetRect(R2, 3, 0)
        else OffsetRect(R2, 0, 3);
        Windows.DrawEdge(Canvas.Handle, R2, BDR_RAISEDINNER, BF_RECT);
        Canvas.Pixels[R2.Left, R2.Bottom - 1] := clBtnHighlight;
      end;
    end;
  end;

  { Close Button }
  if BtnVisible then
  begin
    CloseButtonDown := (ToolbarInfo.CloseButtonState and CDBS_PRESSED) <> 0;
    CloseButtonHover := (ToolbarInfo.CloseButtonState and CDBS_HOT) <> 0;
    R2 := GetTBXDockedCloseButtonRect(ToolbarInfo);
    Z := 2;
    if USE_THEMES then Z := 1;
    if Horz then
    begin
      Dec(R2.Bottom, Z);
      Dec(R2.Right, Z);
    end
    else
    begin
      Dec(R2.Bottom, Z);
      Inc(R2.Left, Z);
    end;
    if USE_THEMES then
    begin
      Flags := TS_NORMAL;
      if CloseButtonDown then Flags := TS_PRESSED
      else if CloseButtonHover then Flags := TS_HOT;
      DrawThemeBackground(TOOLBAR_THEME, Canvas.Handle, TP_BUTTON, Flags, R2, nil);
      if CloseButtonDown then OffsetRect(R2, 1, 1);
      DrawButtonBitmap;
    end
    else
    begin
      if CloseButtonDown then
      begin
        Windows.DrawEdge(Canvas.Handle, R2, BDR_SUNKENOUTER, BF_RECT);
        OffsetRect(R2, 1, 1);
      end
      else if CloseButtonHover then
        Windows.DrawEdge(Canvas.Handle, R2, BDR_RAISEDINNER, BF_RECT);
      DrawButtonBitmap;
    end;
  end;
end;

procedure TTBXNewOfficeXPTheme.PaintDock(Canvas: TCanvas; const ClientRect,
  DockRect: TRect; DockPosition: Integer);
begin
  if not USE_THEMES then Exit;
  DrawThemeBackground(REBAR_THEME, Canvas.Handle, 0, 0, DockRect, nil);
end;

procedure TTBXNewOfficeXPTheme.PaintDockPanelNCArea(Canvas: TCanvas; R: TRect; const DockPanelInfo: TTBXDockPanelInfo);

  function GetBtnItemState(BtnState: Integer): TBtnItemState;
  begin
    if (BtnState and CDBS_PRESSED) <> 0 then Result := bisPressed
    else if (BtnState and CDBS_HOT) <> 0 then Result := bisHot
    else Result := bisNormal;
  end;

var
  Sz, Flags: Integer;
  R2: TRect;
  BtnItemState: TBtnItemState;
  Col1: TColor;
  Red, Green, Blue: Byte;
begin
  with Canvas, DockPanelInfo do
  begin
    Sz := GetSystemMetrics(SM_CYSMCAPTION);

    { Border }
    FrameRectEx(Canvas, R, ToolbarColor, True);
    R2 := R;
    if ShowCaption then
      if IsVertical then Inc(R2.Top, Sz)
      else Inc(R2.Left, Sz);
    Brush.Color := clWindow;
    FrameRect(R2);

    if not ShowCaption then Exit;

    { Caption area }
    if IsVertical then R.Bottom := R.Top + Sz
    else R.Right := R.Left + Sz;
    if USE_THEMES then
      DrawThemeBackground(REBAR_THEME, Handle, 0, 0, R, nil)
    else
      FillRectEx(Canvas, R, clBtnFace);
//    Windows.DrawEdge(Handle, R, BDR_RAISEDINNER, BF_RECT or BF_ADJUST);

    Pen.Color := clBtnHighlight;
    MoveTo(1, 1);
    LineTo(R.Right - 1, 1);
    MoveTo(1, 1);
    LineTo(1, R.Bottom - 1);
    Col1 := MixColors(clBtnFace, clBlack, 235);
    Red := GetRValue(Col1);
    Green := GetGValue(Col1) - 3;
    Blue := GetBValue(Col1) - 9;
    Col1 := RGB(Red, Green, Blue);
    if (Col1 <> $BDD2D8) and (Col1 <> $C7C9CD) then Col1 := clBtnShadow; // very crude :-) but works
    Pen.Color := Col1;
    MoveTo(R.Right - 1, 1);
    LineTo(R.Right - 1, R.Bottom);
    MoveTo(1, R.Bottom - 1);
    LineTo(R.Right, R.Bottom - 1);

    { Close button }
    if (CDBS_VISIBLE and CloseButtonState) <> 0 then
    begin
      R2 := R;
      if IsVertical then
      begin
        R2.Left := R2.Right - Sz + 1;
        R.Right := R2.Left;
      end
      else
      begin
        R2.Top := R2.Bottom - Sz + 1;
        R.Bottom := R2.Top;
      end;

//      Inc(R2.Top);
//      Inc(R2.Left);
      Dec(R2.Bottom);
      Dec(R2.Right);

      BtnItemState := GetBtnItemState(CloseButtonState);
      FrameRectEx(Canvas, R2, BtnItemColors[BtnItemState, ipFrame], True);
      FillRectEx(Canvas, R2, BtnItemColors[BtnItemState, ipBody]);
      Dec(R2.Left);
      DrawButtonBitmap(Canvas, R2, BtnItemColors[BtnItemState, ipText]);
    end;

    { Caption }
    Brush.Color := ToolbarColor;
    //FillRect(R);
    if IsVertical then InflateRect(R, -2, 0)
    else Inflaterect(R, 0, -2);
    Font.Assign(SmCaptionFont);
    Font.Color := clBtnText;
    Font.Style := Font.Style - [fsBold];  // Get rid of Bold, ugly, does not look like XP;
    Brush.Style := bsClear;
    Flags := DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS or DT_NOPREFIX;
    if IsVertical then DrawText(Canvas.Handle, Caption, -1, R, Flags)
    else DrawRotatedText(Canvas.Handle, string(Caption), R, Flags);
    Brush.Style := bsSolid;
  end;
end;

procedure TTBXNewOfficeXPTheme.SetupColorCache;
var
  DC: HDC;
  HotBtnFace, DisabledText: TColor;

  procedure Undither(var C: TColor);
  begin
    if C <> clNone then C := GetNearestColor(DC, ColorToRGB(C));
  end;

begin
  DC := StockCompatibleBitmap.Canvas.Handle;

  if TBXLoColor then
  begin
    { View/Window Colors }
    MenubarColor := clBtnFace;
    ToolbarColor := clBtnFace;
    PopupColor := clWindow;
    DockPanelColor := clWindow;
    StatusPanelFrameColor := clBtnShadow;

    PopupFrameColor := clBtnText;
    WinFrameColors[wfsActive, wfpBorder]        := clBtnShadow;
    WinFrameColors[wfsActive, wfpCaption]       := clBtnShadow;
    WinFrameColors[wfsActive, wfpCaptionText]   := clBtnHighlight;
    WinFrameColors[wfsInactive, wfpBorder]      := clBtnShadow;
    WinFrameColors[wfsInactive, wfpCaption]     := clBtnShadow;
    WinFrameColors[wfsInactive, wfpCaptionText] := clBtnHighlight;

    PnlFrameColors[wfsActive, wfpBorder]        := clBtnShadow;
    PnlFrameColors[wfsActive, wfpCaption]       := clBtnFace;
    PnlFrameColors[wfsActive, wfpCaptionText]   := clBtnText;
    PnlFrameColors[wfsInactive, wfpBorder]      := clBtnShadow;
    PnlFrameColors[wfsInactive, wfpCaption]     := clBtnFace;
    PnlFrameColors[wfsInactive, wfpCaptionText] := clBtnText;

    MenuItemColors[misNormal, ipBody]          := clNone;
    MenuItemColors[misNormal, ipText]          := clWindowText;
    MenuItemColors[misNormal, ipFrame]         := clNone;
    MenuItemColors[misDisabled, ipBody]        := clNone;
    MenuItemColors[misDisabled, ipText]        := clGrayText;
    MenuItemColors[misDisabled, ipFrame]       := clNone;
    MenuItemColors[misHot, ipBody]             := clWindow;
    MenuItemColors[misHot, ipText]             := clWindowtext;
    MenuItemColors[misHot, ipFrame]            := clHighlight;
    MenuItemColors[misDisabledHot, ipBody]     := clWindow;
    MenuItemColors[misDisabledHot, ipText]     := clGrayText;
    MenuItemColors[misDisabledHot, ipFrame]    := clHighlight;

    BtnItemColors[bisNormal, ipBody]           := clNone;
    BtnItemColors[bisNormal, ipText]           := clBtnText;
    BtnItemColors[bisNormal, ipFrame]          := clNone;
    BtnItemColors[bisDisabled, ipBody]         := clNone;
    BtnItemColors[bisDisabled, ipText]         := clBtnShadow;
    BtnItemColors[bisDisabled, ipFrame]        := clNone;
    BtnItemColors[bisSelected, ipBody]         := clWindow;
    BtnItemColors[bisSelected, ipText]         := clWindowText;
    BtnItemColors[bisSelected, ipFrame]        := clHighlight;
    BtnItemColors[bisPressed, ipBody]          := clHighlight;
    BtnItemColors[bisPressed, ipText]          := clHighlightText;
    BtnItemColors[bisPressed, ipFrame]         := clHighlight;
    BtnItemColors[bisHot, ipBody]              := clWindow;
    BtnItemColors[bisHot, ipText]              := clWindowText;
    BtnItemColors[bisHot, ipFrame]             := clHighlight;
    BtnItemColors[bisDisabledHot, ipBody]      := clWindow;
    BtnItemColors[bisDisabledHot, ipText]      := clBtnShadow;
    BtnItemColors[bisDisabledHot, ipFrame]     := clHighlight;
    BtnItemColors[bisSelectedHot, ipBody]      := clHighlight;
    BtnItemColors[bisSelectedHot, ipText]      := clHighlightText;
    BtnItemColors[bisSelectedHot, ipFrame]     := clHighlight;
    BtnItemColors[bisPopupParent, ipBody]      := clBtnFace;
    BtnItemColors[bisPopupParent, ipText]      := clBtnText;
    BtnItemColors[bisPopupParent, ipFrame]     := PopupFrameColor;

    { Other Colors }
    DragHandleColor := clBtnText;
    IconShadowColor := clBtnFace;
    PopupSeparatorColor := clBtnShadow;
    ToolbarSeparatorColor := clBtnShadow;
  end
 else
  begin
    { View/Window Colors }
    MenubarColor := clBtnFace;
    ToolbarColor := {Blend(clWindow, clBtnFace, 165)}clBtnFace;
    PopupColor := Blend(clBtnFace, clWindow, 143);
    DockPanelColor := PopupColor;
    PopupFrameColor := Blend(clBtnText, clBtnShadow, 20);
    SetContrast(PopupFrameColor, PopupColor, 100);

    HotBtnFace := Blend(clHighlight, clWindow, 30);
    SetContrast(HotBtnFace, {ToolbarColor}Blend(clWindow, clBtnFace, 165), 50); // XP Silver Bugfix
    DisabledText := Blend(clBtnshadow, clWindow, 90);

    WinFrameColors[wfsActive, wfpBorder]        := Blend(clBtnText, clBtnShadow, 15);
    SetContrast(WinFrameColors[wfsActive, wfpBorder], ToolbarColor, 120);
    WinFrameColors[wfsActive, wfpCaption]       := clBtnShadow;
    WinFrameColors[wfsActive, wfpCaptionText]   := clBtnHighlight;
    SetContrast(WinFrameColors[wfsActive, wfpCaptionText], clBtnShadow, 180);
    WinFrameColors[wfsInactive, wfpBorder]      := WinFrameColors[wfsActive, wfpBorder];
    WinFrameColors[wfsInactive, wfpCaption]     := clBtnFace;
    WinFrameColors[wfsInactive, wfpCaptionText] := DisabledText;
    SetContrast(WinFrameColors[wfsInactive, wfpCaptionText], clBtnFace, 120);

    PnlFrameColors[wfsActive, wfpBorder]        := clBtnShadow;
    PnlFrameColors[wfsActive, wfpCaption]       := clBtnFace;
    PnlFrameColors[wfsActive, wfpCaptionText]   := clBtnText;
    PnlFrameColors[wfsInactive, wfpBorder]      := clBtnShadow;
    PnlFrameColors[wfsInactive, wfpCaption]     := clBtnFace;
    PnlFrameColors[wfsInactive, wfpCaptionText] := DisabledText;
    SetContrast(PnlFrameColors[wfsInactive, wfpCaptionText], clBtnFace, 120);

    BtnItemColors[bisNormal, ipBody]           := clNone;
    BtnItemColors[bisNormal, ipText]           := clBtnText;
    SetContrast(BtnItemColors[bisNormal, ipText], ToolbarColor, 180);
    BtnItemColors[bisNormal, ipFrame]          := clNone;
    BtnItemColors[bisDisabled, ipBody]         := clNone;
    BtnItemColors[bisDisabled, ipText]         := DisabledText;
    SetContrast(BtnItemColors[bisDisabled, ipText], ToolbarColor, 80);
    BtnItemColors[bisDisabled, ipFrame]        := clNone;
    BtnItemColors[bisSelected, ipBody]         := Blend(clHighlight, Blend(clBtnFace, clWindow, 50), 10);
    SetContrast(BtnItemColors[bisSelected, ipBody], ToolbarColor, 5);
    BtnItemColors[bisSelected, ipText]         := BtnItemColors[bisNormal, ipText];
    BtnItemColors[bisSelected, ipFrame]        := clHighlight;
    BtnItemColors[bisPressed, ipBody]          := Blend(clHighlight, clWindow, 50);
    BtnItemColors[bisPressed, ipText]          := clHighlightText;
    BtnItemColors[bisPressed, ipFrame]         := clHighlight;
    BtnItemColors[bisHot, ipBody]              := HotBtnFace;
    BtnItemColors[bisHot, ipText]              := clMenuText;
    SetContrast(BtnItemColors[bisHot, ipText], BtnItemColors[bisHot, ipBody], 180);
    BtnItemColors[bisHot, ipFrame]             := clHighlight;
    SetContrast(BtnItemColors[bisHot, ipFrame], ToolbarColor, 100);
    BtnItemColors[bisDisabledHot, ipBody]      := HotBtnFace;
    BtnItemColors[bisDisabledHot, ipText]      := DisabledText;
    BtnItemColors[bisDisabledHot, ipFrame]     := clHighlight;
    BtnItemColors[bisSelectedHot, ipBody]      := Blend(clHighlight, clWindow, 50);
    SetContrast(BtnItemColors[bisSelectedHot, ipBody], ToolbarColor, 30);
    BtnItemColors[bisSelectedHot, ipText]      := clHighlightText;
    SetContrast(BtnItemColors[bisSelectedHot, ipText], BtnItemColors[bisSelectedHot, ipBody], 180);
    BtnItemColors[bisSelectedHot, ipFrame]     := clHighlight;
    SetContrast(BtnItemColors[bisSelectedHot, ipFrame], BtnItemColors[bisSelectedHot, ipBody], 100);
    BtnItemColors[bisPopupParent, ipBody]      := ToolbarColor;
    BtnItemColors[bisPopupParent, ipText]      := BtnItemColors[bisNormal, ipText];
    BtnItemColors[bisPopupParent, ipFrame]     := PopupFrameColor;

    MenuItemColors[misNormal, ipBody]          := clNone;
    MenuItemColors[misNormal, ipText]          := clWindowText;
    SetContrast(MenuItemColors[misNormal, ipText], PopupColor, 180);
    MenuItemColors[misNormal, ipFrame]         := clNone;
    MenuItemColors[misDisabled, ipBody]        := clNone;
    MenuItemColors[misDisabled, ipText]        := Blend(clGrayText, clWindow, 70);
    SetContrast(MenuItemColors[misDisabled, ipText], PopupColor, 80); // 145?
    MenuItemColors[misDisabled, ipFrame]       := clNone;
    MenuItemColors[misHot, ipBody]             := BtnItemColors[bisHot, ipBody];
    MenuItemColors[misHot, ipText]             := BtnItemColors[bisHot, ipText];
    MenuItemColors[misHot, ipFrame]            := BtnItemColors[bisHot, ipFrame];
    MenuItemColors[misDisabledHot, ipBody]     := PopupColor;
    MenuItemColors[misDisabledHot, ipText]     := Blend(clGrayText, clWindow, 70);
    MenuItemColors[misDisabledHot, ipFrame]    := clHighlight;

    { Other Colors }
    DragHandleColor := Blend(clBtnShadow, clWindow, 75);
    SetContrast(DragHandleColor, ToolbarColor, 85);
    IconShadowColor := Blend(clBlack, HotBtnFace, 25);
    ToolbarSeparatorColor := Blend(clBtnShadow, clWindow, 70);
    SetContrast(ToolbarSeparatorColor, ToolbarColor, 50);
    PopupSeparatorColor := ToolbarSeparatorColor;
    StatusPanelFrameColor := Blend(clWindow, clBtnFace, 30);
    SetContrast(StatusPanelFrameColor, clBtnFace, 30);

    Undither(MenubarColor);
    Undither(ToolbarColor);
    Undither(PopupColor);
    Undither(DockPanelColor);
    Undither(PopupFrameColor);
    Undither(WinFrameColors[wfsActive, wfpBorder]);
    Undither(WinFrameColors[wfsActive, wfpCaption]);
    Undither(WinFrameColors[wfsActive, wfpCaptionText]);
    Undither(WinFrameColors[wfsInactive, wfpBorder]);
    Undither(WinFrameColors[wfsInactive, wfpCaption]);
    Undither(WinFrameColors[wfsInactive, wfpCaptionText]);
    Undither(PnlFrameColors[wfsActive, wfpBorder]);
    Undither(PnlFrameColors[wfsActive, wfpCaption]);
    Undither(PnlFrameColors[wfsActive, wfpCaptionText]);
    Undither(PnlFrameColors[wfsInactive, wfpBorder]);
    Undither(PnlFrameColors[wfsInactive, wfpCaption]);
    Undither(PnlFrameColors[wfsInactive, wfpCaptionText]);
    Undither(BtnItemColors[bisNormal, ipBody]);
    Undither(BtnItemColors[bisNormal, ipText]);
    Undither(BtnItemColors[bisNormal, ipFrame]);
    Undither(BtnItemColors[bisDisabled, ipBody]);
    Undither(BtnItemColors[bisDisabled, ipText]);
    Undither(BtnItemColors[bisDisabled, ipFrame]);
    Undither(BtnItemColors[bisSelected, ipBody]);
    Undither(BtnItemColors[bisSelected, ipText]);
    Undither(BtnItemColors[bisSelected, ipFrame]);
    Undither(BtnItemColors[bisPressed, ipBody]);
    Undither(BtnItemColors[bisPressed, ipText]);
    Undither(BtnItemColors[bisPressed, ipFrame]);
    Undither(BtnItemColors[bisHot, ipBody]);
    Undither(BtnItemColors[bisHot, ipText]);
    Undither(BtnItemColors[bisHot, ipFrame]);
    Undither(BtnItemColors[bisDisabledHot, ipBody]);
    Undither(BtnItemColors[bisDisabledHot, ipText]);
    Undither(BtnItemColors[bisDisabledHot, ipFrame]);
    Undither(BtnItemColors[bisSelectedHot, ipBody]);
    Undither(BtnItemColors[bisSelectedHot, ipText]);
    Undither(BtnItemColors[bisSelectedHot, ipFrame]);
    Undither(BtnItemColors[bisPopupParent, ipBody]);
    Undither(BtnItemColors[bisPopupParent, ipText]);
    Undither(BtnItemColors[bisPopupParent, ipFrame]);
    Undither(MenuItemColors[misNormal, ipBody]);
    Undither(MenuItemColors[misNormal, ipText]);
    Undither(MenuItemColors[misNormal, ipFrame]);
    Undither(MenuItemColors[misDisabled, ipBody]);
    Undither(MenuItemColors[misDisabled, ipText]);
    Undither(MenuItemColors[misDisabled, ipFrame]);
    Undither(MenuItemColors[misHot, ipBody]);
    Undither(MenuItemColors[misHot, ipText]);
    Undither(MenuItemColors[misHot, ipFrame]);
    Undither(MenuItemColors[misDisabledHot, ipBody]);
    Undither(MenuItemColors[misDisabledHot, ipText]);
    Undither(MenuItemColors[misDisabledHot, ipFrame]);
    Undither(DragHandleColor);
    Undither(IconShadowColor);
    Undither(ToolbarSeparatorColor);
    Undither(PopupSeparatorColor);
    Undither(StatusPanelFrameColor);
  end;
end;

function TTBXNewOfficeXPTheme.GetPopupShadowType: Integer;
begin
  Result := PST_OFFICEXP;
end;

constructor TTBXNewOfficeXPTheme.Create(const AName: string);
begin
  inherited;
  if CounterLock = 0 then InitializeStock;
  Inc(CounterLock);
  AddTBXSysChangeNotification(Self);
  SetupColorCache;
end;

destructor TTBXNewOfficeXPTheme.Destroy;
begin
  RemoveTBXSysChangeNotification(Self);
  Dec(CounterLock);
  if CounterLock = 0 then FinalizeStock;
  inherited;
end;

procedure TTBXNewOfficeXPTheme.GetViewMargins(ViewType: Integer;
  out Margins: TTBXMargins);
begin
  Margins.LeftWidth := 0;
  Margins.TopHeight := 0;
  Margins.RightWidth := 0;
  Margins.BottomHeight := 0;
end;

procedure TTBXNewOfficeXPTheme.PaintPageScrollButton(Canvas: TCanvas;
  const ARect: TRect; ButtonType: Integer; Hot: Boolean);
var
  R: TRect;
  X, Y, Sz: Integer;
begin
  R := ARect;
  if Hot then Canvas.Brush.Color := BtnItemColors[bisHot, ipFrame]
  else Canvas.Brush.Color := clBtnShadow;
  Canvas.FrameRect(R);
  if Hot then Canvas.Brush.Color := BtnItemColors[bisHot, ipBody]
  else Canvas.Brush.Color := clBtnFace;
  InflateRect(R, -1, -1);
  Canvas.FillRect(R);
  X := (R.Left + R.Right) div 2;
  Y := (R.Top + R.Bottom) div 2;
  Sz := Min(X - R.Left, Y - R.Top) * 3 div 4;
  if Hot then Canvas.Pen.Color := BtnItemColors[bisHot, ipText]
  else Canvas.Pen.Color := BtnItemColors[bisNormal, ipText];
  Canvas.Brush.Color := Canvas.Pen.Color;
  case ButtonType of
    PSBT_UP:
      begin
        Inc(Y, Sz div 2);
        Canvas.Polygon([Point(X + Sz, Y), Point(X, Y - Sz), Point(X - Sz, Y)]);
      end;
    PSBT_DOWN:
      begin
        Y := (R.Top + R.Bottom - 1) div 2;
        Dec(Y, Sz div 2);
        Canvas.Polygon([Point(X + Sz, Y), Point(X, Y + Sz), Point(X - Sz, Y)]);
      end;
    PSBT_LEFT:
      begin
        Inc(X, Sz div 2);
        Canvas.Polygon([Point(X, Y + Sz), Point(X - Sz, Y), Point(X, Y - Sz)]);
      end;
    PSBT_RIGHT:
      begin
        X := (R.Left + R.Right - 1) div 2;
        Dec(X, Sz div 2);
        Canvas.Polygon([Point(X, Y + Sz), Point(X + Sz, Y), Point(X, Y - Sz)]);
      end;
  end;
end;

procedure TTBXNewOfficeXPTheme.PaintGlyph(Canvas: TCanvas; R: TRect; Kind, State: Integer);
var
  X, Y: Integer;

  procedure SetupPen;
  begin
    if Boolean(State and GS_DISABLED) then Canvas.Pen.Color := clBtnShadow
    else if Boolean(State and GS_PUSHED) then Canvas.Pen.Color := BtnItemColors[bisPressed, ipFrame]
    else if Boolean(State and GS_HOT) then Canvas.Pen.Color := BtnItemColors[bisHot, ipFrame]
    else Canvas.Pen.Color := clBtnShadow;
  end;

  procedure SetupBrush;
  begin
    Canvas.Brush.Style := bsSolid;
    if Boolean(State and GS_DISABLED) then Canvas.Brush.Style := bsClear
    else if Boolean(State and GS_PUSHED) then Canvas.Brush.Color := BtnItemColors[bisPressed, ipBody]
    else if Boolean(State and GS_HOT) then Canvas.Brush.Color := BtnItemColors[bisHot, ipBody]
    else if Boolean(State and GS_MIXED) then Canvas.Brush.Bitmap := AllocPatternBitmap(clWindow, clBtnFace)
    else Canvas.Brush.Style := bsClear;
  end;

  function TextColor: TColor;
  begin
    if Boolean(State and GS_DISABLED) then Result := BtnItemColors[bisDisabled, ipText]
    else if Boolean(State and GS_PUSHED) then Result := BtnItemColors[bisPressed, ipText]
    else if Boolean(State and GS_MIXED) then Result := clBtnShadow
    else if Boolean(State and GS_HOT) then Result := BtnItemColors[bisHot, ipText]
    else Result := BtnItemColors[bisNormal, ipText];
  end;

  procedure DiagLine(C: TColor);
  begin
    with Canvas, R do
    begin
      Pen.Color := C;
      MoveTo(Right - 1 - X, Bottom - 1); LineTo(Right, Bottom - X - 2);
      Inc(X);
    end;
  end;

begin
  with Canvas do case Kind of
    GK_CHECKBOX:
      begin
        SetupPen;
        SetupBrush;
        InflateRect(R, -1, -1);
        with R do Rectangle(Left, Top, Right, Bottom);
        Pen.Style := psSolid;
        Brush.Style := bsSolid;

        if Boolean(State and (GS_CHECKED or GS_MIXED)) then
        begin
          X := (R.Left + R.Right) div 2 - 1;
          Y := (R.Top + R.Bottom) div 2 + 1;
          Pen.Color := TextColor;
          Brush.Color := Pen.Color;
          Polygon([Point(X-2, Y), Point(X, Y+2), Point(X+4, Y-2),
            Point(X+4, Y-4), Point(X, Y), Point(X-2, Y-2), Point(X-2, Y)]);
        end;
      end;
    GK_RADIOBUTTON:
      begin
        SetupPen;
        SetupBrush;
        InflateRect(R, -1, -1);
        with R do Ellipse(Left, Top, Right, Bottom);
        Pen.Style := psSolid;
        Brush.Style := bsSolid;
        if Boolean(State and GS_CHECKED) then
        begin
          InflateRect(R, -3, -3);
          Pen.Color := TextColor;
          Brush.Color := Pen.Color;
          with R do Ellipse(Left, Top, Right, Bottom);
        end;
      end;
  end;
end;

procedure TTBXNewOfficeXPTheme.PaintStatusBar(Canvas: TCanvas; R: TRect; Part: Integer);
var
  D, Sz, I, Flags: Integer;

  procedure DiagLine(C: TColor);
  begin
    with R do
      DrawLineEx(Canvas, Right - 2 - D, Bottom - 2, Right - 1, Bottom - D - 3, C);
    Inc(D);
  end;

begin
  with Canvas do
    case Part of
      SBP_BODY:
        begin
          if USE_THEMES then
            DrawThemeBackground(STATUSBAR_THEME, Canvas.Handle, 0, 0, R, nil)
          else
            FillRectEx(Canvas, R, clBtnFace);
        end;
      SBP_PANE, SBP_LASTPANE:
        begin
          if USE_THEMES then
          begin
            if Part = SBP_LASTPANE then Flags := SP_GRIPPERPANE
            else Flags := SP_PANE;
            DrawThemeBackground(STATUSBAR_THEME, Canvas.Handle, Flags, 0, R, nil);
          end
          else
          begin
            if Part = SBP_PANE then Dec(R.Right, 2);
            Frame3D(Canvas, R, clBtnShadow, clBtnHighlight);
          end;
        end;
      SBP_GRIPPER:
        begin
          if USE_THEMES then
            DrawThemeBackground(STATUSBAR_THEME, Canvas.Handle, SP_GRIPPER, 0, R, nil)
          else
          begin
            D := 0;
            Sz := Min(R.Right - R.Left, R.Bottom - R.Top);
            for I := 1 to 3 do
              case Sz of
                0..8:
                  begin
                    DiagLine(clBtnShadow);
                    DiagLine(clBtnHighlight);
                  end;
                9..11:
                  begin
                    DiagLine(clBtnFace);
                    DiagLine(clBtnShadow);
                    DiagLine(clBtnHighlight);
                  end;
                12..14:
                  begin
                    DiagLine(clBtnShadow);
                    DiagLine(clBtnShadow);
                    DiagLine(clBtnHighlight);
                  end;
              else
                DiagLine(clBtnFace);
                DiagLine(clBtnShadow);
                DiagLine(clBtnShadow);
                DiagLine(clBtnHighlight);
              end;

            with Canvas, R do
            begin
              Pen.Color := clBtnFace;
              MoveTo(Right - D - 1, Bottom - 1);
              LineTo(Right - 1, Bottom - 1);
              LineTo(Right - 1, Bottom - D - 2);
            end;
          end;
        end;
    end;
end;

procedure TTBXNewOfficeXPTheme.TBXSysCommand(var Message: TMessage);
begin
  if Message.WParam = TSC_VIEWCHANGE then SetupColorCache;
end;

initialization
  RegisterTBXTheme('NewOfficeXP', TTBXNewOfficeXPTheme);

end.
