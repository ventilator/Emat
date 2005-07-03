// unit PluginCtrl
//
// This unit takes charge of followings for TBASSPlayer
//  - managing Winamp 2 plug-ins such as loading, unloading and launching plug-ins.
//  - interfacing Winamp 2 input plug-in to BASS sound system.
// BASS sound sytem acts like an output plug-in for Winamp 2 when you are using
// Winamp input plug-in by this unit.
// You can play any types of stream files with BASS sound system if you have
// appropriate Winamp 2 input plug-in.
//
//
//       written by Silhwan Hyun  hsh@chollian.net
//
//
// Ver 1.31                      14 Dec 2004
//  Made some minor modifications for new BASS version (2.0 -> 2.1)
//
//
// Ver 1.3                        7 Feb 2004
//   Added procedure SetSongDuration
//   Added function IsWinampPluginLoaded
//
//
// Ver 1.2                        15 Dec 2003
//   Added procedures used by VisoutIntf.pas to correct errors at ending visualizer
//   Added functions and a procedure for DSP plug-in
//   Added function GetPluginNumber to get the number of plug-in for specified file type
//
// Ver 1.1                        12 May 2003
//   Modified a procedure LoadVisModule (-> added a parameter "ParentHandle" )
//
// Ver 1.0                        30 Jan 2003
//   - Initial release
//

unit PluginCtrl;

interface

uses
   Windows, SysUtils, Messages, Forms, ioplug, Dynamic_BASS;

const
   MaxPluginNum = 8;                 // the maximum number of plug-ins, simultaneously loadable
   WM_WA_MPEG_EOF = WM_USER + 2;     // message from Winamp input plug-in at the end of playback
   WM_StartPlay = WM_USER + 101;     // message from output plug-in emulator at starting playback
//   WM_StreamOpen = WM_USER + 102;  // message from main program at opening stream file
   WM_StreamClose = WM_USER + 103;   // message from main program at closing stream file
//   WM_PosChange = WM_USER + 104;   // message from main program at changing play position
   WM_BASS_StreamCreate = WM_USER + 105; // message from output plug-in emulator at executing BASS_StreamCreate
   WM_BASS_StreamFree = WM_USER + 106;   // message from output plug-in emulator at executing BASS_StreamFree
   WM_PluginFirst_Changed = WM_USER + 109; // message from PluginConfigForm(=Input plug-in Configuration Form)
   WM_GetChannelInfo = WM_USER + 112;    // message from Winamp input plug-in at getting stream file's properties (sampling rate, ..)
   WM_GetFFTData = WM_USER + 113;        // message from Winamp input plug-in at getting FFT data

   MaxVolume = 255;                      // Winamp input plug-in volume range : 0 ~ 255

 // error types related loading & unloading of Winamp 2 input plug-ins
   ERROR_OMOD_NOTREADY  = 1;   // output plug-in emulator is not ready
   ERROR_LOADED_BEFORE  = 2;   // already loaded before
   ERROR_LOADED_FULL    = 3;   // no space to load
   ERROR_CANNOT_LOAD    = 4;   // uncertain error at loading
   ERROR_INVALID_PLUGIN = 5;   // not a Winamp 2 input plug-in
   ERROR_CANNOT_UNLOAD  = 6;   // uncertain error at unloading
   ERROR_NOT_LOADED     = 7;   // not loaded yet
   ERROR_IN_USE         = 8;   // specified plug-in is in use

   maxVismodNum = 8;
   maxDSPmodNum = 8;

  // constants for visualizer control
   DataReady = 10;
   QuitProg = 20;
   SyncWindows = 30;
   MinimizeWindow = 40;
   RestoreWindow = 50;
   VisModuleLoaded = 55;
   StartVisOut = 60;
   EndVisOut = 70;
 //  InformStatus = 80;
   InformPlayerMode = 81;
   InformStreamInfo = 82;
   InformSyncWindows = 83;
   QueryStatus = 90;

   stPlayerMode = 1;
   stStreamInfo = 2;
   stSyncWindows = 3;

type
   TPlugin = ^TIn_module;
   TPluginInfo = record
      Name : string;
      Version : integer;        // module type (IN_VER)
      Description : string;     // description of module, with version string
      FileExtensions : string;
      Seekable : integer;
      DLLHandle : THandle;
   end;
   TChannelInfo = record
      BitsPerSample : word;     // Bits per sample
      BitRate   : LongInt;
      SampleRate : LongInt;
      Duration : DWORD;         // playback duration in mili second
      Channels : Word;
   end;
   PChannelInfo = ^TChannelInfo;

   TVismod = array[0..maxVismodNum-1] of PWinAmpVisModule;
   TDSPmod = array[0..maxDSPmodNum-1] of PWinAmpDSPModule;

   TPlayerMode = (plmStandby, plmReady, plmStopped, plmPlaying, plmPaused);
   TStreamInfo = record
     FileName : string;
     FileSize : DWORD;        // File size in byte
     SampleRate : DWORD;      // Sampling rate in Hz
     BitRate : DWORD;         // Bit Rate in KBPS
     BitsPerSample : Word;    // Bits per sample
     Duration : DWORD;        // playback duration in mili second
     Channels : Word;         // 1- Mono, 2 - Stereo

     Title : string;
     Artist : string;
     Album : string;
     Year : string;
     Genre : string;
     GenreID : byte;
     Track : byte;
     Comment : string;
  end;

  procedure WinProcessMessages;
  function GetProgDir : string;
  function GetMsgHandler : hwnd;
  function OutputReady : boolean;
  procedure SetMainHandle(MainHandle : HWND);
  function GetMainHandle : HWND;
  function SelectInputPlugin(PluginNum : integer) : integer;
  procedure SetSongDuration(Duration : DWORD);  // * Added at ver 1.3
  procedure SetPosChanged;
