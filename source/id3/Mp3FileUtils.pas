{
  MP3FileUtils 0.1

  //Orginaldatei geändert -> UTF-16 Fix

  Die hier implementierten Klassen ermöglichen es, diverse
  Informationen aus mp3 Dateien auszulesen und zu schreiben.

  Copyright (C) 2005, Daniel 'Gausi' Gaussmann
  Fragen hierzu an Gausi@delphi-forum.de

  Diese Unit basiert zum Teil auf "UltimaTag"
  Copyright (C) 2003 by tommie-lie, tommie-lie@delphi-forum.de
  http://www.delphi-forum.de/viewtopic.php?t=11032
    - Die Klasse TID3v1Tag wurde fast unverändert aus UT übernommen,
      ebenso einige Hilfsprozeduren
    - Die Klasse TID3v2Tag verwendet diverse Techniken aus UT,
      die Datenstruktur jedoch wurde komplett verändert, da die Klasse hier
      wesentlich variabler ist und nicht nur Textframes unterstützt.
    - Eine Klasse TMpegInfo ist in UT nicht enthalten gewesen.

  Diese Unit ist freie Software; sie darf weiterverbreitet und/oder
  modifiziert werden unter den Bedingungen der GNU Lesser Public License,
  veröffentlicht von der Free Software Foundation; entweder Version 2.1 der
  Lizenz, oder eine spätere Version.

  Sie sollten ein Kopie dieser Lizenz mit dieser Unit erhalten haben.
  Wenn nicht, schreiben sie an
      Free Software Foundation, Inc.,
      59 Temple Place, Suite 330,
      Boston, MA 02111-1307 USA


  Folgende Klassen werden zur Verfügung gestellt:
      - TID3v1Tag:
        Lesen und Schreiben des ID3v1-Tags.
        Alle Informationen werden ausgewertet.
        Die Version v1.1 wird erkannt.

      - TID3v2Tag:
        Lesen und schreiben von ID3v2-Tags.
        Es werden die Versionen 2.2, 2.3 und 2.4 unterstützt.
        Zusätzlich zu den in v1 enthaltenen Feldern wird außerdem unterstützt:
            Composer
            OriginalArtist
            Copyright
            EncodedBy
            Languages
            SoftwareSettings
            Mediatype
            Length
            Publisher
            OriginalFilename
            OriginalLyricist
            OriginalReleaseYear
            OriginalAlbumTitel
        Als Besonderheit werden hier auch unterstützt:
            Lyrics
            Pictures
        Die Behandlung dieser Eigenschaften ist nicht trivial und fordert
        etwas mehr Einarbeitung in diese Unit.
        Außerdem ist die Behandlung von Pictures noch nicht "idiotensicher".
        Es werden können beliebige Binärdaten geschrieben werden, laut Spezifikationen
        von id3v2Tag und den Zusatzinfos, die dort geschrieben werden, dürfen mit dieser
        Unit dort NUR JPEGs als Bild verwendet werden. Bei der Verwendung dieser Unit ist also
        sicherzustellen, dass der User nur JPGs zum Einfügen in den Tag auswählen darf.

      - TMpegInfo
        Lesen der MPEG-Informationen
            filesize
            version
            layer
            protection
            bitrate
            samplerate
            channelmode
            extension
            copyright
            original
            emphasis
            frames
            dauer
            vbr
            firstHeaderPosition
}

unit Mp3FileUtils;

interface

uses
  SysUtils, Classes, Windows;

type

//--------------------------------------------------------------------
// Teil 1: Allgemeine Hilfstypen
//--------------------------------------------------------------------
  TBuffer = Array of byte;
   // Error reporting values
  TMP3Error = (MP3ERR_None, MP3ERR_NoFile, MP3ERR_FOpenCrt, MP3ERR_FOpenR,
               MP3ERR_FOpenRW, MP3ERR_FOpenW, MP3ERR_SRead, MP3ERR_SWrite,
               ID3ERR_Mem_Alloc, ID3ERR_Cache, ID3ERR_NoTag,
               ID3ERR_Invalid_Header, ID3ERR_Unclassified,
               MPEGERR_NoFrame );
  TID3Version = record                  // The version format for ID3v2
    Major: Byte;
    Minor: Byte;
  end;
//--------------------------------------------------------------------



//--------------------------------------------------------------------
// Teil 2: Typen für ID3v1Tag
//--------------------------------------------------------------------
  String4  = String[4];                 // Strings are either 4 or 30 byte
  String30 = String[30];

  TID3v1Tag = class(TObject)            // Class that holds the features
  private                               // of ID3v1
    FTitle: String30;
    FArtist: String30;
    FAlbum: String30;
    FComment: String30;
    FTrack: Byte;
    FYear: String4;
    FGenre: Byte;
    FExists: Boolean;
    FVersion: Byte;
    // property read functions
    function GetGenre: String;
    function GetTrack: String;
    // property set procedures
    procedure SetTitle(Value: String30);
    procedure SetArtist(Value: String30);
    procedure SetAlbum(Value: String30);
    procedure SetGenre(Value: String);
    procedure SetYear(Value: String4);
    procedure SetComment(Value: String30);
    procedure SetTrack(Value: String);
  public
    constructor Create;
    property TagExists: Boolean read FExists;
    property Version: Byte read FVersion;
    property Title: String30 read FTitle write SetTitle;
    property Artist: String30 read FArtist write SetArtist;
    property Album: String30 read FAlbum write SetAlbum;
    property Genre: String read GetGenre write SetGenre;
    property Track: String read GetTrack write SetTrack;
    property Year: String4 read FYear write SetYear;
    property Comment: String30 read FComment write SetComment;
    procedure Clear;
    function ReadFromStream(Stream: TStream): TMP3Error;
    function WriteToStream(Stream: TStream): TMP3Error;
    function RemoveFromStream(Stream: TStream): TMP3Error;
    function ReadFromFile(Filename: String): TMP3Error;
    function WriteToFile(Filename: String): TMP3Error;
    function RemoveFromFile(Filename: String): TMP3Error;
  end;
//--------------------------------------------------------------------



//--------------------------------------------------------------------
// Teil 3: Typen für ID3v2-tags
//--------------------------------------------------------------------
  TInt28 = array[0..3] of Byte;         // 28bit integer used in ID3v2

  // einige Frames können mehrfach auftreten, und können dann durch ihre
  // Beschreibung unteschieden werden. Dabei gibt es für verschiedene Frametypen
  // unterschiedliche Beschreibungen:

  // Beschreibung für z.B. Comment- und Lyric-Frames
  TFrameDescription = record
    Language: String;
    Description: String;
  end;
  // Beschreibung für Bild-Frames
  TPictureFrameDesription = record
    Description: String;
    Bildtyp: Byte;
  end;

  TFrameDescriptionArray = Array of TFrameDescription;
  TPictureFrameDescriptionArray = Array of TPictureFrameDesription;

  // Version 2 des V2-tags hatte einen 3-Byte-Frame-Identifier
  // Version 3+4 einen 4-Byte-Frame-identifier
  TID3v24ID = array[0..3] of char;
  TID3v23ID = array[0..3] of char;
  TID3v22ID = array[0..2] of char;

  TID3v2Frame = record
    FFrameID: String;    // 4 bzw. 3 Zeichen lang
    FSize: LongWord;
    Header: TBuffer;     // 10 bzw. 6 Bytes groß
    Data: TBuffer;
  end;

  TID3v2Header = record                // constant structure of an
    ID: array[1..3] of Char;           // ID3v2 header in the file
    Version: Byte;
    Revision: Byte;
    Flags: Byte;
    TagSize: TInt28;
  end;

  TID3v2Tag = class(TObject)            // Class that holds the implemented
  private                               // features of ID3v2
    FExists: Boolean;
    FVersion: TID3Version;
    FFlgUnsynch: Boolean;
    FFlgExtended: Boolean;
    FFlgExperimental: Boolean;
    FFlgFooterPresent: Boolean;
    FPadding: LongWord;
    FTagSize: LongWord;
    FDataSize: LongWord;
    FUsePadding: Boolean;
    FUseExtended: Boolean;
    FFrames: array of TID3v2Frame;

    function GetFrameIDString(ID:integer):string;

    function GetFrameIndex(ID:integer):integer; Overload;
    function GetFrameIndex(ID:integer;Language:string;Description:string):integer; Overload;
    function GetFrameIndex(Description:TPictureFrameDesription):integer; Overload;

    function GetDescription(aFrame:TID3v2Frame):string;
    function GetPictureDescription(aFrame:TID3v2Frame; StartPosition:integer):TPictureFrameDesription;
    function GetMimeType(aFrame:TID3v2Frame):string;

    function GetTextFrame(FrameID: integer):String;
    function GetDescribedTextFrame(ID:integer;Language:string;Description:string):string;
    procedure SetTextFrame(FrameID:integer; Value: String);
    procedure SetDescribedTextFrame(ID:integer;Language:string;Description:string; Value:string);
    // DeleteTextFrame wird intern von SetTextFrame aufgerufen, wenn der übergebene
    // String leer ist - und somit von allen Set-Prozeduren, die reine Textframes setzen
    procedure DeleteTextFrame(FrameID: integer);
    // DeleteDescribedTextFrame wird außerdem von DeleteLyrics und DeleteExtendedComment aufgerufen.
    procedure DeleteDescribedTextFrame(ID:integer;Language:string;Description:string);

    function GetAllFrameDescriptions(FrameID:integer): TFrameDescriptionArray;
    function ReadFrames(From: LongInt; Stream: TStream): TMP3Error;
    function ReadHeader(Stream: TStream; Complete: Boolean): TMP3Error;

    // property read functions
    function GetTitle: String;
    function GetArtist: String;
    function GetAlbum: String;
    function ParseID3v2Genre(value:string):string;
    function GetGenre: String;
    function GetTrack: String;
    function GetYear: String;
    function GetStandardComment: String;
    function GetComposer: String;
    function GetOriginalArtist: String;
    function GetCopyright: String;
    function GetEncodedBy: String;
    function GetLanguages: String;
    function GetSoftwareSettings: String;
    function GetMediatype: String;
    function Getid3Length: String;
    function GetPublisher: String;
    function GetOriginalFilename: String;
    function GetOriginalLyricist: String;
    function GetOriginalReleaseYear: String;
    function GetOriginalAlbumTitel: String;

    //property set functions
    procedure SetTitle(Value: String);
    procedure SetArtist(Value: String);
    procedure SetAlbum(Value: String);
    function BuildID3v2Genre(value:string):string;
    procedure SetGenre(Value: String);
    procedure SetTrack(Value: String);
    procedure SetYear(Value: String);
    procedure SetStandardComment(Value: String);
    procedure SetComposer(Value: String);
    procedure SetOriginalArtist(Value: String);
    procedure SetCopyright(Value: String);
    procedure SetEncodedBy(Value: String);
    procedure SetLanguages(Value: String);
    procedure SetSoftwareSettings(Value: String);
    procedure SetMediatype(Value: String);
    procedure Setid3Length(Value: String);
    procedure SetPublisher(Value: String);
    procedure SetOriginalFilename(Value: String);
    procedure SetOriginalLyricist(Value: String);
    procedure SetOriginalReleaseYear(Value: String);
    procedure SetOriginalAlbumTitel(Value: String);

  public
    constructor Create;
    property Title:   String read GetTitle  write SetTitle;
    property Artist:  String read GetArtist write SetArtist;
    property Album:   String read GetAlbum  write SetAlbum;
    property Genre:   String read GetGenre  write SetGenre;
    property Track:   String read GetTrack  write SetTrack;
    property Year:    String read GetYear   write SetYear;
    property Comment: String read GetStandardComment write SetStandardComment;

    property Composer:         String read  GetComposer           write  SetComposer        ;
    property OriginalArtist:   String read  GetOriginalArtist     write  SetOriginalArtist  ;
    property Copyright:        String read  GetCopyright          write  SetCopyright       ;
    property EncodedBy:        String read  GetEncodedBy          write  SetEncodedBy       ;
    property Languages:        String read  GetLanguages          write  SetLanguages       ;
    property SoftwareSettings: String read  GetSoftwareSettings   write  SetSoftwareSettings;
    property Mediatype:        String read  GetMediatype          write  SetMediatype       ;
    property id3Length:           String read  Getid3Length           write Setid3Length          ;
    property Publisher:           String read  GetPublisher           write SetPublisher          ;
    property OriginalFilename:    String read  GetOriginalFilename    write SetOriginalFilename   ;
    property OriginalLyricist:    String read  GetOriginalLyricist    write SetOriginalLyricist   ;
    property OriginalReleaseYear: String read  GetOriginalReleaseYear write SetOriginalReleaseYear;
    property OriginalAlbumTitel:  String read  GetOriginalAlbumTitel  write SetOriginalAlbumTitel ;

    property size:       LongWord    read FTagSize;
    property exists:     Boolean     read FExists;
    property Padding:    Longword    read FPadding;
    property Version:    TID3Version read FVersion;
    property UsePadding: Boolean     read FUsePadding write FUsePadding;

    function ReadFromStream(Stream: TStream): TMP3Error;
    function WriteToStream(Stream: TStream): TMP3Error;
    function RemoveFromStream(Stream: TStream): TMP3Error;
    function ReadFromFile(Filename: String): TMP3Error;
    function WriteToFile(Filename: String): TMP3Error;
    function RemoveFromFile(Filename: String): TMP3Error;

    // Erweiterte Frames: Comments mit Description, Lyrics, Pictures
    procedure SetExtendedComment(Language:string;Description:string; value:string);
    function GetExtendedComment(Language:string;Description:string): string;
    procedure DeleteExtendedComment(Language:string;Description:string);
    procedure SetLyrics(Language:string;Description:string; value:string);
    function GetLyrics(Language:string;Description:string): string;
    procedure DeleteLyrics(Language:string;Description:string);

    // Ein Bild aus dem ID3Tag lesen und in den Stream schreiben
    procedure GetPicture(stream: TStream; Description:TPictureFrameDesription);
    // Das Bild aus dem Stream in den ID3Tag schreiben
    procedure SetPicture(stream: TStream; Description:TPictureFrameDesription);
    procedure DeletePicture(Description:TPictureFrameDesription);

    //für diverse Anzeigen, z.B. um Auswahl der MehrfachFrames zu realisieren
    function GetAllCommentDescriptions: TFrameDescriptionArray;
    function GetAllLyricsDescriptions: TFrameDescriptionArray;
    function GetAllPictureFrameDescriptions: TPictureFrameDescriptionArray;
    procedure Clear;
  end;
//--------------------------------------------------------------------


//--------------------------------------------------------------------
// Teil 4. Typen für die MPEG-Behandlung
//--------------------------------------------------------------------

  TMpegHeader = record
    version: byte;
    layer: byte;
    protection: boolean;
    bitrate: LongInt;
    samplerate: LongInt;
    channelmode: byte;
    extension: byte;
    copyright: boolean;
    original: boolean;
    emphasis: byte;
    padding: boolean;
    framelength: word;
    valid: boolean;
  end;

  TXingHeader = record
    Frames: integer;
    Size: integer;
    valid: boolean;
  end;

  TMpegInfo = class(TObject)
  Private
    FFilesize: int64;
    Fversion:integer;
    Flayer:integer;
    Fprotection:boolean;
    Fbitrate:word;
    Fsamplerate:integer;
    Fchannelmode:byte;
    Fextension:byte;
    Fcopyright:boolean;
    Foriginal:boolean;
    Femphasis:byte;
    Fframes:Integer;
    Fdauer:Longint;
    Fvbr:boolean;
    Fvalid: boolean;
    FfirstHeaderPosition: int64;

    // Überprüft, ob im Array aBuffer an Position position ein gültiger MpegHeader ist
    // und liefert diesen zurück
    function GetValidatedHeader(aBuffer: TBuffer; position: integer): TMpegHeader;
    // Überprüft, ob nach dem aMpegHeader in aBuffer (pos entsprechend setzen) ein Xing-Frame kommt
    function GetXingHeader(aMpegheader: TMpegHeader; aBuffer: TBuffer; position: integer ): TXingHeader;
    function GetFramelength(version:byte;layer:byte;bitrate:integer;Samplerate:integer;padding:boolean):integer;

  public
    constructor create;
    function LoadFromStream(stream: tStream): TMP3Error;
    function LoadFromFile(filename: string): TMP3Error;
    property Filesize: int64          read   FFilesize;
    property version: integer         read   Fversion;
    property layer: integer           read   Flayer;
    property protection: boolean      read   Fprotection;
    property bitrate: word            read   Fbitrate;
    property samplerate: integer      read   Fsamplerate;
    property channelmode: byte        read   Fchannelmode;
    property extension: byte          read   Fextension;
    property copyright: boolean       read   Fcopyright;
    property original: boolean        read   Foriginal;
    property emphasis: byte           read   Femphasis;
    property frames: Integer          read   Fframes;
    property dauer: Longint           read   Fdauer;
    property vbr: boolean             read   Fvbr;
    property valid: boolean           read   Fvalid;
    property firstHeaderPosition: int64 read   FfirstHeaderPosition;
  end;



// Funktionen, die nicht zu den Klassen hier gehören,
// aber dennoch sinnvoll damit in Zusammenhang stehen.
// sie können z.B. im OnChange eines Editfeldes benutzt werden
  function IsValidV2TrackString(value:string):boolean;
  function IsValidV1TrackString(value:string):boolean;
  function IsValidYearString(value:string):boolean;

