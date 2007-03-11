unit gliste2;
{
//PLZ DO NOT USE THAT COMPONENT, CAUSE IT IS NOOB

<Grafische Liste>

Grafische Stringlistenausgabe (also eine Listbox)

Programmiert mit Delphi 7  / BDS 3.0 PE
Das Design entspricht nicht modernen ergonomischen Gepflogenheiten,
 sondern meiner Unfähigkeit

-'Denglischer' Code, weil ich deutsch angefangen habe und zu faul bin alles
  zu übersetzen
-Extrem unsicherer, umständlicher und unverständlicher Code sowie Übergabeparameter

© Clemens Grünewald
0.1.0  01.07.2004 - 20.07.2004
- initial release
0.1.1
- bugfixing im Zuge der Emat-Entwicklung
0.2   28.07.2004
- ~standalonerelease
 + EmatPfeile
0.2.1 <=20.10.2004
- Bugfixing
- keine EmatPfeile mehr
0.2.2 29.02.05
- Bugfixing
0.3   04.02.05
- dyn Array Struktur
0.3.1
- keine dyn Array Struktur mehr aus Performancegründen
0.3.2   08.03.05
- PopupMenu                     //uk
0.3.3   25.04.05
0.3.4   27.04.05
- Bugfix (markieren/spulen bug) & (letztes Item anscrollen)
0.3.5
- Quicksort (Umkehrquicksort trotzem noch erforderlich!)
0.3.5a
- kleiner Fix
0.3.5b   27.06.05
- rechter Rand
0.3.5c   01.08.05
- Mausüberzeichenbug
0.3.6
- Resizebug workaround, kein Fix (siehe Draw)
0.3.7
- MinimizeName für Spalten, die Pfad enthalten. //uk
0.3.8
- Focusbug searching...and workaround
0.3.9
- Gradient testing
0.3.99
- "'`SingleColMode´'" //<-- Ventilator Name
0.3.999
- Globale Variablen in den private Teil
  (KEIN IMPLEMENTATION -> verhindert Abhängigkeit)
0.4.0
- Demarkiermöglichkeit (der Hauptmarkierung)
0.4.1   22.12.05
- Markiermöglichkeit   (flag-Auswertung)
0.4.2   31.12.2005
- Scrollbar->optische Verbesserung
0.4.3   29.05.2006
- MultiSelect
0.4.4   07.07.2006
- rechter Rand
- freie rechte Spalten werden mitgenutzt
0.4.4b  04.08.2006
0.4.5   11.08.2006
- GetSelectetItems
0.4.5b  15.08.2006
- GetSelectet_ID
0.4.5c  17.08.2006
0.4.5d  03.09.2006
0.4.6   13.09.2006
- Scrollt die Liste hoch/runter, wenn die Markierung 2 Zeilen vor dem Rand steht
  (Anstatt die Markierung immer in die Mitte zu positionieren)
0.4.7   21.09.2006
- Maus kann beim Scrollen auch über der Liste schweben
0.4.8   23/25.9.06
- OnItemMove hinzugefügt
}


interface

uses
  SysUtils, Classes, Controls, Dialogs, Messages, Windows, Forms, Graphics,
  FileCtrl;

const
      zeilenhoehe=15;
      scrollschrittweite=3;
      rand=5;
      randverschiebung=1; //Damit der Rahmen angezeigt wird

type TListenEintraege = record
   {Nummer : integer;
   l0,l1,l2,l3,l4 : string;   //Zu langsam
   markiert : boolean; }
   l0,l1,l2,l3,l4,
   Nummer,markiert: TStringlist;
 end;

type  TRechtsklickevent  = procedure (index, x, y:integer) of object;
type  TDoppelKlickevent  = procedure (index: integer) of object;
type  TElementMarkierenEvent = procedure (index:integer; shift:TShiftState) of object;
type  TSpulenEvent       = procedure (prozent:real) of object;
type  TKeyDownEvent      = procedure (key:word; shift:tshiftstate) of object;
type  TItemMoveEvent     = procedure (Source: TObject; SourcePosition,
                                      SourceID: integer;
                                      Target: TObject; TargetPosition,
                                      TargetID: integer) of object;
type  TDragItemInsertEvent = procedure (Source: TObject; SourcePosition,
                                      SourceID: integer;
                                      Target: TObject; TargetPosition,
                                      TargetID: integer) of object;

