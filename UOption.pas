unit UOption;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnMan, ActnColorMaps, StdCtrls, Buttons;

type
  TFOption = class(TForm)
    sbhintergrundfarbe: TSpeedButton;
    gbfarbe: TGroupBox;
    SBschriftfarbe: TSpeedButton;
    XPColorMap: TXPColorMap;
    colorD: TColorDialog;
    BOK: TButton;
    Label1: TLabel;
    procedure SBschriftfarbeClick(Sender: TObject);
    procedure sbhintergrundfarbeClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    procedure changefontcolor(farbe: tcolor);
    procedure changecolor(farbe: tcolor);
    { Public-Deklarationen }
  end;

var
  FOption: TFOption;

implementation

uses ump3;

{$R *.dfm}

procedure TFOption.SBschriftfarbeClick(Sender: TObject);
begin
IF colorD.Execute
THEN changefontcolor(colorD.Color);
end;


procedure TFOption.sbhintergrundfarbeClick(Sender: TObject);
begin
IF colorD.Execute
THEN changecolor(colorD.Color);
end;



procedure TFOption.changefontcolor(farbe:tcolor);
begin
with fmp3 do
begin
gbpfad.font.color:=farbe;
lepfad.Font.Color:=farbe;
ll.Font.Color:=farbe;
lp.Font.Color:=farbe;
//brandomsort.Font.Color:=farbe;
cbdel.Font.Color:=farbe;
Font.Color:=farbe;
end;
sbhintergrundfarbe.font.Color:=farbe;
SBschriftfarbe.font.Color:=farbe;
xpcolormap.FontColor:=farbe;
gbfarbe.Font.Color:=farbe;
end;

procedure TFOption.changecolor(farbe:tcolor);
begin
with fmp3 do
begin
gbpfad.Color:=farbe;
lepfad.Color:=farbe;
ll.Color:=farbe;
lp.Color:=farbe;
cbdel.Color:=farbe;
Color:=farbe;
end;
color:=farbe;
end;

end.
