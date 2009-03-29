VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cFResizeNWSO"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'cFResizeNWSO.cls
'--------------------------- VB 6.0 Form Module -----------------------------
' BassVis API ADD-ON Sample for Bass Audio Library
' Copyright © 2007 BrewIdeas@Emil Weiss, All Rights Reserved
'
' Author(s) of this class: Emil Weiss
'
' Code was written in and formatted for 10pt Courier New
'----------------------------------------------------------------------------


Option Explicit

Private mFrm           As Form
Private mbDrag         As Boolean

Private mRightStep     As Single
Private mHeightStep    As Single

Private WithEvents mPB As PictureBox
Attribute mPB.VB_VarHelpID = -1

Private Sub Class_Initialize()

    mRightStep = 375
    mHeightStep = 435

End Sub

Private Sub mPB_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)

    If Button = vbLeftButton Then
        mbDrag = True
        If mFrm.name = "frmPlayList" Then
            mFrm.FormFlag = True
            mFrm.ResizeDown = True
        End If
    End If

End Sub

Private Sub mPB_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)

Dim l      As Single    'Form links
Dim T      As Single    'Form Top
Dim w      As Single    'form weite
Dim h      As Single    'Form Höhe

Dim mPBRec As RECT      'Record der PicBox
Dim POINT  As POINTAPI  'Maus Position

'MouseDown ereignis ausgelößt?
    
    If mbDrag Then

        l = mFrm.Left
        T = mFrm.Top
        w = mFrm.ScaleWidth
        h = mFrm.ScaleHeight

        'Aktuelle Position der PictureBox ermitteln
        GetWindowRect mPB.hwnd, mPBRec
        'Aktuelle Cursor Position ermitteln
        GetCursorPos POINT

        If (POINT.x >= mPBRec.Right - 5 And (POINT.y >= mPBRec.Bottom - 5)) Then

            Call mFrm.Move(l, _
                           T, _
                           w + mRightStep, _
                           h + mHeightStep)

            'Neue Position der PictureBox ermitteln. Alte wurde verändert
            GetWindowRect mPB.hwnd, mPBRec
            'Cursor Position setzen auf die mitte der PicBox
            'damit nicht die nächste abfrage ausgelößt wird
            SetCursorPos mPBRec.Left + ((mPBRec.Right - mPBRec.Left) / 2) - 3, _
                                        mPBRec.Top + ((mPBRec.Bottom - mPBRec.Top) / 2) - 3
            Exit Sub
        End If

        If (POINT.x <= mPBRec.Left And (POINT.y <= mPBRec.Top)) Then
            
            'Standart weite erzwingen wenn Formweite unter 4125
            If w < 4125 Then
                w = 4125
            End If
            
            'Standart höhe erzwingen wenn Formhöhe unter 1740
            If h < 1740 Then
                h = 1740
            End If

            Call mFrm.Move(l, _
                           T, _
                           w - mRightStep, _
                           h - mHeightStep)

            'Neue Position der PictureBox ermitteln. Alte wurde verändert
            GetWindowRect mPB.hwnd, mPBRec
            'Cursor Position setzen auf die mitte der PicBox
            'damit nicht die nächste abfrage ausgelößt wird
            SetCursorPos mPBRec.Left + ((mPBRec.Right - mPBRec.Left) / 2) - 3, _
                                        mPBRec.Top + ((mPBRec.Bottom - mPBRec.Top) / 2) - 3
            Exit Sub
        End If

        '******* Form Schrittweise nach Rechts verschieben abhängig von der Cursor Position *******
        If (POINT.x >= (mPBRec.Left + (mPBRec.Right - mPBRec.Left))) Then
            Call mFrm.Move(l, _
                           T, _
                           w + mRightStep, _
                           h)

            'Neue Position der PictureBox ermitteln. Alte wurde verändert
            GetWindowRect mPB.hwnd, mPBRec
            'Cursor Position setzen auf die mitte der PicBox
            'damit nicht die nächste abfrage ausgelößt wird
            SetCursorPos mPBRec.Left + ((mPBRec.Right - mPBRec.Left) / 2) - 3, _
                                        mPBRec.Top + ((mPBRec.Bottom - mPBRec.Top) / 2) - 3

        '******* Form Schrittweise nach Unten verschieben abhängig von der Cursor Position *******
        ElseIf (POINT.y >= (mPBRec.Top + (mPBRec.Bottom - mPBRec.Top))) Then
            Call mFrm.Move(l, _
                           T, _
                           w, _
                           h + mHeightStep)

            'Neue Position der PictureBox ermitteln. Alte wurde verändert
            GetWindowRect mPB.hwnd, mPBRec
            'Cursor Position setzen auf die mitte der PicBox
            'damit nicht die nächste abfrage ausgelößt wird
            SetCursorPos mPBRec.Left + ((mPBRec.Right - mPBRec.Left) / 2) - 3, _
                                        mPBRec.Top + ((mPBRec.Bottom - mPBRec.Top) / 2) - 3

        '******* Form Schrittweise nach Links verschieben abhängig von der Cursor Position *******
        ElseIf (POINT.x <= (mPBRec.Right + (mPBRec.Left - mPBRec.Right) - 6)) Then
            'Standart weite erzwingen wenn Formweite unter 4125
            If w < 4125 Then
                w = 4125
            End If

            Call mFrm.Move(l, _
                           T, _
                           w - mRightStep, _
                           h)
            'Neue Position der PictureBox ermitteln. Alte wurde verändert
            GetWindowRect mPB.hwnd, mPBRec
            'Cursor Position setzen auf die mitte der PicBox
            'damit nicht die nächste abfrage ausgelößt wird
            SetCursorPos mPBRec.Left + ((mPBRec.Right - mPBRec.Left) / 2) - 3, _
                                        mPBRec.Top + ((mPBRec.Bottom - mPBRec.Top) / 2) - 3

        '******* Form Schrittweise nach Oben verschieben abhängig von der Cursor Position *******
        ElseIf (POINT.y <= (mPBRec.Bottom + (mPBRec.Top - mPBRec.Bottom)) - 6) Then
            'Standart höhe erzwingen wenn Formhöhe unter 1740
            If h < 1740 Then
                h = 1740
            End If

            Call mFrm.Move(l, _
                           T, _
                           w, _
                           h - mHeightStep)
            'Neue Position der PictureBox ermitteln. Alte wurde verändert
            GetWindowRect mPB.hwnd, mPBRec
            'Cursor Position setzen auf die mitte der PicBox
            'damit nicht die nächste abfrage ausgelößt wird
            SetCursorPos mPBRec.Left + ((mPBRec.Right - mPBRec.Left) / 2) - 3, _
                                        mPBRec.Top + ((mPBRec.Bottom - mPBRec.Top) / 2) - 3

        End If

    End If

End Sub

Private Sub mPB_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)

    If mbDrag Then
        mbDrag = False
    End If
        
End Sub

Public Sub NewC(aPB As PictureBox, aFrm As Form)

    Set mPB = aPB
    Set mFrm = aFrm

End Sub

