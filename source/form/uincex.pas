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
  if X = max
    then X := min
    else inc(X);
end;

function CopyEx(SourceString:string;Start,Stop:integer):string;
var i:integer;
begin
  if stop=-1 then stop:=length(SourceString);
  Result:='';
  for i:=Start to Stop do
  Result:=Result+SourceString[i];
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
    if N1 and N2 then // Ja -> Zahlen Vergleichen 
      Result := StrToInt(S1) - StrToInt(S2)
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
end;


end.
 