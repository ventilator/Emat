program Emat;

{$mode delphi}{$H+}

{$R Emat.res}

uses
  Interfaces,
  Forms,
  Classes,
  SysUtils,
  gliste2,
  rmkGradient,
  TBXDock2003,
  TBXProgressBar,
  WAVfile,
  WMAfile,
  Bass,
  U_BassPlayer,
  UDatenbank,
  uincex,
  UInfo,
  Ulang,
  Ulaut,
  UListe,
  ump3,
  Usave,
  USpieler,
  Ustart,
  UStatus,
  Mp3FileUtils,
  UnitWDBIPCObjects,
  UnitWDBIPCDemoObj,
  BASSPlayer,
  TBXZezioTheme,
  rmkThemes,
  TBXAluminumTheme,
  TBXAthenTheme,
  TBXDamsokaTheme,
  TBXDefaultTheme,
  TBXDreamTheme,
  TBXEchoTheme,
  TBXEos9Theme,
  TBXEosTheme,
  TBXMirandaTheme,
  TBXMonaiTheme,
  TBXMonaiXPTheme,
  TBXNewOfficeAdaptiveTheme,
  TBXNewOfficeTheme,
  TBXNexos2Theme,
  TBXNexos3Theme,
  TBXNexos4Theme,
  TBXNexos5Theme,
  TBXNexosXTheme,
  TBXOffice11AdaptiveTheme,
  TBXOffice11XPTheme,
  TBXOffice2003Theme,
  TBXSolarizedLightTheme,
  TBXOfficeKTheme,
  TBXOfficeXPTheme,
  TBXProfessionalTheme,
  TBXReliferTheme,
  TBXRomaTheme,
  TBXSentimoXTheme,
  TBXStripesTheme,
  TBXTristan2Theme,
  TBXTristanTheme,
  TBXWhidbeyTheme,
  TBXXitoTheme,
  TBXOfficeCTheme;

begin
  Application.Initialize;
  Application.Title := 'Emat';
  try
    Application.CreateForm(TFmp3, Fmp3);
    Application.CreateForm(TFInfo, FInfo);
    Application.CreateForm(TFlaut, Flaut);
    Application.CreateForm(TFstart, Fstart);
    Application.CreateForm(TFStatus, FStatus);
  except
    on E: Exception do
      with TStringList.Create do
      try
        Add(E.ClassName + ': ' + E.Message);
        SaveToFile(ExtractFilePath(ParamStr(0)) + 'startup_error.txt');
      finally
        Free;
      end;
  end;
  try
    Application.Run;
  except
    on E: Exception do
      with TStringList.Create do
      try
        Add('RUN ' + E.ClassName + ': ' + E.Message);
        SaveToFile(ExtractFilePath(ParamStr(0)) + 'startup_error.txt');
      finally
        Free;
      end;
  end;
end.
