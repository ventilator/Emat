unit UListe;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,  ShellApi, FileCtrl, ExtCtrls, Buttons, Grids, Menus, StdCtrls,

  LMDCustomControl, LMDCustomPanel, LMDCustomBevelPanel, LMDBaseEdit,
  LMDCustomEdit, LMDEdit, LMDCustomComponent, LMDBaseController,
  LMDCustomContainer, LMDCustomImageList, LMDImageList,

  TBX, TBXProgressBar, TB2Dock, TB2Toolbar, TBXExtItems, TB2Item, TB2ExtItems,
  TBXDkPanels, TBXStatusBars,

  Gliste2, ulang;

const
  AusleseIntervall=100;
  Anzahl_TBXToolbars_Liste = 4;

type
  TAusleseThread = class(TThread)
  public
    procedure Execute; override;
  end;

type
  TCopyThread = class(TThread)
  public//protected
    procedure Execute; override;
  end;


type
  TFPlayliste = class(TForm)
    TBXToolbar: TTBXToolbar;
    TBXCBI0: TTBXComboBoxItem;
    TBXCBI1: TTBXComboBoxItem;
    TBXCBI2: TTBXComboBoxItem;
    TBXCBI3: TTBXComboBoxItem;
    TBXCBI4: TTBXComboBoxItem;
    StringGrid: TStringGrid;
    TBXDock1: TTBXDock;
    TBXItem_sort1: TTBXItem;
    TBXItem_sort0: TTBXItem;
    TBXItem_sort2: TTBXItem;
    TBXItem_sort3: TTBXItem;
    TBXItem_sort4: TTBXItem;
    GBliste: TTBXAlignmentPanel;
    PMliste: TTBXPopupMenu;
    TBXItem3: TTBXItem;
    TBXItem2: TTBXItem;
    TBXItem4: TTBXItem;
    TBXItem1: TTBXItem;
    TBXAlignmentPanel1: TTBXAlignmentPanel;
    TBXAlignmentPanel2: TTBXAlignmentPanel;
    TBXAlignmentPanel3: TTBXAlignmentPanel;
    TBXStatusBar1: TTBXStatusBar;
    TBXI_CopyFileNow: TTBXItem;
    TBXIQueHistory: TTBXItem;
    TBXI_SpaltenWaehlen: TTBXItem;
    TBXSeparatorItem9: TTBXSeparatorItem;
    TBX_Del_Dir: TTBXSubmenuItem;
    TBXI_DelDir_1: TTBXItem;
    TBXI_DelDir_2: TTBXItem;
    TBXI_DelDir_3: TTBXItem;
    TBXI_DelDir_4: TTBXItem;
    procedure PMlistePopup(Sender: TObject);
    procedure TBXI_DelDir_3Click(Sender: TObject);
    procedure TBX_Del_DirSelect(Sender: TTBCustomItem; Viewer: TTBItemViewer;
      Selecting: Boolean);
    procedure TBXIselect_colsClick(Sender: TObject);
    procedure TBXIQueHistoryClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure TBXI_CopyFileNowClick(Sender: TObject);
    procedure TBXButton4Click(Sender: TObject);
    procedure TBXButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure StringGridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TBXCBI0Change(Sender: TObject; const Text: String);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TBXItem6Click(Sender: TObject);
    procedure TBXItem_sort0Click(Sender: TObject);
    procedure TBXToolbarVisibleChanged(Sender: TObject);
    procedure TBXItem7Click(Sender: TObject);
    procedure TBXItem2Click(Sender: TObject);
    procedure TBXItem11Click(Sender: TObject);
    procedure TBXItem3Click(Sender: TObject);
    procedure TBXItem4Click(Sender: TObject);
    procedure TBXItem1Click(Sender: TObject);
    procedure TBXItem15Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  { Private-Deklarationen }
    closeflag     : boolean;
    BreakFlag     : boolean;

    ThreadActive  : boolean;

    procedure GlisteKeyDown(Key:word; Shift:tshiftstate);
    procedure GlisteDragOver(Sender, Source: Tobject; x, y: integer;
      State: TDragState; var accept: boolean);
    procedure GlisteDragDrop(Sender, Source: Tobject; x, y: integer);
    procedure GlisteDoppelklick(index : integer);
    procedure GlisteSpule(Prozent: real);
    procedure GlisteKeyPress(Sender :TObject; var Key:char);
    procedure GlisteElementMarkieren(ElementNummer:integer; Shift:TShiftState);
    procedure GlisteItemMOve(Source: TObject; SourcePosition, SourceID:integer;
                             Target: TObject; TargetPosition, TargetID: integer);
  public
    ListenNummer: integer;
    Gliste1    : TGListe2;
    AusleseThread : TAusleseThread;
    CopyThread    : TCopyThread;

    procedure Addfile;
    procedure ListenEintraegeAuslesen;
    procedure AngezeigteMedienKopieren;
    procedure SetRaender;
    procedure CreateDelDirSubmenues;
    { Public-Deklarationen }
  end;

