object FrStatus: TFrStatus
  Left = 0
  Top = 0
  Width = 408
  Height = 72
  Align = alBottom
  TabOrder = 0
  TabStop = True
  object Progress: TTBXProgressBar
    Left = 0
    Top = 24
    Width = 408
    Height = 35
    AltMode = False
    Percentage = False
    Position = 0
    ShowPosText = False
    Align = alBottom
  end
  object Caption: TLabel
    Left = 0
    Top = 0
    Width = 208
    Height = 24
    Align = alClient
    Caption = 'Caption'
  end
  object LLabel: TTBXLabel
    Left = 0
    Top = 59
    Width = 408
    Height = 13
    Align = alBottom
    Caption = 'Label'
  end
  object TBXButton1: TTBXButton
    Left = 308
    Top = 0
    Width = 100
    Height = 24
    Align = alRight
    Caption = 'TBXButton1'
    ImageIndex = 0
    TabOrder = 1
  end
  object TBXButton2: TTBXButton
    Left = 208
    Top = 0
    Width = 100
    Height = 24
    Align = alRight
    Caption = 'TBXButton1'
    ImageIndex = 0
    TabOrder = 2
  end
end
