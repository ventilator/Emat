unit UListe;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TB2Dock, TB2Toolbar, TBXExtItems, TB2Item, TB2ExtItems,
  Gliste2, ExtCtrls, TBX, Buttons, Grids, TBXStatusBars, Menus, StdCtrls,
  TBXDkPanels, LMDCustomControl, LMDCustomPanel, LMDCustomBevelPanel,
  LMDBaseEdit, LMDCustomEdit, LMDEdit, LMDCustomComponent,
  LMDBaseController, LMDCustomContainer, LMDCustomImageList, LMDImageList,
  TBXProgressBar;

const
  AusleseIntervall=100;
  Anzahl_TBXToolbars_Liste = 4;

type
  TAusleseThread = class(TThread)
  protected
    procedure Execute; override;
  end;

type
  TCopyThread = class(TThread)
  protected
    procedure Execute; override;
  end;

type
  TFPlayliste = class(TForm)
    TBXToolbar1: TTBXToolbar;
    TBXToolbar2: TTBXToolbar;
    TBXCBI0: TTBXComboBoxItem;
    TBXCBI1: TTBXComboBoxItem;
    TBXCBI2: TTBXComboBoxItem;
    TBXCBI3: TTBXComboBoxItem;
    TBXCBI4: TTBXComboBoxItem;
    StringGrid: TStringGrid;
    TBXDock1: TTBXDock;
    TBXDock2: TTBXDock;
    TBXDock3: TTBXDock;
    TBXDock4: TTBXDock;
    TBXToolbar3: TTBXToolbar;
    TBXSubmenuItem1: TTBXSubmenuItem;
    TBXItem3: TTBXItem;
    TBXItem4: TTBXItem;
    TBXItem37: TTBXItem;
    TBXItem34: TTBXItem;
    TBXToolbar4: TTBXToolbar;
    TBXItem2: TTBXItem;
    TBXItem_sort1: TTBXItem;
    TBXItem_sort0: TTBXItem;
    TBXItem_sort2: TTBXItem;
    TBXItem_sort3: TTBXItem;
    TBXItem_sort4: TTBXItem;
    GBliste: TTBXAlignmentPanel;
    PMliste: TTBXPopupMenu;
    TBXPopupMenu1: TTBXPopupMenu;
    TBXSubmenuItem2: TTBXSubmenuItem;
    TBXItem5: TTBXItem;
    TBXItem6: TTBXItem;
    TBXItem52: TTBXItem;
    TBXSubmenuItem3: TTBXSubmenuItem;
    TBXItem1: TTBXItem;
    TBXItem7: TTBXItem;
    TBXItem8: TTBXItem;
    TBControlItem2: TTBControlItem;
    ISuche: TImage;
    ES: TEdit;
    TBControlItem1: TTBControlItem;
    TBXItem9: TTBXItem;
    TBXItem10: TTBXItem;
    TBXItem11: TTBXItem;
    TBXStatusBar1: TTBXStatusBar;
    TBXPBauslesen: TTBXProgressBar;
    TBXItem12: TTBXItem;
    TBXItem13: TTBXItem;
    TBXItem14: TTBXItem;
    TBXItCopyFiles: TTBXItem;
    LStatus: TTBXLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure StringGridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TBXCBI0Change(Sender: TObject; const Text: String);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TBXItem2Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TBXItem6Click(Sender: TObject);
    procedure TBXItem_sort0Click(Sender: TObject);
    procedure TBXToolbar1Close(Sender: TObject);
    procedure TBXToolbar2VisibleChanged(Sender: TObject);
    procedure TBXItem1Click(Sender: TObject);
    procedure TBXItem7Click(Sender: TObject);
    procedure TBXItem8Click(Sender: TObject);
    procedure TBXItem9Click(Sender: TObject);
    procedure ESChange(Sender: TObject);
    procedure TBXItem10Click(Sender: TObject);
    procedure TBXItem11Click(Sender: TObject);
    procedure TBXItem5Click(Sender: TObject);
    procedure TBXItem3Click(Sender: TObject);
    procedure TBXItem4Click(Sender: TObject);
    procedure TBXItem12Click(Sender: TObject);
    procedure TBXItem13Click(Sender: TObject);
    procedure TBXItem14Click(Sender: TObject);
    procedure TBXItem15Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TBXItCopyFilesClick(Sender: TObject);
    procedure LStatusClick(Sender: TObject);
  private
    procedure GlisteKeyDown(Key:word; Shift:tshiftstate);
    procedure GlisteDragOver(Sender, Source: Tobject; x, y: integer;
      State: TDragState; var accept: boolean);
    procedure GlisteDragDrop(Sender, Source: Tobject; x, y: integer);
    procedure GlisteDoppelklick(index : integer);
    procedure GlisteSpule(Prozent: real);
    procedure SetRaender;
    procedure TBX_TB_ItemClick(Sender: TObject);
    procedure ToolbarMenuErstellen;
    procedure Minimieren;
    procedure Maximieren;
    procedure RescanFolders;
    procedure Addfile;
    procedure ListenEintraegeAuslesen;
    procedure GlisteElementMarkieren(ElementNummer:integer);
    { Private-Deklarationen }
  public    
    ListenNummer: integer;
    Gliste1    : TGListe2;
    { Public-Deklarationen }
  end;