type
  Tgliste2 = class(TCustomControl)
  private
    zeilen,altesMouseover,mousedown_x, DragTarget: integer;
    maustaste,flag,initialisiert,darfmausueberzeichnen,dblclickflag,
    BeginMouseScroll,DrawDragTarget: boolean;
    bild, Pfeilauf,Pfeilab: tbitmap;
    mouseX, mouseY: integer;

    scrollbarbreite,scrollbarhoehe : integer;
    FRechtsklick :TRechtsklickevent;
    FDoppelKlick :TDoppelKlickevent;
    FElementMarkierenEvent :TElementMarkierenEvent;
    FSpulenEvent :TSpulenEvent;
    FKeyDown: TKeyDownEvent;
    FItemMove : TItemMoveEvent;
    FDragItemInsert : TDragItemInsertEvent;
    //http://www.delphipraxis.net/topic29032_bescheuertes+mausrad.html
    procedure FOnMouseWheel(var AMsg: TWMMouseWheel); message WM_MOUSEWHEEL;
    //http://swiss.torry.net/de/showcode.php?id=591
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;

    procedure Delay(wartezeit: integer);
    procedure AutoRaufscrollen;
    procedure AutoRunterscrollen;
    procedure SetFirstItembyScroll(y:integer);
    procedure ErzeugePfeile;

    procedure Schreibe(Spalte, Zeile, k: integer);

    { Private-Deklarationen }
  protected
    { Protected-Deklarationen }
  public
      ersterEintrag,markiertesElement,mausueberElement,fortschrittlichesElement,
      Tag2 : integer;
      clhintergrund,clhintergrund_inaktiv,clscrollbar,clmouseover,clmarkiert,
      cltext,clscrollbar2,clfortschritt,clfortschrittrahmen,clhintergrund2:tcolor;
      fortschritt:real;
      schriftart:string;
      rand: array [0..5] of integer;
      col_minimizename: array [0..4] of boolean;
      Liste: TListenEintraege;
      aktiv:boolean;
      SingleColMode, MultiSelect, LineMoving: boolean;

      property canvas;

      constructor Create(AOwner: TComponent);  override;
      destructor Destroy;  override;

      procedure ListenReset;

      procedure KeyDown (var Key: Word; Shift: TShiftState); override;
      procedure Paint; override;
      procedure Click; override;
      procedure DblClick; override;
      procedure Resize; override;

      procedure MouseDown( Button: TMouseButton;
                      Shift: TShiftState; X, Y: Integer); override;
      procedure MouseMove (Shift: TShiftState; X,Y: Integer); override;
      procedure MouseUp( Button: TMouseButton;
                      Shift: TShiftState; X, Y: Integer); override;
      procedure DragOver(Source: TObject; X, Y: Integer;
                State: TDragState; var Accept: Boolean); override;
      procedure DragDrop(Source: TObject; X, Y: Integer); override;
 //     procedure EndDrag(Source: TObject; X, Y: Integer); override;
      procedure SetFortschritt(prozent: real);
      procedure SetFortschrittlichesElement(element: integer);
      procedure Draw;
      procedure Raufscrollen;
      procedure Runterscrollen;
      procedure decMarkiertesElement;
      procedure incMarkiertesElement;
      function GetVersion:string;
      function GetZeilen:integer;
      procedure Add (Nummer:integer;markiert:boolean; l0,l1,l2,l3,l4 :string);

      procedure dbg(test:integer);
      procedure SetMainColor(Color: TColor);
      procedure Sort(SortColindex: byte; AtoZ:boolean=true);

      procedure SetGradient(Gradient:boolean);
      function GetMultiSelectetItems_ID(var ItemList:TStringList):boolean;

      //Liefert neben den MultiSelectetItems gegebenenfalls auch das
      //markierte Element (Jeweils die .Nummer Information)
      function GetSelectetItems(var IDList:TStringList):boolean;

      //Liefert das markierteElement (NICHT den .Nummer Eintrag)
      function GetSelectet:integer;

      //Liefert den .Nummer Eintrag
      function GetSelectet_ID:integer;

      //Verschiebt Items innerhalb der Listen
      procedure ItemMove(currentIndex,newIndex:integer);

      //Löscht Elemente
      procedure ItemDelete(Index:integer);

      //Fügt Elemente ein
      procedure ItemInsert(Index,Nummer:integer; markiert:boolean;
                               l0,l1,l2,l3,l4 :string);

      function GetFirstMultiSelectedItem(var Index:integer):boolean;

    { Public-Deklarationen }
  published
      property OnRechtsklick: TRechtsklickevent read FRechtsklick write FRechtsklick;
      property OnDoppelklick: TDoppelKlickevent read FDoppelKlick write FDoppelKlick;
      property OnSpulen: TSpulenevent read FSpulenevent write FSpulenevent;
      property OnKeyDown: TKeyDownevent read FKeyDown write FKeyDown;
      property OnElementMarkieren: TElementMarkierenEvent
                      read FElementMarkierenevent write FElementMarkierenevent;
      property OnItemMove: TItemMoveEvent read FItemMove write FItemMove;
      property OnDragItemInsert: TDragItemInsertEvent read FDragItemInsert
               write FDragItemInsert;
    { Published-Deklarationen }
      property OnDragDrop;
      property OnDragOver;
      property OnStartDrag;
      property OnEndDrag;
      property OnEnter;
      property OnExit;
      property PopupMenu;
      property Font;
      property OnKeyPress;
  end;

procedure Register;

implementation

var gradientback : boolean;

procedure Register;
begin
  RegisterComponents('Beispiele', [Tgliste2]);
end;

constructor Tgliste2.Create(AOwner: TComponent);
var
  i: integer;
begin
  inherited Create(AOwner);
  TabStop := true;
  DoubleBuffered:=true;
  dblclickflag:=false;
  maustaste:=false;
  BeginMousescroll:=false;
  DrawDragTarget:=false;
  DragTarget:=-1;
  aktiv:=false;
  LineMoving:=false;
  Tag2:=0;

  //Listenzeichnungsinitialisierung
  bild:= Tbitmap.Create;
  bild.Width:= self.Width;
  bild.Height:= self.Height;
  bild.Canvas.Font := Font;
  zeilen:=height div zeilenhoehe;

  scrollbarbreite:=22;
  scrollbarhoehe:=20;
  erstereintrag:=0;
  markiertesElement:=-1;
  fortschrittlichesElement:=-1;
  clhintergrund:=$EDEDED;
  clhintergrund_inaktiv:=$00C8C8C8;
  clmouseover:=$0078B0EE; //$00BDCDAD;
  clmarkiert:=clwhite;
  clscrollbar:=$0078B0EE;
  clscrollbar2:=$0078B0EE;
  cltext:=clblack;
  clfortschritt:=$0078B0EE;
  clfortschrittrahmen:=$0078B0EE;
  gradientback:=true;
  SingleColMode := false;
  MultiSelect   := false;

  mausueberElement:=-1;
  ErzeugePfeile;

  //SetLength(Liste,0);
  Liste.l0:=TStringlist.Create;
  Liste.l1:=TStringlist.Create;
  Liste.l2:=TStringlist.Create;
  Liste.l4:=TStringlist.Create;
  Liste.l3:=TStringlist.Create;
  Liste.Nummer:=TStringlist.Create;
  Liste.markiert:=TStringlist.Create;

  for i := 0 to High(col_minimizename) do
  begin
    col_minimizename[i] := false;
  end;

  initialisiert:=true;

end;

