unit Ustart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ump3, shellapi, ImgList;

type
  TFstart = class(TForm)
    LVersion: TLabel;
    Timer1: TTimer;
    ImageList1: TImageList;
    i1: TImage;
    i2: TImage;

    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Fstart: TFstart;

implementation

{$R *.dfm}

procedure TFstart.FormCreate(Sender: TObject);
//var bild: Tbitmap;
begin
{geht net weil delphi beim hinzufügen von bildern der imagelist abstürzt grrr...
  randomize;
  bild.Create;
  bild.Width:=imagelist1.Width;
  bild.Height:=imagelist1.Height;


  ImageList1.GetBitmap(random(ImageList1.Count-1),bild);

  Fstart.Canvas.Draw(0,0,bild);
}
  randomize;
  if random(2)=1 then i1.Visible:=true else i2.Visible:=true;
  LVersion.Caption:='Version '+Version;
  lversion.Transparent:=true;
  LVersion.BringToFront;
end;

procedure TFstart.Timer1Timer(Sender: TObject);
begin
  sleep(1000);
  close;
  fmp3.Visible:=true;
  timer1.Enabled:=false;
end;


procedure TFstart.FormClick(Sender: TObject);
begin
  close;
  fmp3.Visible:=true;
  timer1.Enabled:=false;
end;

end.
