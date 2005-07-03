object Foutput: TFoutput
  Left = 513
  Top = 439
  Align = alClient
  BorderStyle = bsNone
  Caption = 'G-Software | Emat GreenScreenoutput'
  ClientHeight = 106
  ClientWidth = 406
  Color = clBlack
  TransparentColor = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object LMDLabel1: TLMDLabel
    Left = 0
    Top = 0
    Width = 372
    Height = 107
    Bevel.Mode = bmCustom
    FontFX.LightDepth = 30
    FontFX.ShadowDepth = 30
    FontFX.LightColor = -1
    FontFX.ShadowColor = clNavy
    FontFX.Style = tdShadow
    Color = clNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clLime
    Font.Height = -67
    Font.Name = 'Arial'
    Font.Style = []
    Options = []
    ParentColor = False
    ParentFont = False
    Transparent = False
    Caption = 'LMDLabel1'
  end
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 200
    Height = 75
    Caption = 'Label1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clLime
    Font.Height = -67
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 372
  end
end