var
  FPlayliste  : TFPlayliste;



implementation

{$R *.dfm}
uses ump3, UStatus;


procedure TFPlayliste.FormCreate(Sender: TObject);
begin
  GListe1 := TGliste2.create(fplayliste);
  GListe1.Parent := gbliste;
  GListe1.Align := alClient;
  Gliste1.PopupMenu := PMliste;
  Gliste1.OnKeyDown := GlisteKeyDown;
  Gliste1.OnKeyPress := GlisteKeyPress;
  Gliste1.OnDoppelklick := GlisteDoppelklick;
  Gliste1.OnSpulen := GlisteSpule;
  Gliste1.OnElementMarkieren := GlisteElementMarkieren;
  GListe1.OnDragOver:=GlisteDragOver;
  Gliste1.OnDragDrop:=GlisteDragDrop;
  Gliste1.OnItemMove:=GlisteItemMove;
  Gliste1.Font := Font;
  Gliste1.aktiv := true;
  Gliste1.MultiSelect := true;
  Gliste1.LineMoving :=true;
  //Tag2 bezeichnet eine Playlistenliste (für DragOver.accept)
  Gliste1.Tag2:=1;
  SetRaender;

  CopyThread := TCopyThread.Create(true);
  CopyThread.FreeOnTerminate:=true;

  closeflag :=true;
  BreakFlag :=false;

  ThreadActive:= false;
end;

procedure TFPlayliste.GlisteDoppelklick(Index :integer);
begin
  fmp3.Spiele(ListenNummer,strtoint(Gliste1.liste.Nummer[index]),true)
end;


procedure TFPlayliste.GlisteItemMove(Source: TObject; SourcePosition, SourceID:integer;
                                     Target: TObject; TargetPosition, TargetID: integer);
begin
  if Source = Target then
    begin
      fmp3.Datenbank.MoveItem(ListenNummer,SourceID,TargetID);
      fmp3.DatenbankListeAusgeben(ListenNummer,true,false);
    end;
end;


procedure TFPlayliste.GlisteKeyPress(Sender :TObject; var Key:char);
var charset: set of Char;
begin
  charset:=['A'..'Z','a'..'z','Ö','ö','Ä','ä','ü','Ü','ß','´','`','@','_','0'..'9',' '];

  if key in charset then
    Fmp3.Esuche.Text := Fmp3.Esuche.Text + Key;
end;


procedure TFPlayliste.GlisteKeyDown(Key:word;Shift:tshiftstate);
begin
    //Backspace
  if (key = 8) then
    Fmp3.Esuche.Text := Copy(Fmp3.Esuche.Text, 0, Length(Fmp3.Esuche.Text) -1);

  if (key = vk_return) then
    Fmp3.Spiele(ListenNummer, fmp3.Aktiv.MarkiertesElement);

  if (key = vk_right) then
    fmp3.Spule(fmp3.TBXPBar.Position/fmp3.TBXPBar.max+0.05);

  if (key = vk_left) then
    fmp3.Spule(fmp3.TBXPBar.Position/fmp3.TBXPBar.max-0.05);

  if (key = vk_add) then
    fmp3.IncVolume;

  if (key = vk_subtract) then
    fmp3.DecVolume;

  if (key = vk_delete) then
    fmp3.DeleteSelectedItems;

  Gliste1.SetFocus;
