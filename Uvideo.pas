//uk

unit Uvideo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ump3, ComCtrls, StdCtrls, ExtCtrls;

type
  TFvideo = class(TForm)
    Panel1: TPanel;
    procedure FormDblClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Fvideo: TFvideo;

implementation

{$R *.dfm}

procedure TFvideo.FormDblClick(Sender: TObject);
begin
if Fvideo.BorderStyle=bsSingle then
    begin
      BorderStyle:=bsnone;
      Fvideo.BorderIcons:=[];
      Left:=0;
      Top:=0;
      Width:=Screen.Width;
      Height:=Screen.Height;

          
    end else
    begin
      Fvideo.BorderStyle:=bsSingle;
      Fvideo.BorderIcons:=[biSystemMenu];
      Fvideo.Height:=480;
      Fvideo.Width:=640;
      Fvideo.Position:=poscreencenter;
    end;
end;

procedure TFvideo.FormPaint(Sender: TObject);
begin
fmp3.MediaP.Display:=fvideo.panel1;
fmp3.MediaP.DisplayRect:=Fvideo.Panel1.ClientRect;
end;

procedure TFvideo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
Fmp3.AStoppExecute(fmp3);
end;

procedure TFvideo.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
fmp3.FormKeyDown(fvideo,key,shift);
end;

procedure TFvideo.FormShow(Sender: TObject);
begin
SetWindowLong(Handle, GWL_ExStyle, WS_Ex_AppWindow);

end;

end.
