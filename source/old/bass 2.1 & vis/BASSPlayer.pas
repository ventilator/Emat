// Component TBASSPlayer
//
//    written by Silhwan Hyun,  hyunsh@hanafos.com
//    //clgMOD für 2.1
//
// Revision history
//
// (Note) visualizer = Winamp visualization plug-in or its visible window
//
//

// Ver 1.6                        14 Dec 2004
//   ( Based on bass.dll/basswma.dll Ver 2.1 )
//  Made some modifications for new BASS version (2.0 -> 2.1)
//  Added a function "SetAEQGain" to set the gain of a designated equalizer's band.
//    - function SetAEQGain(BandNum : integer; EQGain : float) : boolean;
//  Modified some functions to support music file(MO3, IT, XM, S3M, MTM, MOD, UMX formats)
//   using BASS native function.

// Ver 1.54                       25 Sep 2004
//  Modified function "SetVolume" to control the output volume of Winamp input plug-in
//   which directly sounds out(= not thru output plug-in emulator).
//  Added a property and modified some functions to support playing CD Audio tracks
//   using BASSCD.DLL.
//   -> You do not need Winamp input plug-in such as in_cdda.dll to play CD Audio tracks.
//    - property BASSCDReady : indicates whether BASSCD.DLL is operational.
//  note) BASSCD.DLL cannot access CD drive after accessing it using Winamp input plug-in
//        for CD drive "in_cdda.dll" ("in_CDReader.dll" does not cause this problem).
//        BASS_CD_StreamCreateFile returns BASS_ERROR_NOCD in spite of presence of audio CD.
//        In this case let CD drive re-read media information (open CD drive door then close
//        CD drive door)
//

// Ver 1.53                       25 Jul 2004
//  Added function "PluginInfoBox" to use the function "InfoBox" of Winamp input plug-in.
//    - function : PluginInfoBox(StreamName : string): Boolean;
//  Excluded the parameter "MainWinHwnd" of the functions - RunVisoutProgram, RunDSPPlugin.
//  The parameter "MainWinHwnd" is substituted by the window handle of owner of TBASSPlayer.
//

// Ver 1.52                       7 Feb 2004
//  Attached description to Public declarations and to Published declarations for
//   self-explanation.
//   (I am not a native English speaker.  There may be misspelled, ambiguous, clumsy or
//    grammarless expressions.  I would very much appreciate your sending me the correct/smart
//    expression to replace such expression).
//
//  Added a function "VisThreadReady" in sub-component TVisThread which is used
//   to check the availability of VisThread in TBASSPlayer.
//

// Ver 1.51                       24 Jan 2004
//  Introduced sub-component TVisThread to raise refresh rate of visualizer.
//   (The maximum refresh rate is changed from 30 to 100 fps.)
//  VisOut.exe is launched by internal code of BASSPlayer.pas.
//   (Appexec.pas is not needed to launch VisOut.exe.)
//  Inhibited multiple instance of VisOut.exe because they will use same address
//   space obtained by fisSharedMemory1.
//

// Ver 1.5                        15 Dec 2003
//   ( Based on bass.dll/basswma.dll Ver 2.0 )
//
//  Added properties to play stream files on the internet, or the stream from internet
//   radio (Shout/Icecast server, WMA broadcaster).
//   Followings are the new properties for them.
//    - IsNetStream : true if the stream file is on the internet
//    - IsNetRadio  : true if the stream comes from Shout/Icecast server
//    - ICYInfo     : pointer to ICY tag
//    - HTTPInfo    : pointer to HTTP tag
//    - DownloadProgress : download progress in bytes of an internet file stream
//    - OnGetMeta   : event handler for catching Meta data from Shout/Icecast server.
//    - OnGetChannelInfo : event handler for catching information of an internet stream,
//                         obtained from a Winamp input plug-in.
//    - OnDownloaded : event handler for catching re-estimated value of the playback length
//                      & tag data of an internet stream.
//  Added property "DecodingByPlugin" to show which takes charge of decoding stream,
//     (true if it is Winamp input plug-in, false if BASS)
//  Added property "Seekable" to show if playback position can be changed.
//  Added a function and a procedure to support Winamp DSP plug-ins.
//    - function : RunDSPPlugin         // Run a DSP plug-in
//    - procedure : QuitDSPPlugin       // Quit a DSP plug-in
//  Added a function to inform player status to visualizer
//    - procedure : InformPlayerStatus  // Inform player status to visualizer
//  Added some parameters at running VisOut.exe for more proper operation.
//
//  Changed sound volume range : 0 ~ 100 -> 0 ~ 255
//

// Ver 1.4                        12 May 2003
//   ( Based on bass.dll/basswma.dll Ver 1.8 )
//  Added(modified) functions, procedures and properties to set up synchronized action
//   between the windows of main program and visualizer.
//   - New function : GetVisWindowHandle     // get the handle of visualizer
//   - Modified function : RunVisoutProgram  // added a parameter to inform visualizer
//                                           //  the window handle of main program
//   - New procedure : HideVisWindow         // Hide visualizer
//                     ShowVisWindow         // Show visualizer
//   - New property : VisScale               // set(get) output level of FFT (min : 256 ~ max : 1024)
//                    SyncVisWindow          // set(get) status of synchronized action (true : enabled)
//

// Ver 1.3                        5 Apr 2003
//   ( Based on bass.dll/basswma.dll Ver 1.8 )
//  Added a function and a procedure to run Winamp Visualization plug-ins
//   - function RunVisoutProgram(VismodName : string; VismodNo : word) : boolean;
//   - procedure QuitVisoutProgram;
//  Modified function GetVolume and procedure SetVolume to reflect/adjust the
//   volume level of Winamp plug-in's output
//  Added property EchoLevel & ReverbLevel to adjust the intensity of sound effect
//

// Ver 1.2                        5 Feb 2003
//   ( Based on bass.dll/basswma.dll Ver 1.7 )
//  Added functions & properties to use Winamp 2 input plug-ins.
//   Now TBASSPlayer can play stream files which BASS sound system cannot decode
//   if provided appropriate Winamp input plug-in.
//  Changed the loading method of bass.dll & basswma.dll from static loading to
//   dynamic loading
//
//   - Modified function : GetStreamInfo
//   - New properties : BASSWMAReady, Version, NativeFileExts, PluginFileExts, CanUsePlugin,
//                      SupportedBy, PluginFirst, OnPluginStartPlay, UnloadButEnabled
//   - Renamed property : DLLVersionStr -> BASSDLLVer
//   - New  procedure : ShowPluginConfigForm (-> used to show PluginConfigForm,
//                        which is defined in sub unit PluginConfig.pas)
//   - New functions in sub unit PluginCtrl which you can call in main program
//     if you want to manage Winamp input plug-ins directly(= not using PluginConfigForm).
//       GetPluginIndex(PluginName : string) : integer;
//       GetPlugin(PluginNum : integer) : TPlugin;
//       GetPluginInfo(PluginNum : integer) : TPluginInfo;
//       LoadWinampPlugin(PluginName : string) : integer;
//       UnloadWinampPlugin(PluginName : string) : integer;
//  * include "PluginCtrl" in uses clause of main program to use above functions
//

// Ver 1.1                         8 Dec 2002
//   ( Based on bass.dll/basswma.dll Ver 1.7 )
//   - New function : GetChannelFFTData (for custom processing of FFT data)
//   - Added field at record TStreamInfo : Year
//   - Added property : EQBands (for custom setting of equalizer bands)
//   - Renamed property : EQGains ( <- EqPreset )
//   - New type identifiers : TBandData, TEQBands
//   - Renamed type identifier : TEQGains ( <- TEqPreset )
//   - Updated procedure : TimerFFTTimer (for better output of spectrum visualization)
//

// Ver 1.0                         4 Aug 2002
//   ( Based on bass.dll/basswma.dll Ver 1.6 )
//   - Initial release

unit BASSPlayer;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, Controls, StdCtrls, ExtCtrls,
  Dynamic_BASS, RT_BASSWMA, RT_basscd, ioplug, PluginCtrl, MPEGAudio, OggVorbis,
  WMAFile, WAVFile, PluginConfig, fisSharedMemory, Dialogs, MMSystem,
  CommonTypes;

const
   Ver = '1.60';
   MAXCDDRIVES = 8;
   MaxVolume = 255;      // Volume range : 0 ~ 255
   MaxDX8Effect = 32;    // DX8 Effect range : 0 ~ 32
   NumFFTBands = 25;     // Number of bands for spectrum visualization
   NumEQBands  = 10;     // Number of bands for equalizer
   EQBandWidth  : array[0..NumEQBands-1] of float =
                  (4, 4, 4, 4, 5, 6, 5, 4, 3, 3);
   EQFreq : array[0..NumEQBands-1] of float =
                  (80, 170, 310, 600, 1000, 3000, 6000, 10000, 12000, 14000);
   NoDX8Msg : pchar = 'DirectX Ver 8 are not installed.' + #13#10 +
                      'Sound effects except flanger are disabled.';

   WM_GetToEnd      = WM_USER + 107;  // message to notify that BASS reaches the end of a stream
   WM_NewFFTData    = WM_USER + 108;  // message to notify that new FFT data are ready
   WM_GetMeta       = WM_USER + 110;  // message to notify that new Shoutcast Metadata are ready
   WM_DownLoaded    = WM_USER + 111;  // message to notify that downloading of an internet stream is done.

