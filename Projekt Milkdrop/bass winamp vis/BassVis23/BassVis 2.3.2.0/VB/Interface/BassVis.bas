Attribute VB_Name = "mBassVis"
'mBassVis.BAS
'--------------------------- VB 6.0 Form Module -----------------------------
' BassVis API Module ADD-ON for Bass Audio Library
' Copyright © 2007 BrewIdeas@Emil Weiss, All Rights Reserved
'
' Author(s) of this module: Emil Weiss
'
' Code was written in and formatted for 10pt Courier New
'----------------------------------------------------------------------------

Option Explicit
  
  ' BASS_SONIQUEVIS_CreateVis flags
  Public Const BASS_VIS_NOINIT                       As Integer = 1

  ' BASS_SONIQUEVIS_SetConfig flags
  Public Const BASS_SONIQUEVIS_CONFIG_FFTAMP         As Integer = 1
  Public Const BASS_SONIQUEVIS_CONFIG_FFT_SKIPCOUNT  As Integer = 2  ' Skip count range is from 0 to 3 (because of limited FFT request size)
  Public Const BASS_SONIQUEVIS_CONFIG_WAVE_SKIPCOUNT As Integer = 3  ' Skip count range is from 0 to (...) try it out, whenever Bass crashes or does not return enough sample data
  Public Const BASS_SONIQUEVIS_CONFIG_SLOWFADE       As Integer = 4  ' Dim light colors to less than half, then slowly fade them out

  ' BASS_WINAMP_SetConfig flags
  Public Const BASS_WINAMPVIS_CONFIG_FFTAMP          As Integer = 1

  ' BASS_VIS_FindPlugin flags
  Public Const BASS_VIS_FIND_SONIQUE                 As Integer = 1
  Public Const BASS_VIS_FIND_WINAMP                  As Integer = 2
  Public Const BASS_VIS_FIND_RECURSIVE               As Integer = 4

  ' Plugin Kind
  Public Const BASSVISKIND_NONE = 0
  Public Const BASSVISKIND_WINAMP = 1
  Public Const BASSVISKIND_SONIQUE = 2
  
  ' Plugin Parameter
  Public Type BASSVIS_PARAM
     Vishandle       As Long      ' VisHandle
     VisWinhandle    As Long      ' VisWinHandle
     VisGenWinhandle As Long      ' General Vis Window Handle
     Kind            As Long      ' Plugin Kind (BASSVISKIND_NONE, _
                                                 BASSVISKIND_WINAMP, _
                                                 BASSVISKIND_SONIQUE, _
                                                 )
  End Type
  
  ' Definition der Typen für die variablen Parameter bei Create bzw. Execute
  Public Type BASSVIS_EXEC
    AMP_SON_Pluginfile As String     ' Dateiname des Plugins für Sonique und Winamp
    AMP_UseOwnW1       As Long       ' Flag für Winamp False =(Render Winamp5 im eigenen Window) 0=aus,1=an
    AMP_UseOwnW2       As Long       ' Flag für Winamp False =(Render Winamp2 im eigenen Window) 0=aus,1=an
    AMP_Moduleindex    As Long       ' Modul-index für Winamp
    SON_PaintHandle    As Long       ' Painthandle für Sonique
    SON_ConfigFile     As String     ' Dateiname der Konfiguration für Sonique
    SON_Flags          As Long       ' Flags für Sonique
    Width              As Long       ' Fensterbreite
    Height             As Long       ' Fensterhöhe
    Left               As Long       ' Top
    Top                As Long       ' Left
  End Type

  Public Type BASSVIS_INFO
    SongTitle    As String     ' SongTitel ohne Pfad
    Songfile     As String     ' SongFile incl. Pfad (StreamFile)
    pos          As Long       ' StreamPos = 1000*StreamPos
    len          As Long       ' Stream länge
    PlaylistPos  As Long       ' PlaylistPos minimal > 0
    Playlistlen  As Long       ' Playlist länge
    SampleRate   As Long       ' Samplerate default = 44100
    BitRate      As Long       '
    Duration     As Long       '
    Channels     As Long       ' 2
  End Type

  Public Enum BASSVIS_PLAYSTATE
      psError = -1
      psStop = 0
      psPlay = 1
      psIsPlaying = 2
      psPause = 3
      psGetPlaylistPos = 4
      psSetPlaylistPos = 5
  End Enum


'Core functions for initalizing BASSVIS and Find Plugins of any kind
Public Declare Function BASSVIS_Init Lib "bass_vis.dll" ( _
    ByVal Kind As Long, _
    ByVal AppHandle As Long, _
    ByVal WinHandle As Long _
) As Boolean