destructor Tgliste2.destroy;
begin;
   //code here....
 {   bild.free;
    pfeilab.Free;
    pfeilauf.Free;
    liste.l0.free;
    liste.l1.free;
    liste.l2.free;
    liste.l3.free;
    liste.l4.free;
  }
   inherited Destroy;
end;


procedure Tgliste2.SetGradient(Gradient:boolean);
begin
  gradientback:=Gradient;
end;


procedure Tgliste2.paint;
begin;
  inherited;
  draw;
end;



procedure Tgliste2.ListenReset;
begin
   liste.l0.Clear;
   liste.l1.Clear;
   liste.l2.Clear;
   liste.l3.Clear;
   liste.l4.Clear;
   liste.Nummer.Clear;
   liste.markiert.Clear;

   markiertesElement:=-1;
   fortschrittlichesElement:=-1;
   ersterEintrag:=0;
end;

procedure Tgliste2.ItemDelete(Index:integer);
begin
   if index< liste.l0.Count
   then
     begin
     liste.l0.Delete(index);
     liste.l1.Delete(index);
     liste.l2.Delete(index);
     liste.l3.Delete(index);
     liste.l4.Delete(index);
     liste.Nummer.Delete(index);
     liste.markiert.Delete(index);

     if Index<markiertesElement then dec(markiertesElement);
     if Index<fortschrittlichesElement then dec(fortschrittlichesElement);
     end;
end;

procedure Tgliste2.ItemInsert(Index,Nummer:integer; markiert:boolean;
                               l0,l1,l2,l3,l4 :string);
begin
   if index< liste.l0.Count
   then
     begin
     liste.l0.Insert(Index,l0);
     liste.l1.Insert(index,l1);
     liste.l2.Insert(index,l2);
     liste.l3.Insert(index,l3);
     liste.l4.Insert(index,l4);
     liste.Nummer.Insert(index,inttostr(Nummer));
     liste.markiert.Insert(index,booltostr(markiert));

     if Index<=markiertesElement then inc(markiertesElement);
     if Index<=fortschrittlichesElement then inc(fortschrittlichesElement);
     end;
end;

procedure Tgliste2.Add(Nummer:integer; markiert:boolean; l0,l1,l2,l3,l4 :string);
begin
{  SetLength(Liste,High(Liste)+2);

  Liste[High(Liste)].Nummer:=Nummer;
  Liste[High(Liste)].l0:=l0;
  Liste[High(Liste)].l1:=l1;
  Liste[High(Liste)].l2:=l2;
  Liste[High(Liste)].l3:=l3;
  Liste[High(Liste)].l4:=l4;

  Liste[High(Liste)].markiert:=markiert; }

  liste.l0.Add(l0);
  liste.l1.Add(l1);
  liste.l2.Add(l2);
  liste.l3.Add(l3);
  liste.l4.Add(l4);
  liste.Nummer.Add(inttostr(Nummer));
  liste.markiert.Add(booltostr(markiert));
end;


procedure Tgliste2.Draw;
  procedure DrawGradient(const Canvas: TCanvas; Color1, Color2: TColor; Rect: TRect);
  var
   Y, R, G, B: Integer;
   RColor1, GColor1, BColor1: Integer;
   RColor2, GColor2, BColor2: Integer;
  begin
   Color1:=ColorToRGB(Color1);
   Color2:=ColorToRGB(Color2);

   RColor1:=GetRValue(Color1);
   GColor1:=GetGValue(Color1);
   BColor1:=GetBValue(Color1);

   RColor2:=GetRValue(Color2);
   GColor2:=GetGValue(Color2);
   BColor2:=GetBValue(Color2);

   Canvas.Pen.Width:=1;
   Canvas.Pen.Style:=psInsideFrame;

   for Y:=Rect.Top to Rect.Bottom-1 do
   begin
     R:=Round(RColor1 + ((RColor2 - RColor1) * Y / (Rect.Bottom - Rect.Top)));
     G:=Round(GColor1 + ((GColor2 - GColor1) * Y / (Rect.Bottom - Rect.Top)));
     B:=Round(BColor1 + ((BColor2 - BColor1) * Y / (Rect.Bottom - Rect.Top)));

     Canvas.Brush.Color:=RGB(R, G, B);
     Canvas.FillRect(Classes.Rect(Rect.Left, Y, Rect.Right, Y+1));
   end;
  end;


procedure DMarkierung;
begin
  with bild do begin
    canvas.Pen.Color:=clmarkiert;
    canvas.Brush.Color:=clmarkiert;
    canvas.Rectangle(
        0,
        (markiertesElement-ersterEintrag)*zeilenhoehe+randverschiebung,
        width,
        (markiertesElement-ersterEintrag+1)*zeilenhoehe+randverschiebung);
  end;
end;


procedure DMouseOver;
begin
  with bild do begin
  if darfmausueberzeichnen then
  begin
    canvas.Pen.Color:=clmouseover;
    canvas.Brush.Color:=clmouseover;
    canvas.Rectangle(
        0,
        (mausueberElement-ersterEintrag)*zeilenhoehe+randverschiebung,
        width,
        (mausueberElement-ersterEintrag+1)*zeilenhoehe+randverschiebung);
  end;
  end;
end;


procedure DText;
var i,k,l  : integer;
begin
  with bild do begin

    if liste.l0.Count-1>=0 then          //wenn Liste nicht leer
    begin

    canvas.Font.Color:=cltext;
    canvas.Font.Name:=schriftart;

    k:=0;
    for i:=erstereintrag to erstereintrag+zeilen do
      begin
        if i<liste.l0.Count             //falls weniger Einträge als darstellbar
        then
         begin

          if (focused) or (aktiv) then
          begin
            canvas.Pen.Color:=clhintergrund;
           // canvas.Brush.Color:=Canvas.Pixels[1,zeilenhoehe*k+1];
            canvas.Brush.Color:=clblue;
          end
          else
          begin
            canvas.Pen.Color:=clhintergrund_inaktiv;
            canvas.Brush.Color:=clhintergrund_inaktiv;
          end;

          if i=markiertesElement
           then canvas.Brush.Color:=clmarkiert
           else
            if (i=mausueberElement) and (darfmausueberzeichnen)
             then canvas.Brush.Color:=clmouseover;

          if strtobool(liste.markiert[i])
           then canvas.Font.Style:=[fsunderline]
           else canvas.Font.Style:=[];

          canvas.brush.style:=bsClear;
            //Textausgabe
          for l:=0 to 4 do Schreibe(l,i,k);

          inc(k);
          canvas.brush.style:=bssolid;
          end

          else
          break;
         end;

      end;
  end;
