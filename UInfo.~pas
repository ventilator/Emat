unit UInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg, ump3, shellapi, dxCore, dxContainer, exbar;

type
  TFInfo = class(TForm)
    Mchanges: TMemo;
    Mtodo: TMemo;
    Mbugs: TMemo;
    Mall: TMemo;
    Ichanges: TImage;
    Itodo: TImage;
    Iall: TImage;
    Ibugs: TImage;
    dxCbar: TdxContainer;
    Lbrowser: TLabel;
    Mhilfe: TMemo;
    Ihilfe: TImage;
    procedure Label1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
     { Private-Deklarationen }
  public
    procedure ItemClick(Sender: TObject; Id: Integer);
    { Public-Deklarationen }
  end;

var
  FInfo: TFInfo;
  FExBar: TExBar;

implementation

{$R *.dfm}


procedure TFInfo.Label1Click(Sender: TObject);
begin
 ShellExecute(Application.Handle, 'open',PChar('http://www.g-software.de.gg'), nil, nil, SW_ShowNormal);
end;

procedure TFInfo.FormCreate(Sender: TObject);
begin

  FExBar := TExBar.Create(Self);
  with FExBar do
  begin
    BeginUpdate;
    SetSkin(fmp3.BlueImg.Picture.Bitmap);
    GroupIcons := fmp3.ILSymbolleiste;
    ItemIcons := fmp3.ILSymbolleiste;
    Parent := dxCbar;
    Align := alclient;
    OnMenuItemClick := ItemClick;

     with ExGroups.Add('Info') do
      begin
       AddMenuItem('Allgemeines','',0,13);
       AddMenuItem('Changes','',1,13);
       AddMenuItem('Bugs','',2,13);
       AddMenuItem('To-Do','',3,13);
      end;

     with ExGroups.Add('Online') do
      begin
       AddMenuItem('http://www.g-software.de.gg','',4,15);
       AddMenuItem('http://www.ematupdate.de.gg','',5,15);
      end;

     with ExGroups.Add('siehe auch') do
      begin
       AddMenuItem('Hilfe','',6,13);
      end;

     with ExGroups.Add('Version') do
      begin
       Addline(Version);
      end;

    EndUpdate;
   end;

iall.Visible:=true;
iall.BringToFront;
Mall.Visible:=true;
Mall.BringToFront;

end;


procedure TFinfo.ItemClick(Sender: TObject; Id: Integer);
begin
Iall.Visible:=false;
Ibugs.Visible:=false;
Ichanges.Visible:=false;
Itodo.Visible:=false;
Ihilfe.Visible:=false;
Mbugs.Visible:=false;
Mchanges.Visible:=false;
Mall.Visible:=false;
Mtodo.Visible:=false;
Mhilfe.Visible:=false;
Lbrowser.Visible:=false;


  if id=0 then begin
               iall.Visible:=true;
               iall.BringToFront;
               Mall.Visible:=true;
               Mall.BringToFront;
               end;

  if id=1 then begin
               Ichanges.Visible:=true;
               Ichanges.BringToFront;
               Mchanges.Visible:=true;
               Mchanges.BringToFront;
               end;

  if id=2 then begin
               Ibugs.Visible:=true;
               Ibugs.BringToFront;
               Mbugs.Visible:=true;
               Mbugs.BringToFront;
               end;

  if id=3 then begin
               itodo.Visible:=true;
               itodo.BringToFront;
               Mtodo.Visible:=true;
               Mtodo.BringToFront;
               end;

  if id=4 then begin
               lbrowser.Visible:=true;
               lbrowser.BringToFront;
               ShellExecute(Application.Handle, 'open',PChar('http://www.g-software.de.gg'), nil, nil, SW_ShowNormal);
               end;

  if id=5 then begin
               lbrowser.Visible:=true;
               lbrowser.BringToFront;
               ShellExecute(Application.Handle, 'open',PChar('http://www.ematupdate.de.gg'), nil, nil, SW_ShowNormal);
               end;

  if id=6 then begin
               ihilfe.Visible:=true;
               ihilfe.BringToFront;
               Mhilfe.Visible:=true;
               Mhilfe.BringToFront;
               end;
end;




end.