'Core functions for initalizing BASSVIS and Find Plugins of any kind
'delemiter As Byte = 44 .. ASC(",")
'you can send other delemiter for Spliting
Public Declare Function BASSVIS_FindPlugins Lib "bass_vis.dll" ( _
    ByVal Kind As Long, _
    ByVal PluginPath As Any, _
    ByVal Searchflags As Long, _
    Optional ByVal delemiter As Byte = 44 _
) As Long


Public Declare Function BASSVIS_Free Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM _
) As Boolean


Public Declare Function BASSVIS_GetVersion Lib "bass_vis.dll" () As String
 

Public Declare Sub BASSVIS_ExecutePlugin Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_EXEC, _
    ByRef Base As BASSVIS_PARAM _
)


Public Declare Function BASSVIS_RenderChannel Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM, _
    ByVal channel As Long _
) As Boolean


Public Declare Function BASSVIS_StartRecord Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM, _
    Optional ByVal SampleRate As Long = 44100, _
    Optional ByVal Channels As Long = 2 _
) As Boolean


Public Declare Function BASSVIS_Config Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM, _
    Optional ByVal Entry As Long = -1 _
) As Boolean


Public Declare Function BASSVIS_SetInfo Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM, _
    ByRef infos As BASSVIS_INFO _
) As Boolean


Public Declare Function BASSVIS_Resize Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM, _
    ByVal Left As Long, _
    ByVal Top As Long, _
    ByVal Width As Long, _
    ByVal Height As Long _
) As Boolean


Public Declare Function BASSVIS_SetFullscreen Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM, _
    ByVal SourceHandle As Long, _
    ByVal DestHandle As Long, _
    ByVal SourceLeft As Long, _
    ByVal SourceTop As Long, _
    ByVal SourceWidth As Long, _
    ByVal SourceHeight As Long, _
    ByVal FullScreenFlag As Boolean, _
    ByVal FullScreeWidth As Long, _
    ByVal FullScreenHeight As Long _
) As Boolean


Public Declare Function BASSVIS_GetModulePresetCount Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM, _
    ByVal Pluginname As Any _
) As Long


Public Declare Function BASSVIS_GetModulePresetName Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM, _
    ByVal index As Long, _
    ByVal Pluginname As Any _
) As Long


Public Declare Function BASSVIS_GetModulePresetNameList Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM, _
    ByVal Pluginname As Any _
) As Long


Public Declare Function BASSVIS_SetModulePreset Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM, _
    ByVal index As Long _
) As Boolean


Public Declare Function BASSVIS_GetOption Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM, _
    ByVal options As Long _
) As Long


Public Declare Function BASSVIS_SetOption Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM, _
    ByVal options As Long, _
    ByVal value As Long _
) As Boolean


Public Declare Function BASSVIS_SetPlayState Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM, _
    ByVal State As BASSVIS_PLAYSTATE, _
    Optional ByVal value As Long = -1 _
) As Long


Public Declare Function BASSVIS_GetPluginHandle Lib "bass_vis.dll" ( _
    ByVal Kind As Long, _
    ByVal Pluginfile As Any _
) As Long


Public Declare Function BASSVIS_GetPluginName Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM _
) As Long


Public Declare Function BASSVIS_IsFree Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM _
) As Boolean


Public Declare Sub BASSVIS_Quit Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM _
)


Public Declare Sub BASSVIS_SetVisPort Lib "bass_vis.dll" ( _
    ByRef param As BASSVIS_PARAM, _
    ByVal WindowHandle As Long, _
    ByVal ContainerHandle As Long, _
    ByVal x As Long, _
    ByVal y As Long, _
    ByVal Width As Long, _
    ByVal Height As Long _
)


Public Declare Sub BASSVIS_WINAMP_SetStateCallback Lib "bass_vis.dll" ( _
    ByVal callback As BASSVIS_PLAYSTATE _
)

Public Declare Sub BASSVIS_WINAMP_RemoveCallback Lib "bass_vis.dll" ()


Public Declare Function BASSVIS_SONIQUEVIS_Clicked Lib "bass_vis.dll" ( _
    ByVal handle As Long, _
    ByVal x As Long, _
    ByVal y As Long _
) As Boolean

' ************** End BASSVIS Interface **************
'*****************************************************


' Windows API Declaration
Private Declare Function lstrlen Lib "kernel32" Alias "lstrlenA" ( _
    ByVal lpString As Long _
) As Long

Public Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" ( _
    ByRef Destination As Any, _
    ByRef Source As Any, _
    ByVal Length As Long _
)


Public Function VBStrFromAnsiPtr(ByVal lpStr As Long) As String

Dim bStr() As Byte
Dim cChars As Long

    On Error Resume Next
    ' Get the number of characters in the buffer
    cChars = lstrlen(lpStr)
    ' Resize the byte array
    ReDim bStr(0 To cChars - 1) As Byte
    ' Grab the ANSI buffer
    Call CopyMemory(bStr(0), ByVal lpStr, cChars)
    ' Now convert to a VB Unicode string
    VBStrFromAnsiPtr = StrConv(bStr, vbUnicode)

End Function