end;


procedure DHintergrund;
begin
  with bild do begin
    //Löschen  bzw. Hintergrund
    if (focused) or (aktiv) then
    begin
      canvas.Pen.Color:=clhintergrund;
      canvas.Brush.Color:=clhintergrund;
    end
    else
    begin
      canvas.Pen.Color:=clhintergrund_inaktiv;
      canvas.Brush.Color:=clhintergrund_inaktiv;
    end;
    if (gradientback) and ((focused) or (aktiv))
    then
       drawgradient(canvas,clhintergrund,clhintergrund2,clientrect)
    else
    canvas.Rectangle(0,0,width,height);

 end;
end;


procedure DFortschritt;
begin
  with bild do begin
    //Fortschritt hervorheben
    if (ersterEintrag<=fortschrittlichesElement) and (ersterEintrag+zeilen>fortschrittlichesElement)
       and (fortschrittlichesElement<>-1)
    then
    begin
     { if (fortschrittlichesElement = mausueberElement) and
                              (fortschrittlichesElement <> markiertesElement) then
      begin
        canvas.Pen.Color:=clblack;
        canvas.Brush.Color:=clblack;
      end else
      begin
        canvas.Pen.Color:=clfortschritt;
        canvas.Brush.Color:=clfortschritt;
      end;   }

    canvas.Pen.Color:=(clfortschritt + clblack) div 2;
    canvas.Brush.Color:=canvas.Pen.Color;

    canvas.RoundRect(trunc(fortschritt*(self.width-scrollbarbreite)-3),
                    (fortschrittlichesElement-ersterEintrag)*zeilenhoehe+randverschiebung,
                     trunc(fortschritt*(self.width-scrollbarbreite)+3),
                    (fortschrittlichesElement-ersterEintrag+1)*zeilenhoehe+randverschiebung, 0,0);




     { if (fortschrittlichesElement = mausueberElement) and
                              (fortschrittlichesElement <> markiertesElement) then
      begin
        canvas.Pen.Color:=clblack;
        canvas.Brush.Color:=clblack;
      end else
      begin
        canvas.Pen.Color:=clfortschrittrahmen;
        canvas.Brush.Color:=clfortschrittrahmen;
      end;  }

    canvas.MoveTo(0,(fortschrittlichesElement-ersterEintrag)*zeilenhoehe+randverschiebung);
    canvas.LineTo(self.width,(fortschrittlichesElement-ersterEintrag)*zeilenhoehe+randverschiebung);
    canvas.MoveTo(0,(fortschrittlichesElement-ersterEintrag+1)*zeilenhoehe+randverschiebung);
    canvas.LineTo(self.width,(fortschrittlichesElement-ersterEintrag+1)*zeilenhoehe+randverschiebung);
    end;

  end;
end;


procedure DRahmen;
begin
  with bild do begin
   canvas.Pen.Color:=clmouseover;
   canvas.Pen.Width:=1;
   canvas.MoveTo(self.width-1,0);
   canvas.LineTo(0,0);
   canvas.LineTo(0,self.Height-1);
   canvas.LineTo(self.width-1,self.Height-1);
   canvas.LineTo(self.width-1,0);
 end;
end;


procedure DScrollbar;
var scroll, zeichenhoehe : integer;
    prozent: extended;
begin
  with bild do begin
    //Scrollbar
   if liste.l0.Count>zeilen
   then
   begin
        scrollbarbreite:=22;
        canvas.Pen.Color:=clscrollbar;
        canvas.Brush.Color:=clhintergrund;

        canvas.Rectangle(width-scrollbarbreite,0,width,height);

        canvas.Brush.Color:=clscrollbar;

          //Anzeigebalken
        prozent:=ersterEintrag / (liste.l0.Count-zeilen);
        if prozent>1 then prozent:=1;

        zeichenhoehe:= height-pfeilauf.Height*2;
        scrollbarhoehe:=round(zeilen/(liste.l0.Count)*zeichenhoehe);
        if scrollbarhoehe<10 then scrollbarhoehe:=20;

        dec(zeichenhoehe,scrollbarhoehe);

        scroll:=round( prozent
                       * ( zeichenhoehe)
                       + pfeilauf.Height + scrollbarhoehe div 2);


        canvas.Rectangle( width-scrollbarbreite+2 , scroll - scrollbarhoehe div 2,
                          width-2 , scroll + scrollbarhoehe div 2 );

        //Auf-Ab-Pfeil
        canvas.Draw( width-scrollbarbreite+1 , 1 , Pfeilauf);
        canvas.Draw( width-scrollbarbreite+1 , height-pfeilab.Height-1 , Pfeilab);


   end
   else scrollbarbreite:=0;
  end;
end;


procedure DDragTarget;
begin
  if DrawDragTarget then
    with bild do
    begin
      canvas.Pen.Color:=clmouseover;
      canvas.Brush.Color:=clmouseover;
      canvas.Rectangle(
        0,
        (DragTarget-ersterEintrag)*zeilenhoehe+randverschiebung-3,
        width,
        (DragTarget-ersterEintrag)*zeilenhoehe+randverschiebung+3 );
    end;
end;

//var timetemp:integer;        DrawZeitmessung

