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
     with ExGroups.Add('Webressourcen') do
      begin
       AddMenuItem('http://www.g-software.de.gg','',4,15);
       AddMenuItem('http://www.ematupdate.de.gg','',5,15);
      end;

     ExGroups.Add('siehe auch').AddMenuItem('Hilfe','',6,13);
     ExGroups.Add('Version', true).Addline(Version);

    EndUpdate;
   end;
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

Case id of
  0: Iall.Visible:=true;
  1: Ichanges.Visible:=true;
  2: Ibugs.Visible:=true;
  3: Itodo.Visible:=true;
//4: Noch kein Bild
//5: Noch kein Bild
  6: ihilfe.Visible:=true;
end;

Case id of
  0: Mall.Visible:=true;
  1: Mchanges.Visible:=true;
  2: Mbugs.Visible:=true;
  3: Mtodo.Visible:=true;
  4: Fmp3.AwebseiteExecute(finfo);
  5: Fmp3.AupdateExecute(finfo);
  6: Mhilfe.Visible:=true;
end;


end;

end.
