VERSION 5.00
Begin VB.Form frmGen 
   BackColor       =   &H00808080&
   BorderStyle     =   0  'Kein
   Caption         =   "Gen Bitmap Test"
   ClientHeight    =   4080
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   4770
   Icon            =   "Gen.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   ScaleHeight     =   4080
   ScaleWidth      =   4770
   ShowInTaskbar   =   0   'False
   Begin VB.PictureBox picTopF 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'Kein
      Height          =   300
      Left            =   600
      ScaleHeight     =   300
      ScaleWidth      =   375
      TabIndex        =   2
      ToolTipText     =   "picTopF"
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox picTopTextSrc 
      AutoRedraw      =   -1  'True
      BackColor       =   &H0000FFFF&
      BorderStyle     =   0  'Kein
      Height          =   105
      Left            =   3000
      ScaleHeight     =   105
      ScaleWidth      =   375
      TabIndex        =   14
      ToolTipText     =   "picTopTextSrc"
      Top             =   2520
      Width           =   375
   End
   Begin VB.PictureBox picTopText 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'Kein
      Height          =   300
      Left            =   1080
      ScaleHeight     =   300
      ScaleWidth      =   375
      TabIndex        =   4
      ToolTipText     =   "picTopText"
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox PicBack 
      BackColor       =   &H00000000&
      BorderStyle     =   0  'Kein
      Height          =   615
      Left            =   360
      ScaleHeight     =   41
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   137
      TabIndex        =   15
      Top             =   2520
      Width           =   2055
   End
   Begin VB.PictureBox picTopM 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'Kein
      Height          =   300
      Left            =   1560
      ScaleHeight     =   300
      ScaleWidth      =   375
      TabIndex        =   12
      ToolTipText     =   "picTopM"
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox picClose 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'Kein
      DrawStyle       =   5  'Transparent
      Height          =   135
      Left            =   2760
      ScaleHeight     =   135
      ScaleWidth      =   135
      TabIndex        =   8
      ToolTipText     =   "picClose"
      Top             =   2520
      Width           =   135
   End
   Begin VB.PictureBox picFormResize 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'Kein
      DrawStyle       =   5  'Transparent
      Height          =   210
      Left            =   4200
      ScaleHeight     =   210
      ScaleWidth      =   210
      TabIndex        =   11
      Top             =   3600
      Width           =   210
   End
   Begin VB.PictureBox picBottomR 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'Kein
      Height          =   210
      Left            =   2520
      ScaleHeight     =   210
      ScaleWidth      =   1875
      TabIndex        =   10
      Top             =   3240
      Width           =   1875
   End
   Begin VB.PictureBox picBorderL 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'Kein
      Height          =   435
      Left            =   120
      ScaleHeight     =   435
      ScaleWidth      =   165
      TabIndex        =   9
      Top             =   2640
      Width           =   165
   End
   Begin VB.PictureBox picBottomM 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'Kein
      Height          =   210
      Left            =   2040
      ScaleHeight     =   210
      ScaleWidth      =   375
      TabIndex        =   7
      Top             =   3240
      Width           =   375
   End
   Begin VB.PictureBox picBottomL 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'Kein
      Height          =   210
      Left            =   120
      ScaleHeight     =   210
      ScaleWidth      =   1875
      TabIndex        =   6
      Top             =   3240
      Width           =   1875
   End
   Begin VB.PictureBox picTopL 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'Kein
      Height          =   300
      Left            =   120
      ScaleHeight     =   300
      ScaleWidth      =   375
      TabIndex        =   3
      ToolTipText     =   "picTopL"
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox picMap 
      Appearance      =   0  '2D
      AutoRedraw      =   -1  'True
      BackColor       =   &H80000005&
      BorderStyle     =   0  'Kein
      ClipControls    =   0   'False
      ForeColor       =   &H80000008&
      Height          =   1635
      Left            =   120
      Picture         =   "Gen.frx":08CA
      ScaleHeight     =   1635
      ScaleWidth      =   2910
      TabIndex        =   1
      Top             =   120
      Visible         =   0   'False
      Width           =   2910
   End
   Begin VB.PictureBox picBorderR 
      Appearance      =   0  '2D
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'Kein
      ForeColor       =   &H80000008&
      Height          =   435
      Left            =   4320
      ScaleHeight     =   420
      ScaleMode       =   0  'Benutzerdefiniert
      ScaleWidth      =   120
      TabIndex        =   0
      Top             =   2760
      Width           =   120
   End
   Begin VB.PictureBox picTopC 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'Kein
      Height          =   300
      Left            =   2520
      ScaleHeight     =   300
      ScaleWidth      =   375
      TabIndex        =   5
      ToolTipText     =   "picTopC"
      Top             =   2160
      Width           =   375
   End
   Begin VB.PictureBox picTopStretch 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'Kein
      Height          =   300
      Left            =   2040
      ScaleHeight     =   300
      ScaleWidth      =   375
      TabIndex        =   13
      ToolTipText     =   "picTopR"
      Top             =   2160
      Width           =   375
   End
