unit UFrStatus;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, TBXDkPanels, TBXProgressBar;

type
  TFrStatus = class(TFrame)
    Progress: TTBXProgressBar;
    LLabel: TTBXLabel;
    TBXButton1: TTBXButton;
    TBXButton2: TTBXButton;
    Caption: TLabel;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

implementation

{$R *.lfm}

end.