begin
  //timetemp:=Gettickcount;

  if not initialisiert then abort;

  if (ersterEintrag<0) or (ersterEintrag>liste.l0.Count-1)
    then ersterEintrag:=0;
  if markiertesElement>liste.l0.Count-1
    then markiertesElement:=-1;
  if mausueberElement>liste.l0.Count-1
    then mausueberElement:=-1;

  bild.Width:=width;
  bild.Height:=height;

  //Die 5. Spalte bekommt immer die volle Breite
  rand[5]:=width;

  DHintergrund;
  DMouseOver;
  DMarkierung;
  DFortschritt;
  DRahmen;
  DText;
  DDragTarget;
  DScrollbar;

  canvas.Draw(0,0,bild);

  //showmessage(inttostr(gettickcount-timetemp));
end;

procedure Tgliste2.Schreibe(Spalte,Zeile,k:integer);
  function GetText(Spalte,Zeile:integer):string;
  begin
    case Spalte of
      0: Result:=liste.l0[Zeile];
      1: Result:=liste.l1[Zeile];
      2: Result:=liste.l2[Zeile];
      3: Result:=liste.l3[Zeile];
      4: Result:=liste.l4[Zeile];
    end;
  end;

var randrechts,randlinks,verfuegbareBreite, i:integer;
    verkuerzterText,text : string;
begin


  text:=GetText(Spalte,Zeile);

  randlinks:=rand[Spalte];

  //Wenn Nachbarzelle leer, dann deren Raum nutzen
  i := 1;
  if Spalte < 4
  then
  while (GetText(Spalte+i, Zeile)='') and (Spalte + i < 5) do
  begin
    inc(i);
  end;

  randrechts := rand[Spalte+i];

  if randrechts > width - scrollbarbreite
  then randrechts := width - scrollbarbreite + 8;

  //Wenns nicht reinpasst, 8 Pixel Abstand-Sichheitszone
  verfuegbareBreite:= randrechts-randlinks-8;

  if bild.canvas.TextWidth(text)>verfuegbareBreite
  then
  begin
    if not col_minimizename[spalte]
    then
    begin
      verkuerzterText:=text;
      repeat
        verkuerzterText:=copy(verkuerzterText,1,length(verkuerzterText)-1);
      until (bild.canvas.TextWidth(verkuerzterText+'...')<verfuegbareBreite)
              or (length(verkuerzterText)=0);

      bild.canvas.TextOut(randlinks,zeilenhoehe*k+randverschiebung,verkuerzterText+'...');
    end
    else
    begin
      Text:=minimizename(text, bild.Canvas, randrechts-randlinks);
      bild.canvas.TextOut(randlinks,zeilenhoehe*k+randverschiebung,text);
    end;
  end
  else bild.canvas.TextOut(randlinks,zeilenhoehe*k+randverschiebung,text);

end;


procedure Tgliste2.KeyDown (var Key: Word; Shift: TShiftState);

var B_draw : boolean;

begin
  inherited;

   if not focused then
   begin
     parent.Setfocus;
     self.SetFocus;
   end;

  B_draw:=true;

  case key of
    vk_up   : decMarkiertesElement;
    vk_down : incMarkiertesElement;
    vk_next : Runterscrollen;
    vk_prior: Raufscrollen;
  else B_Draw:=false;
  end;

  if B_Draw then draw;

  if assigned(OnKeyDown) then OnKeyDown(key,Shift);

end;





procedure Tgliste2.incMarkiertesElement;
begin
 //Wenn es schon das letzte Element ist, kann man nicht noch weiter gehen
 //Ein Überlauf wird zwar von Draw verhindert, verursacht aber beim
 //OnElementMarkieren Fehler, deshalb die if Abrage um Fehler zu vermeiden
 if markiertesElement<liste.l0.Count-1 then
 begin
   inc(markiertesElement);

   //Scrollt die Liste runter, wenn die Markierung 2 Zeilen vor dem Rand steht
   //Die zweite Abfrage verhindert das obige, wenn man ganz unten am Ende ist
   if (markiertesElement +3>ersterEintrag+zeilen)
      and (markiertesElement+1<liste.l0.Count-1)
   then inc(ersterEintrag);

   if assigned(OnElementMarkieren) then OnElementMarkieren(markiertesElement,[]);

   draw;
 end;
end;

procedure Tgliste2.decMarkiertesElement;
begin
 if markiertesElement>0
 then
 begin
   dec(markiertesElement);

   //Scrollt die Liste hoch, wenn die Markierung 2 Zeilen vor dem Rand steht
   if markiertesElement-2<ersterEintrag
   then dec(ersterEintrag);

   if assigned(OnElementMarkieren) then OnElementMarkieren(markiertesElement,[]);

   draw;
 end;
end;


procedure Tgliste2.FOnMouseWheel(var AMsg: TWMMouseWheel);
begin
  if AMsg.WheelDelta>0 then raufscrollen;
  if AMsg.WheelDelta<0 then runterscrollen;
end;

procedure Tgliste2.click;
begin
  inherited;
end;

procedure Tgliste2.dblclick;
begin
  inherited;

  if mousedown_x<width-scrollbarbreite then    //wenn auf Liste
  begin
   dblclickflag:=true;

   if (Assigned(OnDoppelklick)) and ( markiertesElement<>-1)
   then OnDoppelklick(markiertesElement);
  end;
end;

procedure Tgliste2.mousedown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var markiert,i:integer;
begin
 inherited;
   if not focused then
   begin
     parent.Setfocus;
     self.SetFocus;
   end;

  maustaste:=true;
  markiert:=((y-randverschiebung) div zeilenhoehe) + ersterEintrag;

  if (markiert<=liste.l0.Count-1)
  then
   begin
   //wenn auf Liste
   if x<width-scrollbarbreite then
    begin
     if (button=mbleft) then BeginDrag(false);

      //Mit Strg einzelne Items markieren
      if (MultiSelect) and (ssCtrl in Shift)
       then liste.markiert[markiert]:=
                        BoolToStr(not StrToBool(liste.markiert[markiert]));

      //Mit Shift alle zwischen neuem und altem MarkiertemElement markieren
      if (MultiSelect) and (ssShift in Shift) and (MarkiertesElement<>-1)
       then
         begin
           if MarkiertesElement<markiert
           then
             for i:=MarkiertesElement to markiert do
               liste.markiert[i]:=BoolToStr(true)
           else
             for i:=MarkiertesElement downto markiert do
               liste.markiert[i]:=BoolToStr(true)
         end;