End
Attribute VB_Name = "frmGen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

'frmGen.FRM
'--------------------------- VB 6.0 Form Module -----------------------------
' BassVis API ADD-ON Sample for Bass Audio Library
' Copyright © 2007 BrewIdeas@Emil Weiss, All Rights Reserved
'
' Author(s) of this Form: Emil Weiss
'
' Code was written in and formatted for 10pt Courier New
'----------------------------------------------------------------------------

Option Explicit

Private i    As Integer
Private picW As Integer

Private Prg As String
Private Sect As String
Private OptDefPath As String

Private mFRszNWSO As cFResizeNWSO

Sub ChangePlayList()

    picBottomM_Resize
    picTopText_Resize
    picTopStretch_Resize

End Sub

Private Sub Form_Load()

    OptDefPath = App.Path & "\Bitmap"

    Me.Move Val(GetSetting(App.EXEName, "config", "GenLeft", Me.Left)), _
            Val(GetSetting(App.EXEName, "config", "GenTop", Me.Top))

    GenVisible = True
    Call LoadSkin

    FormMove.InitTPP
    Set mFRszNWSO = New_cFResizeNWSO(picFormResize, Me)
    
    StandardSize

    WizFormat
    Call SetWindowPos(Me.hwnd, _
                      HWND_TOPMOST, _
                      0, _
                      0, _
                      0, _
                      0, _
                      SWP_NOACTIVATE Or _
                      SWP_NOSIZE Or SWP_NOMOVE _
                      )

    picTopTextSrc.BackColor = GetPixel(picTopText.hDC, 0, 5)

    
End Sub

Public Sub Form_Resize()

Dim myVisHandle As BASSVIS_PARAM

    If GenVisible Then

        Call PicBack.Move(165, _
                          300, _
                          Int((Me.Width - picBorderR.Width - 165) / 15) * 15, _
                          Int((Me.Height - 510) / 15) * 15 _
                          )
        
        If mVisHandle.Kind = BASSVISKIND_WINAMP Then
            myVisHandle.Vishandle = PicBack.hwnd
            myVisHandle.Kind = (Form1.cbVisType.ListIndex + 1)
            
            If mVisHandle.Vishandle <> 0 Then
                BASSVIS_Resize myVisHandle, 0, 0, PicBack.ScaleWidth, PicBack.ScaleHeight
            End If
        Else
            If mVisHandle.Kind = BASSVISKIND_SONIQUE Then
                If mVisHandle.Vishandle <> 0 Then
                    BASSVIS_Resize mVisHandle, 0, 0, PicBack.ScaleWidth, PicBack.ScaleHeight
                End If
            End If
        End If

        picTopC.Move Me.Width - 375, 0
        picClose.Move Me.Width - 180, 30, 135, 135

        picTopText.Move Int((Me.Width / 2) - Int(picTopText.Width / 2)), 0, picTopText.Width, 300
        picTopTextSrc.Move Int((Me.Width / 2) - Int(picTopTextSrc.Width / 2)), picTopText.Top + 60

        picTopL.Move 0, 0

        picTopStretch.Move 375, 0, picTopC.Left, 300
        picTopF.Move (picTopText.Left - 375), 0, 375, 300
        picTopM.Move picTopText.Left + picTopText.Width, 0, 375, 300
        picBottomL.Move 0, (Me.Height - 210)
        picBottomR.Move Me.Width - 1875, Me.Height - 210, 1875, 210
        picFormResize.Move (Me.Width - 210), (Me.Height - 210)


        picBorderL.Move 0, 300, 165, Me.Height - 510
        Call StretchBlt(picBorderL.hDC, _
                        0, _
                        0, _
                        11, _
                        Int((Me.Height - 510) / 15), _
                        picMap.hDC, _
                        127, _
                        42, _
                        11, _
                        29, _
                        SRCCOPY _
                        )
        picBorderL.Refresh
        picBorderR.Move (Me.Width - 120), 300, 120, Me.Height - 510
        Call StretchBlt(picBorderR.hDC, _
                        0, _
                        0, _
                        8, _
                        Int((Me.Height - 510) / 15), _
                        picMap.hDC, _
                        139, _
                        42, _
                        8, _
                        29, _
                        SRCCOPY _
                        )

        picBottomM.Move picBottomL.Width, Me.Height - 210, Me.Width - 1875, 210

    End If
    
    SaveSetting App.EXEName, "config", "GenSize", Str$(Me.Width) & "," & Str$(Me.Height)
    SaveSetting App.EXEName, "config", "GenLeft", Me.Left
    SaveSetting App.EXEName, "config", "GenTop", Me.Top

