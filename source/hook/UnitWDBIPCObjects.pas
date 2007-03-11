//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
// UnitWDBIPCObjects.pas
//--------------------------------------------------------------------------*
// Copyright © 2005 wdbee
//--------------------------------------------------------------------------*
// TWDB_IPC - Klassen zur Interprozesskommunikation
// Basisklasse für IPCObjects und IPCObjectsManager
//--------------------------------------------------------------------------*
// Version: 0.00.000
// Stand:   29.03.2005
// Status:  Entwurf
//--------------------------------------------------------------------------*
// Hinweise:
// Diese Version wurde mit Delphi 5 entwickelt und getestet.
//
// Klassen, die von TWDB_IPCObject abgeleitet werden, erstellen ihre
// Instanzen in einem globalen Speicherbereich, der allen Prozessen
// zugänglich ist. Deshalb können sie zur Kommunikation zwischen
// verschiedenen Prozessen (Programmen) eingesetzt werden.
//
// Dabei gelten derzeit folgende Einschränkungen für alle Klassen, die von
// TWDB_IPCObject abgeleitet werden:
// 1. Es dürfen keine Typen eingesetzt werden, die dynamisch Speicher
//    beschaffen müssen (string, dynamische Arrays usw., ShortString ist ok)
//    Grund: Der dynamisch zugeordnete Speicher ist nur von dem Prozess aus
//    erreichbar, der ihn beschafft hat. Alle anderen Prozesse lösen einen
//    Zugriffsfehler aus!
// 2. Nur bei Nachfahren der ..VM-Klasse dürfen virtuelle Methoden definiert
//    werden.
//    Grund: Die Tabelle der virtuellen Methoden steht nur dem Prozess zur
//    Verfügung, der die Instanz erzeugt hat. Alle anderen Prozesse lösen
//    einen Zugriffsfehler aus! Die Objekte der VM-Klasse erfordern dagegen
//    einen Lock vor dem Zugriff und einen Unlock danach. Solange der Lock
//    besteht, ist eine lokal gültige VMT geladen!
// 3. Eine Folge von 2. ist, dass für Instanzen, die erzeugt wurden, kein
//    Destruktor aufgerufen werden darf! Dies ist aber auch nicht sinnvoll,
//    weil der Speicher durch das Betriebssystem verwaltet wird und erst
//    dann freigegeben werden darf, wenn der letzte Prozess, der sich für die
//    Nutzung angemeldet hatte, sich abgemeldet hat.
//
// Die Zuordnung der globalen Speicher zu den IPCObjects erfolgt
// über einen globalen Namen (max. 31 Zeichen, kein Bachslash).
// Sinnvollerweise sollten die Namen der Objectvariablen als Name für
// den Konstruktor verwendet werden. Alle Prozesse müssen natürlich den
// gleichen Namen verwenden. Verschiedene Namen erzeugen auch verschiedene
// Speicherbereiche, so dass mehrere Instanzen einer Klasse unabhängig
// voneinander genutzt werden können.
//
// Beispiel: Ein Prozess (Masterprogramm) definiert drei Instanzen
// Slave1, Slave2, Slave3 einer von TWDB_IPCObject abgeleiteten Klasse,
// drei Prozesse (Slaveprogramme) definieren dagegen nur je eine der
// Instanzen SlaveX (und die Instanz Commands).
// Dann kann das Masterprogramm den individuellen Status der
// Slaveprogramme feststellen. Über eine Instanz Commands einer anderen
// von TWDB_IPCObject abgeleiteten Klasse kann das Masterprogramm allen
// Slaves gleichzeitig Anweisungen schicken.
//--------------------------------------------------------------------------*
// Beispiel: IPC User Object
//--------------------------------------------------------------------------*
// type
//   TIPCUserObject = class(TWDB_IPCObject)
//   private
//     ...      // Nur Felder, die ihre Daten im Objekt speichern
//   protected
//     ...
//   public
//     ...     // Keine virtuellen odre dynamischen Methoden 
//   end;
//--------------------------------------------------------------------------*
//
// var
//   IPCObject: TIPCUserObject;
// ...
//   IPCObject := TIPCUserObject.Create('IPCObject');
//
//--------------------------------------------------------------------------*
//
// Die Verwaltung der An- und Abmeldungen, der Handles usw. übernimmt in der
// Regel eine Klasseninstanz (cDefaultManager: TWDB_IPCObjectManager)
// die mit der Unit initialisiert wird. Dieser DefaultManager reserviert
// sich für die Verwaltung und die Instanzen der IPCObjects einen globalen
// Speicherbereich von 65535 Bytes. Sollte das nicht ausreichen, kann eine
// eigene Instanz der Klasse TWDB_IPCObjectManager erzeugt werden, die
// sich einen größeren Speicherbereich reservieren kann.
//
// UserManager := TWDB_IPCObjectManager.Create('UserManager',Size);
//
// Instanzen, die mit diesem alternativen Manager verwaltet werden sollen,
// müssen mit diesem erzeugt werden (statt TIPCUserObject.Create!):
//
// UserObj := UserManager.AllocateObject('UserObj',TIPCUserObject);
//
// Manuell erzeugte Instanzen der Klasse TWDB_IPCObjectManager müssen
// auch manuell freigegeben werden:
//
// UserManager.Free;
//
//--------------------------------------------------------------------------*
// Änderungen:
// 29.03.2005 bz Implementiert
//--------------------------------------------------------------------------*
unit UnitWDBIPCObjects;