type
  TSoundEffects = set of (Flanger, Equalizer, Echo, Reverb);
  //TFFTData = array [0..512] of Single;
  //TWaveData = array [ 0..2048] of DWORD;
  TBandOut = array[0..NumFFTBands-1] of word;
  TChannelType = (Channel_NotOpened, Channel_Stream, Channel_CD, Channel_WMA, Channel_Music, Channel_Plugin);
  TSupportedBy = (Both, BASSNative, WinampPlugin, None);
  TEQGains = array [0..NumEQBands-1] of float;
  TBandData = record
     CenterFreq : float;
     BandWidth  : float;
  end;
  TEQBands = record
     Bands : word;     // Number of equalizer bands (min : 0, max : 10)
     BandPara : array[0..NumEQBands-1] of TBandData;
  end;

  TNotifyEvent = procedure(Sender: TObject) of object;
  TNotifyNetEvent = procedure(Sender: TObject; Content : string) of object;
  TNotifyPluginEvent = procedure(Sender: TObject; ChannelInfo : PChannelInfo) of object;
  TNotifyNewFFTDataEvent = procedure(Sender: TObject; BandOut : TBandOut) of object;

  TAbspielfehlerEvent = procedure of object;

  TVisThread = class(TComponent)   // * New at Ver 1.51
  private
    { Private declarations }
    FSuspended : boolean;
    FDelayMS : DWORD;
    FLatencyMs : DWORD;
    FChannelId : DWORD;
    FSampleRate : DWORD;
    FChannels : DWORD;
    FPosition : DWORD;
    FVisScale : word;
    FVisThreadReady : boolean;

    WaitCounter : integer;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
  public
    { Public declarations }
    fisSharedMemory1: TfisSharedMemory;
    ShareMemPointer : pointer;
    DataReadyMsg : hwnd;

    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    function  VisThreadReady : boolean;      // * New at Ver 1.52
    procedure SetDelayMS(DelayMS : DWORD);
    procedure SetChannelInfo(ChannelId, SampleRate, Channels : DWORD);
    procedure SetPosition(Position : DWORD);
    procedure SetVisScale(VisScale : word);
    function  Suspended : boolean;
    procedure Suspend;
    procedure Resume;
  end;

  TBASSPlayer = class(TComponent)
  private
    { Private declarations }
    AppHWND     : THandle;
    ParentHWND  : HWND;
    TimerFFT    : TTimer;

    ChannelType   : TChannelType;
    Channel       : DWORD;

    BassChannelInfo : BASS_CHANNELINFO;
    MessageHandle : hwnd;

    APlugin : TPlugin;
    MessageHandle2 : hwnd;
    NowStarting : boolean;
    UsesOutputPlugin : boolean;
 // Some input plug-ins do not need output plug-in. i.e., some input plug-ins
 // sound out decoded data directly.
 // UsesOutputPlugin is used to know if input plug-in needs output plug-in.
 // Use this instead of input plug-in's UsesOutPlug property because some
 // input plug-ins report wrong UsesOutPlug value.

    BASSDLLLoaded : boolean;
    BassInfoParam : BASS_INFO;
    EQParam       : BASS_FXPARAMEQ;
    EchoParam     : BASS_FXECHO;
    ReverbParam   : BASS_FXREVERB;
    FSoundEffects : TSoundEffects;

 //   DSPHandle     : HDSP;
    fladspHandle  : HDSP;
    EQHandle      : array [0..NumEQBands-1] of HFX;
    EchoHandle    : HFX;
    ReverbHandle  : HFX;

    BandOut: TBandOut;

    NetStream  : boolean;
    NetRadio   : boolean;
    ICYTag     : pchar;
    HTTPTag    : pchar;

    MPEG        : TMPEGaudio;
    Vorbis      : TOggVorbis;
    WMA         : TWMAfile;
    WAV         : TWAVFile;

    MusicStartTime : DWORD;
    MusicPauseTime : DWORD;

  // variables for visualizer
    VisProcId : DWORD;
    VisWindowHandle : HWND;
    GoVisOut : boolean;
    FVisScale : word;
    FSyncVisWindow : boolean;
    WaitingVisualizer : boolean;

    PluginConfigForm: TPluginConfigForm;
    VisThread: TVisThread;

    FBASSReady      : boolean;
    FBASSWMAReady   : boolean;
    FBASSCDReady    : boolean;
    FNumCDDrives    : integer;
    CDDriveList     : array[0..MAXCDDRIVES-1] of string[255];

    FPluginNum      : integer;
    FPluginFirst    : boolean;
    FVersionStr     : string;
    FDLLVersionStr  : string;
    FStreamName     : string;
    FDecodingByPlugin : boolean;
    FDownLoaded     : boolean;
    FStreamInfo     : TStreamInfo;

    FOutputVolume   : DWORD;
    FDX8EffectReady : boolean;
    FEchoLevel      : word;
    FReverbLevel    : word;
    FEQGains        : TEQGains;
    FEQBands        : TEQBands;
    FPlayerMode     : TPlayerMode;
    FUnloadButEnabled : boolean;

    FOnPlayEnd         : TNotifyEvent;
    FOnPluginStartPlay : TNotifyPluginEvent;
    FOnGetChannelInfo  : TNotifyPluginEvent;
    FOnGetMeta         : TNotifyNetEvent;
    FOnDownloaded      : TNotifyNetEvent;
    FOnNewFFTData      : TNotifyNewFFTDataEvent;

    FAbspielfehler     : TAbspielfehlerEvent;

    procedure ClearEffectHandle;
    function  IsPluginReady : boolean;
    function  GetStreamInfo2(StreamName : string;
                            var StreamInfo : TStreamInfo;
                            var SupportedBy : TSupportedBy;
                            var PluginNum : integer) : boolean;
    procedure SetVersionStr(Value : string);
    procedure SetDLLVersionStr(Value : string);
    procedure SetDX8EffectReady(Value : boolean);
    procedure SetVolume(Value : DWORD);
    procedure SetEchoLevel(Value : word);
    procedure SetReverbLevel(Value : word);
    procedure SetSoundEffect(Value : TSoundEffects);
    procedure SetEQGains(Value : TEQGains);
    procedure SetEQBands(Value : TEQBands);
    procedure SetPluginFirst(Value : boolean);
    procedure SetUnloadBut(Value : boolean);
    procedure SetSyncVisWindow(Value : boolean);
    procedure SetVisScale(Value : word);
    function  GetDLLVersionStr : string;
    function  GetNativeFileExts : string;
    function  GetPluginFileExts : string;
    function  IsSeekable : boolean;               // * New at Ver 1.5
    function  GetDownloadProgress : DWORD;        // * New at Ver 1.5
    procedure PausePlay;
    procedure ResumePlay;
    procedure Restart;
    procedure TimerFFTTimer(Sender: TObject);
    procedure ProcMessage(var Msg: TMessage);
    function  CurrentPosition : DWORD;
    procedure SetPosition(Value : DWORD);
    procedure InformPlayerStatus(StatusIndex : DWORD);   // * New at Ver 1.5
    procedure Error(msg: string);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
      // Allocates memory and constructs an instance of TBASSPlayer.
      // This Create method should be executed first to use TBASSPlayer.
      // Parameter :
      //  - AOwner : an owner component

    destructor Destroy; override;
     // Disposes the TBASSPlayer component and its owned components.
     // Do not call Destroy directly. Call Free instead.  Free verifies that the component is not already
     // freed, and only then calls Destroy.

    function GetVisWindowHandle : HWND;
     // Gets the window handle of visualizer(= window created by Winamp visualization plug-in)
     // Gets 0 if visualizer is not running.

    function GetStreamInfo(StreamName: string; var StreamInfo: TStreamInfo; var SupportedBy: TSupportedBy)
                           : boolean;
     // Gets the information of a stream file.
     // Parameters :
     //  - StreamName : the file path of a stream file
     //  - StreamInfo : TStreamInfo record where the information of a stream file is given
     //  - SupportedBy : Gets one of following values
     //      Both : The stream file can be decoded by BASS or Winamp input plug-in.
     //             If property "PluginFirst" is true then the stream file will be decoded by Winamp
     //             input plug-in.
     //      BASSNative : The stream file can be decoded only by BASS.
     //      WinampPlugin : The stream file can be decoded only by Winamp input plug-in.
     //      None : The stream file can not be decoded. (may be an invalid stream file or an unsupported
     //             stream file)
     // Return value : True if valid stream file, else False.
     // note) This function is not available for internet streams.
     //       Because there may be unrecored features in the stream file, some items of StreamInfo
     //       may be filled with default value.
     //       The default value is 0 for numeric item, null for string item.

    function Open(StreamName : string) : boolean;
      //  Prepares to play a local stream file, an internet stream, WMA stream or Shout/Icecast stream.
      //  Previously opened stream is closed in regardless of TBASSPlayer's state.
      //  Local MPx(MP3, MP2, MP1), OGG, WAV, WMA and CD Audio files are decoded by BASS if property
      //  "PluginFirst" is not true or appropriate Winamp input plug-in(s) is not loaded.
      //  You should load the appropriate Winamp input plug-in(s) prior to opening a stream files other
      //  than MPx, OGG, WAV, WMA, CD Audio files.
      //  TBASSPlayer can play MPx, OGG, WAV, ASF or WMA files on the internet.
      //  MPx, OGG, WAV files on the internet are decoded by BASS, and ASF, WMA files on the internet are
      //  decoded by Winamp input plug-in.
      //  So you must load the appropriate Winamp plug-in(s) prior to opening ASF or WMA files on the
      //  internet.
      //  Parameter :
      //   - StreamName : file path, URL of an internet stream, URL for WMA stream or Shout/Icecast stream
      //  Return value : True on success, False on failure.
      //  note) If BASSWMA.DLL is not loaded then you must load appropriate Winamp input plug-in to play
      //        WMA files.

    function PlayLength : DWORD;
      //  Gets playback length in mili seconds.
      //  Gets 0 if there is no opened stream.

    function GetChannelFFTData(PFFTData : pointer; FFTFlag : DWORD) : boolean;
      //  Gets FFT data.
      //  TBASSPlayer itself processes FFT data to drive visualizer internally.
      //  So this function is used only if you want to implement your own visualization program.
      //  Parameters :
      //   - PFFTData : Buffer pointer where FFT data are given.
      //   - FFTFlag : Number of samples to get FFT data. One of followings,
      //         BASS_DATA_FFT512 : 512 samples (returns 256 floating-point values)
      //         BASS_DATA_FFT1024 : 1024 samples (returns 512 floating-point values)
      //         BASS_DATA_FFT2048 : 2048 samples (returns 1024 floating-point values)
      //       in addition, you can add BASS_DATA_FFT_INDIVIDUAL for multi-channel streams.
      //  Return value : True on success, False on failure.

    procedure Play;
      //  Plays an opened stream.
      //  If TBASSPlayer is in paused state then resumes playing.
      //  If TBASSPlayer is in stopped state then restarts from the beginning.
      //  If there is no opened stream or TBASSPlayer is in playing state then
      //  it takes no effects.

    procedure Stop;
      //  Stops playing.
      //  If TBASSPlayer is not playing a stream then it takes no effects.

    procedure Pause(pAction : boolean);
      //  Pauses or resumes playing.
      //  Parameters :
      //   - pAction : Set true if you want to pause palying, false to resume.

    procedure Close;
      //  Closes an opened stream.

    procedure ShowPluginConfigForm;
      //  Shows "Input plug-in Configuration" form.
      //  The "Input plug-in Configuration" form helps you to configure Winamp input plug-ins.
      //  You can load, unload and configure Winamp input plug-ins with it.

    function SetAEQGain(BandNum : integer; EQGain : float) : boolean;   // * New at Ver 1.6
      //  Sets the gain of a equalizer's band.
      //  Parameters :
      //   - BandNum : Band number. ( 0 ~ FEQBands.Bands - 1 )
      //   - EQGain : Gain of the designated equalizer's band. ( -15.0 ~ +15.0 )
      //  Return value : True on success, False on failure.

    property EQGains : TEQGains read FEQGains write SetEQGains;
      //  Specifies equalizer's gain of all bands.
      //  note) The equalizer is not effective if the property "DX8EffectReady" is not true(= the system
      //        does not support DirectX version 8 or higher).

    property EQBands : TEQBands read FEQBands write SetEQBands;
      //  Specifies band parameters of all bands.

    property PlayerReady : boolean read FBASSReady;
      //  Indicates whether BASS.DLL is operational.  It is true if BASS.DLL has been loaded and
      //  initialized successfully.
      //  If FBASSReady is false then none of functions or procedures to play a stream are available.

    property BASSWMAReady : boolean read FBASSWMAReady;
      //  Indicates whether BASSWMA.DLL is operational.  It is true if FBASSReady is true and BASSWMA.DLL
      //  has been loaded.
      //  If FBASSReady is true and FBASSWMAReady is false then you cannot play WMA streams by BASS only.
      //  In this case you can play WMA streams using Winamp input plug-in for WMA stream(ex: in_WM.dll).

    property BASSCDReady : boolean read FBASSCDReady;  // * New at ver 1.54
      //  Indicates whether BASSCD.DLL is operational.  It is true if FBASSReady is true and BASSCD.DLL
      //  has been loaded.
      //  If FBASSReady is true and FBASSCDReady is false then you cannot play CD Audio tracks by BASS only.
      //  In this case you can play CD Audio tracks using Winamp input plug-in for CD Audio file(ex: in_cdda.dll).

  {  property NumCDDrives : integer read FNumCDDrives;
      // Indicates the number of CDROM drives installed.
      // note) NumCDDrives is available only if BASSCDReady is true. (Always will be zero if not)

    function CDDescription(DriveNum : integer) : string;
      // Gets "drive_letter: description" string for specified CDROM drive.
      //  (0 : 1st drive, 1 : 2nd drive ... )  }

    property DecodingByPlugin : boolean read FDecodingByPlugin;
      //  Indicates whether the opened stream is decoded by Winamp input plug-in.

    property Seekable : boolean read IsSeekable;
      //  Indicates whether the playback position is changeable.

    property StreamInfo : TStreamInfo read FStreamInfo;
      //  Gets features of an opened stream.
      //  note) Because there may be unrecored features in an opened stream file, some items of StreamInfo
      //        may be filled with default value.
      //        The default value is 0 for numeric item, null for string item.

    property Mode : TPlayerMode read FPlayerMode;
      //  Indicates the state of TBASSPlayer, It can be one of followings.
      //   plmStandby : TBASSPlayer is in standby state. (= Not opened a stream to play yet)
      //   plmReady   : TBASSPlayer is ready to play a stream. (= Opened a stream to play)
      //   plmStopped : TBASSPlayer is in stopped state.
      //                Subsequent playback is started from the beginning.
      //   plmPlaying : TBASSPlayer is playing a stream.
      //   plmPaused  : TBASSPlayer is in paused state.
      //                Subsequent playback is started from the position paused.

    property Position : DWORD read CurrentPosition write SetPosition;
      //  Specifies the playback position in mili seconds.
      //  Altering Position, which causes to perform SetPosition, takes no effects if the opened stream
      //  is not seekable stream.

    property StreamName : string read FStreamName;
      //  Indicates the file path of an opened stream

    property ChannelId : DWORD read Channel;
      //  Indicates the handle which is given at creating a sample stream by BASS.
      //  You can implement most of BASS functions in your own program if you know the handle of channel.

    property Volume : DWORD read FOutputVolume write SetVolume;
      //  Specifies the output volume.
      //  The output volume range is from 0 to 255.

    property SoundEffects : TSoundEffects read FSoundEffects write SetSoundEffect;
      //  Specifies sound effects to be applied.
      //  The 4 different sound effects can be applied according to the value of SoundEffects.
      //  ex) BASSPlayer1.SoundEffects := [Echo] + [Reverb];  {apply echo and reverb}

    property EchoLevel : word read FEchoLevel write SetEchoLevel;
      //  Specifies the echo level.
      //  The range of echo level is from 0 to 32.

    property ReverbLevel : word read FReverbLevel write SetReverbLevel;
      //  Specifies the reverb level.
      //  The range of reverb level is from 0 to 32.

    property CanUsePlugin : boolean read IsPluginReady;
      //  Indicates whether TBASSPlayer is ready to use Winamp input plug-ins.

    property NativeFileExts : string read GetNativeFileExts;
      //  Reports playable file types which can be decoded by BASS only.

    property PluginFileExts : string read GetPluginFileExts;
      //  Reports the file types which can be decoded by Winamp input plug-ins.
      //  This PluginFileExts changes according to the currently loaded Winamp input plug-ins.

    property UnloadButEnabled : boolean read FUnloadButEnabled write SetUnloadBut;
      //  Specifies the enabled status of "Unload" button on "Input plug-in Configuration" form.
      //  You may need to inhibit unloading of a Winamp input plug-in which is in use.
      //  In this case you can set the enabled status of "Unload" button to "disabled" if the designated
      //  Winamp input plug-in is in use.

    property IsNetStream : boolean read NetStream;
      //  Indicates whether the opened stream is a stream file on the internet.

    property IsNetRadio : boolean read NetRadio;
      //  Indicates whether the opened stream is the stream from internet. (i.e., the
      //  stream comes from internet radio such as Shout/Icecast server.)

    property ICYInfo : pchar read ICYTag;
      //  Reports ICY (Shoutcast) tags. A pointer to a series of null-terminated strings is returned,
      //  the final string ending with a double null.
      //  ICYInfo will be nil if the opened stream has no ICY (Shoutcast) tags.

    property HTTPInfo : pchar read HTTPTag;
      //  Reports HTTP headers, only available when streaming from a HTTP server.
      //  A pointer to a series of null-terminated strings is returned, the final string ending with a
      //  double null.
      //  HTTPInfo will be nil if the opened stream is not from a HTTP server.

    property DownloadProgress : DWORD read GetDownloadProgress;
      //  Reports download progress of an internet file stream in bytes.

    function PluginInfoBox(StreamName : string): Boolean;   // * New at Ver 1.53
      //  Shows dialog box which presents some information on a specified stream file.
      //  This function is effective only if the specified stream file is supported by
      //  one of currently loaded Winamp input plug-ins.
      //  Return value : True on success, False on failure.

    function RunVisoutProgram(VismodName : string; VismodNo : word{;
                              MainWinHwnd : HWND}) : boolean;
      //  Runs a Winamp visualization plug-in.
      //  Parameters :
      //   - VismodName : The file name of a Winamp visualization plug-in to be run.
      //   - VismodNo : The number to select a module among the modules in a Winamp visualization plug-in.
      //                (0 : the 1st module, 1 : 2nd module,.. N-1 : Nth module)
      //        note) A Winamp visualization plug-in can have upto 8 modules.
      //   - MainWinHwnd : The handle of main window.
      //  Return value : True on success, False on failure.

    procedure QuitVisoutProgram;
      //  Quits the running Winamp visualization plug-in.

    function RunDSPPlugin(DSPmodName : string; DSPmodNo : word{;
                              MainWinHwnd : HWND}) : boolean;
      //  Runs a Winamp DSP plug-in.
      //  DSP effects using Winamp DSP plug-in is effective only if the stream being played is decoded
      //  by Winamp input plug-in. (ex. load in_mp3.dll and set "Plugin First" check box of
      //  "Input plug-in Configuration" form, if you are playing MP3 stream files)
      //  Parameters :
      //   - DSPmodName : The file name of a DSP plug-in to be run.
      //   - DSPmodNo : The number to select a module among the modules of a Winamp DSP plug-in.
      //                (0 : the 1st module, 1 : 2nd module,.. N-1 : Nth module)
      //        note) A Winamp DSP plug-in can have upto 8 modules.
      //   - MainWinHwnd : The handle of main window.
      //  Return value : True on success, False on failure.

    procedure QuitDSPPlugin;
      //  Quits the running Winamp DSP plug-in.

    procedure HideVisWindow;
      //  Hides the visualizer(= window created by Winamp visualization plug-in).

    procedure ShowVisWindow;
      //  Shows or restores the visualizer;

    function GetMessageHandle : HWND;   // debug purpose (to debug VisOut program)
      //  Gets the message handle of TBASSPlayer.

  published
    { Published declarations }
    property Version : string read FVersionStr write SetVersionStr;
      //  Indicates the version of TBASSPlayer in string.
      //  note) Altering Version, which causes to perform SetVersionStr, takes no effects.
      //        SetVersionStr is needed only to show FVersionStr at form design.

    property BASSDLLVer : string read FDLLVersionStr write SetDLLVersionStr;
      //  Indicates the version of BASS.DLL in string.
      //  note) Altering BASSDLLVer, which causes to perform SetDLLVersionStr, takes no effects.
      //        SetDLLVersionStr is needed only to show FDLLVersionStr at form design.

    property DX8EffectReady : boolean read FDX8EffectReady write SetDX8EffectReady;
      //  Indicates whether TBASSPlayer is ready to use sound effects which are supported
      //  by Direct-X.
      //  It is set True if the DirectX version 8 or higher is properly installed in your system.
      //  note) Altering DX8EffectReady, which causes to perform SetDX8EffectReady, takes no effects.
      //        SetDX8EffectReady is needed only to show FDX8EffectReady at form design.

    property PluginFirst : boolean read FPluginFirst write SetPluginFirst;
      //  Specifies the priority of taking in charge of decoding an opened stream.
      //  This property is effective only if the opened stream file can be decoded by both BASS and
      //  Winamp input plug-in.
      //  Set True if you want to use Winamp plug-ins for the file types that can be decoded by both
      //  BASS and Winamp input plug-in.
      //  ex) The MP3 files can be played not using Winamp input plug-in.
      //      If you want to play a MP3 file using Winamp input plug-in then load appropriate plug-in
      //      such as in_MP3.dll and set "PluginFirst" True prior to opening the MP3 file.
      //      In this case the decoding process is performed by Winamp input plug-in,
      //      but the processes except decoding are still controled by BASS.

    property VisScale : word read FVisScale write SetVisScale;
      //  Specifies the scale factor to adjust output level of FFT data. (min. 256 ~ max. 1024)
      //  The original FFT data obtained by BASS is multiplied by this scale factor.
      //  note) The original FFT data are floating-point values ranging from 0 to 1.
      //        Winamp visualization plug-in uses BYTE array to accept FFT data.
      //        So minimum VisScale should be 256.

    property SyncVisWindow : boolean read FSyncVisWindow write SetSyncVisWindow;
      //  Determines whether TBASSPlayer should synchronize the owner's window and
      //  the visualizer(= window created by Winamp visualization plug-in).
      //  If you set this property True then visualizer will be hidden when main window is
      //  hidden, and will be shown(or restored) when main window is shown(or restored).

    property OnNewFFTData : TNotifyNewFFTDataEvent read FOnNewFFTData write FOnNewFFTData;
      //  Occurs when new FFT data is placed.

    property OnPluginStartPlay : TNotifyPluginEvent read FOnPluginStartPlay write FOnPluginStartPlay;
      //  Occurs when playback of a stream, which is decoded by Winamp input plug-in, is started.

    property OnGetChannelInfo : TNotifyPluginEvent read FOnGetChannelInfo write FOnGetChannelInfo;
      //  Occurs when the basic characteristics(the number of channels, bit rate and sample rate)
      //  of a stream to be played are received from Winamp input plug-in.
      //  This event also occurs when one of the basic characteristics of a stream
      //  being played is changed.
      //  note) You cannot get the basic characteristics of a stream at opening the stream
      //        if the stream file type is not one of WAV, MPx, OGG or WMA.
      //        If the opened stream is decoded by Winamp input plug-in then the basic characteristics
      //        of the stream are catched by Winamp input plug-in at just before starting playback.
      //        So you can get the basic characteristics of a stream to be played at this event.

    property OnGetMeta : TNotifyNetEvent read FOnGetMeta write FOnGetMeta;
      //  Occurs when metadata is received in a Shoutcast stream.

    property OnDownloaded : TNotifyNetEvent read FOnDownloaded write FOnDownloaded;
      //  Occurs when downloading of an internet stream is done.
      //  note) The downloading process is automatically started when you play an internet stream.
      //        This OnDownloaded event does not occur if the file type of internet stream is ASF or WMA.
      //        The ASF and WMA files on the internet are played in buffered mode(= download and play
      //        in smaller chunks).

    property OnPlayEnd : TNotifyEvent read FOnPlayEnd write FOnPlayEnd;
      //  Occurs when stream reaches the end.

    property OnAbspielfehler: TAbspielfehlerEvent read FAbspielfehler write FAbspielfehler;
  end;

  procedure Register;


implementation


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


constructor TVisThread.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);

   FVisThreadReady := false;
   Timer1 := TTimer.Create(nil);
   Timer1.Interval := 10;
   Timer1.Enabled := false;
   Timer1.OnTimer := Timer1Timer;

   fisSharedMemory1 := TfisSharedMemory.Create(Self);
   fisSharedMemory1.ShareName := 'VisOutSharedMemory';  // * Changed at Ver 1.51
   fisSharedMemory1.Size := 2600;                       // * Changed at Ver 1.51
   fisSharedMemory1.TargetApplication := 'VisOut';
   if fisSharedMemory1.CreateMemory then
   begin
      ShareMemPointer := fisSharedMemory1.MapMemory;
      DataReadyMsg := fisSharedMemory1.SendingDataMsg;
      FVisThreadReady := true;
   end else
      ShareMemPointer := nil;

   FSuspended := true;