End Sub

Private Sub Form_Unload(Cancel As Integer)

    GenVisible = False
    
End Sub

Public Function GetBitArray(StrView As String) As Single

Dim IntI      As Integer       'Zähler
Dim StrPosX   As String        'X Position im Bitmap
Dim StrPosW   As String        'Weite des Buchstaben
Dim IntPos    As Long          'Zähler für die Buchstabenweite

Dim DelemiterCol As OLE_COLOR  'Delemiter als Farbe
Dim IntDelPos As Integer       'Aktuelle Delemiter Position
Dim ColFound  As Boolean       'Farbe gefunden, ergebnis = Buchstabenweite
Dim BWidth    As Variant       'Resultat der gefundenen Buchstabenweiten Spliten
Dim PosX      As Variant       '
Dim NewPos    As Long
Dim StrS      As String
Dim IntX      As Integer
Dim AsciiCode As Integer       'Alphabet zeichensatz prüfen

'******************** Schleife zum ermitteln der Buchstabenweite *********************
'/////////////////////////////////////////////////////////////////////////////////////
'Ermitteln der Delemiter Farbe
    
    On Error Resume Next
    DelemiterCol = GetPixel(picMap.hDC, 0, 88)

    'Schleife durchlaufen bis 26* die Delemiter Farbe gefunden wurde
    For IntI = 1 To picMap.ScaleWidth
        'Raus hier wenn Farbe 26* gefunden
        If IntDelPos = 26 Then Exit For
        'Aktuelle Position der Buchstabenweite um  eins erhöhen
        IntPos = IntPos + 1
        'Wenn aktuelle position im Bitmap die gleiche Farbe
        'enthält wie DelemiterCol ..
        If GetPixel(picMap.hDC, IntI, 88) = DelemiterCol Then
            If IntDelPos <= 24 Then
                'Position im StringArray addieren und Delemiter komma anhängen
                StrPosX = StrPosX & IntI & ","
            Else
                'Letze Position im StringArray addieren ohne Delemiter
                StrPosX = StrPosX & IntI
            End If
            'Zähler für Farbe um eins erhöhen
            IntDelPos = IntDelPos + 1
            'Farbe gefunden
            ColFound = True
        End If
        'wenn Farbe gefunden
        If ColFound Then
            'weite des Buchstaben im Array StrPosW speichern
            If IntDelPos <= 25 Then
                StrPosW = StrPosW & (IntPos - 1) & ","
            Else
                StrPosW = StrPosW & (IntPos - 1)
            End If
            'Buchstabenweite löschen
            IntPos = 0
        End If
        'Farbe gefunden zurück setzen
        ColFound = False
    Next IntI

    BWidth = Split(StrPosW, ",", Len(StrPosW), vbTextCompare)
    PosX = Split(StrPosX, ",", Len(StrPosX), vbTextCompare)

    For IntI = 0 To Len(StrView) - 1

        AsciiCode = Asc(UCase$(Mid$(StrView, IntI + 1, 1)))

        If (AsciiCode = &H20) Or (AsciiCode = &H0) Then
            IntX = IntX + 5
        ElseIf (AsciiCode >= &H41) And (AsciiCode <= &H5A) Then
            IntX = IntX + Int(BWidth(AsciiCode - 65))
        End If

        If (AsciiCode = &H20) Or (AsciiCode = &H0) Then
            IntPos = 61
        ElseIf (AsciiCode >= &H41) And (AsciiCode <= &H5A) Then
            IntPos = PosX(AsciiCode - 65) - Int(BWidth(AsciiCode - 65))
        End If

        If (AsciiCode = &H20) Or (AsciiCode = &H0) Then
            If IntI = 0 Then
                NewPos = IntX - 6
            Else
                NewPos = IntX - 5
            End If
        ElseIf (AsciiCode >= &H41) And (AsciiCode <= &H5A) Then
            NewPos = IntX - Int(BWidth(AsciiCode - 65))
        End If

        If (AsciiCode = &H20) Or (AsciiCode = &H0) Then
            picTopTextSrc.Width = IntX * 15
            SetImage picTopTextSrc, NewPos, 0, CLng(IntX), 7, picMap, IntPos, 4
        ElseIf (AsciiCode >= &H41) And (AsciiCode <= &H5A) Then
            picTopTextSrc.Width = (IntX * 15)
            SetImage picTopTextSrc, NewPos, 0, CLng(IntX), 7, picMap, IntPos, 88
        End If
    Next IntI

    GetBitArray = IntX + Len(StrS)

