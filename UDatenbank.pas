Unit UDatenbank;

interface

uses dialogs, sysutils, strutils, classes, controls, id3v1, id3v2, oggvorbis, ulang;

const DatenVersion:integer=004;
      GENRE_COUNT = 147;
      
type
  ID3Genre = (
    id3gBlues, id3gClassicRock, id3gCountry, id3gDance, id3gDisco,
    id3gFunk, id3gGrunge, id3gHipHop, id3gJazz, id3gMetal, id3gNewAge,
    id3gOldies, id3gOther, id3gPop, id3gRNB, id3gRap, id3gReggae,
    id3gRock, id3gTechno, id3gIndustrial, id3gAlternative, id3gSka,
    id3gDeathMetal, id3gPranks, id3gSoundtrack, id3gEuroTechno,
    id3gAmbient, id3gTripHop, id3gVocal, id3gJazzFunk, id3gFusion,
    id3gTrance, id3gClassical, id3gInstrumental, id3gAcid, id3gHouse,
    id3gGame, id3gSoundClip, id3gGospel, id3gNoise, id3gAlternRock,
    id3gBass, id3gSoul, id3gPunk, id3gSpace, id3gMeditative,
    id3gInstrumentalPop, id3gInstrumentalRock, id3gEthnic, id3gGothic,
    id3gDarkwave, id3gTechnoIndustrial, id3gElectronic, id3gPopFolk,
    id3gEurodance, id3gDream, id3gSouthernRock, id3gComedy, id3gCult,
    id3gGangsta, id3gTop40, id3gChristianRap, id3gPopFunk, id3gJungle,
    id3gNativeAmerican, id3gCabaret, id3gNewWave, id3gPsychadelic,
    id3gRave, id3gShowtunes, id3gTrailer, id3gLoFi, id3gTribal,
    id3gAcidPunk, id3gAcidJazz, id3gPolka, id3gRetro, id3gMusical,
    id3gRockNRoll, id3gHardRock, id3gFolk, id3gFolkRock,
    id3gNationalFolk, id3gSwing, id3gFastFusion, id3gBebob, id3gLatin,
    id3gRevival, id3gCeltic, id3gBluegrass, id3gAvantgarde,
    id3gGothicRock, id3gProgressiveRock, id3gPsychedelicRock,
    id3gSymphonicRock, id3gSlowRock, id3gBigBand, id3gChorus,
    id3gEasyListening, id3gAcoustic, id3gHumour, id3gSpeech,
    id3gChanson, id3gOpera, id3gChamberMusic, id3gSonata, id3gSymphony,
    id3gBootyBass, id3gPrimus, id3gPornGroove, id3gSatire, id3gSlowJam,
    id3gClub, id3gTango, id3gSamba, id3gFolklore, id3gBallad,
    id3gPowerBallad, id3gRhythmicSoul, id3gFreestyle, id3gDuet,
    id3gPunkRock, id3gDrumSolo, id3gAcapella, id3gEuroHouse,
    id3gDanceHall
  );

const        //Blues eigentlich an erster Stelle
  ID3GenreName: array [0..GENRE_COUNT] of String = (
    '', 'Classic Rock', 'Country', 'Dance', 'Disco', 'Funk', 'Grunge',
    'Hip-Hop', 'Jazz', 'Metal', 'New Age', 'Oldies', 'Other', 'Pop', 'R&B',
    'Rap', 'Reggae', 'Rock', 'Techno', 'Industrial', 'Alternative', 'Ska',
    'Death Metal', 'Pranks', 'Soundtrack', 'Euro-Techno', 'Ambient',
    'Trip-Hop', 'Vocal', 'Jazz+Funk', 'Fusion', 'Trance', 'Classical',
    'Instrumental', 'Acid', 'House', 'Game', 'Sound Clip', 'Gospel',
    'Noise', 'AlternRock', 'Bass', 'Soul', 'Punk', 'Space', 'Meditative',
    'Instrumental Pop', 'Instrumental Rock', 'Ethnic', 'Gothic',
    'Darkwave', 'Techno-Industrial', 'Electronic', 'Pop-Folk',
    'Eurodance', 'Dream', 'Southern Rock', 'Comedy', 'Cult', 'Gangsta',
    'Top 40', 'Christian Rap', 'Pop/Funk', 'Jungle', 'Native American',
    'Cabaret', 'New Wave', 'Psychadelic', 'Rave', 'Showtunes', 'Trailer',
    'Lo-Fi', 'Tribal', 'Acid Punk', 'Acid Jazz', 'Polka', 'Retro',
    'Musical', 'Rock & Roll', 'Hard Rock', 'Folk', 'Folk-Rock',
    'National Folk', 'Swing', 'Fast Fusion', 'Bebob', 'Latin', 'Revival',
    'Celtic', 'Bluegrass', 'Avantgarde', 'Gothic Rock', 'Progressive Rock',
    'Psychedelic Rock', 'Symphonic Rock', 'Slow Rock', 'Big Band',
    'Chorus', 'Easy Listening', 'Acoustic', 'Humour', 'Speech', 'Chanson',
    'Opera', 'Chamber Music', 'Sonata', 'Symphony', 'Booty Bass', 'Primus',
    'Porn Groove', 'Satire', 'Slow Jam', 'Club', 'Tango', 'Samba',
    'Folklore', 'Ballad', 'Power Ballad', 'Rhythmic Soul', 'Freestyle',
    'Duet', 'Punk Rock', 'Drum Solo', 'Acapella', 'Euro-House', 'Dance Hall',
    'Goa', 'Drum & Bass', 'Club-House', 'Hardcore','Terror','Indie',
    'BritPop','Negerpunk', 'Polsk Punk', 'Beat','Christian Gangsta Rap',
    'Heavy Metal', 'Black Metal', 'Crossover', 'Contemporary Christian',
    'Christian Rock', 'Merengue', 'Salsa', 'Trash Metal', 'Anime', 'JPop',
    'Synthpop' );




      //Genre für Oggtag als string deklarieren bei nächster Datenbankversion

