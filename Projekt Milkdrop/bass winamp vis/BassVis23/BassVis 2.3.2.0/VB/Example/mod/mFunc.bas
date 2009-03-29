Attribute VB_Name = "mFunc"

'mFunc.BAS
'--------------------------- VB 6.0 Form Module -----------------------------
' BassVis API Module ADD-ON for Bass Audio Library
' Copyright © 2007 BrewIdeas@Emil Weiss, All Rights Reserved
'
' Author(s) of this module: Emil Weiss
'
' Code was written in and formatted for 10pt Courier New
'----------------------------------------------------------------------------

Option Explicit

Public Declare Function BitBlt Lib "gdi32" ( _
    ByVal hDestDC As Long, _
    ByVal x As Long, _
    ByVal y As Long, _
    ByVal nWidth As Long, _
    ByVal nHeight As Long, _
    ByVal hSrcDC As Long, _
    ByVal xSrc As Long, _
    ByVal ySrc As Long, _
    ByVal dwRop As Long _
) As Long


Public Declare Sub SetWindowPos Lib "user32" ( _
    ByVal hwnd As Long, _
    ByVal hWndInsertAfter As Long, _
    ByVal x As Long, _
    ByVal y As Long, _
    ByVal cx As Long, _
    ByVal cy As Long, _
    ByVal wFlags As Long _
)

Declare Function StretchBlt Lib "gdi32" ( _
    ByVal hDC As Long, _
    ByVal x As Long, _
    ByVal y As Long, _
    ByVal nWid6th As Long, _
    ByVal nHeight As Long, _
    ByVal hSrcDC As Long, _
    ByVal xSrc As Long, _
    ByVal ySrc As Long, _
    ByVal nSrcWidth As Long, _
    ByVal nSrcHeight As Long, _
    ByVal dwRop As Long _
) As Long

Public Declare Function GetPixel Lib "gdi32" ( _
    ByVal hDC As Long, _
    ByVal x As Long, _
    ByVal y As Long _
) As Long


Public Declare Function PostMessage Lib "user32" Alias "PostMessageA" ( _
    ByVal hwnd As Long, _
    ByVal wMsg As Long, _
    ByVal wParam As Long, _
    lParam As Any _
) As Long

Public Declare Function GetWindowText Lib "user32" Alias "GetWindowTextA" ( _
    ByVal hwnd As Long, _
    ByVal lpString As String, _
    ByVal cch As Long _
) As Long


Public Declare Function GetWindowTextLength Lib "user32" Alias "GetWindowTextLengthA" ( _
    ByVal hwnd As Long _
) As Long


Public Declare Function SetEnvironmentVariable Lib "kernel32.dll" Alias "SetEnvironmentVariableA" ( _
    ByVal lpName As String, _
    ByVal lpValue As String _
) As Long


Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

Public input_      As Long
Public VisWindowHandle  As Long
Public hWndGen     As Long


Public Const SRCCOPY = &HCC0020
Public Const SRCPAINT = &HEE0086

Public BitTextArray(26) As Variant

Public Const HWND_TOPMOST       As Integer = -1
Public Const HWND_NOTOPMOST     As Integer = -2
Public Const SWP_NOACTIVATE     As Long = &H10
Public Const SWP_NOMOVE         As Long = &H2
Public Const SWP_NOSIZE         As Long = &H1

Public GenVisible               As Boolean
Public mVisHandle               As BASSVIS_PARAM
Public PlaylistPos              As Integer

'Return the Filename part of the filespec
Public Function GetFileName(ByVal filename As String) As String

Dim intL As Integer
Dim intJ As Integer

    intL = Len(filename)
    For intJ = intL To 1 Step -1
        If Mid$(filename, intJ, 1) = "\" Then
            Exit For
        End If
    Next

    GetFileName = Mid$(filename, intJ + 1)
    
End Function

'Return the Path and Filename parts from Filespec
Public Function GetBaseName(ByVal filename As String) As String

Dim intL As Integer
Dim intJ As Integer

    If LenB(filename) = 0 Then
        GetBaseName = vbNullString
        Exit Function
    End If

    On Error GoTo err_Handle
    intL = Len(filename)
    For intJ = intL To 1 Step -1
        If Mid$(filename, intJ, 1) = "." Then
            Exit For
        End If
    Next intJ

    GetBaseName = Left$(filename, intJ - 1)

Exit Function

err_Handle:
    GetBaseName = vbNullString

End Function

'Return the Path part of the filespec
Public Function GetPath(ByVal filename As String) As String

Dim intP As Integer
Dim intJ As Integer

    intP = 0
    For intJ = Len(filename) To 1 Step -1
        If Mid$(filename, intJ, 1) = "\" Then
            intP = intJ
            Exit For
        End If
    Next

    If intP > 0 Then
        GetPath = Left$(filename, intP)
    Else
        GetPath = vbNullString
    End If

End Function

Public Sub BASSVIS_StateCallback(ByVal NewState As BASSVIS_PLAYSTATE)

    'CallBack PlayState for Winamp only
    Select Case NewState
    
        Case psStop
            If (BASS_ChannelIsActive(Form1.Stream) = BASS_ACTIVE_PLAYING) Or _
                (BASS_ChannelIsActive(Form1.Stream) = BASS_ACTIVE_PAUSED) Then

                Form1.cmdStop_Click
                BASSVIS_SetPlayState mVisHandle, psStop
            End If
        Case psPlay
            If Not (BASS_ChannelIsActive(Form1.Stream) = BASS_ACTIVE_PLAYING) And Not _
                (BASS_ChannelIsActive(Form1.Stream) = BASS_ACTIVE_PAUSED) Then
                Form1.cmdPlay_Click
            Else
                BASS_ChannelPlay Form1.Stream, False
                BASSVIS_SetPlayState mVisHandle, psPlay
                Form1.Paused = False
            End If
        Case psPause
            Form1.Paused = False
            Form1.cmdPause_Click
            BASSVIS_SetPlayState mVisHandle, psPause
        Case psGetPlaylistPos
            PlaylistPos = Form1.Playlist.ListIndex
            If PlaylistPos > 0 Then
                Form1.cmdPrev_Click
            End If
        Case psSetPlaylistPos
            If PlaylistPos < (Form1.Playlist.ListCount - 1) Then
                Form1.cmdNext_Click
            End If
            
    End Select

End Sub

Public Sub SyncEndProc(ByVal handle As Long, ByVal channel As Long, ByVal data As Long, ByVal user As Long)
    
    Form1.MusikEnd
    
End Sub