end;

destructor  TVisThread.Destroy;
begin
   Timer1.Free;

   if ShareMemPointer <> nil then
      fisSharedMemory1.UnMapMemory(ShareMemPointer);
   if fisSharedMemory1 <> nil then
      fisSharedMemory1.CloseMemory;
   fisSharedMemory1.Free;

   inherited Destroy;
end;

function TVisThread.VisThreadReady : boolean;   // * Added at Ver 1.52
begin
   result := FVisThreadReady;
end;

procedure TVisThread.SetDelayMS(DelayMS : DWORD);
begin
   FLatencyMS := (DelayMS shr 16);
   FDelayMS := (DelayMS and $0000ffff);
   if FDelayMS < 10 then
      FDelayMS := 10;
   Timer1.Interval := FDelayMS;
end;

procedure TVisThread.SetChannelInfo(ChannelId, SampleRate, Channels : DWORD);
begin
   FChannelId := ChannelId;
   FSampleRate := SampleRate;
   FChannels := Channels;
end;

procedure TVisThread.SetPosition(Position : DWORD);
begin
   FPosition := Position;
end;

procedure TVisThread.SetVisScale(VisScale : word);
begin
   FVisScale := VisScale;
end;


function  TVisThread.Suspended : boolean;
begin
   result := FSuspended;
end;

procedure TVisThread.Suspend;
begin
   FSuspended := true;
   Timer1.Enabled := false;
end;

procedure TVisThread.Resume;
var
   p1 : PDWORD;
begin
   Fsuspended := false;
   WaitCounter := 0;
   p1 := ShareMemPointer;
   inc(p1, 280);
   p1^ := 0;   // Clear flag which is used to notify that new data is given
   Timer1.Enabled := true;
end;


procedure TVisThread.Timer1Timer(Sender: TObject);
var
   i : integer;
   p1 : PDWORD;
   p2 : PBYTE;
   BytesValid : DWORD;
   SpectrumData: array[0..4097] of float;
   WaveformData: array[0..2303] of smallint;
begin
   Timer1.Enabled := false;
   if FSuspended then
      exit;

   if BASS_ChannelIsActive(FChannelId) <> BASS_ACTIVE_PLAYING then
   begin
      Timer1.Enabled := true;
      exit;
   end;

   BytesValid := Bass_ChannelGetdata(FChannelId, nil, BASS_DATA_AVAILABLE);
   if BytesValid < (2048 * FChannels) then
   begin
      Timer1.Enabled := true;
      exit;
   end;

   p1 := ShareMemPointer;
   inc(p1, 280); // FFT Data region is allocated from offset 280 thru 2599 in shared memory

 // The DWORD of offset 280 is used as a flag to notify that new data is given.
 // It is to be zero if rendering is completed.
 // But it won't be zero in some cases so I use WaitCounter to escape from such situation.
   if p1^ <> 0 then
   begin
      WaitCounter := WaitCounter + 1;
      if WaitCounter < 10 then
      begin
         Timer1.Enabled := true;
         exit;
      end;
   end;
   WaitCounter := 0;

   p1^ := 1;     // Set flag to notify that new data is given
   inc(p1, 1);
   p1^ := FSampleRate;
   inc(p1, 1);
   p1^ := FChannels;
   inc(p1, 1);
   p1^ := FPosition;
   inc(p1, 1);
   p2 := pointer(p1);

   if FChannels = 1 then
   begin
      Bass_ChannelGetdata(FChannelId, @spectrumdata, BASS_DATA_FFT2048);

      for i := 1 To 576 do
      begin
        p2^ := trunc(SpectrumData[i] * FVisScale);
        inc(p2);
      end;

      for i := 1 To 576 do
      begin
        p2^ := trunc(SpectrumData[i] * FVisScale);
        inc(p2);
      end;
   end else

// Add BASS_DATA_FFT_INDIVIDUAL flag for seperate FFT per each channel
   begin
      Bass_ChannelGetdata(FChannelId, @spectrumdata, BASS_DATA_FFT2048 + BASS_DATA_FFT_INDIVIDUAL);

      for i := 1 To 576 do
      begin
        p2^ := trunc(SpectrumData[i*2] * FVisScale);
        inc(p2);
      end;

      for i := 1 To 576 do
      begin
        p2^ := trunc(SpectrumData[i*2 + 1] * FVisScale);
        inc(p2);
      end;
   end;

   if FChannels = 1 then
   begin
     Bass_ChannelGetdata(FChannelId, @waveformdata, 1152);

     for i := 0 to 575 do
     begin
       p2^ := waveformdata[i] div 256;
       inc(p2);
     end;

     for i := 0 to 575 do
     begin
       p2^ := waveformdata[i] div 256;
       inc(p2);
     end;
   end else
   begin
      Bass_ChannelGetdata(FChannelId, @waveformdata, 2304);

      for i := 0 to 575 do
      begin
        p2^ := waveformdata[i*2] div 256;
        inc(p2);
      end;

      for i := 0 to 575 do
      begin
        p2^ := waveformdata[i*2+1] div 256;
        inc(p2);
      end;
   end;

 // Inform "VisOut.exe" that visualization data is ready
   fisSharedMemory1.InformDataReady(10{DataReady}, 2320);
   if not FSuspended then
      Timer1.Enabled := true;
end;

// Following statements for flanger effect is adopted from DTMain.pas of BASS16
// package

const
   FLABUFLEN = 350;         // buffer length for flanger effect

var
   // Variables for DSP (flanger effect) implementation
   flabuf : array[0..FLABUFLEN-1, 0..2] of SmallInt;  // buffer
   flapos : Integer;         // cur.pos
   flas, flasinc : FLOAT;    // sweep pos/min/max/inc

function fmod(a, b: FLOAT): FLOAT;
begin
   Result := a - (b * Trunc(a / b));
end;

function Clip(a: Integer): Integer;
begin
   if a <= -32768 then
      a := -32768
   else if a >= 32767 then
      a := 32767;

   Result := a;
end;

procedure Flange(handle: HSYNC; channel: DWORD; buffer: Pointer; length, user: DWORD); stdcall;
var
  lc, rc: SmallInt;
  p1, p2, s: Integer;
  d: ^DWORD;
  f: FLOAT;
begin
  d := buffer;
  while (length > 0) do
  begin
    lc := LOWORD(d^); rc := HIWORD(d^);
    p1 := (flapos + Trunc(flas)) mod FLABUFLEN;
    p2 := (p1 + 1) mod FLABUFLEN;
    f := fmod(flas, 1.0);
    s := lc + Trunc(((1.0-f) * flabuf[p1, 0]) + (f * flabuf[p2, 0]));
    flabuf[flapos, 0] := lc;
    lc := Clip(s);
    s := rc + Trunc(((1.0-f) * flabuf[p1, 1]) + (f * flabuf[p2, 1]));
    flabuf[flapos, 1] := rc;
    rc := Clip(s);
    d^ := MakeLong(lc, rc);
    Inc(d);
    Inc(flapos);
    if (flapos = FLABUFLEN) then flapos := 0;
    flas := flas + flasinc;
    if (flas < 0) or (flas > FLABUFLEN) then
      flasinc := -flasinc;
    length := length - 4;
  end;
end;

const
  decblock = 4608;
var
  DSPmod : TDSPmod;
  DSPModNum : word;

  exlen : integer = 0;
//  Excess : array[0..decblock * 2 - 1] of byte;

// Following WinampDSPProc procedure is not completed and not used in TBassPlayer.
// Anyway you can use any Winamp DSP plug-ins by direct coupling of input~DSP plug-ins.
// See PluginCtrl.pas if you want to know the method for direct coupling of input~DSP plug-ins.
// The direct coupling of input~DSP plug-ins is simple and reliable, so I leave this
// WinampDSPProc procedure uncompleted.
procedure WinampDSPProc(handle: HSYNC; channel: DWORD; buffer: Pointer; length, user: DWORD); stdcall;
var
//  DSPbuffer : array[0..4607] of byte;

  ReadP  : pointer;
  c      : DWord;
  a      : Integer;
//  numsamples : integer;
begin
   a := length;
   ReadP := buffer;
   while a > 0 do
   begin
      if a > (576 * 4) then
         c := (576 * 4)
      else
         c := a;
    //  Move(ReadP^, DSPbuffer, c);
    //  numsamples := DSPmod[DSPModNum].ModifySamples(DSPmod[DSPModNum], @DSPbuffer, c Div 4, 16, 2, 44100);
    //  Move(DSPbuffer, ReadP^, c);
      a := a - c;
      if a > 0 then
         DWord(ReadP) := DWord(ReadP) + c;
   end;
end;

var
   TitleP : array[0..255] of char;

// This procedure is called when metadata are received in a Shoutcast stream.
procedure MetaSync(SyncHandle : HSYNC; Channel, data, user : DWORD); stdcall;
var
   TagP : pchar;
   tmpStr, StreamTitle : string;
   TitlePos, DelimeterPos : integer;
//   TitleP : array[0..255] of char;
begin
   StreamTitle := '';
   TagP := pchar(data);
   tmpStr := string(TagP);
   TitlePos := Pos('StreamTitle=', tmpStr);
   if TitlePos <> 0 then
   begin
      DelimeterPos := Pos(';', tmpStr);
      if DelimeterPos = 0 then
         StreamTitle := copy(tmpStr, TitlePos + 13, length(tmpStr) - TitlePos - 13)
      else
         StreamTitle := copy(tmpStr, TitlePos + 13, DelimeterPos - TitlePos - 14);
   end else
   begin   // May be a chained OGG stream
      while StrLen(TagP) > 0 do
      begin
         if pos('TITLE=', upperCase(string(TagP))) <> 0 then
         begin
            inc(TagP, 6);
            StreamTitle := string(TagP);
            break;

            inc(TagP, StrLen(TagP) + 1);
         end;
      end;
   end;

 {  if StreamTitle = '' then
      StreamTitle := tmpStr;  }

   StrPCopy(TitleP, StreamTitle);
   PostMessage(user, WM_GetMeta, 0, longint(@TitleP));
end;


// This procedure is called when a stream reaches the end.
procedure PlayEndSync(SyncHandle : HSYNC; Channel, data, user : DWORD); stdcall;
begin
   PostMessage(user, WM_GetToEnd, 0, 0);
end;

// This procedure is called when downloading of an internet stream is done.
procedure DownloadSync(SyncHandle : HSYNC; Channel, data, user : DWORD); stdcall;
begin
   PostMessage(user, WM_DownLoaded, 0, 0);
end;

// get the handle of visualizer
function TBASSPlayer.GetVisWindowHandle : HWND;
begin
   result := VisWindowHandle;
end;

procedure TBASSPlayer.Error(msg: string);
var
  s: string;
begin
  s := msg + #13#10 + '(error code: ' + IntToStr(BASS_ErrorGetCode) + ')';
  MessageBox(AppHWND, PChar(s), 'Error', MB_ICONERROR or MB_OK);
end;

{ function TBASSPlayer.CDDescription(DriveNum : integer) : string;  // * New at ver 1.54
begin
   if not FBASSCDReady then
      result := ''
   else if DriveNum >= FNumCDDrives then
      result := ''
   else
      result := CDDriveList[DriveNum];
end; }

procedure TBASSPlayer.ClearEffectHandle;
var
   i : integer;
