unit Usave;

interface

uses inifiles, dialogs, sysutils, forms, ulang, controls, classes;

const
  LBPLSINI = 'pls.set';
  
type TSave = class (TObject)

 private
    ini:Tinifile;
    procedure S_EQ;
    procedure L_EQ;
 public
    constructor Create(iniFileName:string);
    procedure S_OffenePlaylisten;
    procedure L_OffenePlaylisten;
    procedure SpieleBeimStart(ListenNummer: integer);
    procedure S_Einstellungen;
    procedure L_Einstellungen;
    destructor CloseIniFile;
    function LoadVisSetting:boolean;
 end;


implementation

uses ump3;

constructor TSave.Create(iniFileName:string);
 begin
   inherited create;
   ini:=Tinifile.Create(iniFilename);
 end;

procedure TSave.S_OffenePlaylisten;
var i,j,anzahl:integer;
    maximized_list   :integer;
begin
try
  ini.EraseSection('OffenePlaylisten');
  anzahl:=0;
  maximized_list:=-1;

  for i:=0 to High(fmp3.Datenbank.Mp3DatenMeta) do
    begin
     if (fmp3.Datenbank.ListeExists(i))
      and (fmp3.Datenbank.Mp3DatenMeta[i].FileName<>'')
       then
       begin
       inc(Anzahl);
       ini.WriteString('OffenePlaylisten','Liste'+inttostr(Anzahl)
                        ,fmp3.Datenbank.Mp3DatenMeta[i].FileName);
       ini.WriteInteger('OffenePlaylisten','WindowState'+inttostr(Anzahl)
                        ,Integer(fmp3.FPlaylisten[i].WindowState));

       if fmp3.FPlaylisten[i].WindowState = wsmaximized
       then
        begin
           maximized_list:=i;
        end;


       //Windowstate wird auf Normal gesetzt um Größe speichern zu können
       fmp3.FPlaylisten[i].WindowState := wsNormal;

       ini.WriteInteger('OffenePlaylisten','Left'+inttostr(Anzahl),
                        fmp3.FPlaylisten[i].Left);
       ini.WriteInteger('OffenePlaylisten','Top'+inttostr(Anzahl),
                        fmp3.FPlaylisten[i].Top);
       ini.WriteInteger('OffenePlaylisten','Width'+inttostr(Anzahl),
                        fmp3.FPlaylisten[i].Width);
       ini.WriteInteger('OffenePlaylisten','Height'+inttostr(Anzahl),
                        fmp3.FPlaylisten[i].Height);


       for j:=0 to 4 do
        begin
          ini.WriteInteger('OffenePlaylisten','Cols'+inttostr(Anzahl)+
             '_'+inttostr(j),fmp3.FPlaylisten[i].StringGrid.ColWidths[j]);
        end;

       if (fmp3.Aktiv.SpielendeListe=i) and (fmp3.Aktiv.Spielt)
       then
        begin
         ini.WriteString('OffenePlaylisten','SpielendeListe',
                                  fmp3.Datenbank.Mp3DatenMeta[i].FileName);
         ini.WriteInteger('OffenePlaylisten','SpielendesElement',
                                                  fmp3.Aktiv.SpielendesElement);
         ini.WriteInteger('OffenePlaylisten','SpielendesElementPosition',
                                              round(fmp3.Spieler.GetPosition));
        end;
      end;
    end;

  ini.WriteInteger('OffenePlaylisten','Anzahl',Anzahl);
  ini.WriteInteger('OffenePlaylisten','MaximizedList',maximized_list);

except
 fmp3.Fehler('Die Position der geöffneten Listen konnte nicht fehlerfrei gespeichert werden.');
 //Im Fehlerfall offene Listen verwerfen
 ini.WriteInteger('OffenePlaylisten','Anzahl',0);
end;
end;

procedure TSave.SpieleBeimStart(ListenNummer: integer);
{ Port: der Autostart beim Laden der offenen Listen lag im grossen try von
  L_OffenePlaylisten; eine Access Violation im TBX-MDI-Grid (ChangeBounds)
  brach damit das ganze Laden ab. Jetzt gekapselt und geloggt. }
