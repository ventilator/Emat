unit UVis;

{ Visualization window powered by libprojectM v4 (OpenGL 3.3 Core via
  TOpenGLControl). Reads existing Milkdrop .milk presets directly on x64
  Windows without 32-bit Winamp plugins. }

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, Graphics, Menus, Windows,
  IniFiles, OpenGLContext, ProjectM;

type
  TVisGetPCMEvent = function(Buffer: PSingle; FrameCount: Integer): Integer of object;
  TVisLogEvent = procedure(Msg: string) of object;

  TVisForm = class(TForm)
  private
    FGL: TOpenGLControl;
    FTimer: TTimer;
    FPopup: TPopupMenu;
    FMILock: TMenuItem;
    FMIFullscreen: TMenuItem;
    FPM: TProjectMHandle;
    FPresets: TStringList;
    FCurrentPreset: Integer;
    FLocked: Boolean;
    FPendingSwitch: Boolean;
    FPendingHardCut: Boolean;
    FGLReady: Boolean;
    FBaseDir: string;
    FIniPath: string;
    FIsFullscreen: Boolean;
    FSavedBounds: TRect;
    FSavedStyle: TFormBorderStyle;
    FPCMBuffer: array[0..1023] of Single; // 512 stereo frames
    FOnGetPCM: TVisGetPCMEvent;
    FOnLog: TVisLogEvent;
    procedure LogMsg(const Msg: string);
    procedure ScanPresetsInDir(const Dir: string);
    procedure LoadPresetList;
    procedure InitProjectM;
    procedure ShutdownProjectM;
    procedure LoadPresetByIndex(Idx: Integer; Smooth: Boolean);
    procedure UpdateCaption;
    procedure LoadGeometry;
    procedure SaveGeometry;
    procedure DoTimer(Sender: TObject);
    procedure DoGLResize(Sender: TObject);
    procedure DoGLPaint(Sender: TObject);
    procedure DoGLDblClick(Sender: TObject);
    procedure DoFormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoFormShow(Sender: TObject);
    procedure DoFormHide(Sender: TObject);
    procedure DoFormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure DoMenuNext(Sender: TObject);
    procedure DoMenuPrev(Sender: TObject);
    procedure DoMenuRandom(Sender: TObject);
    procedure DoMenuLock(Sender: TObject);
    procedure DoMenuFullscreen(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure NextPreset(Smooth: Boolean = True);
    procedure PrevPreset(Smooth: Boolean = True);
    procedure RandomPreset(Smooth: Boolean = True);
    procedure ToggleLock;
    procedure ToggleFullscreen;
    property OnGetPCM: TVisGetPCMEvent read FOnGetPCM write FOnGetPCM;
    property OnLog: TVisLogEvent read FOnLog write FOnLog;
  end;

implementation

procedure OnProjectMSwitchRequested(is_hard_cut: ByteBool; user_data: Pointer); cdecl;
var
  Form: TVisForm;
begin
  if user_data = nil then Exit;
  Form := TVisForm(user_data);
  Form.FPendingSwitch := True;
  Form.FPendingHardCut := is_hard_cut;
end;

procedure OnProjectMSwitchFailed(const preset_filename, message: PAnsiChar; user_data: Pointer); cdecl;
var
  Form: TVisForm;
begin
  if user_data = nil then Exit;
  Form := TVisForm(user_data);
  Form.LogMsg('projectM preset failed: ' + string(preset_filename) + ' (' + string(message) + ')');
end;

constructor TVisForm.Create(AOwner: TComponent);
var
  MI: TMenuItem;
begin
  inherited CreateNew(AOwner);

  FBaseDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  FIniPath := FBaseDir + 'custom\Emat.ini';
  FPresets := TStringList.Create;
  FCurrentPreset := -1;

  Caption      := 'Emat - Visualisierung (projectM)';
  BorderStyle  := bsSizeable;
  BorderIcons  := [biSystemMenu, biMinimize, biMaximize];
  Position     := poDesigned;
  SetBounds(160, 160, 800, 600);
  Color        := clBlack;
  KeyPreview   := True;
  OnKeyDown    := DoFormKeyDown;
  OnShow       := DoFormShow;
  OnHide       := DoFormHide;
  OnClose      := DoFormClose;

  FPopup := TPopupMenu.Create(Self);
  MI := TMenuItem.Create(FPopup);
  MI.Caption := 'Nächstes Preset (Rechts / N)';
  MI.OnClick := DoMenuNext;
  FPopup.Items.Add(MI);

  MI := TMenuItem.Create(FPopup);
  MI.Caption := 'Vorheriges Preset (Links / P)';
  MI.OnClick := DoMenuPrev;
  FPopup.Items.Add(MI);

  MI := TMenuItem.Create(FPopup);
  MI.Caption := 'Zufälliges Preset (R)';
  MI.OnClick := DoMenuRandom;
  FPopup.Items.Add(MI);

  FMILock := TMenuItem.Create(FPopup);
  FMILock.Caption := 'Preset sperren (L)';
  FMILock.OnClick := DoMenuLock;
  FPopup.Items.Add(FMILock);

  MI := TMenuItem.Create(FPopup);
  MI.Caption := '-';
  FPopup.Items.Add(MI);

  FMIFullscreen := TMenuItem.Create(FPopup);
  FMIFullscreen.Caption := 'Vollbild (F11 / Doppelklick)';
  FMIFullscreen.OnClick := DoMenuFullscreen;
  FPopup.Items.Add(FMIFullscreen);

  FGL := TOpenGLControl.Create(Self);
  FGL.Parent := Self;
  FGL.Align := alClient;
  FGL.OpenGLMajorVersion := 3;
  FGL.OpenGLMinorVersion := 3;
  FGL.RGBA := True;
  FGL.DepthBits := 0;
  FGL.MultiSampling := 0;
  FGL.AutoResizeViewport := False;
  FGL.PopupMenu := FPopup;
  FGL.OnResize := DoGLResize;
  FGL.OnPaint := DoGLPaint;
  FGL.OnDblClick := DoGLDblClick;

  FTimer := TTimer.Create(Self);
  FTimer.Interval := 16; // ~60 FPS
  FTimer.Enabled := False;
  FTimer.OnTimer := DoTimer;

  LoadGeometry;
end;

destructor TVisForm.Destroy;
begin
  SaveGeometry;
  ShutdownProjectM;
  FreeAndNil(FPresets);
  inherited Destroy;
end;

procedure TVisForm.LogMsg(const Msg: string);
begin
  if Assigned(FOnLog) then
    FOnLog(Msg);
end;

procedure TVisForm.ScanPresetsInDir(const Dir: string);
var
  SR: TSearchRec;
  Path: string;
begin
  if not DirectoryExists(Dir) then Exit;
  Path := IncludeTrailingPathDelimiter(Dir);
  if FindFirst(Path + '*', faAnyFile, SR) = 0 then
  try
    repeat
      if (SR.Name = '.') or (SR.Name = '..') then Continue;
      if (SR.Attr and faDirectory) <> 0 then
        ScanPresetsInDir(Path + SR.Name)
      else if SameText(ExtractFileExt(SR.Name), '.milk') then
        FPresets.Add(Path + SR.Name);
    until FindNext(SR) <> 0;
  finally
    SysUtils.FindClose(SR);
  end;
end;

procedure TVisForm.LoadPresetList;
begin
  FPresets.Clear;
  ScanPresetsInDir(FBaseDir + 'Plugins\Milkdrop2.2\Milkdrop2\presets');
  ScanPresetsInDir(FBaseDir + 'Plugins\Milkdrop2.2\presets');
  ScanPresetsInDir(FBaseDir + 'Plugins\Milkdrop2\presets');
  FPresets.Sort;
  LogMsg(Format('projectM: %d Presets gefunden', [FPresets.Count]));
end;

procedure TVisForm.InitProjectM;
var
  TexDirs: array of AnsiString;
  TexPtrs: array of PAnsiChar;
  Candidate: string;
  i: Integer;
begin
  if FPM <> nil then Exit;
  try
    if FPresets.Count = 0 then
      LoadPresetList;

    if not LoadProjectMLibrary(FBaseDir) then
    begin
      LogMsg('projectM: ' + ProjectMLastError);
      Exit;
    end;

    if not FGL.MakeCurrent then
    begin
      LogMsg('projectM: OpenGL-Kontext konnte nicht aktiviert werden');
      Exit;
    end;

    LogMsg('projectM: glewInit=' + IntToStr(InitProjectMGlew(FBaseDir)));

    FPM := projectm_create();
    if FPM = nil then
    begin
      LogMsg('projectM: projectm_create() lieferte nil (OpenGL 3.3 Core erforderlich)');
      Exit;
    end;

    FGLReady := True;
    projectm_set_window_size(FPM, PtrUInt(FGL.ClientWidth), PtrUInt(FGL.ClientHeight));
    if @projectm_set_fps <> nil then
      projectm_set_fps(FPM, 60);
    if @projectm_set_preset_duration <> nil then
      projectm_set_preset_duration(FPM, 25.0);
    if @projectm_set_soft_cut_duration <> nil then
      projectm_set_soft_cut_duration(FPM, 3.0);
    if @projectm_set_aspect_correction <> nil then
      projectm_set_aspect_correction(FPM, True);

    // Register texture directories if present
    SetLength(TexDirs, 0);
    for i := 0 to 2 do
    begin
      case i of
        0: Candidate := FBaseDir + 'Plugins\Milkdrop2.2\Milkdrop2\textures';
        1: Candidate := FBaseDir + 'Plugins\Milkdrop2\textures';
        2: Candidate := FBaseDir + 'Plugins\Milkdrop2\data';
      end;
      if DirectoryExists(Candidate) then
      begin
        SetLength(TexDirs, Length(TexDirs) + 1);
        TexDirs[High(TexDirs)] := AnsiString(Candidate);
      end;
    end;
    if (Length(TexDirs) > 0) and (@projectm_set_texture_search_paths <> nil) then
    begin
      SetLength(TexPtrs, Length(TexDirs));
      for i := 0 to High(TexDirs) do
        TexPtrs[i] := PAnsiChar(TexDirs[i]);
      projectm_set_texture_search_paths(FPM, @TexPtrs[0], PtrUInt(Length(TexPtrs)));
    end;

    if @projectm_set_preset_switch_requested_event_callback <> nil then
      projectm_set_preset_switch_requested_event_callback(FPM, @OnProjectMSwitchRequested, Self);
    if @projectm_set_preset_switch_failed_event_callback <> nil then
      projectm_set_preset_switch_failed_event_callback(FPM, @OnProjectMSwitchFailed, Self);

    LogMsg('projectM: initialisiert (' + IntToStr(FGL.ClientWidth) + 'x' + IntToStr(FGL.ClientHeight) + ')');

    if FPresets.Count > 0 then
      RandomPreset(False)
    else
      UpdateCaption;
  except
    on E: Exception do
      LogMsg('projectM Init Exception: ' + E.ClassName + ': ' + E.Message);
  end;
end;

procedure TVisForm.ShutdownProjectM;
begin
  if FTimer <> nil then
    FTimer.Enabled := False;
  if FPM <> nil then
  begin
    if (FGL <> nil) and FGL.HandleAllocated then
      FGL.MakeCurrent;
    projectm_destroy(FPM);
    FPM := nil;
  end;
  FGLReady := False;
end;

procedure TVisForm.LoadPresetByIndex(Idx: Integer; Smooth: Boolean);
var
  PresetPath: AnsiString;
begin
  if (FPM = nil) or (FPresets.Count = 0) then Exit;
  if Idx < 0 then Idx := FPresets.Count - 1;
  if Idx >= FPresets.Count then Idx := 0;
  FCurrentPreset := Idx;
  PresetPath := AnsiString(FPresets[FCurrentPreset]);
  if FGL.MakeCurrent then
    projectm_load_preset_file(FPM, PAnsiChar(PresetPath), Smooth);
  UpdateCaption;
end;

procedure TVisForm.NextPreset(Smooth: Boolean);
begin
  if FPresets.Count = 0 then Exit;
  LoadPresetByIndex(FCurrentPreset + 1, Smooth);
end;

procedure TVisForm.PrevPreset(Smooth: Boolean);
begin
  if FPresets.Count = 0 then Exit;
  LoadPresetByIndex(FCurrentPreset - 1, Smooth);
end;

procedure TVisForm.RandomPreset(Smooth: Boolean);
var
  Idx: Integer;
begin
  if FPresets.Count = 0 then Exit;
  if FPresets.Count = 1 then
    Idx := 0
  else
  begin
    repeat
      Idx := Random(FPresets.Count);
    until Idx <> FCurrentPreset;
  end;
  LoadPresetByIndex(Idx, Smooth);
end;

procedure TVisForm.ToggleLock;
begin
  FLocked := not FLocked;
  if (FPM <> nil) and (@projectm_set_preset_locked <> nil) then
    projectm_set_preset_locked(FPM, FLocked);
  if FMILock <> nil then
    FMILock.Checked := FLocked;
  UpdateCaption;
end;

procedure TVisForm.ToggleFullscreen;
var
  Mon: TMonitor;
begin
  if not FIsFullscreen then
  begin
    FSavedBounds := BoundsRect;
    FSavedStyle := BorderStyle;
    Mon := Monitor;
    BorderStyle := bsNone;
    BoundsRect := Mon.BoundsRect;
    FIsFullscreen := True;
  end
  else
  begin
    BorderStyle := FSavedStyle;
    BoundsRect := FSavedBounds;
    FIsFullscreen := False;
  end;
  if FMIFullscreen <> nil then
    FMIFullscreen.Checked := FIsFullscreen;
end;

procedure TVisForm.UpdateCaption;
var
  NamePart, LockPart: string;
begin
  if (FCurrentPreset >= 0) and (FCurrentPreset < FPresets.Count) then
    NamePart := ChangeFileExt(ExtractFileName(FPresets[FCurrentPreset]), '')
  else
    NamePart := 'Idle';
  if FLocked then
    LockPart := ' [Gesperrt]'
  else
    LockPart := '';
  Caption := 'Emat - projectM: ' + NamePart + LockPart;
end;

procedure TVisForm.LoadGeometry;
var
  Ini: TIniFile;
  L, T, W, H: Integer;
begin
  if not FileExists(FIniPath) then Exit;
  try
    Ini := TIniFile.Create(FIniPath);
    try
      W := Ini.ReadInteger('VisWindow', 'Width', 800);
      H := Ini.ReadInteger('VisWindow', 'Height', 600);
      L := Ini.ReadInteger('VisWindow', 'Left', 160);
      T := Ini.ReadInteger('VisWindow', 'Top', 160);
      if W < 200 then W := 800;
      if H < 150 then H := 600;
      SetBounds(L, T, W, H);
    finally
      Ini.Free;
    end;
  except
  end;
end;

procedure TVisForm.SaveGeometry;
var
  Ini: TIniFile;
  R: TRect;
begin
  if not DirectoryExists(ExtractFilePath(FIniPath)) then Exit;
  try
    if FIsFullscreen then
      R := FSavedBounds
    else
      R := BoundsRect;
    Ini := TIniFile.Create(FIniPath);
    try
      Ini.WriteInteger('VisWindow', 'Left', R.Left);
      Ini.WriteInteger('VisWindow', 'Top', R.Top);
      Ini.WriteInteger('VisWindow', 'Width', R.Right - R.Left);
      Ini.WriteInteger('VisWindow', 'Height', R.Bottom - R.Top);
    finally
      Ini.Free;
    end;
  except
  end;
end;

procedure TVisForm.DoTimer(Sender: TObject);
var
  Frames: Integer;
begin
  if not Visible then Exit;
  if FPM = nil then
  begin
    InitProjectM;
    if FPM = nil then
    begin
      FTimer.Enabled := False;
      Exit;
    end;
  end;

  if FPendingSwitch then
  begin
    FPendingSwitch := False;
    if not FLocked then
      RandomPreset(not FPendingHardCut);
  end;

  if not FGL.MakeCurrent then Exit;

  if Assigned(FOnGetPCM) then
  begin
    Frames := FOnGetPCM(@FPCMBuffer[0], 512);
    if Frames > 0 then
      projectm_pcm_add_float(FPM, @FPCMBuffer[0], Cardinal(Frames), PROJECTM_STEREO);
  end;

  projectm_opengl_render_frame(FPM);
  FGL.SwapBuffers;
end;

procedure TVisForm.DoGLResize(Sender: TObject);
begin
  if (FPM <> nil) and (FGL.ClientWidth > 0) and (FGL.ClientHeight > 0) then
  begin
    if FGL.MakeCurrent then
      projectm_set_window_size(FPM, PtrUInt(FGL.ClientWidth), PtrUInt(FGL.ClientHeight));
  end;
end;

procedure TVisForm.DoGLPaint(Sender: TObject);
begin
  if FPM = nil then
    InitProjectM;
  if (FPM <> nil) and FGL.MakeCurrent then
  begin
    projectm_opengl_render_frame(FPM);
    FGL.SwapBuffers;
  end;
end;

procedure TVisForm.DoGLDblClick(Sender: TObject);
begin
  ToggleFullscreen;
end;

procedure TVisForm.DoFormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RIGHT, Ord('N'), VK_SPACE:
      begin NextPreset(True); Key := 0; end;
    VK_LEFT, Ord('P'), VK_BACK:
      begin PrevPreset(True); Key := 0; end;
    Ord('R'):
      begin RandomPreset(True); Key := 0; end;
    Ord('L'):
      begin ToggleLock; Key := 0; end;
    VK_F11:
      begin ToggleFullscreen; Key := 0; end;
    VK_RETURN:
      if ssAlt in Shift then
      begin ToggleFullscreen; Key := 0; end;
    VK_ESCAPE:
      if FIsFullscreen then
      begin ToggleFullscreen; Key := 0; end;
  end;
end;

procedure TVisForm.DoFormShow(Sender: TObject);
begin
  FTimer.Enabled := True;
end;

procedure TVisForm.DoFormHide(Sender: TObject);
begin
  FTimer.Enabled := False;
  SaveGeometry;
end;

procedure TVisForm.DoFormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caHide;
  FTimer.Enabled := False;
  SaveGeometry;
end;

procedure TVisForm.DoMenuNext(Sender: TObject);
begin
  NextPreset(True);
end;

procedure TVisForm.DoMenuPrev(Sender: TObject);
begin
  PrevPreset(True);
end;

procedure TVisForm.DoMenuRandom(Sender: TObject);
begin
  RandomPreset(True);
end;

procedure TVisForm.DoMenuLock(Sender: TObject);
begin
  ToggleLock;
end;

procedure TVisForm.DoMenuFullscreen(Sender: TObject);
begin
  ToggleFullscreen;
end;

end.
