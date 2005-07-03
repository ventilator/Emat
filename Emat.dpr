program Emat;

uses
  Forms,
  ump3 in 'ump3.pas' {Fmp3},
  UInfo in 'UInfo.pas' {FInfo},
  Ustart in 'Ustart.pas' {Fstart},
  UId3tag in 'UId3tag.pas',
  Ulaut in 'Ulaut.pas' {Flaut},
  Usave in 'Usave.pas',
  BassPlayer in 'BassPlayer.pas',
  spectrum_vis in 'spectrum_vis.pas',
  CommonTypes in 'CommonTypes.pas',
  UListe in 'UListe.pas' {FPlayliste},
  UDatenbank in 'UDatenbank.pas',
  USpieler in 'USpieler.pas',
  Uscreenout in 'Uscreenout.pas' {Foutput},
  Ulang in 'Ulang.pas',
  osc_vis in 'osc_vis.pas',
  circle_vis in 'circle_vis.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFmp3, Fmp3);
  Application.CreateForm(TFInfo, FInfo);
  Application.CreateForm(TFstart, Fstart);
  Application.CreateForm(TFlaut, Flaut);
  Application.CreateForm(TFoutput, Foutput);
  Application.Run;
end.
