unit Uoption;
           
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ump3, dxCore, dxWinXPBar, ComCtrls, TabNotBk, StdCtrls,
  ExtCtrls, dxButtons, Buttons, ShellAPI, LMDCustomComboBox,
  LMDFontComboBox;

type
  TFsettings = class(TForm)
    TB: TTabbedNotebook;
    CBfontcolor: TColorBox;
    GBfontcolor: TGroupBox;
    GBfont: TGroupBox;
    GBwindowcolor: TGroupBox;
    CBwindow: TColorBox;
    LVersion: TLabel;
    Label1: TLabel;
    Bok: TButton;
    Bclose: TButton;
    Bzurueck: TButton;
    GBtaskbar: TGroupBox;
    CBtray: TCheckBox;
    CBtaskbar: TCheckBox;
    buebernehm: TButton;
    LMDFontCombo: TLMDFontComboBox;
    Label2: TLabel;
    CBplaylistsave: TCheckBox;
    CBminitotray: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure Label1MouseEnter(Sender: TObject);
    procedure Label1MouseLeave(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure BokClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BcloseClick(Sender: TObject);
    procedure BzurueckClick(Sender: TObject);
    procedure buebernehmClick(Sender: TObject);
    procedure EinstellungenSpeichern;
  private
    
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    procedure EinstellungenLaden;
  end;

var
  Fsettings: TFsettings;

implementation

uses Ubug, Ustart, UInfo, uwarte;

{$R *.dfm}



procedure TFsettings.FormCreate(Sender: TObject);
begin
 LVersion.Caption:='Version '+Version;
end;

procedure TFsettings.Label1MouseEnter(Sender: TObject);
begin
Label1.Font.Color:=clBlue;
Label1.Font.Style:=[fsUnderline];
Label1.Cursor:=crHandPoint;
end;

procedure TFsettings.Label1MouseLeave(Sender: TObject);
begin
Label1.Font.Color:=clBlack;
Label1.Font.Style:=[];
Label1.Cursor:=crDefault;
end;

procedure TFsettings.Label1Click(Sender: TObject);
begin
 ShellExecute(Application.Handle, 'open',PChar('http://www.g-software.de.gg'), nil, nil, SW_ShowNormal);
end;

procedure TFsettings.BokClick(Sender: TObject);
begin
  buebernehmClick(fmp3);
  close;
end;

procedure TFsettings.FormShow(Sender: TObject);
begin
 CBfontcolor.Selected:=Fmp3.ClMap.FontColor;
 CBwindow.Selected:=Fmp3.ClMap.Color;

end;

procedure TFsettings.BcloseClick(Sender: TObject);
begin
close;
end;

procedure TFsettings.BzurueckClick(Sender: TObject);
begin
 CBfontcolor.Selected:=clblack;       //Schriftfarbe
 CBwindow.Selected:=clskyblue;        //Fensterfarbe
 CBtaskbar.Checked:=false;            //Taskleisteneintrag
 CBtray.Checked:=true;                //Trayicon
 CBplaylistsave.Checked:=true;        //Playlist
 LMDFontCombo.SelectedFont:='Verdana';//Schriftart
 TB.PageIndex:=0;

 end;

procedure TFsettings.buebernehmClick(Sender: TObject);
begin
 //Schriftfarbe
fmp3.ClMap.FontColor:=CBfontcolor.Selected;

//Fensterfarbe
fmp3.ClMap.Color:=CBwindow.Selected;

                                                    
//Trayicon
 if CBtray.Checked
   then fmp3.TrayIcon.IconVisible:=true
   else fmp3.TrayIcon.IconVisible:=false;

//Taskbaricon
 if CBtaskbar.Checked
   then fmp3.Trayicon.ShowTaskbarIcon
   else fmp3.TrayIcon.HideTaskbarIcon;

//Minimizetotray
 if CBminitotray.Checked
   then fmp3.TrayIcon.MinimizeToTray:=true
   else fmp3.TrayIcon.MinimizeToTray:=false;   

 fmp3.SetColor;
 
 EinstellungenSpeichern;
end;

procedure TFsettings.EinstellungenSpeichern;

begin
   Reg.OpenKey(RegEinstellungenPfad,true);

   Reg.WriteInteger('Schriftfarbe',integer(CBfontcolor.Selected));
   Reg.WriteInteger('Hintergrundfarbe',integer(CBwindow.Selected));

   Reg.WriteBool('taskicon',CBtaskbar.Checked);
   Reg.WriteBool('trayicon',CBtray.Checked);
   Reg.WriteBool('plstsave',CBplaylistsave.Checked);
   Reg.WriteString('schrift',LMDFontCombo.SelectedFont);
   Reg.WriteInteger('tbseite',TB.PageIndex);                               //uk


   
   Reg.CloseKey;
   end;

procedure TFsettings.EinstellungenLaden;
var flag:boolean;
begin
   if Reg.OpenKey(RegEinstellungenPfad,false)
   then
   begin
   try
   CBfontcolor.Selected:=Reg.ReadInteger('Schriftfarbe');
   CBwindow.Selected:=Reg.ReadInteger('Hintergrundfarbe');

   CBtaskbar.Checked:=Reg.ReadBool('taskicon');
   CBtray.Checked:=Reg.ReadBool('trayicon');
   CBplaylistsave.Checked:=Reg.ReadBool('plstsave');
   LMDFontCombo.SelectedFont:=Reg.ReadString('schrift');
   TB.PageIndex:=Reg.ReadInteger('tbseite');                               //uk

   flag:=true;
   except
   showmessage('Es tut mir leid, dass ich die visuellen Einstellungn nicht laden konnte.');
   flag:=false;
   end;
   if flag then buebernehmClick(fmp3);
   end;
   Reg.CloseKey;

 fmp3.SetColor;


  if Reg.OpenKey(RegHauptPfad,false)
  then
  begin
    try
       fmp3.Width:=Reg.ReadInteger('Width');
       fmp3.Height:=Reg.ReadInteger('Height');
       fmp3.Top:=Reg.ReadInteger('Top');
       fmp3.Left:=Reg.ReadInteger('Left');
    except end;

   end;
   Reg.CloseKey;
end;


end.