type
  TID3Tag = record
    Titel   : string[100];
    Artist  : string[100];
    Album   : string[100];
    Year    : string[10];
    Comment : string[255];
    Genre   : string[50];
    dauer   : integer;
    ausgelesen: boolean;
  end;

type TMp3Eintrag = record
      Nummer    : integer;
      filename  : string[255];
      path      : string[255];
      size      : integer;
      anzeige   : boolean;
      dauer     : string[6];
      spielcounter : integer;
      defekt    : boolean;
      id3tag    : Tid3tag;
  end;

type TMp3Liste=ARRAY OF TMp3Eintrag;

type TMp3Datenbank=ARRAY OF TMp3Liste;

type TMp3ListeMeta = record
        offen        : boolean;  
        SpeicherPfad : string [255];
        Pfade        : array [0..255] of string [255]; //Das sollte reichen
        PfadeAnzahl  : byte;
        maxNummer    : integer;  //Größte vergebene PlaylistenEintragsNummer
        spielend     : integer;  //Zuletzt spielende Nummer
        AnzeigeSpalten : array [0..4] of byte;
        SuchText     : string [255];
        zurueck      : array [0..99] of integer;
        vor          : array [0..99] of integer;
        position     : byte; //nutzloses byte
  end;

type TMp3DatenbankMeta=array of TMp3ListeMeta;
            //Könnte man auch in Mp3Datenbank 'kapseln', aber alle Prozeduren
            //bereits auf Array-Struktur getrimmt

type
   TDatenbank = class (TObject)
   private
    procedure OrdnerAnListeAnhaengen_intern(ADirectory, AMask: String;
      ARekursiv: Boolean; Liste: integer);
    procedure Suche_intern(SuchString: string; teilmengenseparator,
      liste: integer);


    function GetFileSizeEx(const AFileName: String): Int64;
    function AreFilesEqual(const file1, file2: String): Boolean;
    procedure VerwaisteEintraegeloeschen(ListenNummer: integer);
    function AreFilesEqual_Help(var Eintrag1,
      Eintrag2: TMp3Eintrag): boolean;
   public
    Mp3Daten    : TMp3Datenbank;
    Mp3DatenMeta: TMp3DatenbankMeta;
    constructor Create;

    procedure AddNeueListe;
 //   function GetArrayindex(Index, Liste: integer): integer;
    procedure ListeAnfuegen(Dateiname: string; Liste: integer);
    procedure ListeLeeren(Liste: integer);
    procedure ListenelementTauschen(var a, b: TMp3Eintrag);
    procedure RenameItem(ListenNummer,ElementNummer: integer);
    procedure ListeSpeichern(Dateiname: string; Liste: integer);
    procedure OrdnerAnListeAnhaengen(Verzeichnis: string; Liste: integer);
    procedure Suche(ListenNummer: integer; SuchText: string);
    function GetMediumFullFileName(ListenNummer, ElementNummer: integer;
      var FullFileName: string): boolean;
    function LeseId3(ListenNummer, ElementNummer: integer):boolean;
    function GetMediumId3Tag(ListenNummer,ElementNummer: integer): Tid3tag;
    function GetGListenIndex (ListenNummer,ElementNummer:integer):integer;
    function GetMediumPlayLength(ListenNummer,
      ElementNummer: integer): string;
    procedure SetMediumPlayLength(ListenNummer, ElementNummer: integer;
      dauer: string);
    procedure SchliesseListe(ListenNummer:integer; Speichern:boolean=true);

    function ElementNummerZuArrayIndex(ListenNummer,
                                         ElementNummer:integer): integer;
    function GetElementNummerbyFileName(ListenNummer: integer; Filepath,
      FileName: string; var ElementNummer: integer): boolean;
    procedure SetPreviousElementNummer(ListenNummer,
      ElementNummer: integer);
    function GetPreviousElementNummer(ListenNummer: integer): integer;
    function GetNextElementNummer(ListenNummer: integer;
      var ElementNummer: integer): boolean;
    function ListeExists(ListenNummer: integer): boolean;
    procedure RescanFolders(ListenNummer:integer);
    procedure AddFile(ListenNummer: integer; FileName: string);
    procedure DeleteItem(ListenNummer, ElementNummer: integer);
    function EintragExists(ListenNummer, ElementNummer: integer;
      var ArrayIndex: integer): boolean;
    procedure CopyItem(QuellListenNummer, QuellElementNummer,
      ZielListenNummer: integer);
    function ItemExists(ListenNummer: integer; Pfad,
      Dateiname: string): boolean;
    procedure Sort(ListenNummer, Kriterium: integer;AtoZ:boolean=true);
    function GetEintragfuerSpalte(Auswahl, Quelle, i: integer): string;
    procedure KopiereDoppelteMedienInAndereListe(QuellListe,
      Zielliste: integer);
    function GetShownFiles(ListenNummer: integer;
      var FileList: TStringlist): boolean;      
   end;


implementation

uses ump3, uspieler;

var  id3_1      : TID3v1;
     id3_2      : TID3v2;
     oggtag     : TOggVorbis;

