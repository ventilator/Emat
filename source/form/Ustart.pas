//ehm. Splashscreen von Emat
//seit 0.75 dient diese Form zum Anzeigen des Emat-Logos

unit Ustart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, DateUtils,
  StdCtrls, ComCtrls, ExtCtrls, TBXDkPanels,
  Dialogs, ump3, TB2Item, ulang;

const
  Logos = 2;

type
  TFstart = class(TForm)
    i0: TImage;
    i1: TImage;
    TBXAlignmentPanel1: TTBXAlignmentPanel;
    RichEdit1: TMemo;
    Lweblink: TLabel;
    Lupdate: TLabel;
    TBXAlignmentPanel2: TTBXAlignmentPanel;
    Lversion: TLabel;
    procedure RichEdit1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LweblinkMouseLeave(Sender: TObject);
    procedure LweblinkMouseEnter(Sender: TObject);
    procedure LweblinkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Fstart: TFstart;

implementation

// Plain-text reader for the RTF help file (LCL has no rich edit control here).
function RtfToPlain(const FileName: string): string;
var
  s, outS: string;
  i, j, n, depth, skipDepth: Integer;
  word: string;
  c: Char;
  ms: TMemoryStream;

  function StartsAt(pos: Integer; const pat: string): Boolean;
  begin
    Result := Copy(s, pos, Length(pat)) = pat;
  end;