var
  FPlayliste  : TFPlayliste;



implementation

{$R *.dfm}
uses ump3, Uscreenout;

var closeflag     : boolean=true;
    BreakFlag     : boolean=false;
    AusleseThread : TAusleseThread;
    CopyThread    : TCopyThread;


procedure TFPlayliste.FormCreate(Sender: TObject);
begin
  GListe1 := TGliste2.create(fplayliste);
  GListe1.Parent := GBListe;
  GListe1.Align := alClient;
  Gliste1.aktiv := true;
  Gliste1.PopupMenu := PMliste;
  Gliste1.OnKeyDown := GlisteKeyDown;
  Gliste1.OnDoppelklick := GlisteDoppelklick;
  Gliste1.OnSpulen := GlisteSpule;
  Gliste1.OnElementMarkieren := GlisteElementMarkieren;
  GListe1.OnDragOver:=GlisteDragOver;
  Gliste1.OnDragDrop:=GlisteDragDrop;
  SetRaender;
end;

procedure TFPlayliste.GlisteDoppelklick(Index :integer);
begin
  fmp3.Aktiv.SpielendeListe := ListenNummer;
  if fmp3.Spiele(ListenNummer,strtoint(Gliste1.liste.Nummer[index]))
  then Gliste1.fortschrittlichesElement:=index;
end;                      


procedure TFPlayliste.GlisteKeyDown(Key:word;Shift:tshiftstate);
begin
  case key of
  vk_delete:    fmp3.ElementLoeschen(ListenNummer,strtoint(Gliste1.Liste.Nummer[
                                                   Gliste1.markiertesElement]));
  end;
  Fplayliste.FormKeyDown(Gliste1,Key,Shift);
end;

procedure TFPlayliste.GlisteDragOver ( Sender, Source:Tobject; x,y: integer;
                                   State: TDragState; var accept:boolean);
begin
  if Source = (Source as TGliste2) then accept:=true;
end;

procedure TFPlayliste.GlisteDragDrop(Sender, Source: Tobject; x,
  y: integer);
  var FileName : string;
begin                                      //nicht in sich selbst kopieren
  if (Source = (Source as TGliste2))  and (Source <> Sender) and
       (fmp3.Datenbank.GetMediumFullFileName(
       (Source as TGliste2).Tag,
       strtoint( (Source as TGliste2).Liste.Nummer[(Source as TGliste2).markiertesElement] ),
       FileName ) )
  then
   begin
    if not fmp3.Datenbank.ItemExists(ListenNummer,extractfilepath(FileName),
                                                extractfilename(FileName))
    then
      begin
        fmp3.Datenbank.CopyItem((Source as TGliste2).Tag,
        strtoint((Source as TGliste2).Liste.Nummer[(Source as TGliste2).markiertesElement]),
        ListenNummer);
        fmp3.DatenbankListeAusgeben(ListenNummer);
      end
     else
       MessageDlg(FileName+' befindet sich bereits in der Liste'+#13+
        'und kann deshalb nicht noch einmal hinzugefügt werden.',mtinformation,[mbok],0);
   end;
end;

procedure TFPlayliste.FormActivate(Sender: TObject);
begin
  fmp3.Aktiv.Liste:=ListenNummer;
  fmp3.SetListsInaktive(ListenNummer);
end;

procedure TFPlayliste.GlisteSpule (Prozent :real );
begin
  fmp3.Spule(prozent);
end;

procedure TFPlayliste.GlisteElementMarkieren(ElementNummer:integer);
begin
  fmp3.ElementMarkieren(ListenNummer,strtoint(Gliste1.liste.Nummer[ElementNummer]));