constructor TDatenbank.Create;
begin
  SetLength(Mp3Daten,0);
  SetLength(Mp3DatenMeta,0);

  id3_1  :=TID3v1.Create;
  id3_2  :=TID3v2.Create;
  oggtag :=TOggVorbis.Create;
end;

procedure TDatenbank.AddNeueListe;
var i: integer;
begin
   //Neue Liste und MetaListe auf 0 setzen
  SetLength(Mp3Daten,High(Mp3Daten)+2);
  SetLength(Mp3Daten[High(Mp3Daten)],0);
  SetLength(Mp3DatenMeta,High(Mp3DatenMeta)+2);

   //Standardzuweisungen
  Mp3DatenMeta[High(Mp3DatenMeta)].maxNummer:=1;
  Mp3DatenMeta[High(Mp3DatenMeta)].offen:=true;
  MP3DatenMeta[High(Mp3DatenMeta)].AnzeigeSpalten[0]:=1;
  MP3DatenMeta[High(Mp3DatenMeta)].AnzeigeSpalten[1]:=0;
  MP3DatenMeta[High(Mp3DatenMeta)].AnzeigeSpalten[2]:=4;
  MP3DatenMeta[High(Mp3DatenMeta)].AnzeigeSpalten[3]:=9;
  MP3DatenMeta[High(Mp3DatenMeta)].AnzeigeSpalten[4]:=10;

  for i:=0 to High(MP3DatenMeta[High(Mp3DatenMeta)].zurueck) do
  begin
   MP3DatenMeta[High(Mp3DatenMeta)].zurueck[i]:=0;
   MP3DatenMeta[High(Mp3DatenMeta)].vor[i]:=0;
  end;
end;

procedure TDatenbank.SchliesseListe(ListenNummer:integer; Speichern:boolean=true);
begin
  if ListeExists(ListenNummer) then
  begin
    if fmp3.Aktiv.SpielendeListe=ListenNummer then fmp3.Stop;

    if Speichern
    then
     if Mp3DatenMeta[ListenNummer].SpeicherPfad=''
      then fmp3.ListeSpeichern(ListenNummer)
      else ListeSpeichern(Mp3DatenMeta[ListenNummer].SpeicherPfad,ListenNummer);

    SetLength(Mp3Daten[ListenNummer],0);
    Mp3DatenMeta[ListenNummer].offen:=false;
  end;
end;


function TDatenbank.GetGListenindex (ListenNummer,ElementNummer:integer):integer;
  var i,zaehler,ArrayIndex:integer;
begin
 Result:=-1;

 if ListeExists(ListenNummer) then
 begin
 zaehler:=-1;
 ArrayIndex:=ElementNummerZuArrayIndex(ListenNummer,ElementNummer);
 for i:=0 to Arrayindex do
 begin
    if Mp3Daten[Listennummer,i].anzeige then inc(zaehler);
 end;
 result:=zaehler;
 end;
{ if Result=-1
  then
   begin
   fmp3.Fehler('GListenIndex konnte nicht ermittel werden.');
   end; }
end;


procedure TDatenbank.ListeLeeren(Liste:integer);
begin
  SetLength(Mp3Daten[liste],0);
end;


function TDatenbank.GetPreviousElementNummer(ListenNummer: integer):integer;
var i :integer;
begin
  if ListeExists(ListenNummer) then
  with Mp3DatenMeta[ListenNummer] do
  begin

  Result:=zurueck[High(zurueck)];
  for i:=0 to High(vor)-1 do
   vor[i]:=vor[i+1];

  vor[High(vor)]:=result;

  for i:=High(zurueck) downto 1 do
   zurueck[i]:=zurueck[i-1];

  end
  else Result:=0;
end;


procedure TDatenbank.SetPreviousElementNummer(ListenNummer,ElementNummer: integer);
var i :integer;
begin
  if ListeExists(ListenNummer) then
  with Mp3DatenMeta[ListenNummer] do
  begin

  for i:=0 to High(zurueck)-1 do
   zurueck[i]:=zurueck[i+1];

 zurueck[High(zurueck)]:=ElementNummer;
 end;
end;


function TDatenbank.GetNextElementNummer(ListenNummer:integer; var ElementNummer:integer):boolean;
 var i:integer;
begin
  with Mp3DatenMeta[ListenNummer] do
  begin
 if (ListeExists(ListenNummer)) and (vor[High(vor)]<>0)
  then
   begin
    Result:=true;
    ElementNummer:=vor[High(vor)];
    for i:=High(vor) downto 1 do
     vor[i]:=vor[i-1];
   end
  else
     Result:=false;
 end;
end;


procedure TDatenbank.ListenElementTauschen (var a, b: TMp3Eintrag);
var c: TMp3Eintrag;
begin
  c:=a;
  a:=b;
  b:=c;
end;


procedure TDatenbank.Sort(ListenNummer,Kriterium:integer;AtoZ:boolean=true);


 procedure QuickSort(ListenNummer, Kriterium, iLo, iHi: Integer);
  var
    Lo, Hi  : Integer;
    Mid : string;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := GetEintragfuerSpalte(Kriterium,ListenNummer,(Lo + Hi) div 2);
    repeat
      while lowercase(GetEintragfuerSpalte(Kriterium,ListenNummer,Lo)) <
                                                      lowercase(Mid) do Inc(Lo);
      while lowercase(GetEintragfuerSpalte(Kriterium,ListenNummer,Hi)) >
                                                      lowercase(Mid) do Dec(Hi);
      if Lo <= Hi then
      begin
       ListenElementTauschen(MP3Daten[ListenNummer,Lo],MP3Daten[ListenNummer,Hi]);
  {      T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T; }
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then QuickSort(ListenNummer,Kriterium, iLo, Hi);
    if Lo < iHi then QuickSort(ListenNummer,Kriterium, Lo, iHi);
  end;

  var i: integer;
