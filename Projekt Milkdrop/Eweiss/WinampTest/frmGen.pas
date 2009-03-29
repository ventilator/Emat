unit frmGen;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, IniFiles, StrUtils, StdCtrls, BassVis;

type
  Tfrm_Gen = class(TForm)
    picMap:        TImage;
    picTopL:       TImage;
    picTopF:       TImage;
    picTopText:    TImage;
    picTopM:       TImage;
    picTopStretch: TImage;
    picTopC:       TImage;
    picBorderL:    TImage;
    picBottomL:    TImage;
    picBottomR:    TImage;
    picBottomM:    TImage;
    picClose:      TImage;
    picTopTextSrc: TImage;
    picBorderR:    TImage;
    picFormResize: TImage;
    picMapSrc:     TImage;
    pBack:         TPanel;
    procedure picTopTextMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure picFormResizeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure picCloseMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure picBottomMMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure picFormResizeMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure picFormResizeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure picTopFMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure FormDestroy(Sender: TObject);
    procedure picTopLMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure picTopMMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure picTopStretchMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure picTopMDblClick(Sender: TObject);
    procedure picCloseMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure picTopTextSrcMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure picBottomMDblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    procedure LoadSkin;
    procedure ImageCopy;
    procedure ScaleScreen;

    procedure picBottomM_Resize;
    procedure picTopText_Resize;
    procedure picTopStretch_Resize;
    procedure StandardSize;

    procedure SetImage(Destination: TImage; x: integer;
      y: integer;
      W: integer;
      H: integer;
      Source: TImage;
      startX: integer;
      StartY: integer);
    procedure ChangeGenPos;
    function SetFullWindowDrag(hwnd: DWORD; ShowFullWindow: boolean): boolean;
    procedure MouseTrap(Sender: TObject; X, Y: integer);
    procedure MouseTrap_Release;
  public
    function GetBitArray(StrView: string): integer;
  end;

  TSplitStrArray = array of string;

function Split(const Source, Delimiter: string): TSplitStrArray;

var
  frm_Gen:    Tfrm_Gen;
  i:          integer;
  picW:       integer;
  fTimer:     single;
  Prg:        string;
  Sect:       string;
  OptDefPath: string;

  FormFlag:  boolean;
  FX:        integer;
  FY:        integer;
  FormFirst: boolean;
  AX:        integer;
  AY:        integer;
  PicMapDC:  hdc;


implementation

uses Unit1;

{$R *.dfm}

procedure Tfrm_Gen.ChangeGenPos;
begin
  picBottomM_Resize;
  picTopText_Resize;
  picTopStretch_Resize;

end;



function Tfrm_Gen.GetBitArray(StrView: string): integer;
var
  IntI:    integer;     //Zähler
  StrPosX: string;      //X Position im Bitmap
  StrPosW: string;      //Weite des Buchstaben
  IntPos:  integer;     //Zähler für die Buchstabenweite

  DelemiterCol: TCOLOR; //Delemiter als Farbe
  IntDelPos: integer;   //Aktuelle Delemiter Position
  ColFound: boolean;    //Farbe gefunden, ergebnis = Buchstabenweite
  BWidth: variant;      //Resultat der gefundenen Buchstabenweiten Spliten
  PosX:   variant;
  NewPos: integer;
  StrS:   string;
  IntX:   integer;

