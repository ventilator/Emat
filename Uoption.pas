unit Uoption;
           
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ump3, dxCore, dxWinXPBar, ComCtrls, TabNotBk, StdCtrls,
  ExtCtrls, dxButtons, Buttons, ShellAPI, LMDCustomComboBox,
  LMDFontComboBox, Menus;

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
    CBplaylistsave: TCheckBox;
    CBminitotray: TCheckBox;
    RGRender: TRadioGroup;
    E_GHK_vorher: TEdit;
    E_GHK_pause: TEdit;
    E_GHK_nachher: TEdit;
    E_GHK25: TEdit;
    E_GHK50: TEdit;
    E_GHK75: TEdit;
    E_GHK100: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
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
    procedure RGRenderClick(Sender: TObject);
    procedure E_GHK_vorherKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure E_GHK_vorherKeyPress(Sender: TObject; var Key: Char);
  private
    
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    procedure EinstellungenLaden;
  end;

var
  Fsettings: TFsettings;
   Renderaender:boolean=false;
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
Fmp3.AwebseiteExecute(fsettings);
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
einstellungenladen;
end;

procedure TFsettings.BzurueckClick(Sender: TObject);
begin
 CBfontcolor.Selected:=clblack;       //Schriftfarbe
 CBwindow.Selected:=clskyblue;        //Fensterfarbe
 CBtaskbar.Checked:=false;            //Taskleisteneintrag
 CBtray.Checked:=true;                //Trayicon
 CBplaylistsave.Checked:=true;        //Playlist
 LMDFontCombo.SelectedFont:='Verdana';//Schriftart
 E_GHK_vorher.Text:='Strg+F9';        //Hotkey
 E_GHK_pause.Text:='Strg+F11';        //Hotkey
 E_GHK_nachher.Text:='Strg+F12';      //Hotkey
 E_GHK25.Text:='Strg+F1';             //Hotkey
 E_GHK50.Text:='Strg+F2';             //Hotkey
 E_GHK75.Text:='Strg+F3';             //Hotkey
 E_GHK100.Text:='Strg+F4';            //Hotkey

 TB.PageIndex:=0;

 end;

procedure TFsettings.buebernehmClick(Sender: TObject);
var i:integer;
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

//Globale Hotkeys
  fmp3.GHK_vorher.HotKey:=TextToShortCut(E_GHK_vorher.Text);
  fmp3.GHK_pause.HotKey:=TextToShortCut(E_GHK_pause.Text);
  fmp3.GHK_nachher.HotKey:=TextToShortCut(E_GHK_nachher.Text);
  fmp3.GHK25.HotKey:=TextToShortCut(E_GHK25.Text);
  fmp3.GHK50.HotKey:=TextToShortCut(E_GHK50.Text);
  fmp3.GHK75.HotKey:=TextToShortCut(E_GHK75.Text);
  fmp3.GHK100.HotKey:=TextToShortCut(E_GHK100.Text);



 fmp3.SetColor;

 if renderaender then
 begin
 for i:=0 to rgrender.Items.count-1 do
 begin
   rgrender.ItemIndex:=i;
   fmp3.Astoppexecute(fmp3);
 end;
 renderaender:=false;
 if rgrender.ItemIndex=1 then fmp3.ieq.visible:=false else fmp3.ieq.visible:=true;
 end;
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
   Reg.WriteInteger('renderkern',rgrender.ItemIndex);
   Reg.WriteString('GHK_nachher',E_GHK_nachher.Text);                      //uk
   Reg.WriteString('GHK_vorher',E_GHK_vorher.Text);                        //uk
   Reg.WriteString('GHK_pause',E_GHK_pause.Text);                          //uk
   Reg.WriteString('GHK100',E_GHK100.Text);                                //uk
   Reg.WriteString('GHK25',E_GHK25.Text);                                  //uk
   Reg.WriteString('GHK50',E_GHK50.Text);                                  //uk
   Reg.WriteString('GHK75',E_GHK75.Text);                                  //uk

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
   rgrender.ItemIndex:=Reg.ReadInteger('renderkern');
   TB.PageIndex:=Reg.ReadInteger('tbseite');                               //uk
   E_GHK_nachher.Text:=Reg.ReadString('GHK_nachher');                      //uk
   E_GHK_vorher.Text:=Reg.ReadString('GHK_vorher');                        //uk
   E_GHK_pause.Text:=Reg.ReadString('GHK_pause');                          //uk
   E_GHK100.Text:=Reg.ReadString('GHK100');                                //uk
   E_GHK75.Text:=Reg.ReadString('GHK75');                                  //uk
   E_GHK50.Text:=Reg.ReadString('GHK50');                                  //uk
   E_GHK25.Text:=Reg.ReadString('GHK25');                                  //uk

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


procedure TFsettings.RGRenderClick(Sender: TObject);
begin
  Renderaender:=true;
end;

procedure TFsettings.E_GHK_vorherKeyDown(Sender: TObject; var Key: Word; //uk
  Shift: TShiftState);
begin
  fmp3.GHK_vorher.Active:=false;
  fmp3.GHK_pause.Active:=false;
  fmp3.GHK_nachher.Active:=false;
  fmp3.GHK25.Active:=false;
  fmp3.GHK50.Active:=false;
  fmp3.GHK75.Active:=false;
  fmp3.GHK100.Active:=false;


if (Shift=[ssShift]) or (Shift=[ssAlt]) or (Shift=[ssCtrl]) then
(Sender as TEdit).Text:=ShortCutToText(ShortCut(Key, Shift));

  fmp3.GHK_vorher.Active:=true;
  fmp3.GHK_pause.Active:=true;
  fmp3.GHK_nachher.Active:=true;
  fmp3.GHK25.Active:=true;
  fmp3.GHK50.Active:=true;
  fmp3.GHK75.Active:=true;
  fmp3.GHK100.Active:=true;
end;

procedure TFsettings.E_GHK_vorherKeyPress(Sender: TObject; var Key: Char); //uk
begin
Key:=#0;
end;

end.
