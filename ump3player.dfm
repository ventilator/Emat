object FMp3Player: TFMp3Player
  Left = 263
  Top = 265
  Width = 759
  Height = 602
  Caption = 'Medien kopieren'
  Color = 15592941
  Constraints.MinHeight = 453
  Constraints.MinWidth = 579
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    751
    573)
  PixelsPerInch = 96
  TextHeight = 13
  object Progress: TXProgress
    Left = 376
    Top = 548
    Width = 283
    Height = 16
    Max = 100
    Position = 0
    Step = 1
    BackgroundColor = clSkyBlue
    BarColor = clBlack
    GradientColor = clBtnFace
    BarType = brBlockGradient
    BorderWidth = 1
    BlockMultiply = 0.250000000000000000
    Caption = 'TXProgress'
    CaptionType = ctPercent
    anchors = [akLeft, akRight, akBottom]
  end
  object Button1: TButton
    Left = 669
    Top = 540
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Schlie'#223'en'
    ModalResult = 1
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 248
    Top = 540
    Width = 121
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Medien '#252'bertragen'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 8
    Top = 540
    Width = 233
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Dateiliste aus Subplaylist aktualisieren'
    TabOrder = 2
    OnClick = Button3Click
  end
  object dxContainer1: TdxContainer
    Left = 7
    Top = 7
    Width = 739
    Height = 525
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'dxContainer1'
    object Splitter1: TSplitter
      Left = 200
      Top = 0
      Width = 2
      Height = 525
    end
    object GroupBox2: TGroupBox
      Left = 202
      Top = 0
      Width = 537
      Height = 525
      Align = alClient
      Caption = 'Dateien'
      TabOrder = 0
      DesignSize = (
        537
        525)
      object Label1: TLabel
        Left = 16
        Top = 444
        Width = 43
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'Anzahl:'
      end
      object Label2: TLabel
        Left = 264
        Top = 444
        Width = 71
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'Gr'#246#223'e (MB):'
      end
      object LAnzahl: TLabel
        Left = 64
        Top = 444
        Width = 7
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = '0'
      end
      object LSize: TLabel
        Left = 346
        Top = 444
        Width = 7
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = '0'
      end
      object Label3: TLabel
        Left = 104
        Top = 444
        Width = 99
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'Dauer (min:sec):'
      end
      object LDauer: TLabel
        Left = 209
        Top = 444
        Width = 33
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = '00:00'
      end
      object lb_files: TCheckListBox
        Left = 8
        Top = 16
        Width = 519
        Height = 421
        OnClickCheck = lb_filesClickCheck
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 13
        TabOrder = 0
      end
      object BNummer: TButton
        Left = 16
        Top = 468
        Width = 129
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = 'Laufende Nummer...'
        Enabled = False
        TabOrder = 1
      end
    end
    object GroupBox1: TGroupBox
      Left = 0
      Top = 0
      Width = 200
      Height = 525
      Align = alLeft
      Caption = 'Zielort'
      TabOrder = 1
      DesignSize = (
        200
        525)
      object STV: TShellTreeView
        Left = 8
        Top = 64
        Width = 184
        Height = 453
        ObjectTypes = [otFolders]
        Root = 'rfDesktop'
        UseShellImages = True
        Anchors = [akLeft, akTop, akRight, akBottom]
        AutoRefresh = False
        Indent = 19
        ParentColor = False
        RightClickSelect = True
        ShowRoot = False
        TabOrder = 0
        OnChange = STVChange
      end
      object Epfad: TEdit
        Left = 8
        Top = 24
        Width = 184
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
      end
    end
  end
end
