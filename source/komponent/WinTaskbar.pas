unit WinTaskbar;

{ Windows 7+ / Windows 11 Taskbar Thumbnail Media Controls via COM ITaskbarList3.
  Provides Prev / Play-Pause / Next buttons on the taskbar hover preview. }

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Windows, ActiveX, Graphics;

const
  THBN_CLICKED = $1800;

  TBTN_ID_PREV = 40001;
  TBTN_ID_PLAY = 40002;
  TBTN_ID_NEXT = 40003;

type
  TWinTaskbarMedia = class
  private
    FTaskbar: IUnknown;
    FTargetWnd: HWND;
    FButtonsAdded: Boolean;
    FPlaying: Boolean;
    FIconPrev: HICON;
    FIconPlay: HICON;
    FIconPause: HICON;
    FIconNext: HICON;
    FTaskbarCreatedMsg: UINT;
    function CreateGlyphIcon(Kind: Integer): HICON;
    procedure FreeIcons;
  public
    constructor Create(ATargetWnd: HWND);
    destructor Destroy; override;
    procedure InitButtons;
    procedure SetPlaying(APlaying: Boolean);
    property TaskbarCreatedMsg: UINT read FTaskbarCreatedMsg;
  end;

implementation

const
  CLSID_TaskbarList: TGUID = '{56FDF344-FD6D-11D0-958A-006097C9A090}';
  IID_ITaskbarList3: TGUID = '{EA1AFB91-9E28-4B86-90E9-9E9F8A5EEFAF}';

  THB_BITMAP  = $00000001;
  THB_ICON    = $00000002;
  THB_TOOLTIP = $00000004;
  THB_FLAGS   = $00000008;

  THBF_ENABLED = $00000000;

type
  // Must match Win32 THUMBBUTTON layout (packing = 8 bytes on Win64/Win32)
  {$PACKRECORDS 8}
  TThumbButton = record
    dwMask: DWORD;
    iId: UINT;
    iBitmap: UINT;
    hIcon: HICON;
    szTip: array[0..259] of WideChar;
    dwFlags: DWORD;
  end;
  PThumbButton = ^TThumbButton;

  ITaskbarList3 = interface(IUnknown)
    ['{EA1AFB91-9E28-4B86-90E9-9E9F8A5EEFAF}']
    // ITaskbarList
    function HrInit: HRESULT; stdcall;
    function AddTab(hwnd: HWND): HRESULT; stdcall;
    function DeleteTab(hwnd: HWND): HRESULT; stdcall;
    function ActivateTab(hwnd: HWND): HRESULT; stdcall;
    function SetActiveAlt(hwnd: HWND): HRESULT; stdcall;
    // ITaskbarList2
    function MarkFullscreenWindow(hwnd: HWND; fFullscreen: BOOL): HRESULT; stdcall;
    // ITaskbarList3
    function SetProgressValue(hwnd: HWND; ullCompleted, ullTotal: UInt64): HRESULT; stdcall;
    function SetProgressState(hwnd: HWND; tbpFlags: DWORD): HRESULT; stdcall;
    function RegisterTab(hwndTab, hwndMDI: HWND): HRESULT; stdcall;
    function UnregisterTab(hwndTab: HWND): HRESULT; stdcall;
    function SetTabOrder(hwndTab, hwndInsertBefore: HWND): HRESULT; stdcall;
    function SetTabActive(hwndTab, hwndMDI: HWND; dwReserved: DWORD): HRESULT; stdcall;
    function ThumbBarAddButtons(hwnd: HWND; cButtons: UINT; pButton: PThumbButton): HRESULT; stdcall;
    function ThumbBarUpdateButtons(hwnd: HWND; cButtons: UINT; pButton: PThumbButton): HRESULT; stdcall;
    function ThumbBarSetImageList(hwnd: HWND; himl: THandle): HRESULT; stdcall;
    function SetOverlayIcon(hwnd: HWND; hIcon: HICON; pszDescription: PWideChar): HRESULT; stdcall;
    function SetThumbnailTooltip(hwnd: HWND; pszTip: PWideChar): HRESULT; stdcall;
    function SetThumbnailClip(hwnd: HWND; prcClip: PRect): HRESULT; stdcall;
  end;

