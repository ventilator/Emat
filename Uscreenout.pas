//Diese Form ist für die Anzeige des grünen Textes am Bildschirmrand da

unit Uscreenout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, LMDControl, LMDBaseControl,
  LMDBaseGraphicControl, LMDBaseLabel, LMDCustomLabel, LMDLabel;

type
  TFoutput = class(TForm)
    Timer1: TTimer;
    LMDLabel1: TLMDLabel;
    Label1: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Foutput: TFoutput;

implementation

uses ump3;

{$R *.dfm}

procedure TFoutput.Timer1Timer(Sender: TObject);
begin
fmp3.ScreenOutdone:= not fmp3.ScreenOutdone;
if fmp3.ScreenOutdone
then
begin
ShowWindow(foutput.Handle,SW_HIDE);
Timer1.Enabled:=false;
end;
end;

procedure TFoutput.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
fmp3.FormKeyDown(Sender, Key, Shift);
end;

procedure TFoutput.FormCreate(Sender: TObject);
begin
 Width:=Screen.Width;
 Top:=Screen.Height-Height*2;
end;

end.