const
  IDv2_ARTIST = 0;
  IDv2_TITEL = 1;
  IDv2_ALBUM = 2;
  IDv2_YEAR = 3;
  IDv2_GENRE = 4;
  IDv2_COMMENT = 5;
  IDv2_TRACK = 6;
  IDv2_LYRICS = 7;
  IDv2_PICTURE = 8;
  IDv2_COMPOSER = 9;
  IDv2_ORIGINALARTIST = 10;
  IDv2_COPYRIGHT = 11;
  IDv2_ENCODEDBY = 12;
  IDv2_LANGUAGES = 13;
  IDv2_SOFTWARESETTINGS = 14;
  IDv2_MEDIATYPE = 15;
  IDv2_LENGTH = 16;
  IDv2_PUBLISHER = 17;
  IDv2_ORIGINALFILENAME = 18;
  IDv2_ORIGINALLYRICIST = 19;
  IDv2_ORIGINALRELEASEYEAR = 20;
  IDv2_ORIGINALALBUMTITEL = 21;

  // Achtung: Es muss sichergestellt sein, dass ID3v2_X-IDs[IDv2_XXXXX] die richtige Bezeichnung ist!
  // also z.B. muss  ID3v2_4_IDs[IDv2_ARTIST] die FrameID für Artist enthalten
  KnownID3v2_4_IDs: Array[0..21] of TID3v24ID
    =('TPE1', 'TIT2', 'TALB', 'TDRC', 'TCON', 'COMM', 'TRCK', 'USLT','APIC',
    'TCOM', 'TOPE', 'TCOP', 'TENC', 'TLAN', 'TSSE', 'TMED',
    'TLEN', 'TPUB', 'TOFN', 'TOLY', 'TDOR', 'TOAL'
    );

  KnownID3v2_3_IDs: Array[0..21] of TID3v23ID
    =('TPE1', 'TIT2', 'TALB', 'TYER', 'TCON', 'COMM', 'TRCK', 'USLT', 'APIC',
    'TCOM', 'TOPE', 'TCOP', 'TENC', 'TLAN', 'TSSE', 'TMED',
    'TLEN', 'TPUB', 'TOFN', 'TOLY', 'TORY', 'TOAL'
    );

  KnownID3v2_2_IDs: Array[0..21] of TID3v22ID
    =('TP1', 'TT2', 'TAL', 'TYE', 'TCO', 'COM', 'TRK','ULT', 'PIC',
    'TCM', 'TOA', 'TCR', 'TEN', 'TLA', 'TSS', 'TMT',
    'TLE', 'TPB', 'TOF', 'TOL', 'TOR', 'TOT'
    );

 MPEG_BIT_RATES : array[1..3] of array[1..3] of array[0..15] of word =
  { Version 1, Layer I }
    (((0,32,64,96,128,160,192,224,256,288,320,352,384,416,448,0),
  { Version 1, Layer II }
    (0,32,48,56, 64, 80, 96,112,128,160,192,224,256,320,384,0),
  { Version 1, Layer III }
    (0,32,40,48, 56, 64, 80, 96,112,128,160,192,224,256,320,0)),
  { Version 2, Layer I }
    ((0,32,48, 56, 64, 80, 96,112,128,144,160,176,192,224,256,0),
  { Version 2, Layer II }
    (0, 8,16,24, 32, 40, 48, 56, 64, 80, 96, 112,128,144,160,0),
  { Version 2, Layer III }
    (0, 8,16,24, 32, 40, 48, 56, 64, 80, 96, 112,128,144,160,0)),
  { Version 2.5, Layer I }
    ((0,32,48, 56, 64, 80, 96,112,128,144,160,176,192,224,256,0),
  { Version 2.5, Layer II }
    (0, 8,16,24, 32, 40, 48, 56, 64, 80, 96, 112,128,144,160,0),
  { Version 2.5, Layer III }
    (0, 8,16,24, 32, 40, 48, 56, 64, 80, 96, 112,128,144,160,0)));

  sample_rates: array[1..3] of array [0..3] of word=
    ((44100,48000,32000,0),
    (22050,24000,16000,0),
    (11025,12000,8000,0));
  channel_modes:array[0..3] of string=('Stereo','Joint stereo','Dual channel (Stereo)','Single channel (Mono)');
  extensions:array[1..3] of array [0..3] of string=
    (('bands 4 to 31','bands 8 to 32','bands 12 to 31','bands 16 to 31'),
     ('bands 4 to 31','bands 8 to 32','bands 12 to 31','bands 16 to 31'),
     ('IS:off, MS:off','IS:on, MS:off','IS:off, MS:on','IS:on, MS:on'));
  emphasis_values: array[0..3] of string = ('None', '50/15ms','reserved','CCIT J.17');

  Picture_Types: Array[0..20] of string =
  (	'Other',
    '32x32 pixels file icon (PNG only)',
    'Other file icon',
    'Cover (front)',
    'Cover (back)',
    'Leaflet page',
    'Media (e.g. lable side of CD)',
    'Lead artist/lead performer/soloist',
    'Artist/performer',
    'Conductor',
    'Band/Orchestra',
    'Composer',
    'Lyricist/text writer',
    'Recording Location',
    'During recording',
    'During performance',
    'Movie/video screen capture',
    'A bright coloured fish',
    'Illustration',
    'Band/artist logotype',
    'Publisher/Studio logotype' );


var
  Genres: TStringList;
  LanguageCodes: TStringlist;
  LanguageNames: TStringlist;


implementation

//--------------------------------------------------------------------
// außerhalb dieser Unit nicht notwendige Struktur
//--------------------------------------------------------------------
type  TID3v1Structure = record             // constant structure of an
    ID: array[1..3] of Char;               // ID3v1 tag in the file
    Title: array[1..30] of Char;
    Artist: array[1..30] of Char;
    Album: array[1..30] of Char;
    Year: array [1..4] of Char;
    Comment: array[1..30] of Char;
    Genre: Byte;
  end;
//--------------------------------------------------------------------




//--------------------------------------------------------------------
// Einige Hilfsprozeduren
//--------------------------------------------------------------------
//--------------------------------------------------------------------
// Liest von einem ByteArray in einen String
// Klappt ganz gut, aber meine Hand lege ich hierfür nicht ins Feuer !!!
//--------------------------------------------------------------------
(*   //Funktion durch nachfolgenden "Beta-Hack" ersetzt
function ReadToString(buffer: TBuffer; start:integer; Art:byte; alength: integer):string;
var tmp:string;
  tmpws:Widestring;
begin
    if alength<0 then
    begin
        result:='';
        exit;
    end;
    case Art of
        0:begin
           { ISO-8859-1 [ISO-8859-1]. Terminated with $00.}
           setlength(tmp,alength);
           move(buffer[start], tmp[1], alength);
        end;
       1: begin
           { UTF-16 [UTF-16] encoded Unicode [UNICODE] __with__ BOM. All
             strings in the same frame SHALL have the same byteorder.
             Terminated with $00 00. }
            setlength(tmpws,alength DIV 2 - 1);
            move(buffer[start+2], tmpws[1], 2*length(tmpws));
            tmp := UTF8ToAnsi(UTF8Encode(tmpws));
        end;
        2: begin
           { UTF-16BE [UTF-16] encoded Unicode [UNICODE] __without__ BOM.
             Terminated with $00 00 } // LE
            setlength(tmpws,alength DIV 2);
            move(buffer[start], tmpws[1], 2*length(tmpws));
            tmp := UTF8ToAnsi(UTF8Encode(tmpws));
        end;
        3: begin
            {03   UTF-8 [UTF-8] encoded Unicode [UNICODE]. Terminated with $00.}
            setlength(tmp,alength);
            move(buffer[start], tmp[1], alength);
            tmp:=UTF8ToAnsi(tmp);
        end;
        else tmp:='';
    end; //case
   result:=trim(tmp);
end;
*)
function ReadToString(buffer: TBuffer; start:integer; Art:byte; alength: integer):string;
var tmp:string;
 tmpws:Widestring;
 i: integer;
 b:byte;
begin
   if alength<0 then
   begin
       result:='';
       exit;
   end;
   case Art of
       0:begin
          { ISO-8859-1 [ISO-8859-1]. Terminated with $00.}
          setlength(tmp,alength);
          move(buffer[start], tmp[1], alength);
       end;
      1: begin
          { UTF-16 [UTF-16] encoded Unicode [UNICODE] __with__ BOM. All
            strings in the same frame SHALL have the same byteorder.
            Terminated with $00 00. }
           setlength(tmpws,alength DIV 2 - 1);
           //********************************
           // 28.Juli 2006: Swap Bytes bei "FE FF"
           if (buffer[start] = $FE) and (buffer[start + 1] = $FF) then
           begin
             for i := 1 to length(tmpws)-1 do begin
               b := buffer[start + 2*i];
               buffer[start + 2*i] := buffer[start + 2*i + 1];
               buffer[start + 2* i + 1] := b;
             end;
           end;
           //********************************
           move(buffer[start+2], tmpws[1], 2*length(tmpws));
           tmp := UTF8ToAnsi(UTF8Encode(tmpws));
           //********************************
           // 28. Juli 2006. Wieder zurückswappen
           if (buffer[start] = $FE) and (buffer[start + 1] = $FF) then
           begin
             for i := 1 to length(tmpws)-1 do begin
               b := buffer[start + 2*i];
               buffer[start + 2*i] := buffer[start + 2*i + 1];
               buffer[start + 2* i + 1] := b;
             end;
           end;
           //********************************
       end;
       2: begin
          { UTF-16BE [UTF-16] encoded Unicode [UNICODE] __without__ BOM.
            Terminated with $00 00 } // LE
           setlength(tmpws,alength DIV 2);
           move(buffer[start], tmpws[1], 2*length(tmpws));
           tmp := UTF8ToAnsi(UTF8Encode(tmpws));
       end;
       3: begin
           {03   UTF-8 [UTF-8] encoded Unicode [UNICODE]. Terminated with $00.}
           setlength(tmp,alength);
           move(buffer[start], tmp[1], alength);
           tmp:=UTF8ToAnsi(tmp);
       end;
       else tmp:='';
   end; //case
  result:=trim(tmp);
end;

//--------------------------------------------------------------------
// Lese einen Kommentar.
// Dabei wird die "Description" des Kommentars übersprungen.
// vgl. www.id3.org für Details - Thema COMMENT-Frames
//--------------------------------------------------------------------
function ReadComment(buffer: TBuffer;  start:integer; Art:byte; alength: integer):string;
var i:integer;
begin
  i:=-1;
  case art of
    1,2: begin // zwei Byte pro Zeichen, d.h. noch eine 0 mehr
        repeat
          inc(i);
        until ((buffer[start+i]=$0) AND (buffer[start+i+1]=$0)) or (i > alength);

        if i < alength {((start + i) = 4)} then
          result := Readtostring(buffer, Start+i+2, Art, alength-i-2)
        else
          result :=''
    end
    else begin
        repeat
          inc(i);
        until (buffer[start+i]=$0) or (i > alength);
        if i < alength then
          result := Readtostring(buffer, Start+i, Art, alength-i)
        else
          result := '';
    end;
  end
end;

//--------------------------------------------------------------------
// Überprüft, ob die Frame-ID gültig ist
//--------------------------------------------------------------------
function ValidFrame(ID: string): Boolean;
var
  i: Cardinal;
begin
  result := true;
  for i := 1 to length(ID) do
    if not (ID[i] in ['0'..'9', 'A'..'Z']) then
    begin
      result := false;
      Break;
    end;
end;

//--------------------------------------------------------------------
// Converts a 28bit integer used in ID3v2 unsync scheme to 32bit integer
//--------------------------------------------------------------------
function Int28ToInt32(Value: TInt28): LongWord;
begin
  // Take the rightmost byte and let it there,
  // take the second rightmost byte and move it 7bit to left
  //                                    (in an 32bit-variable)
  // a.s.o.
  result := (Value[3]) shl  0 or
            (Value[2]) shl  7 or
            (Value[1]) shl 14 or
            (Value[0]) shl 21;
end;

//--------------------------------------------------------------------
// Converts a 32bit Integer to a 28bit Integer
//--------------------------------------------------------------------
function Int32ToInt28(Value: LongWord): TInt28;
begin
  // move every byte in Value to the right, take the 7 LSBs
  // and assign them to the result
  Result[3] := (Value shr  0) and $7F;
  Result[2] := (Value shr  7) and $7F;
  Result[1] := (Value shr 14) and $7F;
  Result[0] := (Value shr 21) and $7F;
end;

//--------------------------------------------------------------------
// Setzt die Size-Bytes in einem Header entsprechend der angegebenen Größe
//--------------------------------------------------------------------
procedure UpdateHeader(Version:byte; Header: TBuffer; Size:integer);
begin
  case Version of
    3:begin
      Header[4] := Size DIV 16777216;
      Size := Size MOD 16777216;
      Header[5] := Size DIV 65536;
      Size := Size MOD 65536;
      Header[6] := Size DIV 256;
      Size := Size MOD 256;
      Header[7] := Size;
    end;
    4:begin
      Header[4] := Size DIV 2097152;
      Size := Size MOD 2097152;
      Header[5] := Size DIV 16384;
      Size := Size MOD 16384;
      Header[6] := Size DIV 128;
      Size := Size MOD 128;
      Header[7] := Size;
    end;
    2: begin
      Header[3] := Size DIV 65536;
      Size := Size MOD 65536;
      Header[4] := Size DIV 256;
      Size := Size MOD 256;
      Header[5] := Size;
    end;
  end;
end;

//--------------------------------------------------------------------
// Gets a filename for temporary files (makes sure, that the file doesn't already exist)
//--------------------------------------------------------------------
function GetTempFile: String;
var
  Path: String;
  i: Integer;
begin
  SetLength(Path, 256);
  FillChar(PChar(Path)^, 256, 0);
  GetTempPath(256, PChar(Path));
  Path := Trim(Path);
  if Path[Length(Path)] <> '\' then
    Path := Path + '\';
  i := 0;
  repeat
    result := Path + 'TagTemp.t' + IntToHex(i, 2);
    inc(i);
  until not FileExists(result);
end;

//--------------------------------------------------------------------
// Copies count data from one stream to another
//  (startpositions must be set in the streams)
//--------------------------------------------------------------------
function StreamToStream(Source, Target: TStream; Count: LongWord): TMP3Error;
var
  BlockSize: LongWord;
  Buffer: PChar;
  Diff: LongWord;
  read: LongWord;
begin
  result := MP3ERR_None;
  // copy the audio data to the temporary file
  BlockSize := 4096;
  try
    GetMem(Buffer, BlockSize);
    try
      Diff := Count;
      while Diff > 0 do
      begin
        // if there are less bytes to read than WC, set WC to new value
        if Diff < BlockSize then
          BlockSize := Diff;

        // Read WC bytes from Stream and writes it to Target
        read := Source.Read(Buffer^, BlockSize);
        dec(Diff, read);
        Target.WriteBuffer(Buffer^, read);
      end;
    finally
      FreeMem(Buffer);
    end;
  except
    on EWriteError do result := MP3ERR_SWrite;
    on EOutOfMemory do result := ID3ERR_Mem_Alloc;
    on E: Exception do
    begin
      result := ID3ERR_Unclassified;
      MessageBox(0, PChar(E.Message), PChar('Error'), MB_OK or MB_ICONERROR or MB_TASKMODAL or MB_SETFOREGROUND);
    end;
  end;
end;

//--------------------------------------------------------------------
// Determines whether the tag is ID3v1 or ID3v1.1
//--------------------------------------------------------------------
function GetID3v1Version(Tag: TID3v1Structure): Byte;
begin
  result := 0;
  //        specification for ID3v1.1:
  // The 29th byte of the comment must be zero,
  // the 30th represents the track number
  if (Tag.Comment[29] = #00) and (Tag.Comment[30] <> #00) then
    result := 1;
end;

//---------------------------------------------------
// Überprüft, ob ein String gültig für die Angabe eines v2-Tracks ist
//---------------------------------------------------
function IsValidV2TrackString(value:string):boolean;
var
  del: Integer;
  Track, Overall: String;
begin
  del := Pos('/', Value);       // getting the position of the delimiter
  if del = 0 then
    // If there is none, then the whole string is the TrackNumber
    result := (StrToIntDef(Value, -1) > -1)
  else begin
    Overall := Trim(Copy(Value, del + 1, Length(Value) - (del)));
    Track := Trim(Copy(Value, 1, del - 1));
    result := ((StrToIntDef(Track, -1) > -1) AND (StrToIntDef(Overall, -1) > -1))
  end;
end;

//--------------------------------------------------------------------
// ... und für v1
//--------------------------------------------------------------------
function IsValidV1TrackString(value:string):boolean;
begin
  result := (StrToIntDef(Value, -1) > -1);
end;

//--------------------------------------------------------------------
// Überprüfen auf gültige Jahresangabe
//--------------------------------------------------------------------
function IsValidYearString(value:string):boolean;
var tmp:integer;
begin
  tmp := StrToIntDef(Value, -1);
  result := (tmp > -1) AND (tmp < 10000);
end;





//--------------------------------------------------------------------
//--------------------------------------------------------------------
//        *** TID3v1Tag ***
//--------------------------------------------------------------------
//--------------------------------------------------------------------


constructor TID3v1Tag.Create;
begin
  inherited Create;
  // Set the tag to its standard-values
  Clear;
end;

{ Reads the ID3v1Tag from a stream containing the whole
  audio file and saves it to the corresponding variables }
function TID3v1Tag.ReadFromStream(Stream: TStream): TMP3Error;
var
  RawTag: TID3v1Structure;
begin
  result := MP3ERR_None;
  FExists := False;
  try
    Stream.Seek(-128, soFromEnd);
    if (Stream.Read(RawTag, 128) = 128) then
      if (RawTag.ID = 'TAG') then
      begin
        FExists := True;
        FVersion := GetID3v1Version(RawTag);
        FTitle := TrimRight(RawTag.Title);
        FArtist := TrimRight(RawTag.Artist);
        FAlbum := TrimRight(RawTag.Album);
        FYear := TrimRight(RawTag.Year);
        if FVersion = 0 then
          FComment := TrimRight(RawTag.Comment)
        else
        begin
          FComment := TrimRight(Copy(RawTag.Comment, 1, 28));
          FTrack := Ord(RawTag.Comment[30]);
        end;
        FGenre := RawTag.Genre;
      end
      else
        result := ID3ERR_NoTag
    else
      result := MP3ERR_SRead;
  except
    on E: Exception do
    begin
      result := ID3ERR_Unclassified;
      MessageBox(0, PChar(E.Message), PChar('Error'), MB_OK or MB_ICONERROR or MB_TASKMODAL or MB_SETFOREGROUND);
    end;
  end;
end;



{ Writes the ID3v1-tag to a given stream }
function TID3v1Tag.WriteToStream(Stream: TStream): TMP3Error;
var
  RawTag: TID3v1Structure;
  Buffer: PChar;
begin
  result := MP3ERR_NONE;

  try
    FillChar(RawTag, 128, 0);

    // assembling the RawTag step by step
    // NOTE: Move is needed because the fields of RawRag are
    //       arrays of Char while the others are real Shortstrings
    // NOTE: The 0 index is the length of the string, so it starts at 1
    RawTag.ID := 'TAG';
    Move(FTitle[1], RawTag.Title, Length(FTitle));
    Move(FArtist[1], RawTag.Artist, Length(FArtist));
    Move(FAlbum[1], RawTag.Album, Length(FAlbum));
    Move(FYear[1], RawTag.Year, Length(FYear));
    Move(FComment[1], RawTag.Comment, Length(FComment));
    if FTrack > 0 then
    begin
      RawTag.Comment[29] := #0;
      RawTag.Comment[30] := Chr(FTrack);
    end;
    RawTag.Genre := FGenre;
    // determining whether there is already a tag (then we have to
    // overwrite it)
    try
      GetMem(Buffer, 3);
      try
        // check for existing tag and seek to the appropriate
        // position in stream
        Stream.Seek(-128, soFromEnd);
        Stream.Read(Buffer^, 3);
        if Buffer = 'TAG' then
          Stream.Seek(-128, soFromEnd)
        else
          Stream.Seek(0, soFromEnd);
        if Stream.Write(RawTag, 128) <> 128 then
          result := MP3ERR_SWrite;
      finally
        FreeMem(Buffer);
      end;
    except
      result := ID3ERR_Mem_Alloc;
    end;
  except
    on E: Exception do
    begin
      result := ID3ERR_Unclassified;
      MessageBox(0, PChar(E.Message), PChar('Error'), MB_OK or MB_ICONERROR or MB_TASKMODAL or MB_SETFOREGROUND);
    end;
  end;
end;

{ Removes an ID3v1-tag from a file, if it exists }
function TID3v1Tag.RemoveFromStream(Stream: TStream): TMP3Error;
var
  Buffer: PChar;
begin
  result := MP3ERR_NONE;
  try
    Stream.Seek(-128, soFromEnd);
    try
      GetMem(Buffer, 3);
      try
        Stream.Read(Buffer^, 3);
        if Buffer = 'TAG' then
        begin
          Stream.Seek(-128, soFromEnd);
          SetEndOfFile((Stream as TFileStream).Handle);
        end
        else
          result := ID3ERR_NoTag;
      finally
        FreeMem(Buffer);
      end;
    except
      result := ID3ERR_Mem_Alloc;
    end;
  except
    on E: Exception do
    begin
      result := ID3ERR_Unclassified;
      MessageBox(0, PChar(E.Message), PChar('Error'), MB_OK or MB_ICONERROR or MB_TASKMODAL or MB_SETFOREGROUND);
    end;
  end;
end;

{ Initializes the tag (called by Create) }
procedure TID3v1Tag.Clear;
begin
  FTitle   := '';
  FArtist  := '';
  FAlbum   := '';
  FYear    := '';
  FComment := '';
  FTrack   := 0;
  FGenre   := 0;
  FVersion := 0;
  FExists  := False;
end;

{ Open a filestream and read tag from it }
function TID3v1Tag.ReadFromFile(Filename: String): TMP3Error;
var
  Stream: TFileStream;
begin
  result := MP3ERR_None;
  if FileExists(Filename) then
    try
      Stream := TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite);
      try
        result := ReadFromStream(Stream);
      finally
        Stream.Free;
      end;
    except
      result := MP3ERR_FOpenR;
    end
  else
    result := MP3ERR_NoFile;