begin
  try
    fmp3.Log('Autostart: Liste=' + IntToStr(ListenNummer) + ' Element=' +
              IntToStr(ini.ReadInteger('OffenePlaylisten','SpielendesElement',-1)));
    if fmp3.Spiele(ListenNummer, ini.ReadInteger('OffenePlaylisten','SpielendesElement',-1)) then
      if fmp3.Spieler.GetLength > 0.001 then
        fmp3.Spule(ini.ReadInteger('OffenePlaylisten','SpielendesElementPosition',0)
                   / fmp3.Spieler.GetLength);
  except
    on E: Exception do
      fmp3.Log('Autostart: ' + E.ClassName + ': ' + E.Message);
  end;
end;


procedure TSave.L_OffenePlaylisten;
var i,j,anzahl,maximized_list:integer;
    SpielendeListe : string;
    flag : boolean;

begin
try
  flag:=false;
  SpielendeListe:=ini.ReadString('OffenePlaylisten','SpielendeListe','');

  anzahl:=ini.ReadInteger('OffenePlaylisten','Anzahl',0);

  if anzahl>0 then
    begin
     for i:=0 to anzahl-1 do
      begin
       if fmp3.ListeLaden
              (ini.ReadString('OffenePlaylisten','Liste'+inttostr(i+1),'')) then
       begin


        //Wenn spielende dann spiele
       if ini.ReadString('OffenePlaylisten','Liste'+inttostr(i+1),'Beispielwert')=SpielendeListe
       then
        begin
         flag:=true;
         SpieleBeimStart(i);   // Port: eigener try-Block, siehe unten
        end;
        //Aussehen (eigenes try: TBX-MDI-Kindfenster kann in LCL keine Bounds setzen)
        try
         fmp3.FPlaylisten[i].Left:=ini.ReadInteger('OffenePlaylisten','Left'
                                +inttostr(i+1),fmp3.FPlaylisten[i].Left);
         fmp3.FPlaylisten[i].Top:=ini.ReadInteger('OffenePlaylisten','Top'
                                +inttostr(i+1),fmp3.FPlaylisten[i].Top);
         fmp3.FPlaylisten[i].Width:=ini.ReadInteger('OffenePlaylisten','Width'
                                +inttostr(i+1),fmp3.FPlaylisten[i].Width);
         fmp3.FPlaylisten[i].Height:=ini.ReadInteger('OffenePlaylisten','Height'
                                +inttostr(i+1),fmp3.FPlaylisten[i].Height);

         for j:=0 to 4 do
         begin
         fmp3.FPlaylisten[i].StringGrid.ColWidths[j]:=
          ini.ReadInteger('OffenePlaylisten','Cols'+inttostr(i+1)+
             '_'+inttostr(j),fmp3.FPlaylisten[i].StringGrid.ColWidths[j]);
         end;
         fmp3.FPlaylisten[i].SetRaender;  //Der Gliste zuweisen

         fmp3.FPlaylisten[i].WindowState:=TWindowState(ini.ReadInteger
                         ('OffenePlaylisten','WindowState'+inttostr(i+1),0));
        except
          on E: Exception do
            with TStringList.Create do try Add('Appearance['+IntToStr(i)+']: '+E.ClassName+': '+E.Message); SaveToFile(ExtractFilePath(ParamStr(0))+'startup_error.txt'); finally Free; end;
        end;
         end;
      end;

      maximized_list:= ini.ReadInteger('OffenePlaylisten','MaximizedList',-1);

      if (maximized_list<>-1) and (fmp3.datenbank.listeexists(maximized_list)) then
        fmp3.FPlaylisten[maximized_list].WindowState:=wsmaximized;

      if flag then
        try
          fmp3.MarkInList;
        except
          on E: Exception do fmp3.Log('MarkInList: ' + E.ClassName + ': ' + E.Message);
        end;
   end;      
