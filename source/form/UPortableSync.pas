unit UPortableSync;

{ Portable Device Sync ("Tragbares Geraet") dialog:
  Copies the active playlist (or selected tracks) to a chosen USB drive or
  target directory, with flat or Artist\Album layout, skip-existing option,
  progress bar, and optional .m3u8 playlist export on the target device. }

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ComCtrls, Dialogs, FileUtil,
  UDatenbank, ULangMgr;

type
  TPortableSyncForm = class(TForm)
  private
    FEdtTarget: TEdit;
    FBtnBrowse: TButton;
    FCBSubdirs: TCheckBox;
    FCBSkipExisting: TCheckBox;
    FCBWriteM3U8: TCheckBox;
    FProgress: TProgressBar;
    FLblStatus: TLabel;
    FBtnStart: TButton;
    FBtnClose: TButton;
    FDatenbank: TDatenbank;
    FListenNummer: Integer;
    FCancelled: Boolean;
    FRunning: Boolean;
    function SanitizeName(const S: string): string;
    procedure DoBrowse(Sender: TObject);
    procedure DoStart(Sender: TObject);
    procedure DoCloseClick(Sender: TObject);
  public
    constructor CreateSync(AOwner: TComponent; ADatenbank: TDatenbank; AListenNummer: Integer);
  end;

procedure ShowPortableSyncDialog(AOwner: TComponent; ADatenbank: TDatenbank; AListenNummer: Integer);

implementation

procedure ShowPortableSyncDialog(AOwner: TComponent; ADatenbank: TDatenbank; AListenNummer: Integer);
var
  Dlg: TPortableSyncForm;
begin
  Dlg := TPortableSyncForm.CreateSync(AOwner, ADatenbank, AListenNummer);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

constructor TPortableSyncForm.CreateSync(AOwner: TComponent; ADatenbank: TDatenbank; AListenNummer: Integer);
var
  Lbl: TLabel;
begin
  inherited CreateNew(AOwner);
  FDatenbank := ADatenbank;
  FListenNummer := AListenNummer;

  Caption := Tr('Tragbares Gerät synchronisieren', 'Sync Portable Device');
  BorderStyle := bsDialog;
  Position := poScreenCenter;
  ClientWidth := 460;
  ClientHeight := 255;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.SetBounds(16, 16, 428, 18);
  Lbl.Caption := Tr('Zielordner / USB-Laufwerk:', 'Target Folder / USB Drive:');

  FEdtTarget := TEdit.Create(Self);
  FEdtTarget.Parent := Self;
  FEdtTarget.SetBounds(16, 38, 340, 24);

  FBtnBrowse := TButton.Create(Self);
  FBtnBrowse.Parent := Self;
  FBtnBrowse.SetBounds(364, 37, 80, 26);
  FBtnBrowse.Caption := Tr('Wählen...', 'Browse...');
  FBtnBrowse.OnClick := DoBrowse;

  FCBSubdirs := TCheckBox.Create(Self);
  FCBSubdirs.Parent := Self;
  FCBSubdirs.SetBounds(16, 74, 428, 22);
  FCBSubdirs.Caption := Tr('Unterordner nach Interpret\Album anlegen', 'Create Artist\Album subfolders');
  FCBSubdirs.Checked := False;

  FCBSkipExisting := TCheckBox.Create(Self);
  FCBSkipExisting.Parent := Self;
  FCBSkipExisting.SetBounds(16, 100, 428, 22);
  FCBSkipExisting.Caption := Tr('Bereits vorhandene Dateien überspringen', 'Skip existing files');
  FCBSkipExisting.Checked := True;

  FCBWriteM3U8 := TCheckBox.Create(Self);
  FCBWriteM3U8.Parent := Self;
  FCBWriteM3U8.SetBounds(16, 126, 428, 22);
  FCBWriteM3U8.Caption := Tr('M3U8-Playliste (Emat.m3u8) im Zielordner erstellen', 'Write M3U8 playlist (Emat.m3u8) in target folder');
  FCBWriteM3U8.Checked := True;

  FProgress := TProgressBar.Create(Self);
  FProgress.Parent := Self;
  FProgress.SetBounds(16, 160, 428, 22);

  FLblStatus := TLabel.Create(Self);
  FLblStatus.Parent := Self;
  FLblStatus.SetBounds(16, 188, 428, 20);
  if (FDatenbank <> nil) and FDatenbank.ListeExists(FListenNummer) then
    FLblStatus.Caption := Format(Tr('Bereit (%d Titel in aktiver Liste)', 'Ready (%d tracks in active playlist)'), [Length(FDatenbank.Mp3Daten[FListenNummer])])
  else
    FLblStatus.Caption := Tr('Keine aktive Playliste geladen.', 'No active playlist loaded.');

  FBtnStart := TButton.Create(Self);
  FBtnStart.Parent := Self;
  FBtnStart.SetBounds(252, 216, 92, 28);
  FBtnStart.Caption := Tr('Kopieren', 'Copy');
  FBtnStart.OnClick := DoStart;

  FBtnClose := TButton.Create(Self);
  FBtnClose.Parent := Self;
  FBtnClose.SetBounds(352, 216, 92, 28);
  FBtnClose.Caption := Tr('Schließen', 'Close');
  FBtnClose.OnClick := DoCloseClick;
