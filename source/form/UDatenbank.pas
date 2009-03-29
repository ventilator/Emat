unit UDatenbank;

interface
                                               
uses dialogs, sysutils, strutils, classes, controls, windows, shellapi,
      oggvorbis, wmafile, Mp3FileUtils,
      ulang, uincex;

const DatenVersion:integer=8;
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



type
  TID3Tag = record
    Titel   : string;
    Artist  : string;
    Album   : string;
    Year    : string;
    Comment : string;
    Genre   : string;
    Track   : integer;
    dauer   : integer;
    ausgelesen: boolean;
  end;

type TMp3Eintrag = record
      Nummer    : integer;
      Filename  : string;
      Path      : string;
      Size      : integer;
      Anzeige   : boolean;
      Dauer     : string;
      Spielcounter : integer;
      Defekt    : boolean;
      Id3tag    : Tid3tag;
  end;

type TMp3Datenbank = array of array of TMp3Eintrag;

type TMp3ListeMeta = record
        offen           : boolean;
        FileName        : string;
        AnzahlSuchPfade : integer;
        SuchPfade       : array of string;
        maxNummer       : integer;
        AnzeigeSpalten  : array [0..4] of byte;
        SuchText        : string;
        history         : array [0..99] of integer;
        historyPosition : integer;
        mode            : integer;
        SuperSearchString: TStringList;
  end;

type TMp3DatenbankMeta=array of TMp3ListeMeta;

type
   TDatenbank = class (TObject)
   private

     Id3v1    : TId3v1Tag;
     Id3v2    : TId3v2Tag;
     mpegInfo : TMpegInfo;

     oggtag     : TOggVorbis;
     wmatag     : TWMAfile;


    function  GetFileSizeEx(const AFileName: String): Int64;

    function  AreFilesEqual(const file1, file2: String): Boolean;

    procedure VerwaisteEintraegeloeschen(ListenNummer: integer);

    function  AreFilesEqual_Help(var Eintrag1,Eintrag2: TMp3Eintrag): boolean;

    procedure AND_Search_Item_intern (ListenNummer,ArrayIndex:integer;
              SearchString:string;SearchPos:integer;var match:boolean);

    function  AND_Search_Item(ListenNummer,ElementNummer:integer;
              SearchString:string):boolean;

    procedure OR_Search(ListenNummer:integer; SearchString: string;
              SearchPos:integer);

    function  TrimSearchStringForSearch(SearchString:string):string;

    procedure AddFileToList(ListenNummer,ArrayIndex,Size :Integer; FileName,
                                   Path :string; ListWasEmty :boolean);

    //Verschiebt eine Datei oder ein Verzeichnis in den Papierkorb
    function DeleteFileToRecycleBin(const AFile: string): boolean;

    procedure CreateSuperSearchString(ListenNummer:integer);

   public

    Mp3Daten    : TMp3Datenbank;
    Mp3DatenMeta: TMp3DatenbankMeta;

    constructor Create;

    procedure AddNeueListe;

 //   function GetArrayindex(Index, Liste: integer): integer;

    procedure LoadPlaylist(FileName:string; ListenNummer:integer);

    procedure ListeLeeren(Liste: integer);

    procedure ListenelementTauschen(var a, b: TMp3Eintrag);

    procedure RenameItem(ListenNummer,ElementNummer: integer);

    procedure SavePlaylist(FileName:string; ListenNummer:integer);

    procedure OrdnerAnListeAnhaengen(Verzeichnis: string; ListenNummer: integer);

    function  GetMediumFullFileName(ListenNummer, ElementNummer: integer;
              var FullFileName: string): boolean;

    function  LeseId3(ListenNummer, ElementNummer: integer):boolean;

    function  GetMediumId3Tag(ListenNummer,ElementNummer: integer): Tid3tag;

    function  GetGListenIndex (ListenNummer,ElementNummer:integer):integer;

    function  GetMediumPlayLength(ListenNummer,ElementNummer: integer): string;

    procedure SetMediumPlayLength(ListenNummer, ElementNummer: integer;
              dauer: string);

    procedure ListeSchliessen(ListenNummer:integer; Speichern:boolean=true);

    function  ElementNummerZuArrayIndex(ListenNummer,
              ElementNummer:integer): integer;

    function  GetArrayIndex(ListenNummer,
              ElementNummer:integer; var ArrayIndex:integer):boolean;

    function  GetElementNummerbyFileName(ListenNummer: integer; Filepath,
              FileName: string; var ElementNummer: integer): boolean;

    function  GetPreviousElementNummer(ListenNummer: integer): integer;

    function  GetNextElementNummer(ListenNummer: integer;
              var ElementNummer: integer): boolean;

    function  ListeExists(ListenNummer: integer): boolean;

    procedure RescanFolders(ListenNummer:integer);

    procedure AddFile(ListenNummer: integer; FileName: string);

    //Löscht ein Element aus dem Mp3Daten-Array
    //Der 2. Parameter ist wahlweise die ElementNummer oder der ArrayIndex
    procedure DeleteItem(ListenNummer,ElementNummerOrArrayIndex: integer;
                          IsArrayIndex:boolean=false);

    function  EintragExists(ListenNummer, ElementNummer: integer;
              var ArrayIndex: integer): boolean;

    procedure CopyItem(QuellListenNummer, QuellElementNummer,
              ZielListenNummer: integer);

    function  ItemExists(ListenNummer: integer; Pfad,Dateiname: string): boolean;

    procedure Sort(ListenNummer, Kriterium: integer;AtoZ:boolean=true);

    function  GetEintragfuerSpalte(Auswahl, Quelle, i: integer): string;

    procedure KopiereDoppelteMedienInAndereListe(QuellListe,
              Zielliste: integer);

    function  GetShownFiles(ListenNummer: integer;
              var FileList: TStringlist): boolean;

    procedure ResetMp3DatenMeta (ListenNummer:integer);

    procedure IncPlayCounter(ListenNummer, ElementNummer: integer);

    procedure SaveId3(Title,Artist,Album,Year,Comment,Genere,Track:string;
                         SaveTitle,SaveArtist,SaveAlbum,SaveYear,SaveComment,
                         SaveGenre,SaveTrack:boolean;
                         ListenNummer,ElementNummer:integer );

    procedure AddItem(ListenNummer:integer;Item:TMp3Eintrag;
                      Setvisible:boolean=true;ItemMustNotExist:boolean=false);

    procedure SetPlaylistMode(ListenNummer,Mode:integer);

    procedure RedundanteItemsAussortieren(ListenNummer:integer);

    procedure Search(ListenNummer:integer; SearchString: string);

    //SetHistory ist mit History_QueueItem fast identisch
    //Bitte letzteres nutzen und erstes bei Zeiten löschen
    procedure SetHistory(ListenNummer,ElementNummer:integer);

    procedure ClearHistoryStatus(ListenNummer:integer);

    procedure History_QueueItem(ListenNummer,ElementNummer:integer;
                                Position : integer = 0 );

    procedure VerifyHistory(ListenNummer: integer);

    procedure GetFavoritItems(ListenNummer,MaxAnzahl: integer;
              var Name,Nummer,Anzahl:TStringlist);

    function GetPlayLengthOfAllFiles(ListenNummer:integer):int64;

    procedure CopyAllFilesToANewListSortedbyNummberOfFilesofFolder;

    procedure RemoveEmptyFolders(ListenNummer:integer);

    //Löscht alle Elemente aus dem Mp3Daten-Array deren .FileName = '' ist
    //Diese Elemente können beim OrdnerAnListeAnhaengen entstehen
    procedure DeleteInvalidItems(ListenNummer:integer);

    function DeleteDirAndItsItems(Dir:string; ListenNummer:integer):boolean;

    //Liefert die Suchpfade einer Liste
    function GetSearchDir(ListenNummer:integer; var DirList:TStringlist)
             :boolean;

    //Verschiebt Elemente
    procedure MoveItem(ListenNummer,SourceElementNummer,TargetElementNummer
                              :integer);
    //Löscht Historyelemente
    procedure History_DeleteItem(ListenNummer,Position:integer);

    //Baut aus einer StringListe die History neu auf
    procedure History_RebuiltfromStringList(ListenNummer:integer;
                ElementNummerListe:TStringlist;HistoryPosition:integer);

    //Kapselt GetEintragfuerSpalte            
    function GetValue(ListenNummer,ElementNummer,ValueIndex:integer):string;

    //Erzeugt einen Dateinamen für das Playlistverzeichnis
    procedure CreateFileNameForPlaylist (ListenNummer : integer; PlaylistDir: string);

    //Anzahl der Titel in einer Playliste
    function GetLengthOfList (ListenNummer:integer):integer;
   end;


