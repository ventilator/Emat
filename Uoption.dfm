object Fsettings: TFsettings
  Left = 347
  Top = 279
  Anchors = [akLeft, akTop, akRight, akBottom]
  BorderStyle = bsDialog
  Caption = 'Einstellungen'
  ClientHeight = 291
  ClientWidth = 366
  Color = 15592941
  Ctl3D = False
  ParentFont = True
  OldCreateOrder = False
  ShowHint = True
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    366
    291)
  PixelsPerInch = 96
  TextHeight = 13
  object LVersion: TLabel
    Left = 11
    Top = 275
    Width = 4
    Height = 13
    Anchors = [akLeft, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
  end
  object Label1: TLabel
    Left = 228
    Top = 275
    Width = 130
    Height = 13
    Hint = 'http://www.g-software.de.gg'
    Anchors = [akRight, akBottom]
    Caption = #169' 2004 by G-Software'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = Label1Click
    OnMouseEnter = Label1MouseEnter
    OnMouseLeave = Label1MouseLeave
  end
  object TB: TTabbedNotebook
    Left = 8
    Top = 4
    Width = 349
    Height = 199
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
    PageIndex = 1
    TabFont.Charset = DEFAULT_CHARSET
    TabFont.Color = clBtnText
    TabFont.Height = -11
    TabFont.Name = 'MS Sans Serif'
    TabFont.Style = []
    TabOrder = 0
    object TTabPage
      Left = 4
      Top = 24
      Caption = 'Ansicht'
      object GBfontcolor: TGroupBox
        Left = 4
        Top = 2
        Width = 161
        Height = 49
        Caption = 'Schriftfarbe'
        TabOrder = 0
        object CBfontcolor: TColorBox
          Left = 8
          Top = 16
          Width = 145
          Height = 22
          Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
          Ctl3D = False
          ItemHeight = 16
          ParentCtl3D = False
          TabOrder = 0
        end
      end
      object GBfont: TGroupBox
        Left = 4
        Top = 58
        Width = 161
        Height = 49
        Caption = 'Schriftart'
        TabOrder = 1
        object LMDFontCombo: TLMDFontComboBox
          Left = 8
          Top = 16
          Width = 145
          Height = 20
          ExampleText = 'Emat'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = []
          ParentFont = False
          ShowExample = True
          TabOrder = 0
        end
      end
      object GBwindowcolor: TGroupBox
        Left = 174
        Top = 2
        Width = 161
        Height = 49
        Caption = 'Fensterfarbe'
        TabOrder = 2
        object CBwindow: TColorBox
          Left = 8
          Top = 16
          Width = 145
          Height = 22
          Selected = clSkyBlue
          Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 0
        end
      end
      object GBtaskbar: TGroupBox
        Left = 4
        Top = 114
        Width = 331
        Height = 49
        Caption = 'Taskleiste'
        TabOrder = 3
        object CBtray: TCheckBox
          Left = 10
          Top = 30
          Width = 143
          Height = 17
          Caption = 'Trayicon'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object CBtaskbar: TCheckBox
          Left = 10
          Top = 13
          Width = 143
          Height = 17
          Caption = 'Taskleisteneintrag'
          TabOrder = 1
        end
        object CBminitotray: TCheckBox
          Left = 152
          Top = 13
          Width = 161
          Height = 17
          Caption = 'In den Tray minimieren'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
      end
    end
    object TTabPage
      Left = 4
      Top = 24
      Caption = 'globale Hotkeys'
      object Label2: TLabel
        Left = 18
        Top = 10
        Width = 70
        Height = 13
        Caption = 'vorheriger Titel'
      end
      object Label3: TLabel
        Left = 18
        Top = 32
        Width = 30
        Height = 13
        Caption = 'Pause'
      end
      object Label4: TLabel
        Left = 18
        Top = 55
        Width = 64
        Height = 13
        Caption = 'n'#228'chster Titel'
      end
      object Label5: TLabel
        Left = 18
        Top = 78
        Width = 73
        Height = 13
        Caption = '25% Lautst'#228'rke'
      end
      object Label6: TLabel
        Left = 18
        Top = 100
        Width = 73
        Height = 13
        Caption = '50% Lautst'#228'rke'
      end
      object Label7: TLabel
        Left = 18
        Top = 123
        Width = 73
        Height = 13
        Caption = '75% Lautst'#228'rke'
      end
      object Label8: TLabel
        Left = 18
        Top = 146
        Width = 79
        Height = 13
        Caption = '100% Lautst'#228'rke'
      end
      object E_GHK_vorher: TEdit
        Left = 128
        Top = 8
        Width = 121
        Height = 19
        TabOrder = 0
        Text = 'Strg+F9'
        OnKeyDown = E_GHK_vorherKeyDown
        OnKeyPress = E_GHK_vorherKeyPress
      end
      object E_GHK_pause: TEdit
        Left = 128
        Top = 30
        Width = 121
        Height = 19
        TabOrder = 1
        Text = 'Strg+F11'
        OnKeyDown = E_GHK_vorherKeyDown
        OnKeyPress = E_GHK_vorherKeyPress
      end
      object E_GHK_nachher: TEdit
        Left = 128
        Top = 53
        Width = 121
        Height = 19
        TabOrder = 2
        Text = 'Strg+F12'
        OnKeyDown = E_GHK_vorherKeyDown
        OnKeyPress = E_GHK_vorherKeyPress
      end
      object E_GHK25: TEdit
        Left = 128
        Top = 76
        Width = 121
        Height = 19
        TabOrder = 3
        Text = 'Strg+F1'
        OnKeyDown = E_GHK_vorherKeyDown
        OnKeyPress = E_GHK_vorherKeyPress
      end
      object E_GHK50: TEdit
        Left = 128
        Top = 98
        Width = 121
        Height = 19
        TabOrder = 4
        Text = 'Strg+F2'
        OnKeyDown = E_GHK_vorherKeyDown
        OnKeyPress = E_GHK_vorherKeyPress
      end
      object E_GHK75: TEdit
        Left = 128
        Top = 121
        Width = 121
        Height = 19
        TabOrder = 5
        Text = 'Strg+F3'
        OnKeyDown = E_GHK_vorherKeyDown
        OnKeyPress = E_GHK_vorherKeyPress
      end
      object E_GHK100: TEdit
        Left = 128
        Top = 144
        Width = 121
        Height = 19
        TabOrder = 6
        Text = 'Strg+F4'
        OnKeyDown = E_GHK_vorherKeyDown
        OnKeyPress = E_GHK_vorherKeyPress
      end
    end
    object TTabPage
      Left = 4
      Top = 24
      Caption = 'Playlisten'
      object CBplaylistsave: TCheckBox
        Left = 7
        Top = 8
        Width = 265
        Height = 17
        Hint = 
          'Speichert die Playlist, sobald sie eine Datei l'#246'schen oder umben' +
          'ennen um bei einem Absturz vor Inkonsistez gefeit zu sein'
        Caption = #196'nderungen an Playlisten sofort speichern'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
    end
    object TTabPage
      Left = 4
      Top = 24
      Caption = 'Renderkern'
      object RGRender: TRadioGroup
        Left = 0
        Top = 0
        Width = 341
        Height = 171
        Align = alClient
        Caption = 'Aktiver Renderkern'
        ItemIndex = 1
        Items.Strings = (
          'DSPack'
          'BASS')
        TabOrder = 0
        OnClick = RGRenderClick
      end
    end
  end
  object Bok: TButton
    Left = 7
    Top = 243
    Width = 82
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = BokClick
  end
  object Bclose: TButton
    Left = 96
    Top = 243
    Width = 87
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Abbrechen'
    TabOrder = 2
    OnClick = BcloseClick
  end
  object Bzurueck: TButton
    Left = 7
    Top = 209
    Width = 282
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Grundeinstellungen'
    TabOrder = 3
    OnClick = BzurueckClick
  end
  object buebernehm: TButton
    Left = 188
    Top = 243
    Width = 101
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #220'bernehmen'
    TabOrder = 4
    OnClick = buebernehmClick
  end
end