interface

uses
  SysUtils, Windows, Contnrs, Dialogs;
  
var
  gVMT: Cardinal;

//==========================================================================*
// Vorwärtsreferenzen
//--------------------------------------------------------------------------*
type
  IPCNameString = string[31];                    // Name eines IPCObjects
  PIPCNameString = ^IPCNameString;               // Zeiger darauf

  TWDB_IPCObjectBlock = record                   // Header des IPCObjects
    Size: Cardinal;                              //   InstanzeSize
    Count: Cardinal;                             //   Referenzzähler
    Name: IPCNameString;                         //   Name
  end;
  PTWDB_IPCObjectBlock = ^TWDB_IPCObjectBlock;

  TWDB_IPCLockResult = (lrSuccess, lrTimeout);   // Rückmeldung

  TWDB_IPCObject = class;                        // Basisklasse für IPCObject
  TWDB_IPCObjectVM = class;                      // IPCObject mit virt. Meth.
  TWDB_IPCObjectItem = class;                    // Verzeichniseintrag
  TWDB_IPCObjectManager = class;                 // Manager für IPCObjects
//==========================================================================*

//==========================================================================*
// Basisklasse für IPC Objects
//--------------------------------------------------------------------------*
  TWDB_IPCObject = class(TObject)
  private

  protected

  public
    class function DefaultManager:               // DefaultManager
      TWDB_IPCObjectManager;
    class procedure SetDefaultManager
      (Value: TWDB_IPCObjectManager);

    class function NewInstance: TObject;         // eigene Speicherverwaltung
      override;

    constructor Create(const Name: string);      // Konstruktor
      virtual;

    procedure AfterConstruction;                 // Debug
      override;

    procedure Free;                              // Eigene Version
      overload;

    procedure FreeInstance;                      // Dummy (tut nichts)
      override;

  end;
//==========================================================================*

//==========================================================================*
// Basisklasse für IPC Objects mit Virtuellen Methoden
//--------------------------------------------------------------------------*
  TWDB_IPCObjectVM = class(TWDB_IPCObject)
  private
    oLocked: Boolean;                            // Sperrstatus
  protected

  public
    function Lock                                // Sperren und
      (ClassRef: TClass;                         //   VMT lokalisieren
      Timeout: Integer = 1000;                   //   Timeout in ms
      Millis: Integer = 20)                      //   Timeslice in ms
      : TWDB_IPCLockResult;
    procedure Unlock;                            // Sperrung beenden
  end;
//==========================================================================*

