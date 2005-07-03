unit Ulaut;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, AppEvnts, TB2Dock, TBXDkPanels;

  type
  TFlaut = class(TForm)
    TimerHide: TTimer;
    TBXMultiDock1: TTBXMultiDock;
    TBXDockablePanel1: TTBXDockablePanel;
    TBTrayVolume: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure TBTrayVolumeChange(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure TimerHideTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Flaut: TFlaut;

implementation

uses ump3;

{$R *.dfm}

procedure TFlaut.FormCreate(Sender: TObject);
begin
Flaut.Width:=48;
Flaut.Height:=130;
end;

procedure TFlaut.TBTrayVolumeChange(Sender: TObject);
begin
fmp3.TBVolume.Position:=maxVolume-TBTrayVolume.Position;
end;

procedure TFlaut.FormDeactivate(Sender: TObject);
begin
flaut.Hide;
end;

procedure TFlaut.TimerHideTimer(Sender: TObject);
begin
if not TBtrayVolume.Focused then FormDeactivate(flaut);
end;

procedure TFlaut.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
Fmp3.FormKeyDown(Fmp3,Key,Shift);
end;

end.