//Markierung wieder aufheben
      if (MultiSelect) and (not(ssShift in Shift) and not(ssCtrl in Shift))
          and (button=mbleft)
      then
        for i:=0 to liste.markiert.Count-1 do
          liste.markiert[i]:=BoolToStr(false);
//

      if markiertesElement<>markiert
      then
       begin
          markiertesElement:=markiert;
          if Assigned(OnElementMarkieren) then OnElementMarkieren(markiert,shift);

       end
      else
        begin
          if (markiert=fortschrittlichesElement) and (button=mbleft)
                and (not dblclickflag)
           then
            begin
             if Assigned(OnSpulen)
             then
              begin
              OnSpulen(x/(width-scrollbarbreite));
              SetFortschritt( x/(width-scrollbarbreite) );
              end;
           end;
         end;
     dblclickflag:=false;
     draw;


      if (button=mbright) then
       begin      //rechte Taste
         if Assigned(OnRechtsklick)
         then
          begin
          OnRechtsklick(markiert, x, y);
          end;
       end;

   end
   else
   begin   //wenn auf Scrollbar
     SetFirstItembyScroll(y);
     BeginMouseScroll:=true;
     draw;
   end;

   mousedown_x:=x;
   end
  else
   begin
    markiertesElement:=-1;
    draw;
   end;

end;


procedure Tgliste2.SetFirstItembyScroll(y:integer);
begin
  if y<=pfeilauf.Height then AutoRaufscrollen
  else
    if y>=(height-pfeilab.Height) then AutoRunterscrollen
    else
      if y<pfeilauf.Height+scrollbarhoehe div 2
      then ersterEintrag:=0
      else
        if y>self.height-pfeilauf.Height-scrollbarhoehe div 2
        then ersterEintrag:=liste.l0.Count-zeilen
        else
          begin //Errechne Position
              ersterEintrag:=round(
                            (y -pfeilab.Height - scrollbarhoehe div 2 )
                             / (self.Height - 2*pfeilab.Height - scrollbarhoehe)
                             *(liste.l0.Count-zeilen));
          end;
end;


procedure Tgliste2.SetFortschritt(prozent:real);
begin
  Fortschritt:=prozent;
  Draw;
end;

procedure Tgliste2.SetFortschrittlichesElement(element:integer);
begin
   FortschrittlichesElement:=element;
   fortschritt:=0;
   Draw;
end;

procedure Tgliste2.mousemove (Shift: TShiftState; X,Y: Integer);
begin
inherited;

  //Nur wenn Maus neben der Scrollbar auf der Liste ist
  if (x<width-scrollbarbreite) and (not BeginMousescroll) then
   begin
     mausueberElement:=(y-randverschiebung) div zeilenhoehe + ersterEintrag;

     if mausueberElement<=liste.l0.Count-1 then
       begin
          darfmausueberzeichnen:=true;

          //nur wenn wirklich neues gemausübert wird
          if (altesMouseover<>mausueberElement) and (mausueberElement>-1) then
          begin
            draw;
            altesMouseover:=mausueberElement;
            flag:=true;
          end;

          //nicht wenn über Markiertem
          if (mausueberElement=markiertesElement) and (flag) then
           begin
             mausueberElement:=-1;
             draw;
             flag:=false;
           end;
       end
     else
       begin
         mausueberelement:=-1;
         if darfmausueberzeichnen then draw;
         darfmausueberzeichnen:=false;
       end;
   end
 else  //wenn ich mich auf der Scrollbar befinde
   begin //auf Scrollbar
    {  if x>width
      then maustaste:=false     //Aus liste herausgehen
      else   }
        begin

          if (y>pfeilauf.Height) and (y<height-pfeilab.Height) then
           while  maustaste do
            begin
              SetFirstItembyScroll(y);
              draw;
              delay(1);
            end;
        end;
   end;

  mouseX := X;
  mouseY := Y;
end;