End Function

Private Sub LoadSkin()

    picMap.Picture = LoadPicture(OptDefPath & "\Gen.bmp")

End Sub

Private Sub picBottomM_DblClick()

    Call ScaleScreen

End Sub

Private Sub picBottomM_MouseDown(Button As Integer, _
                                 Shift As Integer, _
                                 x As Single, _
                                 y As Single _
                                 )

    If Button = 1 Then MouseDown

End Sub

Private Sub picBottomM_MouseMove(Button As Integer, _
                                 Shift As Integer, _
                                 x As Single, _
                                 y As Single _
                                 )

    If Button = 1 Then MouseMove Me

End Sub

Private Sub picBottomM_Resize()

    picW = Int(picBottomM.Width / 15)
    Call StretchBlt(picBottomM.hDC, _
                    0, _
                    0, _
                    picW, _
                    14, _
                    picMap.hDC, _
                    127, _
                    72, _
                    25, _
                    14, _
                    SRCCOPY _
                    )
    picBottomM.Refresh

End Sub

Private Sub picClose_Click()

    Unload Me

End Sub

Private Sub picClose_MouseDown(Button As Integer, _
                               Shift As Integer, _
                               x As Single, _
                               y As Single _
                               )

    Call BitBlt(picClose.hDC, _
                0, _
                0, _
                9, _
                9, _
                picMap.hDC, _
                144, _
                193, _
                SRCCOPY _
                )
    picClose.Refresh

End Sub

Private Sub picClose_MouseUp(Button As Integer, _
                             Shift As Integer, _
                             x As Single, _
                             y As Single _
                             )

    Call BitBlt(picClose.hDC, _
                0, _
                0, _
                9, _
                9, _
                picMap.hDC, _
                144, _
                182, _
                SRCCOPY _
                )
    picClose.Refresh

End Sub

Private Sub picTopF_MouseDown(Button As Integer, _
                              Shift As Integer, _
                              x As Single, _
                              y As Single _
                              )

    If Button = 1 Then MouseDown

End Sub

Private Sub picTopF_MouseMove(Button As Integer, _
                              Shift As Integer, _
                              x As Single, _
                              y As Single _
                              )

    If Button = 1 Then MouseMove Me

End Sub

Private Sub picTopL_MouseDown(Button As Integer, _
                              Shift As Integer, _
                              x As Single, _
                              y As Single _
                              )

    If Button = 1 Then MouseDown

End Sub

Private Sub picTopL_MouseMove(Button As Integer, _
                              Shift As Integer, _
                              x As Single, _
                              y As Single _
                              )

    If Button = 1 Then MouseMove Me

End Sub

Private Sub picTopM_DblClick()

    Call ScaleScreen

End Sub

Private Sub picTopM_MouseDown(Button As Integer, _
                              Shift As Integer, _
                              x As Single, _
                              y As Single _
                              )

    If Button = 1 Then MouseDown

End Sub

Private Sub picTopM_MouseMove(Button As Integer, _
                              Shift As Integer, _
                              x As Single, _
                              y As Single _
                              )

    If Button = 1 Then MouseMove Me

End Sub