except
   on E: Exception do
     fmp3.Log('OffeneListen: ' + E.ClassName + ': ' + E.Message + ' @' + IntToStr(PtrInt(ExceptAddr)));
end;
end;

procedure TSave.S_Einstellungen;
begin
try
  ini.WriteBool('Allgemein','Shuffle',fmp3.TBXIShuffle.Checked);
  ini.WriteBool('Allgemein','Partymode',fmp3.TBX_PartyMode.Checked);
  ini.WriteFloat('Allgemein','Volume', fmp3.GetVolume);
  ini.WriteInteger('Style','TBX-Theme',fmp3.GStyle.MarkiertesElement);
  ini.WriteInteger('Style','WindowState',Integer(Fmp3.WindowState));
  ini.WriteInteger('Style','Left',fmp3.Left);
  ini.WriteInteger('Style','Top',fmp3.Top);
  ini.WriteInteger('Style','Width',fmp3.Width);
  ini.WriteInteger('Style','Height',fmp3.Height);
//  ini.WriteString('Dialogs','PathD',fmp3.PathD.Path);
  ini.WriteBool('Style','TaskbarButton',fmp3.TBXCBtaskbuttton.Checked);
  ini.WriteBool('Style','MinToTray',fmp3.TBXCBmintotray.Checked);
  ini.WriteBool('Style','ShowTray',fmp3.TBXCBtrayicon.Checked);
  ini.WriteBool('Style','TaskScroll',fmp3.TBXCBscrolltitle.Checked);
  ini.WriteBool('Allgemein','HDD-Loesch',fmp3.TBXI_HDDLoeschmodus.Checked);
  fmp3.GPlayListen.Liste.l0.SaveToFile(extractfilepath(ini.FileName)+LBPLSINI);
  fmp3.Esuche.Strings.SaveToFile(extractfilepath(ini.FileName)+'searchstrings.set');
  fmp3.Mosdexenames.Lines.SaveToFile(extractfilepath(ini.FileName)+'autoosdexestrings.set');
  ini.WriteBool('Allgemein','SysHKey',fmp3.TBXCBSysHKey.Checked);
  ini.WriteBool('Allgemein','SingleAutoPlay',fmp3.TBXCBSearchAutoPlay.Checked);
  ini.WriteBool('Allgemein','CoverSearch',fmp3.TBXCBCoverSearch.Checked);
  ini.WriteBool('Allgemein','HighPriority',fmp3.TBXB_HighPriority.Checked);
  ini.WriteBool('Allgemein','AutoSavePlaylist',fmp3.TBXCBAutoSave.Checked);

  ini.WriteString('Style', 'Wallpaper', fmp3.OpenPD.FileName);
  S_EQ;
  ini.WriteInteger('Style', 'WallpColor', fmp3.Color);
  //ini.WriteInteger('Allgemein', 'Clockindex', fmp3.TBXButton3.Tag);
  ini.WriteString('Allgemein', 'OpenD', fmp3.OpenD.InitialDir);
  ini.WriteString('Allgemein', 'SaveD', fmp3.SaveD.InitialDir);
