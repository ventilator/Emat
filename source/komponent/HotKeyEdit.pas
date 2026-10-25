unit HotKeyEdit;

{ THotKeyEdit: a TEdit that captures a key combination and stores it as a
  ShortCut value in HotKey (replacement for the Delphi THotKey control, which
  LCL does not provide). }

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Controls, StdCtrls, Menus, LCLType, LCLProc;

type
  THotKeyEdit = class(TEdit)
  private
    FHotKey: Integer;
    procedure SetHotKey(AValue: Integer);
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property HotKey: Integer read FHotKey write SetHotKey;
  end;

implementation

constructor THotKeyEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ReadOnly := True;
  FHotKey := 0;
end;

procedure THotKeyEdit.SetHotKey(AValue: Integer);
begin
  FHotKey := AValue;
  if AValue = 0 then
    Text := ''
  else
    Text := ShortCutToText(AValue);
end;

procedure THotKeyEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if not (Key in [VK_SHIFT, VK_CONTROL, VK_MENU]) then
  begin
    FHotKey := ShortCut(Key, Shift);
    Text := ShortCutToText(FHotKey);
    Key := 0;
  end;
  inherited KeyDown(Key, Shift);
end;

end.