end;

procedure TFPlayliste.StringGridMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

begin
SetRaender;
end;

procedure TFPlayliste.SetRaender;
var i :integer;
begin
Gliste1.rand[0]:=0;

for i:=0 to 4 do
begin
  Gliste1.rand[i+1]:=Gliste1.rand[i]+StringGrid.ColWidths[i];
  (FindComponent('TBXCBI'+inttostr(i)) as TTBXComboBoxItem).EditWidth:=
            StringGrid.ColWidths[i] - 28; //uk
end;

Gliste1.Draw;
end;

procedure TFPlayliste.TBXCBI0Change(Sender: TObject; const Text: String);
begin
 fmp3.Datenbank.Mp3DatenMeta[ListenNummer].AnzeigeSpalten[
 (Sender as TTBXComboboxItem).Tag]:=(Sender as TTBXComboboxItem).ItemIndex;

 fmp3.DatenbankListeAusgeben(ListenNummer);

 StringGrid.Cols[(Sender as TTBXComboboxItem).Tag].Text:=
        (Sender as TTBXComboboxItem).Text;
end;

procedure TFPlayliste.FormClose(Sender: TObject; var Action: TCloseAction);
var mdlgResult : byte;
begin
  if not closeflag
   then
    begin
     if MessageDlg('Kopiervorgang läuft. Soll dieser abgebrochen werden?',
        mtConfirmation, [mbYes, mbNo], 0) = mryes
     then
      begin
       breakflag:=true;
       while not closeflag do fmp3.delay(1)
      end
     else
       begin
         abort;
       end;
     end;

  mdlgResult:= MessageDlg('Soll die Playliste vor dem Schließen gespeichert werden?',
      mtConfirmation, [mbYes, mbNo, mbcancel], 0);

 if (mdlgResult = mrYes) or (mdlgResult = mrNo)
 then
   begin
     action:=caFree;
     if (mdlgResult = mrYes)
     then fmp3.Datenbank.SchliesseListe(ListenNummer)
     else fmp3.Datenbank.SchliesseListe(ListenNummer,false);
   end
 else action:=caNone;
end;


procedure TFPlayliste.TBXItem2Click(Sender: TObject);
begin
 close;
end;


procedure TFPlayliste.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Fmp3.FormKeyDown(fmp3,Key,Shift);  //?
end;

procedure TFPlayliste.TBXItem6Click(Sender: TObject);
begin
 ListenEintraegeAuslesen;
end;

 //////////////////////////////////////////////////////////////////////////////
procedure TAusleseThread.Execute;
var i,ListenNummer : integer;
begin
   inherited;
   ListenNummer:=fmp3.Aktiv.Liste; //schwammig

   if fmp3.Datenbank.ListeExists(ListenNummer)
   then
   begin
     i:=0;
     fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Caption:='Lese...';
     repeat
       if not fmp3.Datenbank.Mp3Daten[ListenNummer,i].id3tag.ausgelesen
         then fmp3.Datenbank.LeseId3(ListenNummer,
                          fmp3.Datenbank.Mp3Daten[ListenNummer,i].Nummer);

       if fmp3.Datenbank.Mp3Daten[ListenNummer,i].dauer=''
       then
       fmp3.Datenbank.SetMediumPlayLength(ListenNummer,
            fmp3.Datenbank.Mp3Daten[ListenNummer,i].Nummer,
            fmp3.DauerZuString(fmp3.Spieler.GetDauer(
            fmp3.Datenbank.Mp3Daten[ListenNummer,i].path+
            fmp3.Datenbank.Mp3Daten[ListenNummer,i].filename )));

       if (i mod AusleseIntervall)=0
         then
           begin
             fmp3.DatenbankListeAusgeben(ListenNummer);
             fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Max :=
                                High(fmp3.Datenbank.Mp3Daten[ListenNummer]);
                                //Es könnten mehr geworden sein
             fmp3.Fplaylisten[ListenNummer].TBXPBauslesen.Position := i;
           end;

       inc(i);
       until (i=High(fmp3.Datenbank.Mp3Daten[ListenNummer])+1);       

     fmp3.DatenbankListeAusgeben(ListenNummer);
     fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Caption:='';        
   end;
end;
 //////////////////////////////////////////////////////////////////////////////


