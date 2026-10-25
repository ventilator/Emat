unit UStatus;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, TB2Dock,
  TBXDkPanels, TBXProgressBar, ComCtrls, StdCtrls;

type
  TFStatus = class(TForm)
    LTitel: TLabel;
    LName: TLabel;
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

{$R *.lfm}

end.