//  ini.WriteString('Allgemein', 'Mp3PlayerDir', fmp3.LMDDDMp3Player.Path);
  ini.WriteBool('Allgemein','OSD',fmp3.TBXI_ScreenText.Checked);
  ini.WriteBool('AOT', 'TrayPanel', fmp3.Aalwaysontop.Checked);


  //Titelanzeige
  ini.WriteBool('Style','ScreenOut', fmp3.TBXCBhud.Checked);
  ini.WriteBool('Allgemein','OSD',   fmp3.TBXI_ScreenText.Checked);
  ini.WriteBool('Allgemein','Auto-OSD', fmp3.TBXCB_AutoOSD.Checked);


  //VisSettings
  ini.WriteBool('Vis','Aktiv',fmp3.TBXCBvis.checked);
  ini.WriteBool('Vis', '1', fmp3.TBXIvis1.Checked);
  ini.WriteBool('Vis', '2', fmp3.TBXIvis2.Checked);
  ini.WriteBool('Vis', '3', fmp3.TBXIvis3.Checked);
  ini.WriteBool('Vis', '4', fmp3.TBXIvis4.Checked);
  ini.WriteBool('Vis', '5', fmp3.TBXIvis5.Checked);
  ini.WriteBool('Vis', '6', fmp3.TBXIvis6.Checked);
  ini.WriteBool('Vis', '7', fmp3.TBXIvis7.Checked);
  ini.WriteBool('Vis', '8', fmp3.TBXIvis8.Checked);
  ini.WriteBool('Vis', '9', fmp3.TBXIvis9.Checked);
  ini.WriteBool('Vis', '10', fmp3.TBXIvis10.Checked);
  ini.WriteBool('Vis', '11', fmp3.TBXIvis11.Checked);
  ini.WriteBool('Vis', '12', fmp3.TBXIvis12.Checked);

  ini.WriteInteger('Shuffle', 'Staerke', fmp3.TBXPB_shuffle.Position);

  //Hotkeys
  //nicht beim Erstem mal laden, da mir die einzelnen Integer unbekannt sind
  ini.WriteBool('Hotkey','UseCustom',true);
  //Nach erstem Speichern werden die gespeicherten Werte verwendet

  ini.WriteInteger('Hotkey','Next',fmp3.HK_Next.HotKey);
  ini.WriteInteger('Hotkey','Back',fmp3.HK_Back.HotKey);
  ini.WriteInteger('Hotkey','Lauter',fmp3.HK_Lauter.HotKey);
  ini.WriteInteger('Hotkey','Leiser',fmp3.HK_Leiser.HotKey);
  ini.WriteInteger('Hotkey','Play',fmp3.HK_Play.HotKey);
  ini.WriteInteger('Hotkey','Pause',fmp3.HK_Pause.HotKey);
  ini.WriteInteger('Hotkey','Shuffle',fmp3.HK_Shuffle.HotKey);


except
  fmp3.Fehler(SAVESETTINGSERROR);
end
end;


procedure TSave.L_Einstellungen;
var
  Listen: TStringList;
  i: integer;
  wallpaperfilename : string;
begin
try
  Listen := TStringList.Create;
  
  fmp3.SetShuffle(ini.ReadBool('Allgemein','Shuffle',false));
  fmp3.TBX_PartyMode.Checked:=ini.ReadBool('Allgemein','Partymode',false);
  //Fmp3.AshuffleExecute(fmp3);
  fmp3.WindowState:=TWindowState(ini.ReadInteger('Style','WindowState',0));
  fmp3.SetVolume(ini.ReadFloat('Allgemein', 'Volume', 0.5));
  fmp3.GStyle.markiertesElement:=ini.ReadInteger('Style','TBX-Theme',22);
  fmp3.GStyleDoppelClick(ini.ReadInteger('Style','TBX-Theme',0), []);
  fmp3.Left:=ini.ReadInteger('Style','Left',Screen.Width div 2 - fmp3.Width div 2);
  fmp3.Top:=ini.ReadInteger('Style','Top',Screen.Height div 2 - fmp3.Height div 2);
  fmp3.Width:=ini.ReadInteger('Style','Width',fmp3.Width);
  fmp3.Height:=ini.ReadInteger('Style','Height',fmp3.Height);