end;

procedure TFPlayliste.GlisteDragOver ( Sender, Source:Tobject; x,y: integer;
                                   State: TDragState; var accept:boolean);
begin
  //Tag2 = 1 bezeichnet eine Playlistenliste
  if (Source is TGliste2) and
     (1 = (Source as TGliste2).Tag2)
  then accept:=true
  else accept:=false;

end;

procedure TFPlayliste.GlisteDragDrop(Sender, Source: Tobject; x,y: integer);
var QuellListenNummer,i  : integer;
    ItemIDList           : TStringlist;
begin
  ItemIDList:= TStringList.Create;
  //nicht in sich selbst kopieren
  if (Source is TGliste2) and (Source <> Sender)
     //and ((Source as TGliste2).Name='Gliste1')
     and (Source as TGliste2).GetSelectetItems(ItemIDList)
  then
   begin
     QuellListenNummer:=(Source as TGliste2).tag;

     for i:=0 to ItemIDList.Count-1 do
     begin
       fmp3.Datenbank.CopyItem(QuellListenNummer,strtoint(ItemIDList[i]),ListenNummer);
     end;

     fmp3.DatenbankListeAusgeben(ListenNummer);
   end;
end;

procedure TFPlayliste.FormActivate(Sender: TObject);
var
   AutoPlayStatus:boolean;

begin
  fmp3.Aktiv.Liste:=ListenNummer;
  fmp3.SetListsInaktive(ListenNummer); //Anmerkung: Warum?????   //Wegen Farbe
//  fmp3.Esuche.Text:=fmp3.Datenbank.Mp3DatenMeta[ListenNummer].SuchText ;
                 //wird in datenbanklisteaktualisieren gemacht

  //Damit beim Listenwechsel nicht automatisch beim Eintragen ins Suchfeld
  //das Autoplay anspringt               
  AutoPlayStatus:= fmp3.TBXCBSearchAutoPlay.Checked;
  fmp3.TBXCBSearchAutoPlay.Checked:=false;

  fmp3.DatenbankListeAusgeben(ListenNummer);

  fmp3.TBXCBSearchAutoPlay.Checked:=AutoPlayStatus;

  fmp3.EnableMenues();

  //Setzt den Haken für Spalen wählen
  fmp3.TBXIselect_cols.Checked:=TBXAlignmentPanel3.Visible;
end;

procedure TFPlayliste.GlisteSpule (Prozent :real );
begin
  fmp3.Spule(prozent);
end;

  //Die zurückgegebene ElementNummer ist NICHT die liste.nummer sondern der INDEX
procedure TFPlayliste.GlisteElementMarkieren(ElementNummer:integer; Shift:TShiftState);
begin
  fmp3.Aktiv.MarkiertesElement:=strtoint(Gliste1.liste.Nummer[ElementNummer]);

  //Shift = [] damit bei VK_down auf die GListe auch der id3 Tag aktualisiert wird
  if (Shift = [ssLeft]) or (Shift = [])
  then fmp3.ElementMarkieren(ListenNummer,strtoint(Gliste1.liste.Nummer[ElementNummer]));
  if Shift = [ssAlt,ssLeft]
  then
   begin
   fmp3.Datenbank.History_QueueItem(ListenNummer,strtoint(Gliste1.liste.Nummer[ElementNummer]));
   fmp3.DatenbankListeAusgeben(ListenNummer);
   end;

end;

procedure TFPlayliste.StringGridMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

begin
SetRaender;
end;

procedure TFPlayliste.SetRaender;
var i :integer;
begin
Gliste1.rand[0]:=4;

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
 if fmp3.datenbank.ListeExists(Listennummer) then
 fmp3.Datenbank.Mp3DatenMeta[ListenNummer].AnzeigeSpalten[
 (Sender as TTBXComboboxItem).Tag]:=(Sender as TTBXComboboxItem).ItemIndex;

 fmp3.DatenbankListeAusgeben(ListenNummer);

 StringGrid.Cols[(Sender as TTBXComboboxItem).Tag].Text:=
        (Sender as TTBXComboboxItem).Text;
