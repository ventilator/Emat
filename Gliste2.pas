unit gliste2;

{
<Grafische Liste>

Grafische Stringlistenausgabe (also eine Listbox)

Programmiert mit Delphi 7
Das Design entspricht nicht modernen ergonomischen Gepflogenheiten, sondern meinem Geschmack

© Clemens Grünewald
0.1.0  01.07.2004 - 20.07.2004
-initial Release

0.1.1
- bugfixing im Zuge der Emat-Entwicklung

0.2 28.07.2004
- ~standalonerelease
 + EmatPfeile

0.2.1 <=20.10.2004
- Bugfixing 
}

interface

uses
  SysUtils, Classes, Controls, Dialogs, QGraphics, Messages, Windows, Forms, Graphics;

const Version='0.2';
      scrollbarbreite=20;
      scrollbarhoehe=15;
      zeilenhoehe=15;
      scrollbarzeigerhoehe=10;
      scrollschrittweite=3;
      rand=5;

type  TRechtsklickevent = procedure (index, x, y:integer) of object;
type  TDoppelKlickevent = procedure (index:integer) of object;
type  TElementMarkierenEvent = procedure (index:integer) of object;
type  TSpulenEvent = procedure (prozent:real) of object;
type  TKeyDownEvent = procedure (key:word; shift:tshiftstate) of object;

type
  Tgliste2 = class(TCustomControl)
  private
    FRechtsklick :TRechtsklickevent;
    FDoppelKlick :TDoppelKlickevent;
    FElementMarkierenEvent :TElementMarkierenEvent;
    FSpulenEvent :TSpulenEvent;
    FKeyDown: TKeyDownEvent;
    procedure ZeichneScrollbar;
    procedure FOnMouseWheel(var AMsg: TWMMouseWheel); message WM_MOUSEWHEEL;  //
    //http://www.delphipraxis.net/topic29032_bescheuertes+mausrad.html
    // naja.... alles kann ich auch net ;-); danke an SirThornberry und Schneck

    procedure Delay(wartezeit: integer);
    procedure AutoRaufscrollen;
    procedure AutoRunterscrollen;


    { Private-Deklarationen }
  protected
    { Protected-Deklarationen }
  public
      ersterEintrag,markiertesElement,mausueberElement,fortschrittlichesElement:integer;
      clhintergrund,clhintergrund_inaktiv,clscrollbar,clmouseover,clmarkiert,cltext,clscrollbar2,clfortschritt,clfortschrittrahmen:tcolor;
      fortschritt:real;
      schriftart:string;
      aktiv:boolean;
      property canvas;

      constructor create(AOwner: TComponent);  override;
      destructor destroy;  override;

      procedure Initialisize(linkerrand,rechterrand:integer);
      procedure ListenReset;
      procedure Delete(Index: integer);
      procedure Add(links, mitte, rechts: string);      

      procedure keypress(var key:char); override;
      procedure keydown (var Key: Word; Shift: TShiftState); override;
      procedure paint; override;
      procedure click; override;
      procedure dblclick; override;
      procedure resize; override;

      procedure mousedown( Button: TMouseButton;
                      Shift: TShiftState; X, Y: Integer); override;
      procedure mousemove (Shift: TShiftState; X,Y: Integer); override;
      procedure mouseup( Button: TMouseButton;
                      Shift: TShiftState; X, Y: Integer); override;
      procedure MouseLeave(AControl: TControl); dynamic;
      procedure SetLinkerrand(linkerrand: integer);
      procedure SetRechterrand(rechterrand: integer);
      procedure SetFortschritt(prozent: real);
      procedure SetFortschrittlichesElement(element: integer);
      procedure Draw;
      procedure Raufscrollen;
      procedure Runterscrollen;
      procedure decMarkiertesElement;
      procedure incMarkiertesElement;
      function GetVersion:string;
      function GetZeilen:integer;

      procedure dbg(test:integer);
    { Public-Deklarationen }
  published
      liste,listelr,listerr:TStringlist;
      property OnRechtsklick: TRechtsklickevent read FRechtsklick write FRechtsklick;
      property OnDoppelklick: TDoppelKlickevent read FDoppelKlick write FDoppelKlick;
      property OnSpulen: TSpulenevent read FSpulenevent write FSpulenevent;
      property OnKeyDown: TKeyDownevent read FKeyDown write FKeyDown;
      property OnElementMarkieren: TElementMarkierenEvent
                      read FElementMarkierenevent write FElementMarkierenevent;
    { Published-Deklarationen }
      property OnDragDrop;
      property OnDragOver;
      property OnStartDrag;
      property OnEndDrag;
      property OnEnter;
      property OnExit;
  end;

