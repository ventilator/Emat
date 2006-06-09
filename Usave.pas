unit Usave;

interface

uses inifiles, dialogs, sysutils, forms, ulang;

const
  LBPLSINI = 'pls.set';
  
type TSave = class (TObject)

 private
    ini:Tinifile;
    procedure S_EQ;
    procedure L_EQ;
 public
    constructor Create(iniFileName:string);
    /////////////////////////////////////0.75///////////////////////////////////
    procedure S_OffenePlaylisten;
    procedure L_OffenePlaylisten;
    procedure S_Einstellungen;
    procedure L_Einstellungen;
    destructor CloseIniFile;
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
begin
  ini.EraseSection('OffenePlaylisten');
  anzahl:=0;

  for i:=0 to High(fmp3.Datenbank.Mp3DatenMeta) do
    begin
     if (fmp3.Datenbank.Mp3DatenMeta[i].offen)
      and (fmp3.Datenbank.Mp3DatenMeta[i].SpeicherPfad<>'')
       then
       begin
       inc(Anzahl);
       ini.WriteString('OffenePlaylisten','Liste'+inttostr(Anzahl)
                        ,fmp3.Datenbank.Mp3DatenMeta[i].SpeicherPfad);
       ini.WriteInteger('OffenePlaylisten','WindowState'+inttostr(Anzahl)
                        ,Integer(fmp3.FPlaylisten[i].WindowState));
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

       if (fmp3.Aktiv.SpielendeListe=i) {and (fmp3.Aktiv.Spielt)}//Listeschließen stoppt
       then
        begin
         ini.WriteString('OffenePlaylisten','SpielendeListe',
                                  fmp3.Datenbank.Mp3DatenMeta[i].SpeicherPfad);
         ini.WriteInteger('OffenePlaylisten','SpielendesElement',
                                                  fmp3.Aktiv.SpielendesElement);
         ini.WriteInteger('OffenePlaylisten','SpielendesElementPosition',
                                                      fmp3.Spieler.GetPosition);
        end;
      end;
    end;

  ini.WriteInteger('OffenePlaylisten','Anzahl',Anzahl);
end;

procedure TSave.L_OffenePlaylisten;
var i,j,anzahl:integer;
    SpielendeListe : string;
    flag : boolean;
begin
  flag:=false;
  SpielendeListe:=ini.ReadString('OffenePlaylisten','SpielendeListe','');

  anzahl:=ini.ReadInteger('OffenePlaylisten','Anzahl',0);

  if anzahl>0 then
    begin
     for i:=0 to anzahl-1 do
      begin
       fmp3.ListeLaden
              (ini.ReadString('OffenePlaylisten','Liste'+inttostr(i+1),''));

        //Wenn spielende dann spiele
       if ini.ReadString('OffenePlaylisten','Liste'+inttostr(i+1),'Beispielwert')=SpielendeListe
       then
        begin
         flag:=true;
         fmp3.Aktiv.SpielendeListe:=i;
         fmp3.Aktiv.SpielendesElement:=ini.ReadInteger
                                    ('OffenePlaylisten','SpielendesElement',-1);
         fmp3.Spiele(fmp3.Aktiv.SpielendeListe,fmp3.Aktiv.SpielendesElement);
         fmp3.Spule(ini.ReadInteger('OffenePlaylisten',
                         'SpielendesElementPosition',0)/fmp3.Spieler.GetLength);
        end;

       //Aussehen
         fmp3.FPlaylisten[i].WindowState:=TWindowState(ini.ReadInteger
                         ('OffenePlaylisten','WindowState'+inttostr(i+1),0));
         for j:=0 to 4 do
         begin
         fmp3.FPlaylisten[i].StringGrid.ColWidths[j]:=
          ini.ReadInteger('OffenePlaylisten','Cols'+inttostr(i+1)+
             '_'+inttostr(j),fmp3.FPlaylisten[i].StringGrid.ColWidths[j]);
         end;

         fmp3.FPlaylisten[i].Left:=ini.ReadInteger('OffenePlaylisten','Left'
                                +inttostr(i+1),fmp3.FPlaylisten[i].Left);
         fmp3.FPlaylisten[i].Top:=ini.ReadInteger('OffenePlaylisten','Top'
                                +inttostr(i+1),fmp3.FPlaylisten[i].Top);
         fmp3.FPlaylisten[i].Width:=ini.ReadInteger('OffenePlaylisten','Width'
                                +inttostr(i+1),fmp3.FPlaylisten[i].Width);
         fmp3.FPlaylisten[i].Height:=ini.ReadInteger('OffenePlaylisten','Height'
                                +inttostr(i+1),fmp3.FPlaylisten[i].Height);
         fmp3.FPlaylisten[i].Repaint;
        if flag
        then fmp3.FPlaylisten[fmp3.Aktiv.SpielendeListe].BringToFront;
      end;
   end;
end;

