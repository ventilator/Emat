unit Ulaut;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, AppEvnts, TB2Dock, TBXDkPanels, TBXProgressBar,
  TB2Toolbar, TBX, TB2Item;

  type
  TFlaut = class(TForm)
    TBXPBVolume_Tray: TTBXProgressBar;
    TBXDock1: TTBXDock;
    TBXToolbar1: TTBXToolbar;
    TBXItem1: TTBXItem;
    TBXItem2: TTBXItem;
    TBXItem3: TTBXItem;
    TBXItem4: TTBXItem;
    TBXItem5: TTBXItem;
    TBXItem6: TTBXItem;
    TBXSeparatorItem1: TTBXSeparatorItem;
    TBXItem7: TTBXItem;
    TBXPBfortschritt: TTBXProgressBar;
    TBXItem8: TTBXItem;
    TBXSeparatorItem2: TTBXSeparatorItem;
    TBXItem9: TTBXItem;
    procedure FormCreate(Sender: TObject);
    procedure TBXItem9Click(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure TBXPBfortschrittMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TBXPBfortschrittMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TBXPBVolume_TrayMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TBXPBVolume_TrayMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TBXPBVolume_TrayMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Flaut: TFlaut;
  volumeMouseDown: boolean = false;

implementation

uses ump3;

{$R *.dfm}

procedure TFlaut.TBXPBVolume_TrayMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  volumeMouseDown := true;
  fmp3.SetVolume(X / TBXPBVolume_tray.Width);
end;

procedure TFlaut.TBXPBVolume_TrayMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if volumeMouseDown then fmp3.SetVolume(X / TBXPBVolume_tray.Width);
end;

procedure TFlaut.TBXPBVolume_TrayMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  volumeMouseDown := false;
end;

procedure TFlaut.TBXPBfortschrittMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  fmp3.Spule(x/TBXPBfortschritt.Width);
end;

procedure TFlaut.TBXPBfortschrittMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  TBXPBfortschritt.Hint := Format('Zu %s spulen.', [fmp3.DauerZuString(round(X / TBXPBfortschritt.Width * fmp3.Spieler.GetLength))]);
end;

procedure TFlaut.FormDeactivate(Sender: TObject);
begin
  if not Fmp3.Aalwaysontop.Checked then Hide;
end;

procedure TFlaut.TBXItem9Click(Sender: TObject);
begin
  Flaut.Visible:=false;
end;

procedure TFlaut.FormCreate(Sender: TObject);
begin
  TBXPBVolume_Tray.Max := maxVolume;
end;

end.