//==========================================================================*
// IPC Object Manager
//--------------------------------------------------------------------------*
  TWDB_IPCObjectManager = class
  private // Interne Variablen:
    oName: string;                               // Name des Managers
    oSize: Cardinal;                             // Größe des Speichers

    oHandle: THandle;                            // Handle
    oCreated: Boolean;                           // Speicher ist neu angelegt
    oFileView: Pointer;                          // Lokale Sicht auf Speicher
    oNextObject: Pointer;                        // Beginn des nächsten Objs.
    oLastObject: Pointer;                        // Beginn des letzten Objs.

    oIPCObjects: TObjectList;                    // Liste der Objekte
    oMothersLittleHelper: TWDB_IPCObjectItem;

    function AllocateUnnamed                     // Für Konstruktoren abgel.
      (Size: Integer): Pointer;                  //   Klassen (NewInstance)
    function CheckObject                         // Nachtragen des Namens
      (Name: IPCNameString;                      // und Doublettenprüfung
       PObject: Pointer): Pointer;               // anhand des Namens
    function FindObject                          // IPCObject aus Liste
      (Name: IPCNameString): TWDB_IPCObjectItem;
    procedure Refresh;                           // Liste neu lesen

    function GetCount: Integer;

  protected

  public // Userinterface:
    constructor Create                           // Konstruktor
      (const Name: string; const Size: Cardinal);
    destructor Destroy;                          // Destruktor
      override;

    function AllocateObject                      // Objekt erzeugen
      (const Name: string; ClassType: TClass): Pointer;
    procedure FreeObject                         // Objekt freigeben
      (const Name: string);                      //

    function GetObject                           // Objekt holen
      (const Name: string): Pointer;

    function ReferenzCount(Name: string): Integer;

    property Count: Integer
      read GetCount;
  end;
//==========================================================================*

//==========================================================================*
// Nur für internen Gebrauch durch einen Manager:
// Eintrag eines IPC Objects in der Liste des Managers
//--------------------------------------------------------------------------*
  TWDB_IPCObjectItem = class(TObject)
  private
    oName: string;
    oOffset: Cardinal;
    oSize: Cardinal;
    oObject: Pointer;
    oItem: Pointer;
  protected
    procedure SetVMT(VMT: Cardinal);

  public
    constructor Create
      (Manager: TWDB_IPCObjectManager;           // Manager
       const Name: string;
       const Offset: Cardinal;
       const Size: Cardinal);

  end;
//==========================================================================*

implementation

//==========================================================================*
// Klassenvariablen
//--------------------------------------------------------------------------*
var
  cExecptionMessage: string;
  cDefaultManager: TWDB_IPCObjectManager;
//==========================================================================*

//==========================================================================*
// Exception mit formatierter Fehlermeldung auswerfen
//--------------------------------------------------------------------------*
procedure RaiseExceptionWithSystemErrorMessage(Msg: string);
var
  MsgBuffer: HLOCAL;                             // Puffer vom System angel.
begin
  FormatMessage(                                 // Klartext formatiert
    FORMAT_MESSAGE_ALLOCATE_BUFFER
      or FORMAT_MESSAGE_FROM_SYSTEM,
    nil,                                         // Default
    GetLastError,                                // Error holen
    0,                                           // Default language
    @MsgBuffer,                                  // Puffer
    0,                                           // Default
    nil);                                        // Default

  cExecptionMessage := Msg + ' ' + PChar(MsgBuffer);
  LocalFree( MsgBuffer );                        // Puffer freigeben

  raise Exception.Create(cExecptionMessage);
end;
//==========================================================================*

//==========================================================================*
// Formatierte Fehlermeldung
//--------------------------------------------------------------------------*
procedure SystemErrorMessage;
var
  MsgBuffer: HLOCAL;                             // Puffer vom System angel.