end;

{ Open a filestream and write tag to it }
function TID3v1Tag.WriteToFile(Filename: String): TMP3Error;
var
  Stream: TFileStream;
begin
  result := MP3ERR_None;
  if FileExists(Filename) then
    try
      Stream := TFileStream.Create(Filename, fmOpenReadWrite or fmShareDenyWrite);
      try
        result := WriteToStream(Stream);
      finally
        Stream.Free;
      end;
    except
      result := MP3ERR_FOpenRW;
    end
  else
    result := MP3ERR_NoFile;
end;

{ Open a filestream and remove tag from it }
function TID3v1Tag.RemoveFromFile(Filename: String): TMP3Error;
var
  Stream: TFileStream;
begin
  result := MP3ERR_None;
  if FileExists(Filename) then
    try
      Stream := TFileStream.Create(Filename, fmOpenReadWrite or fmShareDenyWrite);
      try
        result := RemoveFromStream(Stream);
      finally
        Stream.Free;
      end;
    except
      result := MP3ERR_FOpenRW;
    end
  else
    result := MP3ERR_NoFile;
end;

{ property read functions }
function TID3v1Tag.GetGenre: String;
begin
  if FGenre <= 125 then
    result := Genres[FGenre]
  else
    result := '';
end;

function TID3v1Tag.GetTrack: String;
begin
  result := IntToStr(FTrack);
end;

{ property write procedures }
procedure TID3v1Tag.SetTitle(Value: String30);
begin
  FTitle := TrimRight(Value);
end;

procedure TID3v1Tag.SetArtist(Value: String30);
begin
  FArtist := TrimRight(Value);
end;

procedure TID3v1Tag.SetAlbum(Value: String30);
begin
  FAlbum := TrimRight(Value);
end;

procedure TID3v1Tag.SetGenre(Value: String);
var
  i: integer;
begin
  i := Genres.IndexOf(Value);

  if i in [0..125] then
    FGenre := i
  else
    FGenre := 255; // undefined
end;

procedure TID3v1Tag.SetYear(Value: String4);
begin
  FYear := TrimRight(Value);
end;

procedure TID3v1Tag.SetComment(Value: String30);
begin
  FComment := TrimRight(Value);
end;

procedure TID3v1Tag.SetTrack(Value : String);
begin
  FTrack := StrToIntDef(Value, 0);
end;





//--------------------------------------------------------------------
//--------------------------------------------------------------------
//        *** TID3v2Tag ***
//--------------------------------------------------------------------
//--------------------------------------------------------------------

constructor TID3v2Tag.Create;
begin
  inherited Create;
  Clear;
end;

function TID3v2Tag.GetFrameIDString(ID:integer):string;
begin
  case Version.Major of
    2: result := KnownID3v2_2_IDs[ID];           
    3: result := KnownID3v2_3_IDs[ID];
    4: result := KnownID3v2_4_IDs[ID];
    else result := '';
  end;
end;

// Zum lesen der Infos aus den Frames
// Achtung: Diese Prozedur nur für Frames verwenden, die eindeutig sind.
// Es gibt Frame-IDs, die mehrfach verwendet werden dürfen,
// z.B. die COMMent-Frames, die sich dann durch Sprache oder Beschreibung unterscheiden!
function TID3v2Tag.GetFrameIndex(ID:integer):integer;
var i:integer;
begin
  // Frame nicht gefunden
  result := -1;
  case Version.Major of
    2: for i:= 0 to length(FFrames)-1 do
        if FFrames[i].FFrameID = KnownID3v2_2_IDs[ID] then result := i;
    3: for i:= 0 to length(FFrames)-1 do
        if FFrames[i].FFrameID = KnownID3v2_3_IDs[ID] then result := i;
    4: for i:= 0 to length(FFrames)-1 do
        if FFrames[i].FFrameID = KnownID3v2_4_IDs[ID] then result := i;
  end;
end;

// Liefert den Index eines Frames mit einer Sprach- und Beschreibungseigenschaft
function TID3v2Tag.GetFrameIndex(ID:integer;Language:string;Description:string):integer;
var i:integer;
  IDstr:string;
  tmplanguage: string;
begin
  // Aufbau des Frames ist:
  //
  // <Header>
  // $xx          Textencoding
  // $xx xx xx    Language
  // <Description> $00 (00)
  // <full text string>
  //
  // z.B. im Comment-Frame, oder im Lyric-Frame
  result := -1;
  idstr := GetFrameIDString(ID);
  for i:= 0 to length(FFrames)-1 do
    if (FFrames[i].FFrameID = IDstr) then
    begin
      // passender IDstring gefunden
      // In Data[1] steht die Textcodierung drin
      // Jetzt: Language überprüfen.
      if (language ='*') OR (language='') then // ist ok, alle Sprachen werden akzeptiert
      else                         //[^^---] Eigentlich is das nicht ok, aber einige Frames sind fehlerhaft mit Leerstings (Nullbytes) gesetzt :-((
      begin
        setlength(tmplanguage,3);
        move(FFrames[i].Data[1],tmplanguage[1],length(tmplanguage));
        // keine Übereinstimmung? Beim nächsten Frame weitermachen
        if tmplanguage <> Language then continue;
      end;

      // Jetzt: Description überprüfen
      if description = '*' then // OK, alles wird akzeptiert
      else
        if description <> GetDescription(FFrames[i]) then continue;
      // Bis herhin durchgekommen? Dann haben wir den Frame gefunden,
      // und können abbrechen!
      result := i;
      break;
    end;
end;

// Liefert anhand der Beschreibung den Index eines Bild-Frames zurück.
function TID3v2Tag.GetFrameIndex(Description:TPictureFrameDesription):integer;
var mime, idstr: string;
  tmpdescription: TPictureFrameDesription;
  i: integer;
begin
  result := -1;
  idstr := GetFrameIDString(IDv2_PICTURE);                                            
  for i:= 0 to length(FFrames)-1 do                                                   
    if (FFrames[i].FFrameID = IDstr) then                                             
    begin                                                                             
      // passender IDstring gefunden                                                  
      // In Data[1] steht die Textcodierung drin                                      
      mime := GetMimeType(FFrames[i]);                                                
      case  Version.Major of                                                          
        2: tmpdescription := GetPictureDescription(FFrames[i], length(Mime) + 1)      
        else tmpdescription := GetPictureDescription(FFrames[i], length(Mime) + 2)    
      end;                                                                            
      if (Description.Description <> tmpDescription.Description)                      
        OR (Description.Bildtyp <> tmpdescription.Bildtyp)                            
      then continue;

      result := i;
      break;
    end;
end;

//--------------------------------------------------------------------
// Liefert die Beschreibung eines Frames zurück
//--------------------------------------------------------------------
function TID3v2Tag.GetDescription(aFrame:TID3v2Frame):string;
var max, ldesc: integer;
begin
      lDesc := -1;
      max := length(aFrame.Data);
      if max < 1 then
      begin
        result := '';
        exit;
      end;
      // frühester Punkt, wo Description zuende sein kann ist Data[4]
      case aFrame.Data[0] of
        1,2: begin // zwei Byte pro Zeichen,
            repeat
              inc(lDesc);
            until  (4+lDesc+1 >= max) OR ((aFrame.Data[4+lDesc]=$0) AND (aFrame.Data[4+lDesc+1]=$0));
            if (4+lDesc+1 < max) then
              result := trim(Readtostring(aFrame.Data, 4, aFrame.Data[0], lDesc))
            else
              result :='';
        end
        else begin  // ein Byte pro Zeichen
            repeat
              inc(ldesc);
            until (4+lDesc >= max) or (aFrame.Data[4+lDesc]=$0);
            if (4+lDesc < max) then
              result := trim(Readtostring(aFrame.Data, 4, aFrame.Data[0], lDesc))
            else
              result :='';
        end;
      end;
end;

//--------------------------------------------------------------------
// Liefert die beschreibung eine PIC / APIC-Frames
//--------------------------------------------------------------------
function TID3v2Tag.GetPictureDescription(aFrame:TID3v2Frame; StartPosition:integer):TPictureFrameDesription;
var max, lDesc: integer;
begin
  result.Bildtyp := aFrame.Data[startposition];
  inc(startposition);
  lDesc := -1;
  max := length(aFrame.Data);
  if max < Startposition then
  begin
    result.Description := '';
    result.Bildtyp := 0;
    exit;
  end;
  case aFrame.Data[0] of
    1,2 : begin
        repeat
          inc(lDesc);
        until  (StartPosition+lDesc+1 >= max)
              OR  ((aFrame.Data[StartPosition+lDesc]=$0) AND (aFrame.Data[StartPosition+lDesc+1]=$0));
        if (StartPosition + lDesc < max) then
          result.Description := trim(Readtostring(aFrame.Data, Startposition, aFrame.Data[0], lDesc))
        else
          result.Description := '';
    end
    else begin
        repeat
          inc(lDesc);
        until (StartPosition+lDesc >= max) or (aFrame.Data[StartPosition+lDesc]=$0);
        if (StartPosition + lDesc < max) then
          result.Description := trim(Readtostring(aFrame.Data, StartPosition, aFrame.Data[0], lDesc))
        else
          result.Description :='';
    end;
  end; //case
end;

//--------------------------------------------------------------------
// Liefert den MIME-Tpen eines PIC / APIC Frames zurück
//--------------------------------------------------------------------
function TID3v2Tag.GetMimeType(aFrame:TID3v2Frame):string;
var ldesc, max:integer;
begin
  case version.Major of
    2: begin // feste Länge für den Typen
      setlength(result,3);
      move(aFrame.Data[1], result[1],3);
    end;
    else begin // variable Länge. terminiert mit $00
      max := length(aFrame.Data);
      ldesc := -1;
      repeat
        inc(ldesc);
      until (1+lDesc >= max) OR (aFrame.Data[1+lDesc] = $0);
      if (1+lDesc < max) AND (lDesc > 0) then
      begin
        setlength(result,lDesc);
        move(aFrame.Data[1], result[1], lDesc);
      end else
        result :='';
    end;
  end;
end;


//--------------------------------------------------------------------
// Liest den ID3v2Header ein
//--------------------------------------------------------------------
function TID3v2Tag.ReadHeader(Stream: TStream; Complete: Boolean): TMP3Error;
var
  RawHeader: TID3v2Header;
  ExtendedHeader: Array[0..5] of byte;
  ExtendedHeaderSize: Integer;
begin
  result := MP3ERR_None;
  // set variables to 0/false
  FExists := False;
  FTagSize := 0;
  FFlgUnsynch := False; FFlgExtended := False; FFlgExperimental := False;

  // ACHTUNG!!!!! ???
  FVersion.Minor := 0; FPadding := 0;
  FVersion.Major := 3;


  // Major Version mit 3 initialisieren, weil:
  // Soll in eine Datei ein ID3v2Tag geschrieben werden, wo noch keiner ist,
  // so soll v3 geschrieben werden.
  // Andererseits soll die version geschrieben werden, die bereits vorhanden ist.
  // Daher ist eine Initialisierung mit 0 nicht sinnvoll

  try
    Stream.Seek(0, soFromBeginning);
    Stream.ReadBuffer(RawHeader, 10);
    if RawHeader.ID = 'ID3' then
      if RawHeader.Version in  [2,3,4] then
      begin
        FTagSize := Int28ToInt32(RawHeader.TagSize) + 10;
        FExists := True;

        // unsync-Flag ist gleich in v2 Version 2, 3, 4
        FFlgUnsynch := (RawHeader.Flags and 128) = 128;

        // Extended und Experimental-Flags erst ab Version 3
        if RawHeader.Version in [3,4] then
        begin
          FFlgExtended := (RawHeader.Flags and 64) = 64;
          FFlgExperimental := (RawHeader.Flags and 32) = 32;
        end
        else begin
          FFlgExtended := False;
          FFlgExperimental := False;
        end;

        // Footer-Present-Flag erst ab Version 4
        if RawHeader.Version = 4 then
        begin
          FFlgFooterPresent := (RawHeader.Flags and 16) = 16;
          if FFlgFooterPresent then
            FTagSize := FTagSize + 10;
        end
        else begin
          FFlgFooterPresent := False;
        end;

        // Version setzen


  // if complete then...       ACHTUNG:::INITIALISIERUNG OBEN!!!!!!!
        FVersion.Major := RawHeader.Version;
        FVersion.Minor := RawHeader.Revision;

        // Wenn ExtendedHeader, dann Größe des Extended Header lesen
        // und entsprechend weiterspringen.
        // Beim Schreiben des ID3v2Tags wird dieser nicht beachtet!
        if FFlgExtended then
        begin
          // VERSION /// NU IN 2.4 IST EXTENDED HEADER SIZE SYNC-SAFE!!!
          Stream.ReadBuffer(ExtendedHeader[0], 6); // Minimumgröße für Extended Header ist 6
          if version.Major =4 then
            ExtendedHeaderSize := 2097152 * ExtendedHeader[0]
              + 16384 * ExtendedHeader[1]
              + 128 * ExtendedHeader[2]
              + ExtendedHeader[3]
          else
            ExtendedHeaderSize := 16777216 * ExtendedHeader[0]
              + 65536 * ExtendedHeader[1]
              + 256 * ExtendedHeader[2]
              + ExtendedHeader[3];

          Stream.Seek(ExtendedHeaderSize-6, soFromCurrent);
        end;

      end
      else
        // Version kleiner als 2 oder größer als 4 -> ungültig
        result := ID3ERR_Invalid_Header
    else
      result := ID3ERR_NoTag;
  except
    on EReadError do result := MP3ERR_SRead;
    on E: Exception do
    begin
      result := ID3ERR_Unclassified;
      MessageBox(0, PChar(E.Message), PChar('Error'), MB_OK or MB_ICONERROR or MB_TASKMODAL or MB_SETFOREGROUND);
    end;
  end;
end;

//--------------------------------------------------------------------
// Lese die frames des ID3v2 Tags
//--------------------------------------------------------------------
function TID3v2Tag.ReadFrames(From: LongInt; Stream: TStream): TMP3Error;
var
  aHeader: TBuffer;  // Header hat Länge 6 oder 10
  newframeIDX: integer;
  FrameIDstr: string;
  FrameSize: integer;
begin
  result := MP3ERR_None;
  FUsePadding := False;
  try
    case Version.Major of
      // Version 2-Header hat eine Größe von 6 Byte (3 Byte ID, 3 Byte Größe)
      2 : begin
        SetLength(aHeader,6);
        Setlength(FrameIDstr,3);
      end;
      // Version 3 und 4 haben 10 Byte Headergröße
      // 4 Byte ID
      // 4 Byte Größe
      // 2 Byte Flags
      3,4: begin
        Setlength(aHeader,10);
        Setlength(FrameIDstr,4);
      end;
    end;

    if Stream.Position <> From then
      Stream.Position := From;

    // evtl. alte Frames entfernen
    SetLength(FFrames,0);

    // while the data already read is not bigger than the
    // whole tag, read the frames
    while (Stream.Position < (FTagSize - Padding))
                                       and (Stream.Position < Stream.Size) do
    begin
      // Header aus Stream lesen
      Stream.ReadBuffer(aHeader[0], Length(aHeader));
      move(aHeader[0],FrameIDstr[1],length(FrameIDstr));
      if ValidFrame(FrameIDstr) then
      begin
        // Framegröße je nach Version berechnen
        case Version.Major of
          2:   FrameSize := 65536 * aHeader[3]
                      + 256 * aHeader[4]
                      + aHeader[5];
          4: FrameSize := 2097152 * aHeader[4]
                      + 16384 * aHeader[5]
                      + 128 * aHeader[6]
                      + aHeader[7];
          else Framesize := 16777216 * aHeader[4]
                      + 65536 * aHeader[5]
                      + 256 * aHeader[6]
                      + aHeader[7];
        end;

        // Frame-Array um eins vergrößern
        SetLength(FFrames, Length(FFrames)+1);
        newFrameIDX := Length(FFrames)-1;

        with FFrames[newframeIDX] do // im Array speichern
        begin
          // Header kopieren
          setLength(Header,length(aHeader));
          move(aHeader[0],Header[0],length(Header));
          // Daten kopieren
          SetLength(Data, FrameSize);
          Stream.ReadBuffer(Data[0], FrameSize);
          //Im Gegensatz zu UltimaTag ist hier das Encoding-Byte enthalten!!!}
          // restliche Infos setzen
          FFrameID := FrameIDstr;
          FSize := FrameSize;
        end;
      end else
      // Kein neuer gültiger Frame gefunden. Der Rest des Tags ist also Padding
      // Den evtl. vorhandenen Footer ignoriere ich (bzw. ersetze ihn durch 0)
      begin
        FPadding := FTagSize - (Stream.Position - length(aHeader));
        FUsePadding := True;
        Break;
      end;
    end;
  except
    on EReadError do result := MP3ERR_SRead;
    on E: Exception do
    begin
      result := ID3ERR_Unclassified;
      MessageBox(0, PChar(E.Message), PChar('Error'), MB_OK or MB_ICONERROR or MB_TASKMODAL or MB_SETFOREGROUND);
    end;
  end;
end;

//--------------------------------------------------------------------
// read the tag information, frames are done seperately
//--------------------------------------------------------------------
function TID3v2Tag.ReadFromStream(Stream: TStream): TMP3Error;
begin
  // Tag löschen - es könnten Frames entahlten sein
  clear;
  result := MP3ERR_None;
  result := ReadHeader(Stream, True);
  if (FExists) and (result = MP3ERR_None) then
    result := ReadFrames(Stream.Position, Stream)
end;


//--------------------------------------------------------------------
// write the tag to a stream
//--------------------------------------------------------------------
function TID3v2Tag.WriteToStream(Stream: TStream): TMP3Error;
var
  aHeader: TID3v2Header;
  TmpStream, ID3v2Stream: TFileStream;
  TmpName, FrameName: String;
  Buffer: PChar;
  CacheAudio: Boolean;
  i: Integer;
