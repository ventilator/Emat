unit ProjectM;

{ Dynamic Pascal bindings for libprojectM v4 C API (projectM-4.dll).
  LGPL-2.1 (libprojectM) - loaded dynamically at runtime so Emat starts
  cleanly even if projectM-4.dll is absent. }

{$mode delphi}{$H+}

interface

uses
  SysUtils, DynLibs;

const
  PROJECTM_DLL = 'projectM-4.dll';

  PROJECTM_MONO   = 1;
  PROJECTM_STEREO = 2;

type
  TProjectMHandle = Pointer;
  TProjectMPresetSwitchCallback = procedure(is_hard_cut: ByteBool; user_data: Pointer); cdecl;
  TProjectMPresetFailedCallback = procedure(const preset_filename, message: PAnsiChar; user_data: Pointer); cdecl;

  Tpm_create = function: TProjectMHandle; cdecl;
  Tpm_destroy = procedure(instance: TProjectMHandle); cdecl;
  Tpm_load_preset_file = procedure(instance: TProjectMHandle; filename: PAnsiChar; smooth_transition: ByteBool); cdecl;
  Tpm_load_preset_data = procedure(instance: TProjectMHandle; data: PAnsiChar; smooth_transition: ByteBool); cdecl;
  Tpm_set_window_size = procedure(instance: TProjectMHandle; width, height: PtrUInt); cdecl;
  Tpm_set_fps = procedure(instance: TProjectMHandle; fps: LongInt); cdecl;
  Tpm_set_preset_duration = procedure(instance: TProjectMHandle; seconds: Double); cdecl;
  Tpm_set_soft_cut_duration = procedure(instance: TProjectMHandle; seconds: Double); cdecl;
  Tpm_set_preset_locked = procedure(instance: TProjectMHandle; lock: ByteBool); cdecl;
  Tpm_get_preset_locked = function(instance: TProjectMHandle): ByteBool; cdecl;
  Tpm_set_aspect_correction = procedure(instance: TProjectMHandle; enabled: ByteBool); cdecl;
  Tpm_set_texture_search_paths = procedure(instance: TProjectMHandle; paths: PPAnsiChar; count: PtrUInt); cdecl;
  Tpm_pcm_get_max_samples = function: Cardinal; cdecl;
  Tpm_pcm_add_float = procedure(instance: TProjectMHandle; samples: PSingle; count: Cardinal; channels: LongInt); cdecl;
  Tpm_opengl_render_frame = procedure(instance: TProjectMHandle); cdecl;
  Tpm_set_preset_switch_requested_event_callback = procedure(instance: TProjectMHandle;
    callback: TProjectMPresetSwitchCallback; user_data: Pointer); cdecl;
  Tpm_set_preset_switch_failed_event_callback = procedure(instance: TProjectMHandle;
    callback: TProjectMPresetFailedCallback; user_data: Pointer); cdecl;
  TglewInit = function: Cardinal; cdecl;

var
  projectm_create: Tpm_create = nil;
  projectm_destroy: Tpm_destroy = nil;
  projectm_load_preset_file: Tpm_load_preset_file = nil;
  projectm_load_preset_data: Tpm_load_preset_data = nil;
  projectm_set_window_size: Tpm_set_window_size = nil;
  projectm_set_fps: Tpm_set_fps = nil;
  projectm_set_preset_duration: Tpm_set_preset_duration = nil;
  projectm_set_soft_cut_duration: Tpm_set_soft_cut_duration = nil;
  projectm_set_preset_locked: Tpm_set_preset_locked = nil;
  projectm_get_preset_locked: Tpm_get_preset_locked = nil;
  projectm_set_aspect_correction: Tpm_set_aspect_correction = nil;
  projectm_set_texture_search_paths: Tpm_set_texture_search_paths = nil;
  projectm_pcm_get_max_samples: Tpm_pcm_get_max_samples = nil;
  projectm_pcm_add_float: Tpm_pcm_add_float = nil;
  projectm_opengl_render_frame: Tpm_opengl_render_frame = nil;
  projectm_set_preset_switch_requested_event_callback: Tpm_set_preset_switch_requested_event_callback = nil;
  projectm_set_preset_switch_failed_event_callback: Tpm_set_preset_switch_failed_event_callback = nil;

function LoadProjectMLibrary(const BaseDir: string = ''): Boolean;
function InitProjectMGlew(const BaseDir: string = ''): Cardinal;
procedure UnloadProjectMLibrary;
function IsProjectMLoaded: Boolean;
function ProjectMLastError: string;

implementation

var
  GLibHandle: TLibHandle = NilHandle;
  GGlewHandle: TLibHandle = NilHandle;
  GGlewInit: TglewInit = nil;
  GGlewExperimental: PByte = nil;
  GLastError: string = '';

function IsProjectMLoaded: Boolean;
begin
  Result := GLibHandle <> NilHandle;
end;

function ProjectMLastError: string;
begin
  Result := GLastError;
end;

function LoadProjectMLibrary(const BaseDir: string): Boolean;
var
  DllPath: string;
