program Emat;

uses
  Forms,
  ump3 in 'ump3.pas' {Fmp3},
  UInfo in 'UInfo.pas' {FInfo},
  Ustart in 'Ustart.pas' {Fstart},
  Uoption in 'Uoption.pas' {Fsettings},
  Ubug in 'Ubug.pas' {Fbug},
  UId3tag in 'UId3tag.pas',
  uwarte in 'uwarte.pas' {FWarte},
  Ulaut in 'Ulaut.pas' {Flaut},
  Uvideo in 'Uvideo.pas' {Fvideo},
  Usave in 'Usave.pas',
  ump3player in 'ump3player.pas' {FMp3Player},
  U_BassPlayer in 'U_BassPlayer.pas',
  spectrum_vis in 'spectrum_vis.pas',
  CommonTypes in 'CommonTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFmp3, Fmp3);
  Application.CreateForm(TFInfo, FInfo);
  Application.CreateForm(TFstart, Fstart);
  Application.CreateForm(TFsettings, Fsettings);
  Application.CreateForm(TFbug, Fbug);
  Application.CreateForm(TFWarte, FWarte);
  Application.CreateForm(TFlaut, Flaut);
  Application.CreateForm(TFvideo, Fvideo);
  Application.CreateForm(TFMp3Player, FMp3Player);
  Application.Run;
end.
