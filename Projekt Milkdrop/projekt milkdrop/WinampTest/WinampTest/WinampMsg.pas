unit WinampMsg;

interface
 uses Messages;

const
  WM_WA_IPC = WM_USER;

  WINAMP_BUTTON1      = 40044;    // Previous Track
  WINAMP_BUTTON2      = 40045;    // Play
  WINAMP_BUTTON3      = 40046;    // Pause/Unpause button
  WINAMP_BUTTON4      = 40047;    // Stop button
  WINAMP_BUTTON5      = 40048;    // Next Track

  //IPC Messagen
  IPC_GETLISTPOS      = 125;
  IPC_ISPLAYING       = 104;
  IPC_SETPLAYLISTPOS  = 121;
  IPC_GETPLAYLISTFILE = 211;


implementation

end.
