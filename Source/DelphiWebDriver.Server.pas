{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Server;

interface

uses
  System.SysUtils
{$IFDEF POSIX}
  , Posix.Unistd
  , Posix.SysTypes
  , Posix.SysWait
  , Posix.Signal
{$ENDIF}
{$IFDEF MSWINDOWS}
  , Winapi.Windows
{$ENDIF}
  ;

type
  TWebDriverServer = class
  private
    FExePath: string;
    FStarted: Boolean;
    {$IFDEF MSWINDOWS}
    FProcessInfo: TProcessInformation;
    {$ENDIF}
    {$IFDEF POSIX}
    FPID: pid_t;
    {$ENDIF}
  public
    constructor Create(const AExePath: string);
    destructor Destroy; override;
    procedure Start(Port: Integer = 9515);
    procedure Stop;
    property Started: Boolean read FStarted;
  end;

implementation

{ TWebDriverServer }

constructor TWebDriverServer.Create(const AExePath: string);
begin
  inherited Create;
  FExePath := AExePath;
  FStarted := False;
  {$IFDEF POSIX}
  FPID := 0;
  {$ENDIF}
end;

destructor TWebDriverServer.Destroy;
begin
  Stop;
  inherited;
end;

procedure TWebDriverServer.Start(Port: Integer = 9515);
{$IFDEF POSIX}
var
  PID: pid_t;
  ArgV: array[0..2] of PAnsiChar;
{$ENDIF}
var
  Cmd: string;
begin
  if FStarted then
    Exit;

  if not FileExists(FExePath) then
    raise Exception.Create('WebDriver executable not found: ' + FExePath);

  Cmd := FExePath + ' --port=' + Port.ToString;

  {$IFDEF MSWINDOWS}
  var SI: TStartupInfo;
  ZeroMemory(@SI, SizeOf(SI));
  ZeroMemory(@FProcessInfo, SizeOf(FProcessInfo));
  SI.cb := SizeOf(SI);

  if not CreateProcess(nil, PChar(Cmd), nil, nil, False, CREATE_NO_WINDOW,
                      nil, nil, SI, FProcessInfo) then
    raise Exception.Create('Cannot start driver: ' + SysErrorMessage(GetLastError));
  {$ENDIF}

  {$IFDEF POSIX}
  ArgV[0] := PAnsiChar(AnsiString(FExePath));
  ArgV[1] := PAnsiChar(AnsiString('--port=' + Port.ToString));
  ArgV[2] := nil;

  PID := fork;
  if PID = -1 then
    raise Exception.Create('fork() failed');

  if PID = 0 then
  begin
    execvp(ArgV[0], @ArgV[0]);
    _exit(127);
  end;

  FPID := PID;
  {$ENDIF}

  FStarted := True;
  Sleep(700);
end;

procedure TWebDriverServer.Stop;
begin
  if not FStarted then
    Exit;

  {$IFDEF MSWINDOWS}
  if FProcessInfo.hProcess <> 0 then
  begin
    if WaitForSingleObject(FProcessInfo.hProcess, 1500) = WAIT_TIMEOUT then
      TerminateProcess(FProcessInfo.hProcess, 0);

    WaitForSingleObject(FProcessInfo.hProcess, 500);
    CloseHandle(FProcessInfo.hProcess);
    CloseHandle(FProcessInfo.hThread);

    FProcessInfo.hProcess := 0;
    FProcessInfo.hThread := 0;
  end;
  {$ENDIF}

  {$IFDEF POSIX}
  if FPID > 0 then
  begin
    kill(FPID, SIGTERM);
    Sleep(300);

    if kill(FPID, 0) = 0 then
      kill(FPID, SIGKILL);

    waitpid(FPID, nil, 0);

    FPID := 0;
  end;
  {$ENDIF}

  FStarted := False;
end;

end.

