program WinampTest;

uses
  Forms,
  SysUtils,
  Windows,
  Bass in '..\Bass.pas',
  BassVis in '..\BassVis.pas',
  Unit1 in 'Unit1.pas' {frmMain},
  WinampMsg in 'WinampMsg.pas',
  frmGen in 'frmGen.pas' {frm_Gen};

{$R *.res}


begin

  Application.Initialize;
  Application.Title := 'BassVis Winamp example';
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(Tfrm_Gen, frm_Gen);
  Application.Run;
end.