begin
   fladspHandle := 0;
   if FDX8EffectReady then
   begin
      for i := 0 to (FEQBands.Bands{NumEQBands}-1) do
          EQHandle[i] := 0;
      EchoHandle := 0;
      ReverbHandle := 0;
   end;
end;

function TBASSPlayer.IsPluginReady : boolean;
begin
   result := OutputReady; // true if Winamp output plug-in emulator is ready
end;

function TBASSPlayer.PlayLength : DWORD;  // get playback length in mili seconds
var
   SongLength : int64;
   FloatLen : FLOAT;
begin
   result := 0;
   case ChannelType of
      Channel_NotOpened : exit;
      Channel_CD, Channel_WMA, Channel_Stream : SongLength := BASS_StreamGetLength(Channel);
      Channel_Music  : SongLength := BASS_MusicGetLength(Channel, true);
      Channel_Plugin : begin
                         result := FStreamInfo.Duration;
                         exit;
                       end;
   end;

   if SongLength < 0 then
      SongLength := 0;

   FloatLen := BASS_ChannelBytes2Seconds(Channel, SongLength);
   result := round(1000 * FloatLen);   // sec -> milli sec
end;


function TBASSPlayer.CurrentPosition : DWORD;  // get playback position in mili seconds
var
   SongPos : int64;
   FloatPos : FLOAT;
   ChannelStat : DWORD;
begin
   result := 0;
   case ChannelType of
      Channel_NotOpened : exit;
      Channel_CD, Channel_WMA, Channel_Stream : SongPos := BASS_ChannelGetPosition(Channel);
      Channel_Music  : begin    // * Modified at Ver 1.6
                          ChannelStat := BASS_ChannelIsActive(Channel);
                          if ChannelStat = BASS_ACTIVE_STOPPED then
                             result := 0
                          else if ChannelStat = BASS_ACTIVE_PAUSED then
                              result := MusicPauseTime
                          else
                              result := timeGetTime - MusicStartTime;
                          exit;
                       end;
      Channel_Plugin : begin
                          if FPlayerMode = plmReady then
                             result := 0
                          else if UsesOutputPlugin then
                             result := GetOutputTime(true)  // Output plug-in's time
                          else
                             result := GetOutputTime(false); // Input plug-in's time
                          exit;
                       end;
   end;

   if SongPos < 0 then
      SongPos := 0;

   FloatPos := BASS_ChannelBytes2Seconds(Channel, SongPos);
   result := round(1000 * FloatPos);     // sec -> milli sec
end;


procedure TBASSPlayer.SetPosition(Value : DWORD); // set playback position in mili seconds
var
   SongPos : int64;
   wCycle : integer;
begin
   if not IsSeekable then   // * Added at Ver 1.51
      exit;

   if Value > PlayLength {= FStreamInfo.Duration} then
      exit;

   if NowStarting then
      exit;

   SongPos := BASS_ChannelSeconds2Bytes(Channel, Value / 1000);
   case ChannelType of
      Channel_NotOpened : exit;
      Channel_Music   : begin   // * Modified at Ver 1.6
                           if (BASS_ChannelSetPosition(Channel, MAKELONG((Value div 1000), $ffff))) then
                               MusicStartTime := timeGetTime - Value;
                           exit;
                        end;
      Channel_CD, Channel_WMA, Channel_Stream  : BASS_ChannelSetPosition(Channel, SongPos);
      Channel_Plugin  : begin
                           if (FPlayerMode = plmPlaying) and UsesOutputPlugin then
                              NowStarting := true;
                      //     PostMessage(MessageHandle2, WM_PosChange, 0, 0);
                           SetPosChanged;
                           APlugin.SetOutputTime(Value);
                           wCycle := 0;
                           while FPlayerMode = plmPlaying do
                           begin
                              if NowStarting = false then
                               begin
                                  TimerFFT.Enabled := true;
                                  break;
                               end;
                               WinProcessMessages;
                               sleep(40);
                               inc(wCycle);
                               if wCycle > 50 then   // 2 sec time out
                                  break;
                           end;
                           NowStarting := false;
                        end;
   end;
end;

function TBASSPlayer.GetDownloadProgress : DWORD;  // get downloaded bytes
begin
   if ChannelType = Channel_NotOpened then
      result := 0
   else if (not NetStream) then
      result := 0
   else if ChannelType = Channel_Plugin then  // not available if current stream is decoded by Winamp plug-in
      result := 0
   else
      result := BASS_StreamGetFilePosition(Channel, BASS_FILEPOS_DOWNLOAD);
end;

function TBASSPlayer.IsSeekable : boolean;
begin
   if (ChannelType = Channel_NotOpened) {or (ChannelType = Channel_Music)} then
      result := false
   else if NetRadio then
      result := false
   else if ChannelType = Channel_Plugin then
      result := (APlugin.is_seekable <> 0)
   else if NetStream then
      result := FDownLoaded
   else
      result := true;
end;


procedure TBASSPlayer.SetVersionStr(Value : string);
begin
   // nothing to do : only to show FVersionStr at form design
end;

procedure TBASSPlayer.SetDLLVersionStr(Value : string);
begin
   // nothing to do : only to show FDLLVersionStr at form design
end;

procedure TBASSPlayer.SetDX8EffectReady(Value : boolean);
begin
   // nothing to do : only to show FDX8EffectReady at form design
end;

procedure TBASSPlayer.SetVolume(Value : DWORD);  // * Modified at Ver 1.54
var
   tmpValue : DWORD;
begin
   if Value > MaxVolume then
      tmpValue := MaxVolume
   else
      tmpValue := Value;

   FOutputVolume := tmpValue;
   if (ChannelType = Channel_Plugin) {and (not UsesOutputPlugin)} then
      APlugin.SetVolume(FOutputVolume)
   else begin
      BASS_SetConfig(BASS_CONFIG_GVOL_MUSIC, FOutputVolume);
      BASS_SetConfig(BASS_CONFIG_GVOL_STREAM, FOutputVolume);
   end;
end;

function TBASSPlayer.SetAEQGain(BandNum : integer; EQGain : float) : boolean;   // * New at Ver 1.6
begin
   result := false;

   if not FDX8EffectReady then
      exit;
   if BandNum >= FEQBands.Bands then
      exit;

   if EQGain > 15.0 then
      FEQGains[BandNum] := 15.0
   else if EQGain < -15.0 then
      FEQGains[BandNum] := -15.0
   else
      FEQGains[BandNum] := EQGain;

   if (Equalizer in FSoundEffects) then
   begin
      if EQHandle[BandNum] = 0 then
         exit;

      if BASS_FXGetParameters(EQHandle[BandNum], @EQParam) then
      begin
      // Avoid redundant operation
         if abs(EQParam.fGain - FEQGains[BandNum]) > 0.001 then   // consider round-off error
         begin
            EQParam.fBandWidth := FEQBands.BandPara[BandNum].BandWidth;
            EQParam.fCenter := FEQBands.BandPara[BandNum].CenterFreq;
            EQParam.fGain:= FEQGains[BandNum];
            if BASS_FXSetParameters(EQHandle[BandNum], @EQParam) then
               result := true;
         end else
            result := true;
      end;
   end;
end;

procedure TBASSPlayer.SetEQGains(Value : TEQGains);
var
   i : integer;
begin
   if not FDX8EffectReady then
      exit;

   for i := 0 to (FEQBands.Bands{NumEQBands} - 1) do
   begin
      if Value[i] > 15.0 then
         FEQGains[i] := 15.0
      else if Value[i] < -15.0 then
         FEQGains[i] := -15.0
      else
         FEQGains[i] := Value[i];

      if not (Equalizer in FSoundEffects) then
         Continue;

      if EQHandle[i] = 0 then
         Continue;

      if BASS_FXGetParameters(EQHandle[i], @EQParam) then
      begin
      // Avoid redundant operation
         if abs(EQParam.fGain - FEQGains[i]) < 0.001 then   // consider round-off error
            Continue;

         EQParam.fBandWidth := FEQBands.BandPara[i].BandWidth;
         EQParam.fCenter := FEQBands.BandPara[i].CenterFreq;
         EQParam.fGain:= FEQGains[i];
         BASS_FXSetParameters(EQHandle[i], @EQParam);
      end;
   end;
end;

procedure TBASSPlayer.SetEchoLevel(Value : word);
begin
   if Value > MaxDX8Effect then
      exit;

   FEchoLevel := Value;
   if Echo in FSoundEffects then
   begin
       if EchoHandle <> 0 then
       begin
         if BASS_FXGetParameters(EchoHandle, @EchoParam) then
         begin
            EchoParam.fWetDryMix := FEchoLevel * 1.2{30.0};
            EchoParam.fFeedBack := 30.0;
            BASS_FXSetParameters(EchoHandle, @EchoParam)
         end;
       end;
   end;
end;

procedure TBASSPlayer.SetReverbLevel(Value : word);
begin
   if Value > MaxDX8Effect then
      exit;

   FReverbLevel := Value;
   if Reverb in FSoundEffects then
   begin
      if ReverbHandle <> 0 then
       begin
         if BASS_FXGetParameters(ReverbHandle, @ReverbParam) then
         begin
            ReverbParam.fInGain := 0.0;
            ReverbParam.fReverbMix := FReverbLevel * 0.5 - 16.0;
            ReverbParam.fReverbTime := 1000.0;
            ReverbParam.fHighFreqRTRatio := 0.1;
            BASS_FXSetParameters(ReverbHandle, @ReverbParam)
         end;
       end;
   end;
end;

procedure TBASSPlayer.SetEQBands(Value : TEQBands);
var
   i : integer;
begin
   FEQBands.Bands := Value.Bands;
   if FEQBands.Bands > NumEQBands then
      FEQBands.Bands := NumEQBands;

   for i := 0 to (FEQBands.Bands-1) do
   begin
      FEQBands.BandPara[i].CenterFreq := Value.BandPara[i].CenterFreq;
      FEQBands.BandPara[i].BandWidth := Value.BandPara[i].BandWidth;
   end;

   if Equalizer in FSoundEffects then
     for i := 0 to (FEQBands.Bands-1) do
     begin
        if EQHandle[i] = 0 then
           EQHandle[i] := BASS_ChannelSetFX(Channel, BASS_FX_PARAMEQ, i+1);
        if EQHandle[i] <> 0 then
        begin
           EQParam.fGain := FEQGains[i];
           EQParam.fBandWidth := FEQBands.BandPara[i].BandWidth;
           EQParam.fCenter := FEQBands.BandPara[i].CenterFreq;
           BASS_FXSetParameters(EQHandle[i], @EQParam);
        end;
     end;

   for i := FEQBands.Bands to (NumEQBands-1) do
   begin
      if EQHandle[i] <> 0 then
         if BASS_ChannelRemoveFX(Channel, EQHandle[i]) then
            EQHandle[i] := 0;
   end;
end;

procedure TBASSPlayer.SetSoundEffect(Value : TSoundEffects);
var
   i : integer;
  // Saved8087CW: Word;
begin
   FSoundEffects := Value;

   if ChannelType = Channel_NotOpened then
      exit;

   if Flanger in Value then
   begin
      if fladspHandle = 0 then
      begin
         FillChar(flabuf, SizeOf(flabuf), 0);
         flapos := 0;
         flas := FLABUFLEN / 2;
         flasinc := 0.002;
         fladspHandle := BASS_ChannelSetDSP(Channel, Flange, 0, 0);
      end;
   end else
      if fladspHandle <> 0 then
         if BASS_ChannelRemoveDSP(Channel, fladspHandle) then
            fladspHandle := 0;

   if not FDX8EffectReady then
      exit;

 //  Saved8087CW := Default8087CW;
 //  Set8087CW($133f);  { Disable all fpu exceptions }

   if Equalizer in Value then
   begin
      for i := 0 to (FEQBands.Bands-1) do
      begin
         if EQHandle[i] = 0 then
            EQHandle[i] := BASS_ChannelSetFX(Channel, BASS_FX_PARAMEQ, i+1);

         if EQHandle[i] <> 0 then
         begin
            EQParam.fGain := FEQGains[i];
            EQParam.fBandWidth := FEQBands.BandPara[i].BandWidth;
            EQParam.fCenter := FEQBands.BandPara[i].CenterFreq;
            BASS_FXSetParameters(EQHandle[i], @EQParam);
         end;
      end;
   end else
      for i := 0 to (FEQBands.Bands{NumEQBands}-1) do
      begin
         if EQHandle[i] <> 0 then
            if BASS_ChannelRemoveFX(Channel, EQHandle[i]) then
               EQHandle[i] := 0;
      end;

   if Echo in Value then
   begin
       if EchoHandle = 0 then
          EchoHandle := BASS_ChannelSetFX(Channel, BASS_FX_ECHO, NumEQBands+1);
       if EchoHandle <> 0 then
       begin
         if BASS_FXGetParameters(EchoHandle, @EchoParam) then
         begin
            EchoParam.fWetDryMix := FEchoLevel * 1.2{30.0};
            EchoParam.fFeedBack := 30.0;
            BASS_FXSetParameters(EchoHandle, @EchoParam)
         end;
       end;
   end else
      if EchoHandle <> 0 then
         if BASS_ChannelRemoveFX(Channel, EchoHandle) then
            EchoHandle := 0;

   if Reverb in Value then
   begin
       if ReverbHandle = 0 then
          ReverbHandle := BASS_ChannelSetFX(Channel, BASS_FX_REVERB, NumEQBands+2);
       if ReverbHandle <> 0 then
       begin
         if BASS_FXGetParameters(ReverbHandle, @ReverbParam) then
         begin
            ReverbParam.fInGain := 0.0;
            ReverbParam.fReverbMix := FReverbLevel * 0.5 - 16.0;
            ReverbParam.fReverbTime := 1000.0;
            ReverbParam.fHighFreqRTRatio := 0.1;
            BASS_FXSetParameters(ReverbHandle, @ReverbParam)
         end;
       end;
   end else
      if ReverbHandle <> 0 then
         if BASS_ChannelRemoveFX(Channel, ReverbHandle) then
            ReverbHandle := 0;

   // Set8087CW(Saved8087CW);  { Restore to original status }
end;


function  TBASSPlayer.RunVisoutProgram(VismodName : string; VismodNo : word{;
                              MainWinHwnd : HWND}) : boolean; // * Modified at Ver 1.5
{type
  _PROCESS_INFORMATION = record
     hProcess : HWND;
     hThread : HWND;
     dwProcessId : DWORD;
     dwThreadId : DWORD;
  end; }
var
   TimerStat : boolean;
   CmdLineStr : string;
   ProcId : DWORD;
   VisOutHandle : HWND;
   SyncWord : word;
   StartupInfo: TStartupInfo;
   BeginPath: PChar;
   ProcessInfo : _PROCESS_INFORMATION;
