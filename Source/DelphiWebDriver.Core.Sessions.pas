{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Core.Sessions;

interface

uses
  System.JSON,
  DelphiWebDriver.Interfaces,
  DelphiWebDriver.Types,
  System.SysUtils;

type
  TWebDriverSessions = class(TInterfacedObject, IWebDriverSessions)
  private
    [weak]
    FDriver: IWebDriver;
    FSessionId: string;
    FWindowHandle: string;
  public
    constructor Create(ADriver: IWebDriver);
    function StartSession: string;
    procedure Quit;
    function GetSessionId: string;
    function GetWindowHandle: string;
  end;

implementation

{ TWebDriverSessions }

constructor TWebDriverSessions.Create(ADriver: IWebDriver);
begin
  inherited Create;
  FDriver := ADriver;
end;

function TWebDriverSessions.GetWindowHandle: string;
begin
  Result := FWindowHandle;
end;

function TWebDriverSessions.GetSessionId: string;
begin
  Result := FSessionId;
end;

procedure TWebDriverSessions.Quit;
begin
  if FSessionId <> '' then
    FDriver.Commands.SendCommand('DELETE', '/session/' + FSessionId).Free;
end;

function TWebDriverSessions.StartSession: string;
label
  ParseResponse;
var
  CapObj, TopObj, AlwaysMatch: TJSONObject;
  LRes, LValue: TJSONValue;
  LSessionObj: TJSONObject;
begin
  CapObj := FDriver.Capabilities.ToJSON;
  try
    if FDriver.BrowserConfig.Browser = wdbOpera then
    begin
      TopObj := TJSONObject.Create;
      try
        TopObj.AddPair('desiredCapabilities', CapObj.Clone as TJSONObject);
        LRes := FDriver.Commands.SendCommand('POST', '/session', TopObj);
      finally
        TopObj.Free;
      end;
      goto ParseResponse;
    end;

    TopObj := TJSONObject.Create;
    try
      AlwaysMatch := TJSONObject.Create;
      AlwaysMatch.AddPair('alwaysMatch', CapObj.Clone as TJSONObject);
      TopObj.AddPair('capabilities', AlwaysMatch);
      LRes := FDriver.Commands.SendCommand('POST', '/session', TopObj);
    finally
      TopObj.Free;
    end;

    ParseResponse:
    try
      LValue := LRes.GetValue<TJSONValue>('value');
      if Assigned(LValue) and (LValue is TJSONObject) then
      begin
        LSessionObj := TJSONObject(LValue);
        LSessionObj.TryGetValue<string>('sessionId', FSessionId);
      end;

      if FSessionId = '' then
        LRes.TryGetValue<string>('sessionId', FSessionId);

      if FSessionId = '' then
        raise EWebDriverError.Create('SessionId not found: ' + LRes.ToString);

      FWindowHandle := FDriver.Contexts.GetWindowHandle;

      Result := FSessionId;
    finally
      LRes.Free;
    end;
  finally
    CapObj.Free;
  end;
end;

end.

