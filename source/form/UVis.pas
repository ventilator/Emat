unit UVis;

{ Port: Fenster fuer die Winamp-Visualisierung (Milkdrop 2).
  Ersetzt das frueher benutzte TVisControlForm aus source/TBASSPlayer/Demo/
  VisPluginCtrl.pas, das nur eine Demo-Beigabe war und viele Abhaengigkeiten
  mitgebracht hat.

  Das Formular haelt nur ein Panel; dessen Handle wird dem BASS-Player als
  EMBED-Fenster uebergeben (VisEMBEDHandle), dort setzt der Vis-Treiber das
  Plug-in-Fenster hinein. Kein .lfm - die Steuerelemente entstehen im
  Konstruktor, damit das Unit ohne Ressource kompiliert. }

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, Graphics, Windows;

type
  TVisForm = class(TForm)
  private
    FPanel: TPanel;
    procedure DoResize(Sender: TObject);
    procedure ResizeVisWindow;
  public
    constructor Create(AOwner: TComponent); override;
    property VisPanel: TPanel read FPanel;
  end;

implementation

constructor TVisForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);

  Caption      := 'Emat - Visualisierung';
  BorderStyle  := bsSizeable;
  BorderIcons  := [biSystemMenu, biMinimize, biMaximize];
  Position     := poDesigned;
  SetBounds(160, 160, 800, 600);
  Color        := clBlack;
  KeyPreview   := True;
  OnResize     := DoResize;

  FPanel := TPanel.Create(Self);
  FPanel.Parent      := Self;
  FPanel.Align       := alClient;
  FPanel.BevelOuter  := bvNone;
  FPanel.BorderStyle := bsNone;
  FPanel.Color       := clBlack;
  FPanel.Caption     := '';
  FPanel.TabStop     := False;
end;

procedure TVisForm.DoResize(Sender: TObject);
begin
  ResizeVisWindow;
end;

procedure TVisForm.ResizeVisWindow;
{ Das Plug-in legt sein Fenster selbst an und haengt es unter das Panel. Beim
  Vergroessern des Formulars zieht LCL nur das Panel mit - das Vis-Fenster
  behaelt seine alte Groesse. Deshalb hier auf die Panel-Groesse bringen. }
var
  Child : HWND;
  R     : TRect;
begin
  if FPanel = nil then
    exit;
  Child := Windows.GetWindow(FPanel.Handle, GW_CHILD);
  if Child = 0 then
    exit;
  Windows.GetClientRect(FPanel.Handle, R);
  Windows.MoveWindow(Child, 0, 0, R.Right - R.Left, R.Bottom - R.Top, True);
end;

end.
