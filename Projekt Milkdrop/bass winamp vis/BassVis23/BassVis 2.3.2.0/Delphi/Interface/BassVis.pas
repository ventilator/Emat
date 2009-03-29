{' UNIT BassVis.pas
'--------------------------- BassVis API Module -----------------------------
' BassVis ADD-ON for Bass Audio Library
' Copyright © 2006-2007 BrewIdeas@Emil Weiss, All Rights Reserved
'
' Author(s) of this Unit: Emil Weiss
'
' Code was written in and formatted for 10pt Courier New
'----------------------------------------------------------------------------}

unit BassVis;

interface

uses
  Windows;

type
  HVIS = DWORD;
  QWORD = Int64;

const

  dllfile = 'bass_vis.dll';                  //filename of the DLL
  
  // BASS_SONIQUEVIS_CreateVis flags
  BASS_VIS_NOINIT = 1;

  // BASS_SONIQUEVIS_SetConfig flags
  BASS_SONIQUEVIS_CONFIG_FFTAMP         = 1;
  BASS_SONIQUEVIS_CONFIG_FFT_SKIPCOUNT  = 2; // Skip count range is from 0 to 3 (because of limited FFT request size)
  BASS_SONIQUEVIS_CONFIG_WAVE_SKIPCOUNT = 3; // Skip count range is from 0 to (...) try it out, whenever Bass crashes or does not return enough sample data
  BASS_SONIQUEVIS_CONFIG_SLOWFADE       = 4; // Dim light colors to less than half, then slowly fade them out

  // BASS_WINAMP_SetConfig flags
  BASS_WINAMPVIS_CONFIG_FFTAMP = 1;

  // BASS_VIS_FindPlugin flags
  BASS_VIS_FIND_SONIQUE   = 1;
  BASS_VIS_FIND_WINAMP    = 2;
  BASS_VIS_FIND_RECURSIVE = 4;

  //Plugin arten
  BASSVISKIND_NONE    = 0; // keins aktiv
  BASSVISKIND_WINAMP  = 1; // Winamp
  BASSVISKIND_SONIQUE = 2; // Sonique

type
  TBASSVIS_KIND_T = integer;

  PBASSVIS_PARAM = ^TBASSVIS_PARAM;
  TBASSVIS_PARAM = record
    VisHandle        : HVIS;            // VisHandle
    VisWinHandle     : DWORD;           // Vis Window Handle         W2
    VisGenWinHandle  : DWORD;           // General Vis Window Handle W5
    Kind             : TBASSVIS_KIND_T; // Aktive Plugin Art
  end;

  //Definition der Records für die variablen Parameter bei Create bzw. Execute
  PBASSVIS_EXEC = ^TBASSVIS_EXEC;
  TBASSVIS_EXEC = record
    AMP_SON_Pluginfile : PChar;    // Dateiname des Plugins für Sonique und Winamp
    AMP_UseOwnW1       : DWORD;    // Flag für Winamp (ownHDC)
    AMP_UseOwnW2       : DWORD;    // Flag für Winamp (ownHDCW2)
    AMP_Moduleindex    : DWORD;    // Modul-index für Winamp
    SON_PaintHandle    : THandle;  // Painthandle für Sonique    
    SON_ConfigFile     : PChar;    // Dateiname der Konfiguration für Sonique
    SON_Flags          : DWORD;    // Flags für Sonique
    Width, Height      : integer;  // Fensterhöhe und Breite
    Left, Top          : integer;  // Left und Top;
  end;

  PBASSVIS_INFO = ^TBASSVIS_INFO;
  TBASSVIS_INFO = record
    SongTitle   : PChar;   // Titel mit vorstehener TitelNr ('1. ')
    Songfile    : PChar;   // SongTitel incl. Pfad
    pos         : DWORD;   // 1000 * Aktuelle Position im Stream
    len         : DWORD;   // Stream länge
    PlaylistPos : DWORD;   // Playlist Position
    Playlistlen : DWORD;   // Playlist einträge
    SampleRate  : integer; // SämpleRate
    BitRate     : integer; // BitRate
    Duration    : DWORD;   // abgelaufen Zeit
    Channels    : integer; // Kanäle default 2 (stereo)

  end;

  TPlayState    = (psError = -1, psStop = 0, psPlay = 1,
                   psIsPlaying = 2, psPause= 3,
                   psGetPlaylistPos = 4, psSetPlaylistPos = 5);


TBASSVIS_STATECALLBACK = procedure(NewState:TPlayState); stdcall;

//Core functions for initalizing BASSVIS and Find Plugins of any kind
function BASSVIS_Init(Kind: TBASSVIS_KIND_T;
    AppHandle: HWND;
    WinHandle: HWND): BOOL; stdcall; external dllfile;


function BASSVIS_FindPlugins(Kind: TBASSVIS_KIND_T;
    PluginPath: PChar;
    Searchflags: DWORD;
    delimiter : char = ','
): PChar; stdcall; external dllfile;


function BASSVIS_GetPluginHandle(Kind: TBASSVIS_KIND_T;
    Pluginfile: PChar
): PBASSVIS_PARAM; stdcall; external dllfile;


procedure BASSVIS_ExecutePlugin(Param: PBASSVIS_EXEC;
    var Base: TBASSVIS_PARAM
); stdcall; external dllfile;


function BASSVIS_RenderChannel(Param: PBASSVIS_PARAM;
    channel: DWORD
): BOOL; stdcall; external dllfile;


function BASSVIS_StartRecord(Param: PBASSVIS_PARAM;
    SampleRate: integer = 44100;
    Channels: integer = 2
): BOOL; stdcall; external dllfile;


function BASSVIS_Config(Param: PBASSVIS_PARAM;
    Entry: integer = -1
): BOOL; stdcall; external dllfile;


function BASSVIS_SetInfo(Param: PBASSVIS_PARAM;
    Infos: PBASSVIS_INFO
): BOOL; stdcall; external dllfile;


function BASSVIS_Resize(Param: PBASSVIS_PARAM;
    Left,Top,Width,
    Height: DWORD
): BOOL; stdcall; external dllfile;


function BASSVIS_SetFullscreen(Param: PBASSVIS_PARAM;
    SourceHandle, DestHandle: HWND;
    SourceLeft, SourceTop,
    SourceWidth, SourceHeight: DWORD;
    FullScreenFlag: Boolean;
    FullScreeWidth, FullScreenHeight: DWORD
): BOOL; stdcall; external dllfile;


function BASSVIS_GetModulePresetCount(Param: PBASSVIS_PARAM;
    PluginName: PChar
): integer; stdcall; external dllfile;


function BASSVIS_GetModulePresetName(Param: PBASSVIS_PARAM;
    index: integer;
    PluginName: PChar = nil
): PChar; stdcall; external dllfile;


function BASSVIS_GetModulePresetNameList(param: PBASSVIS_PARAM;
   Pluginname:Pchar = NIL
):Pchar;stdcall; external dllfile;


function BASSVIS_GetOption(Param: PBASSVIS_PARAM;
    option: integer
): integer; stdcall; external dllfile;


function BASSVIS_SetOption(Param: PBASSVIS_PARAM;
    option: integer;
    Value: integer
): BOOL; stdcall; external dllfile;


function BASSVIS_SetPlayState(Param: PBASSVIS_PARAM;
    State: TPlayState;
    Value: integer = -1
): integer; stdcall; external dllfile;


procedure BASSVIS_SetVisPort(Parram: PBASSVIS_PARAM;
    WindowHandle: HWND;
    ContainerHandle: HWND;
    x, y, Width, Height: integer
); stdcall;external dllfile;


function BASSVIS_SONIQUEVIS_Clicked(
  handle: HVIS;
  x, y: DWORD
): boolean; stdcall;external dllfile;

function BASSVIS_GetPluginName(Param: PBASSVIS_PARAM): PChar; stdcall; external dllfile;
function BASSVIS_IsFree(Param: PBASSVIS_PARAM): BOOL; stdcall; external dllfile;
function BASSVIS_Free(Param: PBASSVIS_PARAM): BOOL; stdcall; external dllfile;
function BASSVIS_GetVersion: pchar; stdcall; external dllfile;
procedure BASSVIS_Quit(Param: PBASSVIS_PARAM);stdcall; external dllfile;

//Spezial für Winamp
procedure BASSVIS_WINAMP_SetStateCallback(callback:TBASSVIS_STATECALLBACK);stdcall;external dllfile;
procedure BASSVIS_WINAMP_RemoveCallback;stdcall;external dllfile;



implementation

end.

