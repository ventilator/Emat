unit ump3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, XPStyleActnCtrls, ActnMan, MPlayer, StdCtrls, Buttons,
  ExtCtrls, CheckLst, ComCtrls, Menus, uinfo, ToolWin, ActnCtrls, ActnMenus,
  XProgress, ActnColorMaps;

type
  Tfmp3 = class(TForm)
    LBdateien: TListBox;
    LEpfad: TLabeledEdit;
    od: TOpenDialog;
    mp: TMediaPlayer;
    ActionManager: TActionManager;
    FindeDateien: TAction;
    ll: TLabel;
    Timer: TTimer;
    lp: TLabel;
    popm: TPopupMenu;
    Umbenennen1: TMenuItem;
    cbdel: TCheckBox;
    GBPfad: TGroupBox;
    Tlame: TTimer;
    AMMB: TActionMainMenuBar;
    ARandomsort: TAction;
    AHDDDel: TAction;
    ABeenden: TAction;
    AInfo: TAction;
    AEinstellungen: TAction;
    Amp3toolzeigen: TAction;
    Amp3AnPlayerAnfuegen: TAction;
    LBSuche: TListBox;
    gbsuche: TGroupBox;
    lesuche: TLabeledEdit;
    LSuchErg: TLabel;
    sbxps: TScrollBar;
    Astyle: TAction;
    APause: TAction;
    XPCM: TXPColorMap;
    Lstatus: TLabel;
    GBstat: TGroupBox;
    procedure FindeDateienExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LBdateienClick(Sender: TObject);
    procedure LBdateienKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LEpfadKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure LEpfadKeyPress(Sender: TObject; var Key: Char);
    procedure CustomizeDlg1Close(Sender: TObject);
    procedure Umbenennen1Click(Sender: TObject);
    procedure LBdateienMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure brandomsortClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TlameTimer(Sender: TObject);
    procedure AOptionShowExecute(Sender: TObject);
    procedure AInfoExecute(Sender: TObject);
    procedure ACloseExecute(Sender: TObject);
    procedure ARandomsortExecute(Sender: TObject);
    procedure Amp3toolzeigenExecute(Sender: TObject);
    procedure Amp3AnPlayerAnfuegenExecute(Sender: TObject);
    procedure lesucheChange(Sender: TObject);
    procedure xpChange(Sender: TObject);
    procedure xpMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sbxpsChange(Sender: TObject);
    procedure xpMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure LBSucheEnter(Sender: TObject);
    procedure LBSucheExit(Sender: TObject);
    procedure APauseExecute(Sender: TObject);
    procedure xpMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LEpfadEnter(Sender: TObject);
    procedure LEpfadExit(Sender: TObject);

  private
    procedure erstellexps;
    procedure begrenzesb;
    { Private-Deklarationen }
  public
    procedure tausch(var a,b:string);
    { Public-Deklarationen }
  end;

const fmp3Version='0.2.5d';
      xpbreite=670;

var
  fmp3: Tfmp3;
  dl:tstringlist;
  farbe,schriftfarbe,mp3playerpfad:string;
  aktivesObjekt:tobject;
  xps : array [0..50] of TXProgress;
  mslezterklick,XPmarkiertes:integer;
  stylemode,shuffle:boolean;
  stylescroll:boolean;
  xptext,xpinaktiv,xpaktiv,xpmausueber,xpbar,xpbar2:tcolor;
implementation

uses UOption, Ump3player;

{$R *.dfm}

function GetConsoleOutput(const Command: String; var Output, Errors: TStringList): Boolean;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  SecurityAttr: TSecurityAttributes;
  PipeOutputRead: THandle;
  PipeOutputWrite: THandle;
  PipeErrorsRead: THandle;
  PipeErrorsWrite: THandle;
  Succeed: Boolean;
  Buffer: array [0..255] of Char;
  NumberOfBytesRead: DWORD;
  Stream: TMemoryStream;