begin
  result := MP3ERR_None;

  // Ein ID3v2Tag muss mindestens einen Frame enthalten, und dieser muss mindestens ein
  // Byte lang sein.
  // Sollten alle Frames gelöscht worden sein, so muss hier ein Frame erzeugt werden.
  // Ich nehme hier den Titel-Frame und weise diesem dern Wert ' ' zu (ein Leerzeichen)
  //
  // Hinweis: Dass die anderen Frames nicht leer sind, liegt in der "Verantwortung der Frames"
  //          d.h. beim setzen der Eigenschaft muss ggf. der ganze Frame gelöscht werden, wenn
  //          er durch die Änderung keine Daten mehr enthält.
  if length(FFrames) = 0 then
    Title := ' ';

  // write frames to a cache to determine their size
  FrameName := GetTempFile;
  try
    ID3v2Stream := TFileStream.Create(FrameName, fmCreate or fmShareDenyWrite);

    try // stop immediately when an error occurs and delete the frame file
      // Baue einen neuen Header
      // Die Größe des geasmten Tags ist hier noch unbekannt -
      // sie wird später neugesetzt
      aHeader.ID := 'ID3';
      aHeader.Version := Version.Major;
      aHeader.Revision := Version.Minor;
      for i:=0 to 3 do
        aHeader.TagSize[i] := 0;
      aHeader.Flags := 0;
        // Compression in Fall 2.2 war wohl ne Sackgasse, ist immer 0
        // Extended Header: den lasse ich beim schreiben weg 0
        // Experimental bin ich auch nicht 0
        // und den Footer lass ich auch weg 0
      ID3v2Stream.WriteBuffer(aHeader,10);

      // schreibe alle Frames in ein temporäres File (Framestream)
      for i := 0 to Length(FFrames) - 1 do
      with FFrames[i] do
        begin
          ID3v2Stream.WriteBuffer(Header[0],length(header));
          ID3v2Stream.WriteBuffer(Data[0],length(Data));
        end;

      // wenn ein frame geschrieben wurde, dann weiter mit schreiben im eigentlichen Sinn
      if ID3v2Stream.Size > 0 then
      begin
        ReadHeader(Stream, False); // check for existing header

        // (-*-)

        // Achtung! Damit wird natürlich der aktuelle Header überschrieben und somit ggf.
        // die ganze Struktur ungültig! (v2.2 hat eine andere Framestruktur als v2.3 und v2.4!!)

        // HÄ?? - Zur Erklärung: Man könnte ja auf die Idee kommen, den ID3v2 Tag von einer Datei,
        //        die mit Version v2.2 getaggt ist, zu lesen (id3v2.ReadFromFile(c:\v2_2.mp3);)
        //        und anschliessend in eine ANDERE Datei zu schreiben, die dann möglicherweise mit
        //        einer anderen Version getaggt ist. (id3v2.WriteToFile(c:\v2_3.mp3);)
        //        Es versteht sich, dass dadurch die Tag-Informationen der Datei v2_3.mp3
        //        verlorengehen und durch die von v2_2.mp3 ersetzt werden.
        //        Trotzdem muss vorher der Header gelesen werden, um festzustellen, ob bereits ein ID3v2
        //        Tag vorhanden ist, damit keine mehrfach-Tags entstehen

        // aber der Header (und somit auch die Version) des Tags, den ich hier schreibe,
        // liegt schon im ID3v2Stream drin...

        // Ans Ende des evtl vorhandenen Tags im Stream gehen
        Stream.Seek(FTagSize, soFromBeginning);

        // <Pos 1>

        CacheAudio := True; // by default, cache audio data to temporary stream
        if FUsePadding and (FTagSize > (ID3v2Stream.Size + 30)) then
          // if we want padding and there is enough space in
          // the existing tag, don't copy audio data !
          CacheAudio := False;
        // otherwise the tag is too small or we want no padding,
        // therefore cache the audio data

        if CacheAudio then
        begin
          // Alter ID3v2Tag ist zu klein für unsere neuen Frames, daher muss der Stream
          // komplett neu geschrieben werden
          // copy audio data to a temporary file
          TmpName := GetTempFile;
          try
            TmpStream := TFileStream.Create(TmpName, fmCreate or fmShareDenyWrite);
            TmpStream.Seek(0, soFromBeginning);
            if StreamToStream(Stream, TmpStream, Stream.Size -
                Stream.Position) <> MP3ERR_None then
            begin
              result := ID3ERR_Cache;
              Exit;
            end;
            TmpStream.Free;
          except
            result := ID3ERR_Cache;
            Exit; // when we could not cache audio data, escape the procedure
                  // for not to damage the file
          end;
        end;
        // Damit liegt jetzt der komplette (d.h. bis auf das Padding) ID3 Tag im Stream  "ID3v2Stream"
        // und die AudioDaten im Stream "tmpstream" (falls das nötig war)

        // allerdings ist der Header noch ungültig - es fehlt ja noch die Größe des Tags
        // Dazu ist aber auch noch das Padding nötig:
        FDataSize := ID3v2Stream.Size;
        if FUsePadding then
        // if we want padding, get its size
          if CacheAudio then
          begin
            // if we don't overwrite the existing tag
            // calculate padding and new TagSize
            FPadding := (((FDataSize + 15) div 2048 + 1) * 2048) - FDataSize;
            FTagSize := FDataSize + FPadding;
          end
          else
            // otherwise, padding size is old tag size minus new data size
            FPadding := FTagSize - FDataSize
            // deswegen an <Pos [1]> noch nicht wieder den neuen Tag einlesen,
            // wie ich es mal zuerst hatte
        else
        begin
          // otherwise, padding is 0 and the tag consits only of data
          FPadding := 0;
          FTagSize := FDataSize;
        end;

        // Jetzt die Größe des Headers neu schreiben
        aHeader.TagSize := Int32ToInt28(FTagSize - 10);
        // JA, FTagSize aus dem Tag, der bereits in der Datei steht
        //     oder halt, wenn der Platz nicht ausreichte (if CacheAudio),
        //     die neu berechnete Größe

        ID3v2Stream.Seek(0, soFromBeginning);
        ID3v2Stream.WriteBuffer(aHeader,10);

        // write always to the beginning of the file
        Stream.Seek(0, soFromBeginning);
        ID3v2Stream.Seek(0, soFromBeginning);

        // ID3v2 Header und Daten schreiben
        StreamToStream(ID3v2Stream, Stream, ID3v2Stream.Size);

        // Padding schreiben
        try
          GetMem(Buffer, FPadding);
          try
            FillChar(Buffer^, FPadding, 0);
            Stream.Write(Buffer^, FPadding);
          finally
            FreeMem(Buffer);
          end;
        except
          result := ID3ERR_Mem_Alloc;
          // why don't escape the function here:
          // here only padding fails, the tag is still there, as the
          // audio cache is
        end;

        // ggf. gecachte AudioDaten schreiben
        if CacheAudio then
        begin
          try
            TmpStream := TFileStream.Create(TmpName, fmOpenRead);
            try
              TmpStream.Seek(0, soFromBeginning);
              StreamToStream(TmpStream, Stream, TmpStream.Size);
            finally
              TmpStream.Free;
            end;
          except
            result := MP3ERR_FOpenR;
            Exit; // when rewriting the cache fails, escape for not to delete
                  // the temporary cache file
          end;
        end;
        // Audio-Cache-File löschen
        DeleteFile(PChar(TmpName));

        // Jetzt den Header wieder lesen

        // HÄ??  Wir haben oben [(-*-)]möglicherweise einen Header gelesen, der nicht zum Rest der Daten passt
        //       Diesen haben wir benötigt, um die Größe des evtl. vorhandenen Tags im Stream festzustellen.
        //       Dieser wurde mit dem neu gebauten Header aHeader und den ganzen Frames überschrieben.
        //       Wenn man nun später neue Frames einfügen möchte, wäre ansonsten aber noch die möglicherweise
        //       fehlerhafte Version des überschriebenen Headers im Speicher. Daher muss der Header hier nochmals
        //       gelesen werden.
        // Ja, ich gebe zu, das ist etwas umständlich
        ID3v2Stream.Seek(0, soFromBeginning);
        ReadHeader(ID3v2Stream, False);

      end;  // if ID3v2Stream.Size > 0;

    finally
      ID3v2Stream.Free;
      // tmp-File für den ID3Tag löschen
      DeleteFile(PChar(FrameName));
    end;
  except
    on EFCreateError do result := MP3ERR_FopenCRT;
    on EWriteError do result := MP3ERR_SWrite;
    on E: Exception do
    begin
      result := ID3ERR_Unclassified;
      MessageBox(0, PChar(E.Message), PChar('Error'), MB_OK or MB_ICONERROR or MB_TASKMODAL or MB_SETFOREGROUND);
    end;
  end;
end;

//--------------------------------------------------------------------
// Removes the whole tag from the given stream, if it exists
//--------------------------------------------------------------------
function TID3v2Tag.RemoveFromStream(Stream: TStream): TMP3Error;
var
  TmpStream: TFileStream;
  TmpName: String;

  ActualVersion: TID3Version;
begin
  result := MP3ERR_None;

  try

    // Version des Tags im Speicher merken
    ActualVersion.Major := FVersion.Major;
    ActualVersion.Minor := FVersion.Minor;

    // in ReadHeader werden folgende Eigenschaften gesetzt
    // FExists, FTagSize FVersion, "Die 4 Flags im Header"
    // Wie auch in "WriteToStream" erläutert, benötige ich hier die Information,
    // ob bereits ein Tag im File/Stream ist. Ich überschreibe mit ReadHeader die
    // Privaten Variablen FVersion etc.
    // Aber: Die Version brauche ich beim Erstellen neuer Frames. Es darf nicht passieren,
    // das im Tag (der, der im Speicher ist), sowohl V2 als auch V3 Frames enthalten sind,
    // denn diese haben ein anderes Format und sind zueinander inkompatibel.

    // Man könnte das Problem auch dadurch lösen, dass man für den Test "Ist ein Header vorhanden"
    // eine eigene Prozedur schreibt. Oder die vorhandene entsprechend anpasst, ob die "echten"
    // Werte geändert werden sollen, oder nur die "temporären"

    ReadHeader(Stream, False);

    // Version wieder herstellen
    FVersion.Major := ActualVersion.Major;
    FVersion.Minor := ActualVersion.Minor;

    // Wenn die übrigen Variablen "falsch" im Speicher liegen, macht das beim gegenwärtigen
    // Stand der Klasse nichts aus:
    // Die Flags ignoriere ich sowieso, Die Tagsize ist nur beim Speichern interessant und
    // muss dort sowieso neu berechnet werden, und FExists wird nur hier und bei ReadfromStream
    // unmittelbar nach einem Aufruf von ReadHeader benutzt.

    // if there is a tag
    if FExists then
    begin
      // seek to its end
      Stream.Seek(FTagSize, soFromBeginning);

      // and copy the following audio data to a temporary file
      TmpName := GetTempFile;
      try
        TmpStream := TFileStream.Create(TmpName, fmCreate);
        try
          TmpStream.Seek(0, soFromBeginning);
          if StreamToStream(Stream, TmpStream, Stream.Size -
                                Stream.Position) <> MP3ERR_None then
          begin
            result := ID3ERR_Cache;
            Exit;
          end;

          // shorten the file by the size of the tag
          Stream.Seek(-FTagSize, soFromEnd);
          SetEndOfFile((Stream as TFileStream).Handle);

          // return the audio data to the stream
          Stream.Seek(0, soFromBeginning);
          TmpStream.Seek(0, soFromBeginning);
          if StreamToStream(TmpStream, Stream, TmpStream.Size) <> MP3ERR_None then
          begin
            result := ID3ERR_Cache;
            Exit;
          end;
        except
          on EWriteError do result := MP3ERR_SWrite;
          on E: Exception do
          begin
            result := ID3ERR_Unclassified;
            MessageBox(0, PChar(E.Message), PChar('Error'), MB_OK or MB_ICONERROR or MB_TASKMODAL or MB_SETFOREGROUND);
          end;
        end;

        // delete the temporary file
        TmpStream.Free;
        DeleteFile(PChar(TmpName));
      except
        on EFOpenError do result := MP3ERR_FOpenCRT;
        on E: Exception do
        begin
          result := ID3ERR_Unclassified;
          MessageBox(0, PChar(E.Message), PChar('Error'), MB_OK or MB_ICONERROR or MB_TASKMODAL or MB_SETFOREGROUND);
        end;
      end;

    end
    else
      result := ID3ERR_NoTag;

  except
    on E: Exception do
    begin
      result := ID3ERR_Unclassified;
      MessageBox(0, PChar(E.Message), PChar('Error'), MB_OK or MB_ICONERROR or MB_TASKMODAL or MB_SETFOREGROUND);
    end;
  end;
end;


//--------------------------------------------------------------------
// Open a filestream and read tag from it
//--------------------------------------------------------------------
function TID3v2Tag.ReadFromFile(Filename: String): TMP3Error;
var
  Stream: TFileStream;
begin
  result := MP3ERR_None;
  if FileExists(Filename) then
    try
      Stream := TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite);
      try
        result := ReadFromStream(Stream);
      finally
        Stream.Free;
      end;
    except
      result := MP3ERR_FOpenR;
    end
  else
    result := MP3ERR_NoFile;
end;

//--------------------------------------------------------------------
// Open a filestream and write tag to it
//--------------------------------------------------------------------
function TID3v2Tag.WriteToFile(Filename: String): TMP3Error;
var
  Stream: TFileStream;
begin
  result := MP3ERR_None;
  if FileExists(Filename) then
    try
      Stream := TFileStream.Create(Filename, fmOpenReadWrite or fmShareDenyWrite);
      try
        result := WriteToStream(Stream);
      finally
        Stream.Free;
      end;
    except
      result := MP3ERR_FOpenRW;
    end
  else
    result := MP3ERR_NoFile;
end;

//--------------------------------------------------------------------
// Open a filestream and remove tag from it
//--------------------------------------------------------------------
function TID3v2Tag.RemoveFromFile(Filename: String): TMP3Error;
var
  Stream: TFileStream;
begin
  result := MP3ERR_None;
  if FileExists(Filename) then
    try
      Stream := TFileStream.Create(Filename, fmOpenReadWrite or fmShareDenyWrite);
      try
        result := RemoveFromStream(Stream);
      finally
        Stream.Free;
      end;
    except
      result := MP3ERR_FOpenRW;
    end
  else
    result := MP3ERR_NoFile;
end;


procedure TID3v2Tag.Clear;
var
  i: Integer;
begin
  for i := 0 to length(FFrames) - 1 do
    with FFrames[i] do
    begin
      FFrameID := '';
      FSize := 0;
      Setlength(Data,0);
      Setlength(Header,0);
    end;
  // Default-Verison ist bei mir 3. Diese schreibe ich, wenn kein ID3v2Tag gefunden wird.
  FVersion.Major := 3;
  FVersion.Minor := 0;
  FTagSize := 0;
  FDataSize :=0;
  FExists := False;

  SetLength(FFrames, 0);
end;


//--------------------------------------------------------------------
// Liefert die Textinformationen aus einem textframe zurück
//--------------------------------------------------------------------
function TID3v2Tag.GetTextFrame(FrameID: integer):String;
var i:integer;
begin
  i := GetFrameIndex(FrameID);
  if i > -1 then
  begin
    result := readtostring(FFrames[i].Data,   // Der gewünschte Datenteil
        1,                          // Das erste Byte gehört nicht zum string, sondern:
        FFrames[i].Data[0],         // Im ersten Byte steht die TextCodierung drin
        length(FFrames[i].Data)-1); // Länge
  end
  else result := '';
end;

//--------------------------------------------------------------------
// Schreibt einen String in einen Textframe
// Zeichenkodierung ist Standard [ISO-8859-1]
//
// Ist der übergebene String leer, wird der gesamte Frame gelöscht
//--------------------------------------------------------------------
procedure TID3v2Tag.SetTextFrame(FrameID:integer; Value: String);
var i:integer;
begin
  // Achtung: Hier nicht trim(value)='' nehmen!
  //          vgl. dazu die 'Absicherung' in WriteToStream, dass mindestens ein Frame im Tag vorhanden ist!
  if value='' then
  begin
    DeleteTextFrame(FrameID);
    exit;
  end;

  i := GetFrameIndex(FrameID);
  if i > -1 then
  begin
        // Frame existiert schon
        Setlength(FFrames[i].Data, length(Value)+1);
        move(Value[1], FFrames[i].Data[1], length(Value));
        FFrames[i].Data[0] := 0;
        FFrames[i].FSize := length(FFrames[i].Data);
        // Update Header (Size-Teil)
        UpdateHeader(Version.Major,FFrames[i].Header,FFrames[i].FSize);
  end else
  begin
    // Frame existiert noch nicht
    SetLength(FFrames, Length(FFrames)+1);
    i := Length(FFrames)-1;
    case Version.Major of
      2: begin
        FFrames[i].FFrameID := KnownID3v2_2_IDs[FrameID];
        Setlength(FFrames[i].Data, length(Value)+1);
        move(Value[1], FFrames[i].Data[1], length(Value));
        FFrames[i].Data[0] := 0;
        FFrames[i].FSize := length(FFrames[i].Data);
        Setlength(FFrames[i].Header,6);
        //Header0-2(FRAMEID)
        move(FFrames[i].FFrameID[1], FFrames[i].Header[0], 3);
        // Header3-5 (Size-Teil)
        UpdateHeader(Version.Major,FFrames[i].Header,FFrames[i].FSize);
      end;
      3,4: begin
        if Version.Major = 3 then
          FFrames[i].FFrameID := KnownID3v2_3_IDs[FrameID]
        else
          FFrames[i].FFrameID := KnownID3v2_4_IDs[FrameID];

        Setlength(FFrames[i].Data, length(Value)+1);
        move(Value[1], FFrames[i].Data[1], length(Value));
        FFrames[i].Data[0] := 0;
        FFrames[i].FSize := length(FFrames[i].Data);
        Setlength(FFrames[i].Header,10);
        //Header0-3(FRAMEID)
        move(FFrames[i].FFrameID[1], FFrames[i].Header[0], 4);
        // Header4-7 (Size-Teil)
        UpdateHeader(Version.Major,FFrames[i].Header,FFrames[i].FSize);
        FFrames[i].Header[8] := 0;
        FFrames[i].Header[9] := 0;
      end;
    end;
  end;
end;

//--------------------------------------------------------------------
// Liest den String aus einem "Beschriebenen" Textframe, z.B. Commentare, Lyrics
//--------------------------------------------------------------------
function TID3v2Tag.GetDescribedTextFrame(ID:integer;Language:string;Description:string):string;
var i: integer;
begin
  i := GetFrameIndex(ID,Language,Description);
  if i > -1 then
    result := ReadComment(FFrames[i].Data,   // Der gewünschte Datenteil
        1,                          // Das erste Byte gehört nicht zum string, sondern:
        FFrames[i].Data[0],         // Im ersten Byte steht die TextCodierung drin
        length(FFrames[i].Data)-1) // Länge
  else result:='';
end;

