object FStatus: TFStatus
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsNone
  Caption = 'Bitte warten...'
  ClientHeight = 146
  ClientWidth = 458
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
    Width = 458
    Height = 147
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
      object LTitel: TLMDLabel
        Left = 32
        Top = 8
        Width = 222
        Height = 15
        Bevel.Mode = bmCustom
        Options = []
        Caption = 'Es werden Medien der Playliste hinzugef'#252'gt...'
      end
      object LName: TLMDLabel
        Left = 8
        Top = 64
        Width = 437
        Height = 57
        Bevel.Mode = bmCustom
        AutoSize = False
        MultiLine = True
        Options = []
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
      object Animate1: TAnimate
        Left = 8
        Top = 8
        Width = 16
        Height = 16
        Active = True
        CommonAVI = aviFindFile
        StopFrame = 8
      end
    end
  end
end