begin
 // Winamp visualization plug-ins are designed to be run in their own user
 // interface thread.
 // I have made a program named "VisOut.exe" to run Winamp visualization plug-ins
 // in a seperate process.
 // The visualization data are fed to "VisOut.exe" via shared memory.
 // note : Some Winamp visualization plug-ins won't be run, if the cooperator
 //        of them is not Winamp.exe. I use fake Winamp window to overcome
 //        this obstacle.

   result := false;

   if not VisThread.VisThreadReady then
   begin
      MessageBox(AppHWND, 'Cannot run Winamp visualization plug-ins', 'Notify',
                                                   MB_OK or MB_ICONWARNING);
      exit;
   end;

   if not FileExists(VismodName) then
   begin
      MessageBox(AppHWND, 'Specified visualization plug-in does not exist', 'Notify',
                                                   MB_OK or MB_ICONWARNING);
      exit;
   end;

   if WaitingVisualizer then   // prohibit duplicate request to launch visualizer
      exit;

   VisOutHandle := FindWindow('TApplication', 'VisOut');
   if VisOutHandle <> 0 then  // VisOut.exe is running ?
   begin
      GetWindowThreadProcessId(VisOutHandle, @ProcId); // get process identifier
      if ProcId = VisProcId then  // if VisOut.exe is being run by this program then quit it
         VisThread.fisSharedMemory1.InformDataReady(QuitProg, 0)
      else begin
      // Multiple instance of VisOut.exe is not allowed because they will use
      // same address space obtained by fisSharedMemory1.
         MessageBox(AppHWND, 'Visout.exe is being run by another program', 'Notify',
                                                   MB_OK or MB_ICONWARNING);
         exit;
      end;
   end;

   WaitingVisualizer := true;
   TimerStat := TimerFFT.Enabled;
   TimerFFT.Enabled := false;

   GetWindowThreadProcessId(AppHWND, @ProcId);
   if FSyncVisWindow then
      SyncWord := 1
   else
      SyncWord := 0;

   CmdLineStr := GetProgDir + 'VisOut.exe'  // Added some parameters at Ver 1.5
                      + ' "' + VismodName
                      + '" '+ intToStr(VismodNo)
                      + ' ' + intToStr(int64(ProcId))
                      + ' ' + intToStr(ParentHWND{MainWinHwnd})
                      + ' ' + intToStr(MessageHandle)
                      + ' "' + FStreamInfo.Title
                      + ' " ' + intToStr(FStreamInfo.Channels)
                      + ' ' + intToStr(FStreamInfo.SampleRate)
                      + ' ' + intToStr(FStreamInfo.BitRate)
                      + ' ' + intToStr(FStreamInfo.Duration)
                      + ' ' + intToStr(ord(FPlayerMode))
                      + ' ' + intToStr(SyncWord);

   FillChar (StartupInfo, Sizeof(StartupInfo), 0);
   StartupInfo.cb := Sizeof(StartupInfo);
   StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
   StartupInfo.wShowWindow := SW_NORMAL;
   BeginPath := pchar(GetProgDir);
   Result := CreateProcess(nil, pchar(CmdLineStr),
                           nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS,
                           nil, BeginPath, StartupInfo, ProcessInfo);

   if Result then
   begin
     VisProcId := ProcessInfo.dwProcessId;
     CloseHandle(ProcessInfo.hThread);
     CloseHandle(ProcessInfo.hProcess);
   end else
      MessageBox(AppHWND, 'Failed to run VisOut.exe', 'Error',
                                                   MB_OK or MB_ICONERROR);

   TimerFFT.Enabled := TimerStat;
end;

procedure TBASSPlayer.QuitVisoutProgram;
begin
   if not VisThread.VisThreadReady then
      exit;

   VisThread.Suspend;
   GoVisOut := false;

 // Inform "VisOut.exe" that it's time to end
   if FindWindow('TApplication', 'VisOut') <> 0 then
      VisThread.fisSharedMemory1.InformDataReady(QuitProg, 0);

end;

function TBassPlayer.RunDSPPlugin(DSPmodName : string; DSPmodNo : word{;
                              MainWinHwnd : HWND}) : boolean; // * Added at Ver 1.5
var
   DSPheader : PWinampDSPHeader;
   NumDSPmod : integer;
   Msg : pchar;
begin
   result := false;

   LoadDSPModule(DSPmodName, DSPheader, DSPmod, NumDSPmod, ParentHWND{MainWinHwnd});
   if (DSPmodNo < NumDSPmod) then
   begin
      if StartDSPModule(DSPmodNo) = 0 then
      begin
    // DSP plug-ins are activated by direct coupling of input~DSP plug-ins.
    // So, following 'BASS_ChannelSetDSP' is not necessary.
    // If you want to activate DSP plug-ins without the need of input plug-ins,
    // you must complete the WinampDSPProc procedure. ( I have not completed it yet.)
    //     DSPHandle := BASS_ChannelSetDSP(Channel, WinampDSPProc, 0, 0);
         DSPModNum := DSPModNo;
         result := true;   // succeed
      end
      else begin
         UnloadDSPModule;
         Application.MessageBox('Specified plug-in is not operative', 'Error',
                                                          MB_OK + MB_ICONERROR);
       //  Application.Terminate;
      end;
   end else begin
      if NumDSPmod = 0 then
         Msg := 'Specified plug-in is invalid'
      else
         Msg := 'Invalid module number';
      Application.MessageBox(Msg, 'Error', MB_OK + MB_ICONERROR);
     // Application.Terminate;
   end;
end;

procedure TBASSPlayer.QuitDSPPlugin;
begin
   StopDSPModule;
 //  if DSPHandle <> 0 then
 //  begin
 //     BASS_ChannelRemoveDSP(Channel, DSPHandle);
 //     DSPHandle := 0;
 //  end;
end;

procedure TBASSPlayer.SetPluginFirst(Value : boolean);
begin
   FPluginFirst := Value;
end;

// This procedure is used to inhibit or to allow unloading of Winamp
// input plug-ins.
//   SetUnloadBut(false) -> inhibit,  SetUnloadBut(true) -> allow
procedure TBASSPlayer.SetUnloadBut(Value : boolean);
begin
   FUnloadButEnabled := value;
   PluginConfigForm.btnUnload.Enabled := value;
end;

procedure TBASSPlayer.SetSyncVisWindow(Value : boolean);
begin
   if Value <> FSyncVisWindow then
   begin
      FSyncVisWindow := Value;
      InformPlayerStatus(stSyncWindows);
   end;
end;

procedure TBASSPlayer.SetVisScale(Value : word);
begin
   if (Value < 256) or (Value > 1024) then
      exit;

   FVisScale := Value;
   VisThread.SetVisScale(FVisScale);
end;


constructor TBASSPlayer.Create(AOwner: TComponent);
var
   i : integer;
   BASSVersion : DWORD;
   d: PChar;
   t : string;
   n: Integer;
begin
   inherited Create(AOwner);

   FVersionStr := Ver;
   FBASSReady := false;
   FBASSWMAReady := false;
   FBASSCDReady := false;
   FNumCDDrives := 0;

   ChannelType := Channel_NotOpened;
   FSoundEffects := [];
   FPlayerMode := plmStandby;
   FStreamName :='';
   FStreamInfo.FileName := '';
   FStreamInfo.SampleRate := 0;
   FPluginFirst := false;
   FVisScale := 512;        // Scale factor for visualizer
   FSyncVisWindow := false; // Syncronized action (disabled)

   if not (csDesigning in ComponentState) then
   begin
     ParentHWND := (AOwner as TWinControl).Handle;
     AppHWND := Application.Handle;
     MessageHandle := AllocateHWnd(ProcMessage);
     SetMainHandle(MessageHandle);  // set hMainHandle in PluginCtrl unit
     TimerFFT := TTimer.Create(nil);
     TimerFFT.Interval := 25;       // * Changed at Ver 1.51 (33 -> 25)
     TimerFFT.Enabled := false;
     TimerFFT.OnTimer := TimerFFTTimer;
   end;

   BASSDLLLoaded := Load_BASSDLL(GetProgDir + 'bass.dll');
   if not BASSDLLLoaded then
   begin
      if (csDesigning in ComponentState) then
         FDLLVersionStr := 'N.A.(Copy bass.dll in <directory Delphi installed>\Bin to get version)'
      else
         FDLLVersionStr := '';
      exit;
   end;

   BASSVersion := BASS_GetVersion;
   if (BASSVersion <> MAKELONG(2,1)) then
   begin
     if not (csDesigning in ComponentState) then
        Application.MessageBox('BASS version is not 2.1 !', 'Confirm', MB_OK);
     exit;
   end;

   BASS_SetConfig(BASS_CONFIG_MAXVOL, MaxVolume);  // Set maximum volume range
 // setup output - default device, 44100hz, stereo, 16 bits
   if not BASS_Init(1, 44100, 0, AppHWND, nil) then
   begin
      if not (csDesigning in ComponentState) then
         Error('Can''t initialize device');
      exit;
   end else
      FBASSReady := true;

   BassInfoParam.size := SizeOf(BassInfoParam);
   BASS_GetInfo(BassInfoParam);

 // BASS_ChannelSetFX requires DirectX version 8 or higher
   if BassInfoParam.dsver >= 8 then
   begin
      FDX8EffectReady := true;
   end else begin
      if not (csDesigning in ComponentState) then
         MessageBox(AppHWND, NoDX8Msg, 'Warning', MB_ICONWARNING or MB_OK);
      FDX8EffectReady := false;
   end;

   FEQBands.Bands := NumEQBands;
   for i := 0 to (NumEQBands-1) do
   begin
      FEQGains[i] := 0;
      FEQBands.BandPara[i].CenterFreq := EQFreq[i];
      FEQBands.BandPara[i].BandWidth := EQBandWidth[i];
   end;
   FEchoLevel := MaxDX8Effect div 2{16};
   FReverbLevel := MaxDX8Effect div 2{16};

   FOutputVolume := MaxVolume;
   BASS_SetConfig(BASS_CONFIG_GVOL_MUSIC, FOutputVolume);
   BASS_SetConfig(BASS_CONFIG_GVOL_STREAM, FOutputVolume);

   FDLLVersionStr := GetDLLVersionStr;

   if not (csDesigning in ComponentState) then
   begin
      if FBASSReady then
      begin
         if Load_BASSWMADLL(GetProgDir + 'basswma.dll') then
            FBASSWMAReady := true;
         if Load_BASSCDDLL(GetProgDir + 'basscd.dll') then
         begin
            FBASSCDReady := true;
         // Get list of available CDROM drives
            n := 0;
            d := BASS_CD_GetDriveDescription(n);
            while (n < MAXCDDRIVES) and (d <> nil) do
            begin
               t := Format('%s: %s', [Char(BASS_CD_GetDriveLetter(n) + Ord('A')), d]); // "letter: description"
               CDDriveList[n] := t;
               n := n + 1;
               d := BASS_CD_GetDriveDescription(n);
            end;
            FNumCDDrives := n;
         end;
      end;

      InitPluginCtrl;
      MessageHandle2 := GetMsgHandler;  // = message handler of PluginCtrl unit
      MPEG := TMPEGaudio.Create;
      Vorbis := TOggVorbis.Create;
      WMA := TWMAfile.Create;
      WAV := TWAVFile.Create;

      PluginConfigForm := TPluginConfigForm.Create(Self);
      SetMessageHandle(MessageHandle);
      FUnloadButEnabled := PluginConfigForm.btnUnload.Enabled;

      VisThread := TVisThread.Create(Self);
      VisThread.SetVisScale(FVisScale);
   end;
end;


destructor  TBASSPlayer.Destroy;
begin
   if ChannelType = Channel_Plugin then
   begin
      if Channel <> 0 then
         APlugin.Stop
   end else if (FPlayerMode = plmPlaying) then
      Stop;

   repeat
      WinProcessMessages;
   until BASS_ChannelIsActive(Channel) <> BASS_ACTIVE_PLAYING;

   if not (csDesigning in ComponentState) then
   begin
     TimerFFT.Free;
     MPEG.Free;
     Vorbis.Free;
     WMA.Free;
     WAV.Free;
     QuitPluginCtrl;
     if MessageHandle <> 0 then
        DeallocateHWnd(MessageHandle);

     VisThread.Free;
     PluginConfigForm.Free;
   end;

   if BASSDLLLoaded then
   begin
      BASS_Free;
      Unload_BASSDLL;
   end;
   if FBASSWMAReady then
      Unload_BASSWMADLL;
   if FBASSCDReady then
      Unload_BASSCDDLL;

   inherited Destroy;
end;

// Get the version information as string
function TBASSPlayer.GetDLLVersionStr : string;
var
   VersionNum : DWORD;
begin
   if not FBASSReady then
   begin
      result := '';
      exit;
   end;

   VersionNum := BASS_GetVersion;
   result := intToStr(LoWord(VersionNum)) + '.' + intToStr(HiWord(VersionNum));
end;

function TBASSPlayer.GetNativeFileExts : string;
const
   StreamFileExt = '*.wav;*.mp1;*.mp2;*.mp3;*.ogg;';
   MusicFileExt = '*.MO3;*.IT;*.XM;*.S3M;*.MTM;*.MOD;*.UMX;';
begin
   if not FBASSReady then
      result := ''
   else if FBASSCDReady and FBASSWMAReady then
      result := StreamFileExt + MusicFileExt + '*.cda;*.wma;'
   else if FBASSCDReady then
      result := StreamFileExt + MusicFileExt + '*.cda;'
   else if FBASSWMAReady then
      result := StreamFileExt + MusicFileExt + '*.wma;'
   else
      result := StreamFileExt + MusicFileExt;

  { if FBASSReady and FBASSWMAReady then
      result := '*.wav;*.mp1;*.mp2;*.mp3;*.ogg;*.wma;'
   else if FBASSReady then
      result := '*.wav;*.mp1;*.mp2;*.mp3;*.ogg;'
   else
      result := ''; }
end;

function TBASSPlayer.GetPluginFileExts : string;
begin
   result := GetPlayableFiles;
end;

function TBASSPlayer.PluginInfoBox(StreamName : string): Boolean;
var
   i : integer;
   s, ExtCode : string;
   tmpAPlugin : TPlugin;
   APluginInfo : TPluginInfo;
   _file : array[0..255] of char;
begin
   result := false;

   ExtCode := UpperCase(ExtractFileExt(StreamName));
   if (ExtCode = '') or ((length(ExtCode) <> 4) and (length(ExtCode) <> 3)) then
      exit;

   // Check if it is the file type that can be played by Winamp input plug-in
   for i := 0 to MaxPluginNum - 1 do
   begin
      tmpAPlugin := GetPlugin(i);
      if tmpAPlugin <> nil then
      begin
         APluginInfo := GetPluginInfo(i);
         s := uppercase(APluginInfo.FileExtensions);
         if pos(copy(ExtCode, 2, 3), s) <> 0 then
         begin
            result := true;
            StrPCopy(_file, StreamName);
            tmpAPlugin.InfoBox(_file, ParentHWND);
            break;
         end;
      end;
   end;
end;

function TBASSPlayer.GetStreamInfo2(StreamName : string;
                       var StreamInfo : TStreamInfo;
                       var SupportedBy : TSupportedBy;
                       var PluginNum : integer) : boolean;
var
   i, n : integer;
   f : file;
   tmpTitle : array [1..28] of Char;
   s, ExtCode : string;
   DriveLetter : string[2];

   tmpAPlugin : TPlugin;
   APluginInfo : TPluginInfo;
   _file : array[0..255] of char;
   _title : array[0..255] of char;
   _length_in_ms : integer;
