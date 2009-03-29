VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form Form1 
   BorderStyle     =   3  'Fester Dialog
   Caption         =   "BassVis Visual Basic example"
   ClientHeight    =   9345
   ClientLeft      =   405
   ClientTop       =   870
   ClientWidth     =   12465
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   9345
   ScaleWidth      =   12465
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'Bildschirmmitte
   Begin VB.PictureBox picTimerHwnd 
      BackColor       =   &H00000000&
      BorderStyle     =   0  'Kein
      Height          =   255
      Left            =   1440
      ScaleHeight     =   255
      ScaleWidth      =   1215
      TabIndex        =   63
      Top             =   10320
      Width           =   1215
   End
   Begin MSComDlg.CommonDialog CommonDialog1 
      Left            =   720
      Top             =   10320
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
      MaxFileSize     =   9999
   End
   Begin VB.ListBox lstPlgPath 
      Height          =   255
      ItemData        =   "Form1.frx":0000
      Left            =   240
      List            =   "Form1.frx":0002
      TabIndex        =   60
      Top             =   9840
      Width           =   975
   End
   Begin VB.PictureBox picPlgSource 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'Kein
      Height          =   4080
      Left            =   7440
      ScaleHeight     =   272
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   328
      TabIndex        =   59
      Top             =   240
      Width           =   4920
   End
   Begin VB.Frame fraShowOption 
      Caption         =   "Show Option"
      Height          =   615
      Left            =   7440
      TabIndex        =   54
      Top             =   7800
      Width           =   4935
      Begin VB.OptionButton optDefault 
         Caption         =   "Default"
         Height          =   255
         Left            =   3360
         TabIndex        =   57
         Top             =   240
         Width           =   975
      End
      Begin VB.OptionButton optGen 
         Caption         =   "With GenBitmap"
         Height          =   255
         Left            =   1680
         TabIndex        =   56
         Top             =   240
         Width           =   1455
      End
      Begin VB.OptionButton optPicBox 
         Caption         =   "in PicBox"
         Height          =   255
         Left            =   240
         TabIndex        =   55
         Top             =   240
         Value           =   -1  'True
         Width           =   1095
      End
   End
   Begin VB.Frame fraRenderOpt 
      Caption         =   "Render Option"
      Height          =   735
      Left            =   7440
      TabIndex        =   51
      Top             =   8520
      Width           =   4935
      Begin VB.OptionButton optfile 
         Caption         =   "Render from Filestream"
         Height          =   255
         Left            =   2400
         TabIndex        =   53
         Top             =   360
         Value           =   -1  'True
         Width           =   1935
      End
      Begin VB.OptionButton optDevice 
         Caption         =   "Render from Device"
         Height          =   255
         Left            =   240
         TabIndex        =   52
         Top             =   360
         Width           =   1815
      End
   End
   Begin VB.Frame fraSelectVisType 
      Height          =   735
      Left            =   120
      TabIndex        =   28
      Top             =   960
      Width           =   7095
      Begin VB.ComboBox cbScreenRes 
         Height          =   315
         ItemData        =   "Form1.frx":0004
         Left            =   4920
         List            =   "Form1.frx":0014
         TabIndex        =   61
         Top             =   240
         Width           =   1575
      End
      Begin VB.ComboBox cbVisType 
         Height          =   315
         ItemData        =   "Form1.frx":003C
         Left            =   1320
         List            =   "Form1.frx":0046
         TabIndex        =   29
         Top             =   240
         Width           =   2055
      End
      Begin VB.Label lblScreenres 
         Alignment       =   2  'Zentriert
         Caption         =   "Select FullScreen Mode"
         Height          =   375
         Left            =   3480
         TabIndex        =   62
         Top             =   240
         Width           =   1335
      End
      Begin VB.Label lblVisArt 
         Alignment       =   2  'Zentriert
         Caption         =   "Visualizations Kind"
         Height          =   420
         Left            =   120
         TabIndex        =   30
         Top             =   240
         Width           =   945
      End
   End
   Begin VB.CheckBox ckRandom 
      Caption         =   "Random"
      Height          =   255
      Left            =   6240
      TabIndex        =   24
      Top             =   4920
      Value           =   1  'Aktiviert
      Width           =   975
   End
   Begin VB.CommandButton cmdResize 
      Caption         =   ">>"
      Height          =   375
      Left            =   6720
      TabIndex        =   18
      Top             =   4440
      Width           =   495
   End
   Begin VB.Frame fraPlayOpt 
      Height          =   735
      Left            =   0
      TabIndex        =   12
      Top             =   8520
      Width           =   7095
      Begin VB.CommandButton cmdAdd 
         Caption         =   "AddFiles"
         Height          =   375
         Left            =   5760
         TabIndex        =   25
         Top             =   240
         Width           =   1215
      End
      Begin VB.CommandButton cmdPrev 
         Caption         =   "<<"
         Enabled         =   0   'False
         Height          =   375
         Left            =   120
         TabIndex        =   17
         Top             =   240
         Width           =   975
      End
      Begin VB.CommandButton cmdPlay 
         Caption         =   "Play"
         Enabled         =   0   'False
         Height          =   375
         Left            =   1200
         TabIndex        =   16
         Top             =   240
         Width           =   1095
      End
      Begin VB.CommandButton cmdStop 
         Caption         =   "Stop"
         Enabled         =   0   'False
         Height          =   375
         Left            =   2400
         TabIndex        =   15
         Top             =   240
         Width           =   975
      End
      Begin VB.CommandButton cmdPause 
         Caption         =   "Pause"
         Enabled         =   0   'False
         Height          =   375
         Left            =   3480
         TabIndex        =   14
         Top             =   240
         Width           =   975
      End
      Begin VB.CommandButton cmdNext 
         Caption         =   ">>"
         Enabled         =   0   'False
         Height          =   375
         Left            =   4560
         TabIndex        =   13
         Top             =   240
         Width           =   975
      End
   End
   Begin VB.Frame fraListContainer 
      Height          =   2535
      Left            =   120
      TabIndex        =   9
      Top             =   1800
      Width           =   7095
      Begin VB.ListBox VisModules 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   1740
         ItemData        =   "Form1.frx":005B
         Left            =   2520
         List            =   "Form1.frx":005D
         TabIndex        =   26
         Top             =   600
         Width           =   4455
      End
      Begin VB.TextBox Descript 
         Height          =   285
         Left            =   2520
         TabIndex        =   11
         Top             =   240
         Width           =   4455
      End
      Begin VB.ListBox lstPlugins 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   1980
         ItemData        =   "Form1.frx":005F
         Left            =   120
         List            =   "Form1.frx":0061
         TabIndex        =   10
         Top             =   240
         Width           =   2250
      End
   End
   Begin VB.Frame fraInputsOpt 
      Height          =   735
      Left            =   120
      TabIndex        =   4
      Top             =   120
      Width           =   7095
      Begin VB.ComboBox cmbInputs 
         Height          =   315
         Left            =   1335
         Style           =   2  'Dropdown-Liste
         TabIndex        =   5
         Top             =   240
         Width           =   2235
      End
      Begin MSComctlLib.Slider slLevel 
         Height          =   375
         Left            =   4200
         TabIndex        =   8
         Top             =   240
         Width           =   2295
         _ExtentX        =   4048
         _ExtentY        =   661
         _Version        =   393216
         Max             =   100
      End
      Begin VB.Label lblLevel 
         Caption         =   "0"
         Height          =   255
         Left            =   6600
         TabIndex        =   27
         Top             =   285
         Width           =   375
      End
      Begin VB.Label lblVisFrom 
         AutoSize        =   -1  'True
         Caption         =   "Visualizing from"
         Height          =   195
         Left            =   120
         TabIndex        =   7
         Top             =   285
         Width           =   1080
      End
      Begin VB.Label lblLevelCap 
         AutoSize        =   -1  'True
         Caption         =   "Level :"
         Height          =   195
         Left            =   3720
         TabIndex        =   6
         Top             =   285
         Width           =   480
      End
   End
   Begin VB.ListBox Playlist 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3180
      ItemData        =   "Form1.frx":0063
      Left            =   120
      List            =   "Form1.frx":0065
      TabIndex        =   3
      Top             =   5280
      Width           =   7095
   End
   Begin VB.ListBox lstPathList 
      Height          =   255
      ItemData        =   "Form1.frx":0067
      Left            =   1320
      List            =   "Form1.frx":0069
      TabIndex        =   2
      Top             =   9840
      Width           =   975
   End
   Begin VB.CommandButton cmdConfig 
      Caption         =   "Config"
      Height          =   375
      Left            =   1920
      TabIndex        =   1
      Top             =   4440
      Width           =   1845
   End
   Begin VB.CommandButton cmdStartVis 
      Caption         =   "Start"
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Top             =   4440
      Width           =   1725
   End
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Interval        =   25
      Left            =   240
      Top             =   10320
   End
   Begin VB.Frame fraSonique 
      Height          =   2895
      Left            =   7440
      TabIndex        =   36
      Top             =   4800
      Width           =   4935
      Begin VB.Frame fraSoniqueVisOpt 
         Caption         =   "Vis Option "
         Height          =   2535
         Left            =   120
         TabIndex        =   38
         Top             =   240
         Width           =   4695
         Begin MSComctlLib.Slider sliFFTZoom 
            Height          =   375
            Left            =   240
            TabIndex        =   39
            Top             =   360
            Width           =   1695
            _ExtentX        =   2990
            _ExtentY        =   661
            _Version        =   393216
            LargeChange     =   1
            Max             =   3
         End
         Begin MSComctlLib.Slider sliWaveZoom 
            Height          =   375
            Left            =   2400
            TabIndex        =   41
            Top             =   360
            Width           =   1695
            _ExtentX        =   2990
            _ExtentY        =   661
            _Version        =   393216
            LargeChange     =   1
            Max             =   5
            SelStart        =   1
            Value           =   1
         End
         Begin MSComctlLib.Slider sliFFTSensitivity 
            Height          =   375
            Left            =   240
            TabIndex        =   42
            Top             =   1560
            Width           =   1695
            _ExtentX        =   2990
            _ExtentY        =   661
            _Version        =   393216
            LargeChange     =   1
            Max             =   3
         End
         Begin MSComctlLib.Slider sliSlowfade 
            Height          =   375
            Left            =   2400
            TabIndex        =   43
            Top             =   1560
            Width           =   1695
            _ExtentX        =   2990
            _ExtentY        =   661
            _Version        =   393216
            Min             =   1
            Max             =   80
            SelStart        =   1
            Value           =   1
         End
         Begin VB.Label lblSlowfade 
            AutoSize        =   -1  'True
            Caption         =   "Slow Fade"
            Height          =   195
            Left            =   3000
            TabIndex        =   50
            Top             =   2040
            Width           =   750
         End
         Begin VB.Label lblFFTSensitivity 
            AutoSize        =   -1  'True
            Caption         =   "FFT  Sensitivity"
            Height          =   195
            Left            =   720
            TabIndex        =   49
            Top             =   2040
            Width           =   1080
         End
         Begin VB.Label lblWaveZoom 
            AutoSize        =   -1  'True
            Caption         =   "Wave Zoom"
            Height          =   195
            Left            =   2880
            TabIndex        =   48
            Top             =   840
            Width           =   885
         End
         Begin VB.Label lblFFTZoom 
            AutoSize        =   -1  'True
            Caption         =   "FFT Zoom"
            Height          =   195
            Left            =   840
            TabIndex        =   47
            Top             =   840
            Width           =   735
         End
         Begin VB.Label lblSlowfadeVal 
            Caption         =   "0"
            Height          =   255
            Left            =   4200
            TabIndex        =   46
            Top             =   1560
            Width           =   375
         End
         Begin VB.Label lblFFTSensitivityVal 
            Caption         =   "0"
            Height          =   255
            Left            =   2040
            TabIndex        =   45
            Top             =   1560
            Width           =   375
         End
         Begin VB.Label lblFFTZoomVal 
            Caption         =   "0"
            Height          =   255
            Left            =   2040
            TabIndex        =   44
            Top             =   360
            Width           =   375
         End
         Begin VB.Label lblWaveZoomVal 
            Caption         =   "0"
            Height          =   255
            Left            =   4200
            TabIndex        =   40
            Top             =   360
            Width           =   375
         End
      End
   End
   Begin VB.Frame fraWinamp 
      Height          =   2895
      Left            =   7440
      TabIndex        =   32
      Top             =   4800
      Width           =   4935
      Begin VB.CheckBox ckOwnDcW2 
         Caption         =   "Show Winamp2 Plugins in to Panel or GenBitmap"
         Height          =   255
         Left            =   120
         TabIndex        =   58
         Top             =   2520
         Width           =   3975
      End
      Begin VB.Frame fraWinampOpt 
         Caption         =   "Vis Option              FFT Spectrum Sensitivity"
         Height          =   735
         Left            =   120
         TabIndex        =   33
         Top             =   240
         Width           =   4695
         Begin MSComctlLib.Slider sliFFTSpectrum 
            Height          =   375
            Left            =   120
            TabIndex        =   34
            Top             =   240
            Width           =   3855
            _ExtentX        =   6800
            _ExtentY        =   661
            _Version        =   393216
            Min             =   1
            Max             =   32
            SelStart        =   1
            Value           =   1
         End
         Begin VB.Label lblFFTValue 
            Caption         =   "0"
            Height          =   255
            Left            =   4080
            TabIndex        =   35
            Top             =   360
            Width           =   495
         End
      End
   End
   Begin VB.Label lblVers 
      Caption         =   "BassVis vers."
      Height          =   255
      Left            =   7440
      TabIndex        =   37
      Top             =   4440
      Width           =   1095
   End
   Begin VB.Label lblVersion 
      Height          =   255
      Left            =   8520
      TabIndex        =   31
      Top             =   4440
      Width           =   1815
   End
   Begin VB.Label lblTime 
      AutoSize        =   -1  'True
      Caption         =   "00:00:00"
      Height          =   195
      Left            =   4560
      TabIndex        =   23
      Top             =   4920
      Width           =   630
   End
   Begin VB.Label lblTimeCap 
      Caption         =   "Time :"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   3840
      TabIndex        =   22
      Top             =   4920
      Width           =   615
   End
   Begin VB.Label lblElapsed 
      Caption         =   "00:00:00"
      Height          =   255
      Left            =   2880
      TabIndex        =   21
      Top             =   4920
      Width           =   735
   End
   Begin VB.Label lblTimeElapsed 
      Caption         =   "Time Elapsed :"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   1560
      TabIndex        =   20
      Top             =   4920
      Width           =   1335
   End
   Begin VB.Label lblPlaylist 
      Caption         =   "Playlist ..."
      Height          =   255
      Left            =   120
      TabIndex        =   19
      Top             =   4920
      Width           =   1335
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