begin
  IntPos    := 0;
  IntDelPos := 0;
  Result    := 0;
  ColFound  := False;

  PicMapDC     := PicMap.Picture.Bitmap.Canvas.Handle;
  //******************** Schleife zum ermitteln der Buchstabenweite *********************
  ///////////////////////////////////////////////////////////////////////////////////////
  //Ermitteln der Delemiter Farbe
  DelemiterCol := GetPixel(PicMapDC, 0, 88);
  if not (DelemiterCol = -1) then
  begin
    //Schleife durchlaufen bis 26* die Delemiter Farbe gefunden wurde
    for IntI := 1 to picMap.Width do
    begin
      //Raus hier wenn Farbe 26* gefunden
      if IntDelPos = 26 then
        Break;

      //Aktuelle Position der Buchstabenweite um  eins erhöhen
      Inc(IntPos);
      //Wenn aktuelle position im Bitmap die gleiche Farbe
      //enthält wie DelemiterCol ..
      if GetPixel(PicMapDC, IntI, 88) = Cardinal(DelemiterCol) then
      begin
        if IntDelPos <= 24 then
        begin
          //Position zum StrPosX addieren und Delemiter komma anhängen
          StrPosX := StrPosX + IntToStr(IntI) + ',';
        end
        else
          //Letze Position zum StrPosX addieren ohne Delemiter
          StrPosX := StrPosX + IntToStr(IntI);
        //Zähler für Farbe um eins erhöhen
        Inc(IntDelPos);
        //Farbe gefunden
        ColFound := True;
      end;
      //wenn Farbe gefunden
      if ColFound then
      begin
        //weite des Buchstaben zum StrPosW addieren
        if IntDelPos <= 25 then
        begin
          StrPosW := StrPosW + IntToStr(IntPos - 1) + ',';
        end
        else
          StrPosW := StrPosW + IntToStr(IntPos - 1);
        //Buchstabenweite löschen
        IntPos := 0;
      end;
      //Farbe gefunden zurück setzen
      ColFound := False;
    end;
    BWidth := Split(StrPosW, ',');
    PosX   := Split(StrPosX, ',');

    IntX := 0;
    for IntI := 1 to Length(StrView) + 1 do
    begin
      try
        // Wird benötigt zum Debuggen um den ASCII Wert als String anzuzeigen!
        StrS := MidStr(StrView, IntI, 1);
        // Übergebe Buchstabe abhängig vom aktiven Index
        if StrView[IntI] > ' ' then
        begin
          // weite des aktuellen Buchstaben aus dem Array BWidth
          // vom String(StrPosW) ermitteln.
          // und zu (picTopTextSrc.Width = IntX) addieren
          IntX := IntX + BWidth[Ord(UpCase(StrView[IntI])) - 65];
        end else
          //Bei Leerstring 5 zu (picTopTextSrc.Width = IntX) hinzufügen
          IntX := IntX + 5;

        if StrView[IntI] > ' ' then
        begin
          // Zur neuen X Position aus dem Array PosX vom string(StrPosX)
          // minus der weite des aktuellen Buchstaben aus dem Array BWidth
          // vom String(StrPosW) im picMap springen.
          IntPos := PosX[Ord(UpCase(StrView[IntI])) - 65] -
            BWidth[Ord(UpCase(StrView[IntI])) - 65];
        end else
          // Bei Leerstring zur Position 61 im picMap springen.
          // zeichnet einen leeren Bitmap ausschnitt.
          IntPos := 61;

        if (IntI > 0) and (StrView[IntI] > ' ') then
        begin
          NewPos := IntX - BWidth[Ord(UpCase(StrView[IntI])) - 65];
        end else if IntI = 0 then
          // An die anfangs Position des aktuellen Buchstaben springen
          // wenn IntI = 1
          NewPos := IntX - 6
        else
          NewPos := IntX - 5;


        if StrView[IntI] > ' ' then
        begin
          // neue picTopTextSrc weite zuweisen abhängig von
          // der aktuellen gesamtweite(IntX)
          picTopTextSrc.Width := IntX;
          picTopTextSrc.Picture.Bitmap.Width := IntX;
          SetImage(picTopTextSrc, NewPos, 0, IntX, 7, picMap, IntPos, 88);
        end else
        begin
          // Bei Leerstring wird andere Y Position benötigt
          picTopTextSrc.Width := IntX;
          picTopTextSrc.Picture.Bitmap.Width := IntX;
          SetImage(picTopTextSrc, NewPos, 0, IntX, 7, picMap, IntPos, 4);
        end;
      except
        // Nummeric value
      end;
    end;
    // Resultat an picTopText.Width übergeben
    // picTopText verschieben damit picTopTextSrc platz zur Anzeige hat.
    Result := IntX + Length(StrS) - 1;
  end;
end;



procedure Tfrm_Gen.LoadSkin;
begin
  if FileExists(OptDefPath + '\Gen.bmp') then
  begin
    picMap.Picture.LoadFromFile(OptDefPath + '\Gen.bmp');
  end
  else
    picMap.Picture := picMapSrc.Picture;

  PicMapDC := PicMap.Picture.Bitmap.Canvas.Handle;
