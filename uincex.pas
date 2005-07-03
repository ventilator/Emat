//David Grünewald 01.04.2005
//nospam@undeadking.tk

unit uincex;

interface
  procedure IncEx(var X: integer; max: integer; min: integer = 0); forward;

implementation

procedure IncEx(var X: integer; max: integer; min: integer = 0);
begin
  if X = max
    then X := min
    else inc(X);
end;

end.
 