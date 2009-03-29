//---------------------------------------------------------------------------
//        -----==== Sample project by CM [myjobs@mail.ru] =====-----
//         [ Thanks to Ian Luck! & XMinioNX for his BassWA Plugin ]  
#include <vcl.h>
#include <stdio.h>
#include <Filectrl.hpp>
#pragma hdrstop

#include "BSWExemple.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TBForm *BForm;
//---------------------------------------------------------------------------
__fastcall TBForm::TBForm(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TBForm::FormCreate(TObject *Sender)
{
  // Reset plugin count to zero
  PluginCount = 0;
  // Reset all the plugin handles to zero
  for(int i=0;i<255;i++) lstPlugins[i] = 0;
  // Our usual Bass stuff
  BASS_Init(1, 44100, 0, BForm->Handle, 0);
}
//---------------------------------------------------------------------------
void __fastcall TBForm::FormDestroy(TObject *Sender)
{
  //Free current stream
  BASS_StreamFree(Channel);
  // Unload all previously loaded plugins
  for(int i=0;i<PluginCount;i++) BASS_WINAMP_UnloadPlugin(lstPlugins[i]);
  // Free bass
  BASS_Free();
}
//---------------------------------------------------------------------------
void __fastcall TBForm::Button1Click(TObject *Sender)
{
  int i;
  String sDir;
  HPLUGIN TmpPlugin;
  TStringList *fList = new TStringList();
  try{
  // check if we have the plugin handle list already maxed out
  if(PluginCount == 256) return;

  // choose the dir to search
  if(SelectDirectory("Select directory to search for input plugins", "DESKTOP", sDir)==false) return;
  fList->CommaText = BASS_WINAMP_FindPlugins(sDir.c_str(),  BASS_WINAMP_FIND_INPUT | BASS_WINAMP_FIND_RECURSIVE | BASS_WINAMP_FIND_COMMALIST);

  for(i=0;i<fList->Count;i++)
   {
    // load our plugin
    TmpPlugin = BASS_WINAMP_LoadPlugin(fList->Strings[i].c_str());
    // check if a valid handle was returned
    if (TmpPlugin != 0)
    {
      // add the new plugin as our last one in the list
      lstPlugins[PluginCount] = TmpPlugin;
      // increment our plugin count
      PluginCount++;
      // add the name to the list box
      ListBox1->Items->Add(StrPas(BASS_WINAMP_GetName(TmpPlugin)));
    };
  }
  }
  __finally
  {
    delete fList;
  }
}           
//---------------------------------------------------------------------------
void __fastcall TBForm::Button2Click(TObject *Sender)
{
  BASS_WINAMP_InfoDlg(OpenDialog1->FileName.c_str());
}
//---------------------------------------------------------------------------
void __fastcall TBForm::Button3Click(TObject *Sender)
{
  // open plugin's config window
  if(ListBox1->ItemIndex >= 0 && ListBox1->ItemIndex < ListBox1->Items->Count)
    BASS_WINAMP_ConfigPlugin(lstPlugins[ListBox1->ItemIndex]);
}
//---------------------------------------------------------------------------
void __fastcall TBForm::Button4Click(TObject *Sender)
{
  // display plugin's about
  if (ListBox1->ItemIndex >= 0 && ListBox1->ItemIndex < ListBox1->Items->Count)
    BASS_WINAMP_AboutPlugin(lstPlugins[ListBox1->ItemIndex]);
}
//---------------------------------------------------------------------------
void __fastcall TBForm::Button5Click(TObject *Sender)
{
  char *FileExtentions;
  // Free previous chan
  BASS_StreamFree(Channel);

  OpenDialog1->Filter = "All Files(*.*)|*.*|";

  for(int i=0;i<PluginCount;i++)
  {
    // Filter Name|*.fil|Filter Name2|*.fil2
    FileExtentions=BASS_WINAMP_GetExtentions(lstPlugins[i]);
    while(FileExtentions[0]!=0)
    {
       OpenDialog1->Filter = OpenDialog1->Filter + FileExtentions + '|';
       FileExtentions=&FileExtentions[0]+strlen(FileExtentions)+1;
     }
  }
  // open file
  if (!OpenDialog1->Execute()) return;

  // Create our stream, just like a regular BASS_StreamCreateFile
  Channel = BASS_WINAMP_StreamCreate(OpenDialog1->FileName.c_str(),BASS_SAMPLE_SOFTWARE | BASS_STREAM_AUTOFREE);
    if (Channel != 0){
       BASS_StreamPreBuf(Channel);
     }
}
//---------------------------------------------------------------------------
void __fastcall TBForm::Button8Click(TObject *Sender)
{
  if (Channel != 0)
  {
    BASS_StreamPreBuf(Channel);
    BASS_StreamPlay(Channel, false, 0);
  }
}
//---------------------------------------------------------------------------
void __fastcall TBForm::Button6Click(TObject *Sender)
{
  // The rest is just like any other regular stream
  if (BASS_ChannelIsActive(Channel) == BASS_ACTIVE_PLAYING) BASS_ChannelPause(Channel);
  else if(BASS_ChannelIsActive(Channel) == BASS_ACTIVE_PAUSED) BASS_ChannelResume(Channel);
}
//---------------------------------------------------------------------------
void __fastcall TBForm::Button7Click(TObject *Sender)
{
  // The rest is just like any other regular stream
  BASS_ChannelStop(Channel);
  BASS_StreamFree(Channel);
}
//---------------------------------------------------------------------------
void __fastcall TBForm::Timer1Timer(TObject *Sender)
{
  int Pos, Len;
  // The rest is just like any other regular stream
  Pos = BASS_ChannelBytes2Seconds(Channel, BASS_ChannelGetPosition(Channel));
  Len = BASS_ChannelBytes2Seconds(Channel, BASS_StreamGetLength(Channel));

  if (Pos < 0) Pos = 0;
  if (Len < 0) Len = 0;
  //Time position & length calculation to view in Label1
  char OutTime[20]="";
  sprintf(OutTime,"%02d:%02d/%02d:%02d",Pos/60,Pos-60*(Pos/60),Len/60,Len-60*(Len/60));
  Label1->Caption=OutTime;
  //Getting CPU usage by BASS
  Label2->Caption=FloatToStr(BASS_GetCPU());

  ScrollBar1->Max = Len;
  ScrollBar1->Position = Pos;  
}
//---------------------------------------------------------------------------
void __fastcall TBForm::ScrollBar1Scroll(TObject *Sender,
      TScrollCode ScrollCode, int &ScrollPos)
{
  if (ScrollCode == scEndScroll)
  {
    // The rest is just like any other regular stream
    BASS_ChannelSetPosition(Channel, BASS_ChannelSeconds2Bytes(Channel, ScrollPos));
    Timer1->Enabled = true;
  }
  else Timer1->Enabled = false;
}
//---------------------------------------------------------------------------
void __fastcall TBForm::ListBox1DblClick(TObject *Sender)
{
Button3Click(Button3);
}
//---------------------------------------------------------------------------