begin
  FormatMessage(                                 // Klartext formatiert
    FORMAT_MESSAGE_ALLOCATE_BUFFER
      or FORMAT_MESSAGE_FROM_SYSTEM,
    nil,                                         // Default
    GetLastError,                                // Error holen
    0,                                           // Default language
    @MsgBuffer,                                  // Puffer
    0,                                           // Default
    nil);                                        // Default

  MessageBox( 0, PChar(MsgBuffer),               // Anzeigen
    'GetLastError', MB_OK or MB_ICONINFORMATION );

  LocalFree( MsgBuffer );                        // Puffer freigeben
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObjectManager: Konstruktor
//--------------------------------------------------------------------------*
constructor TWDB_IPCObjectManager.Create
  (const Name: string; const Size: Cardinal);
var
  Si: TSystemInfo;                               // Info zur Granularität
  P: PTWDB_IPCObjectBlock;                       // Verzeichniseintrag
  LastError: Cardinal;
begin
  try
    oName := Name;                               // Name des Managers

    GetSystemInfo(Si);                           // Info zur Granularität
    oSize := Si.dwAllocationGranularity *        // Größe an Granularität
      (Size div Si.dwAllocationGranularity + 1); // anpassen

    oHandle := CreateFileMapping                 // Speicher beschaffen
      ($FFFFFFFF, nil, PAGE_READWRITE, 0,        // mit Schreib/Leserecht,
      oSize, PChar(Name));                       // Größe und Name
    if oHandle = 0 then                          // Erfolg überwachen
      abort;

    LastError := GetLastError;
    if (LastError <> 0) and (LastError <> ERROR_ALREADY_EXISTS) then
      SystemErrorMessage;

    // Bei ERROR_ALREADY_EXISTS oCreated = False
    oCreated := LastError = 0;                   // True wenn neu erzeugt!
    oIPCObjects := TObjectList.Create;           // Liste der IPC Objects

    oFileView := MapViewOfFile                   // Lokale Sicht auf den
      (oHandle, FILE_MAP_WRITE, 0, 0, oSize);    // Speicher erstellen

    if oFileView = nil then                      // Erfolg überwachen
      abort;

    P := oFileView;                              // Zeiger auf Anfang setzen
    if oCreated then
    begin
      P^.Size := oSize;                          // Größe eintragen
      P^.Count := 1;                             // Anzahl eintragen
      P^.Name := oName;                          // Managernamen eintragen
      Inc(P);                                    // Auf erstes Object
      oNextObject := P;                          // positionieren
      oLastObject := P;                          // positionieren
    end
    else
    begin
      Inc(P^.Count);                             // Anzahl eintragen
      Refresh;
    end;

  except
    if oHandle <> 0 then                         // Wenn vergeben, dann auch
      CloseHandle(oHandle);                      //   freigeben
    oHandle := 0;
    RaiseExceptionWithSystemErrorMessage(        // Problem melden
      Format('TWDB_IPCObjectManager: '
      + 'Error creating shared memory %s (%d)! ',
      [Name, GetLastError]));
  end;
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObjectManager: Destruktor
//--------------------------------------------------------------------------*
destructor TWDB_IPCObjectManager.Destroy;
begin
  FreeAndNil(oIPCObjects);                       // Objekte freigeben
  UnmapViewOfFile(oFileView);                    // Ansicht freigeben
  if oHandle <> 0 then                           // Wenn vergeben, dann auch
    CloseHandle(oHandle);                        //   freigeben
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObjectManager: Ein IPC Object erzeugen oder zuordnen
//--------------------------------------------------------------------------*
procedure TWDB_IPCObjectManager.Refresh;
var
  P: PTWDB_IPCObjectBlock;                       // Verzeichniseintrag
  Pb: PByte;
  Offset: Cardinal;
  IPCObject: TWDB_IPCObjectItem;
