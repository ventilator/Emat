unit UStatus;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, LMDControl, LMDBaseControl,
  LMDBaseGraphicControl, LMDBaseLabel, LMDCustomLabel, LMDLabel, TB2Dock,
  TBXDkPanels, TBXProgressBar, ComCtrls, StdCtrls;

type
  TFStatus = class(TForm)
    LTitel: TLMDLabel;
    LName: TLMDLabel;
    TBXPB: TTBXProgressBar;
    TBXMultiDock1: TTBXMultiDock;
    TBXDockablePanel1: TTBXDockablePanel;
    LSpeed: TLabel;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  FStatus: TFStatus;

implementation

{$R *.dfm}

end.
