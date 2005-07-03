// Unit PluginConfig Ver 1.1
//
//  This unit takes charge of configuring Winamp input plug-ins for TBASSPlayer
//
//    written by Silhwan Hyun  hsh@chollian.net
//
//
// Ver 1.1                         15 Feb 2003
//   Changed the goRangeSelect property of PluginGrid from true to false
//       (bug fix : to prohibit multiple selection of plug-ins to unload)
//
// Ver 1.0                         30 Jan 2003
//   - Initial release
//

unit PluginConfig;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, PluginCtrl;

type
  TPluginConfigForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    PluginGrid: TStringGrid;
    Label3: TLabel;
    btnLoad: TButton;
    btnUnload: TButton;
    btnAbout: TButton;
    btnConfigure: TButton;
    btnClose: TButton;
    Label4: TLabel;
    Label5: TLabel;
    PluginFirst: TCheckBox;
    Label6: TLabel;
    Label7: TLabel;
    PluginList: TStringGrid;
    procedure ClearPluginGrid;
    procedure FillPluginGrid;
    procedure btnCloseClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnUnloadClick(Sender: TObject);
    procedure btnConfigureClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure PluginFirstClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PluginGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure PluginListDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

{var
  PluginConfigForm: TPluginConfigForm; }

  procedure SetMessageHandle(MessageHandle : hwnd);

implementation

{$R *.DFM}


var
   LoadCounter : integer;
   PluginCounter : integer;
   CurSelection : TGridRect;
   IndexNum : integer;
   PluginName : string;
   MainMessageHandle : hwnd;

procedure SetMessageHandle(MessageHandle : hwnd);
begin
   MainMessageHandle := MessageHandle;
end;

procedure TPluginConfigForm.ClearPluginGrid;
var
   i : integer;
begin
   with PluginGrid do
   begin
     Perform(WM_SETREDRAW, 0, 0);  // block visual updates
     try
       for i := FixedRows to RowCount - 1 do
         Rows[i].Clear;
     finally
       Perform(WM_SETREDRAW, 1, 0);
       Invalidate;
     end;
   end;
end;

procedure TPluginConfigForm.FillPluginGrid;
var
   i : integer;
   WinampPlugin : TPlugin;
   WinampPluginInfo : TPluginInfo;
begin
   LoadCounter := 0;
   for i := 0 to MaxPluginNum - 1 do
   begin
      WinampPlugin := GetPlugin(i);
      if WinampPlugin <> nil then     // APlugin = nil -> empty element
      begin
         WinampPluginInfo := GetPluginInfo(i);
         inc(LoadCounter);
         PluginGrid.Cells[0, LoadCounter] := WinampPluginInfo.Name;
         PluginGrid.Cells[1, LoadCounter] := WinampPluginInfo.Description;
         PluginGrid.Cells[2, LoadCounter] := WinampPluginInfo.FileExtensions;
      end;
   end;
end;

procedure TPluginConfigForm.btnCloseClick(Sender: TObject);
begin
   Close;
end;


procedure TPluginConfigForm.btnLoadClick(Sender: TObject);
const
   msg1 = 'No plug-in to load';
   msg2 = 'Select plug-in to load first';
   msg3 = 'Load denied : Output plug-in is not ready';
   msg4 = 'Load denied : Already loaded before';
   msg5 = 'Load denied : Max. number of plug-ins loaded';
   msg6 = 'Load denied : Unknown Error';
   msg7 = 'Load denied : Not a valid Winamp 2 input plug-in';
var
   WinampPluginInfo : TPluginInfo;
begin
   IndexNum := PluginList.Selection.Top;
   PluginName := PluginList.Cells[0, IndexNum];
   if PluginName = '' then
   begin
      Application.MessageBox(msg2, 'Confirm', MB_OK);
      exit;
   end;

   case LoadWinampPlugin(PluginName) of
      0 : begin      // 0 : No error
             inc(LoadCounter);
             IndexNum := GetPluginIndex(PluginName);
             WinampPluginInfo := GetPluginInfo(IndexNum);
             PluginGrid.Cells[0, LoadCounter] := WinampPluginInfo.Name;
             PluginGrid.Cells[1, LoadCounter] := WinampPluginInfo.Description;
             PluginGrid.Cells[2, LoadCounter] := WinampPluginInfo.FileExtensions;

            { if LoadCounter = 1 then
             begin } // put the 1st plug-in to selected state
                CurSelection.Top := LoadCounter;
                CurSelection.Left := 0;
                CurSelection.Right := 2;
                CurSelection.Bottom := LoadCounter;
                PluginGrid.Selection := CurSelection;
            { end; }
             PluginList.Invalidate;
         //    btnLoad.Enabled := false;
          end;
      ERROR_OMOD_NOTREADY : Application.MessageBox(msg3, 'Confirm', MB_OK);
      ERROR_LOADED_BEFORE : Application.MessageBox(msg4, 'Confirm', MB_OK);
      ERROR_LOADED_FULL   : Application.MessageBox(msg5, 'Confirm', MB_OK);
      ERROR_CANNOT_LOAD   : Application.MessageBox(msg6, 'Confirm', MB_OK);
      ERROR_INVALID_PLUGIN : Application.MessageBox(msg7, 'Confirm', MB_OK);
   end;