end;

procedure TFPlayliste.FormClose(Sender: TObject; var Action: TCloseAction);
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

  if ThreadActive
   then
    begin
      MessageDlg('Dieser Liste werden noch Dateien hinzugefügt',
        mtInformation, [mbOk], 0);
      abort;
    end;

  fmp3.ListeSchliessenUndSpeichern(ListenNummer);
  fmp3.EnableMenues(false);
  
  fmp3.GHistory.ListenReset;
  fmp3.GHistory.Draw;
  fmp3.GFavorit.ListenReset;
  fmp3.GFavorit.Draw;

  action:=caFree;
end;

procedure TFPlayliste.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   Fmp3.FormKeyDown(fmp3,Key,Shift);  //?
end;

procedure TFPlayliste.TBXItem6Click(Sender: TObject);
begin

end;

 //////////////////////////////////////////////////////////////////////////////
procedure TAusleseThread.Execute;
var i,ListenNummer : integer;
begin
try
   ListenNummer:=fmp3.Aktiv.Liste; //schwammig

   if fmp3.Datenbank.ListeExists(ListenNummer)
   then
   begin
     i:=0;
     {fmp3.Fplaylisten[ ListenNummer ].TBXAlignmentPanel2.Visible := true;
     fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Caption:='Lese...';   }
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
           {  fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Max :=
                                High(fmp3.Datenbank.Mp3Daten[ListenNummer]);
                                //Es könnten mehr geworden sein
             fmp3.Fplaylisten[ListenNummer].TBXPBauslesen.Position := i;  }
           end;

       inc(i);
     until (i=High(fmp3.Datenbank.Mp3Daten[ListenNummer])+1);

     fmp3.DatenbankListeAusgeben(ListenNummer);
   {  fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Caption:='';
     fmp3.Fplaylisten[ ListenNummer ].TBXAlignmentPanel2.Visible := false;  }
   end;
except
on e: exception do
 begin
  showmessage('[TAuslesethread: Ein Fehler ist erwarteterweise aufgetreten]');
 end;
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

procedure TFPlayliste.TBXToolbarVisibleChanged(Sender: TObject);
begin
fmp3.FPlaylisten[ListenNummer].StringGrid.Visible:=
  not fmp3.FPlaylisten[ListenNummer].StringGrid.Visible;
end;

procedure TFPlayliste.TBXItem7Click(Sender: TObject);
begin
  fmp3.Spiele(Listennummer,
                strtoint(GListe1.Liste.Nummer[gliste1.MarkiertesElement]));
end;

procedure TFPlayliste.TBXItem2Click(Sender: TObject);
begin
  fmp3.Umbenennen(ListenNummer,
                strtoint(GListe1.Liste.Nummer[gliste1.MarkiertesElement]));
end;


procedure TFPlayliste.TBXItem11Click(Sender: TObject);
begin
  Addfile;
end;

procedure TFPlayliste.AddFile;
begin
  if fmp3.ODMedia.Execute
  then fmp3.AddFiles(ListenNummer,TStringlist(fmp3.ODMedia.Files));
end;

procedure TFPlayliste.TBXItem3Click(Sender: TObject);
begin
  fmp3.ListeAnfuegenOrdner;
end;

procedure TFPlayliste.ListenEintraegeAuslesen;

begin
  AusleseThread := TAusleseThread.Create(true);
  Auslesethread.FreeOnTerminate:=true;
  Auslesethread.Resume;
end;

procedure TFPlayliste.TBXItem4Click(Sender: TObject);
begin
  fmp3.DeleteSelectedItems;
end;

procedure TFPlayliste.TBXItem1Click(Sender: TObject);
var filename:string;
begin
  if fmp3.Datenbank.GetMediumFullFileName(ListenNummer,
     strtoint(Gliste1.Liste.Nummer[Gliste1.markiertesElement]),filename)
  then fmp3.OpenFolderAndMarkFile(filename);
