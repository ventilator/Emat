object Flaut: TFlaut
  Left = 299
  Top = 224
  BorderStyle = bsNone
  ClientHeight = 64
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDeactivate = FormDeactivate
  PixelsPerInch = 96
  TextHeight = 13
  object TBXPBVolume_Tray: TTBXProgressBar
    Left = 0
    Top = 30
    Width = 420
    Height = 14
    Max = 255
    AltMode = False
    Percentage = False
    Position = 0
    ShowPosText = True
    Align = alClient
    OnMouseDown = TBXPBVolume_TrayMouseDown
    OnMouseMove = TBXPBVolume_TrayMouseMove
    OnMouseUp = TBXPBVolume_TrayMouseUp
  end
  object TBXPBfortschritt: TTBXProgressBar
    Left = 0
    Top = 44
    Width = 420
    Height = 20
    AltMode = False
    Percentage = False
    Position = 0
    ShowPosText = False
    Align = alBottom
    OnMouseDown = TBXPBfortschrittMouseDown
    OnMouseMove = TBXPBfortschrittMouseMove
  end
  object TBXDock1: TTBXDock
    Left = 0
    Top = 0
    Width = 420
    Height = 30
    object TBXToolbar1: TTBXToolbar
      Left = 0
      Top = 0
      Caption = 'TBXToolbar1'
      DockableTo = []
      DockMode = dmCannotFloatOrChangeDocks
      Images = Fmp3.ILSymbolleiste
      Resizable = False
      Stretch = True
      TabOrder = 0
      object TBXItem6: TTBXItem
        Action = Fmp3.Aprev
      end
      object TBXItem1: TTBXItem
        Action = Fmp3.Astop
      end
      object TBXItem5: TTBXItem
        Action = Fmp3.Apause
      end
      object TBXItem2: TTBXItem
        Action = Fmp3.Aplay
      end
      object TBXItem4: TTBXItem
        Action = Fmp3.Anext
      end
      object TBXItem3: TTBXItem
        Action = Fmp3.Ashuffle
      end
      object TBXSeparatorItem1: TTBXSeparatorItem
      end
      object TBXItem7: TTBXItem
        Action = Fmp3.Aalwaysontop
      end
      object TBXSeparatorItem2: TTBXSeparatorItem
      end
      object TBXItem9: TTBXItem
        Caption = '_'
        OnClick = TBXItem9Click
      end
      object TBXItem8: TTBXItem
        Action = Fmp3.Aclose
      end
    end
  end
end
