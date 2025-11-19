unit DelphiWebDriver.Server;

interface

uses
  System.SysUtils
{$IFDEF POSIX}
  , Posix.Unistd
  , Posix.SysTypes
  , Posix.SysWait
  , Posix.Spawn
  , Posix.Signal
{$ENDIF}
{$IFDEF MSWINDOWS}
  , Winapi.Windows;
{$ENDIF}

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
    procedure Start;
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

procedure TWebDriverServer.Start;
var
  Cmd: string;
{$IFDEF POSIX}
  Args: array[0..2] of PAnsiChar;
  Status: Integer;
{$ENDIF}
begin
  if FStarted then
    Exit;
  if not FileExists(FExePath) then
    raise Exception.Create('WebDriver executable not found: ' + FExePath);
  Cmd := FExePath + ' --port=9515';
  {$IFDEF MSWINDOWS}
  var Startup: TStartupInfo;
  ZeroMemory(@Startup, SizeOf(Startup));
  ZeroMemory(@FProcessInfo, SizeOf(FProcessInfo));
  Startup.cb := SizeOf(Startup);
  if not CreateProcess(nil, PChar(Cmd), nil, nil, False, CREATE_NO_WINDOW, nil, nil,
                      Startup, FProcessInfo) then
    raise Exception.Create('Cannot start driver: ' + SysErrorMessage(GetLastError));
  {$ENDIF}
  {$IFDEF POSIX}
  Args[0] := PAnsiChar(AnsiString(FExePath));
  Args[1] := PAnsiChar(AnsiString('--port=9515'));
  Args[2] := nil;
  Status := posix_spawn(@FPID, PAnsiChar(AnsiString(FExePath)), nil, nil, @Args[0], environ);
  if Status <> 0 then
    raise Exception.Create('Failed to start WebDriver process (posix_spawn), errno=' + Status.ToString);
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
    fpKill(FPID, SIGTERM);
    Sleep(300);
    if fpKill(FPID, 0) = 0 then
      fpKill(FPID, SIGKILL);
    FPID := 0;
  end;
  {$ENDIF}
  FStarted := False;
end;

end.