begin
  //Initialisierung ProcessInfo
  FillChar(ProcessInfo, SizeOf(TProcessInformation), 0);

  //Initialisierung SecurityAttr
  FillChar(SecurityAttr, SizeOf(TSecurityAttributes), 0);
  SecurityAttr.nLength := SizeOf(SecurityAttr);
  SecurityAttr.bInheritHandle := true;
  SecurityAttr.lpSecurityDescriptor := nil;

  //Pipes erzeugen
  CreatePipe(PipeOutputRead, PipeOutputWrite, @SecurityAttr, 0);
  CreatePipe(PipeErrorsRead, PipeErrorsWrite, @SecurityAttr, 0);

  //Initialisierung StartupInfo
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb:=SizeOf(StartupInfo);
  StartupInfo.hStdInput := 0;
  StartupInfo.hStdOutput := PipeOutputWrite;
  StartupInfo.hStdError := PipeErrorsWrite;
  StartupInfo.wShowWindow := sw_Hide;
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;

  if  CreateProcess(nil, PChar(command), nil, nil, true,
  CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil,
  StartupInfo, ProcessInfo) then begin
    result:=true;
    //Write-Pipes schließen
    CloseHandle(PipeOutputWrite);
    CloseHandle(PipeErrorsWrite);

    //Ausgabe Read-Pipe auslesen
    Stream := TMemoryStream.Create;
    try
      while true do begin
        succeed := ReadFile(PipeOutputRead, Buffer, 255, NumberOfBytesRead, nil);
        if not succeed then break;
        Stream.Write(Buffer, NumberOfBytesRead);
      end;
      Stream.Position := 0;
      Output.LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
    CloseHandle(PipeOutputRead);

    //Fehler Read-Pipe auslesen
    Stream := TMemoryStream.Create;
    try
      while true do begin
        succeed := ReadFile(PipeErrorsRead, Buffer, 255, NumberOfBytesRead, nil);
        if not succeed then break;
        Stream.Write(Buffer, NumberOfBytesRead);
      end;
      Stream.Position := 0;
      Errors.LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
    CloseHandle(PipeErrorsRead);

    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
    CloseHandle(ProcessInfo.hProcess);
  end
  else begin
    result:=false;
    CloseHandle(PipeOutputRead);
    CloseHandle(PipeOutputWrite);
    CloseHandle(PipeErrorsRead);
    CloseHandle(PipeErrorsWrite);
  end;
end;

function markiertes(sender:tobject):string;
var erg:string;
begin
//if ((sender as tlistbox).ItemIndex>=0) AND ((sender as tlistbox).ItemIndex<(sender as tlistbox).Items.Count)
 erg:=(sender as tlistbox).items[(sender as tlistbox).ItemIndex] ;
result:=erg;
end;

procedure Tfmp3.erstellexps;
var i:integer;
begin
xptext:=clteal;
xpinaktiv:=clbtnface;
xpaktiv:=clwhite;
xpmausueber:=clcream;
xpbar:=clred;
xpbar2:=clwhite;

for i:=0 to 37 do
  begin
  xps[i]:=TXProgress.create(fmp3);
  with xps[i] do
  begin
  Left:=5;
  Top:=80+i*xps[i].Height;
  Caption:=inttostr(i);
  Width:=xpbreite;
  Position:=0;
  Max:=width;
  Font.Name:='Courier';
  Showhint:=true;
  Barcolor:=xpbar;
  GradientColor:=xpbar2;
  OnMouseMove:=xpMouseMove;
  OnChange:=xpChange;
  OnMouseDown:=xpMouseDown;
  end;
  end;
end;

procedure Tfmp3.FindeDateienExecute(Sender: TObject);
VAR errors:tstringlist;
i:integer;
begin
if not directoryexists(lepfad.Text)
then begin
      beep;
      exit;
     end;

dl:=TStringlist.Create;
dl.Clear;
lbdateien.Clear;

errors:=tstringlist.Create;

GetConsoleOutput('cmd /c dir "'+LEpfad.Text+'" /b /a-d /o /s', dl, errors);
errors.Free;
  for i:=0 to dl.Count-1 do
  oemtochar(pchar(dl[i]),pchar(dl[i]));


LBdateien.Items.AddStrings(dl);
lbdateien.sorted:=true;
dl.Free;

begrenzesb;
end;

procedure Tfmp3.FormCreate(Sender: TObject);
var datei:textfile;
    pfad:string;
begin
shuffle:=false;
randomize;
mp.Tag:=-1;
erstellexps;
fmp3.caption:='Emat '+fmp3version+' | Einfaches Mp3-Ausmist-Tool | Der_Ventilator';

try lbdateien.Items.LoadfromFile('playlist.txt');
except beep;
end;

begrenzesb;
XPmarkiertes:=0;
sbxpsChange(fmp3);

schriftfarbe:='clblack';
farbe:='clteal';

pfad:='c:\';

if fileexists('pfad.txt') then
try
assignfile(datei,'pfad.txt');
reset(datei);
readln(datei,pfad);
readln(datei,farbe);
readln(datei,schriftfarbe);
readln(datei,mp3playerpfad);
closefile(datei);
lepfad.text:=pfad
except beep;
end;

lbdateien.ItemIndex:=0;
mslezterklick:=gettickcount;
stylemode:=true;
randomize;
end;

