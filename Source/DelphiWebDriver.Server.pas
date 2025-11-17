{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Server;

interface

uses
  System.SysUtils,
  Winapi.Windows,
  TlHelp32;

type
  TWebDriverServer = class
  private
    FProcessInfo: TProcessInformation;
    FStarted: Boolean;
    FExePath: string;
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
end;

destructor TWebDriverServer.Destroy;
begin
  Stop;
  inherited;
end;

procedure TWebDriverServer.Start;
var
  StartupInfo: TStartupInfo;
  CmdLine: string;
begin
  if FStarted then Exit;
  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  StartupInfo.cb := SizeOf(StartupInfo);
  ZeroMemory(@FProcessInfo, SizeOf(FProcessInfo));
  CmdLine := '"' + FExePath + '" --port=9515';
  if CreateProcess(nil, PChar(CmdLine), nil, nil, False,
    CREATE_NO_WINDOW, nil, nil, StartupInfo, FProcessInfo) then
  begin
    FStarted := True;
    Sleep(800);
  end
  else
    raise Exception.Create('Failed to start driver. Error: ' + SysErrorMessage(GetLastError));
end;

procedure TWebDriverServer.Stop;
begin
  if not FStarted then Exit;

  if WaitForSingleObject(FProcessInfo.hProcess, 3000) = WAIT_TIMEOUT then
  begin
    TerminateProcess(FProcessInfo.hProcess, 0);
    WaitForSingleObject(FProcessInfo.hProcess, 1000);
  end;

  if FProcessInfo.hProcess <> 0 then
  begin
    CloseHandle(FProcessInfo.hProcess);
    FProcessInfo.hProcess := 0;
  end;

  if FProcessInfo.hThread <> 0 then
  begin
    CloseHandle(FProcessInfo.hThread);
    FProcessInfo.hThread := 0;
  end;

  FStarted := False;

  var ProcName := ExtractFileName(FExePath);
  var Snap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Snap <> INVALID_HANDLE_VALUE then
  try
    var PE: TProcessEntry32;
    PE.dwSize := SizeOf(PE);
    if Process32First(Snap, PE) then
    repeat
      if SameText(PE.szExeFile, ProcName) then
      begin
        var HProc := OpenProcess(PROCESS_TERMINATE, False, PE.th32ProcessID);
        if HProc <> 0 then
        begin
          TerminateProcess(HProc, 0);
          CloseHandle(HProc);
        end;
      end;
    until not Process32Next(Snap, PE);
  finally
    CloseHandle(Snap);
  end;
end;

end.