//  procedure SetPlayEnded;
  function GetOutputTime(omodTime : boolean) : integer;
  function GetPluginIndex(PluginName : string) : integer;
  function GetPlugin(PluginNum : integer) : TPlugin;
  function GetPluginInfo(PluginNum : integer) : TPluginInfo;
  function IsWinampPluginLoaded(PluginName : string) : boolean;  // * Added at ver 1.3
  function LoadWinampPlugin(PluginName : string) : integer;
  function UnloadWinampPlugin(PluginName : string) : integer;
  function VisActive : boolean;
  procedure LoadVisModule(PluginName : string;
                          var Visheader : PWinampVisHeader;
                          var Vismod : TVismod;
                          var NumVismod : integer;
                          ParentHandle : HWND);
  function StartVisModule(ModuleNum : word) : integer;
  function UnloadVisModule : integer;
  function DSPActive : boolean;
  procedure LoadDSPModule(PluginName : string;
                          var DSPheader : PWinampDSPHeader;
                          var DSPmod : TDSPmod;
                          var NumDSPmod : integer;
                          ParentHandle : HWND);
  function StartDSPModule(ModuleNum : word) : integer;
  function StopDSPModule : integer;
  function UnloadDSPModule : integer;
  function GetPlayableFiles : string;
  function GetPluginNumber(ExtCode : string) : integer;
  function InitPluginCtrl : boolean;
  procedure QuitPluginCtrl;

// Following procedures are added to fix errors at ending visualizer
  procedure SetVisualizerQuitted;
  procedure SetVisOutHandle(VisOutHandle : HWND);

implementation


var
   pBuf : PBYTE;
   omod : ^TOut_module;
   imod : ^TIn_module;
   omod1 : TOut_module;
   imodNum   : integer;
   omodReady : boolean;
   Plugin : array[0..MaxPluginNum-1] of TPlugin;
   PluginInfo : array[0..MaxPluginNum-1] of TPluginInfo;
   hMainHandle : HWND;	 // handle of main message procedure in BASSPlayer.pas

   HBASSStream : HSTREAM;
   ChannelInfo : TChannelInfo;
   PosChanged : boolean;

   Vismods  : TVismod;
   VismodNum : integer = 0;
   VismodIndex : integer;
   VisIsActive : boolean = false;
   VisualizerQuitted : boolean = false;
   hVisOutWindow : HWND = 0; // handle of the window of visualizer

   DSPmods  : TDSPmod;
   DSPmodNum : integer = 0;
   DSPmodIndex : integer;
   DSPIsActive : boolean = false;


procedure WinProcessMessages;
// Allow Windows to process other system messages
var
    ProcMsg  :  TMsg;
begin
    while PeekMessage(ProcMsg, 0, 0, 0, PM_REMOVE) do begin
      if (ProcMsg.Message = WM_QUIT) then Exit;
      TranslateMessage(ProcMsg);
      DispatchMessage(ProcMsg);
    end;
end;


//---------- procedures & functions for Winamp input plug-in --------------------

procedure SetInfo1(bitrate, srate, stereo, synched : integer); cdecl; // if -1, changes ignored? :)
begin
   if (bitrate = -1) and (srate = -1) and (stereo = -1) then
      exit;

   if bitrate <> -1 then
      ChannelInfo.BitRate := bitrate;
   if srate <> -1 then
      ChannelInfo.SampleRate := srate;
   if stereo <> -1 then
      ChannelInfo.Channels := stereo;

   PostMessage(hMainHandle, WM_GetChannelInfo, 0, longint(@ChannelInfo));
end;

function dsp_isactive1 : integer; cdecl;
begin
   // result := 0;

 // Added to use DSP plug-in
   if DSPIsActive then
        result := 1
     else
        result := 0
end;

function dsp_dosamples1(samples : pointer; numsamples, bps, nch, srate : integer) : integer; cdecl;
var
  rtnsamples : integer;
begin
   result := numsamples;

 // Added to use DSP plug-in
   if DSPIsActive then
   begin
      rtnsamples := DSPmods[DSPmodIndex].ModifySamples(DSPmods[DSPmodIndex], samples, numsamples, bps, nch, srate);
      if rtnsamples > 0 then
         result:= rtnsamples;
   end;
end;

procedure SAVSAInit1(maxlatency_in_ms : integer; srate : integer); cdecl;  // call in omod.Play()
begin
end;

procedure SAVSADeInit1;cdecl;	// call in omod.Stop()
begin
end;

procedure SAAddPCMData1(PCMData: pointer; nch: integer; bps: integer; timestamp: integer); cdecl;
begin
end;

// gets csa (the current type (4=ws,2=osc,1=spec))
function SAGetMode1: integer; cdecl;
begin
   result := 0;
end;

// sets the spec data, filled in by winamp
procedure SAAdd1(data: pointer; timestamp: integer; csa: integer); cdecl;
begin
end;

