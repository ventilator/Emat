// BASS Internet radio example, copyright (c) 2002-2007 Ian Luck.

#include <windows.h>
#include <process.h>
#include <stdio.h>
#include "bass.h"


HWND win=NULL;
DWORD cthread=0;
HSTREAM chan;

const char *urls[10]={ // stream URLs
	"http://www.radioparadise.com/musiclinks/rp_128-9.m3u","http://www.radioparadise.com/musiclinks/rp_32.m3u",
	"http://www.sky.fm/mp3/classical.pls","http://www.sky.fm/mp3/classical_low.pls",
	"http://www.sky.fm/mp3/the80s.pls","http://www.sky.fm/mp3/the80s_low.pls",
	"http://bassdrive.com/v2/streams/BassDrive.m3u","http://bassdrive.com/v2/streams/BassDrive3.m3u",
	"http://somafm.com/secretagent.pls","http://somafm.com/secretagent24.pls"
};

char proxy[100]=""; // proxy server

// display error messages
void Error(const char *es)
{
	char mes[200];
	sprintf(mes,"%s\n(error code: %d)",es,BASS_ErrorGetCode());
	MessageBox(win,mes,0,0);
}

#define MESS(id,m,w,l) SendDlgItemMessage(win,id,m,(WPARAM)w,(LPARAM)l)

// update stream title from metadata
void DoMeta(const char *meta)
{
	char *p;
	if (meta && (p=strstr(meta,"StreamTitle='"))) {
		p=strdup(p+13);
		strchr(p,';')[-1]=0;
		MESS(30,WM_SETTEXT,0,p);
		free(p);
	}
}

void CALLBACK MetaSync(HSYNC handle, DWORD channel, DWORD data, DWORD user)
{
	DoMeta((char*)data);
}

void CALLBACK EndSync(HSYNC handle, DWORD channel, DWORD data, DWORD user)
{
	MESS(31,WM_SETTEXT,0,"not playing");
	MESS(30,WM_SETTEXT,0,"");
	MESS(32,WM_SETTEXT,0,"");
}

void CALLBACK StatusProc(const void *buffer,DWORD length,DWORD user)
{
	if (buffer && !length)
		MESS(32,WM_SETTEXT,0,buffer); // display connection status
}

void __cdecl OpenURL(char *url)
{
	KillTimer(win,0); // stop prebuffer monitoring
	BASS_StreamFree(chan); // close old stream
	MESS(31,WM_SETTEXT,0,"connecting...");
	MESS(30,WM_SETTEXT,0,"");
	MESS(32,WM_SETTEXT,0,"");
	if (!(chan=BASS_StreamCreateURL(url,0,BASS_STREAM_STATUS|BASS_STREAM_AUTOFREE,StatusProc,0))) {
		MESS(31,WM_SETTEXT,0,"not playing");
		Error("Can't play the stream");
	} else
		SetTimer(win,0,50,0); // start prebuffer monitoring
	cthread=0;
}

BOOL CALLBACK dialogproc(HWND h,UINT m,WPARAM w,LPARAM l)
{
	switch (m) {
		case WM_TIMER:
			{ // monitor prebuffering progress
				DWORD len=BASS_StreamGetFilePosition(chan,BASS_FILEPOS_END);
				DWORD progress=(BASS_StreamGetFilePosition(chan,BASS_FILEPOS_DOWNLOAD)
					-BASS_StreamGetFilePosition(chan,BASS_FILEPOS_CURRENT))*100/len; // percentage of buffer filled
				if (progress>75 || !BASS_StreamGetFilePosition(chan,BASS_FILEPOS_CONNECTED)) { // over 75% full (or end of download)
					KillTimer(win,0); // finished prebuffering, stop monitoring
					{ // get the broadcast name and bitrate
						const char *icy=BASS_ChannelGetTags(chan,BASS_TAG_ICY);
						if (!icy) icy=BASS_ChannelGetTags(chan,BASS_TAG_HTTP); // no ICY tags, try HTTP
						if (icy) {
							for (;*icy;icy+=strlen(icy)+1) {
								if (!strnicmp(icy,"icy-name:",9))
									MESS(31,WM_SETTEXT,0,icy+9);
								if (!strnicmp(icy,"icy-br:",7)) {
									char br[30]="bitrate: ";
									strcat(br,icy+7);
									MESS(32,WM_SETTEXT,0,br);
								}
							}
						} else
							MESS(31,WM_SETTEXT,0,"");
					}
					// get the stream title and set sync for subsequent titles
					DoMeta(BASS_ChannelGetTags(chan,BASS_TAG_META));
					BASS_ChannelSetSync(chan,BASS_SYNC_META,0,&MetaSync,0);
					// set sync for end of stream
					BASS_ChannelSetSync(chan,BASS_SYNC_END,0,&EndSync,0);
					// play it!
					BASS_ChannelPlay(chan,FALSE);
				} else {
					char text[20];
					sprintf(text,"buffering... %d%%",progress);
					MESS(31,WM_SETTEXT,0,text);
				}
			}
			break;

		case WM_COMMAND:
			switch (LOWORD(w)) {
				case IDCANCEL:
					DestroyWindow(h);
					return 1;
				case 41:
					if (MESS(41,BM_GETCHECK,0,0))
						BASS_SetConfig(BASS_CONFIG_NET_PROXY,0); // disable proxy
					else
						BASS_SetConfig(BASS_CONFIG_NET_PROXY,(DWORD)proxy); // enable proxy
					break;
				default:
					if (LOWORD(w)>=10 && LOWORD(w)<20) {
						if (cthread) { // already connecting
							MessageBeep(0);
							break;
						}
						GetDlgItemText(win,40,proxy,sizeof(proxy)-1); // get proxy server
						// open URL in a new thread (so that main thread is free)
						cthread=_beginthread(OpenURL,0,urls[LOWORD(w)-10]);
					}
			}
			break;

		case WM_INITDIALOG:
			win=h;
			// setup output device
			if (!BASS_Init(-1,44100,0,win,NULL)) {
				Error("Can't initialize device");
				DestroyWindow(win);
			}
			BASS_SetConfig(BASS_CONFIG_NET_PLAYLIST,1); // enable playlist processing
			BASS_SetConfig(BASS_CONFIG_NET_PREBUF,0); // minimize automatic pre-buffering, so we can do it (and display it) instead
			BASS_SetConfig(BASS_CONFIG_NET_PROXY,(DWORD)proxy); // setup proxy server location
			return 1;

		case WM_DESTROY:
			BASS_Free();
			break;
	}
	return 0;
}

int PASCAL WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,LPSTR lpCmdLine, int nCmdShow)
{
	// check the correct BASS was loaded
	if (HIWORD(BASS_GetVersion())!=BASSVERSION) {
		MessageBox(0,"An incorrect version of BASS.DLL was loaded",0,MB_ICONERROR);
		return 0;
	}

	// display the window
	DialogBox(hInstance,MAKEINTRESOURCE(1000),0,&dialogproc);

	return 0;
}
