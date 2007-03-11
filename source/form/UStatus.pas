unit UStatus;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, LMDControl, LMDBaseControl,
  LMDBaseGraphicControl, LMDBaseLabel, LMDCustomLabel, LMDLabel, TB2Dock,
  TBXDkPanels, TBXProgressBar, ComCtrls;

type
  TFStatus = class(TForm)
    LTitel: TLMDLabel;
    LName: TLMDLabel;
    Animate1: TAnimate;
    TBXPB: TTBXProgressBar;
    TBXMultiDock1: TTBXMultiDock;
    TBXDockablePanel1: TTBXDockablePanel;
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