function TWinTaskbarMedia.CreateGlyphIcon(Kind: Integer): HICON;
{ Kind: 0=Prev, 1=Play, 2=Pause, 3=Next }
var
  ColorBmp, MaskBmp: TBitmap;
  II: TIconInfo;
  Pts: array[0..2] of TPoint;
begin
  ColorBmp := TBitmap.Create;
  MaskBmp := TBitmap.Create;
  try
    ColorBmp.PixelFormat := pf32bit;
    ColorBmp.SetSize(16, 16);
    ColorBmp.Canvas.Brush.Color := clBlack;
    ColorBmp.Canvas.FillRect(0, 0, 16, 16);
    ColorBmp.Canvas.Brush.Color := clWhite;
    ColorBmp.Canvas.Pen.Color := clWhite;

    MaskBmp.Monochrome := True;
    MaskBmp.SetSize(16, 16);
    MaskBmp.Canvas.Brush.Color := clWhite; // 1 = transparent
    MaskBmp.Canvas.FillRect(0, 0, 16, 16);
    MaskBmp.Canvas.Brush.Color := clBlack; // 0 = opaque
    MaskBmp.Canvas.Pen.Color := clBlack;

    case Kind of
      0: begin // Prev: |<
        ColorBmp.Canvas.FillRect(2, 3, 5, 13);
        MaskBmp.Canvas.FillRect(2, 3, 5, 13);
        Pts[0] := Classes.Point(13, 3); Pts[1] := Classes.Point(5, 8); Pts[2] := Classes.Point(13, 13);
        ColorBmp.Canvas.Polygon(Pts);
        MaskBmp.Canvas.Polygon(Pts);
      end;
      1: begin // Play: >
        Pts[0] := Classes.Point(4, 2); Pts[1] := Classes.Point(13, 8); Pts[2] := Classes.Point(4, 14);
        ColorBmp.Canvas.Polygon(Pts);
        MaskBmp.Canvas.Polygon(Pts);
      end;
      2: begin // Pause: ||
        ColorBmp.Canvas.FillRect(3, 3, 7, 13);
        ColorBmp.Canvas.FillRect(9, 3, 13, 13);
        MaskBmp.Canvas.FillRect(3, 3, 7, 13);
        MaskBmp.Canvas.FillRect(9, 3, 13, 13);
      end;
      3: begin // Next: >|
        Pts[0] := Classes.Point(3, 3); Pts[1] := Classes.Point(11, 8); Pts[2] := Classes.Point(3, 13);
        ColorBmp.Canvas.Polygon(Pts);
        MaskBmp.Canvas.Polygon(Pts);
        ColorBmp.Canvas.FillRect(11, 3, 14, 13);
        MaskBmp.Canvas.FillRect(11, 3, 14, 13);
      end;
    end;

    FillChar(II, SizeOf(II), 0);
    II.fIcon := True;
    II.hbmColor := ColorBmp.Handle;
    II.hbmMask := MaskBmp.Handle;
    Result := CreateIconIndirect(II);
  finally
    MaskBmp.Free;
    ColorBmp.Free;
  end;
end;

procedure TWinTaskbarMedia.FreeIcons;
begin
  if FIconPrev <> 0 then begin DestroyIcon(FIconPrev); FIconPrev := 0; end;
  if FIconPlay <> 0 then begin DestroyIcon(FIconPlay); FIconPlay := 0; end;
  if FIconPause <> 0 then begin DestroyIcon(FIconPause); FIconPause := 0; end;
  if FIconNext <> 0 then begin DestroyIcon(FIconNext); FIconNext := 0; end;
end;