// sets the vis data directly from PCM data
procedure VSAAddPCMData1(PCMData: pointer; nch: integer; bps: integer; timestamp: integer); cdecl;
begin
end;

// use to figure out what to give to VSAAdd
function VSAGetMode1(var specNch : integer; var waveNch : integer) : integer; cdecl;
begin
   result := 0;
end;

// filled in by winamp, called by plug-in
procedure VSAAdd1(data : pointer; timestamp : integer); cdecl;
begin
end;

procedure VSASetInfo1(srate : integer; nch : integer); cdecl;
begin
end;


//---------- procedures & functions to emulate Winamp output plug-in -----------

const
   bufSize = 88200;       // buffer size to hold 0.5sec playing data for 44100Hz, 16bit, stereo stream
   WinampBaseSize = 576;  // Winamp input plug-in's base size of data transfering

type
   TMsgHandler = class(TObject)
      procedure ProcMessage(var Msg: TMessage);
   end;

var
   rOffset : dword;
   wOffset : dword;
   SPS : integer;       // samplerate (samples per second)
   BPS : integer;       // bits per sample
   Channels : integer;  // number of channels (MONO = 1, STEREO = 2)
   BASSDataSize : integer;
   isReading : boolean;
   isWriting : boolean;
   posDelta : integer;
   totalWritten : int64;
   InitialBufferFill : boolean;
   PlayEnded : boolean;

   MsgHandler : TMsgHandler;
   MessageHandle2 : hwnd;

   ResumeMode : boolean;

// calulate free space of buffer (The buffer pointed by pBuf to hold sound data
// is used as ring buffer)
function FreeSpace(BufferSize, ReadOffset, WriteOffset : dword) : dword;
begin
   if ReadOffset > WriteOffset then
      result := ReadOffset - WriteOffset
   else
      result := BufferSize  - WriteOffset + ReadOffset;
end;

// calulate data space of buffer
function DataSpace(BufferSize, ReadOffset, WriteOffset : dword) : dword;
begin
   if ReadOffset > WriteOffset then
      result := BufferSize  + WriteOffset - ReadOffset
   else
      result := WriteOffset - ReadOffset;
end;

procedure TMsgHandler.ProcMessage(var Msg: TMessage);
begin
   case Msg.Msg of
     { WM_StreamOpen : begin
                           hMainHandle := Msg.wParam;  // main window's message handle
                           imodNum := Msg.lParam;      // index number of Winamp input plug-in to use
                      end; }
      WM_StreamClose : imodNum := -1;   // -1 : No plug-ins is in use
 //     WM_PosChange  : PosChanged := true;
      WM_StartPlay : begin
                        BASS_ChannelPlay(HBASSStream, false {flush});
                        ResumeMode := false;
                        if hMainHandle <> 0 then
                           PostMessage(hMainHandle, WM_StartPlay, Msg.wParam, Msg.lParam);
                     end;
      WM_WA_MPEG_EOF : begin
                          PlayEnded := true;
                          if hMainHandle <> 0 then
                             PostMessage(hMainHandle, WM_WA_MPEG_EOF, 0, 0);
                       end;
      WM_QueryEndSession : Msg.Result := 1;    // Allow system termination
 //     else Msg.Result := 1;
   end;
end;

// Stream writing callback function for BASS
function StreamWriter(handle : HSTREAM;
                      buffer : pointer;
                      length : DWORD;
                      user : DWORD) : DWORD; stdcall;
// The value of 'length'(data transfering size) is as follows for some cases
//  SPS : 48000, BPS : 16, Channels : 2 -> 38400
//  SPS : 44100, BPS : 16, Channels : 2 -> 35280
//  SPS : 22050, BPS : 8,  Channels : 1 -> 4410
var
   p, p2 : pointer;
   dw : dword;
   wCycle : word;
   OutputTime : DWORD;