//  fmp3.PathD.Path:=ini.ReadString('Dialogs','PathD','');
  fmp3.TBXCBscrolltitle.Checked:=ini.ReadBool('Style','TaskScroll',true);
  fmp3.TBXCBtrayicon.Checked:=ini.ReadBool('Style','ShowTray',true);
  fmp3.TBXCBtaskbuttton.Checked:=ini.ReadBool('Style','TaskbarButton',true);
  fmp3.TBXCBmintotray.Checked:=ini.ReadBool('Style','MinToTray',false);
  fmp3.TBXCBSysHKey.Checked:=ini.ReadBool('Allgemein','SysHKey',true);
  fmp3.TBXCBSearchAutoPlay.Checked:=ini.ReadBool('Allgemein','SingleAutoPlay',true);
  fmp3.TBXCBCoverSearch.Checked:=ini.ReadBool('Allgemein','CoverSearch',true);
  fmp3.TBXB_HighPriority.Checked:=ini.ReadBool('Allgemein','HighPriority',false);
  fmp3.TBXCBAutoSave.Checked:=ini.ReadBool('Allgemein','AutoSavePlaylist',true);
  fmp3.WindowState:=TWindowState(ini.ReadInteger('Style','WindowState',0));
  fmp3.Color := ini.ReadInteger('Style', 'WallpColor', $00808080);
  fmp3.TBXPB_shuffle.Position := ini.ReadInteger('Shuffle', 'Starke', 100);
  //fmp3.TBXButton3.Tag := ini.ReadInteger('Allgemein', 'Clockindex', 0) - 1;
  //fmp3.TBXButton3Click(fmp3);

  fmp3.TBXI_HDDLoeschmodus.Checked := ini.ReadBool('Allgemein','HDD-Loesch',false);
  fmp3.TBXI_HDDLoeschmodus2.Checked := not ini.ReadBool('Allgemein','HDD-Loesch',false);;

  fmp3.Aalwaysontop.Checked := not ini.ReadBool('AOT', 'TrayPanel', false);
    fmp3.AalwaysontopExecute(fmp3);
{  if DirectoryExists(ini.ReadString('Allgemein', 'Mp3PlayerDir', ''))
  then
     fmp3.LMDDDMp3Player.Path:= ini.ReadString('Allgemein', 'Mp3PlayerDir', '');     }
  if FileExists(extractfilepath(ini.FileName)+LBPLSINI)
  then
  begin
    Listen.LoadFromFile(extractfilepath(ini.FileName)+ LBPLSINI);
    for i := 0 to Listen.Count - 1 do
      fmp3.GPlayListen.Add(0,false,Listen[i],'','','','');
  end;
  Listen.Free;

  if FileExists(extractfilepath(ini.FileName)+'searchstrings.set')
  then
  begin
    fmp3.Esuche.Strings.LoadFromFile(extractfilepath(ini.FileName)+ 'searchstrings.set');
  end;

  if FileExists(extractfilepath(ini.FileName)+'autoosdexestrings.set')
  then
  begin
    fmp3.Mosdexenames.Lines.LoadFromFile(extractfilepath(ini.FileName)+ 'autoosdexestrings.set');
  end;

  wallpaperfilename:= ini.ReadString('Style', 'Wallpaper',
                             extractfilepath(application.exeName) + WALLPAPER);


  if fileexists(wallpaperfilename)
  then
  begin
    fmp3.ihintergrund.Picture.LoadFromFile(wallpaperfilename);
    fmp3.OpenPD.FileName := wallpaperfilename;
  end
  else wallpaperfilename := extractfilepath(application.exeName) + WALLPAPER;

  if fileexists(wallpaperfilename)
  then
  begin
    fmp3.ihintergrund.Picture.LoadFromFile(wallpaperfilename);
    fmp3.OpenPD.FileName := wallpaperfilename;
  end;

  //Titelanzeige
  fmp3.TBXCBhud.Checked            :=ini.ReadBool('Style','ScreenOut'   ,false );
  fmp3.TBXI_ScreenText.Checked     :=ini.ReadBool('Allgemein','OSD'     ,false);
  fmp3.TBXCB_AutoOSD.Checked       :=ini.ReadBool('Allgemein','Auto-OSD',true );



  fmp3.OpenD.InitialDir := ini.ReadString('Allgemein', 'OpenD', '');
  fmp3.SaveD.InitialDir := ini.ReadString('Allgemein', 'SaveD', '');

  L_EQ;

  fmp3.TBXCBvis.checked := ini.ReadBool('Vis','Aktiv', false);

  fmp3.TBXIvis1.Checked := ini.ReadBool('Vis', '1', false);
  fmp3.TBXIvis2.Checked := ini.ReadBool('Vis', '2', true);
  fmp3.TBXIvis3.Checked := ini.ReadBool('Vis', '3', false);
  fmp3.TBXIvis4.Checked := ini.ReadBool('Vis', '4', false);
  fmp3.TBXIvis5.Checked := ini.ReadBool('Vis', '5', false);
  fmp3.TBXIvis6.Checked := ini.ReadBool('Vis', '6', false);
  fmp3.TBXIvis7.Checked := ini.ReadBool('Vis', '7', false);
  fmp3.TBXIvis8.Checked := ini.ReadBool('Vis', '8', true);
  fmp3.TBXIvis9.Checked := ini.ReadBool('Vis', '9', false);
  fmp3.TBXIvis10.Checked := ini.ReadBool('Vis', '10', false);
  fmp3.TBXIvis11.Checked := ini.ReadBool('Vis', '11', false);
  fmp3.TBXIvis12.Checked := ini.ReadBool('Vis', '12', true);

  fmp3.TBXIvis12Click(fmp3.TBXIvis1);
  fmp3.TBXIvis12Click(fmp3.TBXIvis2);
  fmp3.TBXIvis12Click(fmp3.TBXIvis3);
  fmp3.TBXIvis12Click(fmp3.TBXIvis4);
  fmp3.TBXIvis12Click(fmp3.TBXIvis5);
  fmp3.TBXIvis12Click(fmp3.TBXIvis6);
  fmp3.TBXIvis12Click(fmp3.TBXIvis7);
  fmp3.TBXIvis12Click(fmp3.TBXIvis8);
  fmp3.TBXIvis12Click(fmp3.TBXIvis9);
  fmp3.TBXIvis12Click(fmp3.TBXIvis10);
  fmp3.TBXIvis12Click(fmp3.TBXIvis11);
  fmp3.TBXIvis12Click(fmp3.TBXIvis12);

  //Hotkeys
  //nicht beim Erstem mal laden, da mir die einzelnen Integer unbekannt sind
  if ini.ReadBool('Hotkey','UseCustom',false) then
  begin
  fmp3.HK_Next.HotKey:=ini.ReadInteger('Hotkey','Next',0);
  fmp3.HK_Back.HotKey:=ini.ReadInteger('Hotkey','Back',0);
  fmp3.HK_Lauter.HotKey:=ini.ReadInteger('Hotkey','Lauter',0);
  fmp3.HK_Leiser.HotKey:=ini.ReadInteger('Hotkey','Leiser',0);
  fmp3.HK_Play.HotKey:=ini.ReadInteger('Hotkey','Play',0);
  fmp3.HK_Pause.HotKey:=ini.ReadInteger('Hotkey','Pause',0);
  fmp3.HK_Shuffle.HotKey:=ini.ReadInteger('Hotkey','Shuffle',0);
  end;
  //Nach dem Laden Keys im System registrieren
  fmp3.RegisterHotKeys;

except
   fmp3.Fehler('Die Einstellungen konnten nicht einwandfrei geladen werden.');
end;
end;


function TSave.LoadVisSetting:boolean;
begin
  Result := ini.ReadBool('Vis','Aktiv', false);
end;

procedure TSave.L_EQ;               //uk
var
  i: integer;
begin
  for i := 0 to High(fmp3.Spieler.eqwert) do
    fmp3.Spieler.eqwert[i] := ini.ReadInteger('EQ', 'Wert'+inttostr(i), 0);
  fmp3.Spieler.EQSetWerte;
end;

procedure TSave.S_EQ;               //uk
var
  i: integer;
begin
  for i := 0 to High(fmp3.Spieler.eqwert) do
    ini.WriteInteger('EQ', 'Wert'+inttostr(i), fmp3.Spieler.eqwert[i]);
end;


destructor TSave.CloseIniFile;
begin
  ini.UpdateFile;
  ini.Free;
end;

end.
