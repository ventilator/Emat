program Emat;

{%HTMLTool 'changelog.html'}

uses
  Forms,
  gliste2 in 'source\komponent\gliste2.pas',
  rmkGradient in 'source\komponent\rmkGradient.pas',
  TBXDock2003 in 'source\komponent\TBXDock2003.pas',
  TBXProgressBar in 'source\komponent\TBXProgressBar.pas',
  OggVorbis in 'source\id3\OggVorbis.pas',
  WAVfile in 'source\id3\WAVfile.pas',
  WMAfile in 'source\id3\WMAfile.pas',
  Bass in 'source\render\Bass.pas',
  FKBassPlayer in 'source\render\FKBassPlayer.pas',
  GFX in 'source\render\GFX.pas',
  U_BassPlayer in 'source\render\U_BassPlayer.pas',
  VisThread in 'source\render\VisThread.pas',
  UDatenbank in 'source\form\UDatenbank.pas',
  uincex in 'source\form\uincex.pas',
  UInfo in 'source\form\UInfo.pas' {FInfo},
  Ulang in 'source\form\Ulang.pas',
  Ulaut in 'source\form\Ulaut.pas' {Flaut},
  UListe in 'source\form\UListe.pas' {FPlayliste},
  ump3 in 'source\form\ump3.pas' {Fmp3},
  Usave in 'source\form\Usave.pas',
  USpieler in 'source\form\USpieler.pas',
  Ustart in 'source\form\Ustart.pas' {Fstart},
  rmkThemes in 'source\Themes\rmkThemes.pas',
  TBXAthenTheme in 'source\Themes\TBXAthenTheme.pas',
  TBXDreamTheme in 'source\Themes\TBXDreamTheme.pas',
  TBXEosTheme in 'source\Themes\TBXEosTheme.pas',
  TBXMirandaTheme in 'source\Themes\TBXMirandaTheme.pas',
  TBXMonaiTheme in 'source\Themes\TBXMonaiTheme.pas',
  TBXMonaiXPTheme in 'source\Themes\TBXMonaiXPTheme.pas',
  TBXNexos2Theme in 'source\Themes\TBXNexos2Theme.pas',
  TBXNexos3Theme in 'source\Themes\TBXNexos3Theme.pas',
  TBXNexos4Theme in 'source\Themes\TBXNexos4Theme.pas',
  TBXNexos5Theme in 'source\Themes\TBXNexos5Theme.pas',
  TBXNexosXTheme in 'source\Themes\TBXNexosXTheme.pas',
  TBXOffice11AdaptiveTheme in 'source\Themes\TBXOffice11AdaptiveTheme.pas',
  TBXOfficeCTheme in 'source\Themes\TBXOfficeCTheme.pas',
  TBXOfficeKTheme in 'source\Themes\TBXOfficeKTheme.pas',
  TBXReliferTheme in 'source\Themes\TBXReliferTheme.pas',
  TBXRomaTheme in 'source\Themes\TBXRomaTheme.pas',
  TBXSentimoXTheme in 'source\Themes\TBXSentimoXTheme.pas',
  TBXTristan2Theme in 'source\Themes\TBXTristan2Theme.pas',
  TBXTristanTheme in 'source\Themes\TBXTristanTheme.pas',
  TBXWhidbeyTheme in 'source\Themes\TBXWhidbeyTheme.pas',
  TBXXitoTheme in 'source\Themes\TBXXitoTheme.pas',
  TBXZezioTheme in 'source\Themes\TBXZezioTheme.pas',
  TBXOffice2003Theme in 'source\Themes\TBXOffice2003Theme.pas',
  UStatus in 'source\form\UStatus.pas' {FStatus},
  Mp3FileUtils in 'source\id3\Mp3FileUtils.pas',
  UnitWDBIPCObjects in 'source\hook\UnitWDBIPCObjects.pas',
  UnitWDBIPCDemoObj in 'source\hook\UnitWDBIPCDemoObj.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Emat';
  Application.CreateForm(TFmp3, Fmp3);
  Application.CreateForm(TFInfo, FInfo);
  Application.CreateForm(TFlaut, Flaut);
  Application.CreateForm(TFstart, Fstart);
  Application.CreateForm(TFStatus, FStatus);
  Application.Run;
end.