begin
 // Let BASS wait until sound data is ready.
 // This waiting routine is not necessary in most cases.
 // This routine is added for the Winamp input plug-in "in_midi.dll" (v2.64,
 // written by Mr. Peter Pawlowski) which takes long time to get sound data after
 // changing play position.
   if not PlayEnded then
      if DataSpace(bufSize, rOffset, wOffset) < length then
      begin
      // Waiting cycle is allowed only when playback position is not at the near end
      // of a stream file.
      // I have found that in_speex.dll v0.7.5a sounds out echo(= repeats playback of
      // internal buffer) at the near end of a stream file. ( I think it is caused by
      // delayed message-out of WM_WA_MPEG_EOF message from in_speex.dll )
         OutputTime := posDelta + round(1000 * totalWritten / (SPS * (BPS SHR 3) * Channels));
         if (ChannelInfo.Duration > OutputTime) and   // OutputTime may be greater than ChannelInfo.Duration
            ((ChannelInfo.Duration - OutputTime) > 2000) then
         begin
            wCycle := 0;
            while DataSpace(bufSize, rOffset, wOffset) < length do
            begin
               WinProcessMessages;
               Sleep(50);
               inc(wCycle);
               if wCycle = 60 then     // 3 sec time out
                  break;
               if PlayEnded then
                  break;
            end;
            ResumeMode := false;
         end;
      end;

   while isWriting do  // avoid duplicate access on buffer
      begin
         WinProcessMessages;
         sleep(20);
      end;

   isReading := true;  // notify that BASS is reading buffer data
   dw := dword(pBuf) + rOffset;
   p := pointer(dw);   // p : starting address to read

   if rOffset > wOffset then
      if (bufSize - rOffset) > length then
      begin
         Move(p^, buffer^, length);
         inc(rOffset, length);
         result := length;
      end
      else if (bufSize - rOffset) = length then
      begin
         Move(p^, buffer^, bufSize - rOffset);
         rOffset := 0;
         result := length;
      end else // (bufSize - rOffset) < length
      begin
         Move(p^, buffer^, bufSize - rOffset);
         dw := dword(buffer) + bufSize - rOffset;
         p2 := pointer(dw);
         if (length - (bufSize - rOffset)) < wOffset then
         begin
            Move(pBuf^, p2^, length - (bufSize - rOffset));
            rOffset := length - (bufSize - rOffset);
            result := length;
         end else
         begin
            Move(pBuf^, p2^, wOffset);
            rOffset := wOffset;
            result := bufSize - rOffset + wOffset {+ BASS_STREAMPROC_END};
         end;
      end
   else if rOffset < wOffset then
      if (wOffset - rOffset) >= length then
      begin
         Move(p^, buffer^, length);
         inc(rOffset, length);
         result := length;
      end else
      begin
         Move(p^, buffer^, wOffset - rOffset);
      // signify that the end of the stream is reached
         result := wOffset - rOffset {+ BASS_STREAMPROC_END};
         rOffset := wOffset;
      end
   else   // rOffset = wOffset : no data in buffer
      result := BASS_STREAMPROC_END{0};

 // Let BASS wait until sound data is ready for long latency devices such CDROM
 // (for the delay time drive's spindle motor gets normal speed after stopping)
   if ResumeMode then
      if DataSpace(bufSize, rOffset, wOffset) < length then
      begin
         wCycle := 0;
         while not isWriting do  // until data is written
         begin
            WinProcessMessages;
            Sleep(200);
            inc(wCycle);
            if wCycle = 50 then  // 10 sec time out
                break;
         end;
         ResumeMode := false;
      end;

   isReading := false;
end;

procedure omodConfig(hwndParent : hwnd); cdecl; // configuration dialog
begin
   Application.MessageBox('No configuration is needed.', 'Confirm', MB_OK);
end;

procedure omodAbout(hwndParent : hwnd); cdecl;  // about dialog
begin
   Application.MessageBox('This is a Winamp output plug-in emulator using BASS',
                          'Confirm', MB_OK);
end;

procedure omodInit; cdecl;     // called when loaded
begin
   if omodReady then
      exit;

   MsgHandler := TMsgHandler.Create;
   MessageHandle2 := AllocateHWnd(MsgHandler.ProcMessage);
   omodReady := true;
end;

procedure omodQuit; cdecl;    // called when unloaded
begin
   if omodReady then
      omodReady := false;

   if MessageHandle2 <> 0 then
   begin
      DeallocateHWnd(MessageHandle2);
      MsgHandler.Free;
   end;
end;

function omodOpen(samplerate, numchannels, bitspersamp, bufferlenms,
                                           prebufferms : integer) : integer; cdecl;
// returns >=0 on success, <0 on failure
// called by input plug-in just before starting playback
var
   flags : DWORD;
begin
   if not omodReady then
   begin
      result := -1;
      exit;
   end;

   if bitspersamp = 8 then
      flags := BASS_SAMPLE_8BITS
   else
      flags := 0;

   HBASSStream := BASS_StreamCreate(samplerate,
                                    numchannels,
                                    flags,
                                    @StreamWriter,
                                    0 {DWORD user data});
   if HBASSStream = 0 then   // 0 : error
      result := -1
   else
   begin
      SPS := samplerate;
      BPS := bitspersamp;
      Channels := numchannels;
  // BASSDataSize : The data size of each transfering to BASS (= amount to play 0.2sec period)
      BASSDataSize := (SPS * (BPS div 8) * CHANNELS * 2) div 10;
      posDelta := 0;
      if hMainHandle <> 0 then
         PostMessage(hMainHandle, WM_BASS_StreamCreate, HBASSStream, 0);
      result := 0;
   end;

   rOffset := 0;
   wOffset := 0;
   totalWritten := 0;
   isReading := false;
   isWriting := false;
   PosChanged := false;
   InitialBufferFill := true;
   PlayEnded := false;
end;

procedure omodClose; cdecl;   // close the ol' output device.
begin
   if BASS_ChannelIsActive(HBASSStream) = BASS_ACTIVE_PLAYING then
      BASS_ChannelStop(HBASSStream);
   BASS_StreamFree(HBASSStream);
  { if not PlayEnded then
      if hMainHandle <> 0 then
         PostMessage(hMainHandle, WM_BASS_StreamFree, 0, 0); }
   HBASSStream := 0;
end;

function omodWrite(buf : pointer; len : integer) : integer; cdecl;
// 0 on success. Len == bytes to write (<= 8192 always).
// 1 returns not able to write (yet). Non-blocking, always.

var
   dw : dword;
   p, p2 : pointer;