begin
  oIPCObjects.Clear;

  P := oFileView;                                // Zeiger auf Anfang setzen
  if P^.Size <> oSize then                       // Größe auslesen
    raise Exception.Create(
      'TWDB_IPCObjectManager.Create '
      + oName + ' Falsche Größe');
  if P^.Name <> oName then                       // Managernamen auslesen
    raise Exception.Create(
      'TWDB_IPCObjectManager.Create '
      + oName + ' Falscher Name');

  Inc(P);                                        // Auf erstes Object
  oNextObject := P;                              // positionieren
  while P^.Size <> 0 do
  begin
    oLastObject := oNextObject;                  // positionieren
    Offset :=
      Cardinal(oNextObject)
      - Cardinal(oFileView)
      + SizeOf(TWDB_IPCObjectBlock);
    IPCObject := TWDB_IPCObjectItem.Create
      (self,P^.Name,Offset,P^.Size);
    oIPCObjects.Add(IPCObject);
    Pb := IPCObject.oObject;
    Inc(Pb,P^.Size);
    P := Pointer(Pb);
    oNextObject := Pb;
  end;
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObjectManager: Ein IPC Object aus der Liste liefern
//--------------------------------------------------------------------------*
function TWDB_IPCObjectManager.GetObject
  (const Name: string): Pointer;
var
  IPCObjectItem: TWDB_IPCObjectItem;
begin
  IPCObjectItem := FindObject(Name);
  if IPCObjectItem = nil then
    Result := nil
  else
    Result := IPCObjectItem.oObject;
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObjectManager: Ein IPC Object in der Liste suchen
//--------------------------------------------------------------------------*
function TWDB_IPCObjectManager.FindObject
  (Name: IPCNameString): TWDB_IPCObjectItem;
var
  I: Integer;
  IPCObject: TWDB_IPCObjectItem;
begin
  Result := nil;

  // Prüfen, ob es diesen Speicherbereich schon gibt
  for I := 0 to oIPCObjects.Count - 1 do
  begin
    IPCObject := TWDB_IPCObjectItem(oIPCObjects[I]);
    if IPCObject.oName = Name then
    begin
      Result := IPCObject;
      break;
    end;
  end;
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObjectManager: Ein IPC Object erzeugen oder zuordnen
//--------------------------------------------------------------------------*
function TWDB_IPCObjectManager.AllocateObject
  (const Name: string; ClassType: TClass): Pointer;
var
  Offset: Cardinal;
  IPCObject: TWDB_IPCObjectItem;
  PSOB: PTWDB_IPCObjectBlock;
  P: PByte;
begin
  // Prüfen, ob es dieses IPCObject schon gibt
  IPCObject := FindObject(Name);

  // Wenn nicht, prüfen ob eine andere Instanz
  // den Block inzwischen angelegt hat
  if IPCObject = nil then
  begin
    Refresh;
    IPCObject := FindObject(Name);
  end;

  // Wenn nicht, Block anlegen
  if IPCObject = nil then
  begin
    oLastObject := oNextObject;                  // Anfang merken
    PSOB := oNextObject;                         // Verzeichniseintrag
    PSOB^.Size := ClassType.InstanceSize;        //   Größe eintragen
    PSOB^.Count := PSOB^.Count + 1;              //   Referenzzähler
    PSOB^.Name := Name;                          //   Namen eintragen

    Offset :=                                    // Position berechnen
      Cardinal(oNextObject)                      // aus letztem Objekt
      - Cardinal(oFileView)                      // Beginn des SharedMem
      + SizeOf(TWDB_IPCObjectBlock);             // und Größe des Eintrags

    IPCObject := TWDB_IPCObjectItem.Create       // Verzeichnis-Objekt erz.
      (self,Name,Offset,ClassType.InstanceSize);

    oIPCObjects.Add(IPCObject);                  // In die Liste aufnehmen
    Result := IPCObject.oObject;                 // Zeiger auf das Objekt
    ClassType.InitInstance(Result);              // Objekt initialisieren
    P := IPCObject.oObject;                      // Position des nächsten
    Inc(P,ClassType.InstanceSize);               // Objekts bestimmen
    oNextObject := P;                            // und merken
  end
  else
  begin
    Result := IPCObject.oObject;
    PSOB := IPCObject.oItem;
    PSOB^.Count := PSOB^.Count + 1;              // Referenzzähler
  end;
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObjectManager: Ein IPC Object freigeben
// Stellt z. Zt. nur den Referenzzähler zurück (für Debugzwecke)
//--------------------------------------------------------------------------*
procedure TWDB_IPCObjectManager.FreeObject
  (const Name: string);