implementation

uses ump3, uspieler, ustatus;

constructor TDatenbank.Create;
begin
  SetLength(Mp3Daten,0);
  SetLength(Mp3DatenMeta,0);

  Id3v1    := TId3v1Tag.Create;
  Id3v2    := TId3v2Tag.Create;
  mpegInfo := TMpegInfo.Create;

  oggtag :=TOggVorbis.Create;
  wmatag :=TWMAFile.Create;
end;

procedure TDatenbank.AddNeueListe;
begin
   //Neue Liste und MetaListe auf 0 setzen
  SetLength(Mp3Daten,High(Mp3Daten)+2);
  SetLength(Mp3Daten[High(Mp3Daten)],0);

  SetLength(Mp3DatenMeta,High(Mp3DatenMeta)+2);
  ResetMp3DatenMeta(High(Mp3Daten));
end;

procedure TDatenbank.ResetMp3DatenMeta(ListenNummer:integer);
var i:integer;
begin
 // if ListeExists(ListenNummer) then   ListeExist ist nur bei offenen Listen wahr
  begin
     //Standardzuweisungen
    Mp3DatenMeta[ListenNummer].maxNummer:=1;
    Mp3DatenMeta[ListenNummer].offen:=true;
    Mp3DatenMeta[ListenNummer].AnzeigeSpalten[0]:=1;
    Mp3DatenMeta[ListenNummer].AnzeigeSpalten[1]:=0;
    Mp3DatenMeta[ListenNummer].AnzeigeSpalten[2]:=7;
    Mp3DatenMeta[ListenNummer].AnzeigeSpalten[3]:=9;
    Mp3DatenMeta[ListenNummer].AnzeigeSpalten[4]:=8;
    Mp3DatenMeta[ListenNummer].AnzahlSuchPfade:=0;
    Mp3DatenMeta[ListenNummer].mode:=0;
    Mp3DatenMeta[ListenNummer].SuperSearchString:=TStringList.Create;

    for i:=0 to High(Mp3DatenMeta[ListenNummer].history) do
    begin
     Mp3DatenMeta[ListenNummer].history[i]:=0;
     Mp3DatenMeta[ListenNummer].historyposition:=0;
    end;
  end;
end;


procedure TDatenbank.ListeSchliessen(ListenNummer:integer; Speichern:boolean=true);
  var FileName : string;
begin
  if ListeExists(ListenNummer) then
  begin
    if   Speichern
    then
      begin
        FileName := Mp3DatenMeta[ListenNummer].FileName;
        SavePlaylist(Mp3DatenMeta[ListenNummer].FileName,ListenNummer);
      end;
    SetLength(Mp3Daten[ListenNummer],0);
    Mp3DatenMeta[ListenNummer].offen:=false;
  end;
end;


procedure TDatenbank.CreateFileNameForPlaylist (ListenNummer: integer; PlaylistDir: string);
var  FileName  : string;
     i         : integer;
begin
  CreateDir(PlaylistDir);
  i:=0;
  repeat
    inc(i);
    FileName := 'Playliste ('+inttostr(i)+').epl'
  until not FileExists(PlaylistDir + FileName);

  Mp3DatenMeta[ListenNummer].FileName:=PlaylistDir + FileName;
end;


function TDatenbank.GetLengthOfList (ListenNummer:integer):integer;
begin
  if ListeExists(ListenNummer)
  then Result:=Length(Mp3Daten[ListenNummer])
  else Result:=0;
end;

function TDatenbank.GetGListenIndex (ListenNummer,ElementNummer:integer):integer;
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
   fmp3.Fehler('GListenIndex konnte nicht ermittel werden.'+#13
                +'Operation abgebrochen.');
   abort;
   end;   }
end;


procedure TDatenbank.ListeLeeren(Liste:integer);
begin
  SetLength(Mp3Daten[liste],0);
  ResetMp3DatenMeta(Liste);
end;


procedure TDatenbank.SetHistory(ListenNummer,ElementNummer:integer);
var i:integer;
begin
  with Mp3DatenMeta[ListenNummer] do
   begin
     if (historyposition=0) and (history[0]<>ElementNummer) then
     begin
       for i:=high(history) downto 1 do
         history[i]:=history[i-1];

       history[0]:=ElementNummer;
     end;
   end;
end;

procedure TDatenbank.ClearHistoryStatus(ListenNummer:integer);
  procedure tausche(var a,b:integer);
  var c:integer;
  begin
    c:=a;
    a:=b;
    b:=c;
  end;

var i:integer;
begin
  with Mp3DatenMeta[ListenNummer] do
  begin
    for i:=0 to (historyposition div 2) do
      tausche(history[i],history[historyposition-i]);
    historyposition:=0;
  end;
end;

function TDatenbank.GetPreviousElementNummer(ListenNummer:integer):integer;
begin
  with Mp3DatenMeta[ListenNummer] do
   begin
     result:=history[historyposition+1];
     if historyposition<high(history) then inc(historyposition);
   end;
end;


function TDatenbank.GetNextElementNummer(ListenNummer:integer; var ElementNummer:integer):boolean;
begin
  with Mp3DatenMeta[ListenNummer] do
  begin
    if historyposition=0 then
      Result:=false
    else
      begin
       Result:=true;
       ElementNummer:=history[historyposition-1];
       dec(historyposition);
      end;
   end;
end;


procedure TDatenbank.History_QueueItem(ListenNummer,ElementNummer:integer;
                                       Position : integer = 0 );
var i:integer;
                      
begin
  with Mp3DatenMeta[ListenNummer] do
  begin
    if (ListeExists(ListenNummer)) and (history[Position]<>ElementNummer)
    then
      begin
        for i:=high(history) downto 1 do
          history[i]:=history[i-1];
        history[Position]:=ElementNummer;
        if historyposition<high(history) then inc(historyposition);
      end;
  end;
end;


procedure TDatenbank.History_DeleteItem(ListenNummer,Position:integer);
  var
   i : integer;
begin
    if ListeExists(ListenNummer) then
    begin
      with Mp3DatenMeta[ListenNummer] do
        begin
          for i:=Position to High(History)-1 do
            begin
              History[i]:=History[i+1];
            end;
          History[99]:=0;
          if HistoryPosition>Position then dec(HistoryPosition);
        end;
    end;    
end;


procedure TDatenbank.History_RebuiltfromStringList(ListenNummer:integer;
                      ElementNummerListe:TStringlist;HistoryPosition:integer);
var
   i,max :integer;

