unit uwarte;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XProgress, StdCtrls;

type
  TFWarte = class(TForm)
    PBwarte: TXProgress;
    BAbbrechen: TButton;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BAbbrechenClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  FWarte: TFWarte;

implementation

uses ump3;

{$R *.dfm}


procedure TFWarte.FormCreate(Sender: TObject);
begin
PBwarte.BackgroundColor:=Fmp3.PBar.BackgroundColor; //uk
PBwarte.BarColor:=Fmp3.PBar.BarColor;               //uk
end;

procedure TFWarte.BAbbrechenClick(Sender: TObject); //uk
begin
Fwarte.FormStyle:=fsNormal;
if MessageDlg('Wollen Sie diesesn Vorgang wirklich abbrechen?'+#13+'Er kann später fortgesetzt werden.',mtConfirmation,[mbYes,mbNo],0) = mrYes
 then PBwarte.Tag:=1;
Fwarte.FormStyle:=fsStayOnTop;
end;

end.
