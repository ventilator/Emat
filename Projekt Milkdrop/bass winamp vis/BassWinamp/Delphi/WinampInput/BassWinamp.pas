unit BassWinamp;

interface

uses
  Bass, Windows;


type
  HPLUGIN = DWORD;


const
  BASS_CTYPE_STREAM_WINAMP   = $10400;

  BASS_WINAMP_SYNC_BITRATE   = 100;

  // BASS_WINAMP_SetConfig flags
  BASS_WINAMP_CONFIG_INPUT_TIMEOUT = 1; // Set the time to wait until timing out because
                                        // the plugin is not using the output system

  // BASS_WINAMP_FindPlugin flags
  BASS_WINAMP_FIND_INPUT     = 1;
  BASS_WINAMP_FIND_RECURSIVE = 4;
  // return value type
  BASS_WINAMP_FIND_COMMALIST = 8;
    // Delphi's comma list style (item1,item2,"item with , commas",item4,"item with space")
    // the list ends with single NULL character


function BASS_WINAMP_LoadPlugin(const f: PChar): HPLUGIN; stdcall; external 'bass_winamp.dll';
procedure BASS_WINAMP_UnloadPlugin(handle: HPLUGIN); stdcall; external 'bass_winamp.dll';
function BASS_WINAMP_GetName(handle: HPLUGIN): PChar; stdcall; external 'bass_winamp.dll';
function BASS_WINAMP_GetVersion(handle: HPLUGIN): Integer; stdcall; external 'bass_winamp.dll';
function BASS_WINAMP_GetIsSeekable(handle: HPLUGIN): Boolean; stdcall; external 'bass_winamp.dll';
function BASS_WINAMP_GetUsesOutput(handle: HPLUGIN): Boolean; stdcall; external 'bass_winamp.dll';
function BASS_WINAMP_GetExtentions(handle: HPLUGIN): PChar; stdcall; external 'bass_winamp.dll';
function BASS_WINAMP_GetFileInfo(f, title: PChar; var lenms: Integer): Boolean; stdcall; external 'bass_winamp.dll';
function BASS_WINAMP_InfoDlg(f: PChar; const win: DWORD): Boolean; stdcall; external 'bass_winamp.dll';
procedure BASS_WINAMP_ConfigPlugin(handle: HPLUGIN; const win: DWORD); stdcall; external 'bass_winamp.dll';
procedure BASS_WINAMP_AboutPlugin(handle: HPLUGIN; const win: DWORD); stdcall; external 'bass_winamp.dll';
function BASS_WINAMP_StreamCreate(const f: PChar; flags: DWORD): HSTREAM; stdcall; external 'bass_winamp.dll';

function BASS_WINAMP_GetConfig(option: DWORD): DWORD; stdcall; external 'bass_winamp.dll';
procedure BASS_WINAMP_SetConfig(option, value: DWORD); stdcall; external 'bass_winamp.dll';
function BASS_WINAMP_FindPlugins(pluginpath: PChar; flags: DWORD): PChar; stdcall; external 'bass_winamp.dll';


implementation

end.