end;



procedure Tfrm_Gen.picBottomM_Resize;
var
  picBottomM_HDC: HDC;
begin
  picBottomM_HDC := picBottomM.Picture.Bitmap.Canvas.Handle;
  PicMapDC := PicMap.Picture.Bitmap.Canvas.Handle;

  picW := picBottomM.Width;
  StretchBlt(picBottomM_HDC, 0, 0, picW, 14, PicMapDC, 127, 72, 25, 14, SRCCOPY);
  picBottomM.Refresh;

end;



procedure Tfrm_Gen.picTopStretchMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  SetFullWindowDrag(frm_Gen.Handle, True);

  SetFullWindowDrag(frm_Gen.Handle, False);
end;



procedure Tfrm_Gen.picTopStretch_Resize;
var
  picTopStretch_HDC: HDC;

begin
  picTopStretch_HDC := picTopStretch.Picture.Bitmap.Canvas.Handle;
  PicMapDC := PicMap.Picture.Bitmap.Canvas.Handle;

  picW := picTopStretch.Width;
  StretchBlt(picTopStretch_HDC, 0, 0, picW, 20, PicMapDC, 104, 0, 25, 20, SRCCOPY);
  picTopStretch.Refresh;

end;



procedure Tfrm_Gen.picTopText_Resize;
var
  picTopText_HDC: HDC;

begin
  picTopText_HDC := picTopText.Picture.Bitmap.Canvas.Handle;
  PicMapDC := PicMap.Picture.Bitmap.Canvas.Handle;

  picW := picTopText.Width;
  StretchBlt(picTopText_HDC, 0, 0, picW, 20, PicMapDC, 52, 0, 25, 20, SRCCOPY);
  picTopText.Refresh;

end;



procedure Tfrm_Gen.ScaleScreen;
begin
  if WindowState <> wsMaximized then
  begin
    WindowState := wsMaximized;
    picFormResize.Enabled := False;
  end
  else
  if WindowState = wsMaximized then
    WindowState := wsNormal;
  picFormResize.Enabled := True;
end;



procedure Tfrm_Gen.SetImage(Destination: TImage; x: integer;
  y: integer;
  W: integer;
  H: integer;
  Source: TImage;
  startX: integer;
  StartY: integer);
var
  DestDC: HDC;
  SrcDC:  HDC;

begin
  DestDC := Destination.Picture.Bitmap.Canvas.Handle;
  SrcDC  := Source.Picture.Bitmap.Canvas.Handle;

  BitBlt(DestDC, x, y, W, H, SrcDC, startX, StartY, SRCCOPY);
  Destination.Refresh;
end;



procedure Tfrm_Gen.StandardSize;
var
  Ini:    TIniFile;
  StrInI: TSplitStrArray;

begin

  // Positionen der Form einlesen und setzen
  Ini := TIniFile.Create(ExtractFilePath(application.exename) + 'Gen.ini');

  StrInI := Split(Ini.ReadString('Position', 'GenPos', '300,300,275,116'), ',');
  Left   := StrToInt(StrInI[0]);
  Top    := StrToInt(StrInI[1]);
  Width  := StrToInt(StrInI[2]);
  Height := StrToInt(StrInI[3]);

  picFormResize.Canvas.MoveTo(Width - 14, Height - 14);
  picTopC.Canvas.MoveTo(Width - 25, 0);
  picClose.Canvas.MoveTo(Width - 12, 2);
  picTopText.Canvas.MoveTo((Width div 2) - (picTopText.Width div 2), 0);
  picTopTextSrc.Canvas.MoveTo(
    (Width div 2) - (picTopTextSrc.Width div 2), picTopText.Top + 4);
  picTopL.Canvas.MoveTo(0, 0);
  picTopStretch.Canvas.MoveTo(25, 0);
  picTopF.Canvas.MoveTo(picTopText.Left - 25, 0);
  picTopM.Canvas.MoveTo(picTopText.Left + picTopText.Width, 0);
  picBottomL.Canvas.MoveTo(0, Height - 14);
  picBottomR.Canvas.MoveTo(Width - 125, Height - 14);
  picBorderL.Canvas.MoveTo(0, 20);
  picBorderR.Canvas.MoveTo(Width - 8, 20);
  picBottomM.Canvas.MoveTo(picBottomL.Width, Height - 14);

  ChangeGenPos;
