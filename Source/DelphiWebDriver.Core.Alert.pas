{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Core.Alert;

interface

uses
  System.JSON,
  DelphiWebDriver.Interfaces;

type
  TWebDriverAlert = class(TInterfacedObject, IWebDriverAlert)
  private
    [weak]
    FDriver: IWebDriver;
  public
    constructor Create(ADriver: IWebDriver);
    procedure Accept;
    procedure Dismiss;
    function GetText: string;
    procedure SendKeys(const Text: string);
  end;

implementation

{ TWebDriverAlert }

procedure TWebDriverAlert.Accept;
var
  JSON: TJSONValue;
begin
  JSON := FDriver.Commands.SendCommand('POST',
    '/session/' + FDriver.Sessions.GetSessionId + '/alert/accept');
  try
  finally
    JSON.Free;
  end;
end;

constructor TWebDriverAlert.Create(ADriver: IWebDriver);
begin
  inherited Create;
  FDriver := ADriver;
end;

procedure TWebDriverAlert.Dismiss;
var
  JSON: TJSONValue;
begin
  JSON := FDriver.Commands.SendCommand('POST',
    '/session/' + FDriver.Sessions.GetSessionId + '/alert/dismiss');
  try
  finally
    JSON.Free;
  end;
end;

function TWebDriverAlert.GetText: string;
var
  JSON: TJSONValue;
begin
  JSON := FDriver.Commands.SendCommand(
    'GET',
    '/session/' + FDriver.Sessions.GetSessionId + '/alert/text'
  );
  try
    Result := JSON.GetValue<string>('value');
  finally
    JSON.Free;
  end;
end;

procedure TWebDriverAlert.SendKeys(const Text: string);
var
  Body: TJSONObject;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('text', Text);
    FDriver.Commands.SendCommand(
      'POST',
      '/session/' + FDriver.Sessions.GetSessionId + '/alert/text',
      Body
    ).Free;
  finally
    Body.Free;
  end;
end;

end.