begin
 if ListeExists(ListenNummer)
 then
   begin
   QuickSort(ListenNummer,Kriterium,0,High(Mp3Daten[ListenNummer]));
   if not AtoZ
   then
     begin
      for i:=0 to (High(Mp3Daten[ListenNummer]) div 2) do
      begin
       ListenElementTauschen(MP3Daten[ListenNummer,i],
                        MP3Daten[ListenNummer,High(Mp3Daten[ListenNummer])-i]);
      end;
     end;
   end;
end;

function TDatenbank.GetEintragfuerSpalte(Auswahl,Quelle,i:integer):string;

begin
{
Interpret - Titel / Dateiname
Dauer
Dateiname (ohne Endung)
Dateiname (mit Endung)
Dateigröße
Interpret
Titel
Album
Jahr
Genere
Bitrate
Kommentar
Speicherpfad
[nichts]

intern: Speicherpfad + Interpret - Titel / Dateiname
}
  Result:='';

  case Auswahl of
  0: begin
     if (Mp3Daten[Quelle,i].id3tag.Artist='') and (Mp3Daten[Quelle,i].id3tag.Titel='')
     then Result:=fmp3.extractrealfilename(Mp3Daten[Quelle,i].filename)
     else
        begin
         if (Mp3Daten[Quelle,i].id3tag.Artist='')
         then Result:=Mp3Daten[Quelle,i].id3tag.Titel
         else Result:=Mp3Daten[Quelle,i].id3tag.Artist+ARTISTSEP+Mp3Daten[Quelle,i].id3tag.Titel;
        end;
    end;
   1: begin
       Result:=Mp3Daten[Quelle,i].dauer;
      end;
   2: begin
       Result:=fmp3.extractrealfilename(Mp3Daten[Quelle,i].filename);
      end;
   3: begin
       Result:=Mp3Daten[Quelle,i].filename;
      end;
   4: begin
       Result:=fmp3.filesizetostr(Mp3Daten[Quelle,i].size);
      end;
   5: begin
       Result:=Mp3Daten[Quelle,i].id3tag.Artist;
      end;
   6: begin
       Result:=Mp3Daten[Quelle,i].id3tag.Titel;
      end;
   7: begin
       Result:=Mp3Daten[Quelle,i].id3tag.Album;
      end;
   8: begin
       Result:=Mp3Daten[Quelle,i].id3tag.Year;
      end;
   9: begin
       Result:=Mp3Daten[Quelle,i].id3tag.genre;
      end;
  10: begin
 //       Result:=inttostr(Mp3Daten[Quelle,i].id3tag.bits);
      end;
  11: begin
        Result:=Mp3Daten[Quelle,i].id3tag.Comment;
      end;
  12: begin
        Result:=Mp3Daten[Quelle,i].path;
      end;
  13: begin
        Result:='';
      end;
  20: begin //SpezialSortierung
       if (Mp3Daten[Quelle,i].id3tag.Artist='') and (Mp3Daten[Quelle,i].id3tag.Titel='')
         then Result:=Mp3Daten[Quelle,i].filename
         else
          begin
           if (Mp3Daten[Quelle,i].id3tag.Artist='')
           then Result:=Mp3Daten[Quelle,i].id3tag.Titel
           else Result:=Mp3Daten[Quelle,i].id3tag.Artist+ARTISTSEP+Mp3Daten[Quelle,i].id3tag.Titel;
         end;
       Result:=Mp3Daten[Quelle,i].path+Result;
      end;
  end;

end;



procedure TDatenbank.KopiereDoppelteMedienInAndereListe(QuellListe,Zielliste:integer);
 var i,k   : integer;
     flag    : boolean;
begin
 if (ListeExists(QuellListe)) and (ListeExists(ZielListe))
 then
 begin

 for i:=0 to high(Mp3Daten[QuellListe]) do
   begin
     if Mp3Daten[QuellListe,i].anzeige then
       begin
          flag:=false;
          for k:=0 to high(Mp3Daten[QuellListe]) do
            begin
              if
             ( k<>i )
               and
             (
              (
                AreFilesEqual_Help(Mp3Daten[QuellListe,i],Mp3Daten[QuellListe,k])
              )
               or
             (
               Mp3Daten[QuellListe,i].filename = Mp3Daten[QuellListe,k].filename
             )
            ) 
              then
               begin
                 //Falls nicht schon früher gefunden
                 if not ItemExists(ZielListe,Mp3Daten[QuellListe,i].path,Mp3Daten[QuellListe,i].filename)
                 then
                   begin
                    SetLength(Mp3Daten[ZielListe],High(Mp3Daten[ZielListe])+2);
                    Mp3Daten[ZielListe,High(Mp3Daten[ZielListe])]:=Mp3Daten[QuellListe,k];
                    Mp3Daten[ZielListe,High(Mp3Daten[ZielListe])].Nummer:=
                       Mp3DatenMeta[ZielListe].maxNummer+1;
                    inc(Mp3DatenMeta[ZielListe].maxNummer);
                    flag:=true;
                   end;
               end;
            end;
          //Orginal falls Kopie gefunden
          if flag then
          begin
           SetLength(Mp3Daten[ZielListe],High(Mp3Daten[ZielListe])+2);
           Mp3Daten[ZielListe,High(Mp3Daten[ZielListe])]:=Mp3Daten[QuellListe,i];
            Mp3Daten[ZielListe,High(Mp3Daten[ZielListe])].Nummer:=
               Mp3DatenMeta[ZielListe].maxNummer+1;
            inc(Mp3DatenMeta[ZielListe].maxNummer);
          end;
       end;
   end;
 end;