'Form1.FRM
'--------------------------- VB 6.0 Form Module -----------------------------
' BassVis API ADD-ON Sample for Bass Audio Library
' Copyright © 2007 BrewIdeas@Emil Weiss, All Rights Reserved
'
' Author(s) of this Form: Emil Weiss
'
' Code was written in and formatted for 10pt Courier New
'----------------------------------------------------------------------------

Option Explicit

Private alist()          As String
Private PluginDir        As String
Private IndexNum         As Integer
Private MediaTitle       As String
Private StreamFile       As String
Public Stream            As Long
Private SyncEnd          As Long
Private StreamPos        As Single
Private StreamLength     As Single
Public Paused            As Boolean

'BassVis Parameter
Private mInfos           As BASSVIS_INFO
Private mExec            As BASSVIS_EXEC
Private mBase            As BASSVIS_PARAM

'TimerHandle for the RenderEvent of Sonique
Private TimerhWnd        As Long

' FullScreen Variable
Private FScreenWidth     As Integer
Private FScreenHeight    As Integer
Private FullScreen       As Boolean

Private Sub cbScreenRes_Click()

    Select Case cbScreenRes.ListIndex

    Case 0
        FScreenWidth = 320
        FScreenHeight = 240
    Case 1
        FScreenWidth = 512
        FScreenHeight = 384
    Case 2
        FScreenWidth = 640
        FScreenHeight = 480
    Case 3
        FScreenWidth = 800
        FScreenHeight = 600
    End Select