end;



procedure Tfrm_Gen.ImageCopy;
begin
  SetImage(picBottomR, 0, 0, 125, 14, picMap, 0, 57);
  SetImage(picBottomL, 0, 0, 125, 14, picMap, 0, 42);
  SetImage(picFormResize, 0, 0, 14, 14, picMap, 111, 57);
  SetImage(picTopC, 0, 0, 25, 20, picMap, 130, 0);
  SetImage(picClose, 0, 0, 9, 10, picTopC, 13, 2);
  SetImage(picTopL, 0, 0, 25, 20, picMap, 0, 0);
  SetImage(picTopF, 0, 0, 25, 20, picMap, 26, 0);
  SetImage(picTopM, 0, 0, 25, 20, picMap, 78, 0);
  SetImage(picBorderL, 0, 0, 11, 29, picMap, 127, 42);
  SetImage(picBorderR, 0, 0, 8, 29, picMap, 139, 42);

end;



procedure Tfrm_Gen.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Ini: TIniFile;

begin
  Ini := TIniFile.Create(ExtractFilePath(application.exename) + 'Gen.ini');
  Ini.WriteString('Position', 'GenPos', IntToStr(Left) +
    ',' + IntToStr(Top) +
    ',' + IntToStr(Width) +
    ',' + IntToStr(Height));

end;

procedure Tfrm_Gen.FormDestroy(Sender: TObject);
var
  Ini: TIniFile;

begin
  Ini := TIniFile.Create(ExtractFilePath(application.exename) + 'Gen.ini');
  Ini.WriteString('Position', 'GenPos', IntToStr(Left) +
    ',' + IntToStr(Top) +
    ',' + IntToStr(Width) +
    ',' + IntToStr(Height));
end;

procedure Tfrm_Gen.FormResize(Sender: TObject);
var
  picBorderL_hDC: HDC;
  picBorderR_hDC: HDC;

begin

  pBack.Left   := 11;
  pBack.Top    := 20;
  pBack.Width  := Width - picBorderR.Width - 11;
  pBack.Height := Height - 34;

  if Unit1.Vischan <> 0 then
  begin
    MoveWindow(Unit1.lHwndParent, 0, 0, PBack.Width, PBack.Height, True);
  end;

  picTopC.left := frm_Gen.Width - 25;
  picTopC.top  := 0;

  picClose.Left   := Width - 12;
  picClose.Top    := 2;
  picClose.Width  := 9;
  picClose.Height := 9;

  picTopText.Left   := (Width div 2) - (picTopText.Width div 2);
  picTopText.Top    := 0;
  picTopText.Width  := picTopText.Width;
  picTopText.Height := 20;

  picTopTextSrc.Left := (Width div 2) - (picTopTextSrc.Width div 2);  //+ 2
  picTopTextSrc.Top  := picTopText.Top + 4;

  picTopL.left := 0;
  picTopL.Top  := 0;

  picTopStretch.left   := 25;
  picTopStretch.top    := 0;
  picTopStretch.Width  := picTopC.Left;
  picTopStretch.Height := 20;

  picTopF.left   := picTopText.Left - 25;
  picTopF.top    := 0;
  picTopF.Width  := 25;
  picTopF.Height := 20;

  picTopM.left   := picTopText.Left + picTopText.Width;
  picTopM.top    := 0;
  picTopM.Width  := 25;
  picTopM.Height := 20;

  picBottomL.left := 0;
  picBottomL.Top  := Height - 14;

  picBottomR.left := Width - 125;
  picBottomR.top  := Height - 14;

  if FormFlag = False then
  begin
    picFormResize.left := Width - 14;
    picFormResize.Top  := Height - 14;
  end;

  picBorderL.Canvas.MoveTo(0, 20);
  picBorderL.Left   := 0;
  picBorderL.Top    := 20;
  picBorderL.Width  := 11;
  picBorderL.Height := Height - 34;

  picBorderL_hDC := picBorderL.Picture.Bitmap.Canvas.Handle;
  StretchBlt(picBorderL_hDC, 0, 0, 11, Height - 34, PicMapDC, 127,
    42, 11, 29, SRCCOPY);
  picBorderL.Refresh;

  picBorderR.Canvas.MoveTo(Width - 8, 20);
  picBorderR.left   := Width - 8;
  picBorderR.Top    := 20;
  picBorderR.Width  := 8;
  picBorderR.Height := Height - 34;

  picBorderR_hDC := picBorderR.Picture.Bitmap.Canvas.Handle;
  StretchBlt(picBorderR_hDC, 0, 0, 8, Height - 34, PicMapDC, 139, 42, 8, 29, SRCCOPY);
  picBorderR.Refresh;

  picBottomM.left   := picBottomL.Width;
  picBottomM.Top    := Height - 14;
  picBottomM.Width  := Width - 125;
  picBottomM.Height := 14;

