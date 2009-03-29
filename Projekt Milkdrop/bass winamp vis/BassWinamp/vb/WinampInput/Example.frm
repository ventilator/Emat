VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form Form1 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Winamp Input plugins example for BassWinamp"
   ClientHeight    =   3180
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   6825
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3180
   ScaleWidth      =   6825
   StartUpPosition =   3  'Windows Default
   Begin VB.Timer Timer1 
      Interval        =   500
      Left            =   5160
      Top             =   2400
   End
   Begin MSComDlg.CommonDialog CommonDialog 
      Left            =   6240
      Top             =   2400
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
      CancelError     =   -1  'True
   End
   Begin VB.ListBox List1 
      Height          =   840
      Left            =   2160
      TabIndex        =   1
      Top             =   840
      Width           =   2775
      Visible         =   0   'False
   End
   Begin VB.ListBox lstPlugins 
      Height          =   2205
      Left            =   120
      TabIndex        =   9
      Top             =   120
      Width           =   5295
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Stop"
      Height          =   375
      Index           =   5
      Left            =   2520
      TabIndex        =   7
      Top             =   2520
      Width           =   1095
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Pause"
      Height          =   375
      Index           =   4
      Left            =   1320
      TabIndex        =   6
      Top             =   2520
      Width           =   1095
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Open && Play"
      Height          =   375
      Index           =   3
      Left            =   120
      TabIndex        =   5
      Top             =   2520
      Width           =   1095
   End
   Begin VB.CommandButton Command1 
      Caption         =   "About"
      Height          =   375
      Index           =   2
      Left            =   5640
      TabIndex        =   4
      Top             =   2040
      Width           =   1095
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Config"
      Height          =   375
      Index           =   1
      Left            =   5640
      TabIndex        =   3
      Top             =   1440
      Width           =   1095
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Find Plugins"
      Height          =   375
      Index           =   0
      Left            =   5640
      TabIndex        =   2
      Top             =   240
      Width           =   1095
   End
   Begin VB.HScrollBar HScroll1 
      Height          =   255
      LargeChange     =   10
      Left            =   120
      TabIndex        =   0
      Top             =   2880
      Width           =   6615
   End
   Begin VB.Label Label1 
      Caption         =   "0 / 0"
      Height          =   255
      Left            =   3840
      TabIndex        =   8
      Top             =   2640
      Width           =   1095
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private WAChan As Long
Private IsScrolling As Boolean, IsUpdating As Boolean

Private Sub Command1_Click(Index As Integer)

Dim alist() As String
Dim i As Integer

