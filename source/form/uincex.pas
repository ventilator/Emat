unit uincex;


//ver 0.3

interface

uses dialogs,forms,StdCtrls;

  //David Grünewald 01.04.2005
  //undeadking@gmx.de
  procedure IncEx(var X: integer; max: integer; min: integer = 0);
  //Clg 30.10.05
  function  CopyEx(SourceString:string;Start,Stop:integer):string;
  //Clg 29.12.2005  by xaromz@DP
  function  NatCompare(const Item1, Item2: WideString): Integer;
  //http://www.swissdelphicenter.ch/de/showcode.php?id=1241
  //08.08.2010
  function MyMessageDialog(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; Captions: array of string): Integer;
implementation

uses sysutils;

procedure IncEx(var X: integer; max: integer; min: integer = 0);
begin
  if (X >= max) or (X < min)
    then X := min
    else inc(X);
end;

function CopyEx(SourceString:string;Start,Stop:integer):string;
var
  Len: integer;
begin
  Len := Length(SourceString);
  if (Len = 0) or (Start > Len) then
  begin
    Result := '';
    Exit;
  end;
  if Start < 1 then Start := 1;
  if (Stop = -1) or (Stop > Len) then Stop := Len;
  if Stop < Start then
  begin
    Result := '';
    Exit;
  end;
  Result := Copy(SourceString, Start, Stop - Start + 1);
end;

function NatCompare(const Item1, Item2: WideString): Integer;
var
  Start1, Start2: Integer;
  S1, S2: WideString;
  N1, N2: Boolean;

  function IsDigit(const C: WideChar): Boolean; 
  begin 
    Result := (C in [WideChar('0')..WideChar('9')]); 
  end; 

  function GetNext(const S: WideString; var Start: Integer; 
    var IsNumber: Boolean): WideString; 
  var 
    Len, 
    Laenge, 
    C: Integer; 
  begin 
    Len := Length(S); 
    if Start > Len then 
    begin 
      Result := ''; 
      Exit; 
    end; 

    // Beginnt eine Zahl? 
    IsNumber := IsDigit(S[Start]); 
    Laenge := 1; 

    for C := Start + 1 to Len do 
    begin 
      // Weiterhin eine Zahl/ein Wort? 
      if IsDigit(S[C]) = IsNumber then 
        Inc(Laenge) 
      else 
        Break; 
    end; 

    Result := Copy(S, Start, Laenge); 
    Inc(Start, Laenge); 
  end; 

  function CompareNumericStr(const A, B: WideString): Integer;
  var
    pA, pB, lenA, lenB: Integer;
  begin
    pA := 1;
    while (pA < Length(A)) and (A[pA] = '0') do Inc(pA);
    pB := 1;
    while (pB < Length(B)) and (B[pB] = '0') do Inc(pB);
    lenA := Length(A) - pA + 1;
    lenB := Length(B) - pB + 1;
    if lenA <> lenB then
      Result := lenA - lenB
    else
      Result := WideCompareStr(Copy(A, pA, lenA), Copy(B, pB, lenB));
    if Result = 0 then
      Result := Length(A) - Length(B);
  end;

begin
  Result := 0; 

  // Beide gleich -> Raus hier 
  if Item1 = Item2 then 
    Exit; 

  Start1 := 1; 
  Start2 := 1; 
  // Alle Teile durchgehen 
  repeat 
    // Teile holen 
    S1 := GetNext(Item1, Start1, N1); 
    S2 := GetNext(Item2, Start2, N2); 

    // Haben wir zwei Zahlen? 
    if N1 and N2 then // Ja -> Zahlen Vergleichen (ohne Int32-Ueberlauf)
      Result := CompareNumericStr(S1, S2)
    else // Nein -> Normaler Stringvergleich 
      Result := WideCompareStr(S1, S2); 

  until (Result <> 0) or 
        (Start1 > Length(Item1)) or 
        (Start2 > Length(Item2)); 
end;

function MyMessageDialog(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; Captions: array of string): Integer;
var
  aMsgDlg: TForm;
  i: Integer;
  dlgButton: TButton;
  CaptionIndex: Integer;
begin
  { Create the Dialog }
  { Dialog erzeugen }
  aMsgDlg := CreateMessageDialog(Msg, DlgType, Buttons);
  try
    captionIndex := 0;
    { Loop through Objects in Dialog }
    { Über alle Objekte auf dem Dialog iterieren}
    for i := 0 to aMsgDlg.ComponentCount - 1 do
    begin
     { If the object is of type TButton, then }
     { Wenn es ein Button ist, dann...}
      if (aMsgDlg.Components[i] is TButton) then
      begin
        dlgButton := TButton(aMsgDlg.Components[i]);
        if CaptionIndex > High(Captions) then Break;
        { Give a new caption from our Captions array}
        { Schreibe Beschriftung entsprechend Captions array}
        dlgButton.Caption := Captions[CaptionIndex];
        Inc(CaptionIndex);
      end;
    end;
    Result := aMsgDlg.ShowModal;
  finally
    aMsgDlg.Free;
  end;
end;


end.
 