end;

function TPortableSyncForm.SanitizeName(const S: string): string;
var
  i: Integer;
begin
  Result := Trim(S);
  for i := 1 to Length(Result) do
    if Result[i] in ['\', '/', ':', '*', '?', '"', '<', '>', '|'] then
      Result[i] := '_';
  if Result = '' then
    Result := 'Unbekannt';
end;

procedure TPortableSyncForm.DoBrowse(Sender: TObject);
var
  Dlg: TSelectDirectoryDialog;
begin
  Dlg := TSelectDirectoryDialog.Create(Self);
  try
    Dlg.Title := 'Zielordner für tragbares Gerät wählen';
    if DirectoryExists(FEdtTarget.Text) then
      Dlg.InitialDir := FEdtTarget.Text;
    if Dlg.Execute then
      FEdtTarget.Text := Dlg.FileName;
  finally
    Dlg.Free;
  end;
end;

procedure TPortableSyncForm.DoStart(Sender: TObject);
var
  TargetDir, SrcFile, SubDir, DestDir, DestFile, RelPath, Disp: string;
  M3U: TStringList;
  i, Total, Copied, Skipped, Failed: Integer;
begin
  if FRunning then Exit;
  if (FDatenbank = nil) or (not FDatenbank.ListeExists(FListenNummer)) then
  begin
    MessageDlg('Keine aktive Playliste vorhanden.', mtWarning, [mbOK], 0);
    Exit;
  end;
  TargetDir := Trim(FEdtTarget.Text);
  if (TargetDir = '') or (not DirectoryExists(TargetDir)) then
  begin
    MessageDlg('Bitte einen gültigen Zielordner auswählen.', mtWarning, [mbOK], 0);
    Exit;
  end;
  TargetDir := IncludeTrailingPathDelimiter(TargetDir);

  Total := Length(FDatenbank.Mp3Daten[FListenNummer]);
  if Total = 0 then
  begin
    FLblStatus.Caption := 'Liste ist leer.';
    Exit;
  end;

  FRunning := True;
  FCancelled := False;
  FBtnStart.Enabled := False;
  FBtnClose.Caption := 'Abbrechen';
  FProgress.Min := 0;
  FProgress.Max := Total;
  FProgress.Position := 0;
  Copied := 0;
  Skipped := 0;
  Failed := 0;

  M3U := TStringList.Create;
  try
    M3U.Add('#EXTM3U');
    for i := 0 to Total - 1 do
    begin
      if FCancelled then Break;
      with FDatenbank.Mp3Daten[FListenNummer, i] do
      begin
        if Path <> '' then
          SrcFile := IncludeTrailingPathDelimiter(Path) + Filename
        else
          SrcFile := Filename;

        if FCBSubdirs.Checked then
          SubDir := SanitizeName(id3tag.Artist) + '\' + SanitizeName(id3tag.Album) + '\'
        else
          SubDir := '';

        DestDir := TargetDir + SubDir;
        DestFile := DestDir + Filename;
        RelPath := SubDir + Filename;

        FLblStatus.Caption := Format('[%d/%d] %s', [i + 1, Total, Filename]);
        Application.ProcessMessages;

        if not FileExists(SrcFile) then
          Inc(Failed)
        else if FCBSkipExisting.Checked and FileExists(DestFile) then
        begin
          Inc(Skipped);
          if FCBWriteM3U8.Checked then
          begin
            Disp := ChangeFileExt(Filename, '');
            if id3tag.Titel <> '' then Disp := id3tag.Titel;
            M3U.Add(Format('#EXTINF:%d,%s', [id3tag.dauer, Disp]));
            M3U.Add(RelPath);
          end;
        end
        else
        begin
          ForceDirectories(DestDir);
          if CopyFile(SrcFile, DestFile, [cffOverwriteFile]) then
          begin
            Inc(Copied);
            if FCBWriteM3U8.Checked then
            begin
              Disp := ChangeFileExt(Filename, '');
              if id3tag.Titel <> '' then Disp := id3tag.Titel;
              M3U.Add(Format('#EXTINF:%d,%s', [id3tag.dauer, Disp]));
              M3U.Add(RelPath);
            end;
          end
          else
            Inc(Failed);
        end;
      end;
      FProgress.Position := i + 1;
    end;

    if FCBWriteM3U8.Checked and (not FCancelled) and (M3U.Count > 1) then
      M3U.SaveToFile(TargetDir + 'Emat.m3u8');
  finally
    M3U.Free;
    FRunning := False;
    FBtnStart.Enabled := True;
    FBtnClose.Caption := 'Schließen';
  end;

  if FCancelled then
    FLblStatus.Caption := Format('Abgebrochen: %d kopiert, %d übersprungen, %d Fehler.', [Copied, Skipped, Failed])
  else
    FLblStatus.Caption := Format('Fertig: %d kopiert, %d übersprungen, %d Fehler.', [Copied, Skipped, Failed]);
end;

procedure TPortableSyncForm.DoCloseClick(Sender: TObject);
begin
  if FRunning then
    FCancelled := True
  else
    Close;
end;

end.