begin
   result := false;

   with StreamInfo do
   begin
      FileName := '';
      FileSize := 0;
      SampleRate := 0;
      BitRate := 0;
      BitsPerSample := 16;  // default value except WAV file
      Duration := 0;
      Title := '';
      Artist := '';
      Album := '';
      Year := '';
      Genre := '';
      GenreID := 0;
      Track := 0;
      Comment := '';
      Channels := 0;
   end;

   StreamInfo.FileName := StreamName;
   SupportedBy := None;
   PluginNum := -1;

   ExtCode := UpperCase(ExtractFileExt(StreamName));
   if (ExtCode = '') or ((length(ExtCode) <> 4) and (length(ExtCode) <> 3)) then
      exit;

 // Check if native file types
   if ExtCode = '.WAV' then
   begin
      WAV.ReadFromFile(StreamName);
      if WAV.Valid then
      begin
         with StreamInfo do
         begin
            FileSize := WAV.FileSize;
            SampleRate := WAV.SampleRate;
            BitsPerSample := WAV.BitsPerSample;
            BitRate := (SampleRate * BitsPerSample) div 1000;  // Why not 1024 ?
            Duration := round(WAV.Duration * 1000);
            Channels := WAV.ChannelModeID;
         end;
         if FBASSReady then
            SupportedBy := BASSNative;
         result := true;
      end;
   end else if (ExtCode = '.MP1') or (ExtCode = '.MP2') or (ExtCode = '.MP3') then
   begin
      MPEG.ReadFromFile(StreamName);
      if MPEG.Valid then
      begin
         with StreamInfo do
         begin
            FileSize := MPEG.FileLength;
            SampleRate := MPEG.SampleRate;
            BitRate := MPEG.BitRate;
            Duration := round(MPEG.Duration * 1000);

            if MPEG.ID3v1.Exists then
            begin
               Title := MPEG.ID3v1.Title;
               Artist := MPEG.ID3v1.Artist;
               Album := MPEG.ID3v1.Album;
               Year := MPEG.ID3v1.Year;
               Genre := MPEG.ID3v1.Genre;
               GenreID := MPEG.ID3v1.GenreID;
               Track := MPEG.ID3v1.Track;
               Comment := MPEG.ID3v1.Comment;
            end else if MPEG.ID3v2.Exists then
            begin
               Title := MPEG.ID3v2.Title;
               Artist := MPEG.ID3v2.Artist;
               Album := MPEG.ID3v2.Album;
               Year := MPEG.ID3v2.Year;
               Genre := MPEG.ID3v2.Genre;
               Track := MPEG.ID3v2.Track;
               Comment := MPEG.ID3v2.Comment;
            end;

            if MPEG.ChannelMode = 'Mono' {MPEG_CM_MONO} then
               Channels := 1
            else
               Channels := 2;
         end;
         if FBASSReady then
            SupportedBy := BASSNative;
         result := true;
      end;
   end else if ExtCode = '.OGG' then
   begin
      Vorbis.ReadFromFile(StreamName);
      if Vorbis.Valid then
      begin
         with StreamInfo do
         begin
            FileSize := Vorbis.FileSize;
            SampleRate := Vorbis.SampleRate;
            BitRate := Vorbis.BitRate;
            Duration := round(Vorbis.Duration * 1000);
            Title := Vorbis.Title;
            Artist := Vorbis.Artist;
            Album := Vorbis.Album;
            Year := Vorbis.Date;
            Genre := Vorbis.Genre;
            Channels := Vorbis.ChannelModeID;
            Track := Vorbis.Track;
            Comment := Vorbis.Comment;
         end;
         if FBASSReady then
            SupportedBy := BASSNative;
         result := true;
      end;
   end else if ExtCode = '.WMA' then
   begin
      WMA.ReadFromFile(StreamName);
      if WMA.Valid then
      begin
         with StreamInfo do
         begin
            FileSize := WMA.FileSize;
            SampleRate := WMA.SampleRate;
            BitRate := WMA.BitRate;
            Duration := round(WMA.Duration * 1000);
            Title := WMA.Title;
            Artist := WMA.Artist;
            Album := WMA.Album;
            Year := WMA.Year;
            Genre := WMA.Genre;
            Channels := WMA.ChannelModeID;
            Track := WMA.Track;
            Comment := WMA.Comment;
         end;
         if FBASSWMAReady then
            SupportedBy := BASSNative;
         result := true;
      end;
   end else if ExtCode = '.CDA' then
   begin
      if FBASSCDReady then
      begin
         DriveLetter := copy(UpperCase(StreamName), 1, 1);
         for i := 0 to (FNumCDDrives - 1) do
         begin
          // Check if the specified stream file is in a Audio CD.
            if DriveLetter = copy(CDDriveList[i], 1, 1) then
            begin
               n := strToint(copy(StreamName, length(StreamName) - 5, 2)) - 1;
               with StreamInfo do
               begin
                  FileSize := BASS_CD_GetTrackLength(i, n);
                  SampleRate := 44100;
                  BitRate := 1408;
                  Duration := (FileSize * 10) div 1764;  // in mili seconds
                  Channels := 2;
                  Track := n;
               end;
               SupportedBy := BASSNative;
               result := true;
            end;
         end;
      end;

 // * Added at Ver 1.6 (support music file)
   end else if (ExtCode = '.MO3') or (ExtCode = '.IT') or (ExtCode = '.XM') or
      (ExtCode = '.S3M') or (ExtCode = '.MTM') or (ExtCode = '.MOD') or
      (ExtCode = '.UMX') then
   begin
  // I do not have full technical information on MOD music, so only basic information
  // is given to StreamInfo record.
      AssignFile(f, StreamName);
      Reset(f, 1);
      StreamInfo.FileSize := FileSize(f);
      with StreamInfo do
      begin
         FileName := StreamName;

     // Get the title for some types of music files.
     // I am not sure it always works correctly.
         FillChar(tmpTitle, SizeOf(tmpTitle), ' ');
         if (ExtCode = '.MOD') or (ExtCode = '.MTM') or (ExtCode = '.XM') or
            (ExtCode = '.IT') then
         begin
            if (ExtCode = '.XM') then
                Seek(f, $11)
            else if (ExtCode = '.IT') or (ExtCode = '.MTM') then
                Seek(f, 4);
            BlockRead(f, tmpTitle, 20);
            Title := TrimRight(tmpTitle);
         end else if (ExtCode = '.S3M') then
         begin
            BlockRead(f, tmpTitle, 28);
            Title := TrimRight(tmpTitle);
         end else    // for MO3 and UMX file ( I cannot get any documentation on these files )
            Title := ExtractFileName(StreamName);  // Not the title given to music file

         SampleRate := 44100;
         BitRate := 1408;
         Channels := 2;
      end;

      CloseFile(f);
      SupportedBy := BASSNative;
      result := true;
   end;

 // Check if it is the file type that can be played by Winamp input plug-in
   for i := 0 to MaxPluginNum - 1 do
   begin
      tmpAPlugin := GetPlugin(i);
      if tmpAPlugin <> nil then
      begin
         APluginInfo := GetPluginInfo(i);
         s := uppercase(APluginInfo.FileExtensions);
         if pos(copy(ExtCode, 2, 3), s) <> 0 then
         begin
            PluginNum := i;
            StrPCopy(_file, StreamName);
            tmpAPlugin.GetFileInfo(_file, _title, _length_in_ms);
            if (_length_in_ms > 0) then
            begin
               with StreamInfo do
               begin
                  if SupportedBy = BASSNative then
                     SupportedBy := Both
                  else begin
                     if FBASSReady then
                        SupportedBy := WinampPlugin;
                     Title := string( _title);
                     Duration := _length_in_ms;
                     result := true;
                  end;
                  break;
               end;
            end;
         end;
      end;
   end;

   if (result = true) and (StreamInfo.Title = '') then
      StreamInfo.Title := ExtractFileName(StreamName);
end;

function TBASSPlayer.GetStreamInfo(StreamName : string;
                       var StreamInfo : TStreamInfo;
                       var SupportedBy : TSupportedBy) : boolean;
var
   dumNum : integer;
begin
   result := GetStreamInfo2(StreamName, StreamInfo, SupportedBy, dumNum);
end;


procedure TBASSPlayer.ProcMessage(var Msg: TMessage);
var
   PChannelInfo : ^TChannelInfo;
   PTitle : PChar;
   ExtCode : string;
   TagP : pchar;
   TagVer : word;
   MP3Tag : MP3TagRec;
   PlaybackSec : float;
   PBandOut : ^WORD;
   i : integer;

   _title : array[0..255] of char;
   _length_in_ms : integer;
begin
   if Msg.Msg = VisThread.DataReadyMsg then   // message from visualizer ?
   begin
      if Msg.wParam = VisModuleLoaded then      // visualizer loaded ?
      begin
         VisThread.SetDelayMS(Msg.lParam);
      end else if Msg.wParam = StartVisOut then // visualizer started ?
      begin
         if Msg.lParam <> 0 then
         begin
            VisWindowHandle := Msg.lParam;
            VisThread.fisSharedMemory1.TargetApplication := 'VisOut';
            GoVisOut := true;
            if (FPlayerMode = plmPlaying) and VisThread.Suspended then
               VisThread.Resume;
         end;
         WaitingVisualizer := false;
      end else
      if Msg.wParam = EndVisOut then       // visualizer ended ?
      begin
         VisWindowHandle := 0;
         GoVisOut := false;
         if not VisThread.Suspended then
            VisThread.Suspend;
      end else
      if Msg.wParam = QueryStatus then      // query from visualizer ?
      begin
         if Msg.lParam = stPlayerMode then
            InformPlayerStatus(stPlayerMode)
         else if Msg.lParam = stStreamInfo then
            InformPlayerStatus(stStreamInfo)
         else if Msg.lParam = stSyncWindows then
            InformPlayerStatus(stSyncWindows);
      end;

      exit;
   end;

   case Msg.Msg of
      WM_NewFFTData    : if Assigned(FOnNewFFTData) then
                            FOnNewFFTData(Self, BandOut);
      WM_GetFFTData    : begin
                            PBandOut := pointer(Msg.lParam);
                            for i := 0 to NumFFTBands do
                            begin
                               BandOut[i] := PBandOut^;
                               inc(PBandOut);
                            end;
                            FOnNewFFTData(Self, BandOut);
                         end;
   // We do not know the Channels & SampleRate of opened stream file before Winamp
   // input plug-in informs to output plug-in, if the file type is the one which is
   // supported only by Winamp input plug-in.
   // WM_StartPlay message is used to receive the Channels & SampleRate of opened
   // stream file at starting playback from output plug-in emulator.
   // We still cannot know the Channels & SampleRate of opened stream file if its related
   // Winamp input plug-in is the type which directly sound out (= not thru output plug-in emulator).
      WM_StartPlay     : begin             // Message from output plug-in emulator
                            NowStarting := false;
                            UsesOutputPlugin := true;
                            SetVolume(FOutputVolume);
                            PChannelInfo := pointer(Msg.lParam);
                            FStreamInfo.Channels := PChannelInfo^.Channels;
                            FStreamInfo.SampleRate := PChannelInfo^.SampleRate;
                            FStreamInfo.BitsPerSample := PChannelInfo^.BitsPerSample;
                            if FStreamInfo.Duration = 0 then  // for internet stream
                            begin
                           //    FStreamInfo.Duration := APlugin.GetLength;
                               APlugin.GetFileInfo(nil, _title, _length_in_ms);
                               if (_length_in_ms > 0) then
                               begin
                                  with FStreamInfo do
                                  begin
                                    Title := string( _title);
                                    Duration := _length_in_ms;
                                  end;
                               end;
                            end;
                            InformPlayerStatus(stStreamInfo);
                            if Assigned(OnPluginStartPlay) then
                               FOnPluginStartPlay(Self, pointer(Msg.lParam));
                            VisThread.SetChannelInfo(Channel,
                                                     FStreamInfo.SampleRate,
                                                     FStreamInfo.Channels);
                            if Assigned(FOnNewFFTData) then
                               TimerFFT.Enabled := true;
                            SetSoundEffect(FSoundEffects);
                         end;
      WM_GetChannelInfo : begin    // The basic characteristics of a stream to be played
                                   // are received from Winamp input plug-in.
                            PChannelInfo := pointer(Msg.lParam);
                            FStreamInfo.Channels := PChannelInfo^.Channels;
                            FStreamInfo.SampleRate := PChannelInfo^.SampleRate;
                            FStreamInfo.BitRate := PChannelInfo^.BitRate;
                            if Assigned(OnGetChannelInfo) then
                               FOnGetChannelInfo(Self, pointer(Msg.lParam));
                         end;
      WM_GetMeta       : begin     // BASS received Metadata in a Shoutcast stream
                            PTitle := pointer(Msg.lParam);
                            FStreamInfo.Title := string(PTitle);
                            InformPlayerStatus(stStreamInfo);
                            if Assigned(OnGetMeta) then
                               FOnGetMeta(Self, FStreamInfo.Title);
                         end;
      WM_DownLoaded    : begin     // BASS finished download of an internet stream
                            FDownloaded := true;
                            ExtCode := UpperCase(ExtractFileExt(FStreamName));
                            if (ExtCode = '.MP3') or (ExtCode = '.MP2') or (ExtCode = '.MP1') then
                            begin
                               TagP := BASS_StreamGetTags(Channel, BASS_TAG_ID3);
                               if TagP = nil then
                               begin
                                  TagP := BASS_StreamGetTags(Channel, BASS_TAG_ID3V2);
                                  if TagP = nil then
                                     TagVer := 0
                                  else
                                     TagVer := 2;
                               end else
                                  TagVer := 1;
                            end else
                               TagVer := 0;

                            FStreamInfo.FileSize := BASS_StreamGetFilePosition(Channel, BASS_FILEPOS_END);

                            if (TagVer = 1) or (TagVer = 2) then
                              if MPEG.ReadFromTagStream(TagP, FStreamInfo.FileSize, TagVer, MP3Tag) then
                                 with FStreamInfo do
                                 begin
                                    Title := MP3Tag.Title;
                                    Artist := MP3Tag.Artist;
                                    Album := MP3Tag.Album;
                                    Year := MP3Tag.Year;
                                    Genre := MP3Tag.Genre;
                                    Track := MP3Tag.Track;
                                    Comment := MP3Tag.Comment;
                                 end;

                         // Now we can get the exact playback length of an internet stream after finishing download.
                            PlaybackSec := BASS_ChannelBytes2Seconds(Channel, BASS_StreamGetLength(Channel));
                            FStreamInfo.Duration := round(1000 * PlaybackSec);  // in mili seconds
                            if Assigned(OnDownloaded) then
                               FOnDownloaded(Self, IntToStr(FStreamInfo.Duration));
                         end;
      WM_BASS_StreamCreate : Channel := Msg.WParam;  // Message from output plug-in emulator
     { WM_BASS_StreamFree   : begin                   // Message from output plug-in emulator
                                Channel := 0;
                                ClearEffectHandle;
                             end; }
      WM_WA_MPEG_EOF   : begin           // Winamp input plug-in reached the end of playback
                         //   SetPlayEnded;
                            NowStarting := false;
                            if UsesOutputPlugin then
                               while BASS_ChannelIsActive(Channel) = BASS_ACTIVE_PLAYING do
                               begin
                                  WinProcessMessages;
                                  sleep(50);
                               end;

                            Stop;
                            if Assigned(FOnPlayEnd) then
                               FOnPlayEnd(Self);
                         end;
      WM_GetToEnd      : begin                       // BASS reached the end of playback
                            FPlayerMode := plmStopped;
                            InformPlayerStatus(stPlayerMode);
                            if not VisThread.Suspended then
                               VisThread.Suspend;
                            if Assigned(FOnPlayEnd) then
                               FOnPlayEnd(Self);
                         end;
      WM_PluginFirst_Changed : if Msg.lParam = 0 then  // Message from PluginConfigForm
                                  FPluginFirst := false
                               else
                                  FPluginFirst := true;

      WM_QueryEndSession : Msg.Result := 1;    // Allow system termination
   end;