procedure Tfmp3.LBdateienClick(Sender: TObject);
var seklaenge:integer;
    datei:string;
begin
datei:=markiertes(sender);
IF not fileexists(datei)
  then
      begin
      beep;
        if (sender as tlistbox).ItemIndex=(sender as tlistbox).Items.Count-1
        then (sender as tlistbox).ItemIndex:=0
        else (sender as tlistbox).ItemIndex:=(sender as tlistbox).ItemIndex+1;
        LBdateienClick(fmp3);         //Rekursion!!!!
        exit;
      end;

LStatus.Caption:=datei;
aktivesObjekt:=sender;

mp.FileName:=datei;
mp.Open;
try
mp.Play;
except
beep
end;

mp.Tag:=LBDateien.ItemIndex;
seklaenge:=round(mp.Length/1000);
ll.Caption:=inttostr(seklaenge div 60)+':'+(format('%.2d',[seklaenge mod 60]));

timer.Enabled:=true;
stylescroll:=true;
end;



procedure loesche(sender:tobject);
var position:integer;
    hatgespielt:boolean;
    zuloeschendes:string;
begin
hatgespielt:=false;
position:=(sender as tlistbox).Itemindex;
zuloeschendes:=(sender as tlistbox).Items[position];

IF (fmp3.mp.FileName=(zuloeschendes)) and (fmp3.cbdel.checked)
THEN
  begin
  fmp3.timer.enabled:=false;
  fmp3.mp.Stop;
  fmp3.mp.Eject;
  hatgespielt:=true;
  end;

if (fmp3.cbdel.checked)
  then
    begin
      IF Deletefile(zuloeschendes)
      then
        begin
        RemoveDir(extractfilepath(zuloeschendes));
        (sender as tlistbox).DeleteSelected;
        end
      else
        beep;
    end

  else
    begin
    (sender as tlistbox).DeleteSelected;
    end;


IF (sender as tlistbox).Items.Count<>0 then
  begin
  (sender as tlistbox).ItemIndex:=position;


  if hatgespielt then
      begin
      fmp3.LBdateienClick(sender);
      fmp3.timer.enabled:=true;
      end;
  end;

fmp3.sbxpsChange(fmp3);
end;

procedure Tfmp3.LBdateienKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
IF key=VK_DELETE THEN Loesche(sender);
IF (key=77) or (key=109) THEN fmp3player.ZuMp3PlayerListeAnfuegen(sender);
end;

procedure Tfmp3.LEpfadKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if key=VK_RETURN then
  begin
  FindeDateienExecute(fmp3);
  sbxpsChange(fmp3);
  end;

end;


procedure Tfmp3.FormActivate(Sender: TObject);
begin
lepfad.SetFocus;
end;

procedure Tfmp3.TimerTimer(Sender: TObject);
var seklaenge,i:integer;
begin
if lp.Caption=ll.Caption then
  begin
  if ( (aktivesobjekt as tlistbox).Items.Count=0 )
  then
    begin
    timer.Enabled:=false;
    exit;
    end;

if shuffle then
    begin
    (aktivesobjekt as tlistbox).ItemIndex:=random((aktivesobjekt as tlistbox).Items.Count);
    sbxps.Position:=(aktivesobjekt as tlistbox).ItemIndex-10;
    end
 else
 begin
  if ( (aktivesobjekt as tlistbox).ItemIndex=(aktivesobjekt as tlistbox).Items.Count-1 )
  then (aktivesobjekt as tlistbox).ItemIndex:=0
  else (aktivesobjekt as tlistbox).ItemIndex:=(aktivesobjekt as tlistbox).ItemIndex+1
 end;
  LBdateienClick((aktivesobjekt));
  sbxpschange(fmp3);
  end;


seklaenge:=round(mp.Position/1000);
lp.Caption:=inttostr(seklaenge div 60)+':'+(format('%.2d',[seklaenge mod 60]));


  FOR i:=0 TO 37 DO
    begin
    IF xps[i].HelpKeyword='spielt' THEN
      begin
      xps[i].position:=round(mp.Position/mp.Length*xpbreite);
      break;
      end;
    end;


end;