end;



procedure Tfrm_Gen.FormShow(Sender: TObject);
begin
  // Flackern von TImage verhindern
  DoubleBuffered := True;
  // SkinPfad laden
  OptDefPath     := ExtractFileDir(application.ExeName) + '\Bitmap';
  // Skin laden
  LoadSkin;
  // Default Position setzen
  StandardSize;
  // Images copieren
  ImageCopy;
  // Windowposition / OnTop
  SetWindowPos(frm_Gen.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or
    SWP_NOSIZE or SWP_NOMOVE);

end;

procedure Tfrm_Gen.picBottomMDblClick(Sender: TObject);
begin
  ScaleScreen;
end;



procedure Tfrm_Gen.picBottomMMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  SetFullWindowDrag(frm_Gen.Handle, True);

  SetFullWindowDrag(frm_Gen.Handle, False);
end;



procedure Tfrm_Gen.picCloseMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  picClose_hDC: HDC;

begin
  picClose_hDC := picClose.Picture.Bitmap.Canvas.Handle;
  BitBlt(picClose_hDC, 0, 0, 9, 9, PicMapDC, 144, 193, SRCCOPY);
  picClose.Refresh;
end;



procedure Tfrm_Gen.picCloseMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  picClose_hDC: HDC;

begin
  picClose_hDC := picClose.Picture.Bitmap.Canvas.Handle;
  BitBlt(picClose_hDC, 0, 0, 9, 9, PicMapDC, 144, 182, SRCCOPY);
  picClose.Refresh;
  Unit1.frmMain.Button2Click(Sender);
end;



procedure Tfrm_Gen.picFormResizeMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if FormFlag = False then
  begin
    FX := picFormResize.Left + (picFormResize.Width div 2);
    FY := picFormResize.Top + (picFormResize.Height div 2);
    AX := x;
    AY := y;
    FormFlag := True;
    FormFirst := True;
    //fTimer := GetTickCount + 2; //Timer
  end;
end;



procedure Tfrm_Gen.picFormResizeMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
var
  posW:  Dword;
  posH:  Dword;
  formW: Dword;
  formH: Dword;
begin

  if FormFlag = True then
  begin
    //If GetTickCount < fTimer Then Exit;
    //fTimer := GetTickCount  + 2; //Timer

    // Maus in picFormResize einfangen.
    MouseTrap(picFormResize, x, y);

    if FormFirst = True then
    begin
      posW := (FX + x) - x;
    end else
      posW := (FX + x) - AX;

    if FormFirst = True then
    begin
      posH := (FY + y) - y;
    end else
      posH := (FY + y) - AY;

    if posW < 261 then
      posW := 261;

    if posH < 99 then
      posH := 99;
    if FormFirst = True then
    begin
      FX := FX;
    end else
      FX := posW;

    if FormFirst = True then
    begin
      FY := FY;
    end else
      FY := posH;

    if FormFirst = False then
    begin
      picFormResize.Left := FX;
      picFormResize.Top := FY;
      formW := FX + 14;
      formH := FY + 14;
      frm_Gen.Width := formW;
      frm_Gen.Height := formH;
    end;
    // Maus wieder freigeben
    MouseTrap_Release;
    FormFirst := False;
  end;
end;



