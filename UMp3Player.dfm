object fmp3player: Tfmp3player
  Left = 485
  Top = 162
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'MP3 zu MP3-Player Transfer'
  ClientHeight = 694
  ClientWidth = 698
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object XPKopier: TXProgress
    Left = 4
    Top = 672
    Width = 689
    Height = 16
    Max = 100
    Position = 0
    Step = 1
    BackgroundColor = clBtnFace
    BarColor = clTeal
    GradientColor = clBtnFace
    BarType = brGradient
    BorderWidth = 1
    BlockMultiply = 0.250000000000000000
    Caption = 'Kopierfortschritt'
    CaptionType = ctCustom
  end
  object LBdateien: TListBox
    Left = 4
    Top = 52
    Width = 689
    Height = 613
    Color = clWhite
    ExtendedSelect = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clTeal
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    TabOrder = 0
    OnKeyDown = LBdateienKeyDown
  end
  object GBPfad: TGroupBox
    Left = 4
    Top = 4
    Width = 545
    Height = 45
    Caption = 'GBPfad'
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 1
    object LEpfad: TLabeledEdit
      Left = 4
      Top = 16
      Width = 533
      Height = 19
      Color = clWhite
      EditLabel.Width = 47
      EditLabel.Height = 13
      EditLabel.Caption = 'Zielordner'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clTeal
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Text = 'c:\'
    end
  end
  object BTransfer: TButton
    Left = 564
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Transfer'
    TabOrder = 2
    OnClick = BTransferClick
  end
  object BHelp: TButton
    Left = 652
    Top = 16
    Width = 35
    Height = 25
    Caption = '?'
    TabOrder = 3
    OnClick = BHelpClick
  end
end
