#ifndef BASSVIS_H
#define BASSVIS_H

#include <wtypes.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifndef BASSVISDEF
#define BASSVISDEF(f) WINAPI f
#endif

typedef DWORD HVIS;

typedef unsigned __int64 QWORD;


// BASS_SONIQUEVIS_CreateVis flags
#define BASS_VIS_NOINIT				1

// BASS_SONIQUEVIS_SetConfig flags
#define BASS_SONIQUEVIS_CONFIG_FFTAMP			1
#define BASS_SONIQUEVIS_CONFIG_FFT_SKIPCOUNT	2 // Skip count range is from 0 to 3 (because of limited FFT request size)
#define BASS_SONIQUEVIS_CONFIG_WAVE_SKIPCOUNT   3 // Skip count range is from 0 to (...) try it out, whenever Bass crashes or does not return enough sample data
#define BASS_SONIQUEVIS_CONFIG_SLOWFADE	        4 // Dim light colors to less than half, then slowly fade them out

// BASS_WINAMP_SetConfig flags
#define BASS_WINAMPVIS_CONFIG_FFTAMP    1

// BASS_VIS_FindPlugin flags
#define BASS_VIS_FIND_SONIQUE			1
#define BASS_VIS_FIND_WINAMP			2
#define BASS_VIS_FIND_RECURSIVE			4

//Plugin kind
#define BASSVISKIND_NONE     0 // no kind
#define BASSVISKIND_WINAMP   1 // Winamp
#define BASSVISKIND_SONIQUE  2 // Sonique


typedef int BASSVIS_KIND_T;

typedef struct {
    HVIS  VisHandle;          // VisHandle
    DWORD VisWinHandle;       // Vis Window Handle         W2
    DWORD VisGenWinHandle;    // General Vis Window Handle W5
    BASSVIS_KIND_T Kind;      // Plugin kind	
} BASSVIS_PARAM;

typedef struct {
    char* AMP_SON_Pluginfile; // path to Plugin kind
    DWORD AMP_UseOwnW1;       // flags for Winamp (ownHDC)
    DWORD AMP_UseOwnW2;       // flags for Winamp (ownHDCW2)
    DWORD AMP_Moduleindex;    // Modul-index for Winamp
    DWORD SON_PaintHandle     // Painthandle for Sonique
    char* SON_ConfigFile;     // path to configfile Sonique
    DWORD SON_Flags;          // flags for Sonique
    int   Width;              // SrcWindow width
    int   Height;             // SrcWindow height
    int   Left;               // SrcWindow left
    int   Top;                // SrcWindow top
} BASSVIS_EXEC;

typedef struct {  
    char* SongTitle;          // songtitel
    char* Songfile;           // songTitle with path
    DWORD pos;                // stream position
    DWORD len;                // stream length
    DWORD PlaylistPos;        // playlist position
    DWORD Playlistlen;        // playlist entry
    int SampleRate;           // samplerate
    int BitRate;              // bitrate
    DWORD Duration;           // duration
    int Channels;             // channel default 2 (stereo)
} BASSVIS_INFO;

enum {
	psError = -1,			
	psStop = 0,		        
	psPlay = 1,		
	psIsPlaying = 2,			
	psPause = 3,		
	psGetPlaylistPos = 4,			
	psSetPlaylistPos = 5			
} PlayState;


typedef void (_stdcall *BASSVIS_STATECALLBACK) (PlayState);

BOOL BASSVISDEF(BASSVIS_Init)(BASSVIS_KIND_T Kind, HWND AppHandle, HWND WinHandle, HWND PaintHandle);
BOOL BASSVISDEF(BASSVIS_RenderChannel)(BASSVIS_PARAM* Param, DWORD channel); 
BOOL BASSVISDEF(BASSVIS_StartRecord)(BASSVIS_PARAM* Param, int SampleRate = 44100, int Channels = 2);
BOOL BASSVISDEF(BASSVIS_Config)(BASSVIS_PARAM* Param, int Entry = -1);
BOOL BASSVISDEF(BASSVIS_SetInfo)(BASSVIS_PARAM* Param, BASSVIS_INFO Infos);
BOOL BASSVISDEF(BASSVIS_Resize)(BASSVIS_PARAM* Param, int Left, int Top, int Width, int Height);
BOOL BASSVISDEF(BASSVIS_SetFullscreen)(BASSVIS_PARAM* Param, HWND SourceHandle, HWND DestHandle, int SourceLeft, int SourceTop, int SourceWidth, int SourceHeight, BOOL FullScreenFlag, int FullScreeWidth, int FullScreenHeight);
BOOL BASSVISDEF(BASSVIS_SetModulePreset)(BASSVIS_PARAM* Param, int index);
BOOL BASSVISDEF(BASSVIS_SetOption)(BASSVIS_PARAM* Param, int option, int value);
BOOL BASSVISDEF(BASSVIS_IsFree)(BASSVIS_PARAM* Param);
BOOL BASSVISDEF(BASSVIS_Free)(BASSVIS_PARAM* Param);

char* BASSVISDEF(BASSVIS_FindPlugins)(BASSVIS_KIND_T Kind, char *PluginPath, DWORD Searchflags);
char* BASSVISDEF(BASSVIS_GetModulePresetName)(BASSVIS_PARAM* Param, int index, char* PluginName = null);
char* BASSVISDEF(BASSVIS_GetModulePresetNameList)(BASSVIS_PARAM* Param, char* PluginName = null);
char* BASSVISDEF(BASSVIS_GetPluginName)(BASSVIS_PARAM* Param);
char* BASSVISDEF(BASSVIS_GetVersion);

BASSVIS_PARAM* BASSVISDEF(BASSVIS_GetPluginHandle)(BASSVIS_KIND_T Kind, char *Pluginfile);

void _stdcall BASSVISDEF(BASSVIS_ExecutePlugin)(BASSVIS_EXEC* Param, BASSVIS_PARAM* Base); 
void BASSVISDEF(BASSVIS_Quit)(BASSVIS_PARAM* Param);
void BASSVISDEF(BASSVIS_SetGenParent)(HWND WindowHandle, HWND ContainerHandle, int Left, int Top, int Width, int Height);

int BASSVISDEF(BASSVIS_GetModulePresetCount)(BASSVIS_PARAM* Param, char* PluginName);
int BASSVISDEF(BASSVIS_GetOption)(BASSVIS_PARAM* Param, int option);
int BASSVISDEF(BASSVIS_SetPlayState)(BASSVIS_PARAM* Param, PlayState State, int value = -1);

//Spezial for Winamp
void BASSVISDEF(BASSVIS_WINAMP_SetStateCallback)(BASSVIS_STATECALLBACK callback);
void BASSVISDEF(BASSVIS_WINAMP_RemoveCallback);

//Spezial for Sonique
BOOL BASSVISDEF(BASSVIS_SONIQUEVIS_Clicked)(HVIS handle, DWORD x, DWORD y);

#ifdef __cplusplus
}
#endif

#endif