procedure Tgliste2.mouseup(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  maustaste:=false;
  BeginMousescroll:=false;
end;


procedure Tgliste2.DragOver(Source: TObject; X, Y: Integer; State: TDragState;
                            var Accept: Boolean);
var
    newPosition: integer;
begin
  inherited;
  //Nur wenn Maus neben der Scrollbar auf der Liste ist
  if (x<width-scrollbarbreite) and (not BeginMousescroll) and (Source is tgliste2)
     and (accept)
   then
   begin
     //Errechnet neue Position zwischen 2 Elementen
     //Zone beginnt ein halbes Element über dem Ersten
     newPosition:=(y-randverschiebung+(zeilenhoehe div 2)) div zeilenhoehe
                        + ersterEintrag ;

     if newPosition<0 then newPosition:=0;
     if newPosition>liste.l0.Count then newPosition:=liste.l0.Count;



     if (newPosition<>DragTarget) {and } then
       begin
         DragTarget:=newPosition;

         //Verhindern, dass die Positionsbalken direkt über/unter dem Item gezeichnet wird
         DrawDragTarget:= (DragTarget<>GetSelectet) and
                          (DragTarget<>GetSelectet+1);
         draw;
       end;
   end;
end;


procedure Tgliste2.DragDrop(Source: TObject; X, Y: Integer);
var
   TargetID:integer;
begin
  inherited;
  DrawDragTarget:=false;

  if Source is TGliste2 then
  begin
  //TargetID muss um eins erniedrigt werden, wenn es unter der Markierung ist,
  //da die TargetID zeichentechnisch um eins zu groß ist,
  //weil das markierte Element zwei ungültige Targets beinhaltet
  //Aber nur wenn innerhalb einer Liste gedragt wird
  if (Source=Self) and (DragTarget>GetSelectet) then dec(DragTarget);

  //Bei ungültiger Target ID ober einem Drag ans Ende der Liste liefert das
  //System TargetID := -1

  if (DragTarget>liste.Nummer.Count-1) or
     ((DragTarget<liste.Nummer.Count) and
     (not tryStrToInt(liste.Nummer[DragTarget],TargetID)))
  then TargetID:=-1;

  if (DragTarget<>GetSelectet) then
  begin
    //OnItemMove wird nur durchgeführt wenn INNERHALB der Liste gedraggt wird
    if (Source = Self) then
      begin
        if assigned(OnItemMove) and (DragTarget>=0) and (DragTarget<liste.l0.count)
        then OnItemMove(Source,(Source as Tgliste2).GetSelectet,
                        (Source as Tgliste2).GetSelectet_ID,
                        Self, DragTarget,TargetID);
      end
    else
    //Wenn ein Item von außen kommt
      begin
        if assigned(OnDragItemInsert) and (DragTarget>=0) and (DragTarget<liste.l0.count)
        then OnDragItemInsert(Source,(Source as Tgliste2).GetSelectet,
                        (Source as Tgliste2).GetSelectet_ID,
                        Self, DragTarget,TargetID);
        (Source as TGliste2).DrawDragTarget:=false;
        (Source as TGliste2).draw;
      end;
  end;
  end;
end;

  {
procedure Tgliste2.EndDrag(Source: TObject; X, Y: Integer);
begin
  inherited;
  DrawDragTarget:=false;
end;
   }
procedure Tgliste2.ItemMove(currentIndex,newIndex:integer);
begin
  liste.l0.Move(currentIndex,newIndex);
  liste.l1.Move(currentIndex,newIndex);
  liste.l2.Move(currentIndex,newIndex);
  liste.l3.Move(currentIndex,newIndex);
  liste.l4.Move(currentIndex,newIndex);
  liste.Nummer.Move(currentIndex,newIndex);
  liste.markiert.Move(currentIndex,newIndex);

  if markiertesElement=currentIndex
    then markiertesElement:=newIndex;

  if fortschrittlichesElement=currentIndex
    then fortschrittlichesElement:=newIndex;
end;



procedure Tgliste2.Runterscrollen;
begin
  if ersterEintrag<liste.l0.Count-zeilen
  then inc(ersterEintrag,scrollschrittweite);

  if ersterEintrag>liste.l0.Count-zeilen
  then ersterEintrag:=liste.l0.Count-zeilen;

//  MouseMove([], mouseX, mouseY);
  draw;
end;

procedure Tgliste2.Raufscrollen;
begin
 if erstereintrag>0
 then dec(erstereintrag,scrollschrittweite);

 if erstereintrag<0
 then ersterEintrag:=0;

 draw;
end;

procedure Tgliste2.AutoRunterscrollen;
begin
  while maustaste do
    begin
      runterscrollen;
      delay(60);
    end;

end;

procedure Tgliste2.AutoRaufscrollen;
begin
  while maustaste do
    begin
      raufscrollen;
      delay(60);
    end;
end;

procedure Tgliste2.dbg(test:integer);
begin
  showmessage(inttostr(test));
end;

procedure Tgliste2.Delay(wartezeit: integer);
var
  anfangsseit: integer;
begin
  anfangsseit := GetTickCount;
  while abs(GetTickCount) - anfangsseit <= wartezeit do
    begin
      Application.ProcessMessages;
      Sleep(1);
    end;
end;

function Tgliste2.GetVersion:string;
begin
  result := Version;
end;

procedure Tgliste2.resize;
begin
  inherited;

  zeilen := height div zeilenhoehe;
  bild.Width := self.Width;
  bild.Height := self.height;

  if SingleColMode then
  begin
    Rand[1] := width-scrollbarbreite;
    Rand[2] := width-scrollbarbreite + 1;
    Rand[3] := width-scrollbarbreite + 1;
    Rand[4] := width-scrollbarbreite + 1;
    Rand[5] := width-scrollbarbreite + 1;
  end
  else
    rand[5] := width-scrollbarbreite;

end;

function Tgliste2.GetZeilen:integer;
begin
  Result:=zeilen;
end;

procedure Tgliste2.ErzeugePfeile;
var Punkte: array of TPoint;
    Rand: integer;
begin
  setlength(Punkte,3);
  Rand:=3;

(*pfeilauf*)

  Pfeilauf:= TBitmap.Create;
  Pfeilauf.Width :=20;
  Pfeilauf.Height :=20;

  Punkte[0].X:=Pfeilauf.Width div 2;
  Punkte[0].Y:=rand;
  Punkte[1].X:=rand;
  Punkte[1].Y:=Pfeilauf.Height-rand;
  Punkte[2].X:=Pfeilauf.Width-rand;
  Punkte[2].Y:=Pfeilauf.Height-rand;

  Pfeilauf.Canvas.Pen.Color:=clhintergrund;
  Pfeilauf.Canvas.Brush.Color:=clscrollbar;
  Pfeilauf.Canvas.Rectangle(0,0,Pfeilauf.Width,Pfeilauf.Height);

  Pfeilauf.Canvas.Pen.Color:=clblack;
  Pfeilauf.Canvas.Brush.Color:=clblack;
  Pfeilauf.Canvas.Polygon(Punkte);


(*pfeilab*)

  Pfeilab:= TBitmap.Create;
  Pfeilab.Width :=20;
  Pfeilab.Height :=20;

  Punkte[0].X:=rand;
  Punkte[0].Y:=rand;
  Punkte[1].X:=Pfeilab.Width-rand;
  Punkte[1].Y:=rand;
  Punkte[2].X:=Pfeilab.Width div 2;
  Punkte[2].Y:=Pfeilab.Height-rand;

  Pfeilab.Canvas.Pen.Color:=clhintergrund;
  Pfeilab.Canvas.Brush.Color:=clscrollbar;
  Pfeilab.Canvas.Rectangle(0,0,Pfeilab.Width,Pfeilab.Height);

  Pfeilab.Canvas.Pen.Color:=clblack;
  Pfeilab.Canvas.Brush.Color:=clblack;
  Pfeilab.Canvas.Polygon(Punkte);
end;

procedure Tgliste2.SetMainColor(Color: TColor);
begin
    clscrollbar:=Color;
    clscrollbar2:=Color;
    clfortschritt:=Color;
    clfortschrittrahmen:=Color;
    clmouseover:=Color;
    ErzeugePfeile;
    Draw;
end;

    //Die Funktion liefert die liste.NUMMER Information!
function TGliste2.GetMultiSelectetItems_ID(var ItemList:TStringList):boolean;
var i: integer;
begin
  Result:=false;
  ItemList.Clear;

  for i:=0 to liste.markiert.Count-1 do
    begin
      if liste.markiert[i]=BoolToStr(true)
      then
        begin
          Result:=true;
          ItemList.Add(liste.Nummer[i]);
        end;
    end;
end;


function TGliste2.GetFirstMultiSelectedItem(var Index:integer):boolean;
var i:integer;
begin
  Result:=false;
  Index:=-1;

  for i:=0 to liste.markiert.Count-1 do
    begin
      if liste.markiert[i]=BoolToStr(true)
      then
        begin
          Result:=true;
          Index:=i;
          break;
        end;
    end;
end;


function Tgliste2.GetSelectetItems(var IDList:TStringList):boolean;
var markiertesElement:integer;
begin
  if GetMultiSelectetItems_ID(IDList)
  then
    Result:=true
  else
    begin
      markiertesElement:=GetSelectet;
      if markiertesElement>=-1 then
        begin
          IDList.Clear;
          IDList.Add(liste.Nummer[markiertesElement]);
          Result:=true;
        end
      else
        Result:=false;
    end;
end;

//Liefert den Index des Markierten, nicht die .Nummer eigentschaft
function Tgliste2.GetSelectet:integer;
begin
  if (markiertesElement<>-1) and (markiertesElement<liste.l0.Count)
  then Result:=markiertesElement
  else Result:=-1;
end;

//Liefert die .Nummer eigenschaft
function Tgliste2.GetSelectet_ID:integer;
begin
  Result:=GetSelectet;
  if (Result<>-1)
  then Result:=strtoint(liste.nummer[Result]);
end;


procedure Tgliste2.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  message.Result := message.Result or DLGC_WANTARROWS;
end;


procedure Tgliste2.Sort( SortColIndex:byte; AtoZ:boolean=true);

 procedure QuickSort(var A: TStringlist; iLo, iHi: Integer);
  var
    Lo, Hi  : Integer;
    Mid : string;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2];
    repeat
      while lowercase(A[Lo]) < lowercase(Mid) do Inc(Lo);
      while lowercase(A[Hi]) > lowercase(Mid) do Dec(Hi);
      if Lo <= Hi then
      begin
        liste.l0.Exchange(Lo,Hi);
        liste.l1.Exchange(Lo,Hi);
        liste.l2.Exchange(Lo,Hi);
        liste.l3.Exchange(Lo,Hi);
        liste.l4.Exchange(Lo,Hi);
        liste.Nummer.Exchange(Lo,Hi);
        liste.markiert.Exchange(Lo,Hi);
  {      T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T; }
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then QuickSort(A, iLo, Hi);
    if Lo < iHi then QuickSort(A, Lo, iHi);
  end;

