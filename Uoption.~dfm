object Fsettings: TFsettings
  Left = 313
  Top = 303
  Width = 376
  Height = 320
  Anchors = [akLeft, akTop, akRight, akBottom]
  Caption = 'Einstellungen'
  Color = 15592941
  Ctl3D = False
  ParentFont = True
  OldCreateOrder = False
  ShowHint = True
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    368
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
    Left = 230
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
    Width = 351
    Height = 199
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
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
      Caption = 'Hotkeys'
      object Label2: TLabel
        Left = 52
        Top = 0
        Width = 148
        Height = 143
        Caption = 
          '...sind derzeit nicht ver'#228'nderbar'#13#10#13#10#8226' Strg+F9   zur'#252'ck'#13#10#8226' Strg+' +
          'F11  pause/spielen'#13#10#8226' Strg+F12  vor'#13#10#13#10#8226' Strg+F1 25% Lautst'#228'rke'#13 +
          #10#8226' Strg+F2 50% Lautst'#228'rke'#13#10#8226' Strg+F3 75% Lautst'#228'rke'#13#10#8226' Strg+F4 1' +
          '00% Lautst'#228'rke'#13#10
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
