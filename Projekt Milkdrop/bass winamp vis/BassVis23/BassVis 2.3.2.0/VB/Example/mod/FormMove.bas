Attribute VB_Name = "FormMove"
'FormMove.BAS
'--------------------------- VB 6.0 Form Module -----------------------------
' BassVis API Module ADD-ON for Bass Audio Library
' Copyright © 2007 BrewIdeas@Emil Weiss, All Rights Reserved
'
' Author(s) of this module: Emil Weiss
'
' Code was written in and formatted for 10pt Courier New
'----------------------------------------------------------------------------

Option Explicit

Public Type RECT
    Left                              As Long
    Top                               As Long
    Right                             As Long
    Bottom                            As Long
End Type

Declare Function SetCursorPos Lib "user32" ( _
    ByVal x As Long, _
    ByVal y As Long _
) As Long

Declare Function GetCursorPos Lib "user32" ( _
    lpPoint As POINTAPI _
) As Long

Public Declare Sub Sleep Lib "kernel32" ( _
    ByVal dwMilliseconds As Long _
)

Public Declare Function GetWindowRect Lib "user32" ( _
    ByVal hwnd As Long, _
    lpRect As RECT _
) As Long

Type POINTAPI
    x As Long
    y As Long
End Type

Public LastPoint As POINTAPI
Public lngTPPY As Long
Public lngTPPX As Long

Public Function New_cFResizeNWSO(aPB As PictureBox, aFrm As Form) As cFResizeNWSO

    Set New_cFResizeNWSO = New cFResizeNWSO
    Call New_cFResizeNWSO.NewC(aPB, aFrm)

End Function

Sub InitTPP()

    lngTPPX& = Screen.TwipsPerPixelX
    lngTPPY& = Screen.TwipsPerPixelY

End Sub

Sub MouseDown()

Dim POINT As POINTAPI

    GetCursorPos POINT
    LastPoint.x = POINT.x
    LastPoint.y = POINT.y

End Sub

Sub MouseMove(ctlForm As Form)

    On Error Resume Next
    Dim lngX     As Long
    Dim lngY     As Long
    Dim POINT    As POINTAPI
        
        GetCursorPos POINT
        lngX& = (POINT.x - LastPoint.x) * lngTPPX&
        lngY& = (POINT.y - LastPoint.y) * lngTPPY&
        LastPoint.x = POINT.x
        LastPoint.y = POINT.y
        ctlForm.Move ctlForm.Left + lngX&, ctlForm.Top + lngY&
    
    SaveSetting App.EXEName, "config", "GenLeft", ctlForm.Left
    SaveSetting App.EXEName, "config", "GenTop", ctlForm.Top

End Sub