begin
   while isReading do
      begin
         WinProcessMessages;
         sleep(20);
      end;

   isWriting := true;   // notify that Winamp input plug-in is writing sound data
   dw := dword(pBuf) + wOffset;
   p := pointer(dw);   // p : starting address to write

   if FreeSpace(bufSize, rOffset, wOffset) > len then
   begin
      if rOffset > wOffset then
      begin
            Move(buf^, p^, len);
            inc(wOffset, len);
      end
      else
         if (bufSize - wOffset) > len then
         begin
            Move(buf^, p^, len);
            inc(wOffset, len);
         end else
         begin
            Move(buf^, p^, bufSize - wOffset);
            if (bufSize - wOffset) < len then
            begin
               dw := dword(buf) + (bufSize - wOffset);
               p2 := pointer(dw);
               Move(p2^, pBuf^, len - (bufSize - wOffset));
            end;
            wOffset := len - (bufSize - wOffset);
         end;

      inc(totalWritten, len);
      result := 0;
   end else
   begin
      result := 1;      // This case should not happen !
      Application.MessageBox('Write error : No Space', 'Error', ID_OK);  // debug purpose
   end;

   isWriting := false;

 // Let BASS start playing after initial buffer filling
   if InitialBufferFill then
      if (FreeSpace(bufSize, rOffset, wOffset) <= 8192) or
         (DataSpace(bufSize, rOffset, wOffset) >= (BASSDataSize SHL 1)) then
      begin
         InitialBufferFill := false;
         if HBASSStream <> 0 then
         begin
            ChannelInfo.BitsPerSample := BPS;
            ChannelInfo.SampleRate := SPS;
            ChannelInfo.Channels := Channels;
            PostMessage(MessageHandle2, WM_StartPlay, 0, longint(@ChannelInfo));
         end;
      end;
end;

function omodCanWrite: integer; cdecl;
// returns number of bytes possible to write at a given time.
// Never will decrease unless you call Write (or Close, heh)
begin
   if isReading then
   begin
      result := 0;
      exit;
   end;

 // Subtract 1 from real free space to prevent wOffset become equal to rOffset
 // after writing data.  (it means there is no data in buffer if rOffset equals
 //  to wOffset)
   result := FreeSpace(bufSize, rOffset, wOffset) - 1;
end;

function omodIsPlaying : integer; cdecl;
// non0 if output is still going or if data in buffers waiting to be
// written (i.e. closing while IsPlaying() returns 1 would truncate the song
begin
   if BASS_ChannelIsActive(HBASSStream) = BASS_ACTIVE_PLAYING then
      result := 1
   else
      result := 0;
end;

function omodPause(pause : integer) : integer; cdecl;
// returns previous pause state
begin
   if BASS_ChannelIsActive(HBASSStream) = BASS_ACTIVE_PAUSED then
      result := 1
   else
      result := 0;

   if (pause = 0) and (result = 1) then
   begin
      ResumeMode := true;
      BASS_ChannelPlay(HBASSStream, false);
   end

// This case will happen in the sequence, Pause -> position change -> resume
   else if (pause = 0) then
   begin
      ResumeMode := true;
      BASS_ChannelPlay(HBASSStream, true{flush})
   end else if (pause <> 0) and (result = 0) then
      BASS_ChannelPause(HBASSStream);
end;

procedure omodSetVolume(volume : integer); cdecl; // volume is 0-255
var
   SetVolume : integer;
begin
   if Volume < 0 then
      SetVolume := 0
   else if Volume > MaxVolume then
      SetVolume := MaxVolume
   else
      SetVolume := Volume;

   BASS_SetConfig(BASS_CONFIG_GVOL_STREAM, SetVolume);
end;

procedure omodSetPan(pan : integer); cdecl;       // pan is -128 to 128
begin
   BASS_ChannelSetAttributes(HBASSStream, -1, -1, round(pan * (100 / 128)));
end;

procedure omodFlush(t : integer); cdecl;
// flushes buffers and restarts output at time t (in ms) (used for seeking)
// This procedure is called by input plug-in when position is changed
var
   chnStatus : dword;
   wasPlaying : boolean;
begin
   chnStatus := BASS_ChannelIsActive(HBASSStream);
   if (chnStatus <> BASS_ACTIVE_PAUSED) and
      (chnStatus <> BASS_ACTIVE_STOPPED) then
      if (FreeSpace(bufSize, rOffset, wOffset) > 0) or
         (chnStatus = BASS_ACTIVE_PLAYING) then
      begin
         wasPlaying := true;
      end else
         wasPlaying := false
   else
      wasPlaying := false;

 // Normally this omod.Flush procedure is called by Winamp input plug-in when
 // play position is changed but "in_midi.dll" (v2.64, written by Mr. Peter
 // Pawlowski) calls this procedure when it starts play after pause without
 // position change.
 // The variable PosChanged is used to know if the position has been changed or not.
 // Set PosChanged true in the main program if position is cahnged.
   if chnStatus = BASS_ACTIVE_PAUSED then
      if not PosChanged then  // if position has not been changed then escape
         exit;

   while isReading do
      begin
         WinProcessMessages;
         sleep(20);
      end;

 // Use BASS_ChannelStop regardless the status of BASS_Channel to flush the buffer in BASS
   BASS_ChannelStop(HBASSStream);

   if wasPlaying then
      InitialBufferFill := true;   // Reset to restart after seeking

   posDelta := t;
   rOffset := 0;
   wOffset := 0;
   totalWritten := 0;
   isWriting := false;
   PosChanged := false;
end;

function omodGetOutputTime : integer; cdecl;  // returns played time in MS
begin
   result := posDelta +
     round(1000 * BASS_ChannelGetPosition(HBASSStream) / (SPS * (BPS SHR 3) * Channels));