procedure TSave.S_Einstellungen;
begin
try
  ini.WriteBool('Allgemein','Shuffle',fmp3.TBXIShuffle.Checked);
  ini.WriteInteger('Allgemein','Volume',fmp3.TBVolume.Position);
  ini.WriteInteger('Style','TBX-Theme',fmp3.LBthemes.ItemIndex);
  ini.WriteInteger('Style','WindowState',Integer(Fmp3.WindowState));
  ini.WriteInteger('Style','Left',fmp3.Left);
  ini.WriteInteger('Style','Top',fmp3.Top);
  ini.WriteInteger('Style','Width',fmp3.Width);
  ini.WriteInteger('Style','Height',fmp3.Height);
  ini.WriteString('Dialogs','PathD',fmp3.PathD.Path);
  ini.WriteBool('Style','TaskbarButton',fmp3.TBXCBtaskbuttton.Checked);
  ini.WriteBool('Style','MinToTray',fmp3.TBXCBmintotray.Checked);
  ini.WriteBool('Style','ShowTray',fmp3.TBXCBtrayicon.Checked);
  ini.WriteBool('Style','TaskScroll',fmp3.TBXCBscrolltitle.Checked);
  ini.WriteBool('Style','ScreenOut',fmp3.TBXCBhud.Checked);
  ini.WriteBool('Allgemein','HDD-Loesch',fmp3.TBXI_HDDLoeschmodus.Checked);
  fmp3.ListBox1.Items.SaveToFile(extractfilepath(ini.FileName)+LBPLSINI);
  ini.WriteBool('Allgemein','SysHKey',fmp3.TBXCBSysHKey.Checked);
  ini.WriteBool('Allgemein','SingleAutoPlay',fmp3.TBXCBSearchAutoPlay.Checked);
  ini.WriteString('Style', 'Wallpaper', fmp3.OpenPD.FileName);
  ini.WriteInteger('Vis', 'Mode', fmp3.PBSpectrum.Tag);            //uk
  S_EQ;
  ini.WriteInteger('Style', 'WallpColor', fmp3.Color);

except
  fmp3.Fehler(SAVESETTINGSERROR);
end
end;


procedure TSave.L_Einstellungen;
begin
  fmp3.WindowState:=TWindowState(ini.ReadInteger('Style','WindowState',0));
  if ini.ReadBool('Allgemein','Shuffle',false) then fmp3.TBXIShuffle.Click;
  fmp3.TBVolume.Position:=ini.ReadInteger('Allgemein','Volume',fmp3.TBVolume.Max);
  fmp3.LBthemes.ItemIndex:=ini.ReadInteger('Style','TBX-Theme',3);
  fmp3.LBthemesClick(fmp3);
  fmp3.Left:=ini.ReadInteger('Style','Left',Screen.Width div 2 - fmp3.Width div 2);
  fmp3.Top:=ini.ReadInteger('Style','Top',Screen.Height div 2 - fmp3.Height div 2);
  fmp3.Width:=ini.ReadInteger('Style','Width',750);
  fmp3.Height:=ini.ReadInteger('Style','Height',650);
  fmp3.PathD.Path:=ini.ReadString('Dialogs','PathD','');
  fmp3.TBXCBscrolltitle.Checked:=ini.ReadBool('Style','TaskScroll',true);
  fmp3.TBXCBtrayicon.Checked:=ini.ReadBool('Style','ShowTray',true);
  fmp3.TBXCBtaskbuttton.Checked:=ini.ReadBool('Style','TaskbarButton',true);
  fmp3.TBXCBmintotray.Checked:=ini.ReadBool('Style','MinToTray',false);
  fmp3.TBXCBhud.Checked:=ini.ReadBool('Style','ScreenOut',true);
  fmp3.TBXCBSysHKey.Checked:=ini.ReadBool('Allgemein','SysHKey',true);
  fmp3.TBXCBSearchAutoPlay.Checked:=ini.ReadBool('Allgemein','SingleAutoPlay',false);
  fmp3.WindowState:=TWindowState(ini.ReadInteger('Style','WindowState',0));
  fmp3.PBSpectrum.Tag := ini.ReadInteger('Vis', 'Mode', 0);   //uk
  fmp3.Spieler.SetBassVisOutput(fmp3.PBSpectrum.Tag);         //uk  
  fmp3.Color := ini.ReadInteger('Style', 'WallpColor', $00808080);

  if ini.ReadBool('Allgemein','HDD-Loesch',false)
    then fmp3.TBXI_HDDLoeschmodus.Click;
  if FileExists(extractfilepath(ini.FileName)+LBPLSINI)
    then fmp3.ListBox1.Items.LoadFromFile(extractfilepath(ini.FileName)+
      LBPLSINI);

  if FileExists(ini.ReadString('Style', 'Wallpaper', extractfilepath(
    ini.FileName + WALLPAPER)))
    then
      begin
        fmp3.ihintergrund.Picture.LoadFromFile(ini.ReadString('Style',
          'Wallpaper', extractfilepath(ini.FileName)));
        fmp3.OpenPD.FileName := ini.ReadString('Style', 'Wallpaper',
          extractfilepath(ini.FileName));
      end;
  L_EQ;
end;

procedure TSave.L_EQ;               //uk
var
  i: integer;
begin
  for i := 1 to High(fmp3.Spieler.eqwert) do
    fmp3.Spieler.eqwert[i] := ini.ReadInteger('EQ', 'Wert'+inttostr(i), 0);
  fmp3.Spieler.EQSetWerte;
end;

procedure TSave.S_EQ;               //uk
var
  i: integer;
begin
  for i := 1 to High(fmp3.Spieler.eqwert) do
    ini.WriteInteger('EQ', 'Wert'+inttostr(i), fmp3.Spieler.eqwert[i]);
end;


destructor TSave.CloseIniFile;
begin
  ini.UpdateFile;
  ini.Free;
end;

end.