procedure TFPlayliste.TBXItem_sort0Click(Sender: TObject);
begin
  if (Sender as TTBXItem).ImageIndex = 15
    then
      begin
        (Sender as TTBXItem).ImageIndex := 16;
        fmp3.Datenbank.Sort(ListenNummer,TTBXComboboxItem(FindComponent('TBXCBI'+inttostr((Sender as TTBXItem).Tag))).ItemIndex);
      //  Gliste1.Sort((Sender as TTBXItem).Tag,false);
      end
    else
      begin
        (Sender as TTBXItem).ImageIndex := 15;
        fmp3.Datenbank.Sort(ListenNummer,TTBXComboboxItem(FindComponent('TBXCBI'+inttostr((Sender as TTBXItem).Tag))).ItemIndex,false);
      end;
   fmp3.DatenbankListeAusgeben(ListenNummer);   
end;

procedure TFPlayliste.ToolbarMenuErstellen;   //uk
var
  TBXItem: TTBXItem;
  i       : integer;
begin
  try
    for i := 1 to Anzahl_TBXToolbars_Liste do
      begin
        TBXItem:=TTBXItem.Create(fplayliste);
        TBXItem.Name:='TBX_TB_Item'+inttostr(i);
        TBXItem.Caption:=(FindComponent('TBXToolbar'+IntToStr(i)) as TTBXToolbar).Caption;
        TBXItem.Checked:=(FindComponent('TBXToolbar'+IntToStr(i)) as TTBXToolbar).Visible;
        TBXItem.OnClick:=TBX_TB_ItemClick;
        TBXItem.Tag:=i;
        TBXSubmenuItem3.Add(TBXItem);
        (FindComponent('TBXToolbar'+IntToStr(i)) as TTBXToolbar).Tag:=i;
      end;
  except
    showmessage('Fehler beim Erstellen der Toolbar-Menüleiste');
  end;
end;

procedure TFPlayliste.TBX_TB_ItemClick(Sender: TObject);   //uk
begin
  (Sender as TTBXItem).Checked := not (Sender as TTBXItem).Checked;
  (FindComponent( 'TBXToolbar'+IntToStr((Sender as TTBXItem).Tag)) as
    TTBXToolbar).Visible := (Sender as TTBXItem).Checked;
end;

procedure TFPlayliste.TBXToolbar1Close(Sender: TObject);
begin
try
  (FindComponent('TBX_TB_Item'+IntToStr((Sender as TTBXToolbar).Tag)) as
    TTBXItem).Checked := false;
except
  showmessage('Fehler beim Ändern des Checked-Status.');
end;
end;

procedure TFPlayliste.TBXToolbar2VisibleChanged(Sender: TObject);
begin
fmp3.FPlaylisten[ListenNummer].StringGrid.Visible:=
  not fmp3.FPlaylisten[ListenNummer].StringGrid.Visible;
end;

procedure TFPlayliste.TBXItem1Click(Sender: TObject);
begin
  Minimieren;
end;

procedure TFplayliste.Minimieren;
begin
  fmp3.FPlaylisten[ListenNummer].WindowState:=wsMinimized;
end;

procedure TFPlayliste.TBXItem7Click(Sender: TObject);
begin
  fmp3.Spiele(Listennummer,
                strtoint(GListe1.Liste.Nummer[gliste1.MarkiertesElement]));
end;

procedure TFPlayliste.TBXItem8Click(Sender: TObject);
begin
  fmp3.Umbenennen(ListenNummer,
                strtoint(GListe1.Liste.Nummer[gliste1.MarkiertesElement]));
end;

procedure TFPlayliste.TBXItem9Click(Sender: TObject);
begin
  Maximieren;
end;

procedure TFPlayliste.Maximieren;
begin
if fmp3.FPlaylisten[ListenNummer].WindowState=wsMaximized
  then fmp3.FPlaylisten[ListenNummer].WindowState:=wsNormal
  else fmp3.FPlaylisten[ListenNummer].WindowState:=wsMaximized;
end;

procedure TFPlayliste.ESChange(Sender: TObject);
begin
  Gliste1.ersterEintrag:=0;
  fmp3.Suche(ListenNummer,Es.Text);
end;

procedure TFplayliste.RescanFolders;
begin
  fmp3.Datenbank.RescanFolders(ListenNummer);
  fmp3.DatenbankListeAusgeben(ListenNummer);
end;

procedure TFPlayliste.TBXItem10Click(Sender: TObject);
begin
  RescanFolders;
end;