constructor TWinTaskbarMedia.Create(ATargetWnd: HWND);
var
  TB: ITaskbarList3;
begin
  inherited Create;
  FTargetWnd := ATargetWnd;
  FTaskbarCreatedMsg := RegisterWindowMessage('TaskbarButtonCreated');
  FIconPrev := CreateGlyphIcon(0);
  FIconPlay := CreateGlyphIcon(1);
  FIconPause := CreateGlyphIcon(2);
  FIconNext := CreateGlyphIcon(3);

  CoInitialize(nil);
  if Succeeded(CoCreateInstance(CLSID_TaskbarList, nil, CLSCTX_INPROC_SERVER,
       IID_ITaskbarList3, TB)) then
  begin
    if Succeeded(TB.HrInit) then
      FTaskbar := TB;
  end;
end;

destructor TWinTaskbarMedia.Destroy;
begin
  FTaskbar := nil;
  FreeIcons;
  inherited Destroy;
end;

procedure TWinTaskbarMedia.InitButtons;
var
  TB: ITaskbarList3;
  Btns: array[0..2] of TThumbButton;
begin
  if (FTaskbar = nil) or (FTargetWnd = 0) then Exit;
  if not Supports(FTaskbar, IID_ITaskbarList3, TB) then Exit;

  FillChar(Btns, SizeOf(Btns), 0);

  Btns[0].dwMask := THB_ICON or THB_TOOLTIP or THB_FLAGS;
  Btns[0].iId := TBTN_ID_PREV;
  Btns[0].hIcon := FIconPrev;
  StringToWideChar('Zurück', Btns[0].szTip, 260);
  Btns[0].dwFlags := THBF_ENABLED;

  Btns[1].dwMask := THB_ICON or THB_TOOLTIP or THB_FLAGS;
  Btns[1].iId := TBTN_ID_PLAY;
  if FPlaying then
  begin
    Btns[1].hIcon := FIconPause;
    StringToWideChar('Pause', Btns[1].szTip, 260);
  end
  else
  begin
    Btns[1].hIcon := FIconPlay;
    StringToWideChar('Wiedergabe', Btns[1].szTip, 260);
  end;
  Btns[1].dwFlags := THBF_ENABLED;

  Btns[2].dwMask := THB_ICON or THB_TOOLTIP or THB_FLAGS;
  Btns[2].iId := TBTN_ID_NEXT;
  Btns[2].hIcon := FIconNext;
  StringToWideChar('Nächster Titel', Btns[2].szTip, 260);
  Btns[2].dwFlags := THBF_ENABLED;

  if not FButtonsAdded then
  begin
    if Succeeded(TB.ThumbBarAddButtons(FTargetWnd, 3, @Btns[0])) then
      FButtonsAdded := True;
  end
  else
    TB.ThumbBarUpdateButtons(FTargetWnd, 3, @Btns[0]);
end;

procedure TWinTaskbarMedia.SetPlaying(APlaying: Boolean);
var
  TB: ITaskbarList3;
  Btn: TThumbButton;
begin
  if FPlaying = APlaying then Exit;
  FPlaying := APlaying;
  if (not FButtonsAdded) or (FTaskbar = nil) or (FTargetWnd = 0) then Exit;
  if not Supports(FTaskbar, IID_ITaskbarList3, TB) then Exit;

  FillChar(Btn, SizeOf(Btn), 0);
  Btn.dwMask := THB_ICON or THB_TOOLTIP or THB_FLAGS;
  Btn.iId := TBTN_ID_PLAY;
  Btn.dwFlags := THBF_ENABLED;
  if FPlaying then
  begin
    Btn.hIcon := FIconPause;
    StringToWideChar('Pause', Btn.szTip, 260);
  end
  else
  begin
    Btn.hIcon := FIconPlay;
    StringToWideChar('Wiedergabe', Btn.szTip, 260);
  end;
  TB.ThumbBarUpdateButtons(FTargetWnd, 1, @Btn);
end;

end.
