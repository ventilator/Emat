unit Ubug;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, StdCtrls, Buttons, ump3, ShellAPI, ICQClient;

type
  TFbug = class(TForm)
    Ibug: TImage;
    Mbug: TMemo;
    Minfo: TMemo;
    Iinfo: TImage;
    Idat: TImage;
    Itxt: TImage;
    Lversion: TLabel;
    Label1: TLabel;
    Mtxt: TMemo;
    LEname: TLabeledEdit;
    Lemail: TLabeledEdit;
    Licq: TLabeledEdit;
    Bsenden: TBitBtn;
    ICQ: TICQClient;
    procedure Label1Click(Sender: TObject);
    procedure Label1MouseLeave(Sender: TObject);
    procedure Label1MouseEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BsendenClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Fbug: TFbug;

implementation

{$R *.dfm}

procedure TFbug.FormCreate(Sender: TObject);
begin
  Lversion.Caption:='Version '+Version;
end;

procedure TFbug.Label1Click(Sender: TObject);
begin
 ShellExecute(Application.Handle, 'open',PChar('http://www.g-software.de.gg'), nil, nil, SW_ShowNormal);
end;

procedure TFbug.Label1MouseLeave(Sender: TObject);
begin
Label1.Font.Color:=clBlack;
Label1.Font.Style:=[];
Label1.Cursor:=crDefault;
end;

procedure TFbug.Label1MouseEnter(Sender: TObject);
begin
Label1.Font.Color:=clBlue;
Label1.Font.Style:=[fsUnderline];
Label1.Cursor:=crHandPoint;
end;

procedure TFbug.BsendenClick(Sender: TObject);
begin
 //ICQ.SendMessage(238134403,mtxt.Lines);
end;

end.
