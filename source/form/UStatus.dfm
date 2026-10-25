object FStatus: TFStatus
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsNone
  Caption = 'Bitte warten...'
  ClientHeight = 151
  ClientWidth = 481
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object TBXMultiDock1: TTBXMultiDock
    Left = 0
    Top = 0
    Width = 481
    Height = 145
    object TBXDockablePanel1: TTBXDockablePanel
      Left = 0
      Top = 0
      Caption = 'Bitte warten'
      CaptionRotation = dpcrAlwaysHorz
      CloseButton = False
      CloseButtonWhenDocked = False
      DockedHeight = 125
      DockMode = dmCannotFloatOrChangeDocks
      DockPos = 0
      SupportedDocks = [dkStandardDock, dkMultiDock]
      TabOrder = 0
      object LTitel: TLabel
        Left = 8
        Top = 8
        Width = 222
        Height = 15
        Caption = 'Es werden Medien der Playliste hinzugef'#252'gt...'
      end
      object LName: TLabel
        Left = 8
        Top = 64
        Width = 437
        Height = 65
        AutoSize = False
        WordWrap = True
        Caption = 
          'D:\Daten\Mp3\Deine Lakaien\Dark Star\Deine Lakaien - Dark Star -' +
          ' 01 - Dark Star.mp3'
      end
      object TBXPB: TTBXProgressBar
        Left = 8
        Top = 31
        Width = 437
        Height = 26
        AltMode = False
        Percentage = False
        Position = 20
        PosTextSuffix = ' / 2000'
        ShowPosText = True
      end
      object LSpeed: TLabel
        Left = 336
        Top = 9
        Width = 109
        Height = 13
        Caption = ' Titel/Sekunde'
        Visible = False
      end
    end
  end
end