procedure TFplayliste.Addfile;
begin
  if fmp3.ODMedia.Execute
  then fmp3.AddFiles(ListenNummer,TStringlist(fmp3.ODMedia.Files));
end;

procedure TFPlayliste.TBXItem11Click(Sender: TObject);
begin
  Addfile;
end;

procedure TFPlayliste.TBXItem5Click(Sender: TObject);
begin
  fmp3.ErzeugeNeuePlayliste;
  fmp3.Datenbank.KopiereDoppelteMedienInAndereListe(ListenNummer,
        High(fmp3.Datenbank.Mp3Daten));
  fmp3.DatenbankListeAusgeben(High(fmp3.Datenbank.Mp3Daten));
end;

procedure TFPlayliste.TBXItem3Click(Sender: TObject);
begin
  fmp3.ListeAnfuegenOrdner;
end;

procedure TFPlayliste.TBXItem4Click(Sender: TObject);
begin
  fmp3.ListeSpeichern(ListenNummer);
end;

procedure TFPlayliste.ListenEintraegeAuslesen;
begin
  AusleseThread := TAusleseThread.Create(true);
  Auslesethread.FreeOnTerminate:=true;
  Auslesethread.Resume;
end;

procedure TFPlayliste.TBXItem12Click(Sender: TObject);
begin
  fmp3.ElementLoeschen(ListenNummer,strtoint(Gliste1.Liste.Nummer[
                                                   Gliste1.markiertesElement]));
end;

procedure TFPlayliste.TBXItem13Click(Sender: TObject);
var filename:string;
begin
  if fmp3.Datenbank.GetMediumFullFileName(ListenNummer,
     strtoint(Gliste1.Liste.Nummer[Gliste1.markiertesElement]),filename)
  then fmp3.OpenFolderAndMarkFile(filename);
end;

procedure TFPlayliste.TBXItem14Click(Sender: TObject);
begin
  fmp3.Datenbank.Sort(ListenNummer,20); //Spezialsortierung
  fmp3.DatenbankListeAusgeben(ListenNummer);
end;

procedure TFPlayliste.TBXItem15Click(Sender: TObject);
begin
tbxcbI0.ItemIndex:=4;
end;

procedure TFPlayliste.FormShow(Sender: TObject);
begin
  ToolbarMenuErstellen;
  TBXCBI0.ItemIndex:=1; //Dauer
  TBXCBI1.ItemIndex:=0; //Interpret - Titel / Dateiname
  TBXCBI2.ItemIndex:=7; //Album
  TBXCBI3.ItemIndex:=9; //Genre
  TBXCBI4.ItemIndex:=8; //Jahr
end;

procedure TFPlayliste.TBXItCopyFilesClick(Sender: TObject);
begin
  CopyThread := TCopyThread.Create(true);
  CopyThread.FreeOnTerminate:=true;
  CopyThread.Resume;
end;

{ TCopyThread }

procedure TCopyThread.Execute;
var i,ListenNummer : integer;
    FileList       : TStringList;
    Zielpfad       : string;
begin
  inherited;
  ListenNummer:=fmp3.Aktiv.Liste;

  BreakFlag:=false;
  closeflag:=false;

  FileList:= TStringList.Create;

  if (fmp3.datenbank.GetShownFiles(ListenNummer,FileList)) and
     (fmp3.PathD.Execute) then
  begin
   Zielpfad:=fmp3.PathD.Path;
   if DirectoryExists( Zielpfad ) then
   begin
     fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Max := FileList.Count;
     fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Caption:='Kopiere...';
     fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Position := 0;
     fmp3.Fplaylisten[ ListenNummer ].LStatus.Caption:='Abbrechen';
     for i:=0 to FileList.Count-1 do
     begin
      if not Copyfile( pchar( FileList[i] ),
                       pchar( includetrailingbackslash(Zielpfad)
                                +extractfilename(FileList[i]) ),true)
      then
        if MessageDlg('Die Datei "'+FileList[i]+'" konnte nicht kopiert werden.'
                        +#13+'Fortfahren?',mtwarning,[mbyes,mbno],0)=mrno
        then break;

      if BreakFlag then break;

      fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Position := i;
     end;
     fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Position := 0;
     fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Caption:='';
     fmp3.Fplaylisten[ ListenNummer ].LStatus.Caption:='';
   end;
  end;
  closeflag:=true;
end;

procedure TFPlayliste.LStatusClick(Sender: TObject);
begin
  LStatus.Caption:='Breche ab...';
  BreakFlag:=true;
end;

end.