procedure Tfrm_Gen.picFormResizeMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  FormFlag := False;

end;



procedure Tfrm_Gen.picTopFMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  SetFullWindowDrag(frm_Gen.Handle, True);

  SetFullWindowDrag(frm_Gen.Handle, False);
end;



procedure Tfrm_Gen.picTopLMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  SetFullWindowDrag(frm_Gen.Handle, True);

  SetFullWindowDrag(frm_Gen.Handle, False);
end;



procedure Tfrm_Gen.picTopMDblClick(Sender: TObject);
begin
  ScaleScreen;
end;



procedure Tfrm_Gen.picTopMMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  SetFullWindowDrag(frm_Gen.Handle, True);

  SetFullWindowDrag(frm_Gen.Handle, False);
end;



procedure Tfrm_Gen.picTopTextMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  SetFullWindowDrag(frm_Gen.Handle, True);

  SetFullWindowDrag(frm_Gen.Handle, False);
end;

procedure Tfrm_Gen.picTopTextSrcMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  SetFullWindowDrag(frm_Gen.Handle, True);

  SetFullWindowDrag(frm_Gen.Handle, False);
end;



function Split(const Source, Delimiter: string): TSplitStrArray;
var
  spCount:  integer;
  spPos:    integer;
  spLength: integer;
  sTemp:    string;
  aSplit:   TSplitStrArray;

begin
  sTemp    := Source;
  spCount  := 0;
  spLength := Length(Delimiter) - 1;
  repeat
    spPos := Pos(Delimiter, sTemp);
    if spPos = 0 then
      break
    else
    begin
      Inc(spCount);
      SetLength(aSplit, spCount);
      aSplit[spCount - 1] := Copy(sTemp, 1, spPos - 1);
      Delete(sTemp, 1, spPos + spLength);
    end;

  until False;
  if Length(sTemp) > 0 then
  begin
    Inc(spCount);
    SetLength(aSplit, spCount);
    aSplit[spCount - 1] := sTemp;
  end;

  Result := aSplit;

end;



function Tfrm_Gen.SetFullWindowDrag(hwnd: DWORD; ShowFullWindow: boolean): boolean;

  // Aktiviert oder deaktiviert die Anzeige von Fensterinhalten während des 
  // Ziehens oder der Größenänderung von Anwendungsfenstern. 
  // Der Rückgabewert gibt Aufschluss darüber, ob der Aufruf zu einer Änderung
  // gegenüber der vorherigen Einstellung geführt hat (True) oder nicht (False). 
var
  lOldSetting: integer;

begin
  // Bisherige Einstellung ermitteln: 

  Result := SystemParametersInfo(SPI_GETDRAGFULLWINDOWS, 0, @lOldSetting, 0);
  if Result = False then
    // Der abfragende Aufruf war nicht erfolgreich
    // (z.B. Windows 95 ohne "PLUS!"-Pack).
    Exit; // Rückgabewert bleibt False

  // Eine Aktion ist nur dann notwendig, wenn sich der bisherige
  // vom gewünschten Wert unterscheidet:
  if Bool(lOldSetting) <> ShowFullWindow then
  begin
    // Wert ändern und Erfolg prüfen:
    Result := SystemParametersInfo(SPI_SETDRAGFULLWINDOWS,
      Abs(DWORD(ShowFullWindow)), nil,
      SPIF_UPDATEINIFILE or SPIF_SENDWININICHANGE);
    if bool(Result) = True then
    begin
      Result := True;
      ReleaseCapture;
      SendMessage(hwnd, WM_NCLBUTTONDOWN, HTCAPTION, 0);
    end;
  end;
end;


procedure Tfrm_Gen.MouseTrap(Sender: TObject; X, Y: integer);
var
  R:     TRECT;
  Image: TImage;
begin
  Image := (Sender as TImage);
  // Image-Koordinaten in Bildschirmkoordinaten umrechnen
  R     := Image.ClientRect;
  with Image.ClientOrigin do
    OffsetRect(R, X, Y);
  // Bewegung des Mauszeigers einschränken 
  ClipCursor(@R);

end;

procedure Tfrm_Gen.MouseTrap_Release;
begin
  ClipCursor(nil);
end;

end.
