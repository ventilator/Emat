object FInfo: TFInfo
  Left = 449
  Top = 272
  BorderStyle = bsDialog
  Caption = 'Info'
  ClientHeight = 128
  ClientWidth = 221
  Color = clTeal
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 62
    Height = 13
    Caption = 'Emat 0.1.7'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 16
    Top = 24
    Width = 188
    Height = 13
    Caption = 'Bugs, Reports, fehlende Funktion, Lob?'
  end
  object Label3: TLabel
    Left = 16
    Top = 48
    Width = 113
    Height = 13
    Caption = 'Der_Ventilator@web.de'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnClick = Label3Click
    OnMouseMove = Label3MouseMove
    OnMouseLeave = Label3MouseLeave
  end
  object Label4: TLabel
    Left = 16
    Top = 65
    Width = 137
    Height = 13
    Caption = 'http://www.g-software.de.gg'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnClick = Label4Click
    OnMouseMove = Label3MouseMove
    OnMouseLeave = Label3MouseLeave
  end
  object Button1: TButton
    Left = 16
    Top = 92
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = Button1Click
  end
  object History: TButton
    Left = 128
    Top = 92
    Width = 75
    Height = 25
    Caption = 'History'
    TabOrder = 1
    OnClick = HistoryClick
  end
end
