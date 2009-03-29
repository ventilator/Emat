object BForm: TBForm
  Left = 313
  Top = 109
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'C++Builder example for BassWinamp   by CM myjobs@mail.ru'
  ClientHeight = 199
  ClientWidth = 424
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 353
    Top = 157
    Width = 59
    Height = 13
    Caption = '00:00/00:00'
  end
  object Label2: TLabel
    Left = 344
    Top = 141
    Width = 75
    Height = 13
    AutoSize = False
    Caption = '00'
  end
  object ListBox1: TListBox
    Left = 2
    Top = 3
    Width = 335
    Height = 137
    Hint = 'DoubleClick opens config for selected plugin'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnDblClick = ListBox1DblClick
  end
  object Button1: TButton
    Left = 344
    Top = 0
    Width = 75
    Height = 25
    Caption = '&Find Plugins'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 344
    Top = 64
    Width = 75
    Height = 25
    Caption = '&Info Box'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 344
    Top = 88
    Width = 75
    Height = 25
    Caption = '&Config'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 344
    Top = 112
    Width = 75
    Height = 25
    Caption = '&About'
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 2
    Top = 144
    Width = 75
    Height = 25
    Caption = '&Open...'
    TabOrder = 5
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 176
    Top = 144
    Width = 75
    Height = 25
    Caption = 'Pa&use'
    TabOrder = 7
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 263
    Top = 144
    Width = 75
    Height = 25
    Caption = '&Stop'
    TabOrder = 8
    OnClick = Button7Click
  end
  object ScrollBar1: TScrollBar
    Left = 3
    Top = 176
    Width = 417
    Height = 17
    PageSize = 0
    TabOrder = 9
    OnScroll = ScrollBar1Scroll
  end
  object Button8: TButton
    Left = 89
    Top = 144
    Width = 75
    Height = 25
    Caption = '&Play'
    TabOrder = 6
    OnClick = Button8Click
  end
  object OpenDialog1: TOpenDialog
    Left = 344
    Top = 32
  end
  object Timer1: TTimer
    Interval = 300
    OnTimer = Timer1Timer
    Left = 376
    Top = 32
  end
end