end;

function omodGetWrittenTime : integer; cdecl;
// returns time written in MS (used for synching up vis stuff)
begin
   result := posDelta + round(1000 * totalWritten / (SPS * (BPS SHR 3) * Channels));
end;

//----------- The end of functions and procedures for Winamp plug-in -----------


procedure SetOutputPlugin;
begin
   omod := @omod1;
   omod.version := $10;
   omod.description := 'BASS Winamp output plug-in emulator';
   omod.id := 65536 + 1;
   omod.hMainWindow := Application.Handle;
   omod.hDllInstance := 0;
   omod.Config := omodConfig;
   omod.About := omodAbout;
   omod.Init := omodInit;
   omod.Quit := omodQuit;
   omod.Open := omodOpen;
   omod.Close := omodClose;
   omod.Write := omodWrite;
   omod.CanWrite := omodCanWrite;
   omod.IsPlaying := omodIsPlaying;
   omod.Pause := omodPause;
   omod.SetVolume := omodSetVolume;
   omod.SetPan := omodSetPan;
   omod.Flush := omodFlush;
   omod.GetOutputTime := omodGetOutputTime;
   omod.GetWrittenTime := omodGetWrittenTime;

   omod.Init;
end;

function GetProgDir : string;
begin
   result := ExtractFilePath(ParamStr(0));
end;


function GetMsgHandler : hwnd;
begin
   result := MessageHandle2;
end;


//---------------------- The plug-in managing part  ----------------------------

// get the reference number of specified plug-in
//  ( -1 :  specified plug-in is not loaded )
function GetPluginIndex(PluginName : string) : integer;
var
   i : integer;
begin
   result := -1;

   for i := 0 to MaxPluginNum - 1 do
      if Plugin[i] <> nil then
         if Uppercase(PluginInfo[i].Name) = Uppercase(PluginName) then
         begin
            result := i;
            break;
         end;
end;

// get the control pointer of specified plug-in
//  ( nil : specified plug-in is not loaded )
function GetPlugin(PluginNum : integer) : TPlugin;
var
   dw : dword;
begin
   if (PluginNum < 0) or (PluginNum > (MaxPluginNum - 1)) then
      result := nil
   else
   begin
      dw := dword(Plugin[PluginNum]);
      result := pointer(dw);
   end;
end;

// get the information on specified plug-in
function GetPluginInfo(PluginNum : integer) : TPluginInfo;
var
  APluginInfo : TPluginInfo;

 procedure ClearPluginInfo;
 begin
    with APluginInfo do
      begin
         Name := '';
         Version := 0;
         Description := '';
         FileExtensions := '';
         Seekable := 0;
         DLLHandle := 0;
      end;
 end;

begin
   if (PluginNum < 0) or (PluginNum > (MaxPluginNum - 1)) then
      ClearPluginInfo
   else if Plugin[PluginNum] = nil then
      ClearPluginInfo
   else
      with APluginInfo do
      begin
          Name := PluginInfo[PluginNum].Name;
          Version := PluginInfo[PluginNum].Version;
          Description := PluginInfo[PluginNum].Description;
          FileExtensions := PluginInfo[PluginNum].FileExtensions;
          Seekable := PluginInfo[PluginNum].Seekable;
          DLLHandle := PluginInfo[PluginNum].DLLHandle;
      end;

   result := APluginInfo;
end;

// get the played time in ms
function GetOutputTime(omodTime : boolean) : integer;
begin
   if omodTime then
      result := omod.GetOutputTime
   else
      result := Plugin[imodNum].GetOutputTime;
end;

procedure SetSongDuration(Duration : DWORD);  // * New at ver 1.3
begin
   ChannelInfo.Duration := Duration;
end;

procedure SetPosChanged;
begin
   PosChanged := true;
end;

{procedure SetPlayEnded;
begin
   PlayEnded := true;
end; }

function SelectInputPlugin(PluginNum : integer) : integer;
begin
   result := -1;

   if (PluginNum < -1) or (PluginNum > (MaxPluginNum - 1)) then
      exit;
   if Plugin[PluginNum] = nil then   // no valid Plugin[x]
      exit;

   imodNum := PluginNum;
   result := 0;
end;

procedure SetMainHandle(MainHandle : HWND);
begin
   hMainHandle := MainHandle;
end;

function GetMainHandle : HWND;  // * Added at Ver 1.2
begin
   result := hMainHandle;
end;

// check if output plug-in emulator is ready  ( true : ready )
function OutputReady : boolean;
begin
   result := omodReady;
end;

// Check whether the specified Winamp input plug-in is loaded.
function IsWinampPluginLoaded(PluginName : string) : boolean;
var
   i : integer;
begin
   result := false;

   for i := 0 to MaxPluginNum - 1 do
      if Plugin[i] <> nil then     // Plugin[i] = nil -> empty element
         if Uppercase(PluginInfo[i].Name) = Uppercase(PluginName) then
         begin
            result := true;  // The specified plug-in is loaded.
            exit;
         end;
end;

// load a Winamp input plug-in  ( 0 : succeed )
function LoadWinampPlugin(PluginName : string) : integer;
var
   indexToLoad : integer;
   FilePath : string;
   DLLHandle : THandle;
   getInModule2 : function : pointer; stdcall;
   dw : dword;
   i : integer;