var
  I: Integer;
  SharedObject: TWDB_IPCObjectItem;
  PSOB: PTWDB_IPCObjectBlock;
begin
  // Prüfen, ob es diesen Speicherbereich schon gibt
  for I := 0 to oIPCObjects.Count - 1 do
  begin
    SharedObject := TWDB_IPCObjectItem(oIPCObjects[I]);
    if SharedObject.oName = Name then
    begin
      PSOB := SharedObject.oItem;
      PSOB^.Count := PSOB^.Count - 1;            // Referenzzähler
      break;
    end;
  end;
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObjectManager: Ein IPC Object ohne Namen erzeugen
//--------------------------------------------------------------------------*
function TWDB_IPCObjectManager.AllocateUnnamed
  (Size: Integer): Pointer;
var
  Offset: Cardinal;
  SharedObject: TWDB_IPCObjectItem;
  P: PByte;
begin
  oLastObject := oNextObject;

  Offset :=
    Cardinal(oNextObject)
    - Cardinal(oFileView)
    + SizeOf(TWDB_IPCObjectBlock);

  SharedObject := TWDB_IPCObjectItem.Create
    (self,'',Offset,Size);

  oMothersLittleHelper := SharedObject;

  Result := SharedObject.oObject;

  P := SharedObject.oObject;
  Inc(P,Size);
  oNextObject := P;
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObjectManager: Namen nachtragen und Doublettenprüfung
//--------------------------------------------------------------------------*
function TWDB_IPCObjectManager.CheckObject
  (Name: IPCNameString; PObject: Pointer): Pointer;
var
  SharedObject: TWDB_IPCObjectItem;
  PSOB: PTWDB_IPCObjectBlock;
  P: ^Cardinal;
begin
  // Prüfen, ob es dieses IPCObject schon gibt
  SharedObject := FindObject(Name);

  if SharedObject <> nil then
  begin
    // Objekt war schon vorhanden
    Result := SharedObject.oObject;
    // Zeiger der VMT umbiegen
    P := oMothersLittleHelper.oObject;
    SharedObject.SetVMT(P^);
    PSOB := SharedObject.oItem;
    Inc(PSOB.Count);
    oNextObject := oLastObject;
  end
  else
  begin
    // Objekt war noch nicht vorhanden
    oIPCObjects.Add(oMothersLittleHelper);
    Result := PObject;
    SharedObject := FindObject('');
    SharedObject.oName := Name;
    PSOB := oLastObject;
    PSOB.Name := Name;
    PSOB.Size := SharedObject.oSize;
    PSOB.Count := 1;
  end;
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObjectManager: Anzahl der Manager
//--------------------------------------------------------------------------*
function TWDB_IPCObjectManager.GetCount: Integer;
var
  P: PTWDB_IPCObjectBlock;                       // Verzeichniseintrag
begin
  P := oFileView;                                // Zeiger auf Anfang setzen
  Result := P^.Count;                            // Anzahl ausgeben
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObjectManager: Referenzzähler zum Objekt
//--------------------------------------------------------------------------*
function TWDB_IPCObjectManager.ReferenzCount(Name: string): Integer;
var
  SharedObject: TWDB_IPCObjectItem;
  PSOB: PTWDB_IPCObjectBlock;                    // Verzeichniseintrag
begin
  Result := 0;

  Refresh;                                       // Objektliste auffrischen

  // Prüfen, ob es diesen Speicherbereich schon gibt
  SharedObject := FindObject(Name);

  if SharedObject <> nil then
  begin
    PSOB := SharedObject.oItem;
    Result := PSOB^.Count;                       // Referenzzähler ausgeben
  end;
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObjectItem: Konstruktor
//--------------------------------------------------------------------------*
constructor TWDB_IPCObjectItem.Create
  (Manager: TWDB_IPCObjectManager;
  const Name: string; const Offset: Cardinal; const Size: Cardinal);
var
  ByteBuffer: PByte;