end;


function TBASSPlayer.Open(StreamName : string) : boolean;
var
   IsMusicFile : boolean;
   FromNet : boolean;
   StreamInfo : TStreamInfo;
   SupportedBy : TSupportedBy;
   PluginNum : integer;
   NameHeader1, NameHeader2 : string;
   tmpName : string;
   TagP : pchar;
   PlaybackSec : float;
   FileLen : integer;
   ExtCode, tmpStr : string;
   TitlePos, DelimeterPos : integer;

 // get the file name from the name of an internet stream
 // (ex: http://.../.../file_name.mp3 -> file_name)
  function ExtractFileName2(NetStream : string) : string;
  var
    pos, i : integer;
  begin
     pos := 0;
     for i := (length(NetStream) - 6)  downto 6 do
        if NetStream[i] = '/' then
        begin
           pos := i;
           break;
        end;

     if pos > 0 then
        result := copy(NetStream, pos + 1, length(NetStream) - pos - 4)
     else
        result := '';
  end;

begin
   result := false;

   if not FBASSReady then
   begin
      Application.MessageBox('Player is not ready !', 'Confirm', MB_OK);
      exit;
   end;

   FromNet := false;

   NameHeader1 := copy(StreamName, 1, 7);
   NameHeader2 := copy(StreamName, 1, 6);
   if (NameHeader1 = 'http://') or (NameHeader2 = 'ftp://') or
      (NameHeader2 = 'mms://') then
   begin
      FromNet := true;
      StreamInfo.FileName := StreamName;
      StreamInfo.BitRate := 0;
   end
   else if not GetStreamInfo2(StreamName, StreamInfo, SupportedBy, PluginNum) then
   begin
