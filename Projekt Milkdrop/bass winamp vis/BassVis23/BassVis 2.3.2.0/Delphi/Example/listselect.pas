unit listselect;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TfrListSelect = class(TForm)
    cbolist: TComboBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;


function SelectFromList(ACaption:string;AList:TStrings):integer;
implementation

{$R *.dfm}

function SelectFromList(ACaption:string;AList:TStrings):integer;
var
  dlg : TFrListSelect;

begin
  result := -1;

  dlg := TFrListSelect.Create(application);
  dlg.Caption := ACaption;
  dlg.cbolist.Items.Assign(AList);
  dlg.cbolist.ItemIndex := 0;
  if (dlg.ShowModal = mrOK) then
    result := dlg.cbolist.ItemIndex;
  dlg.free;
end;

end.
