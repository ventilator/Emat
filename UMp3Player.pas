unit UMp3Player;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XProgress, StdCtrls, ExtCtrls;

type
  Tfmp3player = class(TForm)
    LBdateien: TListBox;
    GBPfad: TGroupBox;
    LEpfad: TLabeledEdit;
    BTransfer: TButton;
    XPKopier: TXProgress;
    BHelp: TButton;
    procedure BHelpClick(Sender: TObject);
    procedure BTransferClick(Sender: TObject);
    procedure LBdateienKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private

    { Private-Deklarationen }
  public
      procedure ZuMp3PlayerListeAnfuegen(sender:tobject);
    { Public-Deklarationen }
  end;

var
  fmp3player: Tfmp3player;

implementation

uses ump3;

{$R *.dfm}

PROCEDURE tfmp3player.ZuMp3PlayerListeAnfuegen(sender:tobject);
VAR datei:string;
begin
if (sender as tlistbox).ItemIndex<0 then exit;
datei:=(sender as tlistbox).Items[(sender as tlistbox).ItemIndex];
IF lbdateien.items.IndexOf(datei)=-1 then
lbdateien.Items.Add(datei);
end;
                                        

procedure Tfmp3player.BHelpClick(Sender: TObject);
begin
showmessage('Wählen Sie die Mp3 im Hauptfenster mit "M" aus, die zum Zielpfad transferiert werden soll.'+#13
            +'Dann ins Transferfenster wechseln und Transfer auslösen.');
end;

procedure Tfmp3player.BTransferClick(Sender: TObject);
var zielpfad:string;
    i,gesamtanzahl:integer;
begin
zielpfad:=IncludeTrailingPathDelimiter(lepfad.Text);
gesamtanzahl:=lbdateien.Items.Count-1; //u.a. für Statistik
xpkopier.Max:=gesamtanzahl;
xpkopier.Position:=0;

if not directoryexists(zielpfad)
then
  begin
  beep;
  lepfad.Clear;
  lepfad.SetFocus;
  exit;
  end;


for i:=gesamtanzahl downto 0 do
begin
  if fileexists(zielpfad+extractfilename(pchar(lbdateien.Items[i])))
  then
    begin
    lbdateien.Items.Delete(i);
    end
  else
    begin
      try
        copyfile(pchar(lbdateien.Items[i]),pchar(zielpfad+extractfilename(lbdateien.Items[i])),true);
        lbdateien.Items.Delete(i);
        application.ProcessMessages;
      except
        beep;
      end;
    end;

xpkopier.Position:=gesamtanzahl-i;
end;
close;
end;

procedure Tfmp3player.LBdateienKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
IF key=VK_DELETE then lbdateien.Items.Delete(lbdateien.ItemIndex);
end;


end.
