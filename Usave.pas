unit Usave;

interface

uses inifiles,dialogs,sysutils;

type Tplayliste = record
       filename : string[255];
       path     : string[255];
       eintraege : integer;
      end;

type Tplaylisten = array of tplayliste;

type TSave = class (TObject)

 private
    ini:Tinifile;

 public
    constructor Create(iniFileName:string);
    procedure S_Playlisten(playlisten:tplaylisten);
    function L_Playlisten:tplaylisten;
 end;


implementation

uses ump3;

constructor TSave.Create(iniFileName:string);
 begin
   ini:=Tinifile.Create(iniFilename);
 end;

procedure TSave.S_Playlisten(playlisten:tplaylisten);
 var datei : file of tplayliste;
     i     : integer;
 begin
  assign(datei,'playlisten.dat');
  try
   rewrite(datei);
  except
   messagedlg('"playlisten.dat" kann nicht gelesen werden.',mtwarning,[mbOK],0);
   exit;
  end;
  Reset(Datei);
  for i:=0 to High(playlisten) do
  Write(Datei,playlisten[i]);

  CloseFile(Datei);
 end;

function TSave.L_Playlisten:tplaylisten;
 var datei : file of tplayliste;
     playlisten : tplaylisten;
     i     : integer;
begin
  if fileexists('playlisten.dat') then
  begin
   AssignFile(Datei,'playlisten.dat');
   Reset(Datei);

   for i:=0 to FileSize(Datei)-1 do
   begin
    SetLength(Playlisten,High(Playlisten)+2);
    Read(Datei,Playlisten[High(Playlisten)]); 
   end;
   Result:=playlisten;
  end;
end;

end.