begin
  try
    oName := Name;
    oOffset := Offset;
    oSize := Size;

    ByteBuffer := PByte(Manager.oFileView);
    Inc(ByteBuffer,Offset);
    oObject := ByteBuffer;
    Dec(ByteBuffer,SizeOf(TWDB_IPCObjectBlock));
    oItem := ByteBuffer;

  except
    RaiseExceptionWithSystemErrorMessage(
      Format('TWDB_IPCObject.Create: '
      + 'Error creating shared object %s (%d)! ',
      [Name, GetLastError]));
  end;
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObjectItem: VMT-Zeiger setzen
//--------------------------------------------------------------------------*
procedure TWDB_IPCObjectItem.SetVMT(VMT: Cardinal);
var
  P: ^Cardinal;
begin
  P := oObject;
  P^ := VMT;
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObject: Konstructor
//--------------------------------------------------------------------------*
constructor TWDB_IPCObject.Create(const Name: string);
begin
  try
    self := cDefaultManager.CheckObject(Name,self);
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObject: Speicher beschaffen
//--------------------------------------------------------------------------*
class function TWDB_IPCObject.NewInstance: TObject;
begin
  Result := cDefaultManager.AllocateUnnamed(InstanceSize);
  InitInstance(Result);
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObject: DefaultManager liefern
//--------------------------------------------------------------------------*
class function TWDB_IPCObject.DefaultManager: TWDB_IPCObjectManager;
begin
  Result := cDefaultManager;
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObject: DefaultManager liefern
//--------------------------------------------------------------------------*
class procedure TWDB_IPCObject.SetDefaultManager
  (Value: TWDB_IPCObjectManager);
begin
  cDefaultManager := Value;
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObject: (zur Kontrolle der Umsetzung der VMT)
//--------------------------------------------------------------------------*
procedure TWDB_IPCObject.AfterConstruction;
begin
  // nothing to do here
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObject: Wegen VMT+Speicherverwaltung übeschrieben
//--------------------------------------------------------------------------*
procedure TWDB_IPCObject.Free;
begin
  // nothing to do here
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObject: Wegen Speicherverwaltung übeschrieben
//--------------------------------------------------------------------------*
procedure TWDB_IPCObject.FreeInstance;
begin
  // nothing to do here
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObject: Objekt sperren
//--------------------------------------------------------------------------*
function TWDB_IPCObjectVM.Lock
  (ClassRef: TClass; Timeout: Integer = 1000; Millis: Integer = 20): TWDB_IPCLockResult;
var
  Tmp: TObject;
  P: ^Cardinal;
  PO: ^Cardinal;
  VMT: Cardinal;
  Loops: Integer;
begin
  Result := lrTimeout;
  Loops := 1 + Timeout div Millis;
  while oLocked do                               // Warten bis Obj. frei ist
  begin
    Dec(Loops);
    if Loops < 0 then
      Exit;
    Sleep(Millis);
  end;

  oLocked := True;                               // Sperrung anmelden
  Tmp := ClassRef.Create;                        // Ein temp. Object erzuegen
  P := Pointer(Tmp);                             // um eine lokal gültige
  VMT := P^;                                     // VMT zu bekommen

  PO := Pointer(self);                           // globale VMT
  PO^ := VMT;                                    // durch lokale ersetzen
  Tmp.Free;                                      // tmp. Obj. freigeben

  gVMT := VMT;

  Result := lrSuccess;
end;
//==========================================================================*

//==========================================================================*
// TWDB_IPCObject: Objekt entsperren
//--------------------------------------------------------------------------*
procedure TWDB_IPCObjectVM.Unlock;
begin
  oLocked := False;
end;
//==========================================================================*

//==========================================================================*
// WDB_IPC: Default Manager initialisieren
//--------------------------------------------------------------------------*
initialization
  cDefaultManager := TWDB_IPCObjectManager.Create('cDefaultManager',65535);
//==========================================================================*

//==========================================================================*
// WDB_IPC: Default Manager freigeben
//--------------------------------------------------------------------------*
finalization
  cDefaultManager.Free;
//==========================================================================*
end.
//--------------------------------------------------------------------------*
// end of file UnitWDBIPCObjects.pas
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*