procedure TID3v2Tag.SetDescribedTextFrame(ID:integer;Language:string;Description:string; Value:string);
var i:integer;
begin
  // Hinweis zur Benutzung dieser Funktion:
  // der Comment-Frame im id3v2Tag _kann_ mehrfach auftreten - jeweils einer mit eindeutiger Sprache|Description
  // Viele ID3Tagger zeigen aber eine Art "Standard-Comment" an.
  // Dieser hat die Description '' (Leerstring). Die Sprache ist aber nicht einheitlich.
  // Um diesen "Pseudo-Standard-Kommentar" zu setzen erlaube ich die Übergabe von "*" im Sprach-Parameter.
  // Dann wird der erste gefundene Frame, der mit der Beschreibung zusammenpasst, überschrieben. Wird kein
  // passender Frame gefunden, wird die Sprache auf 'eng' (english) gesetzt.
  // DIESES PROBLEM SOLLTE NUR BEIM STANDARD-COMMENT KOMMEN (Description = '') !
  // ANDERE KOMMENTARE ODER DESCRIBED-TEXTFRAMES SOLLTEN _EINDEUTIG_ GESETZT WERDEN
  // vgl. dazu
  //     GetAllCommentDescriptions,
  //     GetAllLyricsDescriptions,
  //     GetAllPictureFrameDescriptions,
  // die eine Liste/Array mit allen gefunden
  // Beschreibungen + Languages einer mehrfach vorkommenden Frame-ID liefert

  if (language <>'*') AND (length(language)<>3)
    then language := 'eng';

  // Achtung: Hier nicht trim(value)='' nehmen!
  //          vgl. dazu die 'Absicherung' in WriteToStream, dass mindestens ein Frame im Tag vorhanden ist!
  if value='' then
  begin
    DeleteDescribedTextFrame(ID, Language, Description);
    exit;
  end;

  // Frame suchen
  i := GetFrameIndex(ID, Language, Description);

  // entsprechender Frame existiert schon
  if i > -1 then
  begin
        Setlength(FFrames[i].Data, length(Value)+length(description)+5);
        // Set Text Encoding to 00
        FFrames[i].Data[0] := 0;
        // Kopiere den Language String in den Frame, wenn eine Sprache gewünscht ist
        // andernfalls bleibt die Sprache des vorher vorhandenen Frames erhalten
        if language <> '*' then
          move(Language[1], FFrames[i].Data[1], 3);
        // Kopiere Description in den Frame
        if Description <>'' then
          move(Description[1], FFrames[i].Data[4], length(description));
        // Setze Description-Termination-Byte auf 00
        FFrames[i].Data[4 + length(description)] := 0;
        // Kopiere Value in den Frame
        move(Value[1], FFrames[i].Data[5+length(description)], length(Value));
        // Setze Größe neu
        FFrames[i].FSize := length(FFrames[i].Data);
        // Berechne GreößenFeld im Header neu
        UpdateHeader(Version.Major,FFrames[i].Header,FFrames[i].FSize);
  end else
  // entsprechender Frame existiert noch nicht
  begin
    SetLength(FFrames, Length(FFrames)+1);
    i := Length(FFrames)-1;
    case Version.Major of
      2: begin
        // Setze den Frame-ID-String
        FFrames[i].FFrameID := KnownID3v2_2_IDs[ID];
        // Setze die Größe des DatenTeils
        Setlength(FFrames[i].Data, length(Value)+length(description)+5);
        // Set TextEncoding auf 00
        FFrames[i].Data[0] := 0;
        // Language kopieren
        if length(language)<>3
          then language := 'eng';
        move(Language[1], FFrames[i].Data[1], 3);
        // Description kopieren
        if Description <>'' then
          move(Description[1], FFrames[i].Data[4], length(description));
        // Setze Description-Termination-Byte auf 00
        FFrames[i].Data[4 + length(description)] := 0;
        // Value kopieren
        move(Value[1], FFrames[i].Data[5+length(description)], length(Value));

        FFrames[i].FSize := length(FFrames[i].Data);
        // Header Länge auf 6 setzen
        Setlength(FFrames[i].Header,6);
        // Header ID-String setzen
        move(FFrames[i].FFrameID[1], FFrames[i].Header[0], 3);
        // Größe im Header neu setzen
        UpdateHeader(Version.Major,FFrames[i].Header,FFrames[i].FSize);
      end;
      3,4: begin
        if Version.Major = 3 then
          FFrames[i].FFrameID := KnownID3v2_3_IDs[ID]
        else
          FFrames[i].FFrameID := KnownID3v2_4_IDs[ID];
        Setlength(FFrames[i].Data, length(Value)+length(description)+5);
        FFrames[i].Data[0] := 0;
        if length(language)<>3
          then language := 'eng';
        move(Language[1], FFrames[i].Data[1], 3);
        if Description <>'' then
          move(Description[1], FFrames[i].Data[4], length(description));
        FFrames[i].Data[4 + length(description)] := 0;
        move(Value[1], FFrames[i].Data[5+length(description)], length(Value));

        FFrames[i].FSize := length(FFrames[i].Data);
        Setlength(FFrames[i].Header,10);
        move(FFrames[i].FFrameID[1], FFrames[i].Header[0], 4);
        UpdateHeader(Version.Major,FFrames[i].Header,FFrames[i].FSize);
        FFrames[i].Header[8] := 0;
        FFrames[i].Header[9] := 0;
      end;
    end;
  end;
end;

procedure TID3v2Tag.DeleteTextFrame(FrameID: integer);
var i,delIDX: integer;
begin
  delIDX := GetFrameIndex(FrameID);
  if delIDX < 0 then exit;

  for i:=delIDX to length(FFrames)-2 do
    FFrames[i] := FFrames[i+1];
  Setlength(FFrames, length(FFrames)-1);
end;

procedure TID3v2Tag.DeleteDescribedTextFrame(ID:integer;Language:string;Description:string);
var i,delIDX: integer;
begin
  delIDX := GetFrameIndex(ID,Language,Description);
  if delIDX < 0 then exit;
  
  for i:=delIDX to length(FFrames)-2 do
    FFrames[i] := FFrames[i+1];
  Setlength(FFrames, length(FFrames)-1);
end;

function TID3v2Tag.GetAllFrameDescriptions(FrameID:integer): TFrameDescriptionArray;
var idstr: string;
  i:integer;
  arrayIDX:integer;
begin
  setlength(result,0);
  idstr := GetFrameIDString(FrameID);
  for i:= 0 to length(FFrames)-1 do
    if (FFrames[i].FFrameID = IDstr) then
    begin
      // passender IDstring gefunden
      // In Data[1] steht die Textcodierung drin
      arrayIDX := length(result);
      setlength(result,arrayIDX+1);
      // Sprache kopieren
      setlength(result[arrayIDX].Language,3);
      move(FFrames[i].Data[1],result[arrayIDX].Language[1],3);
      result[arrayIDX].Language := trim(result[arrayIDX].Language);
      // Description kopieren
      result[arrayIDX].Description := GetDescription(FFrames[i]);
    end;
end;

function TID3v2Tag.GetAllPictureFrameDescriptions: TPictureFrameDescriptionArray;
var idstr, mime: string;
  i:integer;
  arrayIDX:integer;
begin
  setlength(result,0);
  idstr := GetFrameIDString(IDv2_PICTURE);
  for i:= 0 to length(FFrames)-1 do
    if (FFrames[i].FFrameID = IDstr) then
    begin
      arrayIDX := length(result);
      setlength(result,arrayIDX+1);
      mime := GetMimeType(FFrames[i]);
      case  Version.Major of
        2: result[arrayIDX] := GetPictureDescription(FFrames[i], length(Mime) + 1);
        else result[arrayIDX] := GetPictureDescription(FFrames[i], length(Mime) + 2)
      end;
    end;
end;


// ------------------------------------------
// Erweiterte Comments schreiben und lesen
// ------------------------------------------
procedure TID3v2Tag.SetExtendedComment(Language:string;Description:string; value:string);
begin
  SetDescribedTextFrame(IDv2_COMMENT,Language,Description,value);
end;
function TID3v2Tag.GetExtendedComment(Language:string;Description:string): string;
begin
  result := GetDescribedTextFrame(IDv2_COMMENT,Language,Description);
end;
function TID3v2Tag.GetAllCommentDescriptions: TFrameDescriptionArray;
begin
  result := GetAllFrameDescriptions(IDv2_COMMENT);
end;
procedure TID3v2Tag.DeleteExtendedComment(Language:string;Description:string);
begin
  DeleteDescribedTextFrame(IDv2_COMMENT, Language, Description);
end;

// ------------------------------------------
// Lyrics lesen und schreiben
// ------------------------------------------
procedure TID3v2Tag.SetLyrics(Language:string;Description:string; value:string);
begin
  SetDescribedTextFrame(IDv2_LYRICS,Language,Description,value);
end;
function TID3v2Tag.GetLyrics(Language:string;Description:string): string;
begin
  result := GetDescribedTextFrame(IDv2_LYRICS,Language,Description);
end;
function TID3v2Tag.GetAllLyricsDescriptions: TFrameDescriptionArray;
begin
  result := GetAllFrameDescriptions(IDv2_LYRICS);
end;
procedure TID3v2Tag.DeleteLyrics(Language:string;Description:string);
begin
  DeleteDescribedTextFrame(IDv2_LYRICS, Language, Description);
end;


// ------------------------------------------
// Bild lesen
// WARNUNG: EVTL. wird in dem MP3File ein Unsynchronisations-Schema verwendet (laut id3.org nur bei MPEG 2 und 2.5)
// das wird hier ignoriert!
// Dies kann beim lesen zu JPEG-Fehlern führen,
// und beim Schreiben zu Problemen mit anderen Taggern!
// ------------------------------------------
procedure TID3v2Tag.GetPicture(stream: TStream; Description:TPictureFrameDesription);
var IDX: integer;
  StartPictureIDX: integer;
  mime: string;
begin
  // Frame Index herausbekommen
  IDX := GetFrameIndex(Description);
  mime := GetMimeType(FFrames[IDX]);

  // Beginn desBilddatenTeils berechnen
  StartPictureIDX := 2; //TextEncoding + ImageTyp
  case Version.Major of
    2:    StartPictureIDX := StartPictureIDX + 3
    else  StartPictureIDX := StartPictureIDX + length(mime) + 1;
  end;
  case FFrames[IDX].Data[0] of
    0: StartPictureIDX := StartPictureIDX + length(description.Description) + 1; //Description + 1 Termination-Byte
    1: StartPictureIDX := StartPictureIDX + (2*length(description.Description)) + 4; // 2 Bytes pro Zeichen, 2 Bytes Terminierung, 2 Byte BOM
    2: StartPictureIDX := StartPictureIDX + (2*length(description.Description)) + 2; // 2 Bytes pro Zeichen, 2 Bytes Terminierung, kein BOM
    3: StartPictureIDX := StartPictureIDX + length(description.Description) + 1; //Description + 1 Termination-Byte
  end;
  if IDX > -1 then
    stream.WriteBuffer(FFrames[IDX].Data[StartPictureIDX], length(FFRames[IDX].Data) - StartPictureIDX );
end;
// ------------------------------------------
// Bild schreiben
// ------------------------------------------
{   Aufbau eines PICTURE-FRAMES:

    Version 2:
      Frame ID:      P I C    (3 Bytes)
      Grösse:        xx xx xx (3 Bytes)

     Textencoding:   xx (00)
     IMageFormat:    xx xx xx  (JPG)
     Bildtyp:        xx
     Description     <Description> 00
     Data            <Stream>

    Version 3 / 4:
     Frame ID:       A P I C     (4 Bytes)
     Größe:          xx xx xx xx (4 Bytes)
     Flags:          xx xx       (2 Bytes)

     Textencoding:   xx (00)
     MIME Type       <Typ>  00    (\image\jpeg) oder so
     Bildtyp:        xx
     Description     <Description> 00
     Data            <Stream>
}
procedure TID3v2Tag.SetPicture(stream: TStream; Description:TPictureFrameDesription);
var IDX: integer;
  mime: string;
begin
  // Frame Index herausbekommen
  IDX := GetFrameIndex(Description);
  if IDX = -1 then
  begin
    SetLength(FFrames, Length(FFrames)+1);
    IDX := Length(FFrames)-1;
  end;

  case Version.Major of
    2: begin
      setlength(FFrames[IDX].Data, 1 + 3 + 1 + length(description.Description) + 1 + stream.size);
      FFrames[IDX].Data[0] := 0; // Textencoding        // [0]
      mime := 'JPG';
      move(mime[1], FFrames[IDX].Data[1], length(mime)); // [1] [2] [3]
      FFrames[IDX].Data[4] := Description.Bildtyp;      // [4]
      move(Description.description[1], FFrames[IDX].Data[5], length(Description.Description));
      FFrames[IDX].Data[5 + length(description.Description) ] := 0; // Terminate Description
      stream.Seek(0, soFromBeginning);
      stream.Read(FFrames[IDX].Data[5 + length(description.Description) + 1], Stream.Size);
      setlength(FFrames[IDX].Header,6);
      FFrames[IDX].FFrameID := KnownID3v2_2_IDs[IDv2_PICTURE];
      move(FFrames[IDX].FFrameID[1], FFrames[IDX].Header[0], length(FFrames[IDX].FFrameID));
      FFrames[IDX].FSize := length(FFrames[IDX].Data);
      UpdateHeader(Version.Major,FFrames[IDX].Header,FFrames[IDX].FSize);
    end;
    3,4:begin
      setlength(FFrames[IDX].Data, 1 + 11 + 1 + length(description.Description) + 1 + stream.size);
      FFrames[IDX].Data[0] := 0; // Textencoding        // [0]
      mime := 'image/jpeg'; // Länge: 10, +1 Terminate => 11 in der Länge oben
      move(mime[1], FFrames[IDX].Data[1], length(mime)); // [1] [2] [3]...
      FFrames[IDX].Data[length(mime)+1] := 0; // Terminate-Mime
      FFrames[IDX].Data[length(mime)+2] := Description.Bildtyp;
      move(Description.description[1], FFrames[IDX].Data[length(mime)+3], length(Description.Description));

      FFrames[IDX].Data[length(mime) + 3 + length(description.Description) ] := 0; // Terminate Description
      stream.Seek(0, soFromBeginning);
      stream.Read(FFrames[IDX].Data[length(mime) + 3 + length(description.Description) + 1], Stream.Size);
      setlength(FFrames[IDX].Header,10);
      FFrames[IDX].FFrameID := KnownID3v2_3_IDs[IDv2_PICTURE];
      move(FFrames[IDX].FFrameID[1], FFrames[IDX].Header[0], length(FFrames[IDX].FFrameID));
      FFrames[IDX].FSize := length(FFrames[IDX].Data);
      UpdateHeader(Version.Major,FFrames[IDX].Header,FFrames[IDX].FSize);
    end;
  end;
end;

procedure TID3v2Tag.DeletePicture(Description:TPictureFrameDesription);
var idx,i: integer;
  idstr,mime: string;
  tmpdescription: TPictureFrameDesription;
begin
  // Frame Index herausbekommen
  IDX := GetFrameIndex(Description);
  if IDX > -1 then
  begin
    for i:=IDX to length(FFrames)-2 do
      FFrames[i] := FFrames[i+1];
    Setlength(FFrames, length(FFrames)-1);
  end;
end;



// ------------------------------------------
// Set-Funktionen der Standard-Eigenschaften
// ------------------------------------------
procedure TID3v2Tag.SetTitle(Value: String);
begin
  SetTextFrame(IDv2_TITEL, Value);
end;
procedure TID3v2Tag.SetArtist(Value: String);
begin
  SetTextFrame(IDv2_ARTIST, Value);
end;
procedure TID3v2Tag.SetAlbum(Value: String);
begin
  SetTextFrame(IDv2_ALBUM, Value);
end;
function TID3v2Tag.BuildID3v2Genre(value:string):string;
begin
  // Baue einen String der Form "(<Index>)<Name>"
  if Genres.IndexOf(value) > -1 then
    result := '(' + inttostr(Genres.IndexOf(value)) + ')' + value
  else
    result := value;
end;
procedure TID3v2Tag.SetGenre(Value: String);
begin
  SetTextFrame(IDv2_GENRE, BuildID3v2Genre(Value));
end;
procedure TID3v2Tag.SetYear(Value: String);
var temp:integer;
begin
  // Value Korrigieren
  temp := StrToIntDef(Trim(Value), 0);
  if  (temp > 0) and (temp < 10000) then
  begin
    // ensure that the string is always 4 characters long
    // by filling up the string with zeros
    Value := Trim(Value);
    Insert(StringOfChar('0', 4 - Length(Value)), Value, 1);
  end
  else
    Value := '';
  SetTextFrame(IDv2_YEAR, Value);
end;
procedure TID3v2Tag.SetTrack(Value: String);
begin
  SetTextFrame(IDv2_TRACK, Value);
end;
procedure TID3v2Tag.SetStandardComment(Value: String);
begin
  SetDescribedTextFrame(IDv2_COMMENT,'*','',value);
end;

procedure TID3v2Tag.SetComposer(Value: String);
begin
  SetTextFrame(IDv2_COMPOSER, value);
end;
procedure TID3v2Tag.SetOriginalArtist(Value: String);
begin
  SetTextFrame(IDv2_ORIGINALARTIST, value);
end;
procedure TID3v2Tag.SetCopyright(Value: String);
begin
  SetTextFrame(IDv2_COPYRIGHT, value);
end;
procedure TID3v2Tag.SetEncodedBy(Value: String);
begin
  SetTextFrame(IDv2_ENCODEDBY, value);
end;
procedure TID3v2Tag.SetLanguages(Value: String);
begin
  SetTextFrame(IDv2_LANGUAGES, value);
end;
procedure TID3v2Tag.SetSoftwareSettings(Value: String);
begin
  SetTextFrame(IDv2_SOFTWARESETTINGS, value);
end;
procedure TID3v2Tag.SetMediatype(Value: String);
begin
  SetTextFrame(IDv2_MEDIATYPE, value);
end;

procedure TID3v2Tag.Setid3Length(Value: String);
begin
  SetTextFrame(Idv2_LENGTH, value);
end;
procedure TID3v2Tag.SetPublisher(Value: String);
begin
  SetTextFrame(Idv2_PUBLISHER, value);
end;
procedure TID3v2Tag.SetOriginalFilename(Value: String);
begin
  SetTextFrame(Idv2_ORIGINALFILENAME, value);
end;
procedure TID3v2Tag.SetOriginalLyricist(Value: String);
begin
  SetTextFrame(Idv2_ORIGINALLYRICIST, value);
end;
procedure TID3v2Tag.SetOriginalReleaseYear(Value: String);
begin
  SetTextFrame(Idv2_ORIGINALRELEASEYEAR, value);
end;
procedure TID3v2Tag.SetOriginalAlbumTitel(Value: String);
begin
  SetTextFrame(Idv2_ORIGINALALBUMTITEL, value);
end;


// ------------------------------------------
// Get-Funktionen der Standard-Eigenschaften
// ------------------------------------------
function TID3v2Tag.GetTitle:String;
begin
  result := GetTextFrame(IDv2_TITEL);
