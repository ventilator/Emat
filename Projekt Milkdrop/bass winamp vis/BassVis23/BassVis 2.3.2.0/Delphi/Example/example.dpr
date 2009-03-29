program example;

uses
  Forms,
  mainU in 'mainU.pas' {frmain},
  listselect in 'listselect.pas' {frListSelect},
  displayU in 'displayU.pas' {frmdisplay};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfrmain, frmain);
  Application.CreateForm(Tfrmdisplay, frmdisplay);
  Application.Run;
end.