Private Sub picTopStretch_MouseDown(Button As Integer, _
                                    Shift As Integer, _
                                    x As Single, _
                                    y As Single _
                                    )

    If Button = 1 Then MouseDown

End Sub

Private Sub picTopStretch_MouseMove(Button As Integer, _
                                    Shift As Integer, _
                                    x As Single, _
                                    y As Single _
                                    )

    If Button = 1 Then MouseMove Me

End Sub

Private Sub picTopStretch_Resize()

    picW = Int(picTopStretch.Width / 15)
    Call StretchBlt(picTopStretch.hDC, _
                    0, _
                    0, _
                    picW, _
                    20, _
                    picMap.hDC, _
                    104, _
                    0, _
                    25, _
                    20, _
                    SRCCOPY _
                    )
    picTopStretch.Refresh

End Sub

Private Sub picTopText_MouseDown(Button As Integer, _
                                 Shift As Integer, _
                                 x As Single, _
                                 y As Single _
                                 )
    
    If Button = 1 Then MouseDown

End Sub

Private Sub picTopText_MouseMove(Button As Integer, _
                                 Shift As Integer, _
                                 x As Single, _
                                 y As Single _
                                 )
    
    If Button = 1 Then MouseMove Me

End Sub

Private Sub picTopText_Resize()

    picW = Int(picTopText.Width / 15)
    Call StretchBlt(picTopText.hDC, _
                    0, _
                    0, _
                    picW, _
                    20, _
                    picMap.hDC, _
                    52, _
                    0, _
                    25, _
                    20, _
                    SRCCOPY _
                    )
    picTopText.Refresh

End Sub

Private Sub picTopTextSrc_MouseDown(Button As Integer, _
                                    Shift As Integer, _
                                    x As Single, _
                                    y As Single _
                                    )

    If Button = 1 Then MouseDown

End Sub

Private Sub picTopTextSrc_MouseMove(Button As Integer, _
                                    Shift As Integer, _
                                    x As Single, _
                                    y As Single _
                                    )

    If Button = 1 Then MouseMove Me

End Sub

Private Sub ScaleScreen()

    If Me.WindowState <> 2 Then
        Me.WindowState = 2
        picFormResize.Enabled = False
    ElseIf Me.WindowState = 2 Then
        Me.WindowState = 0
        picFormResize.Enabled = True
    End If

End Sub

Public Sub SetImage(Destination As Control, _
                    x As Long, _
                    y As Long, _
                    w As Long, _
                    h As Long, _
                    Source As Control, _
                    startX As Long, _
                    StartY As Long _
                    )

Dim DestName As String

    On Error GoTo err_Handle

    Call BitBlt(Destination.hDC, _
                x, _
                y, _
                w, _
                h, _
                Source.hDC, _
                startX, _
                StartY, _
                SRCCOPY _
                )
    Destination.Refresh

err_Handle:

End Sub

Public Sub StandardSize()

Dim a

    a = Trim(GetSetting(App.EXEName, "config", "GenSize", "4125,1740"))
    If a <> "" Then
        For i = 1 To Len(a)

            If Mid(a, i, 1) = "," Then Exit For:

            If Mid(a, i, 1) = ";" Then Exit For:
        Next i
        Me.Width = IIf(IsNumeric(Left$(a, i - 1)) = True, Left(a, i - 1), 4125)
        Me.Height = IIf(IsNumeric(Mid$(a, i + 1)) = True, Right(a, Len(a) - i), 1740)

        If Me.Width < 4125 Then Me.Width = 4125:

        If Me.Height < 1740 Then Me.Height = 1740:
    End If
    
    picFormResize.Left = Me.Width - 210
    picFormResize.Top = Me.Height - 210
    Call ChangePlayList

End Sub

Sub WizFormat()

    SetImage picBottomR, 0, 0, 125, 14, picMap, 0, 57
    SetImage picBottomL, 0, 0, 125, 14, picMap, 0, 42
    SetImage picFormResize, 0, 0, 14, 14, picMap, 111, 57
    SetImage picTopC, 0, 0, 25, 20, picMap, 130, 0
    SetImage picClose, 0, 0, 9, 10, picTopC, 13, 2
    SetImage picTopL, 0, 0, 25, 20, picMap, 0, 0
    SetImage picTopF, 0, 0, 25, 20, picMap, 26, 0
    SetImage picTopM, 0, 0, 25, 20, picMap, 78, 0

End Sub