procedure Register;

implementation

uses ump3;                                                                                            //Emat
                                                           //Pfeilaufabscroll
var zeilen,randlinks,randrechts,altesMouseover,mousedown_x, scroll:integer;
var maustaste,flag,dblclickflag,dblclickflag2,initialisiert,darfmausueberzeichnen:boolean;
    bild, Pfeilauf,Pfeilab: tbitmap;  
              //flag: gegen mousover-flackern

procedure Register;
begin
  RegisterComponents('Beispiele', [Tgliste2]);
end;

constructor Tgliste2.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TabStop := true;
  DoubleBuffered:=true;
  dblclickflag:=false;
  dblclickflag2:=false;
  initialisiert:=false;


  //Listenzeichnungsinitialisierung
  bild:= Tbitmap.Create;
  bild.Width:= 1600;           //net so doll
  bild.Height:= 1200;         //aber ich bin müd



  Pfeilauf:= TBitmap.Create;
  Pfeilauf.Width :=16;
  Pfeilauf.Height :=16;
  fmp3.ILSymbolleiste.GetBitmap( 7 , Pfeilauf);   //Emat


  Pfeilab:= TBitmap.Create;
  Pfeilab.Width :=16;
  Pfeilab.Height :=16;
  fmp3.ILSymbolleiste.GetBitmap( 8 , Pfeilab);   //Emat
  

end;

destructor Tgliste2.destroy;
begin;
   liste.Free;
   listelr.Free;
   listerr.Free;
   inherited Destroy;
end;

procedure Tgliste2.paint;
begin;
draw;
  inherited Paint;
end;


procedure Tgliste2.Initialisize(linkerrand,rechterrand:integer);
begin
  zeilen:=height div zeilenhoehe;
  randlinks:=linkerrand;
  randrechts:=rechterrand;
  liste:=TStringlist.Create;
  listelr:=TStringlist.Create;
  listerr:=TStringlist.Create;

  erstereintrag:=0;
  markiertesElement:=0;
  clhintergrund:=$EDEDED;
  clmouseover:=$00BDCDAD;
  clmarkiert:=clwhite;
  clscrollbar:=$00BDCDAD;
  clscrollbar2:=$00BDCDAD;
  cltext:=clblack;
  clfortschritt:=$00BDCDAD;
  clfortschrittrahmen:=$00BDCDAD;
  clhintergrund_inaktiv:=$00C8C8C8;

  mausueberElement:=-1;
  initialisiert:=true;
end;

procedure Tgliste2.ListenReset;
begin
   liste.Free;
   listelr.Free;
   listerr.Free;

   liste:=TStringlist.Create;
   listelr:=TStringlist.Create;
   listerr:=TStringlist.Create;

   markiertesElement:=-1;
   fortschrittlichesElement:=-1;
   //ersterEintrag:=0;                       EMAT-Mod für ArrayZuListe bei minimalen Listenoperationen
end;

procedure Tgliste2.Delete(Index:integer);
begin
  liste.Delete(index);
  listelr.Delete(Index);
  listerr.Delete(index);
end;

procedure Tgliste2.Add(links,mitte,rechts:string);
begin
  liste.Add(mitte);
  listelr.Add(rechts);
  listerr.Add(links);
end;

procedure Tgliste2.SetLinkerrand(linkerrand:integer);
begin
   randlinks:=linkerrand;
end;

procedure Tgliste2.SetRechterrand(rechterrand:integer);
begin
   randrechts:=rechterrand;
end;

