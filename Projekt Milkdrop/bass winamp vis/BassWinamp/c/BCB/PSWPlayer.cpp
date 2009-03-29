//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("PSWPlayer.res");
USEFORM("BSWExemple.cpp", BForm);
USELIB("Bass.lib");
USELIB("bass_winamp.lib");
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
        try
        {
                 Application->Initialize();
                 Application->Title = "BCB BassWA Player";
                 Application->CreateForm(__classid(TBForm), &BForm);
                 Application->Run();
        }
        catch (Exception &exception)
        {
                 Application->ShowException(&exception);
        }
        return 0;
}
//---------------------------------------------------------------------------