End Sub

Private Sub cbVisType_Click()

'deactivate Timer

    Timer1.Enabled = False

    'Remove CallBack
    BASSVIS_WINAMP_RemoveCallback

    If mVisHandle.Vishandle <> 0 Or mVisHandle.Kind <> 0 Then
        BASSVIS_Quit mVisHandle
        picPlgSource.Cls
    End If

    Select Case (cbVisType.ListIndex + 1)
    Case 1
        'initialize BassVis
        BASSVIS_Init BASSVISKIND_WINAMP, App.hInstance, Form1.hwnd
        PluginDir = App.Path & "\Plugins"
        fraWinamp.ZOrder 0
        'SetCallBack for PlayState
        Call BASSVIS_WINAMP_SetStateCallback(AddressOf BASSVIS_StateCallback)
    Case 2
        'initialize BassVis
        TimerhWnd = picTimerHwnd.hwnd
        'Any control that does not need its Window Procedure
        'Use TimerhWnd instead of App.hInstance for RenderTimer only Sonique
        BASSVIS_Init BASSVISKIND_SONIQUE, TimerhWnd, Form1.hwnd
        PluginDir = App.Path & "\SPlugins"
        fraSonique.ZOrder 0
    End Select

    GetPlugin cbVisType.ListIndex + 1
    Call SaveSetting(App.EXEName, "PluginType", "Kind", cbVisType.ListIndex)

End Sub

Private Sub cmbInputs_Click()

Dim it As Long
Dim i As Integer

    If (input_ > -1) Then
        input_ = cmbInputs.ListIndex
        'enable the selected input

        For i = 0 To cmbInputs.ListCount - 1
            BASS_RecordSetInput i, BASS_INPUT_OFF
        Next
        BASS_RecordSetInput input_, BASS_INPUT_ON

    End If

    it = BASS_RecordGetInput(cmbInputs.ListIndex)
    slLevel.value = LoWord(it)