//      Application.MessageBox(pchar('Invalid stream file (' + StreamName + ') !'),
//                                                               'Confirm', MB_OK);
   if Assigned(OnAbspielfehler) then OnAbspielfehler;
      exit;                    //ich nutze überhaupt keine Streams. sinnlos...
   end;

   ExtCode := UpperCase(ExtractFileExt(StreamName));
   if (ExtCode = '.MO3') or (ExtCode = '.IT') or (ExtCode = '.XM') or
      (ExtCode = '.S3M') or (ExtCode = '.MTM') or (ExtCode = '.MOD') or
      (ExtCode = '.UMX') then
      IsMusicFile := true
   else
      IsMusicFile := false;

   // release previously assigned channel
   case ChannelType of
      Channel_Music : BASS_MusicFree(Channel);
      Channel_CD, Channel_WMA, Channel_Stream : BASS_StreamFree(Channel);
      Channel_Plugin : if Channel <> 0 then
                          APlugin.Stop;
   end;

 //  FPlayerMode := plmStandby;
 //  InformPlayerStatus(stPlayerMode);
   ChannelType := Channel_NotOpened;
   FDecodingByPlugin := false;
   FDownLoaded := false;
   NetStream := false;
   NetRadio  := false;
   ICYTag    := nil;
   HTTPTag   := nil;

   if FromNet then   // It's an internet stream.
   begin

  // ASF files and WMA files are streamed with Winamp input plug-in for the
  // file types.
  // note) WMA files on the internet can be streamed without Winamp plug-in, but
  //       I have found that some of BASS functions do not work properly.
  //       So I have decided to use Winamp plug-in.

      if (ExtCode = '.ASF') or (ExtCode = '.WMA') then
      begin
         if ExtCode = '.ASF' then
            PluginNum := GetPluginNumber('ASF')
         else
            PluginNum := GetPluginNumber('WMA');
         if PluginNum >= 0 then  // = A plug-in which can play ASF (or WMA) files is loaded
         begin
            ChannelType := Channel_Plugin;
            FPluginNum := PluginNum;
            APlugin := GetPlugin(PluginNum);
            FDecodingByPlugin := true;
            SelectInputPlugin(FPluginNum);
            StreamInfo.SampleRate := 0;
            StreamInfo.Duration := 0;
         end else
         begin
            Application.MessageBox('Winamp input plug-in for ASF (or WMA) file is not loaded.',
                                                       'Confirm', MB_OK);
            exit;
         end;
      end else
      begin
         Channel := BASS_StreamCreateURL(pchar(StreamName), 0, BASS_STREAM_META, nil, 0);
         if Channel <> 0 then
            ChannelType := Channel_Stream
         else if FBASSWMAReady then
         begin
         // Change the URL name "http://..." to "mms://..." {and add add a #0 at the end of the URL,}
         // for that of WMA stream.
         // I do not know the reason for this operation. Anyway BASS_WMA_StreamCreateFile may
         // not work without this operation.
            tmpName := StreamName {+ chr(0)};
            if NameHeader1 = 'http://' then
               tmpName := 'mms://' + copy(tmpName, 8, length(tmpName) - 7);
            Channel := BASS_WMA_StreamCreateFile(FALSE, PChar(tmpName), 0, 0, BASS_SYNC_META);
            if Channel <> 0 then
               ChannelType := Channel_WMA;
         end;
      end;

      if (ChannelType <> Channel_Plugin) and (Channel = 0) then  // not a playable URL stream
      begin
         Application.MessageBox(pchar('Can''t play the specified URL stream : ' + StreamName),
                                  'Confirm', MB_OK);
         Exit;
      end;

      if (ExtCode = '.MP3') or (ExtCode = '.MP2') or (ExtCode = '.MP1')
         or (ExtCode = '.OGG') or (ExtCode = '.WAV') or (ExtCode = '.WMA')
           or (ExtCode = '.ASF') then
      begin
         NetStream := true;

         if (ExtCode = '.OGG') then
         begin
            TagP := BASS_StreamGetTags(Channel, BASS_TAG_OGG);
            while StrLen(TagP) > 0 do
            begin
               tmpStr := string(TagP);
               if pos('TITLE=', tmpStr) <> 0 then
               begin
                  StreamInfo.Title := copy(tmpStr, 7, length(tmpStr) - 6);
                  break;
               end {else if pos('ARTIST=', tmpStr) <> 0 then
                  StreamInfo.Artist := copy(tmpStr, 8, length(tmpStr) - 7)
               else if pos('GENRE=', tmpStr) <> 0 then
                  StreamInfo.Genre := copy(tmpStr, 7, length(tmpStr) - 6)
               else if pos('ALBUM=', tmpStr) <> 0 then
                  StreamInfo.Album := copy(tmpStr, 7, length(tmpStr) - 6)};

               inc(TagP, StrLen(TagP) + 1);
            end;

     { // <-
         end else if (ExtCode = '.WMA') then
         begin
            TagP := BASS_StreamGetTags(Channel, BASS_TAG_ID3V2);
            ICYTag := TagP;
            while StrLen(TagP) > 0 do
            begin
               tmpStr := string(TagP);
               if pos('FileSize : ', tmpStr) <> 0 then
                  StreamInfo.FileSize := strToInt(copy(tmpStr, 12, length(tmpStr) - 11));
               if pos('Bitrate : ', tmpStr) <> 0 then
               begin
                  SepPos := pos(':', tmpStr);
                  StreamInfo.Bitrate := strToInt(copy(tmpStr, SepPos + 2, length(tmpStr) - (SepPos + 1))) div 1000;
               end;
               if pos('Title : ', tmpStr) <> 0 then
                  StreamInfo.Title := copy(tmpStr, 9, length(tmpStr) - 8);

               inc(TagP, StrLen(TagP) + 1);
            end;  // <-   }


      // We can get the TITLE & Playback length of stream files on the internet
      // at just before the starting playback from Winamp input plug-in if decoded
      // by Winamp input plug-in.
         end else if (ChannelType <> Channel_Plugin) then
            StreamInfo.Title := ExtractFileName2(StreamName);

         if ChannelType <> Channel_Plugin then
         begin
            if (NameHeader1 = 'http://') or (NameHeader2 = 'mms://') then
            begin
               TagP := BASS_StreamGetTags(Channel, BASS_TAG_HTTP);
               HTTPTag := TagP;
            end;

         // BASS_StreamGetLength may return a very rough estimation until the whole file
         // has been downloaded.
         // So it is needed to re-estimate after finishing download.
            PlaybackSec := BASS_ChannelBytes2Seconds(Channel, BASS_StreamGetLength(Channel));
            StreamInfo.Duration := round(1000 * PlaybackSec);  // in mili seconds

         // note) BASS_StreamGetFilePosition does not work for WMA files on the internet.
         //       Does the BASSWMA always download and play WMA files on the internet in
         //       smaller chunks ? (i.e., operates only in "buffered" mode ?)
            FileLen := BASS_StreamGetFilePosition(Channel, BASS_FILEPOS_END); // file length
            if FileLen <> -1 then
            begin
               StreamInfo.FileSize := FileLen;
               StreamInfo.BitRate := round(FileLen / (125 * PlaybackSec));   // bitrate (Kbps)
            end;

            BASS_ChannelSetSync(Channel, BASS_SYNC_DOWNLOAD, 0, @DownloadSync, MessageHandle);
         end;
      end else   // = Shout/Icecast server
      begin
         NetRadio := true;
         TagP := BASS_StreamGetTags(Channel, BASS_TAG_ICY);
         ICYTag := TagP;
         if TagP <> nil then  // * Added at 2004-03-20
            while StrLen(TagP) > 0 do
            begin
              if pos('icy-br:', string(TagP)) <> 0 then
              begin
                 inc(TagP, 7);
                 StreamInfo.BitRate := strToInt(string(TagP));
                 break;
              end;
              inc(TagP, StrLen(TagP) + 1);
            end;

         TagP := BASS_StreamGetTags(Channel, BASS_TAG_META);
         tmpStr := string(TagP);
         TitlePos := Pos('StreamTitle=', tmpStr);
         if TitlePos <> 0 then
         begin
            DelimeterPos := Pos(';', tmpStr);
            if DelimeterPos = 0 then
               StreamInfo.Title := copy(tmpStr, TitlePos + 13, length(tmpStr) - TitlePos - 13)
            else
               StreamInfo.Title := copy(tmpStr, TitlePos + 13, DelimeterPos - TitlePos - 14);
         end else
            StreamInfo.Title := '';

         BASS_ChannelSetSync(Channel, BASS_SYNC_META, 0, @MetaSync, MessageHandle);
      end;

      if (ChannelType <> Channel_Plugin) then
      begin
         BASS_ChannelGetInfo(Channel, BassChannelInfo);
         StreamInfo.SampleRate := BassChannelInfo.freq;
         StreamInfo.Channels := BassChannelInfo.chans;
         VisThread.SetChannelInfo(Channel, StreamInfo.SampleRate, StreamInfo.Channels);
      end;
   end    // end of for 'internet stream'

 // for local stream files
   else if (SupportedBy = WinampPlugin) or
      ((SupportedBy = Both) and FPluginFirst) then
   begin
      ChannelType := Channel_Plugin;
      FPluginNum := PluginNum;
      APlugin := GetPlugin(PluginNum);
  //    PostMessage(MessageHandle2, WM_StreamOpen, MessageHandle, FPluginNum);
      SelectInputPlugin(FPluginNum);
      FDecodingByPlugin := true;
   end else
   begin
      ExtCode := UpperCase(ExtractFileExt(StreamName));
      if (ExtCode <> '.CDA') and (ExtCode <> '.WMA') then
      begin
         if IsMusicFile then
         begin
            Channel := BASS_MusicLoad(FALSE, PChar(StreamName), 0, 0,
                            BASS_MUSIC_CALCLEN+BASS_MUSIC_POSRESET+BASS_MUSIC_RAMPS, 0);  // * changed at Ver 1.6 (added flags)
            if (Channel <> 0) then
            begin
               ChannelType := Channel_Music;
               StreamInfo.Duration := PlayLength;
            end;
         end else
         begin
            Channel := BASS_StreamCreateFile(FALSE, PChar(StreamName), 0, 0, 0{BASS_SAMPLE_FX});
            if (Channel <> 0) then
               ChannelType := Channel_Stream
         end;
      end else begin   // (ExtCode = '.CDA') or (ExtCode = '.WMA')
         if ExtCode = '.CDA' then
         begin
            if FBASSCDReady then
               Channel := BASS_CD_StreamCreateFile(PChar(StreamName), BASS_CD_FREEOLD{0});
            if (Channel <> 0) then
               ChannelType := Channel_CD;
         end else   // ExtCode = '.WMA'
         begin
            if FBASSWMAReady then
               Channel := BASS_WMA_StreamCreateFile(FALSE, PChar(StreamName), 0, 0, 0{BASS_SAMPLE_FX}); // it's a WMA?
            if (Channel <> 0) then
               ChannelType := Channel_WMA;
         end;
      end;

      if (Channel = 0) then  // not a playable file
      begin
         ChannelType := Channel_NotOpened;
         Error('Can''t play the file');
         if Assigned(OnAbspielfehler) then OnAbspielfehler;
         Exit;
      end;

   //   chattr := BASS_ChannelGetFlags(Channel) and ({BASS_SAMPLE_MONO or} BASS_SAMPLE_8BITS);
      BASS_ChannelGetInfo(Channel, BassChannelInfo);
      if (BassChannelInfo.flags and BASS_SAMPLE_8BITS) = BASS_SAMPLE_8BITS then
      begin
      // does not support 16-bit sources.
         BASS_MusicFree(Channel);
         BASS_StreamFree(Channel);
         Application.MessageBox('Sound card does not support 16-bit sources.',
                                  'Confirm', MB_OK);
         Exit;
      end;
      VisThread.SetChannelInfo(Channel, StreamInfo.SampleRate, StreamInfo.Channels);
   end;   // end of for 'local stream'

  // Reset previous handle values
   ClearEffectHandle;

  // Apply equalyzation and sound effects
   if ChannelType <> Channel_Plugin then
      SetSoundEffect(FSoundEffects);

   FStreamName := StreamName;
   FStreamInfo := StreamInfo;
   InformPlayerStatus(stStreamInfo);
   FPlayerMode := plmReady;
   InformPlayerStatus(stPlayerMode);
   result := true;
end;


procedure TBASSPlayer.Play;
var
   StartOK : boolean;
   wCycle : integer;
begin
   if NowStarting then   // avoid duplicate Play operation
      exit
   else if ChannelType = Channel_NotOpened then
      exit
   else if FPlayerMode = plmPlaying then
      exit
   else if FPlayerMode = plmPaused then
   begin
      ResumePlay;
      exit;
   end else if FPlayerMode = plmStopped then
   begin
      if ChannelType <> Channel_Plugin then
         SetPosition(0);   // Set position to starting point
      Restart;
      exit;
   end;

   StartOK := false;

 // play an opened channel
   if ChannelType = Channel_Plugin then
   begin
      NowStarting := true;
      UsesOutputPlugin := false;
      Channel := 1;  // for Winamp input plug-in which does not need output plug-in
      SetSongDuration(FStreamInfo.Duration);
      if APlugin.Play(pchar(FStreamName)) = 0 then
      begin
        //  some plug-ins starts with minimum volume (ex: in_cdda.dll)
         APlugin.SetVolume(FOutputVolume);
         wCycle := 0;
         while wCycle < 60 do
         begin
            if GetOutputTime(false) > 200 then
            begin
               StartOK := true;
               break;
            end;
            WinProcessMessages;
            inc(wCycle);
            sleep(50);
         end;
      end;
      if not StartOK then
         MessageBox(AppHWND,
                    PChar('Can''t play the specified stream : ' + FStreamName),
                    'Error', MB_ICONERROR or MB_OK);
      NowStarting := false;
   end else
      StartOK := BASS_ChannelPlay(Channel, true);

   if StartOK then
   begin
      if ChannelType <> Channel_Plugin then
         BASS_ChannelSetSync(Channel, BASS_SYNC_END, 0, @PlayEndSync, MessageHandle);
      if ChannelType = Channel_Music then
         MusicStartTime := timeGetTime;
      FPlayerMode := plmPlaying;
      InformPlayerStatus(stPlayerMode);
      if GoVisOut and VisThread.Suspended then
         VisThread.Resume;
      if (ChannelType <> Channel_Plugin) then
         if Assigned(FOnNewFFTData) then
            TimerFFT.Enabled := true;
   end;
end;

procedure TBASSPlayer.PausePlay;
begin
   if FPlayerMode <> plmPlaying then
      exit;

   if ChannelType = Channel_Plugin then
      APlugin.Pause
   else
      BASS_ChannelPause(Channel);

   if ChannelType = Channel_Music then
      MusicPauseTime := timeGetTime - MusicStartTime;
   FPlayerMode := plmPaused;
   InformPlayerStatus(stPlayerMode);
   if not VisThread.Suspended then
      VisThread.Suspend;
end;

procedure TBASSPlayer.ResumePlay;
begin
   if FPlayerMode <> plmPaused then
      exit;

   if ChannelType = Channel_Plugin then
      APlugin.UnPause
   else
      BASS_ChannelPlay(Channel, false);

   if ChannelType = Channel_Music then
      MusicStartTime := timeGetTime - MusicPauseTime;
   FPlayerMode := plmPlaying;
   InformPlayerStatus(stPlayerMode);
   if GoVisOut and VisThread.Suspended then
      VisThread.Resume;
   if Assigned(FOnNewFFTData) then
      if ChannelType <> Channel_Plugin then
         TimerFFT.Enabled := true
      else if UsesOutputPlugin then
         TimerFFT.Enabled := true;
end;

procedure TBASSPlayer.Pause(pAction : boolean);
begin
   if pAction then
      PausePlay
   else
      ResumePlay;
end;

procedure TBASSPlayer.Stop;
begin
   if FPlayerMode <> plmPlaying then
      exit;

   if ChannelType = Channel_Plugin then
   begin
      if Channel <> 0 then
      begin
         APlugin.Stop;
         Channel := 0;
         ClearEffectHandle;
      end
   end else
      BASS_ChannelStop(Channel);

   FPlayerMode := plmStopped;
   InformPlayerStatus(stPlayerMode);
   if not VisThread.Suspended then
      VisThread.Suspend;
end;

procedure TBASSPlayer.Restart;
var
   StartOK : boolean;
   wCycle : integer;
begin
   if FPlayerMode <> plmStopped then
      exit;
   if NowStarting then
      exit;
   StartOK := false;

  // play a opened channel
   if ChannelType = Channel_Plugin then
   begin
      NowStarting := true;
      UsesOutputPlugin := false;
      Channel := 1;  // for Winamp input plug-in which does not need output plug-in
      if APlugin.Play(pchar(FStreamName)) = 0 then
      begin
   //  some plug-ins starts with minimum volume (ex: in_cdda.dll)
         APlugin.SetVolume(FOutputVolume);
         wCycle := 0;
         while wCycle < 60 do
         begin
            if GetOutputTime(false) > 200 then
            begin
               StartOK := true;
               break;
            end;
            WinProcessMessages;
            inc(wCycle);
            sleep(50);
         end;
      end;
      NowStarting := false;
   end else
      StartOK := BASS_ChannelPlay(Channel, true);

   if StartOK then
   begin
      FPlayerMode := plmPlaying;
      InformPlayerStatus(stPlayerMode);
      if GoVisOut and VisThread.Suspended then
         VisThread.Resume;
      if (ChannelType <> Channel_Plugin) then
         if Assigned(FOnNewFFTData) then
            TimerFFT.Enabled := true;
   end;
end;


procedure TBASSPlayer.Close;
begin
   case ChannelType of
      Channel_Music : BASS_MusicFree(Channel);
      Channel_CD, Channel_Stream, Channel_WMA : BASS_StreamFree(Channel);
      Channel_Plugin : begin
                          if Channel <> 0 then
                          begin
                             APlugin.Stop;
                             Channel := 0;
                             ClearEffectHandle;
                          end;
                          FPluginNum := -1;
                          APlugin := nil;
                          PostMessage(MessageHandle2, WM_StreamClose, 0, 0);
                       end;
   end;

   ChannelType := Channel_NotOpened;
   FPlayerMode := plmStandby;
   InformPlayerStatus(stPlayerMode);
   if not VisThread.Suspended then
      VisThread.Suspend;
   FStreamName :='';
   FStreamInfo.FileName := '';
   FStreamInfo.SampleRate := 0;
end;


function TBASSPlayer.GetChannelFFTData(PFFTData : pointer; FFTFlag : DWORD) : boolean;
begin
   result := false;

   if BASS_ChannelIsActive(Channel) <> BASS_ACTIVE_PLAYING then
      exit;

   if (FFTFlag = BASS_DATA_FFT512) or
      (FFTFlag = BASS_DATA_FFT512 + BASS_DATA_FFT_INDIVIDUAL) or
      (FFTFlag = BASS_DATA_FFT1024) or
      (FFTFlag = BASS_DATA_FFT1024 + BASS_DATA_FFT_INDIVIDUAL) or
      (FFTFlag = BASS_DATA_FFT2048) or
      (FFTFlag = BASS_DATA_FFT2048 + BASS_DATA_FFT_INDIVIDUAL) then
      if BASS_ChannelGetData(Channel, PFFTData, FFTFlag) <> DW_ERROR {-1} then
         result := true;
end;


// If you have any idea on spectrum visualization for better result,
// please let me know.
procedure TBASSPlayer.TimerFFTTimer(Sender: TObject);
const
 // Classify FFTData[x] by the number of required bands for spectrum visualization.
 // FreqCoef defines the last index number of FFTData[x] for each band.
   FreqCoef : array[0..NumFFTBands - 1] of word =
               (  1,  2,    3,   6,       // narrow interval for low freq. range
                 12,  18,  24,  30,  36,  // normal interval for middle freq. range
                 42,  48,  54,  60,  66,
                 72,  78,  84,  90,  96,
                102, 108,
                120, 132, 156, 180 );     // wide interval for high freq. range

  // If the sampling rate is (standard) 44100Hz then the frequency of FFTData[x]
  // is 44100 / 512 * x, so the representative(or maximum) frequency of each
  // band is as followings
  //  BandOut[0] : 86.1Hz     BandOut[1] : 172.3Hz    BandOut[2] : 344.5Hz
  //  BandOut[3] : 516.8Hz    BandOut[4] : 1033.6Hz   BandOut[5] : 1550.4Hz
  //  . . . (516.8Hz interval upto BandOut[20]) . .   BandOut[20] : 9302.2Hz
  //  BandOut[21] : 10336Hz   BandOut[22] : 11370Hz   BandOut[23] : 13437Hz
  //  BandOut[24] : 15503Hz   . . very high frequency range is excluded

   Boost = 0.15; // Factor to intensify high frequency bands
   Scale = 80;   // Factor to calibrate the output range of BandOut[x]
                 //   ( approximately from 0 to 24 ).
var
   FFTData : TFFTData;
   NewBandOut : TBandOut;
   StartIndex : integer;
   i, k : integer;
   tmpIntensity : double;

begin
   if BASS_ChannelIsActive(Channel) <> BASS_ACTIVE_PLAYING then
      if BASS_ChannelIsActive(Channel) <> BASS_ACTIVE_STALLED then
      begin
         TimerFFT.Enabled := false;
         exit;
      end;

   if BASS_ChannelGetData(Channel, @FFTData, BASS_DATA_FFT512) = DW_ERROR {-1} then
   begin
      for i := 0 to (NumFFTBands - 1) do
         BandOut[i] := 0;
      exit;
   end;

   TimerFFT.Enabled := false;  // Avoid duplicate timer interrupt

   for i := 0 to (NumFFTBands - 1) do
   begin
       if i = 0 then
          StartIndex := 1
       else
          StartIndex := FreqCoef[i-1] + 1;

    // tmpIntensity <= the greatest value in classified FFTData[x]'s
       tmpIntensity := 0;
       for k := StartIndex to FreqCoef[i] do
           if FFTData[k] > tmpIntensity then
              tmpIntensity := FFTData[k];

       NewBandOut[i] := round(tmpIntensity * (1 + i * Boost) * Scale);

    // Decrease the value of BandOut[i] smoothly for better looking
       if NewBandOut[i] > BandOut[i] then
          BandOut[i] := NewBandOut[i]
       else
          if BandOut[i] >= 2 then
             dec(BandOut[i], 2)
          else
             BandOut[i] := 0;

    // for the case that original NewBandOut[i] is smaller than BandOut[i] by 1
       if NewBandOut[i] > BandOut[i] then
          BandOut[i] := NewBandOut[i];
   end;

 //  if not GoVisOut then
      PostMessage(MessageHandle, WM_NewFFTData, 0, 0);

   if not GoVisOut then
   begin
      TimerFFT.Enabled := true;
      exit;
   end;

   VisThread.SetPosition(CurrentPosition);

  // Following sentences to rendering FFT data to visualization plug-ins are
  // executed in a different class to raise refresh rate
 {  p1 := ShareMemPointer;
   inc(p1, 280); // FFT Data region is allocated from offset 280 thru 2595 in shared memory
   p1^ := FstreamInfo.SampleRate; // BassChannelInfo.freq;
   inc(p1, 1);
   p1^ := FstreamInfo.Channels;   // BassChannelInfo.chans;
   inc(p1, 1);
   p1^ := CurrentPosition;
   inc(p1, 1);
   p2 := pointer(p1);

   FillChar(SpectrumData, SizeOf(SpectrumData), 0);
   FillChar(WaveformData, SizeOf(waveformData), 0);

   if FstreamInfo.Channels = 1 then
   begin
      Bass_ChannelGetdata(Channel, @spectrumdata, BASS_DATA_FFT2048);
      for i := 1 To 576 do
      begin
        p2^ := trunc(SpectrumData[i] * FVisScale);
        inc(p2);
      end;
      for i := 1 To 576 do
      begin
        p2^ := trunc(SpectrumData[i] * FVisScale);
        inc(p2);
      end;
   end else

 // Add BASS_DATA_FFT_INDIVIDUAL flag for seperate FFT per each channel
   begin
      Bass_ChannelGetdata(Channel, @spectrumdata, BASS_DATA_FFT2048 + BASS_DATA_FFT_INDIVIDUAL);
      for i := 1 To 576 do
      begin
        p2^ := trunc(SpectrumData[i*2] * FVisScale);
        inc(p2);
      end;
      for i := 1 To 576 do
      begin
        p2^ := trunc(SpectrumData[i*2 + 1] * FVisScale);
        inc(p2);
      end;
   end;

   if FstreamInfo.Channels = 1 then
   begin
     Bass_ChannelGetdata(Channel, @waveformdata, 1152);
     for i := 0 to 575 do
     begin
       p2^ := waveformdata[i] div 256;
       inc(p2);
     end;
     for i := 0 to 575 do
     begin
       p2^ := waveformdata[i] div 256;
       inc(p2);
     end;
   end else
   begin
      Bass_ChannelGetdata(Channel, @waveformdata, 2304);
      for i := 0 to 575 do
      begin
        p2^ := waveformdata[i*2] div 256;
        inc(p2);
      end;
      for i := 0 to 575 do
      begin
        p2^ := waveformdata[i*2+1] div 256;
        inc(p2);
      end;
   end;

 // Inform "VisOut.exe" that visualization data is ready
   fisSharedMemory1.InformDataReady(DataReady, 2316); }

   TimerFFT.Enabled := true;
end;


procedure TBASSPlayer.ShowPluginConfigForm;
begin
   if not FBASSReady then
   begin
      Application.MessageBox('Player is not ready !', 'Confirm', MB_OK);
      exit;
   end;

   if FPluginFirst then
      PluginConfigForm.PluginFirst.Checked := true
   else
      PluginConfigForm.PluginFirst.Checked := false;

   PluginConfigForm.ShowModal;
end;

procedure TBASSPlayer.HideVisWindow;
begin
   if not GoVisOut then
      exit;

   VisThread.fisSharedMemory1.InformDataReady(MinimizeWindow, 0{Data Size});
end;

procedure TBASSPlayer.ShowVisWindow;
begin
   if not GoVisOut then
      exit;

   VisThread.fisSharedMemory1.InformDataReady(RestoreWindow, 0{Data Size});
end;

function TBASSPlayer.GetMessageHandle : HWND;
begin
   result := MessageHandle;
end;

// Inform current player status to visualizer
procedure TBASSPlayer.InformPlayerStatus(StatusIndex : DWORD);   // * Added at Ver 1.5
var
   p1 : PDWORD;
   p2 : PBYTE;
   ModeId : DWORD;
   TitleBuf : array[0..255] of char;

// The shared memory obtained by fisSharedMemory1 is used as follows
//   offset   0 -    3 : Player Mode
//            4 -  275 : Stream Information
//          276 -  279 : SyncWindows flag
//          280 -  283 : Flag to notify that new FFT data is given
//          284 -  287 : Sample rate
//          288 -  291 : number of channels
//          292 -  295 : playback position;
//          296 - 2599 : FFT Data

begin
   if not GoVisOut then
      exit;

   TimerFFT.Enabled := false;

   p1 := VisThread.ShareMemPointer;

   case StatusIndex of
      stPlayerMode : begin
           ModeId := ord(FPlayerMode);
           p1^ := ModeId;
           VisThread.fisSharedMemory1.InformDataReady(InformPlayerMode, 4);
         end;
      stStreamInfo : begin
           inc(p1, 4);
           p1^ := FStreamInfo.SampleRate;
           inc(p1, 1);
           p1^ := FStreamInfo.BitRate;
           inc(p1, 1);
           p1^ := FStreamInfo.Channels;
           inc(p1, 1);
           p1^ := FStreamInfo.Duration;
           inc(p1, 1);
           FillChar(TitleBuf, 256, 0);
           StrPCopy(TitleBuf, FStreamInfo.Title);
           p2 := pointer(p1);
           move(TitleBuf, p2^, 256);
           VisThread.fisSharedMemory1.InformDataReady(InformStreamInfo, 272);
         end;
      stSyncWindows : begin
           inc(p1, 276);
           if FSyncVisWindow then
              p1^ := 1
           else
              p1^ := 0;
           VisThread.fisSharedMemory1.InformDataReady(InformSyncWindows, 4);
         end;
   end;

   TimerFFT.Enabled := true;
end;


procedure Register;
begin
   RegisterComponents('Samples', [TBASSPlayer]);
end;

end.
