unit Ulaut;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, AppEvnts;

  type
  TFlaut = class(TForm)
    TBTrayVolume: TTrackBar;
    TimerHide: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure TBTrayVolumeChange(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure TimerHideTimer(Sender: TObject);
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
Flaut.Width:=TBTrayVolume.Width;
end;

procedure TFlaut.TBTrayVolumeChange(Sender: TObject);
begin
fmp3.TBVolume.Position:=1000-TBTrayVolume.Position;
end;

procedure TFlaut.FormDeactivate(Sender: TObject);
begin
flaut.Hide;
end;

procedure TFlaut.TimerHideTimer(Sender: TObject);
begin
if not TBtrayVolume.Focused then FormDeactivate(flaut);
end;



end.
