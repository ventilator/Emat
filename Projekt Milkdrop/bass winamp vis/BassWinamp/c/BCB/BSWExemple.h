//---------------------------------------------------------------------------

#ifndef BSWExempleH
#define BSWExempleH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>

#include "Bass.h"
#include "BassWinamp.h"
#include <Dialogs.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TBForm : public TForm
{
__published:	// IDE-managed Components
        TListBox *ListBox1;
        TButton *Button1;
        TButton *Button2;
        TButton *Button3;
        TButton *Button4;
        TButton *Button5;
        TButton *Button6;
        TButton *Button7;
        TScrollBar *ScrollBar1;
        TButton *Button8;
        TOpenDialog *OpenDialog1;
        TTimer *Timer1;
        TLabel *Label1;
        TLabel *Label2;
        void __fastcall FormCreate(TObject *Sender);
        void __fastcall FormDestroy(TObject *Sender);
        void __fastcall Button1Click(TObject *Sender);
        void __fastcall Button2Click(TObject *Sender);
        void __fastcall Button3Click(TObject *Sender);
        void __fastcall Button4Click(TObject *Sender);
        void __fastcall Button5Click(TObject *Sender);
        void __fastcall Button8Click(TObject *Sender);
        void __fastcall Button6Click(TObject *Sender);
        void __fastcall Button7Click(TObject *Sender);
        void __fastcall Timer1Timer(TObject *Sender);
        void __fastcall ScrollBar1Scroll(TObject *Sender,
          TScrollCode ScrollCode, int &ScrollPos);
        void __fastcall ListBox1DblClick(TObject *Sender);
private:	// User declarations
    HSTREAM Channel;
    int PluginCount;
    HPLUGIN lstPlugins[255];
    void __fastcall GetTAG(int type);
public:		// User declarations
        __fastcall TBForm(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TBForm *BForm;
//---------------------------------------------------------------------------
#endif