End Sub

Private Sub cmdAdd_Click()

Dim vFiles As Variant
Dim lFile As Long
Dim uB    As Long

    Playlist.Clear
    lstPathList.Clear

    On Error Resume Next

        With CommonDialog1
            .filename = ""
            .CancelError = False
            .DialogTitle = "Select File(s)..."
            .flags = cdlOFNAllowMultiselect Or cdlOFNExplorer Or cdlOFNHideReadOnly
            .Filter = "All files (*.mp3*)|*.mp3*"
            .ShowOpen
            vFiles = Split(.filename, Chr$(0))

            uB = UBound(vFiles)
            If uB = 0 Then
                lstPathList.AddItem .filename
                Playlist.AddItem GetBaseName(.FileTitle)
            Else
                For lFile = 1 To uB
                    lstPathList.AddItem vFiles(0) + "\" & vFiles(lFile)
                    Playlist.AddItem GetBaseName(vFiles(lFile))
                Next
            End If
        End With
        If Playlist.ListCount <> 0 Then
            Playlist.ListIndex = 0
            Playlist.Selected(Playlist.ListIndex) = True
        End If

        cmdPrev.Enabled = True
        cmdPlay.Enabled = True
        cmdStop.Enabled = True
        cmdPause.Enabled = True
        cmdNext.Enabled = True

End Sub