end;
function TID3v2Tag.GetArtist:String;
begin
  result := GetTextFrame(IDv2_ARTIST);
end;
function TID3v2Tag.GetAlbum:String;
begin
  result := GetTextFrame(IDv2_ALBUM);
end;
function TID3v2Tag.ParseID3v2Genre(value:string):string;
var posauf, poszu: integer;
  GenreID:Byte;
begin
  //Erwartete Formate des Genrestrings im ID3v2Tag:
  // (a): (nr), wobei nr. die v1-ID ist, oder sein sollte
  // (b): (nr)BEZEICHNUNG, wobei "Bezeichnung" zusätzlich die entsprechende Benennung zur ID sein sollte
  // (c): BEZEICHNUNG, die dann in dem Array genres[] gesucht werden sollte.}
  // Default
  result := value;
  // Fall a, b: Klammern vorhanden
  posauf := pos('(',value);
  poszu := pos(')',value);
  if posauf<poszu then
  begin
    GenreID := StrTointDef(copy(value,posauf+1, poszu-posauf-1),255);
    if GenreID < 126 then
      result := Genres[GenreID];
  end;
end;
function TID3v2Tag.GetGenre:String;
begin
  result := ParseID3v2Genre(GetTextFrame(IDv2_GENRE));
end;
function TID3v2Tag.GetYear:String;
begin
  result := GetTextFrame(IDv2_YEAR);
end;
function TID3v2Tag.GetTrack:String;
begin
  result := GetTextFrame(IDv2_TRACK);
end;
function TID3v2Tag.GetStandardComment: String;
begin
  result := GetDescribedTextFrame(IDv2_COMMENT,'*','');
end;

function TID3v2Tag.GetComposer: String;
begin
  result := GetTextFrame(IDv2_COMPOSER);
end;
function TID3v2Tag.GetOriginalArtist: String;
begin
  result := GetTextFrame(IDv2_ORIGINALARTIST);
end;
function TID3v2Tag.GetCopyright: String;
begin
  result := GetTextFrame(IDv2_COPYRIGHT);
end;
function TID3v2Tag.GetEncodedBy: String;
begin
  result := GetTextFrame(IDv2_ENCODEDBY);
end;
function TID3v2Tag.GetLanguages: String;
begin
  result := GetTextFrame(IDv2_LANGUAGES);
end;
function TID3v2Tag.GetSoftwareSettings: String;
begin
  result := GetTextFrame(IDv2_SOFTWARESETTINGS);
end;
function TID3v2Tag.GetMediatype: String;
begin
  result := GetTextFrame(IDv2_MEDIATYPE);
end;

function TID3v2Tag.Getid3Length: String;
begin
  result := GetTextFrame(IDv2_LENGTH);
end;
function TID3v2Tag.GetPublisher: String;
begin
  result := GetTextFrame(IDv2_PUBLISHER);
end;
function TID3v2Tag.GetOriginalFilename: String;
begin
  result := GetTextFrame(IDv2_ORIGINALFILENAME);
end;
function TID3v2Tag.GetOriginalLyricist: String;
begin
  result := GetTextFrame(IDv2_ORIGINALLYRICIST);
end;
function TID3v2Tag.GetOriginalReleaseYear: String;
begin
  result := GetTextFrame(IDv2_ORIGINALRELEASEYEAR);
end;
function TID3v2Tag.GetOriginalAlbumTitel: String;
begin
  result := GetTextFrame(IDv2_ORIGINALALBUMTITEL);
end;




//------------------------------------------------------
//------------------------------------------------------
//          *** mpeg ***
//------------------------------------------------------
//------------------------------------------------------


constructor TMpegInfo.create;
begin
  inherited create;
end;

//------------------------------------------------------
// Liefert die MPEG-Informationen aus einem Stream
//------------------------------------------------------
function TMpegInfo.LoadFromStream(stream: tStream): TMP3Error;
var buffer: TBuffer;
  erfolg: boolean;
  positionInStream: int64;  // position in der Datei/Stream
  max: int64;
  c,bufferpos: integer;
  tmpMpegHeader, tmp2MpegHeader: TMpegHeader;
  tmpXingHeader: tXingHeader;
  // evtl. nur den Header in ein "kleines" Array schreiben
  smallBuffer1, smallBuffer2: TBuffer;
  blocksize: integer;
begin
  // hier erstmal negativ anfangen.
  // Wird ein frame gefunden, dann wird das Ergebnis auf MP3ERR_None gesetzt
  result := MPEGERR_NoFrame;

  Fvalid := False;
  FfirstHeaderPosition := -1;
  blocksize := 512;
  // Gesamtposition im Stream -- gibt am Ende die Position des ersten Mpeg-Headers an.
  positionInStream := Stream.Position-1 ;
  // position im Buffer-Array
  bufferpos := -1 ;

  setlength(buffer, blocksize);
  c := Stream.Read(buffer[0], length(buffer));
  if c<blocksize then Setlength(Buffer, c);
  max := Stream.Size;
  erfolg :=False;

  FFilesize := max;

  while ( (NOT erfolg) AND (positionInStream + 3 < max ) )
  do begin
    inc(bufferpos);
    inc(positionInStream);
    // damit ist sind wir beim ersten durchlauf an Position 0 im BufferArray;

    // beim nächsten Durchlauf der Schleife sind wir evtl. übers Ende des Buffers hinaus
    // Wir lesen ja jeweils im Laufe der Prozedur 4 Byte Daten ein, also pos,pos+1,pos+2,pos+3
    if (bufferpos+3) = (length(buffer)-1) then
    begin
      //stream.Seek(-4, soFromCurrent);
      Stream.Position := PositionInStream;
      c := Stream.Read(buffer[0], length(buffer));
      if c<blocksize then
        Setlength(Buffer, c);
      bufferpos := 0;
    end;

    tmpXingHeader.valid := False;

    // Schritt 1: Test, ob hier ein Mpeg-Header beginnt.
    // ---------------------------------------------------------------------------
    tmpMpegHeader := GetValidatedHeader(Buffer, bufferpos);
    if not tmpMpegHeader.valid then continue;

    // Nächster Schritt 2: Test auf XingHeader
    // ---------------------------------------------------------------------------
    // dazu: evtl. Daten in einen Puffer laden, falls der Frame des
    //       gefundenen Headers nicht mehr komplett im Buffer entahlten ist.
    //      (ich lade ggf. direkt den nächsten Header mit)
    if (bufferpos + tmpMpegHeader.framelength + 3 > length(buffer)-1)  // nächster Header nicht mehr im Buffer
       AND
       (positionInStream + tmpMpegHeader.framelength + 3 < max) // aber noch im Stream
       then
    begin
      // StreamPostition setzen auf den Beginn des aktuellen Headers
      Stream.Position := PositionInStream;
      setlength(smallBuffer1,tmpMpegHeader.framelength + 4);
      // Daten in Buffer lesen
      Stream.Read(smallBuffer1[0],length(smallBuffer1));
      // XingHeader und nächsten MPEG HEader überprüfen
      try
        tmpXingHeader := GetXingHeader(tmpMpegheader, smallbuffer1, 0);        // !!!!!????!!!!!!!!!
        tmp2MpegHeader := GetValidatedHeader(smallBuffer1, tmpMpegHeader.framelength );
      except
        tmp2MpegHeader.valid := false;
      end;
      Stream.Position := PositionInStream;
    end else
    begin
      if (positionInStream + tmpMpegHeader.framelength + 3 > max) then
      begin
        continue;
      end;
      // XingHeader und nächsten MpegHeader aus Buffer lesen
      tmpXingHeader := GetXingHeader(tmpMpegheader, buffer, bufferpos );         // !!!!!!?????!!!!!!!!
      tmp2MpegHeader := GetValidatedHeader(buffer, bufferpos + tmpMpegHeader.framelength);
    end;
    // wenn der neue Header nicht gültig ist: Abbruch
    if not tmp2MpegHeader.valid then continue;

    // 3. Schritt: Einen dritten MpegHeader suchen
    // ---------------------------------------------------------------------------
    // dazu: wieder ggf. nachladen                                          // + 3: Darauf wird zugegriffen!
    if (bufferpos + tmpMpegHeader.framelength + tmp2MpegHeader.framelength + 3 > length(buffer)-1)  // nächster Header nicht mehr im Buffer
       AND
       (positionInStream + tmpMpegHeader.framelength + tmp2MpegHeader.framelength + 3 < max) // aber noch im Stream
    then // nachladen
    begin
      // StreamPostition setzen auf den Beginn des aktuellen Headers                 // !!!!!!!!??????!!!!!!
      Stream.Position := PositionInStream + tmpMpegHeader.framelength + tmp2MpegHeader.framelength;
      setlength(smallBuffer2,4);
      // Daten in Buffer lesen
      Stream.Read(smallBuffer2[0],length(smallBuffer2));
      Stream.Position := PositionInStream;
      if (smallbuffer2[0]<>$FF) OR (smallbuffer2[1]<$E0) then continue;
    end
    else
    begin
      if (positionInStream + tmpMpegHeader.framelength + tmp2MpegHeader.framelength + 3 > max)
      then continue;

      if (buffer[bufferpos + tmpMpegHeader.framelength + tmp2MpegHeader.framelength] <> $FF)
      OR (buffer[bufferpos + tmpMpegHeader.framelength + tmp2MpegHeader.framelength+1] < $E0)
      then continue;
    end;


    // 4. Schritt: Bis hier durchgekommen? - Daten setzen!
    // ---------------------------------------------------------------------------
    Fversion := tmpMpegHeader.version;
    Flayer := tmpMpegHeader.layer;
    Fprotection := tmpMpegHeader.protection;
    Fsamplerate := tmpMpegHeader.samplerate;
    Fchannelmode := tmpMpegHeader.channelmode;
    Fextension := tmpMpegHeader.extension;
    Fcopyright := tmpMpegHeader.copyright;
    Foriginal := tmpMpegHeader.original;
    Femphasis := tmpMpegHeader.emphasis;

    // Hinweis zu dem " - PositionInStream"
    // Was am Anfang des mp3Files nicht als AudioFrame erkannt wurde
    // (z.B. ID3v2Tag), darf nicht in die Längenberechnung eingehen
    // eigentlich müsste man ggf. Auf den ID3v1 Tag abziehen,
    // aber das dürfte nur sehr selten einen Unterschied machen (max. +/- 1 Frame)
    if tmpXingHeader.valid then
      try
        Fbitrate := trunc((tmpMpegheader.samplerate/1000 *
          (max - PositionInStream - tmpXingHeader.Size))  /   (tmpXingHeader.frames*144));
        Fvbr := True;
        Fdauer := ((max-PositionInStream-tmpXingHeader.Size)*8) div ((Fbitrate)*1000);
        FFrames := tmpXingHeader.Frames;
      except
        continue;
      end
    else
      try
        Fframes := trunc((max - PositionInStream)/tmpMpegheader.framelength);
        FBitrate := tmpMpegHeader.bitrate;
        Fvbr := False;
        Fdauer := ((max - PositionInStream)*8) div ((Fbitrate)*1000);
      except
        continue;
      end;

    Fvalid := True;
    FfirstHeaderPosition := PositionInStream;
    result := MP3ERR_None;
    erfolg := True;
  end;
end;

function TMpegInfo.LoadFromFile(filename: string): TMP3Error;
var Stream: TFileStream;
begin
  result := MP3ERR_None;
  if FileExists(Filename) then
    try
      stream := TFileStream.Create(filename, fmOpenRead or fmShareDenyWrite);
      try
        result := LoadFromStream(Stream);
      finally
        Stream.Free;
      end;
    except
      result := MP3ERR_FOpenR;
    end
  else
    result := MP3ERR_NoFile;
end;

//------------------------------------------------------
// Überprüft, ob an Postion von aBuffer ein gültiger MpegHeader steht
// und liefert diesen zurück
// Eigenschaft .valid ist dabei entscheidend !!!
//------------------------------------------------------
function TMpegInfo.GetValidatedHeader(aBuffer: TBuffer; position: integer): TMpegheader;
var bitrateindex, versionindex: byte;
    samplerateindex:byte;
begin
  // Ein MpegHeader beginnt mit 11 gesetzen Bytes
  if (abuffer[position]<>$FF) OR (abuffer[position+1]<$E0)
  then
  begin
    result.valid := False;
    exit;
  end;

  //Byte 1 und 2: AAAAAAAA AAABBCCD
  //A=1 (11 Sync bytes) am Anfang
  //B: Version, bei Standard-mp3 (=MPEG1, Layer3) sollte BB=11 sein
  //C: Layer, III ist CC=01
  //D: Protection BIT wenn gesetzt, folgt dem mpeg-header 16bit CRC
  Versionindex := (abuffer[position+1] shr 3) and 3;
  case versionindex of
      0: result.version := 3; //eigentlich ist das Version 2.5 aber wegen dem Array-Index...
      1: result.version := 0; //Reserved
      2: result.version := 2;
      3: result.version := 1;
  end;
  result.Layer := 4-((abuffer[position+1] shr 1) and 3);
  result.protection := (abuffer[position+1] AND 1)=0;

  // Byte 3: EEEEFFGH
  // E: Bitrate-Index
  // F: Samplerate-Index
  // G: Padding Bit
  // H: Private Bit
  bitrateindex := (abuffer[position+2] shr 4) AND $F;
  result.bitrate := MPEG_BIT_RATES[result.version][result.layer][bitrateindex];
  if bitrateindex=$F then
  begin
    result.valid := false; // Bad Value !
    exit;
  end;
  samplerateindex := (abuffer[position+2] shr 2) AND $3;
  result.samplerate := sample_rates[result.version][samplerateindex];
  result.padding := ((abuffer[position+2] shr 1) AND $1) = 1;

  // Byte 4: IIJJKLMM
  // I: Channel mode
  // J: Mode extension (for Joint Stereo)
  // K: copyright
  // L: original
  // M: Emphasis  meistens =0
  result.channelmode := ((abuffer[position+3] shr 6) AND 3);
  result.extension := ((abuffer[position+3] shr 4) AND 3);
  result.copyright := ((abuffer[position+3] shr 3) AND 1)=1;
  result.original := ((abuffer[position+3] shr 2) AND 1)=1;
  result.emphasis := (abuffer[position+3] AND 3);

  // "For Layer II there are some combinations of bitrate and mode which are not allowed."
  if result.layer=2 then
      if ((result.bitrate=32) AND (result.channelmode<>3))
          OR ((result.bitrate=48) AND (result.channelmode<>3))
          OR ((result.bitrate=56) AND (result.channelmode<>3))
          OR ((result.bitrate=80) AND (result.channelmode<>3))
          OR ((result.bitrate=224) AND (result.channelmode=3))
          OR ((result.bitrate=256) AND (result.channelmode=3))
          OR ((result.bitrate=320) AND (result.channelmode=3))
          OR ((result.bitrate=384) AND (result.channelmode=3))
      then begin
        result.valid := false;
        exit;
      end;

  // aus gewonnenen Daten die Framelength des dahinterliegenden Frames bestimmen
  result.framelength := GetFramelength(result.version, result.layer,
                              result.bitrate,
                              result.Samplerate,
                              result.padding);
  if result.framelength<=0 then
  begin
    result.valid := false;
    exit;
  end;
  // Erfolg!!
  result.valid := True;
end;

//------------------------------------------------------
// Überprüft, ob an Postion von aBuffer ein gültiger XingHeader steht
// und liefert diesen zurück
// Eigenschaft .valid ist dabei entscheidend !!!
//------------------------------------------------------
function TMpegInfo.GetXingHeader(aMpegheader: TMpegHeader; aBuffer: TBuffer; position: integer ): TXingHeader;
var Xing_offset: integer;
  Xing_Flags: byte;
begin
  if aMpegheader.version=1 then
    if aMpegheader.channelmode<>3 then
      xing_offset := 32+4
    else
      xing_offset := 17+4
  else
    if aMpegheader.channelmode<>3 then
      xing_offset := 17+4
    else
      xing_offset := 9+4;
  if (abuffer[position+xing_offset]=$58)        {'Xing'}
     AND (abuffer[position+xing_offset+1]=$69)
     AND (abuffer[position+xing_offset+2]=$6E)
     AND (abuffer[position+xing_offset+3]=$67)
     then // Xing Tag vorhanden
  begin
          // Die nächsten 4 Bytes sind die "Flags", wobei eigentlich nur das 4te interessant ist
          Xing_flags := abuffer[position+xing_offset+7];
          if (Xing_flags AND 1)=1 then
          begin //Anzahl der frames in den nächsten 4 Bytes gespeichert
              result.frames := 16777216 * abuffer[position+xing_offset+8]
                  + 65536 * abuffer[position+xing_offset+9]
                  + 256 * abuffer[position+xing_offset+10]
                  + abuffer[position+xing_offset+11];
          end
          else
            result.frames := 0;
          // Warnung: evtl. liegt hier eine Fehlerquelle:
          //      Wenn der Xing header so fehlerhaft ist,
          //      werden weitrere Berechnungen aufgrund des ersten vbr-Frames erstellt!
          result.Size := aMpegHeader.framelength;
          result.valid := True;
  end else
    result.valid := False;
end;

function TMpegInfo.GetFramelength(version:byte;layer:byte;bitrate:longint;Samplerate:longint;padding:boolean):integer;
begin
  if samplerate=0 then result := -2
  else
    if Layer=1 then
      result := trunc(12*bitrate*1000 / samplerate+Integer(padding)*4)
    else
      if Version = 1 then
        result :=  144 * bitrate * 1000 DIV samplerate + integer(padding)
      else
        result := 72 * bitrate * 1000 DIV samplerate + integer(padding)

end;

//
//
//
//
//
//
//
//
//
//
//
//
//
//