end;


procedure TPluginConfigForm.btnUnloadClick(Sender: TObject);
const
   msg1 = 'No plug-ins are loaded';
   msg2 = 'Select plug-in to unload first';
   msg3 = 'Cannot unload : Unknown Error';
   msg4 = 'Cannot unload : Plug-in is not loaded';
   msg5 = 'Cannot unload : Plug-in is in use';

begin
   if LoadCounter = 0 then
   begin
      Application.MessageBox(msg1, 'Confirm', MB_OK);
      exit;
   end;

   CurSelection := PluginGrid.Selection;
   if CurSelection.Top = -1 then
   begin
      Application.MessageBox(msg2, 'Confirm', MB_OK);
      exit;
   end;

   PluginName := PluginGrid.Cells[0, CurSelection.Top];
   if PluginName = '' then
   begin
      Application.MessageBox(msg2, 'Confirm', MB_OK);
      exit;
   end;

   case UnloadWinampPlugin(PluginName) of
      0 : begin
            if CurSelection.Top = LoadCounter then   // the last item in PluginGrid ?
            begin
               PluginGrid.Cells[0, LoadCounter] := '';
               PluginGrid.Cells[1, LoadCounter] := '';
               PluginGrid.Cells[2, LoadCounter] := '';
               dec(LoadCounter);
               if LoadCounter > 0 then
               begin  // Move selected position
                  CurSelection.Top := LoadCounter;
                  CurSelection.Left := 0;
                  CurSelection.Right := 2;
                  CurSelection.Bottom := LoadCounter;
               end else
               begin  // No selected position
                  CurSelection.Top := -1;
                  CurSelection.Left := 0;
                  CurSelection.Right := 2;
                  CurSelection.Bottom := -1;
               end;
               PluginGrid.Selection := CurSelection;
            end else
            begin
               ClearPluginGrid;
               FillPluginGrid;
            end;
            PluginList.Invalidate;
         end;
      ERROR_CANNOT_UNLOAD : Application.MessageBox(msg3, 'Confirm', MB_OK);
      ERROR_NOT_LOADED : Application.MessageBox(msg4, 'Confirm', MB_OK);
      ERROR_IN_USE     : Application.MessageBox(msg5, 'Confirm', MB_OK);
   end;
end;


procedure TPluginConfigForm.btnAboutClick(Sender: TObject);
const
   msg1 = 'Select plug-in to query first';
   msg2 = 'No plug-ins to query are loaded';
var
   WinampPlugin : TPlugin;
   PluginNum : integer;
begin
   if LoadCounter = 0 then
   begin
      Application.MessageBox(msg2, 'Confirm', MB_OK);
      exit;
   end;

   CurSelection := PluginGrid.Selection;
   if CurSelection.Top = -1 then
   begin
      Application.MessageBox(msg1, 'Confirm', MB_OK);
      exit;
   end;
   PluginName := PluginGrid.Cells[0, CurSelection.Top];
   if PluginName = '' then
   begin
      Application.MessageBox(msg1, 'Confirm', MB_OK);
      exit;
   end;

   PluginNum := GetPluginIndex(PluginName);
   WinampPlugin := GetPlugin(PluginNum);
   WinampPlugin.About(Self.Handle);
end;

procedure TPluginConfigForm.btnConfigureClick(Sender: TObject);
const
   msg1 = 'Select plug-in to configure first';
   msg2 = 'No plug-ins to configure are loaded';
var
   WinampPlugin : TPlugin;
   PluginNum : integer;
begin
   if LoadCounter = 0 then
   begin
      Application.MessageBox(msg2, 'Confirm', MB_OK);
      exit;
   end;

   CurSelection := PluginGrid.Selection;
   if CurSelection.Top = -1 then
   begin
      Application.MessageBox(msg1, 'Confirm', MB_OK);
      exit;
   end;
   PluginName := PluginGrid.Cells[0, CurSelection.Top];
   if PluginName = '' then
   begin
      Application.MessageBox(msg1, 'Confirm', MB_OK);
      exit;
   end;

   PluginNum := GetPluginIndex(PluginName);
   WinampPlugin := GetPlugin(PluginNum);
   WinampPlugin.config(Self.Handle);