begin
  If ListeExists(ListenNummer) and (ElementNummerListe.Count>0) then
    begin
      if ElementNummerListe.Count>99
        then max:=99
        else max:=ElementNummerListe.Count-1;

      for i:=0 to max do
        Mp3DatenMeta[ListenNummer].History[i]:=strtoint(ElementNummerListe[i]);

      Mp3DatenMeta[ListenNummer].HistoryPosition:=HistoryPosition;
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
      while NatCompare(
                lowercase(GetEintragfuerSpalte(Kriterium,ListenNummer,Lo)),
                lowercase(Mid))<0
      do Inc(Lo);

      while NatCompare(
                lowercase(GetEintragfuerSpalte(Kriterium,ListenNummer,Hi)),
                lowercase(Mid))>0
      do Dec(Hi);
   {   while lowercase(GetEintragfuerSpalte(Kriterium,ListenNummer,Lo)) <
                                                      lowercase(Mid) do Inc(Lo);
      while lowercase(GetEintragfuerSpalte(Kriterium,ListenNummer,Hi)) >
                                                      lowercase(Mid) do Dec(Hi); }
      if Lo <= Hi then
      begin
       ListenElementTauschen(MP3Daten[ListenNummer,Lo],MP3Daten[ListenNummer,Hi]);
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


function TDatenbank.GetValue(ListenNummer,ElementNummer,ValueIndex:integer):string;
begin
  if ListeExists(ListenNummer) then
  begin
    Result:=GetEintragfuerSpalte(ValueIndex,ListenNummer,ElementNummerZuArrayIndex(ListenNummer,ElementNummer));
  end
  else
    Result:='';
end;


function TDatenbank.GetEintragfuerSpalte(Auswahl,Quelle,i:integer):string;