end;

procedure TFPlayliste.TBXItem15Click(Sender: TObject);
begin
tbxcbI0.ItemIndex:=4;
end;

procedure TFPlayliste.FormShow(Sender: TObject);
begin
  TBXCBI0.ItemIndex:=1; //Dauer
  TBXCBI1.ItemIndex:=0; //Interpret - Titel / Dateiname
  TBXCBI2.ItemIndex:=7; //Album
  TBXCBI3.ItemIndex:=9; //Genre
  TBXCBI4.ItemIndex:=8; //Jahr
end;

{ TCopyThread }

procedure TCopyThread.Execute;
var i,ListenNummer : integer;
    FileList       : TStringList;
    Zielpfad       : string;
begin
  inherited;
  ListenNummer:=fmp3.Aktiv.Liste;

  fmp3.FPlaylisten[ListenNummer].BreakFlag:=false;
  fmp3.FPlaylisten[ListenNummer].Closeflag:=false;

  FileList:= TStringList.Create;

  if (fmp3.datenbank.GetShownFiles(ListenNummer,FileList))

 then
  begin
     zielpfad:=fmp3.SelDirectory('');
     if DirectoryExists( Zielpfad ) then
     begin
         fmp3.Fplaylisten[ ListenNummer ].TBXAlignmentPanel2.Visible := true;