procedure Tgliste2.Draw;
var i,k,m,breite     :integer;
    verkuerzterText :string;
begin
if not initialisiert then exit;

breite:=width;        //blöde with-do Anweisung!!! Wie heißt die Komponente selbst?

if ersterEintrag<0 then ersterEintrag:=0;          //warum weiß ich nicht mehr... zur Sicherheit?
if ersterEintrag>liste.Count-1 then ersterEintrag:=liste.Count-1;
if markiertesElement>liste.Count-1 then markiertesElement:=liste.Count-1;

with bild do begin

     //Löschen
  if aktiv then
  begin
  canvas.Pen.Color:=clhintergrund;
  canvas.Brush.Color:=clhintergrund;
  end
  else begin
  canvas.Pen.Color:=clhintergrund_inaktiv;
  canvas.Brush.Color:=clhintergrund_inaktiv;
  end;
  canvas.Rectangle(0,0,width,height);

  //Mausüber hervorheben
  if darfmausueberzeichnen then begin
  canvas.Pen.Color:=clmouseover;
  canvas.Brush.Color:=clmouseover;
  canvas.Rectangle(0,(mausueberElement-ersterEintrag)*zeilenhoehe,
                      width,(mausueberElement-ersterEintrag+1)*zeilenhoehe);
  end;

  //Markietes hervorheben
  canvas.Pen.Color:=clmarkiert;
  canvas.Brush.Color:=clmarkiert;
  canvas.Rectangle(0,(markiertesElement-ersterEintrag)*zeilenhoehe,
                      breite,(markiertesElement-ersterEintrag+1)*zeilenhoehe);


  //Text
  if liste.Count>0 then begin           //Wenn Liste nicht leer

  canvas.Font.Color:=cltext;
  canvas.Font.Name:=schriftart;

  k:=0;
  for i:=erstereintrag to erstereintrag+zeilen do
    begin
    if i=liste.Count then break;                           //falls weniger Einträge als darstellbar

    if aktiv then
    begin
      canvas.Pen.Color:=clhintergrund;
      canvas.Brush.Color:=clhintergrund;
    end
    else begin
      canvas.Pen.Color:=clhintergrund_inaktiv;
      canvas.Brush.Color:=clhintergrund_inaktiv;
    end;

    if i=mausueberElement then canvas.Brush.Color:=clmouseover;

    if i=markiertesElement then canvas.Brush.Color:=clmarkiert;

    canvas.TextOut(rand,zeilenhoehe*k,listerr[i]);

    if canvas.TextWidth(liste[i])>breite-randrechts-randlinks //Wenns nicht reinpasst...
    then
     begin
       verkuerzterText:=liste[i];
       repeat
        verkuerzterText:=copy(verkuerzterText,1,length(verkuerzterText)-1);
       until (canvas.TextWidth(verkuerzterText+'...')<breite-randrechts-randlinks)
              or (length(verkuerzterText)=0);

      canvas.TextOut(randlinks,zeilenhoehe*k,verkuerzterText+'...');
     end
    else canvas.TextOut(randlinks,zeilenhoehe*k,liste[i]);
    canvas.TextOut(breite-canvas.TextWidth(listelr[i])-scrollbarbreite-rand,zeilenhoehe*k,listelr[i]);
    inc(k);
    end;

    end;
      //Fortschritt hervorheben
  if (ersterEintrag<=fortschrittlichesElement) and (ersterEintrag+zeilen>fortschrittlichesElement) then begin
  canvas.Pen.Color:=clfortschritt;
  canvas.Brush.Color:=clfortschritt;
  canvas.Pen.Mode:=pmmask;

  canvas.RoundRect(trunc(fortschritt*(breite-scrollbarbreite)-3),
                  (fortschrittlichesElement-ersterEintrag)*zeilenhoehe,
                   trunc(fortschritt*(breite-scrollbarbreite)+3),
                  (fortschrittlichesElement-ersterEintrag+1)*zeilenhoehe ,2,2);
  canvas.Pen.Mode:=pmcopy;

  canvas.Pen.Color:=clfortschrittrahmen;
  canvas.Brush.Color:=clfortschrittrahmen;
  canvas.MoveTo(0,(fortschrittlichesElement-ersterEintrag)*zeilenhoehe);
  canvas.LineTo(breite,(fortschrittlichesElement-ersterEintrag)*zeilenhoehe);
  canvas.MoveTo(0,(fortschrittlichesElement-ersterEintrag+1)*zeilenhoehe);
  canvas.LineTo(breite,(fortschrittlichesElement-ersterEintrag+1)*zeilenhoehe);

  end;
 end;
    //Scrollbar ;-)
   ZeichneScrollbar;

   canvas.Draw(0,0,bild);
