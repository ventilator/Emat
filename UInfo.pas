unit UInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ShellApi;

type
  TFInfo = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    History: TButton;
    Label4: TLabel;
    procedure Label3MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Label3MouseLeave(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure HistoryClick(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  FInfo: TFInfo;

implementation

uses UHistroy, ump3;

{$R *.dfm}

procedure TFInfo.Label3MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
(Sender as TLabel).Font.Style:=[fsUnderline];
end;

procedure TFInfo.Label3MouseLeave(Sender: TObject);
begin
(Sender as TLabel).Font.Style:=[];
end;

procedure TFInfo.Button1Click(Sender: TObject);
begin
close;
end;

procedure TFInfo.Label3Click(Sender: TObject);
begin
ShellExecute(Handle, 'open', 'mailto:ClemensGruenewald@web.de', nil, nil , SW_SHOW);
end;

procedure TFInfo.HistoryClick(Sender: TObject);
begin
FHistory.Showmodal;
end;

procedure TFInfo.Label4Click(Sender: TObject);
begin
ShellExecute(Handle, 'open', 'http://www.g-software.de.gg', nil, nil, SW_SHOW);
end;

procedure TFInfo.FormCreate(Sender: TObject);
begin
finfo.Label1.Caption:='Emat '+fmp3version;
end;

end.