//ukuk         fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Max := FileList.Count;
//ukuk         fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Caption:='Kopiere...';
//ukuk         fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Position := 0;
//ukuk         fmp3.Fplaylisten[ ListenNummer ].TBXButton4.Caption := 'Abbrechen';
//ukuk         fmp3.Fplaylisten[ ListenNummer ].TBXButton4.Visible := true;
//ukuk         fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Visible := true;

         for i:=0 to FileList.Count-1 do
         begin
          {  if not} Copyfile( pchar( FileList[i] ),
                             pchar( includetrailingbackslash(Zielpfad)+extractfilename(FileList[i]) ),true) ;
          {  then  }
       {      begin
              if MessageDlg('Die Datei "'+FileList[i]+'" konnte nicht kopiert werden.'
                              +#13+'Fortfahren?',mtwarning,[mbyes,mbno],0)=mrno
              then break;
             end;   }
            if fmp3.Fplaylisten[ ListenNummer ].BreakFlag then break;

//ukuk           fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Position := i;
         end;

         fmp3.Fplaylisten[ ListenNummer ].TBXAlignmentPanel2.Visible := false;
//ukuk         fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Position := 0;
//ukuk         fmp3.Fplaylisten[ ListenNummer ].TBXPBauslesen.Caption:='';
//ukuk         fmp3.Fplaylisten[ ListenNummer ].TBXButton4.Caption:='';
     end;
  end;

  FileList.Free;
  fmp3.Fplaylisten[ ListenNummer ].closeflag:=true;
end;

procedure TFPlayliste.AngezeigteMedienKopieren;
begin
  CopyThread.Resume;
end;

procedure TFPlayliste.TBXButton1Click(Sender: TObject);
begin
  fmp3.Fplaylisten[ ListenNummer ].TBXAlignmentPanel3.Visible := not
  fmp3.Fplaylisten[ ListenNummer ].TBXAlignmentPanel3.Visible;
//ukuk  fmp3.Fplaylisten[ ListenNummer ].TBXButton1.Checked :=
//ukuk  fmp3.Fplaylisten[ ListenNummer ].TBXAlignmentPanel3.Visible;
end;

procedure TFPlayliste.TBXButton4Click(Sender: TObject);
begin
//ukuk  TBXButton4.Caption:='Breche ab...';
  BreakFlag:=true;
end;

procedure TFPlayliste.TBXI_CopyFileNowClick(Sender: TObject);


function CopyFileEx(const ASource, ADest: String;
 ARenameCheck: boolean = false): boolean;
var
  sh: TSHFileOpStruct;
begin
  sh.Wnd := Application.Handle;
  sh.wFunc := FO_COPY;

  // String muss mit #0#0 Terminiert werden, um das Listenende zu setzen
  sh.pFrom := PChar(ASource + #0);
  sh.pTo := PChar(ADest + #0);
  sh.fFlags := {fof_Silent or }fof_MultiDestFiles;
  if ARenameCheck then
    sh.fFlags := sh.fFlags or fof_RenameOnCollision;
  Result:=ShFileOperation(sh)=0;
end;

var filename:string;
begin
  if
  fmp3.Datenbank.GetMediumFullFileName(ListenNummer,fmp3.aktiv.MarkiertesElement,FileName)
  then
   if not
   copyfileex(filename,fmp3.aktiv.SelDirPath+extractfilename(filename))
   then showmessage(Filename + ' konnte nicht nach '+fmp3.aktiv.SelDirPath+' kopiert werden');
end;

procedure TFPlayliste.FormResize(Sender: TObject);
begin
  StringGrid.ColWidths[4]:=StringGrid.Width -StringGrid.ColWidths[3]
                                            -StringGrid.ColWidths[2]
                                            -StringGrid.ColWidths[1]
                                            -StringGrid.ColWidths[0]
                                            -1;
  SetRaender;
end;

procedure TFPlayliste.TBXIQueHistoryClick(Sender: TObject);
begin
   fmp3.Datenbank.History_QueueItem(ListenNummer,strtoint(Gliste1.liste.Nummer[Gliste1.markiertesElement]));
   fmp3.DatenbankListeAusgeben(ListenNummer);
end;


procedure TFPlayliste.TBXIselect_colsClick(Sender: TObject);
begin
  Fmp3.TBXIselect_colsClick(sender);
end;

procedure TFPlayliste.CreateDelDirSubMenues;
var FileName:string;
    ElementNummer,i:integer;
    SearchDirList : TStringlist;
begin
  ElementNummer:=Gliste1.GetSelectet_ID;

  for i:=1 to 4 do
  begin
    (FindComponent('TBXI_DelDir_'+inttostr(i)) as  TTBXItem).Caption:='';
    (FindComponent('TBXI_DelDir_'+inttostr(i)) as  TTBXItem).Visible:=false;
  end;

  if Gliste1.GetSelectet_ID<>-1 then
  begin
    fmp3.Datenbank.GetMediumFullFileName(ListenNummer,ElementNummer,FileName);

    SearchDirList:=TStringlist.Create;
    fmp3.Datenbank.GetSearchDir(ListenNummer,SearchDirList);

    for i:=4 downto 1 do
    begin
      FileName:=ExtractFileDir(FileName);

      (FindComponent('TBXI_DelDir_'+inttostr(i)) as  TTBXItem).Caption:=FileName;
      (FindComponent('TBXI_DelDir_'+inttostr(i)) as  TTBXItem).Visible:=true;

      if SearchDirList.IndexOf(FileName)<>-1 then break;
    end;

  end;
end;

procedure TFPlayliste.TBX_Del_DirSelect(Sender: TTBCustomItem;
  Viewer: TTBItemViewer; Selecting: Boolean);
begin
  CreateDelDirSubMenues;
end;

procedure TFPlayliste.TBXI_DelDir_3Click(Sender: TObject);
var Dir:string;
begin
  Dir:=(Sender as TTBXItem).Caption;

  if (dir<>'') and (MessageDlg('Soll der Ordner "'+Dir+'" wirklich in den Papierkorb verschoben werden?'
               +#13+'Tipp: Spielen Sie bitte keines der Medien aus diesem Verzeichnis ab.',
                 mtConfirmation, [mbYes, mbNo], 0)=mrYes) then
    begin
      fmp3.Datenbank.DeleteDirAndItsItems(dir,ListenNummer);
      fmp3.DatenbankListeAusgeben(ListenNummer);
    end;
end;

procedure TFPlayliste.PMlistePopup(Sender: TObject);
var
  i: integer;
  enable: boolean;
begin
  enable := GListe1.markiertesElement <> -1;
  for i := 0 to PMListe.Items.Count - 2 do
  begin
    PMListe.Items.Items[i].Enabled := enable;
  end;
end;

end.