end;

procedure Tgliste2.ZeichneScrollbar;

begin

  bild.canvas.Pen.Color:=clscrollbar;
  bild.canvas.Brush.Color:=clhintergrund;
  bild.canvas.Rectangle(width-scrollbarbreite,0,width,height);
  bild.canvas.Brush.Color:=clscrollbar;
  bild.canvas.Rectangle(width-scrollbarbreite,0,width,scrollbarhoehe);
  bild.canvas.Rectangle(width-scrollbarbreite,height-scrollbarhoehe,width,height);
    //Anzeigebalken
  scroll:=trunc( (ersterEintrag / (liste.Count-zeilen)* ( (height-scrollbarhoehe*2)) + scrollbarhoehe ));
  bild.canvas.Brush.Color:=clscrollbar2;
  bild.canvas.Rectangle( width-scrollbarbreite , scroll-scrollbarzeigerhoehe ,  width , scroll+scrollbarzeigerhoehe );

    //Auf-Ab-Pfeil
  bild.canvas.Draw( width-scrollbarbreite+2 , 0 , Pfeilauf);
  bild.canvas.Draw( width-scrollbarbreite+2 , height-scrollbarhoehe , Pfeilab);

end;


procedure Tgliste2.KeyPress (var Key:char);
begin
//
  inherited KeyPress (Key);
end;

procedure Tgliste2.KeyDown (var Key: Word; Shift: TShiftState);
begin
  case key of
  VK_DOWN   : Runterscrollen;
  VK_UP     : Raufscrollen;
  VK_NEXT	  : Runterscrollen;
  VK_PRIOR  : Raufscrollen;
  65      : decMarkiertesElement;
  89      : incMarkiertesElement;
  end;
  inherited KeyDown (Key,Shift);
  if assigned(OnKeyDown) then OnKeyDown(key,Shift);
end;

procedure Tgliste2.incMarkiertesElement;
begin
 if markiertesElement<liste.count
 then
 begin
   inc(markiertesElement);

   if markiertesElement+zeilen div 2>ersterEintrag+zeilen   //Läuft wahrscheinlich über Grenze
   then inc(ersterEintrag);                                          //wird aber von draw aufgefangen
                                                                           //;-)
   draw;
 end;
end;

procedure Tgliste2.decMarkiertesElement;
begin
 if markiertesElement>0
 then
 begin
   dec(markiertesElement);
   if markiertesElement+zeilen div 2>ersterEintrag
   then dec(ersterEintrag);
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
   Setfocus;
end;

procedure Tgliste2.dblclick;
begin
  if mousedown_x<width-scrollbarbreite then begin   //wenn auf Liste

   fortschrittlichesElement:=markiertesElement;
   dblclickflag:=true;
   dblclickflag2:=false;
   fortschritt:=0;

   if fortschrittlichesElement<=high(ump3.mp3s) then
   if Assigned(OnDoppelklick) then OnDoppelklick(markiertesElement);

   inherited dblclick;
  end;
end;

procedure Tgliste2.mousedown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var markiert:integer;
begin
if assigned(OnEnter) then OnEnter(fmp3);