begin
   if not omodReady then
   begin
      result := ERROR_OMOD_NOTREADY;  // output plug-in emulator is not ready
      exit;
   end;

   if IsWinampPluginLoaded(PluginName) then
   begin
      result := ERROR_LOADED_BEFORE;  // already loaded plug-in
      exit;
   end;

   indexToLoad := -1;
   for i := 0 to MaxPluginNum - 1 do
      if Plugin[i] = nil then
      begin
         indexToLoad := i;       // found out empty element to use
         break;
      end;
   if indexToLoad = -1 then
   begin
      result := ERROR_LOADED_FULL;     // no empty element to use
      exit;
   end;

   FilePath := GetProgDir + 'Plugins\' + PluginName;
   DLLHandle := LoadLibrary(pchar(FilePath));
   if DLLHandle = 0 then
   begin
     result := ERROR_CANNOT_LOAD;
     exit;
   end;

   getInModule2 := GetProcAddress(DLLHandle, 'winampGetInModule2');
   if @getInModule2 = nil then
   begin
     result := ERROR_INVALID_PLUGIN;
     FreeLibrary(DLLHandle);
     exit;
   end;

   imod := getInModule2;
   imod.hMainWindow := MessageHandle2;  // <= handle of internal messsage handler
   imod.hDllInstance := DllHandle;
   imod.outMod := omod;
   imod.init;
   imod.SetInfo := SetInfo1;
   imod.dsp_IsActive := dsp_isactive1;
   imod.dsp_dosamples := dsp_dosamples1;
   imod.SAVSAInit := SAVSAInit1;
   imod.SAVSADeInit := SAVSADeinit1;
   imod.SAAddPCMData := SAAddPCMData1;
   imod.SAGetMode := SAGetMode1;
   imod.SAAdd := SAADD1;
   imod.VSASetInfo := VSASetInfo1;
   imod.VSAAddPCMData := VSAAddPCMData1;
   imod.VSAGetMode := VSAGetMode1;
   imod.VSAAdd := VSAAdd1;
//   imod.About(0);

   dw := dword(imod);
   Plugin[indexToLoad] := pointer(dw);
   PluginInfo[indexToLoad].Name := PluginName;
   PluginInfo[indexToLoad].Version := imod.version;
   PluginInfo[indexToLoad].Description := string(imod.description);
   PluginInfo[indexToLoad].FileExtensions := string(imod.FileExtensions);
   PluginInfo[indexToLoad].Seekable := imod.is_seekable;
   PluginInfo[indexToLoad].DLLHandle := DLLHandle;

   result := 0;
end;

// unload a Winamp input plug-in  ( 0 : succeed )
function UnloadWinampPlugin(PluginName : string) : integer;
var
   indexToUnload : integer;
   returnOK : longbool;
begin
   indexToUnload := GetPluginIndex(PluginName);

   if indexToUnload = -1 then
   begin
      result := ERROR_NOT_LOADED;
      exit;
   end;
   if indexToUnload = imodNum then
   begin
      result := ERROR_IN_USE;
      exit;
   end;

   Plugin[indexToUnload].Quit;
   returnOK := FreeLibrary(PluginInfo[indexToUnload].DLLHandle);
   if returnOK then
   begin
      result := 0;
      Plugin[indexToUnload] := nil;
   end else
      result := ERROR_CANNOT_UNLOAD;
end;

function VisActive : boolean;
begin
   result := VisIsActive;
end;

procedure LoadVisModule(PluginName : string;
                        var Visheader : PWinampVisHeader;
                        var Vismod : TVismod;
                        var NumVismod : integer;
                        ParentHandle : HWND);
var
   i : integer;
begin
   NumVismod := 0;
   VismodNum := 0;
 //  CloseVisDLL;

   if Uppercase(PluginName) <> Uppercase(LoadedVisDLL) then
      if not initVisDll(PluginName) then
        exit;

   Visheader := getVisHeader;
   if VisHeader = nil then
     exit;

   for i := 0 to (maxVismodNum - 1) do
   begin
      Vismod[i] := Visheader.getModule(i);
      if Vismod[i] <> nil then
      begin
         Vismod[i]^.hwndParent := ParentHandle;
         Vismod[i]^.hDllInstance := VisDLLHandle;
         inc(VismodNum);
      end else
         break;
   end;

   Vismods := Vismod;
   NumVismod := VismodNum;
   VismodIndex := -1;
end;

function StartVisModule(ModuleNum : word) : integer;
begin
   result := -1;

   if VismodNum = 0 then
      exit;
   if (ModuleNum > VismodNum - 1) then
   begin
      result := -2;
      exit;
   end;
   if VismodIndex = ModuleNum then
   begin
      result := -3;
      exit;
   end;

   if VismodIndex > -1 then
      if Vismods[VismodIndex] <> nil then
         Vismods[VismodIndex]^.Quit(Vismods[VismodIndex]);

   VismodIndex := ModuleNum;
   result := Vismods[VismodIndex]^.init(Vismods[VismodIndex]);

   if result = 0 then
      VisIsActive := true;
end;

procedure SetVisOutHandle(VisOutHandle : HWND);  // * Added at Ver 1.2
begin
   hVisOutWindow := VisOutHandle;
end;

procedure SetVisualizerQuitted;                 // * Added at Ver 1.2
begin
   VismodIndex := -1;
   VisualizerQuitted := true;
end;