Select Case Index
    Case 0
        'find plugins
        Dim sdir As String
        Dim flist As String
        
        'browse for folders
        sdir = SelectDirectory("Select Winamp Input Plugins Dir")
        If sdir = "" Then Exit Sub
        
        lstPlugins.Clear
        
        'find out input plugins
        flist = VBStrFromAnsiPtr(BASS_WINAMP_FindPlugins(sdir, BASS_WINAMP_FIND_INPUT Or BASS_WINAMP_FIND_COMMALIST Or BASS_WINAMP_FIND_RECURSIVE))
        alist = Split(flist, """") 'Split the commalist into an array (in case a path/filename includes a comma, it's split by quotes)
        If UBound(alist) = 0 Then alist = Split(flist, ",") 'In case it didn't use quotes
        
        'add the new ones at the end of both lists
        For i = 0 To UBound(alist)
            List1.AddItem BASS_WINAMP_LoadPlugin(alist(i))
            lstPlugins.AddItem VBStrFromAnsiPtr(BASS_WINAMP_GetName(List1.List(i)))
        Next i
Case 1
    If lstPlugins.ListIndex >= 0 Then Call BASS_WINAMP_ConfigPlugin(List1.List(lstPlugins.ListIndex))

Case 2
    If lstPlugins.ListIndex >= 0 Then Call BASS_WINAMP_AboutPlugin(List1.List(lstPlugins.ListIndex))
Case 3
    Dim Filter As String, MemPtr As Long, Ext As String
    For i = 0 To List1.ListCount - 1
        MemPtr = BASS_WINAMP_GetExtentions(List1.List(i))
        Do While VBStrFromAnsiPtr(MemPtr) <> ""
            Ext = VBStrFromAnsiPtr(MemPtr)
            Filter = Filter & Ext & "|"
            MemPtr = MemPtr + Len(Ext) + 1
        Loop
    Next i
    On Error GoTo Cancel
    CommonDialog.Filter = Filter
    CommonDialog.ShowOpen
    Call BASS_StreamFree(WAChan)
    WAChan = BASS_WINAMP_StreamCreate(CommonDialog.FileName, 0)
    Dim Title As String, length As Long
    BASS_WINAMP_GetFileInfo CommonDialog.FileName, Title, length
    Me.Caption = Title & " | " & length & " ms"
    Call BASS_StreamPlay(WAChan, 0, 0)
Case 4
    If BASS_ChannelResume(WAChan) = 0 Then Call BASS_ChannelPause(WAChan)
Case 5
    Call BASS_ChannelStop(WAChan)
End Select
Cancel:
End Sub

Private Sub Form_Load()
    'change and set the current path
    'so it won't ever tell you that "bass.dll" isn't found
    ChDrive App.Path
    ChDir App.Path
    
    'check if "bass.dll" is exists
    If FileExists(RPP(App.Path) & "bass.dll") = False Then
        Call MsgBox("BASS.DLL does not exists", vbCritical, "BASS.DLL")
        End
    End If
    
    'Check that BASS 2.0 was loaded
    If BASS_GetVersion <> MakeLong(2, 0) Then
        Call MsgBox("BASS version 2.0 was not loaded", vbCritical, "BASS.DLL")
        End
    End If
    
    If BASS_Init(1, 44100, 0, Me.hWnd, 0) = 0 Then
        Call MsgBox("Can't initialize device", vbCritical, "BASS.DLL")
        End
    End If
End Sub

'---------------------------------
' some useful function :)
'---------------------------------

'check if any file exists
Public Function FileExists(ByVal FileName As String) As Boolean
  On Local Error Resume Next
  FileExists = (Dir$(FileName) <> "")
End Function

' RPP = Return Proper Path
Function RPP(ByVal fp As String) As String
    RPP = IIf(Mid(fp, Len(fp), 1) <> "\", fp & "\", fp)
End Function

Private Sub Form_Unload(Cancel As Integer)
    Call BASS_StreamFree(WAChan)
    Call BASS_Free
    Dim i As Integer
    For i = 0 To lstPlugins.ListCount - 1
        Call BASS_WINAMP_UnloadPlugin(List1.List(i))
    Next i
End Sub

Private Sub HScroll1_Change()
    If IsUpdating = True Then Exit Sub 'The change action was taken during a update, don't process
    
    IsScrolling = False
    
    Call BASS_ChannelSetPosition(WAChan, BASS_ChannelSeconds2Bytes(WAChan, HScroll1.value))
End Sub

Private Sub HScroll1_Scroll()
    IsScrolling = True
End Sub

Private Sub Timer1_Timer()
    If BASS_ChannelGetPosition(WAChan) >= 0 And BASS_StreamGetLength(WAChan) >= 0 Then
        Label1.Caption = Int(BASS_ChannelBytes2Seconds(WAChan, BASS_ChannelGetPosition(WAChan))) & " / " & Int(BASS_ChannelBytes2Seconds(WAChan, BASS_StreamGetLength(WAChan)))
        IsUpdating = True
        If IsScrolling = False Then 'If user is scrolling, don't change scroll
            HScroll1.max = Int(BASS_ChannelBytes2Seconds(WAChan, BASS_StreamGetLength(WAChan)))
            If Int(BASS_ChannelBytes2Seconds(WAChan, BASS_ChannelGetPosition(WAChan))) <= HScroll1.max Then HScroll1.value = Int(BASS_ChannelBytes2Seconds(WAChan, BASS_ChannelGetPosition(WAChan)))
        End If
        IsUpdating = False
    End If
End Sub
