Attribute VB_Name = "modBassWinamp"
Option Explicit

Global Const BASS_CTYPE_STREAM_WINAMP = &H10400

Global Const BASS_WINAMP_SYNC_BITRATE = 100

' BASS_WINAMP_SetConfig flags
Global Const BASS_WINAMP_CONFIG_INPUT_TIMEOUT = 1 ' Set the time to wait until timing out because
                                                  ' the plugin is not using the output system

' BASS_WINAMP_FindPlugin flags
Global Const BASS_WINAMP_FIND_INPUT = 1
Global Const BASS_WINAMP_FIND_RECURSIVE = 4
' return value type
Global Const BASS_WINAMP_FIND_COMMALIST = 8
  ' Delphi's comma list style (item1,item2,"item 3",item4,"item with space")
  ' the list ends with single NULL character


Declare Function BASS_WINAMP_LoadPlugin Lib "bass_winamp.dll" (ByVal f As Any) As Long
Declare Sub BASS_WINAMP_UnloadPlugin Lib "bass_winamp.dll" (ByVal handle As Long)
Declare Function BASS_WINAMP_GetName Lib "bass_winamp.dll" (ByVal handle As Long) As Long
Declare Function BASS_WINAMP_GetVersion Lib "bass_winamp.dll" (ByVal handle As Long) As Long
Declare Function BASS_WINAMP_GetIsSeekable Lib "bass_winamp.dll" (ByVal handle As Long) As Long
Declare Function BASS_WINAMP_GetUsesOutput Lib "bass_winamp.dll" (ByVal handle As Long) As Long
Declare Function BASS_WINAMP_GetExtentions Lib "bass_winamp.dll" (ByVal handle As Long) As Long
Declare Function BASS_WINAMP_GetFileInfoPtr Lib "bass_winamp.dll" Alias "BASS_WINAMP_GetFileInfo" (ByVal f As Any, ByVal Title As Any, ByRef Lenms As Long) As Long
Declare Function BASS_WINAMP_InfoDlg Lib "bass_winamp.dll" (ByVal f As Any, ByVal win As Long) As Long
Declare Sub BASS_WINAMP_ConfigPlugin Lib "bass_winamp.dll" (ByVal handle As Long, ByVal win As Long)
Declare Sub BASS_WINAMP_AboutPlugin Lib "bass_winamp.dll" (ByVal handle As Long, ByVal win As Long)
Declare Function BASS_WINAMP_StreamCreate Lib "bass_winamp.dll" (ByVal f As Any, ByVal flags As Long) As Long

Declare Function BASS_WINAMP_GetConfig Lib "bass_winamp.dll" (ByVal opt As Long) As Long
Declare Sub BASS_WINAMP_SetConfig Lib "bass_winamp.dll" (ByVal opt As Long, ByVal value As Long)
Declare Function BASS_WINAMP_FindPlugins Lib "bass_winamp.dll" (ByVal pluginpath As Any, ByVal flags As Long) As Long

'VB wrapper function for BASS_WINAMP_GetFileInfo
Function BASS_WINAMP_GetFileInfo(f As String, Title As String, Lenms As Long) As Long
    Title = String$(255, 0)
    BASS_WINAMP_GetFileInfo = BASS_WINAMP_GetFileInfoPtr(f, Title, Lenms)
    Title = Left$(Title, InStr(1, Title, Chr$(0)) - 1)
End Function