Private Sub cmdConfig_Click()

    If lstPlugins.ListCount > 0 Then

        IndexNum = lstPlugins.ListIndex
        mVisHandle.Vishandle = BASSVIS_GetPluginHandle(cbVisType.ListIndex + 1, PluginDir & "\" & lstPlugins.List(IndexNum))

        If mVisHandle.Vishandle <> 0 Then
            BASSVIS_Config mVisHandle, VisModules.ListIndex
        Else
            Exit Sub
        End If
    End If

End Sub

Public Sub cmdNext_Click()

    If Playlist.ListIndex = (Playlist.ListCount - 1) Then
        Playlist.ListIndex = 0
    Else
        Playlist.ListIndex = Playlist.ListIndex + 1
    End If
    BASSVIS_SetPlayState mVisHandle, psSetPlaylistPos, Playlist.ListIndex
    PlaylistPos = Playlist.ListIndex

    Playlist.Selected(Playlist.ListIndex) = True

    cmdPlay_Click

End Sub

Public Sub cmdPause_Click()

    Paused = Not Paused
    If Paused = False Then
        If Stream <> 0 Then
            BASS_ChannelPlay Stream, False

            ' SendMessage Status Play
            BASSVIS_SetPlayState mVisHandle, psPlay
            Sleep (50)
        End If
    Else
        If Stream <> 0 Then
            BASS_ChannelPause (Stream)

            ' SendMessage Status Paused
            BASSVIS_SetPlayState mVisHandle, psPause
            Sleep (50)
        End If
    End If

End Sub

Public Sub cmdPlay_Click()

Dim nReturn As Long

    On Error Resume Next

        If Stream <> 0 Then
            BASS_ChannelStop Stream
            Stream = 0
        End If

        StreamFile = lstPathList.List(Playlist.ListIndex)
        MediaTitle = Playlist.List(Playlist.ListIndex)
        lstPathList.Selected(Playlist.ListIndex) = True

        Stream = BASS_StreamCreateFile(False, StreamFile, 0, 0, 0)

        If Stream <> 0 Then
            SyncEnd = BASS_ChannelSetSync(Stream, BASS_SYNC_END, 0, AddressOf SyncEndProc, 0)
            lblTime.Caption = GetTime(BASS_ChannelBytes2Seconds(Stream, BASS_ChannelGetLength(Stream)))

            ' play the filestream
            BASS_ChannelPlay Stream, False
            BASSVIS_SetPlayState mVisHandle, psPlay

        End If

        Select Case mVisHandle.Kind
        Case BASSVISKIND_WINAMP
            If VisWindowHandle <> 0 Then
                ' send the last active Playlist index to visplugin
                BASSVIS_SetPlayState mVisHandle, psSetPlaylistPos, PlaylistPos

                ' Send Status Play
                BASSVIS_SetPlayState mVisHandle, psPlay
                nReturn = BASSVIS_SetPlayState(mVisHandle, psIsPlaying)

                ' Check Play Status
                If nReturn = psPlay Then
                    Timer1.Enabled = True
                Else
                    Timer1.Enabled = False
                End If

                If (mVisHandle.Vishandle <> 0) And (optDevice.value = False) Then
                    BASSVIS_RenderChannel mVisHandle, Stream
                End If

            Else
                Timer1.Enabled = True
            End If
        Case BASSVISKIND_SONIQUE

            If (mVisHandle.Vishandle <> 0) And (optDevice.value = False) Then
                BASSVIS_RenderChannel mVisHandle, Stream
            End If
            Timer1.Enabled = True
            
        End Select

    On Error GoTo 0

End Sub

Public Sub cmdPrev_Click()

    If Playlist.ListIndex = 0 Then
        Playlist.ListIndex = Playlist.ListCount - 1
    Else
        Playlist.ListIndex = Playlist.ListIndex - 1
    End If
    PlaylistPos = Playlist.ListIndex

    BASSVIS_SetPlayState mVisHandle, psSetPlaylistPos, Playlist.ListIndex

    Playlist.Selected(Playlist.ListIndex) = True

    cmdPlay_Click

End Sub

Private Sub cmdResize_Click()

    If Me.Width = 7470 Then
        Me.Width = 12615
        cmdResize.Caption = "<<"
    Else
        Me.Width = 7470
        cmdResize.Caption = ">>"
    End If

End Sub

Private Sub cmdStartVis_Click()

Dim Puffer        As String
Dim Pufferlänge   As Long
Dim Counter       As Integer
Dim IsFree        As Boolean

' check if we have something selected on the list

    If (lstPlugins.ListIndex >= 0) And (lstPlugins.ListIndex < lstPlugins.ListCount) Then
        If mVisHandle.Vishandle <> 0 Then
            Timer1.Enabled = False

            If GenVisible = True Then
                frmGen.Hide
                Unload frmGen
                Set frmGen = Nothing
            End If

            If mVisHandle.Vishandle <> 0 Then
                BASSVIS_Free mVisHandle
                Do Until (IsFree = True) Or (Counter = 250)
                    IsFree = BASSVIS_IsFree(mVisHandle)
                    DoEvents
                    Counter = Counter + 1
                Loop
                IsFree = False
                mVisHandle.Vishandle = 0
            End If
            picPlgSource.Cls
        End If

        Select Case (cbVisType.ListIndex + 1)
        Case 1
            ' create our new plugin
            If (optPicBox.value) Or (optGen.value) = True Then
                With mExec
                    .AMP_SON_Pluginfile = PluginDir & "\" & lstPlugins.List(IndexNum)
                    .AMP_Moduleindex = VisModules.ListIndex
                    .AMP_UseOwnW1 = 1
                    .AMP_UseOwnW2 = ckOwnDcW2.value
                End With

                mBase.Kind = cbVisType.ListIndex + 1
                BASSVIS_ExecutePlugin mExec, mBase

            ElseIf optDefault.value = True Then

                With mExec
                    .AMP_SON_Pluginfile = PluginDir & "\" & lstPlugins.List(IndexNum)
                    .AMP_Moduleindex = VisModules.ListIndex
                    .AMP_UseOwnW1 = 0
                    .AMP_UseOwnW2 = 0
                End With

                mBase.Kind = cbVisType.ListIndex + 1
                BASSVIS_ExecutePlugin mExec, mBase

            End If

            ' new vishandle
            mVisHandle.Vishandle = mBase.Vishandle

            If mVisHandle.Vishandle <> 0 Then

                ' Get HWND from Winamp Dummy Window
                VisWindowHandle = mBase.VisWinhandle

                ' send the last active Playlist index to visplugin
                BASSVIS_SetPlayState mVisHandle, psSetPlaylistPos, PlaylistPos

                ' SendMessage Playing Status
                BASSVIS_SetPlayState mVisHandle, psPlay

                ' Check IsPlaying
                BASSVIS_SetPlayState mVisHandle, psIsPlaying

                If optPicBox.value = True Then

                    hWndGen = mBase.VisGenWinhandle

                    If hWndGen <> 0 Then
                        BASSVIS_SetVisPort mVisHandle, _
                                           hWndGen, _
                                           picPlgSource.hwnd, _
                                           0, _
                                           0, _
                                           picPlgSource.ScaleWidth, _
                                           picPlgSource.ScaleHeight
                    End If

                End If

                If optGen.value = True Then

                    hWndGen = mBase.VisGenWinhandle

                    If hWndGen <> 0 Then

                        'Caption des Plugin auslesen
                        Pufferlänge = GetWindowTextLength(hWndGen) + 1
                        Puffer = Space$(Pufferlänge)
                        Pufferlänge = GetWindowText(hWndGen, Puffer, Pufferlänge)
                        'Form laden
                        Load frmGen
                        'String übergeben
                        frmGen.picTopText.Width = (frmGen.GetBitArray(Left$(Puffer$, Pufferlänge)) * 15) + 75
                        'Form Gen resizen
                        frmGen.Form_Resize
                        'Plugin auf die weite/höhe von 'frmGen.PicBack' anpassen
                        BASSVIS_SetVisPort mVisHandle, hWndGen, _
                                           frmGen.PicBack.hwnd, _
                                           0, _
                                           0, _
                                           frmGen.PicBack.ScaleWidth, _
                                           frmGen.PicBack.ScaleHeight

                        'Skin anzeigen
                        frmGen.Show
                    End If
                End If
            End If
            sliFFTSpectrum.value = 16

            If optDevice.value = True Then
                BASS_RecordInit 0
                BASSVIS_StartRecord mVisHandle
            End If

            If Stream <> 0 And optfile.value = True Then
                BASSVIS_RenderChannel mVisHandle, Stream
            End If
            Timer1.Enabled = True

        Case 2

            If optPicBox.value = True Then
                With mExec
                    .AMP_SON_Pluginfile = lstPlgPath.List(IndexNum) + lstPlugins.List(IndexNum)
                    .SON_ConfigFile = PluginDir & "\" & "vis.ini"
                    .SON_Flags = 0
                    .SON_PaintHandle = picPlgSource.hwnd
                    .Left = 0
                    .Top = 0
                    .Width = picPlgSource.Width / 15
                    .Height = picPlgSource.Height / 15
                End With

                mBase.Kind = BASSVISKIND_SONIQUE
                BASSVIS_ExecutePlugin mExec, mBase

                mVisHandle.Vishandle = mBase.Vishandle
                sliSlowfade.value = 2
            End If

            If optGen.value = True Then
                'only retrive the handle
                With mExec
                    .AMP_SON_Pluginfile = lstPlgPath.List(IndexNum) + lstPlugins.List(IndexNum)
                    .SON_ConfigFile = PluginDir & "\" & "vis.ini"
                    .SON_Flags = BASS_VIS_NOINIT
                End With

                mBase.Kind = BASSVISKIND_SONIQUE
                BASSVIS_ExecutePlugin mExec, mBase

                mVisHandle.Vishandle = mBase.Vishandle

                hWndGen = mVisHandle.Vishandle

                If hWndGen <> 0 Then

                    'Caption des Plugin auslesen
                    Puffer = VisModules.List(VisModules.ListIndex)
                    Pufferlänge = Len(Puffer)
                    'Form laden
                    Load frmGen
                    'String übergeben
                    frmGen.picTopText.Width = (frmGen.GetBitArray(Left$(Puffer$, Pufferlänge)) * 15) + 75
                    'Form Gen resizen
                    frmGen.Form_Resize

                    'Plugin auf die weite/höhe von 'frmGen.PicBack' anpassen
                    With mExec
                        .AMP_SON_Pluginfile = lstPlgPath.List(IndexNum) + lstPlugins.List(IndexNum)
                        .SON_ConfigFile = PluginDir & "\" & "vis.ini"
                        .SON_Flags = 0
                        .SON_PaintHandle = frmGen.PicBack.hwnd
                        .Left = 0
                        .Top = 0
                        .Width = frmGen.PicBack.ScaleWidth
                        .Height = frmGen.PicBack.ScaleHeight
                    End With

                    mBase.Kind = BASSVISKIND_SONIQUE
                    BASSVIS_ExecutePlugin mExec, mBase

                    BASSVIS_SetVisPort mBase, hWndGen, _
                                       frmGen.PicBack.hwnd, _
                                       0, _
                                       0, _
                                       frmGen.PicBack.ScaleWidth, _
                                       frmGen.PicBack.ScaleHeight

                    mVisHandle.Vishandle = mBase.Vishandle

                    sliSlowfade.value = 2
                    'Skin anzeigen
                    frmGen.Show
                End If
            End If

            If mVisHandle.Vishandle <> 0 Then
                If optDevice.value = True Then
                    BASS_RecordInit 0
                    BASSVIS_StartRecord mVisHandle
                End If

                If Stream <> 0 And optfile.value = True Then
                    BASSVIS_RenderChannel mVisHandle, Stream
                End If

                Timer1.Enabled = True
            End If

        End Select

    End If

End Sub

Public Sub cmdStop_Click()

Dim nReturn As Long

' Stop stream when available

    If Stream <> 0 Then
        BASS_ChannelStop (Stream)
    End If

    ' SendMessage Status Stop
    BASSVIS_SetPlayState mVisHandle, psStop
    Sleep (50)

End Sub

Public Function FileExists(ByVal filename As String) As Boolean

'check if exist file

    On Local Error Resume Next
        FileExists = (Dir$(filename) <> "")

End Function

Private Sub Form_Load()

Dim BassPath    As String
Dim BassVisPath As String
Dim c           As Integer

    Me.Width = 7470
    Me.Height = 9735

    'Setze den Pfad zum BassPath
    BassPath = "%Path%;" & App.Path & "\BassLib"
    SetEnvironmentVariable "Path", BassPath

    'Überprüfe ob "bass.dll" existiert
    If FileExists(RPP(App.Path) & "\BassLib\bass.dll") = False Then
        MsgBox "BASS.DLL does not exists", vbCritical, "BASS.DLL"
        End
    End If

    ' check the correct BASS was loaded
    If (HiWord(BASS_GetVersion) <> BASSVERSION) Then
        MsgBox "Falsche version der BASS.DLL wurde geladen", vbCritical
        End
    End If

    'Setze den Pfad zu den AddOns
    BassVisPath = "%Path%;" & App.Path & "\BassADDOn"
    SetEnvironmentVariable "Path", BassVisPath

    'Überprüfe "bass_Vis.dll" ob sie existiert
    If Not FileExists(RPP(App.Path) & "\BassADDOn\bass_Vis.dll") Then
        MsgBox "BASS_Vis.DLL existiert nicht!", vbCritical, "BASS_Vis.DLL"
        End
    End If

    'Load Default Plugin Kind
    mVisHandle.Kind = GetSetting(App.EXEName, "PluginType", "Kind", 1)

    'Setze Record and Ausgangs Devices (Default wird gesetzt)
    If (BASS_RecordInit(0) = 0) Or (BASS_Init(1, 44100, 0, lstPathList.hwnd, 0) = 0) Then
        MsgBox "Can't initialize device", vbCritical, "BASS.DLL"
        End
    Else
        'get list of inputs
        input_ = -1
        Do While BASS_RecordGetInputName(c)
            cmbInputs.AddItem VBStrFromAnsiPtr(BASS_RecordGetInputName(c))
            If (BASS_RecordGetInput(c) And BASS_INPUT_OFF) = 0 Then
                cmbInputs.ListIndex = c
                input_ = c
            End If
            c = c + 1
        Loop
    End If

    'Get Version of BassVis
    lblVersion.Caption = BASSVIS_GetVersion

    ' find avaiable Plugins
    If mVisHandle.Kind < 0 Then mVisHandle.Kind = 0
    cbVisType.ListIndex = mVisHandle.Kind

    cbScreenRes.ListIndex = 0

End Sub

Private Sub Form_QueryUnload(Cancel As Integer, _
                             UnloadMode As Integer)

    Call SaveSetting(App.EXEName, "PluginType", "Kind", cbVisType.ListIndex)

    Unload Me

End Sub

Private Sub Form_Unload(Cancel As Integer)

'Timer disabled

    Timer1.Enabled = False
    If GenVisible Then
        Unload frmGen
        Set frmGen = Nothing
    End If

    'remove BassVis from memory
    'and free all resources
    BASSVIS_Quit mVisHandle
    BASS_RecordFree
    BASS_Free

End Sub

Private Sub GetPlugin(ByVal index As Long)

Dim IntI    As Integer
Dim flist   As String
Dim uB      As Integer

' clear plugin list

    lstPlugins.Clear

    ' clear module list
    VisModules.Clear

    ' clear Plugin info
    Descript.Text = vbNullString

    Select Case index
    Case BASSVISKIND_WINAMP
        ' find out vis plugins
        flist = VBStrFromAnsiPtr(BASSVIS_FindPlugins( _
                cbVisType.ListIndex + 1, _
                PluginDir, _
                BASS_VIS_FIND_WINAMP Or _
                BASS_VIS_FIND_RECURSIVE))

        alist = Split(flist, ",")

        If flist > "" Then
            uB = UBound(alist)
            For IntI = 0 To uB
                lstPlugins.AddItem GetFileName(alist(IntI))
            Next

            If lstPlugins.ListCount > 0 Then
                lstPlugins.ListIndex = 0

                ' Get Plugin Information
                GetPluginInfo index
            Else
                Descript.Text = vbNullString
                VisModules.ListIndex = 0
            End If
        End If

    Case BASSVISKIND_SONIQUE

        ' find out vis plugins
        flist = VBStrFromAnsiPtr(BASSVIS_FindPlugins( _
                cbVisType.ListIndex + 1, _
                PluginDir, _
                BASS_VIS_FIND_SONIQUE Or _
                BASS_VIS_FIND_RECURSIVE))

        alist = Split(flist, ",")

        If flist > "" Then
            uB = UBound(alist)
            For IntI = 0 To uB
                If LenB(alist(IntI)) > 2 Then
                    lstPlugins.AddItem GetFileName(alist(IntI))
                    lstPlgPath.AddItem GetPath(alist(IntI))
                End If
            Next

            If lstPlugins.ListCount > 0 Then
                lstPlugins.ListIndex = 0

                ' Get Plugin Information
                GetPluginInfo index
            Else
                Descript.Text = vbNullString
                VisModules.ListIndex = 0
            End If
        End If

    End Select

End Sub

Private Sub GetPluginInfo(ByVal index As Long)

Dim Pluginname     As String
Dim PlgDescription As String
Dim NumModule      As Integer
Dim NumPresets     As Integer
Dim IntI           As Integer
Dim uB             As Integer

    mVisHandle.Kind = index
    IndexNum = lstPlugins.ListIndex

    ' clear module list
    VisModules.Clear

    ' clear Plugin info
    Descript.Text = vbNullString

    Select Case index
    Case 1

        mVisHandle.Vishandle = BASSVIS_GetPluginHandle(cbVisType.ListIndex + 1, PluginDir & "\" & lstPlugins.List(IndexNum))
        NumModule = BASSVIS_GetModulePresetCount(mVisHandle, PluginDir & "\" & lstPlugins.List(IndexNum))
        Pluginname = VBStrFromAnsiPtr(BASSVIS_GetPluginName(mVisHandle))

        If NumModule = 0 Then
            Exit Sub
        End If

        Descript.Text = Pluginname

        With VisModules
            uB = (NumModule - 1)
            For IntI = 0 To uB
                .AddItem VBStrFromAnsiPtr(BASSVIS_GetModulePresetName(mVisHandle, IntI, PluginDir & "\" & lstPlugins.List(IndexNum))), IntI
            Next
        End With

        If NumModule > 0 Then
            VisModules.Selected(0) = True
        End If

        If Stream <> 0 And NumModule = 1 Then
            cmdStartVis_Click
        End If

    Case 2

        Descript.Text = "Avaiable Module"
        With mExec
            .AMP_SON_Pluginfile = lstPlgPath.List(IndexNum) + lstPlugins.List(IndexNum)
            .SON_ConfigFile = PluginDir & "\" & "vis.ini"
            .SON_Flags = BASS_VIS_NOINIT
        End With

        mBase.Kind = BASSVISKIND_SONIQUE
        BASSVIS_ExecutePlugin mExec, mBase

        mVisHandle.Vishandle = mBase.Vishandle

        With VisModules
            .AddItem VBStrFromAnsiPtr(BASSVIS_GetPluginName(mVisHandle))
        End With

        VisModules.ListIndex = 0
        VisModules.Selected(0) = True

        If Stream <> 0 Or (optDevice.value = True) Then
            cmdStartVis_Click
        End If

    End Select

End Sub

Public Function GetTime(ByVal seconds As Long) As String

Dim hour As Single
Dim min As Single
Dim sec As Single

    hour = seconds / 60 / 60
    sec = seconds Mod 60
    min = (hour - Int(hour)) * 60

    GetTime = Format$(Int(hour), "00") & ":" & Format$(Int(min), "00") & ":" & Format$(Int(sec), "00")

End Function

Private Sub lstPlugins_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)

    GetPluginInfo cbVisType.ListIndex + 1

End Sub

Public Sub MusikEnd()

    If ckRandom.value = 1 Then
        If (Playlist.ListIndex = Playlist.ListCount - 1) Then
            Playlist.ListIndex = 0
            Playlist.Selected(Playlist.ListIndex) = True

            ' play filestream
            cmdPlay_Click
        Else
            Playlist.ListIndex = Playlist.ListIndex + 1
            Playlist.Selected(Playlist.ListIndex) = True

            ' play filestream
            cmdPlay_Click
        End If
    Else
        ' stop filestream
        cmdStop_Click
        BASS_ChannelRemoveSync Stream, SyncEnd
    End If

End Sub

Private Sub optDefault_Click()

' start new Plugin

    cmdStartVis_Click

End Sub

Private Sub optDevice_Click()

    If mVisHandle.Vishandle <> 0 Then
        BASS_RecordInit (0)
        BASSVIS_StartRecord mVisHandle
    End If

End Sub

Private Sub optfile_Click()

    If Stream <> 0 Then
        BASSVIS_RenderChannel mVisHandle, Stream
    End If

End Sub

Private Sub optGen_Click()

' start new Plugin

    cmdStartVis_Click

End Sub

Private Sub optPicBox_Click()

' start new Plugin

    cmdStartVis_Click

End Sub

Private Sub picPlgSource_DblClick()

    FullScreen = Not FullScreen
    Select Case (cbVisType.ListIndex + 1)

    Case 2
        BASSVIS_SetFullscreen mVisHandle, _
                              picPlgSource.hwnd, _
                              Me.hwnd, _
                              7560, _
                              240, _
                              328, _
                              272, _
                              FullScreen, _
                              FScreenWidth, _
                              FScreenHeight

    End Select

End Sub

Private Sub picPlgSource_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
    
    Select Case (cbVisType.ListIndex + 1)

    Case 2
        BASSVIS_SONIQUEVIS_Clicked mVisHandle.Vishandle, x, y
    End Select

End Sub

Private Sub Playlist_DblClick()

    Timer1.Enabled = False
    If Playlist.ListCount <> 0 Then
        BASSVIS_SetPlayState mVisHandle, psSetPlaylistPos, Playlist.ListIndex
        PlaylistPos = Playlist.ListIndex
        ' play filestream
        cmdPlay_Click
    End If

End Sub

Public Function RPP(ByVal fp As String) As String

    RPP = IIf(Mid$(fp, Len(fp), 1) <> "\", fp & "\", fp)

End Function

Private Sub sliFFTSensitivity_Change()

    If mVisHandle.Kind = BASSVISKIND_SONIQUE Then
        BASSVIS_SetOption mVisHandle, BASS_SONIQUEVIS_CONFIG_FFTAMP, CLng(sliFFTSensitivity.value)
        lblFFTSensitivityVal.Caption = CLng(sliFFTSensitivity.value) * 32
    End If

End Sub

Private Sub sliFFTSensitivity_Scroll()

    If mVisHandle.Kind = BASSVISKIND_SONIQUE Then
        BASSVIS_SetOption mVisHandle, BASS_SONIQUEVIS_CONFIG_FFTAMP, CLng(sliFFTSensitivity.value)
        lblFFTSensitivityVal.Caption = CLng(sliFFTSensitivity.value) * 32
    End If

End Sub

Private Sub sliFFTSpectrum_Change()

    If mVisHandle.Kind = BASSVISKIND_WINAMP Then
        BASSVIS_SetOption mVisHandle, BASS_WINAMPVIS_CONFIG_FFTAMP, CLng(sliFFTSpectrum.value)
        lblFFTValue.Caption = CLng(sliFFTSpectrum.value) * 32
    End If

End Sub

Private Sub sliFFTSpectrum_Scroll()

    If mVisHandle.Kind = BASSVISKIND_WINAMP Then
        BASSVIS_SetOption mVisHandle, BASS_WINAMPVIS_CONFIG_FFTAMP, CLng(sliFFTSpectrum.value)
        lblFFTValue.Caption = CLng(sliFFTSpectrum.value) * 32
    End If

End Sub

Private Sub sliFFTZoom_Change()

    If mVisHandle.Kind = BASSVISKIND_SONIQUE Then
        BASSVIS_SetOption mVisHandle, BASS_SONIQUEVIS_CONFIG_FFT_SKIPCOUNT, CLng(sliFFTZoom.value)
        lblFFTZoomVal.Caption = sliFFTZoom.value
    End If

End Sub

Private Sub sliFFTZoom_Scroll()

    If mVisHandle.Kind = BASSVISKIND_SONIQUE Then
        BASSVIS_SetOption mVisHandle, BASS_SONIQUEVIS_CONFIG_FFT_SKIPCOUNT, CLng(sliFFTZoom.value)
        lblFFTZoomVal.Caption = sliFFTZoom.value
    End If

End Sub

Private Sub sliSlowfade_Change()

    If mVisHandle.Kind = BASSVISKIND_SONIQUE Then
        BASSVIS_SetOption mVisHandle, BASS_SONIQUEVIS_CONFIG_SLOWFADE, CLng(sliSlowfade.value)
        lblSlowfadeVal.Caption = sliSlowfade.value
    End If

End Sub

Private Sub sliSlowfade_Scroll()

    If mVisHandle.Kind = BASSVISKIND_SONIQUE Then
        BASSVIS_SetOption mVisHandle, BASS_SONIQUEVIS_CONFIG_SLOWFADE, CLng(sliSlowfade.value)
        lblSlowfadeVal.Caption = sliSlowfade.value
    End If

End Sub

Private Sub sliWaveZoom_Change()

    If mVisHandle.Kind = BASSVISKIND_SONIQUE Then
        BASSVIS_SetOption mVisHandle, BASS_SONIQUEVIS_CONFIG_WAVE_SKIPCOUNT, CLng(sliWaveZoom.value)
        lblWaveZoomVal.Caption = sliWaveZoom.value
    End If

End Sub

Private Sub sliWaveZoom_Scroll()

    If mVisHandle.Kind = BASSVISKIND_SONIQUE Then
        BASSVIS_SetOption mVisHandle, BASS_SONIQUEVIS_CONFIG_WAVE_SKIPCOUNT, CLng(sliWaveZoom.value)
        lblWaveZoomVal.Caption = sliWaveZoom.value
    End If

End Sub

Private Sub slLevel_Change()

    BASSVIS_SetOption mVisHandle, cmbInputs.ListIndex, BASS_INPUT_LEVEL Or slLevel.value
    lblLevel.Caption = slLevel.value

End Sub

Private Sub slLevel_Scroll()

    BASS_RecordSetInput cmbInputs.ListIndex, BASS_INPUT_LEVEL Or slLevel.value
    lblLevel.Caption = slLevel.value

End Sub

Private Sub Timer1_Timer()

    On Error Resume Next

        If Stream <> 0 Then
            ' format position HH:MM:SS write in to lblTime
            lblElapsed.Caption = GetTime(BASS_ChannelBytes2Seconds(Stream, BASS_ChannelGetPosition(Stream)))

            ' get stream position from bass
            StreamPos = BASS_ChannelBytes2Seconds(Stream, BASS_ChannelGetPosition(Stream))

            ' get stream length from bass
            StreamLength = BASS_ChannelBytes2Seconds(Stream, BASS_ChannelGetLength(Stream))
        End If

        'Set MediaInfo
        Select Case (cbVisType.ListIndex + 1)

        Case BASSVISKIND_WINAMP
            If (MediaTitle <> "") And (mVisHandle.Vishandle <> 0) Then

                ' set listindex and point for MediaTitle
                ' any plugins not work when not use this with Title
                With mInfos
                    .SongTitle = (PlaylistPos + 1) & ". " & MediaTitle
                    .Songfile = StreamFile
                    .pos = 1000 * StreamPos
                    .len = StreamLength
                    .PlaylistPos = PlaylistPos
                    .Playlistlen = Playlist.ListCount
                End With

                BASSVIS_SetInfo mVisHandle, mInfos

            End If

        End Select

    On Error GoTo 0

End Sub

':) Ulli's VB Code Formatter V2.19.5 (2007-Aug-01 17:17)  Decl: 36  Code: 1062  Total: 1098 Lines
':) CommentOnly: 87 (7,9%)  Commented: 0 (0%)  Empty: 290 (26,4%)  Max Logic Depth: 6
