//ehm. Splashscreen von Emat
//seit 0.75 dient diese Form zum Anzeigen des Emat-Logos

unit Ustart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ump3, JPEG, TB2Item, TBX, TB2Dock,
  TB2Toolbar, TBXExtItems;

const
  Logos = 2;   //uk

type
  TFstart = class(TForm)
    i0: TImage;
    i1: TImage;
    TBXToolbar1: TTBXToolbar;
    TBXItem1: TTBXItem;
    TBXItem2: TTBXItem;
    TBXSeparatorItem1: TTBXSeparatorItem;
    TBXLabelItem1: TTBXLabelItem;
    procedure FormClick(Sender: TObject);
    procedure TBXItem1Click(Sender: TObject);
    procedure TBXItem2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Fstart: TFstart;

implementation

{$R *.dfm}

procedure TFstart.FormClick(Sender: TObject);
begin
  (FindComponent( 'i' +inttostr( random( Logos ) ) ) as TImage).BringToFront; //uk
end;

procedure TFstart.TBXItem1Click(Sender: TObject);
begin
  Close;
end;

procedure TFstart.TBXItem2Click(Sender: TObject);
begin
  FormClick(fstart);
end;

procedure TFstart.FormCreate(Sender: TObject);
begin
  randomize;
  TBXLabelItem1.Caption := Version;
end;

procedure TFstart.FormShow(Sender: TObject);
begin
  FormClick(fstart);
end;

end.