end;

procedure TPluginConfigForm.PluginFirstClick(Sender: TObject);
var
   msgPluginFirst : longint;
begin
   if PluginFirst.Checked then
      msgPluginFirst := 1
   else
      msgPluginFirst := 0;

 // I do not know the method how to hand over a value of Form's element to its parent's
 //  (in this case PluginConfigForm.Checked -> TBASSPlayer.FPluginFirst)
 // So I simply use PostMessage API call.
   PostMessage(MainMessageHandle, WM_PluginFirst_Changed, 0, msgPluginFirst);
end;


procedure TPluginConfigForm.FormShow(Sender: TObject);
var
   GridRect : TGridRect;
   SearchRec : TSearchRec;
   i : integer;
begin
 // Clear PluginList's contents
   PluginList.RowCount := 1;
   PluginList.Cells[0, 0] := '';
   btnLoad.Enabled := false;
   
   i := 0;
   if FindFirst(GetProgDir + 'Plugins\in_*.dll', 0, SearchRec) = 0 then
   begin
  //    PluginConfigForm.PluginList.Items.Add(SearchRec.Name);
      PluginList.Cells[0, 0] := SearchRec.Name;
      i := 1;
      while FindNext(SearchRec) = 0 do
      begin
     //    PluginConfigForm.PluginList.Items.Add(SearchRec.Name);
         PluginList.RowCount := i + 1;
         PluginList.Cells[0, i] := SearchRec.Name;
         inc(i);
      end;
   end;
   FindClose(SearchRec);
   PluginCounter := i;

   ClearPluginGrid;
   FillPluginGrid;

   if PluginCounter = 0 then   // There are no plug-ins.
   begin
      GridRect.Top := -1;
      GridRect.Left := -1;
      GridRect.Right := -1;
      GridRect.Bottom := -1;
      PluginList.Selection := GridRect;
      PluginList.Enabled := false;
      PluginGrid.Enabled := false;
   end else
   begin
      GridRect.Top := 0;
      GridRect.Left := 0;
      GridRect.Right := 0;
      GridRect.Bottom := 0;
      PluginList.Selection := GridRect;
      PluginList.Enabled := true;
      PluginGrid.Enabled := true;
   end;

   if LoadCounter = 0 then   // There are no loaded plug-ins.
   begin
      GridRect.Top := -1;
      GridRect.Left := -1;
      GridRect.Right := -1;
      GridRect.Bottom := -1;
      PluginGrid.Selection := GridRect;
   end else
   begin
      GridRect.Top := 1;
      GridRect.Left := 0;
      GridRect.Bottom := 1;
      GridRect.Right := 2;
      PluginGrid.Selection := GridRect;
   end;

end;

procedure TPluginConfigForm.FormCreate(Sender: TObject);
begin
   with PluginGrid do
   begin
      Cells[0, 0] := 'Name';
      Cells[1, 0] := 'Decsription';
      Cells[2, 0] := 'Playable File Types';
   end;
end;

procedure TPluginConfigForm.PluginGridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
   if PluginGrid.Cells[ACol, ARow] = '' then
      CanSelect := false
   else
      CanSelect := true;
end;

procedure TPluginConfigForm.PluginListDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
   PluginName : string;
   PluginLoaded : boolean;
   i : integer;
begin
   PluginName := PluginList.Cells[0, ARow];

   PluginLoaded := false;
   for i := 1 to LoadCounter do
      if Uppercase(PluginGrid.Cells[0, i]) = Uppercase(PluginName) then
      begin
          PluginLoaded := true;
          break;
      end;

   with Sender as TDrawGrid do
   begin
      if gdSelected in State then
      begin
         Canvas.Brush.Color := clHighlight;
         if PluginLoaded then
            btnLoad.Enabled := false
         else
            btnLoad.Enabled := true;
      end else
         Canvas.Brush.Color := (Sender as TDrawGrid).Color;
      Canvas.FillRect(Rect);

      if PluginLoaded then
         Canvas.Font.Color := clLtGray
      else
         if gdSelected in State then
            Canvas.Font.Color := clWhite
         else
            Canvas.Font.Color := clBlack;

      Canvas.Font.Charset := ANSI_CHARSET;
      Canvas.Font.Name := 'Arial';
      Canvas.Font.Size := 9;
      Canvas.TextOut(Rect.Left + 3, Rect.Top + 1, PluginName);
      if gdFocused in State then
         Canvas.DrawFocusRect(Rect);
   end;
end;

end.