end;

function TDatenbank.AreFilesEqual_Help(var Eintrag1,Eintrag2: TMp3Eintrag):boolean;
begin
  if Eintrag1.size = Eintrag2.size
  then Result:=AreFilesEqual( Eintrag1.path+Eintrag1.filename,
                              Eintrag1.path+Eintrag1.filename  )
  else Result:=false;
end;



procedure TDatenbank.OrdnerAnListeAnhaengen(Verzeichnis: string; Liste: integer);
var i   : integer;
    flag: boolean;
begin
    //Verzeichnis abspeichern
 flag:=false;
 for i:=0 to Mp3DatenMeta[Liste].PfadeAnzahl-1 do
  begin
    if Mp3DatenMeta[Liste].Pfade[i]=Verzeichnis then flag:=true;
  end;

 if not flag then
  begin
    inc(Mp3DatenMeta[Liste].PfadeAnzahl);
    Mp3DatenMeta[Liste].Pfade[Mp3DatenMeta[Liste].PfadeAnzahl-1]:=Verzeichnis;
  end;
    //Verzeichnis durchsuchen
 OrdnerAnListeAnhaengen_intern(Verzeichnis,'*.*',true,Liste);
end;


procedure TDatenbank.OrdnerAnListeAnhaengen_intern(ADirectory: string; AMask: String;
          ARekursiv: Boolean; Liste: integer);
var
  SR: TSearchRec;