var
  i{, j, Pos }: Integer;
  //SListe     : ^TStringlist;
begin
            {
case SortColIndex of
//0 : SListe:=@liste.l0;
1 : SListe:=@liste.l1;
2 : SListe:=@liste.l2;
3 : SListe:=@liste.l3;
4 : SListe:=@liste.l4;
else SListe:=@liste.l0;
end;


  for i := 0 to SListe.Count-2 do
  begin
    Pos := i;
    for j := i+1 to SListe.Count-1 do
     begin
      if AtoZ
        then
          if lowercase(SListe.Strings[j]) > lowercase(SListe.Strings[Pos])
            then Pos := j ;

      if not AtoZ then
          if lowercase(SListe.Strings[j]) < lowercase(SListe.Strings[Pos])
            then Pos := j;
     end;
        liste.l0.Exchange(Pos,i);
        liste.l1.Exchange(Pos,i);
        liste.l2.Exchange(Pos,i);
        liste.l3.Exchange(Pos,i);
        liste.l4.Exchange(Pos,i);
        liste.Nummer.Exchange(Pos,i);
        liste.markiert.Exchange(Pos,i);
  end;
        {   }
 //Quicksort

    case SortColIndex of
    1 :  QuickSort(liste.l1,0,liste.l0.Count-1);
    2 :  QuickSort(liste.l2,0,liste.l0.Count-1);
    3 :  QuickSort(liste.l3,0,liste.l0.Count-1);
    4 :  QuickSort(liste.l4,0,liste.l0.Count-1);
    else  QuickSort(liste.l0,0,liste.l0.Count-1);
    end;

if not AtoZ then  //Hier fehlt der Umkehrquicksort !!! (Notbehelf)
  begin
   for i:=0 to ((liste.l0.Count-1) div 2) do
   begin
        liste.l0.Exchange(i,liste.l0.Count-1-i);
        liste.l1.Exchange(liste.l0.Count-1-i,i);
        liste.l2.Exchange(liste.l0.Count-1-i,i);
        liste.l3.Exchange(liste.l0.Count-1-i,i);
        liste.l4.Exchange(liste.l0.Count-1-i,i);
        liste.Nummer.Exchange(liste.l0.Count-1-i,i);
        liste.markiert.Exchange(liste.l0.Count-1-i,i);
   end;
  end;

 markiertesElement:=-1;
 fortschrittlichesElement:=-1;
 ersterEintrag:=0;

 end;



end.