maustaste:=true;
markiert:=y div zeilenhoehe + ersterEintrag;
IF (markiert>liste.Count-1) then exit;

   if x<width-scrollbarbreite then begin   //wenn auf Liste
      if markiertesElement<>markiert then begin
          markiertesElement:=markiert;
          if Assigned(OnElementMarkieren) then OnElementMarkieren(markiert);
          BeginDrag(false);
          end;                                                 //linke Taste
      if (markiert=fortschrittlichesElement) and (button=mbleft) and (dblclickflag2) then begin
         if Assigned(OnSpulen)
         then
          begin
          OnSpulen(x/(width-scrollbarbreite));
          SetFortschritt( x/(width-scrollbarbreite) );
          end;

         end;
      if dblclickflag then begin dblclickflag2:=true;  dblclickflag:=false; end; //Fortschrittspreventing
                                                                                 //beim erstem Markieren

      if (button=mbright) then begin      //rechte Taste
         if Assigned(OnRechtsklick)
         then
          begin
          draw;
          OnRechtsklick(markiert, x, y);
          end;
         end;

      draw;

   end
   else begin   //wenn auf Scrollbar

        if y<scrollbarhoehe then AutoRaufscrollen;
        if y>(height-scrollbarhoehe) then AutoRunterscrollen;
        if (y>scrollbarhoehe) and (y<(height-scrollbarhoehe)) then begin
            ersterEintrag:=trunc( (y-scrollbarhoehe)/(height-scrollbarhoehe*2 ) * (liste.Count-1-zeilen) );
            draw;
            end;
   end;

   mousedown_x:=x;
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
if x<width-scrollbarbreite then begin   //nur wenn neben der Scrollbar
        mausueberElement:=y div zeilenhoehe + ersterEintrag;

   IF  mausueberElement<liste.Count then begin

      darfmausueberzeichnen:=true;

      if (altesMouseover<>mausueberElement) and (mausueberElement>-1) then begin //nur wenn wirklich neues gemausübert wird
        draw;
        altesMouseover:=mausueberElement;
        flag:=true;
      end;

      if (mausueberElement=markiertesElement) and (flag) then begin   //nicht wenn über Markiertem
         mausueberElement:=-1;
         draw;
         flag:=false;
      end;
     end else begin
        mausueberelement:=-1;
        if darfmausueberzeichnen then draw;
        darfmausueberzeichnen:=false; 
        end;

end else begin //auf Scrollbar
        if (y>scrollbarhoehe) and (y<(height-scrollbarhoehe)) then
         while  maustaste do begin
            ersterEintrag:=trunc( (y-scrollbarhoehe-1)/(height-scrollbarhoehe*2-1 ) * (liste.Count-zeilen+7) );
            draw;                                                                   //alles ein bisschen
            delay(1);                                                               //schwammig
          end;

end;

end;



procedure Tgliste2.MouseLeave(AControl: TControl);
begin

maustaste:=false;    //stimmt ja gar net
end;



procedure Tgliste2.mouseup(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
maustaste:=false;

end;



procedure Tgliste2.Runterscrollen;
begin
    inc(ersterEintrag,scrollschrittweite);
    if ersterEintrag>liste.count-zeilen then ersterEintrag:=liste.count-zeilen;
    Draw;

end;

procedure Tgliste2.Raufscrollen;
begin
   dec(erstereintrag,scrollschrittweite);
   if erstereintrag<0 then erstereintrag:=0;
   Draw;

end;

procedure Tgliste2.AutoRunterscrollen;
begin
while maustaste do begin
    runterscrollen;
    delay(60);
 end;

end;

procedure Tgliste2.AutoRaufscrollen;
begin
while maustaste do begin
    raufscrollen;
    delay(60);
 end;
end;

procedure Tgliste2.dbg(test:integer);
begin
 showmessage(inttostr(test));

end;

PROCEDURE Tgliste2.Delay(wartezeit: integer);
VAR anfangsseit:integer;
  BEGIN
    anfangsseit := GetTickCount;
      WHILE abs(GetTickCount) - anfangsseit <= wartezeit do  BEGIN
        Application.ProcessMessages;
        Sleep(1);
      END;
  END;

function Tgliste2.GetVersion:string;
begin
  result:=Version;
end;

procedure Tgliste2.resize;
begin
  zeilen:=height div zeilenhoehe;  
inherited resize;
end;

function Tgliste2.GetZeilen:integer;
begin
  Result:=zeilen;
end;


end.