begin
  if GLibHandle <> NilHandle then
    Exit(True);

  GLastError := '';
  if (BaseDir <> '') and FileExists(IncludeTrailingPathDelimiter(BaseDir) + PROJECTM_DLL) then
    DllPath := IncludeTrailingPathDelimiter(BaseDir) + PROJECTM_DLL
  else
    DllPath := PROJECTM_DLL;

  GLibHandle := SafeLoadLibrary(DllPath);
  if GLibHandle = NilHandle then
  begin
    GLastError := 'Konnte ' + DllPath + ' nicht laden (' + GetLoadErrorStr + ')';
    Exit(False);
  end;

  projectm_create := Tpm_create(GetProcedureAddress(GLibHandle, 'projectm_create'));
  projectm_destroy := Tpm_destroy(GetProcedureAddress(GLibHandle, 'projectm_destroy'));
  projectm_load_preset_file := Tpm_load_preset_file(GetProcedureAddress(GLibHandle, 'projectm_load_preset_file'));
  projectm_load_preset_data := Tpm_load_preset_data(GetProcedureAddress(GLibHandle, 'projectm_load_preset_data'));
  projectm_set_window_size := Tpm_set_window_size(GetProcedureAddress(GLibHandle, 'projectm_set_window_size'));
  projectm_set_fps := Tpm_set_fps(GetProcedureAddress(GLibHandle, 'projectm_set_fps'));
  projectm_set_preset_duration := Tpm_set_preset_duration(GetProcedureAddress(GLibHandle, 'projectm_set_preset_duration'));
  projectm_set_soft_cut_duration := Tpm_set_soft_cut_duration(GetProcedureAddress(GLibHandle, 'projectm_set_soft_cut_duration'));
  projectm_set_preset_locked := Tpm_set_preset_locked(GetProcedureAddress(GLibHandle, 'projectm_set_preset_locked'));
  projectm_get_preset_locked := Tpm_get_preset_locked(GetProcedureAddress(GLibHandle, 'projectm_get_preset_locked'));
  projectm_set_aspect_correction := Tpm_set_aspect_correction(GetProcedureAddress(GLibHandle, 'projectm_set_aspect_correction'));
  projectm_set_texture_search_paths := Tpm_set_texture_search_paths(GetProcedureAddress(GLibHandle, 'projectm_set_texture_search_paths'));
  projectm_pcm_get_max_samples := Tpm_pcm_get_max_samples(GetProcedureAddress(GLibHandle, 'projectm_pcm_get_max_samples'));
  projectm_pcm_add_float := Tpm_pcm_add_float(GetProcedureAddress(GLibHandle, 'projectm_pcm_add_float'));
  projectm_opengl_render_frame := Tpm_opengl_render_frame(GetProcedureAddress(GLibHandle, 'projectm_opengl_render_frame'));
  projectm_set_preset_switch_requested_event_callback :=
    Tpm_set_preset_switch_requested_event_callback(GetProcedureAddress(GLibHandle, 'projectm_set_preset_switch_requested_event_callback'));
  projectm_set_preset_switch_failed_event_callback :=
    Tpm_set_preset_switch_failed_event_callback(GetProcedureAddress(GLibHandle, 'projectm_set_preset_switch_failed_event_callback'));

  if (@projectm_create = nil) or (@projectm_destroy = nil) or
     (@projectm_opengl_render_frame = nil) or (@projectm_pcm_add_float = nil) or
     (@projectm_load_preset_file = nil) or (@projectm_set_window_size = nil) then
  begin
    GLastError := 'projectM-4.dll fehlen erwartete C-API-Exporte';
    UnloadProjectMLibrary;
    Exit(False);
  end;

  Result := True;
end;

function InitProjectMGlew(const BaseDir: string): Cardinal;
var
  DllPath: string;
begin
  Result := $FFFFFFFF;
  if GGlewHandle = NilHandle then
  begin
    if (BaseDir <> '') and FileExists(IncludeTrailingPathDelimiter(BaseDir) + 'glew32.dll') then
      DllPath := IncludeTrailingPathDelimiter(BaseDir) + 'glew32.dll'
    else
      DllPath := 'glew32.dll';
    GGlewHandle := SafeLoadLibrary(DllPath);
    if GGlewHandle = NilHandle then
      Exit;
    GGlewInit := TglewInit(GetProcedureAddress(GGlewHandle, 'glewInit'));
    GGlewExperimental := PByte(GetProcedureAddress(GGlewHandle, 'glewExperimental'));
  end;
  if GGlewExperimental <> nil then
    GGlewExperimental^ := 1;
  if @GGlewInit <> nil then
    Result := GGlewInit();
end;

procedure UnloadProjectMLibrary;
begin
  if GLibHandle <> NilHandle then
  begin
    UnloadLibrary(GLibHandle);
    GLibHandle := NilHandle;
  end;
  if GGlewHandle <> NilHandle then
  begin
    UnloadLibrary(GGlewHandle);
    GGlewHandle := NilHandle;
  end;
  GGlewInit := nil;
  GGlewExperimental := nil;
  projectm_create := nil;
  projectm_destroy := nil;
  projectm_load_preset_file := nil;
  projectm_load_preset_data := nil;
  projectm_set_window_size := nil;
  projectm_set_fps := nil;
  projectm_set_preset_duration := nil;
  projectm_set_soft_cut_duration := nil;
  projectm_set_preset_locked := nil;
  projectm_get_preset_locked := nil;
  projectm_set_aspect_correction := nil;
  projectm_set_texture_search_paths := nil;
  projectm_pcm_get_max_samples := nil;
  projectm_pcm_add_float := nil;
  projectm_opengl_render_frame := nil;
  projectm_set_preset_switch_requested_event_callback := nil;
  projectm_set_preset_switch_failed_event_callback := nil;
end;

finalization
  UnloadProjectMLibrary;

end.
