object FOption: TFOption
  Left = 271
  Top = 189
  BorderStyle = bsDialog
  Caption = 'Einstellungen'
  ClientHeight = 153
  ClientWidth = 135
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 136
    Width = 117
    Height = 13
    Caption = '! Dialog seit 0.2 veraltet !'
  end
  object gbfarbe: TGroupBox
    Left = 4
    Top = 8
    Width = 125
    Height = 85
    Caption = 'GUI-Farben'
    TabOrder = 0
    object sbhintergrundfarbe: TSpeedButton
      Left = 12
      Top = 48
      Width = 97
      Height = 22
      Caption = 'Hintergrund'
      OnClick = sbhintergrundfarbeClick
    end
    object SBschriftfarbe: TSpeedButton
      Left = 12
      Top = 20
      Width = 97
      Height = 22
      Caption = 'Schrift'
      OnClick = SBschriftfarbeClick
    end
  end
  object BOK: TButton
    Left = 28
    Top = 100
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
  end
  object XPColorMap: TXPColorMap
    HighlightColor = 14410210
    BtnSelectedColor = clBtnFace
    UnusedColor = 14410210
    Left = 96
    Top = 24
  end
  object colorD: TColorDialog
    Options = [cdFullOpen, cdAnyColor]
    Left = 96
    Top = 56
  end
end
