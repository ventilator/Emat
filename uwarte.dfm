object FWarte: TFWarte
  Left = 417
  Top = 352
  Cursor = crHourGlass
  ActiveControl = BAbbrechen
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  BorderStyle = bsNone
  Caption = 'Bitte warten...'
  ClientHeight = 54
  ClientWidth = 312
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  DesignSize = (
    312
    54)
  PixelsPerInch = 96
  TextHeight = 13
  object PBwarte: TXProgress
    Left = 8
    Top = 4
    Width = 295
    Height = 16
    Cursor = crHourGlass
    Max = 100
    Position = 50
    Step = 1
    BackgroundColor = clBtnFace
    BarColor = 12438957
    GradientColor = clBtnFace
    BarType = brBlockGradient
    BorderWidth = 1
    BlockMultiply = 0.250000000000000000
    Caption = 'Bitte warten...'
    CaptionType = ctCustom
    anchors = [akLeft, akTop, akRight]
  end
  object BAbbrechen: TButton
    Left = 116
    Top = 25
    Width = 75
    Height = 25
    Caption = 'Abbrechen'
    TabOrder = 0
    OnClick = BAbbrechenClick
  end
end