procedure Tfmp3.LEpfadKeyPress(Sender: TObject; var Key: Char);
begin
if key in [#13,#42] then key:=#0;
end;

procedure Tfmp3.CustomizeDlg1Close(Sender: TObject);
begin
beeP;
end;

procedure Tfmp3.Umbenennen1Click(Sender: TObject);
var altname,neuname:string;
     datei:file;
     lbstelle:integer;
begin
if (sender as tlistbox).ItemIndex<0 then exit;
altname:=markiertes(sender);
lbstelle:=(sender as tlistbox).ItemIndex;

neuname:=ExtractFileName(altname);
if inputquery('Umbenenner','Neuer Dateiname:',neuname) then
  begin
  try assignfile(datei,altname);
      rename(datei,extractfilepath(altname)+neuname);
      (sender as tlistbox).Items[lbstelle]:=extractfilepath(altname)+neuname;
  except beep end;
  end;

end;

procedure Tfmp3.LBdateienMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
IF button=mbright THEN Umbenennen1Click(sender);
end;

procedure Tfmp3.brandomsortClick(Sender: TObject);
var i,x,y:integer;
    c,position:string;
begin
if ARandomsort.Caption='Randomsort' then
begin
lbdateien.Sorted:=false;
position:=lbdateien.Items[lbdateien.Itemindex];

for i:=0 to LBdateien.Items.Count-1 do
begin
x:=random(LBdateien.Items.Count)   ;
y:=random(LBdateien.Items.Count)   ;
c:=LBdateien.Items[x];
LBdateien.Items[x]:=LBdateien.Items[y];
LBdateien.Items[y]:=c;

end;
lbdateien.ItemIndex:=lbdateien.Items.IndexOf(position) ;


ARandomsort.Caption:='Sortieren'
end
else
begin
lbdateien.Sorted:=true;
ARandomsort.Caption:='Randomsort'
end;


end;


procedure tfmp3.tausch(var a,b:string);
var c:string;
begin
c:=a;
a:=b;
b:=c;
end;

procedure Tfmp3.FormClose(Sender: TObject; var Action: TCloseAction);
var datei:textfile;
    pfad:string;
begin
lbdateien.Items.SaveToFile('playlist.txt');

pfad:=lepfad.text;
assignfile(datei,'pfad.txt');
rewrite(datei);
writeln(datei,pfad);
writeln(datei,colortostring(color));
writeln(datei,colortostring(font.color));
writeln(datei,fmp3player.lepfad.text);
closefile(datei);
end;

procedure Tfmp3.TlameTimer(Sender: TObject);
begin
tlame.Enabled:=false;
foption.changefontcolor(stringtocolor(schriftfarbe));
foption.changecolor(stringtocolor(farbe));
fmp3player.LEpfad.Text:=mp3playerpfad;
sbxps.SetFocus;
end;

procedure Tfmp3.AOptionShowExecute(Sender: TObject);
begin
foption.showmodal;
end;

procedure Tfmp3.AInfoExecute(Sender: TObject);
begin
finfo.ShowModal;
end;

procedure Tfmp3.ACloseExecute(Sender: TObject);
begin
Close;
end;

procedure Tfmp3.ARandomsortExecute(Sender: TObject);
begin
if ARandomsort.Caption='Shuffle an' then
begin
shuffle:=true;
ARandomsort.Caption:='Shuffle aus';
end
else
begin
shuffle:=false;
ARandomsort.Caption:='Shuffle an';
end;

end;

procedure Tfmp3.Amp3toolzeigenExecute(Sender: TObject);
begin
fmp3player.Show;
end;

procedure Tfmp3.Amp3AnPlayerAnfuegenExecute(Sender: TObject);
begin
fmp3player.ZuMp3PlayerListeAnfuegen(aktivesobjekt);
end;

procedure Tfmp3.lesucheChange(Sender: TObject);
var i:integer;
begin
lbsuche.Clear;
for i:=0 to lbdateien.Items.Count-1 do
if pos(ansiuppercase(lesuche.Text),ansiuppercase(lbdateien.Items[i]))>0 then lbsuche.Items.Add(lbdateien.Items[i]);

lsucherg.Caption:=inttostr(lbsuche.Items.Count)+' Element(e) gefunden';
end;

procedure Tfmp3.xpChange(Sender: TObject);
begin
//
end;

procedure Tfmp3.xpMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var i:integer;
begin

if ((sender as TXProgress).backgroundcolor=xpmausueber) then exit ;

if ((sender as TXProgress).backgroundcolor=xpinaktiv) then
    begin
      for i:=0 to 37 do
        begin
          with xps[i] do
            begin
              if backgroundcolor=xpmausueber then
                begin
                  backgroundcolor:=xpinaktiv;
                  gradientcolor:=xpinaktiv;
               end;
            end;
        end;
     (sender as TXProgress).backgroundcolor:=xpmausueber;
     (sender as TXProgress).GradientColor:=xpmausueber;
    end;

IF (sender as TXProgress).backgroundcolor=xpaktiv then
    begin
      for i:=0 to 37 do
        begin
          with xps[i] do
            begin
              if backgroundcolor=xpmausueber then
                begin
                  backgroundcolor:=xpinaktiv;
                  gradientcolor:=xpinaktiv;
                  break;
               end;
            end;
        end;
    end;

end;

procedure Tfmp3.sbxpsChange(Sender: TObject);
var i,j:integer;
    eintrag:string;
begin
for i:=0 to 37 do
  begin
  with xps[i] do
  begin
    if sbxps.position+i<lbdateien.items.count-1
    then
      begin
      eintrag:=extractfilename(lbdateien.Items[sbxps.position+i]);
      IF length(eintrag)>82 then
          begin
            hint:=eintrag;
            eintrag:=copy(eintrag,0,79)+'...';
          end
        else hint:='';
      FOR j:=length(eintrag) to 82 do
            eintrag:=eintrag+' ';
      caption:=eintrag;
      tag:=sbxps.position+i;
      IF mp.Tag=tag
      THEN begin
              HelpKeyword:='spielt';
              position:=round(mp.Position/mp.Length*xpbreite);
              end
      ELSE  begin
               HelpKeyword:='';
               if position>0 then position:=0;
            end;   
      IF tag=LBdateien.ItemIndex THEN
        begin
        backgroundcolor:=xpaktiv;
        gradientcolor:=xpaktiv;
        end
      ELSE
        begin
        backgroundcolor:=xpinaktiv;
        end;
      end
    else caption:='';
  end;
end;

end;

procedure tfmp3.begrenzesb;
begin
sbxps.position:=0;
if lbdateien.Items.Count>1 then
sbxps.Max:=lbdateien.Items.Count-1 -38
else sbxps.Max:=1;
end;

procedure Tfmp3.xpMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i:integer;  
begin
if button=mbleft then
begin

IF (sender as TXProgress).helpkeyword='spielt' THEN begin
  (sender as TXProgress).Position:=x;
  mp.Position:=round(mp.Length*x/xpbreite);
  mp.Play;
  end;


  begin
  if (sender as TXProgress).HelpKeyword='spielt'
  then (sender as TXProgress).GradientColor:=xpaktiv
  else  begin
        FOR i:=0 TO 37 DO
        if xps[i].HelpKeyword='spielt'
        then xps[i].GradientColor:=xpinaktiv
        end;
  end;

LBdateien.ItemIndex:=(sender as TXProgress).tag;
LStatus.Caption:=LBDateien.Items[LBdateien.ItemIndex];
                   //Doppelklick
IF mslezterklick+250>abs(gettickcount)
THEN
  begin
  LbdateienClick(lbdateien);
  (sender as TXProgress).Position:=0;
  FOR i:=0 TO 37 DO xps[i].HelpKeyword:='';
  (sender as TXProgress).HelpKeyword:='spielt';
  XPmarkiertes:=(sender as TXProgress).tag;
  end;

mslezterklick:=gettickcount;

sbxpsChange(fmp3);
end;
if button=mbright then
begin
  LBdateien.ItemIndex:=(sender as TXProgress).tag;
  (sender as TXProgress).Backgroundcolor:=xpaktiv;
  (sender as TXProgress).GradientColor:=xpaktiv;
  sbxpsChange(fmp3);
  Umbenennen1Click(lbdateien);
  sbxpsChange(fmp3);
end;
end;

procedure Tfmp3.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
IF stylescroll THEN sbxps.Position:=sbxps.Position+3;
end;

procedure Tfmp3.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
IF stylescroll THEN sbxps.Position:=sbxps.Position-3;
end;

procedure Tfmp3.LBSucheEnter(Sender: TObject);
begin
stylescroll:=false;
end;

procedure Tfmp3.LBSucheExit(Sender: TObject);
begin
stylescroll:=true;
end;

procedure Tfmp3.APauseExecute(Sender: TObject);
begin
if apause.Caption='Pause'
then
  begin
  mp.Pause;
  apause.Caption:='Fortsetzen'
  end
else
  begin
  mp.Play;
  apause.Caption:='Pause';
  end;
end;

procedure Tfmp3.xpMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
//wenn man es mal braucht...
end;

procedure Tfmp3.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  var i:integer;
begin
if stylescroll then begin
    for i:=0 to 37 do begin
    if xps[i].BackgroundColor=xpaktiv then begin
        LBdateien.ItemIndex:=xps[i].tag;
        break
        end;
    end;
    LBdateienKeyDown(lbdateien,key,shift);
    end;
end;

procedure Tfmp3.LEpfadEnter(Sender: TObject);
begin
stylescroll:=false;
end;

procedure Tfmp3.LEpfadExit(Sender: TObject);
begin
stylescroll:=true;
end;

end.