begin
{
0  Interpret - Titel / Dateiname
1   Dauer
2   Dateiname (ohne Endung)
3   Dateiname (mit Endung)
4   Dateigröße
5   Interpret
6   Titel
7   Album
8   Jahr
9   Genere
10    Bitrate
11    Kommentar
12    Speicherpfad
13    Anzahl Abspielvorgänge
14    [nichts]

20  intern: Speicherpfad + Album + Track + Interpret + Titel / Dateiname
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
           else
             if Mp3Daten[Quelle,i].id3tag.Titel<>''
             then Result:=Mp3Daten[Quelle,i].id3tag.Artist+ARTISTSEP+Mp3Daten[Quelle,i].id3tag.Titel
             else Result:=Mp3Daten[Quelle,i].id3tag.Artist
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
      // if length(result)>4 then showmessage(result);
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
        Result:=inttostr(Mp3Daten[Quelle,i].spielcounter);
      end;
  14: begin
        Result:='';
      end;
  20: begin //SpezialSortierung
       with Mp3Daten[Quelle,i] do
       begin
         if (Mp3Daten[Quelle,i].id3tag.Artist='') and (Mp3Daten[Quelle,i].id3tag.Titel='')
           then Result:=Mp3Daten[Quelle,i].filename
           else
            begin
             if (Mp3Daten[Quelle,i].id3tag.Artist='')
             then Result:=Mp3Daten[Quelle,i].id3tag.Titel
             else
               if Mp3Daten[Quelle,i].id3tag.Titel<>''
               then Result:=Mp3Daten[Quelle,i].id3tag.Artist+ARTISTSEP+Mp3Daten[Quelle,i].id3tag.Titel
               else Result:=Mp3Daten[Quelle,i].id3tag.Artist
           end;

          if id3tag.track<>0
          then Result:=inttostr(id3tag.track)+Result;

          if id3tag.Album<>''
          then Result:=id3tag.Album+Result;

         Result:=Mp3Daten[Quelle,i].path+Result;
       end;
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
   //  if Mp3Daten[QuellListe,i].anzeige then
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
                    AddItem(ZielListe,Mp3Daten[QuellListe,k],true);
                    flag:=true;
                   end;
               end;
            end;
          //Orginal falls Kopie gefunden
          if flag then
          begin
             AddItem(ZielListe,Mp3Daten[QuellListe,i],true);
          end;
       end;
   end;
 end;
end;

procedure TDatenbank.AddItem(ListenNummer:integer;Item:TMp3Eintrag;
                        SetVisible:boolean=true;ItemMustNotExist:boolean=false);
begin
  if (ListeExists(ListenNummer)) and  ((not ItemMustNotExist)
     or (not ItemExists(ListenNummer,Item.path,item.Filename)))  then
  begin
    if SetVisible then item.anzeige:=true;

    SetLength(MP3Daten[ListenNummer],High(MP3Daten[ListenNummer])+2);
    Mp3Daten[ListenNummer,High(Mp3Daten[ListenNummer])]:=Item;
    Mp3Daten[ListenNummer,High(Mp3Daten[ListenNummer])].Nummer:=
                                          Mp3DatenMeta[ListenNummer].maxNummer+1;
    inc(Mp3DatenMeta[ListenNummer].maxNummer);
  end;
end;


function TDatenbank.AreFilesEqual_Help(var Eintrag1,Eintrag2: TMp3Eintrag):boolean;
begin
  if Eintrag1.size = Eintrag2.size
  then Result:=AreFilesEqual( Eintrag1.path+Eintrag1.filename,
                              Eintrag2.path+Eintrag2.filename  )
  else Result:=false;
end;

//Diese Funktion löscht alle leeren Ordner aus den Suchpfaden
//{ursprüngliche Version: "Delete-Tool" aus "OrdnerSync"
procedure TDatenbank.RemoveEmptyFolders(ListenNummer:integer);
var i,counter:integer;
    DirList: TStringlist;

procedure GetDirectorys(ADirectory: string; AMask: String; AList: TStrings; ARekursiv: Boolean);
var
  SR: TSearchRec;
begin
  if (ADirectory<>'') and (ADirectory[length(ADirectory)]<>'\') then
    ADirectory:=ADirectory+'\';

  if (FindFirst(ADirectory+AMask,faDirectory,SR)=0) then begin
    repeat
      if (SR.Name<>'.') and (SR.Name<>'..') and (SR.Attr=faDirectory) then
          AList.Add(ADirectory+SR.Name)
    until FindNext(SR)<>0;
    sysutils.FindClose(SR);
  end;

  if ARekursiv then
    if (FindFirst(ADirectory+'*.*',faDirectory,SR)=0) then
    begin
      repeat
        if (SR.Name<>'.') and (SR.Name<>'..') then
          GetDirectorys(ADirectory+SR.Name,AMask,AList,True);
      until FindNext(SR)<>0;
      sysutils.FindClose(SR);
    end;
end;


begin
 if (ListeExists(ListenNummer)) and
    (MessageDlg('Alle leeren Verzeichnisse aus den hinzugefügten Verzeichnissen werden jetzt gelöscht.'
               +#13+'Dieser Vorgang kann mitunter mehrere Minuten dauern.',mtConfirmation, [mbok, mbcancel], 0) = mrok)
  then
 begin
   DirList:= TStringlist.Create;

   for i:=0 to Mp3DatenMeta[ListenNummer].AnzahlSuchpfade-1 do
     GetDirectorys(Mp3DatenMeta[ListenNummer].Suchpfade[i],'*.*',DirList,true);

   DirList.Sort;
   counter:=0;

{ Liste wird rückwärts durchlaufen, weil so erst die Unterordner gelöscht
  werden }
   for i:=DirList.Count-1 downto 0 do
   begin
     if RemoveDir(DirList[i]) then inc(counter);
   end;

  MessageDlg('Es wurden '+inttostr(counter)+' leere Verzeichnisse gelöscht.',
             mtInformation, [mbok],0);
end;
      
{
PROCEDURE TFHaupt.LeereOrdnerLoeschen(Pfad:string);
VAR Ordnerliste,Errors:TStringlist;
VAR i,anzahl,gesamtanzahl:integer;
BEGIN
IF MessageDlg('Alle leeren Ordner in "'+pfad+'" werden jetzt gelöscht.'+#13+'Dieser Vorgang kann mitunter mehrere Minuten dauern.',mtConfirmation, [mbok, mbcancel], 0) = mrcancel
THEN exit;

gesamtanzahl:=0;
Ordnerliste:=TStringlist.Create;
Errors:=TStringlist.Create;

GetConsoleOutput('cmd /c dir '+Pfad+' /b /ad /o /s', ordnerliste, errors);

REPEAT
anzahl:=0;

FOR i:=0 TO ordnerliste.Count-1 DO
  BEGIN
  IF RemoveDir(ordnerliste[i]) THEN inc(anzahl);
  END;

gesamtanzahl:=gesamtanzahl+anzahl;

UNTIL anzahl=0;


Showmessage('Es wurden '+inttostr(gesamtanzahl)+' leere Ordner in "'+pfad+'" gelöscht.');
END;}

end;


procedure TDatenbank.OrdnerAnListeAnhaengen(Verzeichnis: string; ListenNummer: integer);
var i,ArrayLength   : integer;
    flag,EmtyFlag: boolean;
    FileList,DirList,SizeList: TStringList;

procedure OrdnerAnListeAnhaengen_intern(ADirectory: string; AMask: String;
          ARekursiv: Boolean; ListenNummer: integer; FastAndUnsaveMode:boolean=false);
var
  SR: TSearchRec;

begin

  if (ADirectory<>'') and (ADirectory[length(ADirectory)]<>'\') then
    ADirectory:=ADirectory+'\';

  fmp3.updatetextfstatus('Durchsuche '+adirectory,
    'Es werden Medien der Playliste hinzugefügt... ('+inttostr(FileList.Count)+' Titel)');

  if (FindFirst(ADirectory+AMask,faAnyFile-faDirectory,SR)=0) then
   begin
    repeat
      if (SR.Name<>'.') and (SR.Name<>'..') and (SR.Attr<>faDirectory) then
              begin
                //Daten dem dyn. Array zuweisen   //ähnlich AddFile
                if (fmp3.Spieler.ZustaendigerRenderKern(ExtractFileExt(sr.Name))=
                                              Mp3DatenMeta[ListenNummer].mode)
                then
                  begin
                    //Zwischenspeichern in einer StringListe um einmalig ein
                    //SetLength auf das Array Anwenden zu müssen.
                    //Tausende SetLengths erzeugen viel Speicherlast.
                    FileList.Add(sr.Name);
                    Dirlist.Add(adirectory);
                    sizelist.Add(inttostr(sr.size));

                    //AddFileToList(ListenNummer,SR.Size,sr.Name,Adirectory,FastAndUnsaveMode);
                  end;

                //
              end

    until FindNext(SR)<>0;
    sysutils.FindClose(SR);
  end;

  if ARekursiv then
    if (FindFirst(ADirectory+'*.*',faDirectory,SR)=0) then
    begin
      repeat
        if (SR.Name<>'.') and (SR.Name<>'..') then
          OrdnerAnListeAnhaengen_intern(ADirectory+SR.Name,AMask,True,ListenNummer,
                                              FastAndUnsaveMode);
      until FindNext(SR)<>0;
      sysutils.FindClose(SR);
    end;


end;


begin
//Verzeichnis abspeichern
 flag:=true;
 for i:=0 to Mp3DatenMeta[ListenNummer].AnzahlSuchPfade-1 do
  begin
    //Unterverzeichnisse werden nicht hinzugefügt
    if (Pos(Mp3DatenMeta[ListenNummer].SuchPfade[i],Verzeichnis)>0)
    then flag:=false;

    //Überverzeichnisse überschreiben ihr Unterverzeichnis
    //und werden ebenfalls nicht hinzugefügt
    if (Pos(Verzeichnis,Mp3DatenMeta[ListenNummer].SuchPfade[i])>0)
    then
      begin
        Mp3DatenMeta[ListenNummer].SuchPfade[i]:=Verzeichnis;
        flag:=false;
      end;
  end;

 if flag then
  begin
    inc(Mp3DatenMeta[ListenNummer].AnzahlSuchPfade);
    SetLength(Mp3DatenMeta[ListenNummer].SuchPfade,High(Mp3DatenMeta[ListenNummer].SuchPfade)+2);
    Mp3DatenMeta[ListenNummer].SuchPfade[Mp3DatenMeta[ListenNummer].AnzahlSuchPfade-1]:=Verzeichnis;
  end;
//

//Verzeichnis durchsuchen
  EmtyFlag:= (High(Mp3Daten[ListenNummer])=-1);

  FileList:=TStringList.Create;
  DirList :=TStringList.Create;
  SizeList:=TStringList.Create;

  OrdnerAnListeAnhaengen_intern(Verzeichnis,'*.*',true,ListenNummer,EmtyFlag);

  //Einmaliger SetLength-Aufruf um Speicher zu sparen
  //Array wird um neue Anzahl erweitert
  ArrayLength:=High(Mp3daten[ListenNummer])+1;
  SetLength(Mp3daten[ListenNummer],ArrayLength+filelist.Count);

  fmp3.StartFStatus(filelist.Count);

  for i:=0 to filelist.Count-1 do
  begin
    if i mod 10 = 0 then
     fmp3.UpdateFStatus(dirlist.Strings[i]+filelist.Strings[i],i+1);

    AddFileToList(ListenNummer, ArrayLength+i, strtoint(sizelist.Strings[i]),
                  filelist.Strings[i], dirlist.Strings[i], EmtyFlag);
  end;
//

 if EmtyFlag then Sort(ListenNummer, 20);
 //RedundanteItemsAussortieren(ListenNummer); nicht nötig weil die nicht entstehen können


end;


procedure TDatenbank.AddFileToList(ListenNummer,ArrayIndex,Size :Integer; FileName,
                                   Path :string; ListWasEmty :boolean);
begin
  if (ListWasEmty) or
         (not (ItemExists(ListenNummer,Path,filename)))
  then
  begin

    Mp3daten[ListenNummer,ArrayIndex].filename:=filename;
    Mp3daten[ListenNummer,ArrayIndex].path:=Path;
    Mp3daten[ListenNummer,ArrayIndex].size:=size;
    Mp3daten[ListenNummer,ArrayIndex].anzeige:=true;
      //Nummerierung der einzelnen Items
    Mp3daten[ListenNummer,ArrayIndex].Nummer:=
                                         Mp3datenMeta[ListenNummer].maxNummer+1;
    inc(Mp3datenMeta[ListenNummer].maxNummer);

    LeseId3(ListenNummer,Mp3daten[ListenNummer,ArrayIndex].Nummer);
  end;
end;


function TDatenbank.ItemExists(ListenNummer :integer; Pfad,Dateiname :string):boolean;
 var i: integer;
begin
  Result:=false;
  Pfad:=lowercase(Pfad);
  Dateiname:=lowercase(Dateiname);

  if (ListeExists(ListenNummer))
  then
  begin
    for i:=0 to High(Mp3Daten[ListenNummer]) do
    begin
      if (lowercase(Mp3Daten[ListenNummer,i].path)=Pfad)
       and (lowercase(Mp3Daten[ListenNummer,i].filename)=Dateiname)
       then
       begin
         Result:=true;
         break;
       end;
    end;
  end;
end;

procedure TDatenbank.DeleteItem(ListenNummer,ElementNummerOrArrayIndex: integer;
                                IsArrayIndex:boolean=false);
var index,i:integer;
begin
 if ListeExists(ListenNummer)
 then
  begin
     if IsArrayIndex
     then
       index:=ElementNummerOrArrayIndex
     else
       index:=ElementNummerZuArrayIndex(ListenNummer,ElementNummerOrArrayIndex);

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


function tdatenbank.TrimSearchStringForSearch(SearchString:string):string;
begin
  if SearchString<>''
  then
   begin
     if CharInSet(SearchString[1],[' ',';'])
     then
      begin
       if length(SearchString)>1
         then
           begin
             SearchString := CopyEx(SearchString,2,-1);
             SearchString:=TrimSearchStringForSearch(SearchString)
           end
         else Searchstring :='';
      end;

  if SearchString<>''
  then
    begin
     if CharInSet(SearchString[length(searchstring)],[' ',';'])
     then
       begin
       SearchString := Copy(SearchString,1,length(searchstring)-1);
       SearchString:=TrimSearchStringForSearch(SearchString)
       end;
   end;
   end;
   Result:=ansilowercase(SearchString);
end;



procedure TDatenbank.AND_Search_Item_intern (ListenNummer,ArrayIndex:integer;
                                           SearchString:string; SearchPos:integer;var match:boolean);
var SeperatorPos:integer;
    CurrentSearch:string;
begin
  SeperatorPos:=posex(' ',SearchString,SearchPos);

  if (SeperatorPos>0) and (SeperatorPos<length(SearchString))
  then
    begin
     AND_Search_Item_intern(ListenNummer,ArrayIndex,SearchString,SearchPos+1,match);
    end;

  //Falls vorheriges UND-Element vorhanden ist
  if match
  then
   begin
    CurrentSearch:=copy(SearchString,SearchPos,SeperatorPos-SearchPos);

    if CurrentSearch<>''
    then
      if
      ( pos( ( CurrentSearch ) ,
       Mp3DatenMeta[ListenNummer].SuperSearchString.Strings[ArrayIndex] ) <>0 )
      then match:=true else match:=false;

  {
    if CurrentSearch<>''
    then
      if
       ( pos( ( CurrentSearch ) ,
         ansilowercase(  Mp3Daten[ListenNummer,ArrayIndex].id3tag.Titel ) ) <>0 )
      or
       ( pos( ( CurrentSearch ) ,
         ansilowercase(  Mp3Daten[ListenNummer,ArrayIndex].id3tag.Artist ) ) <>0 )
      or
      ( pos( ( CurrentSearch ) ,
         ansilowercase(  Mp3Daten[ListenNummer,ArrayIndex].Filename ) ) <>0 )
      or
       ( pos( ( CurrentSearch ) ,
         ansilowercase(  Mp3Daten[ListenNummer,ArrayIndex].Path ) ) <>0 )
      or
       ( pos( ( CurrentSearch ) ,
         ansilowercase(  Mp3Daten[ListenNummer,ArrayIndex].id3tag.Album) ) <>0 )
     or
       ( pos( ( CurrentSearch ) ,
         ansilowercase(  Mp3Daten[ListenNummer,ArrayIndex].id3tag.Genre) ) <>0 )
     or
       ( pos( ( CurrentSearch ) ,
         ansilowercase(  Mp3Daten[ListenNummer,ArrayIndex].id3tag.Comment) ) <>0 )
     or
       ( pos( ( CurrentSearch ) ,
         ansilowercase(  Mp3Daten[ListenNummer,ArrayIndex].id3tag.year) ) <>0 )

      then match:=true else match:=false;   }
  end;
end;


function TDatenbank.AND_Search_Item(ListenNummer,ElementNummer:integer;
                                    SearchString:string):boolean;
var  match : boolean;
begin
      //ElementNummer ist hier == ArrayIndex!
      //Leerzeichen um Ende zu markieren
      SearchString:=SearchString+' ';

      match:=true;

      if SearchString <> ' '
      then
      AND_Search_Item_intern(ListenNummer,ElementNummer,SearchString,1,match);

      Result:=Match;
end;



procedure TDatenbank.OR_Search(ListenNummer:integer; SearchString: string;
                                                   SearchPos:integer);
var CurrentSearch: string;
     SeparatorPos,i : integer;
begin
  //Suche Semikolon
  SeparatorPos:=posex(';',SearchString,SearchPos);

  if (SeparatorPos>0) and (SeparatorPos<length(SearchString))
  then
    begin
      OR_Search(ListenNummer,SearchString,SeparatorPos+1);
    end;

  CurrentSearch:=copy(SearchString,SearchPos,SeparatorPos-SearchPos);

  //Durchsuche jedes Element
  for i:=0 to High(Mp3Daten[ListenNummer]) do
  begin
    //Wenn schon gefunden von anderer OderSuche dann nicht nochmal
    if not (MP3Daten[ListenNummer,i].anzeige)
       and AND_Search_Item(ListenNummer,i,CurrentSearch)
    then MP3Daten[ListenNummer,i].anzeige:=true;
  end;
end;

procedure tdatenbank.Search(ListenNummer:integer; SearchString: string);

var i:integer;

begin
  Mp3DatenMeta[ListenNummer].SuchText:=SearchString;

  SearchString:= TrimSearchStringForSearch(SearchString);

  CreateSuperSearchString(ListenNummer);

  if SearchString=''
  then
    begin
      //Alles Anzeigen
      for i:=0 to High(Mp3Daten[ListenNummer]) do
        Mp3Daten[ListenNummer,i].anzeige:=true;
   end
  else
    begin
      //Nichts Anzeigen um in OderSuche die einzelnen Elemente aktivieren
      for i:=0 to High(Mp3Daten[ListenNummer]) do
        Mp3Daten[ListenNummer,i].anzeige:=false;

      //OderZeichen um Ende zu markieren
      SearchString:=SearchString+';';
      //OderSuche starten
      OR_Search(ListenNummer,SearchString,1);
    end;
end;

procedure TDatenbank.CreateSuperSearchString(ListenNummer:integer);
  var i:integer;
begin
  Mp3DatenMeta[ListenNummer].SuperSearchString.Clear;
  for i:=0 to High(Mp3Daten[ListenNummer]) do
    Mp3DatenMeta[ListenNummer].SuperSearchString.Add(
      ansilowercase(
        Mp3Daten[ListenNummer,i].id3tag.Titel+' '+
        Mp3Daten[ListenNummer,i].id3tag.Artist+' '+
        Mp3Daten[ListenNummer,i].Filename+' '     +
        Mp3Daten[ListenNummer,i].Path+' '         +
        Mp3Daten[ListenNummer,i].id3tag.Album+' ' +
        Mp3Daten[ListenNummer,i].id3tag.Genre+' '+
        Mp3Daten[ListenNummer,i].id3tag.Comment+' '+
        Mp3Daten[ListenNummer,i].id3tag.year));
  //Leerzeichen dazwischen um nicht in "ArmBein" "mB" zu finden
end;

procedure TDatenbank.LoadPlaylist(FileName:string; ListenNummer:integer);

 var Datei : TFileStream;
     Mp3DatenSaetze,DateiDatenVersion,i : integer;

  function LoadString :string;

  var StringLength : integer;

  begin
    Datei.Read( Stringlength, SizeOf(Stringlength) );
    SetLength( Result, stringlength );
    if (Stringlength > 0) then
      Datei.Read( Result[1], Stringlength );
  end;

begin
 if fileexists(FileName)
 then
  begin
   Datei:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyWrite);
   try
   Datei.Position:=0;
   Datei.Read(DateiDatenVersion , sizeof(integer) );

    if (DatenVersion=DateiDatenversion)
    then
      begin
        Mp3DatenMeta[ListenNummer].FileName:=FileName;

        with Mp3DatenMeta[ListenNummer] do
        begin
          Datei.Read(offen, SizeOf(offen));
          Datei.Read(AnzahlSuchpfade, SizeOf(integer));
          SetLength(Suchpfade,AnzahlSuchPfade);
          for i:=0 to AnzahlSuchpfade-1 do
            SuchPfade[i]:=LoadString;
          Datei.Read(maxNummer, SizeOf(integer));
          for i:=0 to 4 do
            Datei.Read(AnzeigeSpalten[i], SizeOf(integer));
          SuchText:=LoadString;
          for i:=0 to 99 do
            Datei.Read(history[i], SizeOf(integer));
          Datei.Read(historyPosition, SizeOf(integer));
          Datei.Read(mode, SizeOf(integer));
        end;

        Datei.Read( Mp3DatenSaetze , SizeOf(integer) );
        SetLength(Mp3Daten[ListenNummer],Mp3DatenSaetze);

        for i:=0 to Mp3DatenSaetze-1 do
        begin
          with Mp3Daten[ListenNummer,i].id3tag do
          begin
            Titel  :=LoadString;
            Artist :=LoadString;
            Album  :=LoadString;
            Year   :=LoadString;
            Comment:=LoadString;
            Genre  :=LoadString;
            Datei.Read(dauer, SizeOf(integer));
            Datei.Read(Track, SizeOf(integer));
            Datei.Read(ausgelesen, SizeOf(ausgelesen));
          end;
          with Mp3Daten[ListenNummer,i] do
          begin
            Datei.Read(Nummer, SizeOf(Nummer));
            Filename:=LoadString;
            Path    :=LoadString;
            Datei.Read(Size, SizeOf(integer));
            Datei.Read(Anzeige, SizeOf(Anzeige));
            Dauer   :=LoadString;
            Datei.Read(Spielcounter, SizeOf(integer));
            Datei.Read(Defekt, SizeOf(Defekt));
          end;
        end;

       Datei.Free;
      end
    else
     begin
      MessageDlg(Format(PLSNOTCOMP, [FileName]),mtWarning,[mbOk],0);
      Datei.Free;
      exit;
     end
   except
      MessageDlg(Format(PLSNOTLOAD, [FileName]),mtWarning,[mbOk],0);
      Datei.Free;
      exit;
   end;
  end
 else
  begin
   MessageDlg(Format(PLSNOTFOUND, [FileName]),mtWarning,[mbOk],0);
   exit;
  end;
end;


procedure TDatenbank.SavePlaylist(FileName:string; ListenNummer:integer);

var Datei    : TFileStream;
    Mp3DatenSaetze,i : integer;


  procedure SaveString( Datei:TFileStream; SString:string);
  var StringLength : integer;
  begin
    stringlength := Length( SString );
    datei.Write( stringlength, SizeOf(stringlength) );
    if (stringlength > 0) then
      datei.Write( SString[1], stringlength );
  end;



begin
  Mp3DatenMeta[ListenNummer].FileName:=FileName;

  Datei:=TFileStream.Create(FileName,fmCreate);

  try
  Datei.Position:=0;

{    Version 8.0    }
  Datei.Write( DatenVersion , SizeOf(integer) );

{ Speichere MP3DatenMeta

type TMp3ListeMeta = record
        offen           : boolean;
        FileName        : string;
        AnzahlSuchpfade : integer;
        SuchPfade       : array of string;
        maxNummer       : integer;
        AnzeigeSpalten  : array [0..4] of byte;
        SuchText        : string;
        history         : array [0..99] of integer;
        historyPosition : integer;
        mode            : byte;
}
  with Mp3DatenMeta[ListenNummer] do
  begin
    Datei.Write(offen, SizeOf(offen));

    Datei.Write(AnzahlSuchpfade, SizeOf(integer));
    for i:=0 to AnzahlSuchpfade-1 do
      SaveString(Datei,(SuchPfade[i]));
    Datei.Write(maxNummer, SizeOf(integer));
    for i:=0 to 4 do
      Datei.Write(AnzeigeSpalten[i], SizeOf(integer));
    SaveString(Datei,(SuchText));
    for i:=0 to 99 do
      Datei.Write(history[i], SizeOf(integer));
    Datei.Write(historyPosition, SizeOf(integer));
    Datei.Write(mode, SizeOf(integer));
  end;

{ Speichere MP3Daten
type
  TID3Tag = record
    Titel   : string;
    Artist  : string;
    Album   : string;
    Year    : string;
    Comment : string;
    Genre   : string;
    dauer   : integer;
    Track   : integer;
    ausgelesen: boolean;
  end;

type TMp3Eintrag = record
      Nummer    : integer;
      Filename  : string;
      Path      : string;
      Size      : integer;
      Anzeige   : boolean;
      Dauer     : string;
      Spielcounter : integer;
      Defekt    : boolean;
      Id3tag    : Tid3tag;
  end;
}
  Mp3DatenSaetze:=High(Mp3Daten[ListenNummer])+1;
  Datei.Write( Mp3DatenSaetze , SizeOf(integer) );

  for i:=0 to Mp3DatenSaetze-1 do
  begin
    with Mp3Daten[ListenNummer,i].id3tag do
    begin
      SaveString(Datei,(Titel));
      SaveString(Datei,(Artist));
      SaveString(Datei,(Album));
      SaveString(Datei,(Year));
      SaveString(Datei,(Comment));
      SaveString(Datei,(Genre));
      Datei.Write(dauer,sizeof(integer));
      Datei.Write(Track, SizeOf(integer));
      Datei.Write(ausgelesen, SizeOf(ausgelesen));
    end;
    with Mp3Daten[ListenNummer,i] do
    begin
      Datei.Write(Nummer, SizeOf(Nummer));
      SaveString(Datei,(Filename));
      SaveString(Datei,(Path));
      Datei.Write(Size, SizeOf(integer));
      Datei.Write(Anzeige, SizeOf(Anzeige));
      SaveString(Datei,(Dauer));
      Datei.Write(Spielcounter, SizeOf(integer));
      Datei.Write(Defekt, SizeOf(Defekt));
    end;
  end;

  Datei.Free;
  except
   MessageDlg(Format(PLSNOTSAVED, [FileName]), mtwarning, [mbok],0);
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
  if (ListenNummer>=0) and (ListenNummer<=High(Mp3Daten))
  then Result:=(MP3DatenMeta[ListenNummer].offen)
  else Result:=false;
end;


function TDatenbank.GetMediumId3Tag (ListenNummer,ElementNummer : integer)
                                                                      :Tid3tag;
var
  ArrayIndex: integer;
begin
  if (ListeExists(ListenNummer)) and
     (EintragExists(ListenNummer, ElementNummer, ArrayIndex))
  then
    Result:=Mp3Daten[ ListenNummer, ArrayIndex ].id3tag
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
var i,k      : integer;
    FileExt, FileName: string;
    Stream : TFilestream;
begin
  Result:=false;

  i:=ElementNummerZuArrayIndex(ListenNummer,ElementNummer);

  FileExt:=ansilowercase(extractfileext(Mp3Daten[ListenNummer,i].filename));
  FileName:=Mp3Daten[ListenNummer,i].path+Mp3Daten[ListenNummer,i].filename;

  //Initialiserung um evtl. GetDauer zu verhindern
  Mp3Daten[ListenNummer,i].id3tag.dauer:=0;

  try

  if FileExt='.mp3'
  then
    begin
      stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);

      // ID3v2-Tag auslesen
      Id3v2.ReadFromStream(stream);

      // Position neu setzen
      if Not Id3v2.exists then
        stream.Seek(0, sobeginning)
      else
        stream.Seek(Id3v2.size, soFromBeginning);

      // MPEG-Informationen lesen
      MpegInfo.LoadFromStream(Stream);

      Mp3Daten[ListenNummer,i].id3tag.dauer:=mpeginfo.dauer;

      if id3v2.Exists
      then
       begin
          Result:=true;
          with Mp3Daten[ListenNummer,i] do
            begin
              id3tag.Titel  := id3v2.Title;
              id3tag.Artist := id3v2.Artist;
              id3tag.Album  := id3v2.Album;

              //id3tag.Year   := id3v2.Year;
              //fix weil manche id3v2 2.3 utf years '2005//2005' enthalten
              id3tag.year:='';
              for k:=1 to length (id3v2.Year) do
              if CharInSet(id3v2.year[k],['0','1','2','3','4','5','6','7','8','9'])
               then id3tag.year:=id3tag.year+id3v2.year[k]
               else break;

              id3tag.Comment:= id3v2.Comment;
              id3tag.Genre  := id3v2.Genre;
              if not trystrtoint(id3v2.Track,id3tag.Track)
              then id3tag.Track:=0;
              id3tag.ausgelesen:=true;
            end;
       end
      else
      begin
        // ID3v1-Tag auslesen
        Id3v1.ReadFromStream(stream);
        if id3v1.TagExists
        then
         begin
          Result:=true;
          with Mp3Daten[ListenNummer,i] do
            begin
              id3tag.Titel  := id3v1.Title;
              id3tag.Artist := id3v1.Artist;
              id3tag.Album  := id3v1.Album;
              id3tag.Year   := id3v1.Year;
              id3tag.Comment:= id3v1.Comment;
              if not trystrtoint(id3v1.Track,id3tag.Track)
              then id3tag.Track:=0;
              id3tag.Genre  := id3v1.Genre;
              id3tag.ausgelesen:=true;
            end;
         end;
       end;
       //Stream auflösen
       stream.Free;
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
            id3tag.Track  := oggtag.Track;
            id3tag.ausgelesen:=true;
          end;
        end;
    end;

  if FileExt='.wma'
  then
    begin
      if wmatag.ReadFromFile(Mp3Daten[ListenNummer,i].path+
                                            Mp3Daten[ListenNummer,i].filename)
      then
        begin
        Result:=true;
        with Mp3Daten[ListenNummer,i] do
          begin
            id3tag.Titel  := wmatag.Title;
            id3tag.Artist := wmatag.Artist;
            id3tag.Album  := wmatag.Album;
            id3tag.Year   := wmatag.Year;
            id3tag.Comment:= wmatag.Comment;
            id3tag.Genre  := wmatag.genre;
            id3tag.Track  := wmatag.Track;
            id3tag.ausgelesen:=true;
          end;
        end;
    end;

  if Mp3Daten[ListenNummer,i].id3tag.dauer=0
  then
    begin
    Mp3Daten[ListenNummer,i].id3tag.dauer:=
      fmp3.Spieler.GetDauer(Mp3Daten[ListenNummer,i].path+
                                            Mp3Daten[ListenNummer,i].filename);
    end;

  Mp3Daten[ListenNummer,i].dauer:=
                      fmp3.DauerZuString(Mp3Daten[ListenNummer,i].id3tag.dauer);

  except
    fmp3.Fehler('Ein schwerwiegender Fehler ist beim Lesen der Metainformationen aufgetreten.'+#13+
                'Fehlerhafte, standardinkombatible Datei: '+FileName);
  end;
end;


procedure TDatenbank.MoveItem(ListenNummer,SourceElementNummer,TargetElementNummer
                              :integer);
var
    SourceIndex,TargetIndex,i : integer;
    Item : TMp3Eintrag;
begin
  if (GetArrayIndex(ListenNummer,SourceElementNummer,SourceIndex)) and
     (GetArrayIndex(ListenNummer,TargetElementNummer,TargetIndex)) then
    begin
      if SourceIndex<TargetIndex then
        begin
          Item:=MP3Daten[ListenNummer,SourceIndex];
          for i:=SourceIndex to TargetIndex-1 do
            Mp3Daten[ListenNummer,i]:=Mp3Daten[ListenNummer,i+1];
          MP3Daten[ListenNummer,TargetIndex]:=item;
        end;
      if SourceIndex>TargetIndex then
        begin

          Item:=MP3Daten[ListenNummer,SourceIndex];

          for i:=SourceIndex downto TargetIndex+1 do
            Mp3Daten[ListenNummer,i]:=Mp3Daten[ListenNummer,i-1];

          MP3Daten[ListenNummer,TargetIndex]:=item;
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


function TDatenbank.GetArrayIndex(ListenNummer,
                         ElementNummer:integer; var ArrayIndex:integer):boolean;
var i : integer;
begin
  Result:=false;
  ArrayIndex:=0;
  if ListeExists(ListenNummer)
  then
   begin
    for i:=0 to High(Mp3Daten[ ListenNummer ]) do
     begin
       if Mp3Daten[ ListenNummer, i ].Nummer = ElementNummer
         then
          begin
            ArrayIndex:=i;
            Result := true;
            break;
          end;
      end;
    end;
end;


function TDatenbank.GetSearchDir(ListenNummer:integer; var DirList:TStringlist)
          :boolean;
  var i:integer;
begin
  Result:=false;

  if ListeExists(ListenNummer) then
  begin
    with Mp3DatenMeta[ListenNummer] do
    if AnzahlSuchpfade>0 then
    begin
      for i:=0 to AnzahlSuchpfade-1 do
      begin
        DirList.Add(Suchpfade[i]);
      end;
      Result:=true;
    end;
  end;
end;


procedure TDatenbank.RescanFolders(ListenNummer:integer);
var i:integer;
    DirList:TStringlist;

begin
 fmp3.UpdateTextFStatus('Überprüfe auf verwaiste Einträge...');

 VerwaisteEintraegeloeschen(ListenNummer);

 DirList:=TStringList.Create;
 if GetSearchDir(ListenNummer,DirList)
 then
   for i:=0 to DirList.Count-1 do
     begin
       OrdnerAnListeAnhaengen(DirList[i],ListenNummer);
     end;

 fmp3.UpdateTextFStatus('Verifiziere die Ergebnisse...');
 DeleteInvalidItems(ListenNummer);
end;


procedure TDatenbank.DeleteInvalidItems(ListenNummer:integer);
var i:integer;
begin
  if ListeExists(ListenNummer) then
  begin

    for i:=High(Mp3Daten[ListenNummer]) downto 0 do
    begin
      if Mp3Daten[ListenNummer,i].FileName=''
      then DeleteItem(ListenNummer,i,true);
    end;

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
   if (fmp3.Spieler.ZustaendigerRenderKern(ExtractFileExt(FileName))=Mp3DatenMeta[ListenNummer].mode)
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

      LeseId3(ListenNummer,Mp3daten[ListenNummer,High(Mp3daten[ListenNummer])].Nummer);
    end;
 end;
end;

procedure TDatenbank.CopyItem(QuellListenNummer,QuellElementNummer,ZielListenNummer:integer);
var ArrayIndex : integer;
begin
  if (ListeExists(QuellListenNummer)) and (ListeExists(ZielListenNummer)) then
  begin
    ArrayIndex:=ElementNummerZuArrayIndex(QuellListenNummer,QuellElementNummer);
    AddItem(ZielListenNummer,Mp3Daten[QuellListenNummer,ArrayIndex],true,true);
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
  FileList.Clear;
  if ListeExists(ListenNummer) then
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


procedure TDatenbank.IncPlayCounter(ListenNummer, ElementNummer: integer);
begin
  if ListeExists(ListenNummer) then
  begin
    inc(MP3Daten[ListenNummer,ElementNummerZuArrayIndex(ListenNummer,ElementNummer)].spielcounter)
  end;
end;


procedure  TDatenbank.SaveId3(Title,Artist,Album,Year,Comment,Genere,Track:string;
                         SaveTitle,SaveArtist,SaveAlbum,SaveYear,SaveComment,
                         SaveGenre,SaveTrack:boolean;
                         ListenNummer,ElementNummer:integer );
var FileExt,FileName: string;
    ArrayIndex,TrackNr:integer;
begin
  if EintragExists(ListenNummer,ElementNummer,ArrayIndex)
  then
  begin
    //Hier könnte man auch den schon oben ermittelten ArrayIndex nutzen
  GetMediumFullFileName(ListenNummer,ElementNummer,FileName);

  FileExt:=AnsiLowerCase(ExtractFileExt(FileName));
  if not TryStrToInt(Track,TrackNr) then TrackNr:=0;

  if FileExt='.mp3'
    then
     begin
       id3v2.ReadFromFile(FileName);

       if SaveTitle   then id3v2.Title := Title;
       if SaveArtist  then id3v2.Artist:= Artist;
       if SaveAlbum   then id3v2.Album := Album;
       if SaveYear    then id3v2.Year  := Year;
       if SaveComment then id3v2.Comment := Comment;
       if SaveGenre   then id3v2.Genre := Genere;
       if SaveTrack   then id3v2.Track := inttostr(TrackNr);

       id3v2.WriteToFile(FileName);


       id3v1.ReadFromFile(FileName);

       if SaveTitle   then id3v1.Title := Title;
       if SaveArtist  then id3v1.Artist:= Artist;
       if SaveAlbum   then id3v1.Album := Album;
       if SaveYear    then id3v1.Year  := Year;
       if SaveComment then id3v1.Comment := Comment;
       if SaveTrack   then id3v1.Track := inttostr(TrackNr);

       id3v1.WriteToFile(FileName);

       LeseId3(ListenNummer,ElementNummer);
     end
    else
     if FileExt='.ogg'
      then
        begin
         oggtag.ReadFromFile(FileName);

         if SaveTitle   then oggtag.Title := Title;
         if SaveArtist  then oggtag.Artist:= Artist;
         if SaveAlbum   then oggtag.Album := Album;
         if SaveYear    then oggtag.Date  := Year;
         if SaveComment then oggtag.Comment := Comment;
         if SaveGenre   then oggtag.Genre := Genere;
         if SaveTrack   then oggtag.Track := TrackNr;

         oggtag.SaveTag(FileName);

         LeseId3(ListenNummer,ElementNummer);
        end;              
  end;
end;


procedure TDatenbank.SetPlaylistMode(ListenNummer,Mode:integer);
begin
    //  0  = MP3s usw.
    //  2  = Applauncher

   if ListeExists(ListenNummer) then
   begin
      Mp3DatenMeta[ListenNummer].mode:=Mode;
   end;
end;


procedure TDatenbank.RedundanteItemsAussortieren(ListenNummer:integer);
var i,k:integer;
begin
   Sort(ListenNummer,20);

   for i:=High(Mp3Daten[ListenNummer]) downto 1 do
   begin
      if   (Mp3Daten[ListenNummer,i].path=Mp3Daten[ListenNummer,i-1].path)
       and (Mp3Daten[ListenNummer,i].filename=Mp3Daten[ListenNummer,i-1].filename)

      then
       begin
        for k:=i to High(Mp3Daten[ListenNummer])-1 do
         Mp3Daten[ListenNummer,k]:=Mp3Daten[ListenNummer,k+1];
        SetLength(Mp3Daten[ListenNummer],High(Mp3Daten[ListenNummer]));
       end;
   end;
end;


procedure TDatenbank.GetFavoritItems(ListenNummer,MaxAnzahl: integer;
                                      var Name,Nummer,Anzahl:TStringlist);
var i: integer;
    max,CurrentAnzahl: integer;
begin
  if ListeExists(ListenNummer) then
  begin

    //Max ermitteln
    max:=0;
    for i:=0 to High(Mp3Daten[ListenNummer]) do
    begin
      if Mp3Daten[ListenNummer,i].spielcounter>max
      then max:=Mp3Daten[ListenNummer,i].spielcounter;
    end;
    //
    CurrentAnzahl:=0;
    if High(Mp3Daten[ListenNummer])<MaxAnzahl
    then MaxAnzahl:=High(Mp3Daten[ListenNummer]);

    while (CurrentAnzahl<MaxAnzahl) and (max>0) do
    begin

     //Items=max hinzufügen
      for i:=0 to High(Mp3Daten[ListenNummer]) do
      begin
        if (Mp3Daten[ListenNummer,i].spielcounter=max)
        then
          if (CurrentAnzahl<MaxAnzahl)
          then
            begin
              Name.Add(GetEintragfuerSpalte(0,ListenNummer,i));
              Nummer.Add(inttostr(Mp3Daten[ListenNummer,i].Nummer));
              Anzahl.Add(inttostr(max));

              inc(CurrentAnzahl);
            end
          else
            break;
      end;
     //
      dec(max);

    end;

  end;
end;


function TDatenbank.DeleteDirAndItsItems(Dir:string; ListenNummer:integer):boolean;
var i:integer;
begin
  if DeleteFileToRecycleBin(Dir) then
  begin
     for i:=High(Mp3Daten[ListenNummer]) downto 0 do
     begin
       if pos(dir,Mp3Daten[ListenNummer,i].Path)>0
       then
         begin
           DeleteItem(ListenNummer,Mp3Daten[ListenNummer,i].Nummer);
         end;
     end;
    result := true
  end
  else
  begin
    fmp3.Fehler('Das Verzeichnis "'+ Dir +'" konnte nicht gelöscht werden');
    result := false
  end
end;


function TDatenbank.GetPlayLengthOfAllFiles(ListenNummer:integer):int64;
var i:integer;
begin
  Result:=0;
  if ListeExists(ListenNummer) then
    begin
      for i:=0 to High(Mp3Daten[ListenNummer]) do
        if Mp3Daten[ListenNummer,i].anzeige then
        Result:=Result+Mp3Daten[ListenNummer,i].id3tag.dauer;
    end;
end;

//Diese Prozedur ist nicht für öffentliche Zwecke bestimmt
//Ich brauchte sie nur für einen Sonderfall meiner MP3-Sammlung
//(um die Ordner zu finden, die nur wenige Dateien enthalten,
// da der MagicMP3Tagger zahlreiche Ordner erstellt hat, die nur 1-2 MP3s
// enthalten)
procedure TDatenbank.CopyAllFilesToANewListSortedbyNummberOfFilesofFolder;

const MAX_ANZAHL_ELEMENTE = 3;

var ListenNummer,newList,i,k,m,counter,maxcounter:integer;
    currentsearchpath : string;

    items : array [1..MAX_ANZAHL_ELEMENTE] of integer;

begin
  ListenNummer:=fmp3.aktiv.liste;
  fmp3.ErzeugeNeuePlayliste;
  newList:=high(mp3datenmeta);

  for maxcounter:=1 to MAX_ANZAHL_ELEMENTE do
  begin

    for k:=0 to high(mp3daten[ListenNummer]) do
    begin
      counter:=0;

      //Hauptpfad wegschneiden
      currentsearchpath:=copy(mp3daten[ListenNummer,k].path,
                         length(mp3datenmeta[listennummer].suchpfade[0])+1,500);
      //Alles nach nächstem Semikolon wegschneiden
      currentsearchpath:=copy(currentsearchpath,1,posex('\',currentsearchpath,2));

      //Hauptpfad wieder dran setzen
      currentsearchpath:=mp3datenmeta[listennummer].suchpfade[0]+currentsearchpath;


        for i:=0 to high(mp3daten[ListenNummer]) do
        begin
          if pos(currentsearchpath,mp3daten[ListenNummer,i].path)<>0 then
          begin
            inc(counter);
            if counter<=MAX_ANZAHL_ELEMENTE
            then items[counter]:=i
            else break;
          end;

        end;

      if counter=maxcounter then
        for m:=1 to counter do
        additem(newlist,mp3daten[listennummer,items[m]],true,true);

    end;


  end;

  fmp3.DatenbankListeAusgeben(newlist);
end;
//

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


function TDatenbank.DeleteFileToRecycleBin(const AFile: string): boolean;
var
  Operation: TSHFileOpStruct;
begin
  with Operation do
  begin
    Wnd := fmp3.Handle;//Application.Handle
    wFunc := FO_DELETE;
    pFrom := PChar(AFile +#0);
    pTo := Nil;
    { in den Papierkorb verschieben / keine
      Sicherheitsabfrage }
    fFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION;
  end;
  Result := SHFileOperation(Operation) = 0;
end;


procedure TDatenbank.VerifyHistory(ListenNummer: integer);
var
  i, j, ArrayIndex: integer;
begin
  if ListeExists(ListenNummer) then
    with Mp3DatenMeta[ListenNummer] do
    begin
      for i := 0 to High(History) do
      begin
        if not EintragExists(ListenNummer, History[i], ArrayIndex) then
        begin
          for j := i to High(History) - 1 do
          begin
            History[j] := History[j + 1];
          end;
          History[High(History)] := 0;
          if Mp3DatenMeta[ListenNummer].historyposition > i then
          begin
            dec(Mp3DatenMeta[ListenNummer].historyposition);
          end;
        end;
      end;
    end;
end;

end.