begin
  outS := '';
  ms := TMemoryStream.Create;
  try
    ms.LoadFromFile(FileName);
    SetLength(s, ms.Size);
    if ms.Size > 0 then
    begin
      ms.Position := 0;
      ms.Read(s[1], ms.Size);
    end;
  finally
    ms.Free;
  end;
  n := Length(s);
  i := 1;
  depth := 0;
  skipDepth := 0;
  while i <= n do
  begin
    c := s[i];
    if c = '{' then
    begin
      Inc(depth);
      if (skipDepth = 0) and (StartsAt(i + 1, '\*') or StartsAt(i + 1, '\fonttbl') or
         StartsAt(i + 1, '\colortbl') or StartsAt(i + 1, '\stylesheet') or
         StartsAt(i + 1, '\info') or StartsAt(i + 1, '\pict')) then
        skipDepth := depth;
      Inc(i);
    end
    else if c = '}' then
    begin
      if (skipDepth <> 0) and (depth = skipDepth) then
        skipDepth := 0;
      Dec(depth);
      Inc(i);
    end
    else if c = '\' then
    begin
      if i + 1 > n then
        Inc(i)
      else if s[i + 1] in ['\', '{', '}'] then
      begin
        if skipDepth = 0 then outS := outS + s[i + 1];
        Inc(i, 2);
      end
      else if s[i + 1] = '''' then
      begin
        if skipDepth = 0 then outS := outS + Chr(StrToIntDef('$' + Copy(s, i + 2, 2), 63));
        Inc(i, 4);
      end
      else if s[i + 1] = '~' then
      begin
        if skipDepth = 0 then outS := outS + ' ';
        Inc(i, 2);
      end
      else if s[i + 1] in ['a'..'z', 'A'..'Z'] then
      begin
        word := '';
        j := i + 1;
        while (j <= n) and (s[j] in ['a'..'z', 'A'..'Z']) do
        begin
          word := word + s[j];
          Inc(j);
        end;
        if (j <= n) and ((s[j] = '-') or (s[j] in ['0'..'9'])) then
        begin
          Inc(j);
          while (j <= n) and (s[j] in ['0'..'9']) do Inc(j);
        end;
        if (j <= n) and (s[j] = ' ') then Inc(j);
        if skipDepth = 0 then
        begin
          if (word = 'par') or (word = 'line') then outS := outS + #13#10
          else if word = 'tab' then outS := outS + #9;
        end;
        i := j;
      end
      else
        Inc(i, 2);
    end
    else
    begin
      if (skipDepth = 0) and (c <> #13) and (c <> #10) then outS := outS + c;
      Inc(i);
    end;
  end;
  Result := outS;
end;

{$R *.lfm}

procedure TFstart.FormShow(Sender: TObject);

function GetImageLinkTimeStamp(const FileName: string): DWORD; 
const 
  INVALID_SET_FILE_POINTER = DWORD(-1); 
  BorlandMagicTimeStamp = $2A425E19;  // Delphi 4-6 (and above?) 
  FileTime1970: TFileTime = (dwLowDateTime:$D53E8000; dwHighDateTime:$019DB1DE); 
type 
  PImageSectionHeaders = ^TImageSectionHeaders; 
  TImageSectionHeaders = array [Word] of TImageSectionHeader; 
type 
  PImageResourceDirectory = ^TImageResourceDirectory; 
  TImageResourceDirectory = packed record 
    Characteristics: DWORD; 
    TimeDateStamp: DWORD; 
    MajorVersion: Word; 
    MinorVersion: Word; 
    NumberOfNamedEntries: Word; 
    NumberOfIdEntries: Word; 
  end; 
var 
  FileHandle: THandle; 
  BytesRead: DWORD; 
  ImageDosHeader: TImageDosHeader; 
  ImageNtHeaders: TImageNtHeaders; 
  SectionHeaders: PImageSectionHeaders; 
  Section: Word; 
  ResDirRVA: DWORD; 
  ResDirSize: DWORD; 
  ResDirRaw: DWORD; 
  ResDirTable: TImageResourceDirectory; 
  FileTime: TFileTime; 
begin 
  Result := 0; 
  // Open file for read access 
  FileHandle := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil, 
    OPEN_EXISTING, 0, 0); 
  if (FileHandle <> INVALID_HANDLE_VALUE) then 
  try 
    // Read MS-DOS header to get the offset of the PE32 header 
    // (not required on WinNT based systems - but mostly available) 
    if not ReadFile(FileHandle, ImageDosHeader, SizeOf(TImageDosHeader), 
      BytesRead, nil) or (BytesRead <> SizeOf(TImageDosHeader)) or 
      (ImageDosHeader.e_magic <> IMAGE_DOS_SIGNATURE) then 
    begin 
      ImageDosHeader._lfanew := 0; 
    end; 
    // Read PE32 header (including optional header 
    if (SetFilePointer(FileHandle, ImageDosHeader._lfanew, nil, FILE_BEGIN) = 
      INVALID_SET_FILE_POINTER) then 
    begin 
      Exit; 
    end; 
    if not(ReadFile(FileHandle, ImageNtHeaders, SizeOf(TImageNtHeaders), 
      BytesRead, nil) and (BytesRead = SizeOf(TImageNtHeaders))) then 
    begin 
      Exit; 
    end; 
    // Validate PE32 image header 
    if (ImageNtHeaders.Signature <> IMAGE_NT_SIGNATURE) then 
    begin 
      Exit; 
    end; 
    // Seconds since 1970 (UTC) 
    Result := ImageNtHeaders.FileHeader.TimeDateStamp; 

    // Check for Borland's magic value for the link time stamp 
    // (we take the time stamp from the resource directory table) 
    if (ImageNtHeaders.FileHeader.TimeDateStamp = BorlandMagicTimeStamp) then 
    with ImageNtHeaders, FileHeader, OptionalHeader do 
    begin 
      // Validate Optional header 
      if (SizeOfOptionalHeader < IMAGE_SIZEOF_NT_OPTIONAL_HEADER) or 
        (Magic <> IMAGE_NT_OPTIONAL_HDR_MAGIC) then 
      begin 
        Exit; 
      end; 
      // Read section headers 
      SectionHeaders := 
        GetMemory(NumberOfSections * SizeOf(TImageSectionHeader)); 
      if Assigned(SectionHeaders) then 
      try 
        if (SetFilePointer(FileHandle, 
          SizeOfOptionalHeader - IMAGE_SIZEOF_NT_OPTIONAL_HEADER, nil, 
          FILE_CURRENT) = INVALID_SET_FILE_POINTER) then 
        begin 
          Exit; 
        end; 
        if not(ReadFile(FileHandle, SectionHeaders^, NumberOfSections * 
          SizeOf(TImageSectionHeader), BytesRead, nil) and (BytesRead = 
          NumberOfSections * SizeOf(TImageSectionHeader))) then 
        begin 
          Exit; 
        end; 
        // Get RVA and size of the resource directory 
        with DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE] do 
        begin 
          ResDirRVA := VirtualAddress; 
          ResDirSize := Size; 
        end; 
        // Search for section which contains the resource directory 
        ResDirRaw := 0; 
        for Section := 0 to NumberOfSections - 1 do 
        with SectionHeaders[Section] do 
          if (VirtualAddress <= ResDirRVA) and 
            (VirtualAddress + SizeOfRawData >= ResDirRVA + ResDirSize) then 
          begin 
            ResDirRaw := PointerToRawData - (VirtualAddress - ResDirRVA); 
            Break; 
          end; 
        // Resource directory table found? 
        if (ResDirRaw = 0) then 
        begin 
          Exit; 
        end; 
        // Read resource directory table 
        if (SetFilePointer(FileHandle, ResDirRaw, nil, FILE_BEGIN) = 
          INVALID_SET_FILE_POINTER) then 
        begin 
          Exit; 
        end; 
        if not(ReadFile(FileHandle, ResDirTable, 
          SizeOf(TImageResourceDirectory), BytesRead, nil) and 
          (BytesRead = SizeOf(TImageResourceDirectory))) then 
        begin 
          Exit; 
        end; 
        // Convert from DosDateTime to SecondsSince1970 
        if DosDateTimeToFileTime(HiWord(ResDirTable.TimeDateStamp), 
          LoWord(ResDirTable.TimeDateStamp), FileTime) then 
        begin 
          // FIXME: Borland's linker uses the local system time 
          // of the user who linked the executable image file. 
          // (is that information anywhere?) 
          Result := (ULARGE_INTEGER(FileTime).QuadPart - 
            ULARGE_INTEGER(FileTime1970).QuadPart) div 10000000; 
        end; 
      finally 
        FreeMemory(SectionHeaders); 
      end; 
    end; 
  finally 
    CloseHandle(FileHandle); 
  end; 
end;


begin
  Lweblink.Caption := WEBSITE;
  Lupdate.Caption := UPDATEPAGE;
  Lversion.Caption := Version;
  LVersion.Hint    :=DateTimeToStr(UnixToDateTime(GetImageLinkTimeStamp(Application.ExeName)));

  (FindComponent( 'i' + inttostr(random(Logos))) as TImage).BringToFront;
  if FileExists(extractfilepath(application.ExeName) + 'emat.rtf')
  then fstart.RichEdit1.Lines.Text := RtfToPlain(extractfilepath(application.ExeName) + 'emat.rtf')
  else fstart.RichEdit1.Lines.Add(HELPFILENOTFOUND);
  RichEdit1.SelStart := -1;
end;

procedure TFstart.LweblinkClick(Sender: TObject);
begin
  fmp3.GoToUrl((Sender as TLabel).Caption);
end;

procedure TFstart.LweblinkMouseEnter(Sender: TObject);
begin
  (Sender as TLabel).Font.Style := Fstart.Font.Style + [fsUnderline];
end;

procedure TFstart.LweblinkMouseLeave(Sender: TObject);
begin
  (Sender as TLabel).Font.Style := Fstart.Font.Style - [fsUnderline];
end;

procedure TFstart.RichEdit1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  HideCaret(RichEdit1.Handle);
end;

end.
