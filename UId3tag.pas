unit UId3tag;

interface

Type
  TID3Tag = record
    ID: string[3];
    Titel: string[30];
    Artist: string[30];
    Album: string[30];
    Year: string[4];
    Comment: string[30];
    Genre: byte;
    dauer: longint; //in sekunden;
    sample: integer;
    bits: byte;
    vers: byte;
    layers: byte;
end;

const
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
    
type
  TId3 = class (TObject)

 public
  ID3Tag: TID3Tag;
  procedure Lese(Filename: string);

  end;

implementation  


procedure TId3.Lese(Filename: string);
var
  Buffer: array[1..128] of char;
  F: File;
  mp3hdrread: array[1..4] of byte;
  mp3hdr: longint absolute mp3hdrread;
  tempbyte, bitrateindex, versionindex: byte;
  bitrate, version, layer, groese: longint;
begin
  AssignFile(F, Filename);
   {$I-}
  Reset(F,1);
  if ioresult<>0 then exit;                    
   {$I+}
  groese:=filesize(f);
  blockread(f,mp3hdrread,4);
  tempbyte:=mp3hdrread[1];
  mp3hdrread[1]:=mp3hdrread[4];
  mp3hdrread[4]:=tempbyte;
  tempbyte:=mp3hdrread[2];
  mp3hdrread[2]:=mp3hdrread[3];
  mp3hdrread[3]:=tempbyte;

  reset(f,1);
  Seek(F,FileSize(F)-128);
  BlockRead(F, Buffer, SizeOf(Buffer));
  CloseFile(F);
  bitrateindex:=((mp3hdr shr 12) and $F);
  versionindex:=((mp3hdr shr 19) and $3);

  case versionindex of
    0: version:=3;
    1: version:=0; //unbekannt
    2: version:=2;
    3: version:=1;
  end;

  layer:=4-((mp3hdr shr 17) and $3);

  if version<>0 then
    bitrate:=MPEG_BIT_RATES[version][layer][bitrateindex]
  else
    bitrate:=128;

  with ID3Tag do
  begin
    ID:=copy(Buffer,1,3);
    Titel:=copy(Buffer,4,30);
    Artist:=copy(Buffer,34,30);
    Album:=copy(Buffer,64,30);
    Year:=copy(Buffer,94,4);
    Comment:=copy(Buffer,98,30);
    Genre:=ord(Buffer[128]);
    sample:=sample_rates[version][((mp3hdr shr 10) and $3)];
    dauer:=(groese*8) div ((bitrate)*1000);
    bits:=bitrate;
    vers:=version;
    layers:=layer;
  end;
end;



end.
