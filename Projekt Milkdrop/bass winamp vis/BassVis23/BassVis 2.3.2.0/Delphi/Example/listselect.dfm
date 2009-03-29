object frListSelect: TfrListSelect
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'frListSelect'
  ClientHeight = 91
  ClientWidth = 341
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 341
    Height = 13
    Align = alTop
    Caption = 'Plugins:'
    ExplicitWidth = 37
  end
  object cbolist: TComboBox
    Left = 0
    Top = 13
    Width = 341
    Height = 21
    Align = alTop
    Style = csDropDownList
    ItemHeight = 0
    TabOrder = 0
  end
  object BitBtn1: TBitBtn
    Left = 8
    Top = 48
    Width = 97
    Height = 25
    TabOrder = 1
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 234
    Top = 48
    Width = 99
    Height = 25
    TabOrder = 2
    Kind = bkCancel
  end
end