begin
  if (ADirectory<>'') and (ADirectory[length(ADirectory)]<>'\') then
    ADirectory:=ADirectory+'\';

  if (FindFirst(ADirectory+AMask,faAnyFile-faDirectory,SR)=0) then begin
    repeat
      if (SR.Name<>'.') and (SR.Name<>'..') and (SR.Attr<>faDirectory) then
              begin
                //Daten dem dyn. Array zuweisen   //ähnlich AddFile
                if (fmp3.Spieler.ZustaendigerRenderKern(ExtractFileExt(SR.Name))<>-1)
                  and not (ItemExists(Liste,ADirectory,SR.Name))
                then
                begin
                SetLength(Mp3daten[liste],High(Mp3daten[liste])+2);
                Mp3daten[liste,High(Mp3daten[liste])].filename:=SR.Name;
                Mp3daten[liste,High(Mp3daten[liste])].path:=ADirectory;
                Mp3daten[liste,High(Mp3daten[liste])].size:=SR.Size;
                Mp3daten[liste,High(Mp3daten[liste])].anzeige:=true;
                  //Nummerierung der einzelnen Items
                Mp3daten[liste,High(Mp3daten[liste])].Nummer:=
                                    Mp3datenMeta[liste].maxNummer+1;
                inc(Mp3datenMeta[liste].maxNummer);
                end
                //
              end

    until FindNext(SR)<>0;
    FindClose(SR);
  end;

  if ARekursiv then
    if (FindFirst(ADirectory+'*.*',faDirectory,SR)=0) then
    begin
      repeat
        if (SR.Name<>'.') and (SR.Name<>'..') then
          OrdnerAnListeAnhaengen_intern(ADirectory+SR.Name,AMask,True,Liste);
      until FindNext(SR)<>0;
      FindClose(SR);
    end;
end;


function TDatenbank.ItemExists(ListenNummer :integer; Pfad,Dateiname :string):boolean;
 var i: integer;
begin
  Result:=false;

  if ListeExists(ListenNummer)
  then
  begin
    for i:=0 to High(Mp3Daten[ListenNummer]) do
    begin
      if (lowercase(Mp3Daten[ListenNummer,i].path)=lowercase(Pfad))
       and (lowercase(Mp3Daten[ListenNummer,i].filename)=lowercase(Dateiname))
       then
       begin
         Result:=true;
         break;
       end;
    end;
  end;
end;

procedure TDatenbank.DeleteItem(ListenNummer,ElementNummer: integer);
var index,i:integer;
begin
 if ListeExists(ListenNummer)
 then
  begin
     index:=ElementNummerZuArrayIndex(ListenNummer,ElementNummer);
     for i:=index to high( Mp3daten[ListenNummer] )-1 do
     begin
       Mp3daten[ListenNummer,i] := Mp3daten[ListenNummer,i+1];
     end;
     SetLength ( Mp3daten[ListenNummer], High (Mp3daten[ListenNummer]) );
  end;
end;


procedure TDatenbank.RenameItem(ListenNummer,ElementNummer: integer);
var  altname,neuname,endung:string;
     datei:file;
     i:integer;
begin
  if ListeExists(ListenNummer) then
  begin
      i:=ElementNummerZuArrayIndex(ListenNummer,ElementNummer);

      altname:=Mp3daten[ListenNummer,i].path + Mp3daten[ListenNummer,i].filename;
      endung:=ExtractFileExt(Mp3daten[ListenNummer,i].Filename);
      neuname:=fmp3.extractrealfilename ( Mp3Daten[ListenNummer,i].Filename );

    if inputquery(RENAMECAPTION,NEWFILENAMECAPTION,neuname) then
      begin
        if not fileexists(altname)
        then
          begin
            MessageDlg(Format(FILENOTFOUND, [altname]) , mtWarning , [mbOk] , 0 );
            exit;
          end;

        try
          assignfile( datei , altname );
          rename( datei , Mp3daten[ListenNummer,i].path+neuname+endung );
          Mp3daten[ListenNummer,i].filename:=neuname+endung;
        except
          MessageDlg(Format(UNABLETORENAME, [altname]), mtWarning , [mbOk] , 0 );
          exit;
        end; 
      end;
  end;
end;


procedure TDatenbank.Suche_intern (SuchString:string;teilmengenseparator,liste:integer);
var i,leerzeichenpos:integer;
    aktuellerName:string;
begin
  aktuellerName:='';
  leerzeichenpos:=posex(' ',SuchString,teilmengenseparator);

  if (leerzeichenpos>0) and (leerzeichenpos<length(SuchString))
  then
    begin
      suche_intern(SuchString,posex(' ',SuchString,teilmengenseparator)+1, liste);
    end   ;
   begin
   i:=teilmengenseparator;
    repeat
      aktuellerName:=aktuellerName+SuchString[i];
      inc(i)
    until (SuchString[i]=' ');
   end;

  aktuellerName:=trim(aktuellerName);

  for i:=0 to high(Mp3Daten[liste]) do
  begin
    if ( pos( ansiuppercase( AktuellerName ) ,
         ansiuppercase( fmp3.extractrealfilename ( Mp3Daten[liste,i].Filename ) )) =0 )
      and
       ( pos( ansiuppercase( AktuellerName ) ,
         ansiuppercase( fmp3.extractrealfilename ( Mp3Daten[liste,i].Path ) )) =0 )
      and
       ( pos( ansiuppercase( AktuellerName ) ,
         ansiuppercase( fmp3.extractrealfilename ( Mp3Daten[liste,i].id3tag.Titel ) )) =0 )
      and
       ( pos( ansiuppercase( AktuellerName ) ,
         ansiuppercase( fmp3.extractrealfilename ( Mp3Daten[liste,i].id3tag.Artist ) )) =0 )
      and
       ( pos( ansiuppercase( AktuellerName ) ,
         ansiuppercase( fmp3.extractrealfilename ( Mp3Daten[liste,i].id3tag.Album) )) =0 )         

    then
       Mp3Daten[liste,i].anzeige:=false;
  end;
end;


procedure TDatenbank.Suche(ListenNummer:integer;SuchText:string);
var name  : string;
    i     : integer;
begin
    Mp3DatenMeta[ListenNummer].SuchText:=SuchText;

    for i:=0 to High(Mp3Daten[ListenNummer]) do
    Mp3Daten[ListenNummer,i].anzeige:=true;

    name:=Suchtext;
    name:=trim(name);
    name:=name+' '; //Leerzeichen um Ende zu markieren

    if name <> ' '
    then Suche_intern(Name,1,ListenNummer);
end;


procedure TDatenbank.ListeAnfuegen (Dateiname:string; Liste:integer);
 var Datei : TFileStream;
     Mp3DatenLaenge,Mp3DatenSaetze,Mp3DatenMetaLaenge,DateiDatenVersion,i : integer;
begin
 if fileexists(dateiname)
 then
  begin
   try
   Datei:=TFileStream.Create(DateiName,fmOpenRead or fmShareDenyWrite);
   Datei.Position:=0;
   Datei.Read(DateiDatenVersion , sizeof(integer) );
    if DatenVersion=DateiDatenversion
    then
      begin
       //Daten
       Datei.Read(Mp3DatenSaetze,sizeof(integer));
       SetLength(Mp3Daten[Liste],Mp3DatenSaetze+1);
       Mp3DatenLaenge:=SizeOf (TMp3Eintrag);
       for i:=0 to Mp3DatenSaetze do
       Datei.Read(Mp3Daten[Liste,i] , Mp3DatenLaenge);
       //Meta
       Mp3DatenMetaLaenge:=sizeof(TMp3ListeMeta);
       Datei.Read(Mp3DatenMeta[Liste] , Mp3DatenMetaLaenge);

       Datei.Free; 
      end
    else
     begin
      MessageDlg(Format(PLSNOTCOMP, [DateiName]),mtWarning,[mbOk],0);
      Datei.Free;
      exit;
     end
   except
      MessageDlg(Format(PLSNOTLOAD, [DateiName]),mtWarning,[mbOk],0);
      Datei.Free;
      exit;
   end;
  end
 else
  begin
   MessageDlg(Format(PLSNOTFOUND, [DateiName]),mtWarning,[mbOk],0);
   exit;
  end;
end;


procedure TDatenbank.ListeSpeichern(Dateiname:string; Liste:integer);
 var Datei    : TFileStream;
     Mp3DatenLaenge,Mp3DatenMetaLaenge,i : integer;
begin
  Mp3DatenMeta[Liste].Speicherpfad:=dateiname;
  try
  Datei:=TFileStream.Create(DateiName,fmCreate);
  Datei.Position:=0;
  Datei.Write( DatenVersion , SizeOf(integer) );

  Mp3DatenLaenge:=High(Mp3Daten[Liste]);
  Datei.Write( Mp3DatenLaenge , SizeOf(integer) );
  for i:=0 to Mp3DatenLaenge do
  Datei.Write( Mp3Daten[Liste,i] , SizeOf(TMp3Eintrag) );

  Mp3DatenMetaLaenge:=SizeOf(TMp3ListeMeta);
  Datei.Write( Mp3DatenMeta[Liste] , Mp3DatenMetaLaenge );

  Datei.Free; 
  except
   MessageDlg(Format(PLSNOTSAVED, [DateiName]), mtwarning, [mbok],0);
   Datei.Free;
  end;
end;


function TDatenbank.GetMediumFullFileName (ListenNummer,ElementNummer : integer;
                                           var FullFileName:string):boolean;
var i:integer;
begin
  Result:=false;
    if EintragExists(ListenNummer,ElementNummer,i)
      then
        begin
    //      i:=ElementNummerZuArrayIndex(ListenNummer,ElementNummer);
          FullFileName:=Mp3Daten[ ListenNummer, i ].path +
                          Mp3Daten[ ListenNummer, i ].filename;
          Result:=true;
        end;
end;
      //Überprüft auf Existenz und gibt ggf. den ArrayIndex zurück
function TDatenbank.EintragExists(ListenNummer, ElementNummer:integer;
                                              var ArrayIndex:integer):boolean;
var i:integer;
begin
 Result:=false;
 ArrayIndex:=-1;
 if ListeExists(ListenNummer)
 then
   for i:=0 to High(Mp3Daten[ListenNummer]) do
    begin
      if ElementNummer=Mp3Daten[ListenNummer,i].Nummer
        then
          begin
           Result:=true;
           ArrayIndex:=i;
           break;
          end;
    end;
end;

function TDatenbank.ListeExists(ListenNummer:integer):boolean;
begin
  Result:=false;
  if (ListenNummer>=0) and (ListenNummer<=High(Mp3Daten))
  then Result:=(MP3DatenMeta[ListenNummer].offen);
end;


function TDatenbank.GetMediumId3Tag (ListenNummer,ElementNummer : integer)
                                                                      :Tid3tag;
begin
  Result:=Mp3Daten[ ListenNummer,
                 ElementNummerZuArrayIndex(ListenNummer,ElementNummer) ].id3tag;
end;


function TDatenbank.GetMediumPlayLength(ListenNummer,ElementNummer:integer):string;
begin
 Result:=Mp3Daten[ ListenNummer,
                 ElementNummerZuArrayIndex(ListenNummer,ElementNummer) ].dauer;
end;


procedure TDatenbank.SetMediumPlayLength(ListenNummer,ElementNummer:integer;
                                                        dauer:string);
begin
  Mp3Daten[ ListenNummer,
       ElementNummerZuArrayIndex(ListenNummer,ElementNummer) ].dauer:=dauer;
end;


function TDatenbank.LeseId3(ListenNummer,ElementNummer : integer):boolean;
var i : integer;
    FileExt:string;
begin
  Result:=false;
  i:=ElementNummerZuArrayIndex(ListenNummer,ElementNummer);
  FileExt:=extractfileext(Mp3Daten[ListenNummer,i].filename);

  if FileExt='.mp3'
  then
    begin
      id3_2.ReadFromFile(Mp3Daten[ListenNummer,i].path+
                                            Mp3Daten[ListenNummer,i].filename);
      if id3_2.Exists
      then
       begin
          Result:=true;
          with Mp3Daten[ListenNummer,i] do
            begin
              id3tag.Titel  := id3_2.Title;
              id3tag.Artist := id3_2.Artist;
              id3tag.Album  := id3_2.Album;
              id3tag.Year   := id3_2.Year;
              id3tag.Comment:= id3_2.Comment;
              id3tag.Genre  := id3_2.Genre;
              id3tag.ausgelesen:=true;
            end;
       end
      else
      begin
        id3_1.ReadFromFile(Mp3Daten[ListenNummer,i].path+
                                              Mp3Daten[ListenNummer,i].filename);
        if id3_1.Exists
        then
         begin
          Result:=true;
          with Mp3Daten[ListenNummer,i] do
            begin
              id3tag.Titel  := id3_1.Title;
              id3tag.Artist := id3_1.Artist;
              id3tag.Album  := id3_1.Album;
              id3tag.Year   := id3_1.Year;
              id3tag.Comment:= id3_1.Comment;
              if id3_1.GenreID<=GENRE_COUNT
              then id3tag.Genre  := id3GenreName[id3_1.GenreID]
              else id3tag.Genre  := '';

              id3tag.ausgelesen:=true;
            end;
         end;
       end;
    end;
    
  if FileExt='.ogg'
  then
    begin
      if oggtag.ReadFromFile(Mp3Daten[ListenNummer,i].path+
                                            Mp3Daten[ListenNummer,i].filename)
      then
        begin
        Result:=true;
        with Mp3Daten[ListenNummer,i] do
          begin
            id3tag.Titel  := oggtag.Title;
            id3tag.Artist := oggtag.Artist;
            id3tag.Album  := oggtag.Album;
            id3tag.Year   := oggtag.Date;
            id3tag.Comment:= oggtag.Comment;
            id3tag.Genre  := oggtag.genre;

            id3tag.ausgelesen:=true;
          end;
        end;
    end;
end;


function TDatenbank.ElementNummerZuArrayIndex(ListenNummer,
                                                ElementNummer:integer):integer;
var i : integer;
begin
  Result:=-1;
  if ListeExists(ListenNummer)
  then
   begin
    for i:=0 to High(Mp3Daten[ ListenNummer ]) do
     begin
       if Mp3Daten[ ListenNummer, i ].Nummer = ElementNummer
         then
          begin
            Result:=i;
            break;
          end;
      end;
    end;  
    if Result=-1
    then
      begin
       fmp3.Fehler('Der Eintrag '+inttostr(ElementNummer)+' konnte'
                      +' in der Datenbank nicht gefunden werden.'
                      +#13+'Operation abgebrochen.');
       abort;
      end;
end;


procedure TDatenbank.RescanFolders(ListenNummer:integer);
var i:integer;
begin
 VerwaisteEintraegeloeschen(ListenNummer);
 for i:=0 to 255 do
 begin
   if Mp3DatenMeta[ListenNummer].pfade[i]='' then break;
   OrdnerAnListeAnhaengen(Mp3DatenMeta[ListenNummer].pfade[i],ListenNummer);
 end;
end;

procedure TDatenbank.VerwaisteEintraegeloeschen(ListenNummer: integer);
 var i: integer;
begin
 for i:=High(Mp3Daten[ListenNummer]) downto 0 do
 begin
  if not FileExists(Mp3Daten[ListenNummer,i].path+Mp3Daten[ListenNummer,i].filename)
   then DeleteItem(ListenNummer,Mp3Daten[ListenNummer,i].Nummer);
 end;
end;

procedure TDatenbank.AddFile(ListenNummer:integer;FileName:string);
begin
 if ListeExists(ListenNummer) and FileExists(FileName)
 then
 begin
   if (fmp3.Spieler.ZustaendigerRenderKern(ExtractFileExt(FileName))<>-1)
   and not (ItemExists(ListenNummer,ExtractFileDir(FileName),ExtractFileName(FileName)))
   then
    begin
      SetLength(Mp3daten[ListenNummer],High(Mp3daten[ListenNummer])+2);
      Mp3daten[ListenNummer,High(Mp3daten[ListenNummer])].filename:=ExtractFileName(FileName);
      Mp3daten[ListenNummer,High(Mp3daten[ListenNummer])].path:=ExtractFilePath(FileName);
      Mp3daten[ListenNummer,High(Mp3daten[ListenNummer])].size:=GetFileSizeEx(FileName);
      Mp3daten[ListenNummer,High(Mp3daten[ListenNummer])].anzeige:=true;
      Mp3daten[ListenNummer,High(Mp3daten[ListenNummer])].spielcounter:=0;
                  //Nummerierung der einzelnen Items
      Mp3daten[ListenNummer,High(Mp3daten[ListenNummer])].Nummer:=
                                         Mp3datenMeta[ListenNummer].maxNummer+1;
      inc(Mp3datenMeta[ListenNummer].maxNummer);
   end;
 end;
end;

procedure TDatenbank.CopyItem(QuellListenNummer,QuellElementNummer,ZielListenNummer:integer);
var ArrayIndex : integer;
begin
  if (ListeExists(QuellListenNummer)) and (ListeExists(ZielListenNummer)) then
  begin
    SetLength(Mp3Daten[ZielListenNummer],High(Mp3Daten[ZielListenNummer])+2);
    ArrayIndex:=ElementNummerZuArrayIndex(QuellListenNummer,QuellElementNummer);

    Mp3Daten[ZielListenNummer,High(Mp3Daten[ZielListenNummer])]:=
      Mp3Daten[QuellListenNummer,ArrayIndex];
    Mp3Daten[ZielListenNummer,High(Mp3Daten[ZielListenNummer])].Nummer:=
      Mp3DatenMeta[ZielListenNummer].maxNummer+1;
    inc(Mp3DatenMeta[ZielListenNummer].maxNummer);
  end;
end;


function TDatenbank.GetElementNummerbyFileName(ListenNummer:integer;
                Filepath,FileName:string;var ElementNummer:integer):boolean;
var i:integer;
begin
  Result:=false;

  if ListeExists(ListenNummer) then
  begin
    for i:=0 to High(Mp3Daten[ListenNummer]) do
     if (filepath=Mp3Daten[ListenNummer,i].path) and
        (filename=Mp3Daten[ListenNummer,i].filename)
     then
       begin
         Result:=true;
         ElementNummer:=Mp3Daten[ListenNummer,i].Nummer;
       end;
  end;
end;

function TDatenbank.GetShownFiles(ListenNummer:integer;var FileList:TStringlist):boolean;
var i:integer;
begin
  Result:=false;

  if ListeExists(ListenNummer) then
  begin
    FileList.Clear;
      begin
        for i:=0 to High(Mp3Daten[ListenNummer]) do
        begin
          if Mp3Daten[ListenNummer,i].anzeige then
          begin
             FileList.Add(Mp3Daten[ListenNummer,i].path+Mp3Daten[ListenNummer,i].filename);
          end;
        end;
      end;
     Result:=FileList.Count>0;
  end;
end;


function TDatenbank.GetFileSizeEx(const AFileName: String): Int64;
var
  F: TSearchRec;
begin
  Result := -1;
  if FindFirst(AFileName, faAnyFile, F) = 0 then
  begin
    try
      Result :=  F.FindData.nFileSizeLow or (F.FindData.nFileSizeHigh shl 32);
    finally
      SysUtils.FindClose(F);
    end;
  end;
end;

function TDatenbank.AreFilesEqual(const file1, file2: String): Boolean;
var
  m1, m2: TMemoryStream;
begin
  Result := False;
  m1 := TMemoryStream.Create;
  try
    m1.LoadFromFile(file1);
    m2 := TMemoryStream.Create;
    try
      m2.LoadFromFile(file2);
      if m1.Size = m2.Size then
        Result := CompareMem(m1.Memory, m2.Memory, m1.Size);
    finally
      m2.Free;
    end;
  finally
    m1.Free;
  end
end;

end.