function UnloadVisModule : integer;
begin
   result := -1;
   if VismodNum = 0 then
      exit;

   VisIsActive := false;
   if IsWindow(hVisOutWindow) then
      if not VisualizerQuitted then
         if Vismods[VismodIndex] <> nil then
            Vismods[VismodIndex]^.Quit(Vismods[VismodIndex]);

   CloseVisDLL;
   VismodNum := 0;
   hVisOutWindow := 0;
   result := 0;
end;

function DSPActive : boolean;    // * Added at Ver1.2
begin
   result := DSPIsActive;
end;

procedure LoadDSPModule(PluginName : string;        // * Added at Ver 1.2
                        var DSPheader : PWinampDSPHeader;
                        var DSPmod : TDSPmod;
                        var NumDSPmod : integer;
                        ParentHandle : HWND);
var
   i : integer;
begin
   NumDSPmod := 0;
   DSPmodNum := 0;
 //  CloseDSPDLL;

   if Uppercase(PluginName) <> Uppercase(LoadedDSPDLL) then
      if not initDSPDll(PluginName) then
         exit;

   DSPheader := getDSPHeader;
   if DSPHeader = nil then
     exit;

   for i := 0 to (maxDSPmodNum - 1) do
   begin
      DSPmod[i] := DSPheader.getModule(i);
      if DSPmod[i] <> nil then
      begin
         DSPmod[i]^.hwndParent := ParentHandle;  // * Changed at Ver 1.1
         DSPmod[i]^.hDllInstance := DSPDLLHandle;
         inc(DSPmodNum);
      end else
         break;
   end;

   DSPmods := DSPmod;
   NumDSPmod := DSPmodNum;
   DSPmodIndex := -1;
end;


function StartDSPModule(ModuleNum : word) : integer; // * Added at Ver 1.2
begin
   result := -1;

   if DSPmodNum = 0 then
      exit;
   if (ModuleNum > DSPmodNum - 1) then
      exit;
   if DSPmodIndex = ModuleNum then
      exit;

   if DSPmodIndex > -1 then
      if DSPmods[DSPmodIndex] <> nil then
         DSPmods[DSPmodIndex]^.Quit(DSPmods[DSPmodIndex]);

   DSPmodIndex := ModuleNum;
   result := DSPmods[DSPmodIndex]^.init(DSPmods[DSPmodIndex]);
   if result = 0 then
      DSPIsActive := true;
end;

function StopDSPModule : integer;                  // * Added at Ver 1.2
begin
   result := -1;
   if DSPmodNum = 0 then
      exit;

   if DSPIsActive then
   begin
      DSPIsActive := false;
      if DSPmods[DSPmodIndex] <> nil then
         DSPmods[DSPmodIndex]^.Quit(DSPmods[DSPmodIndex]);
   end;

   result := 0;
end;

function UnloadDSPModule : integer;                  // * Added at Ver 1.2
begin
   result := -1;
   if DSPmodNum = 0 then
      exit;

   if DSPIsActive then
   begin
      DSPIsActive := false;
      if DSPmods[DSPmodIndex] <> nil then
         DSPmods[DSPmodIndex]^.Quit(DSPmods[DSPmodIndex]);
   end;

   CloseDSPDLL;
   DSPmodNum := 0;
   result := 0;
end;


// get the file types (file extensions) which can be played by any loaded plug-ins
function GetPlayableFiles : string;
var
   s : string;
   i : integer;

  function GetFileExt(s : string) : string;
  var
     s1, s2 : string;
     i : integer;
  begin
     s1 := s;
     if length(s1) = 0 then
        s2 := ''
     else begin
        s2 := '*.';
        for i := 1 to length(s1) do
        begin
           s2 := s2 + s1[i];
           if s1[i] = ';' then
              if i < length(s1) then
                 s2 := s2 + '*.';
        end;
     end;

     result := s2;
  end;

begin
   s := '';
   for i := 0 to MaxPluginNum - 1 do
      if Plugin[i] <> nil then
         s := s + GetFileExt(Plugin[i].FileExtensions) + ';';
   result := s;
end;

// Get the number of plug-in which can play specified file type
function GetPluginNumber(ExtCode : string) : integer;
var
   i : integer;
begin
   result := -1;  // Pre-assume there is no plug-in for specified file type

   for i := 0 to MaxPluginNum - 1 do
      if Plugin[i] <> nil then
         if pos(upperCase(ExtCode), upperCase(Plugin[i].FileExtensions)) <> 0 then
         begin
            result := i;
            break;
         end;
end;

//------------------ The end of plug-in managing part --------------------------


// initialization
function InitPluginCtrl : boolean;
var
   i : integer;
begin
   for i := 0 to MaxPluginNum - 1 do
     Plugin[i] := nil;
   omodReady := false;
   GetMem(pBuf, bufSize); // Get memory to hold sound data from Winamp input plug-in
   if (pBuf <> nil) then
      SetOutputPlugin;

   imodNum := -1;
   result := omodReady;
end;

// finalization
procedure QuitPluginCtrl;
var
   i : integer;
begin
   for i := 0 to MaxPluginNum - 1 do
      if (Plugin[i] <> nil) then
      begin                           // Release all Winamp input plug-ins
         Plugin[i].Quit;
         FreeLibrary(PluginInfo[i].DLLHandle);
      end;

   if (omod <> nil) then
      omod.Quit;

   if (pBuf <> nil) then
      FreeMem(pBuf);
end;



end.