initialization

  Genres := TStringList.Create;
  Genres.CaseSensitive := False;
  // Genres defined by ID3v1 standard
  Genres.Add('Blues');
  Genres.Add('Classic Rock');
  Genres.Add('Country');
  Genres.Add('Dance');
  Genres.Add('Disco');
  Genres.Add('Funk');
  Genres.Add('Grunge');
  Genres.Add('Hip-Hop');
  Genres.Add('Jazz');
  Genres.Add('Metal');
  Genres.Add('New Age');
  Genres.Add('Oldies');
  Genres.Add('Other');
  Genres.Add('Pop');
  Genres.Add('R&B');
  Genres.Add('Rap');
  Genres.Add('Reggae');
  Genres.Add('Rock');
  Genres.Add('Techno');
  Genres.Add('Industrial');
  Genres.Add('Alternative');
  Genres.Add('Ska');
  Genres.Add('Death Metal');
  Genres.Add('Pranks');
  Genres.Add('Soundtrack');
  Genres.Add('Euro-Techno');
  Genres.Add('Ambient');
  Genres.Add('Trip-Hop');
  Genres.Add('Vocal');
  Genres.Add('Jazz+Funk');
  Genres.Add('Fusion');
  Genres.Add('Trance');
  Genres.Add('Classical');
  Genres.Add('Instrumental');
  Genres.Add('Acid');
  Genres.Add('House');
  Genres.Add('Game');
  Genres.Add('Sound Clip');
  Genres.Add('Gospel');
  Genres.Add('Noise');
  Genres.Add('AlternRock');
  Genres.Add('Bass');
  Genres.Add('Soul');
  Genres.Add('Punk');
  Genres.Add('Space');
  Genres.Add('Meditative');
  Genres.Add('Instrumental Pop');
  Genres.Add('Instrumental Rock');
  Genres.Add('Ethnic');
  Genres.Add('Gothic');
  Genres.Add('Darkwave');
  Genres.Add('Techno-Industrial');
  Genres.Add('Electronic');
  Genres.Add('Pop-Folk');
  Genres.Add('Eurodance');
  Genres.Add('Dream');
  Genres.Add('Southern Rock');
  Genres.Add('Comedy');
  Genres.Add('Cult');
  Genres.Add('Gangsta');
  Genres.Add('Top 40');
  Genres.Add('Christian Rap');
  Genres.Add('Pop/Funk');
  Genres.Add('Jungle');
  Genres.Add('Native American');
  Genres.Add('Cabaret');
  Genres.Add('New Wave');
  Genres.Add('Psychadelic');
  Genres.Add('Rave');
  Genres.Add('Showtunes');
  Genres.Add('Trailer');
  Genres.Add('Lo-Fi');
  Genres.Add('Tribal');
  Genres.Add('Acid Punk');
  Genres.Add('Acid Jazz');
  Genres.Add('Polka');
  Genres.Add('Retro');
  Genres.Add('Musical');
  Genres.Add('Rock & Roll');
  Genres.Add('Hard Rock');

  // Extended WinAmp-genres
  Genres.Add('Folk');
  Genres.Add('Folk-Rock');
  Genres.Add('National Folk');
  Genres.Add('Swing');
  Genres.Add('Fast Fusion');
  Genres.Add('Bebob');
  Genres.Add('Latin');
  Genres.Add('Revival');
  Genres.Add('Celtic');
  Genres.Add('Bluegrass');
  Genres.Add('Avantgarde');
  Genres.Add('Gothic Rock');
  Genres.Add('Progessive Rock');
  Genres.Add('Psychedelic Rock');
  Genres.Add('Symphonic Rock');
  Genres.Add('Slow Rock');
  Genres.Add('Big Band');
  Genres.Add('Chorus');
  Genres.Add('Easy Listening');
  Genres.Add('Acoustic');
  Genres.Add('Humour');
  Genres.Add('Speech');
  Genres.Add('Chanson');
  Genres.Add('Opera');
  Genres.Add('Chamber Music');
  Genres.Add('Sonata');
  Genres.Add('Symphony');
  Genres.Add('Booty Bass');
  Genres.Add('Primus');
  Genres.Add('Porn Groove');
  Genres.Add('Satire');
  Genres.Add('Slow Jam');
  Genres.Add('Club');
  Genres.Add('Tango');
  Genres.Add('Samba');
  Genres.Add('Folklore');
  Genres.Add('Ballad');
  Genres.Add('Power Ballad');
  Genres.Add('Rhythmic Soul');
  Genres.Add('Freestyle');
  Genres.Add('Duet');
  Genres.Add('Punk Rock');
  Genres.Add('Drum Solo');
  Genres.Add('A capella');
  Genres.Add('Euro-House');
  Genres.Add('Dance Hall');

  // Quelle für die Sprachcodes und Namen:
  // http://www.id3.org/iso639-2.html
  LanguageCodes := TStringList.Create;
  LanguageNames := TStringList.Create;
  LanguageCodes.CaseSensitive := False;
  LanguageNames.CaseSensitive := False;
  LanguageCodes.Add('aar');  LanguageNames.Add('Afar');
  LanguageCodes.Add('abk');  LanguageNames.Add('Abkhazian');
  LanguageCodes.Add('ace');  LanguageNames.Add('Achinese');
  LanguageCodes.Add('ach');  LanguageNames.Add('Acoli');
  LanguageCodes.Add('ada');  LanguageNames.Add('Adangme');
  LanguageCodes.Add('afa');  LanguageNames.Add('Afro-Asiatic (Other)');
  LanguageCodes.Add('afh');  LanguageNames.Add('Afrihili');
  LanguageCodes.Add('afr');  LanguageNames.Add('Afrikaans');
  LanguageCodes.Add('aka');  LanguageNames.Add('Akan');
  LanguageCodes.Add('akk');  LanguageNames.Add('Akkadian');
  LanguageCodes.Add('alb');  LanguageNames.Add('Albanian');
  LanguageCodes.Add('ale');  LanguageNames.Add('Aleut');
  LanguageCodes.Add('alg');  LanguageNames.Add('Algonquian Languages');
  LanguageCodes.Add('amh');  LanguageNames.Add('Amharic');
  LanguageCodes.Add('ang');  LanguageNames.Add('English, Old (ca. 450-1100)');
  LanguageCodes.Add('apa');  LanguageNames.Add('Apache Languages');
  LanguageCodes.Add('ara');  LanguageNames.Add('Arabic');
  LanguageCodes.Add('arc');  LanguageNames.Add('Aramaic');
  LanguageCodes.Add('arm');  LanguageNames.Add('Armenian');
  LanguageCodes.Add('arn');  LanguageNames.Add('Araucanian');
  LanguageCodes.Add('arp');  LanguageNames.Add('Arapaho');
  LanguageCodes.Add('art');  LanguageNames.Add('Artificial (Other)');
  LanguageCodes.Add('arw');  LanguageNames.Add('Arawak');
  LanguageCodes.Add('asm');  LanguageNames.Add('Assamese');
  LanguageCodes.Add('ath');  LanguageNames.Add('Athapascan Languages');
  LanguageCodes.Add('ava');  LanguageNames.Add('Avaric');
  LanguageCodes.Add('ave');  LanguageNames.Add('Avestan');
  LanguageCodes.Add('awa');  LanguageNames.Add('Awadhi');
  LanguageCodes.Add('aym');  LanguageNames.Add('Aymara');
  LanguageCodes.Add('aze');  LanguageNames.Add('Azerbaijani');
  LanguageCodes.Add('bad');  LanguageNames.Add('Banda');
  LanguageCodes.Add('bai');  LanguageNames.Add('Bamileke Languages');
  LanguageCodes.Add('bak');  LanguageNames.Add('Bashkir');
  LanguageCodes.Add('bal');  LanguageNames.Add('Baluchi');
  LanguageCodes.Add('bam');  LanguageNames.Add('Bambara');
  LanguageCodes.Add('ban');  LanguageNames.Add('Balinese');
  LanguageCodes.Add('baq');  LanguageNames.Add('Basque');
  LanguageCodes.Add('bas');  LanguageNames.Add('Basa');
  LanguageCodes.Add('bat');  LanguageNames.Add('Baltic (Other)');
  LanguageCodes.Add('bej');  LanguageNames.Add('Beja');
  LanguageCodes.Add('bel');  LanguageNames.Add('Byelorussian');
  LanguageCodes.Add('bem');  LanguageNames.Add('Bemba');
  LanguageCodes.Add('ben');  LanguageNames.Add('Bengali');
  LanguageCodes.Add('ber');  LanguageNames.Add('Berber (Other)');
  LanguageCodes.Add('bho');  LanguageNames.Add('Bhojpuri');
  LanguageCodes.Add('bih');  LanguageNames.Add('Bihari');
  LanguageCodes.Add('bik');  LanguageNames.Add('Bikol');
  LanguageCodes.Add('bin');  LanguageNames.Add('Bini');
  LanguageCodes.Add('bis');  LanguageNames.Add('Bislama');
  LanguageCodes.Add('bla');  LanguageNames.Add('Siksika');
  LanguageCodes.Add('bnt');  LanguageNames.Add('Bantu (Other)');
  LanguageCodes.Add('bod');  LanguageNames.Add('Tibetan');
  LanguageCodes.Add('bra');  LanguageNames.Add('Braj');
  LanguageCodes.Add('bre');  LanguageNames.Add('Breton');
  LanguageCodes.Add('bua');  LanguageNames.Add('Buriat');
  LanguageCodes.Add('bug');  LanguageNames.Add('Buginese');
  LanguageCodes.Add('bul');  LanguageNames.Add('Bulgarian	');
  LanguageCodes.Add('bur');  LanguageNames.Add('Burmese	');
  LanguageCodes.Add('cad');  LanguageNames.Add('Caddo');
  LanguageCodes.Add('cai');  LanguageNames.Add('Central American Indian (Other)');
  LanguageCodes.Add('car');  LanguageNames.Add('Carib');
  LanguageCodes.Add('cat');  LanguageNames.Add('Catalan	');
  LanguageCodes.Add('cau');  LanguageNames.Add('Caucasian (Other)');
  LanguageCodes.Add('ceb');  LanguageNames.Add('Cebuano');
  LanguageCodes.Add('cel');  LanguageNames.Add('Celtic (Other)');
  LanguageCodes.Add('ces');  LanguageNames.Add('Czech');
  LanguageCodes.Add('cha');  LanguageNames.Add('Chamorro');
  LanguageCodes.Add('chb');  LanguageNames.Add('Chibcha	');
  LanguageCodes.Add('che');  LanguageNames.Add('Chechen');
  LanguageCodes.Add('chg');  LanguageNames.Add('Chagatai');
  LanguageCodes.Add('chi');  LanguageNames.Add('Chinese');
  LanguageCodes.Add('chm');  LanguageNames.Add('Mari');
  LanguageCodes.Add('chn');  LanguageNames.Add('Chinook jargon');
  LanguageCodes.Add('cho');  LanguageNames.Add('Choctaw');
  LanguageCodes.Add('chr');  LanguageNames.Add('Cherokee');
  LanguageCodes.Add('chu');  LanguageNames.Add('Church Slavic');
  LanguageCodes.Add('chv');  LanguageNames.Add('Chuvash');
  LanguageCodes.Add('chy');  LanguageNames.Add('Cheyenne');
  LanguageCodes.Add('cop');  LanguageNames.Add('Coptic');
  LanguageCodes.Add('cor');  LanguageNames.Add('Cornish');
  LanguageCodes.Add('cos');  LanguageNames.Add('Corsican');
  LanguageCodes.Add('cpe');  LanguageNames.Add('Creoles and Pidgins, English-based (Other)');
  LanguageCodes.Add('cpf');  LanguageNames.Add('Creoles and Pidgins, French-based (Other)');
  LanguageCodes.Add('cpp');  LanguageNames.Add('Creoles and Pidgins, Portuguese-based (Other)');
  LanguageCodes.Add('cre');  LanguageNames.Add('Cree');
  LanguageCodes.Add('crp');  LanguageNames.Add('Creoles and Pidgins (Other)	');
  LanguageCodes.Add('cus');  LanguageNames.Add('Cushitic (Other)');
  LanguageCodes.Add('cym');  LanguageNames.Add('Welsh	');
  LanguageCodes.Add('cze');  LanguageNames.Add('Czech');
  LanguageCodes.Add('dak');  LanguageNames.Add('Dakota');
  LanguageCodes.Add('dan');  LanguageNames.Add('Danish');
  LanguageCodes.Add('del');  LanguageNames.Add('Delaware');
  LanguageCodes.Add('deu');  LanguageNames.Add('German');
  LanguageCodes.Add('din');  LanguageNames.Add('Dinka	');
  LanguageCodes.Add('div');  LanguageNames.Add('Divehi');
  LanguageCodes.Add('doi');  LanguageNames.Add('Dogri	');
  LanguageCodes.Add('dra');  LanguageNames.Add('Dravidian (Other)');
  LanguageCodes.Add('dua');  LanguageNames.Add('Duala');
  LanguageCodes.Add('dum');  LanguageNames.Add('Dutch, Middle (ca. 1050-1350)');
  LanguageCodes.Add('dut');  LanguageNames.Add('Dutch	');
  LanguageCodes.Add('dyu');  LanguageNames.Add('Dyula');
  LanguageCodes.Add('dzo');  LanguageNames.Add('Dzongkha');
  LanguageCodes.Add('efi');  LanguageNames.Add('Efik');
  LanguageCodes.Add('egy');  LanguageNames.Add('Egyptian (Ancient)');
  LanguageCodes.Add('eka');  LanguageNames.Add('Ekajuk');
  LanguageCodes.Add('ell');  LanguageNames.Add('Greek, Modern (1453-)');
  LanguageCodes.Add('elx');  LanguageNames.Add('Elamite');
  LanguageCodes.Add('eng');  LanguageNames.Add('English');
  LanguageCodes.Add('enm');  LanguageNames.Add('English, Middle (ca. 1100-1500)');
  LanguageCodes.Add('epo');  LanguageNames.Add('Esperanto	');
  LanguageCodes.Add('esk');  LanguageNames.Add('Eskimo (Other)');
  LanguageCodes.Add('esl');  LanguageNames.Add('Spanish');
  LanguageCodes.Add('est');  LanguageNames.Add('Estonian');
  LanguageCodes.Add('eus');  LanguageNames.Add('Basque');
  LanguageCodes.Add('ewe');  LanguageNames.Add('Ewe');
  LanguageCodes.Add('ewo');  LanguageNames.Add('Ewondo');
  LanguageCodes.Add('fan');  LanguageNames.Add('Fang');
  LanguageCodes.Add('fao');  LanguageNames.Add('Faroese');
  LanguageCodes.Add('fas');  LanguageNames.Add('Persian');
  LanguageCodes.Add('fat');  LanguageNames.Add('Fanti');
  LanguageCodes.Add('fij');  LanguageNames.Add('Fijian');
  LanguageCodes.Add('fin');  LanguageNames.Add('Finnish');
  LanguageCodes.Add('fiu');  LanguageNames.Add('Finno-Ugrian (Other)');
  LanguageCodes.Add('fon');  LanguageNames.Add('Fon');
  LanguageCodes.Add('fra');  LanguageNames.Add('French');
  LanguageCodes.Add('fre');  LanguageNames.Add('French');
  LanguageCodes.Add('frm');  LanguageNames.Add('French, Middle (ca. 1400-1600)');
  LanguageCodes.Add('fro');  LanguageNames.Add('French, Old (842- ca. 1400)');
  LanguageCodes.Add('fry');  LanguageNames.Add('Frisian');
  LanguageCodes.Add('ful');  LanguageNames.Add('Fulah');
  LanguageCodes.Add('gaa');  LanguageNames.Add('Ga');
  LanguageCodes.Add('gae');  LanguageNames.Add('Gaelic (Scots)');
  LanguageCodes.Add('gai');  LanguageNames.Add('Irish');
  LanguageCodes.Add('gay');  LanguageNames.Add('Gayo');
  LanguageCodes.Add('gdh');  LanguageNames.Add('Gaelic (Scots)');
  LanguageCodes.Add('gem');  LanguageNames.Add('Germanic (Other)');
  LanguageCodes.Add('geo');  LanguageNames.Add('Georgian');
  LanguageCodes.Add('ger');  LanguageNames.Add('German');
  LanguageCodes.Add('gez');  LanguageNames.Add('Geez');
  LanguageCodes.Add('gil');  LanguageNames.Add('Gilbertese');
  LanguageCodes.Add('glg');  LanguageNames.Add('Gallegan');
  LanguageCodes.Add('gmh');  LanguageNames.Add('German, Middle High (ca. 1050-1500)');
  LanguageCodes.Add('goh');  LanguageNames.Add('German, Old High (ca. 750-1050)');
  LanguageCodes.Add('gon');  LanguageNames.Add('Gondi');
  LanguageCodes.Add('got');  LanguageNames.Add('Gothic');
  LanguageCodes.Add('grb');  LanguageNames.Add('Grebo');
  LanguageCodes.Add('grc');  LanguageNames.Add('Greek, Ancient (to 1453)');
  LanguageCodes.Add('gre');  LanguageNames.Add('Greek, Modern (1453-)');
  LanguageCodes.Add('grn');  LanguageNames.Add('Guarani');
  LanguageCodes.Add('guj');  LanguageNames.Add('Gujarati');
  LanguageCodes.Add('hai');  LanguageNames.Add('Haida');
  LanguageCodes.Add('hau');  LanguageNames.Add('Hausa');
  LanguageCodes.Add('haw');  LanguageNames.Add('Hawaiian');
  LanguageCodes.Add('heb');  LanguageNames.Add('Hebrew');
  LanguageCodes.Add('her');  LanguageNames.Add('Herero');
  LanguageCodes.Add('hil');  LanguageNames.Add('Hiligaynon');
  LanguageCodes.Add('him');  LanguageNames.Add('Himachali');
  LanguageCodes.Add('hin');  LanguageNames.Add('Hindi');
  LanguageCodes.Add('hmo');  LanguageNames.Add('Hiri Motu');
  LanguageCodes.Add('hun');  LanguageNames.Add('Hungarian');
  LanguageCodes.Add('hup');  LanguageNames.Add('Hupa');
  LanguageCodes.Add('hye');  LanguageNames.Add('Armenian');
  LanguageCodes.Add('iba');  LanguageNames.Add('Iban');
  LanguageCodes.Add('ibo');  LanguageNames.Add('Igbo');
  LanguageCodes.Add('ice');  LanguageNames.Add('Icelandic');
  LanguageCodes.Add('ijo');  LanguageNames.Add('Ijo');
  LanguageCodes.Add('iku');  LanguageNames.Add('Inuktitut');
  LanguageCodes.Add('ilo');  LanguageNames.Add('Iloko');
  LanguageCodes.Add('ina');  LanguageNames.Add('Interlingua (International Auxiliary language Association)');
  LanguageCodes.Add('inc');  LanguageNames.Add('Indic (Other)');
  LanguageCodes.Add('ind');  LanguageNames.Add('Indonesian');
  LanguageCodes.Add('ine');  LanguageNames.Add('Indo-European (Other)');
  LanguageCodes.Add('ine');  LanguageNames.Add('Interlingue');
  LanguageCodes.Add('ipk');  LanguageNames.Add('Inupiak');
  LanguageCodes.Add('ira');  LanguageNames.Add('Iranian (Other)');
  LanguageCodes.Add('iri');  LanguageNames.Add('Irish');
  LanguageCodes.Add('iro');  LanguageNames.Add('Iroquoian uages');
  LanguageCodes.Add('isl');  LanguageNames.Add('Icelandic');
  LanguageCodes.Add('ita');  LanguageNames.Add('Italian');
  LanguageCodes.Add('jav');  LanguageNames.Add('Javanese');
  LanguageCodes.Add('jaw');  LanguageNames.Add('Javanese');
  LanguageCodes.Add('jpn');  LanguageNames.Add('Japanese');
  LanguageCodes.Add('jpr');  LanguageNames.Add('Judeo-Persian');
  LanguageCodes.Add('jrb');  LanguageNames.Add('Judeo-Arabic');
  LanguageCodes.Add('kaa');  LanguageNames.Add('Kara-Kalpak');
  LanguageCodes.Add('kab');  LanguageNames.Add('Kabyle');
  LanguageCodes.Add('kac');  LanguageNames.Add('Kachin');
  LanguageCodes.Add('kal');  LanguageNames.Add('Greenlandic');
  LanguageCodes.Add('kam');  LanguageNames.Add('Kamba');
  LanguageCodes.Add('kan');  LanguageNames.Add('Kannada');
  LanguageCodes.Add('kar');  LanguageNames.Add('Karen');
  LanguageCodes.Add('kas');  LanguageNames.Add('Kashmiri	');
  LanguageCodes.Add('kat');  LanguageNames.Add('Georgian');
  LanguageCodes.Add('kau');  LanguageNames.Add('Kanuri');
  LanguageCodes.Add('kaw');  LanguageNames.Add('Kawi');
  LanguageCodes.Add('kaz');  LanguageNames.Add('Kazakh');
  LanguageCodes.Add('kha');  LanguageNames.Add('Khasi');
  LanguageCodes.Add('khi');  LanguageNames.Add('Khoisan (Other)');
  LanguageCodes.Add('khm');  LanguageNames.Add('Khmer');
  LanguageCodes.Add('kho');  LanguageNames.Add('Khotanese');
  LanguageCodes.Add('kik');  LanguageNames.Add('Kikuyu');
  LanguageCodes.Add('kin');  LanguageNames.Add('Kinyarwanda');
  LanguageCodes.Add('kir');  LanguageNames.Add('Kirghiz');
  LanguageCodes.Add('kok');  LanguageNames.Add('Konkani');
  LanguageCodes.Add('kom');  LanguageNames.Add('Komi');
  LanguageCodes.Add('kon');  LanguageNames.Add('Kongo');
  LanguageCodes.Add('kor');  LanguageNames.Add('Korean');
  LanguageCodes.Add('kpe');  LanguageNames.Add('Kpelle');
  LanguageCodes.Add('kro');  LanguageNames.Add('Kru');
  LanguageCodes.Add('kru');  LanguageNames.Add('Kurukh');
  LanguageCodes.Add('kua');  LanguageNames.Add('Kuanyama');
  LanguageCodes.Add('kum');  LanguageNames.Add('Kumyk');
  LanguageCodes.Add('kur');  LanguageNames.Add('Kurdish');
  LanguageCodes.Add('kus');  LanguageNames.Add('Kusaie');
  LanguageCodes.Add('kut');  LanguageNames.Add('Kutenai');
  LanguageCodes.Add('lad');  LanguageNames.Add('Ladino');
  LanguageCodes.Add('lah');  LanguageNames.Add('Lahnda');
  LanguageCodes.Add('lam');  LanguageNames.Add('Lamba');
  LanguageCodes.Add('lao');  LanguageNames.Add('Lao');
  LanguageCodes.Add('lat');  LanguageNames.Add('Latin');
  LanguageCodes.Add('lav');  LanguageNames.Add('Latvian');
  LanguageCodes.Add('lez');  LanguageNames.Add('Lezghian');
  LanguageCodes.Add('lin');  LanguageNames.Add('Lingala');
  LanguageCodes.Add('lit');  LanguageNames.Add('Lithuanian');
  LanguageCodes.Add('lol');  LanguageNames.Add('Mongo');
  LanguageCodes.Add('loz');  LanguageNames.Add('Lozi');
  LanguageCodes.Add('ltz');  LanguageNames.Add('Letzeburgesch');
  LanguageCodes.Add('lub');  LanguageNames.Add('Luba-Katanga');
  LanguageCodes.Add('lug');  LanguageNames.Add('Ganda');
  LanguageCodes.Add('lui');  LanguageNames.Add('Luiseno');
  LanguageCodes.Add('lun');  LanguageNames.Add('Lunda');
  LanguageCodes.Add('luo');  LanguageNames.Add('Luo (Kenya and Tanzania)');
  LanguageCodes.Add('mac');  LanguageNames.Add('Macedonian');
  LanguageCodes.Add('mad');  LanguageNames.Add('Madurese');
  LanguageCodes.Add('mag');  LanguageNames.Add('Magahi');
  LanguageCodes.Add('mah');  LanguageNames.Add('Marshall');
  LanguageCodes.Add('mai');  LanguageNames.Add('Maithili');
  LanguageCodes.Add('mak');  LanguageNames.Add('Macedonian');
  LanguageCodes.Add('mak');  LanguageNames.Add('Makasar');
  LanguageCodes.Add('mal');  LanguageNames.Add('Malayalam	');
  LanguageCodes.Add('man');  LanguageNames.Add('Mandingo');
  LanguageCodes.Add('mao');  LanguageNames.Add('Maori');
  LanguageCodes.Add('map');  LanguageNames.Add('Austronesian (Other)');
  LanguageCodes.Add('mar');  LanguageNames.Add('Marathi');
  LanguageCodes.Add('mas');  LanguageNames.Add('Masai');
  LanguageCodes.Add('max');  LanguageNames.Add('Manx');
  LanguageCodes.Add('may');  LanguageNames.Add('Malay');
  LanguageCodes.Add('men');  LanguageNames.Add('Mende');
  LanguageCodes.Add('mga');  LanguageNames.Add('Irish, Middle (900 - 1200)');
  LanguageCodes.Add('mic');  LanguageNames.Add('Micmac');
  LanguageCodes.Add('min');  LanguageNames.Add('Minangkabau');
  LanguageCodes.Add('mis');  LanguageNames.Add('Miscellaneous (Other)');
  LanguageCodes.Add('mkh');  LanguageNames.Add('Mon-Kmer (Other)');
  LanguageCodes.Add('mlg');  LanguageNames.Add('Malagasy');
  LanguageCodes.Add('mlt');  LanguageNames.Add('Maltese');
  LanguageCodes.Add('mni');  LanguageNames.Add('Manipuri');
  LanguageCodes.Add('mno');  LanguageNames.Add('Manobo Languages');
  LanguageCodes.Add('moh');  LanguageNames.Add('Mohawk');
  LanguageCodes.Add('mol');  LanguageNames.Add('Moldavian');
  LanguageCodes.Add('mon');  LanguageNames.Add('Mongolian');
  LanguageCodes.Add('mos');  LanguageNames.Add('Mossi');
  LanguageCodes.Add('mri');  LanguageNames.Add('Maori');
  LanguageCodes.Add('msa');  LanguageNames.Add('Malay');
  LanguageCodes.Add('mul');  LanguageNames.Add('Multiple Languages');
  LanguageCodes.Add('mun');  LanguageNames.Add('Munda Languages');
  LanguageCodes.Add('mus');  LanguageNames.Add('Creek');
  LanguageCodes.Add('mwr');  LanguageNames.Add('Marwari');
  LanguageCodes.Add('mya');  LanguageNames.Add('Burmese');
  LanguageCodes.Add('myn');  LanguageNames.Add('Mayan Languages');
  LanguageCodes.Add('nah');  LanguageNames.Add('Aztec');
  LanguageCodes.Add('nai');  LanguageNames.Add('North American Indian (Other)');
  LanguageCodes.Add('nau');  LanguageNames.Add('Nauru');
  LanguageCodes.Add('nav');  LanguageNames.Add('Navajo');
  LanguageCodes.Add('nbl');  LanguageNames.Add('Ndebele, South');
  LanguageCodes.Add('nde');  LanguageNames.Add('Ndebele, North');
  LanguageCodes.Add('ndo');  LanguageNames.Add('Ndongo');
  LanguageCodes.Add('nep');  LanguageNames.Add('Nepali');
  LanguageCodes.Add('new');  LanguageNames.Add('Newari');
  LanguageCodes.Add('nic');  LanguageNames.Add('Niger-Kordofanian (Other)');
  LanguageCodes.Add('niu');  LanguageNames.Add('Niuean');
  LanguageCodes.Add('nla');  LanguageNames.Add('Dutch');
  LanguageCodes.Add('nno');  LanguageNames.Add('Norwegian (Nynorsk)');
  LanguageCodes.Add('non');  LanguageNames.Add('Norse, Old');
  LanguageCodes.Add('nor');  LanguageNames.Add('Norwegian');
  LanguageCodes.Add('nso');  LanguageNames.Add('Sotho, Northern');
  LanguageCodes.Add('nub');  LanguageNames.Add('Nubian Languages');
  LanguageCodes.Add('nya');  LanguageNames.Add('Nyanja');
  LanguageCodes.Add('nym');  LanguageNames.Add('Nyamwezi');
  LanguageCodes.Add('nyn');  LanguageNames.Add('Nyankole');
  LanguageCodes.Add('nyo');  LanguageNames.Add('Nyoro	');
  LanguageCodes.Add('nzi');  LanguageNames.Add('Nzima');
  LanguageCodes.Add('oci');  LanguageNames.Add('Langue d''Oc (post 1500)');
  LanguageCodes.Add('oji');  LanguageNames.Add('Ojibwa');
  LanguageCodes.Add('ori');  LanguageNames.Add('Oriya');
  LanguageCodes.Add('orm');  LanguageNames.Add('Oromo');
  LanguageCodes.Add('osa');  LanguageNames.Add('Osage');
  LanguageCodes.Add('oss');  LanguageNames.Add('Ossetic');
  LanguageCodes.Add('ota');  LanguageNames.Add('Turkish, Ottoman (1500 - 1928)');
  LanguageCodes.Add('oto');  LanguageNames.Add('Otomian Languages');
  LanguageCodes.Add('paa');  LanguageNames.Add('Papuan-Australian (Other)');
  LanguageCodes.Add('pag');  LanguageNames.Add('Pangasinan');
  LanguageCodes.Add('pal');  LanguageNames.Add('Pahlavi');
  LanguageCodes.Add('pam');  LanguageNames.Add('Pampanga');
  LanguageCodes.Add('pan');  LanguageNames.Add('Panjabi');
  LanguageCodes.Add('pap');  LanguageNames.Add('Papiamento');
  LanguageCodes.Add('pau');  LanguageNames.Add('Palauan');
  LanguageCodes.Add('peo');  LanguageNames.Add('Persian, Old (ca 600 - 400 B.C.)');
  LanguageCodes.Add('per');  LanguageNames.Add('Persian');
  LanguageCodes.Add('phn');  LanguageNames.Add('Phoenician');
  LanguageCodes.Add('pli');  LanguageNames.Add('Pali');
  LanguageCodes.Add('pol');  LanguageNames.Add('Polish');
  LanguageCodes.Add('pon');  LanguageNames.Add('Ponape');
  LanguageCodes.Add('por');  LanguageNames.Add('Portuguese');
  LanguageCodes.Add('pra');  LanguageNames.Add('Prakrit uages');
  LanguageCodes.Add('pro');  LanguageNames.Add('Provencal, Old (to 1500)');
  LanguageCodes.Add('pus');  LanguageNames.Add('Pushto');
  LanguageCodes.Add('que');  LanguageNames.Add('Quechua');
  LanguageCodes.Add('raj');  LanguageNames.Add('Rajasthani');
  LanguageCodes.Add('rar');  LanguageNames.Add('Rarotongan');
  LanguageCodes.Add('roa');  LanguageNames.Add('Romance (Other)');
  LanguageCodes.Add('roh');  LanguageNames.Add('Rhaeto-Romance');
  LanguageCodes.Add('rom');  LanguageNames.Add('Romany');
  LanguageCodes.Add('ron');  LanguageNames.Add('Romanian');
  LanguageCodes.Add('rum');  LanguageNames.Add('Romanian');
  LanguageCodes.Add('run');  LanguageNames.Add('Rundi');
  LanguageCodes.Add('rus');  LanguageNames.Add('Russian');
  LanguageCodes.Add('sad');  LanguageNames.Add('Sandawe');
  LanguageCodes.Add('sag');  LanguageNames.Add('Sango');
  LanguageCodes.Add('sah');  LanguageNames.Add('Yakut');
  LanguageCodes.Add('sai');  LanguageNames.Add('South American Indian (Other)');
  LanguageCodes.Add('sal');  LanguageNames.Add('Salishan Languages');
  LanguageCodes.Add('sam');  LanguageNames.Add('Samaritan Aramaic');
  LanguageCodes.Add('san');  LanguageNames.Add('Sanskrit');
  LanguageCodes.Add('sco');  LanguageNames.Add('Scots');
  LanguageCodes.Add('scr');  LanguageNames.Add('Serbo-Croatian');
  LanguageCodes.Add('sel');  LanguageNames.Add('Selkup');
  LanguageCodes.Add('sem');  LanguageNames.Add('Semitic (Other)');
  LanguageCodes.Add('sga');  LanguageNames.Add('Irish, Old (to 900)');
  LanguageCodes.Add('shn');  LanguageNames.Add('Shan');
  LanguageCodes.Add('sid');  LanguageNames.Add('Sidamo');
  LanguageCodes.Add('sin');  LanguageNames.Add('Singhalese');
  LanguageCodes.Add('sio');  LanguageNames.Add('Siouan Languages');
  LanguageCodes.Add('sit');  LanguageNames.Add('Sino-Tibetan (Other)');
  LanguageCodes.Add('sla');  LanguageNames.Add('Slavic (Other)');
  LanguageCodes.Add('slk');  LanguageNames.Add('Slovak');
  LanguageCodes.Add('slo');  LanguageNames.Add('Slovak');
  LanguageCodes.Add('slv');  LanguageNames.Add('Slovenian');
  LanguageCodes.Add('smi');  LanguageNames.Add('Sami Languages');
  LanguageCodes.Add('smo');  LanguageNames.Add('Samoan');
  LanguageCodes.Add('sna');  LanguageNames.Add('Shona');
  LanguageCodes.Add('snd');  LanguageNames.Add('Sindhi');
  LanguageCodes.Add('sog');  LanguageNames.Add('Sogdian');
  LanguageCodes.Add('som');  LanguageNames.Add('Somali');
  LanguageCodes.Add('son');  LanguageNames.Add('Songhai');
  LanguageCodes.Add('sot');  LanguageNames.Add('Sotho, Southern');
  LanguageCodes.Add('spa');  LanguageNames.Add('Spanish');
  LanguageCodes.Add('sqi');  LanguageNames.Add('Albanian');
  LanguageCodes.Add('srd');  LanguageNames.Add('Sardinian	');
  LanguageCodes.Add('srr');  LanguageNames.Add('Serer');
  LanguageCodes.Add('ssa');  LanguageNames.Add('Nilo-Saharan (Other)');
  LanguageCodes.Add('ssw');  LanguageNames.Add('Siswant');
  LanguageCodes.Add('ssw');  LanguageNames.Add('Swazi');
  LanguageCodes.Add('suk');  LanguageNames.Add('Sukuma');
  LanguageCodes.Add('sun');  LanguageNames.Add('Sudanese');
  LanguageCodes.Add('sus');  LanguageNames.Add('Susu');
  LanguageCodes.Add('sux');  LanguageNames.Add('Sumerian');
  LanguageCodes.Add('sve');  LanguageNames.Add('Swedish');
  LanguageCodes.Add('swa');  LanguageNames.Add('Swahili');
  LanguageCodes.Add('swe');  LanguageNames.Add('Swedish');
  LanguageCodes.Add('syr');  LanguageNames.Add('Syriac');
  LanguageCodes.Add('tah');  LanguageNames.Add('Tahitian');
  LanguageCodes.Add('tam');  LanguageNames.Add('Tamil');
  LanguageCodes.Add('tat');  LanguageNames.Add('Tatar');
  LanguageCodes.Add('tel');  LanguageNames.Add('Telugu');
  LanguageCodes.Add('tem');  LanguageNames.Add('Timne');
  LanguageCodes.Add('ter');  LanguageNames.Add('Tereno');
  LanguageCodes.Add('tgk');  LanguageNames.Add('Tajik');
  LanguageCodes.Add('tgl');  LanguageNames.Add('Tagalog');
  LanguageCodes.Add('tha');  LanguageNames.Add('Thai');
  LanguageCodes.Add('tib');  LanguageNames.Add('Tibetan');
  LanguageCodes.Add('tig');  LanguageNames.Add('Tigre');
  LanguageCodes.Add('tir');  LanguageNames.Add('Tigrinya');
  LanguageCodes.Add('tiv');  LanguageNames.Add('Tivi');
  LanguageCodes.Add('tli');  LanguageNames.Add('Tlingit	');
  LanguageCodes.Add('tmh');  LanguageNames.Add('Tamashek');
  LanguageCodes.Add('tog');  LanguageNames.Add('Tonga (Nyasa)	');
  LanguageCodes.Add('ton');  LanguageNames.Add('Tonga (Tonga Islands)');
  LanguageCodes.Add('tru');  LanguageNames.Add('Truk');
  LanguageCodes.Add('tsi');  LanguageNames.Add('Tsimshian');
  LanguageCodes.Add('tsn');  LanguageNames.Add('Tswana');
  LanguageCodes.Add('tso');  LanguageNames.Add('Tsonga');
  LanguageCodes.Add('tuk');  LanguageNames.Add('Turkmen');
  LanguageCodes.Add('tum');  LanguageNames.Add('Tumbuka');
  LanguageCodes.Add('tur');  LanguageNames.Add('Turkish');
  LanguageCodes.Add('tut');  LanguageNames.Add('Altaic (Other)');
  LanguageCodes.Add('twi');  LanguageNames.Add('Twi');
  LanguageCodes.Add('tyv');  LanguageNames.Add('Tuvinian');
  LanguageCodes.Add('uga');  LanguageNames.Add('Ugaritic');
  LanguageCodes.Add('uig');  LanguageNames.Add('Uighur');
  LanguageCodes.Add('ukr');  LanguageNames.Add('Ukrainian');
  LanguageCodes.Add('umb');  LanguageNames.Add('Umbundu');
  LanguageCodes.Add('und');  LanguageNames.Add('Undetermined');
  LanguageCodes.Add('urd');  LanguageNames.Add('Urdu');
  LanguageCodes.Add('uzb');  LanguageNames.Add('Uzbek');
  LanguageCodes.Add('vai');  LanguageNames.Add('Vai');
  LanguageCodes.Add('ven');  LanguageNames.Add('Venda');
  LanguageCodes.Add('vie');  LanguageNames.Add('Vietnamese');
  LanguageCodes.Add('vol');  LanguageNames.Add('Volapük');
  LanguageCodes.Add('vot');  LanguageNames.Add('Votic');
  LanguageCodes.Add('wak');  LanguageNames.Add('Wakashan Languages');
  LanguageCodes.Add('wal');  LanguageNames.Add('Walamo');
  LanguageCodes.Add('war');  LanguageNames.Add('Waray');
  LanguageCodes.Add('was');  LanguageNames.Add('Washo');
  LanguageCodes.Add('wel');  LanguageNames.Add('Welsh');
  LanguageCodes.Add('wen');  LanguageNames.Add('Sorbian Languages');
  LanguageCodes.Add('wol');  LanguageNames.Add('Wolof');
  LanguageCodes.Add('xho');  LanguageNames.Add('Xhosa');
  LanguageCodes.Add('yao');  LanguageNames.Add('Yao');
  LanguageCodes.Add('yap');  LanguageNames.Add('Yap');
  LanguageCodes.Add('yid');  LanguageNames.Add('Yiddish');
  LanguageCodes.Add('yor');  LanguageNames.Add('Yoruba');
  LanguageCodes.Add('zap');  LanguageNames.Add('Zapotec');
  LanguageCodes.Add('zen');  LanguageNames.Add('Zenaga');
  LanguageCodes.Add('zha');  LanguageNames.Add('Zhuang');
  LanguageCodes.Add('zho');  LanguageNames.Add('Chinese');
  LanguageCodes.Add('zul');  LanguageNames.Add('Zulu');
  LanguageCodes.Add('zun');  LanguageNames.Add('Zuni');


end.
