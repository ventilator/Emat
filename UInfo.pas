//uk
unit UInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg, ump3, shellapi, exbar, ImgList, TBXDkPanels,
  Ulang, ComCtrls;

type
  TFInfo = class(TForm)
    Mchanges: TRichEdit;
    Mtodo: TRichEdit;
    Mbugs: TRichEdit;
    Mall: TRichEdit;
    Ichanges: TImage;
    Itodo: TImage;
    Iall: TImage;
    Ibugs: TImage;
    Mhilfe: TRichEdit;
    Ihilfe: TImage;
    Blueimg: TImage;
    TBXAPexbar: TTBXAlignmentPanel;
    Splitter1: TSplitter;
    TBXAPclient: TTBXAlignmentPanel;
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
    SetSkin(BlueImg.Picture.Bitmap);
    GroupIcons := fmp3.ILSymbolleiste;
    ItemIcons := fmp3.ILSymbolleiste;
    Parent := TBXAPexbar;
    Align := alclient;
    OnMenuItemClick := ItemClick;

    with ExGroups.Add('Info') do
     begin
      AddMenuItem('Allgemeines', '', 0, 12);
      AddMenuItem('Changes', '', 1, 12);
      AddMenuItem('Bugs', 'Sie haben einen Fehler gefunden?' + sLineBreak +
        'Feedback@G-Software.tk', 2, 12);
      AddMenuItem('To-Do', '', 3, 12);
      end;

     with ExGroups.Add('Webressourcen') do
      begin
       AddMenuItem('g-software.de.gg', 'http://www.g-software.de.gg',
         4, 21);
       AddMenuItem('ematupdate.de.gg', 'http://www.g-software.de.gg',
         5, 21);
      end;

     ExGroups.Add('Version', true).Addline(Version);
     ExGroups.Add('siehe auch').AddMenuItem('Hilfe', '', 6, -1);
     EndUpdate;
   end;
end;


procedure TFinfo.ItemClick(Sender: TObject; Id: Integer);
begin
  Iall.Visible := false;
  Ibugs.Visible := false;
  Ichanges.Visible := false;
  Itodo.Visible := false;
  Ihilfe.Visible := false;
  Mbugs.Visible := false;
  Mchanges.Visible := false;
  Mall.Visible := false;
  Mtodo.Visible := false;
  Mhilfe.Visible := false;

  case id of
    0: begin
         Iall.Visible := true;
         Mall.Visible := true;
       end;

    1: begin
         Ichanges.Visible := true;
         Mchanges.Visible := true;
       end;

    2: begin
         Ibugs.Visible := true;
         Mbugs.Visible := true;
       end;

    3: begin
         Itodo.Visible := true;
         Mtodo.Visible := true;
       end;

    4: fmp3.GoToUrl(Website);
    
    5: fmp3.GoToUrl(Updatepage);

    6: begin
         Ihilfe.Visible := true;
         Mhilfe.Visible := true;
       end;

  end;
end;

end.
