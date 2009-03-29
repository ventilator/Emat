object frmain: Tfrmain
  Left = 0
  Top = 0
  Caption = 'Exampel for bassvis'
  ClientHeight = 457
  ClientWidth = 717
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mm
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 441
    Top = 0
    Height = 438
    ExplicitLeft = 249
    ExplicitTop = -6
    ExplicitHeight = 412
  end
  object sbmain: TStatusBar
    Left = 0
    Top = 438
    Width = 717
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 200
      end
      item
        Width = 50
      end>
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 441
    Height = 438
    Align = alLeft
    Caption = 'Playlist'
    TabOrder = 1
    object Panel2: TPanel
      Left = 2
      Top = 350
      Width = 437
      Height = 86
      Align = alBottom
      TabOrder = 0
      object Button1: TButton
        Left = 104
        Top = 57
        Width = 75
        Height = 25
        Hint = 'Play'
        Caption = 'play'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = Button1Click
      end
      object Button2: TButton
        Left = 262
        Top = 57
        Width = 75
        Height = 25
        Hint = 'Stop'
        Caption = 'stop'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = Button2Click
      end
      object add: TButton
        Left = 23
        Top = 6
        Width = 75
        Height = 25
        Hint = 'Add files to playlist'
        Caption = 'Add Files'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnClick = addClick
      end
      object Button4: TButton
        Left = 185
        Top = 57
        Width = 75
        Height = 25
        Hint = 'Pause/Resume'
        Caption = 'Pause'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnClick = Button4Click
      end
      object Button5: TButton
        Left = 23
        Top = 57
        Width = 75
        Height = 25
        Hint = 'Prev. Track'
        Caption = '<<'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        OnClick = Button5Click
      end
      object Button6: TButton
        Left = 343
        Top = 57
        Width = 75
        Height = 25
        Hint = 'Next Track'
        Caption = '>>'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
        OnClick = Button6Click
      end
    end
    object lbsongs: TListBox
      Left = 2
      Top = 15
      Width = 437
      Height = 335
      Hint = 'Playlist for the music'
      Align = alClient
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = lbsongsClick
      OnDblClick = lbsongsDblClick
    end
  end
  object Panel1: TPanel
    Left = 444
    Top = 0
    Width = 273
    Height = 438
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 2
    object Splitter2: TSplitter
      Left = 0
      Top = 248
      Width = 273
      Height = 3
      Cursor = crVSplit
      Align = alTop
      ExplicitLeft = 1
      ExplicitTop = 249
      ExplicitWidth = 142
    end
    object pdisplay: TPanel
      Left = 0
      Top = 0
      Width = 273
      Height = 248
      Align = alTop
      Caption = 'Display Panel'
      TabOrder = 0
      OnMouseDown = pdisplayMouseDown
      OnResize = pdisplayResize
    end
    object ppoptions: TPanel
      Left = 0
      Top = 251
      Width = 273
      Height = 187
      Align = alClient
      TabOrder = 1
      object rbrecord: TRadioButton
        Left = 6
        Top = 24
        Width = 113
        Height = 17
        Hint = 'Recordchannel as Source'
        Caption = 'Record as Source'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = rbrecordClick
      end
      object rbstream: TRadioButton
        Left = 6
        Top = 6
        Width = 113
        Height = 17
        Hint = 'Stream or Music as Source'
        Caption = 'Stream as Source'
        Checked = True
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        TabStop = True
        OnClick = rbstreamClick
      end
      object gbdevice: TGroupBox
        Left = 6
        Top = 47
        Width = 155
        Height = 114
        Caption = 'Device-Options'
        TabOrder = 2
        object lblsource: TLabel
          Left = 3
          Top = 16
          Width = 37
          Height = 13
          Caption = 'Source:'
        end
        object Label1: TLabel
          Left = 3
          Top = 59
          Width = 29
          Height = 13
          Caption = 'Level:'
        end
        object cbodevlist: TComboBox
          Left = 3
          Top = 32
          Width = 145
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          OnChange = cbodevlistChange
        end
        object edlvl: TEdit
          Left = 3
          Top = 78
          Width = 41
          Height = 21
          TabOrder = 1
          Text = '0'
          OnChange = edlvlChange
        end
        object udlvl: TUpDown
          Left = 44
          Top = 78
          Width = 16
          Height = 21
          Associate = edlvl
          TabOrder = 2
        end
      end
      object rgview: TRadioGroup
        Left = 167
        Top = 6
        Width = 98
        Height = 155
        Hint = 'Visualisation Options only on next Plugin'
        Caption = ' View '
        ItemIndex = 0
        Items.Strings = (
          'Panel'
          'Window'
          'Winampwin')
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
      end
    end
  end
  object mm: TMainMenu
    Left = 336
    Top = 344
    object Plugins1: TMenuItem
      Caption = 'Plugins'
      object ShowbassvisVersion1: TMenuItem
        Action = acshowversion
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object SelectSoniquePlugin1: TMenuItem
        Action = acselsonique
      end
      object SelectWinampPlugin1: TMenuItem
        Action = acselwinamp
      end
    end
  end
  object almain: TActionList
    Left = 376
    Top = 344
    object acselsonique: TAction
      Caption = 'Select Sonique Plugin'
      Hint = 'Use Soniqueplayer Plugin'
      OnExecute = acselsoniqueExecute
    end
    object acselwinamp: TAction
      Caption = 'Select Winamp Plugin'
      Hint = 'Use Winamp plugin'
      OnExecute = acselwinampExecute
    end
    object acshowversion: TAction
      Caption = 'Show bassvis Version'
      OnExecute = acshowversionExecute
    end
  end
  object od: TOpenDialog
    FileName = 
      '*.mp3;*.mp2;*.mp1;*.ogg;*.wav;*.aiff;*.MO3;*.S3M;*.MOD;*.XM;*.IT' +
      ';*.MTM;*.UMX'
    Filter = 
      'Stream-Files (*.mp3,*.mp2,*.mp1,*.ogg,*.wav,*.aiff)|*.mp3;*.mp2;' +
      '*.mp1;*.ogg;*.wav;*.aiff|Module-Files (*.MO3;*.S3M;*.MOD;*.XM;*.' +
      'IT;*.MTM;*.UMX)|*.MO3;*.S3M;*.MOD;*.XM;*.IT;*.MTM;*.UMX|All avai' +
      'lable formats|*.mp3;*.mp2;*.mp1;*.ogg;*.wav;*.aiff;*.MO3;*.S3M;*' +
      '.MOD;*.XM;*.IT;*.MTM;*.UMX'
    FilterIndex = 3
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Add Songfiles'
    Left = 200
    Top = 352
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 240
    Top = 352
  end
end
