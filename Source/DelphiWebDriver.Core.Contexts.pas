{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Core.Contexts;

interface

uses
  System.SysUtils,
  System.JSON,
  System.Generics.Collections,
  DelphiWebDriver.Interfaces,
  DelphiWebDriver.Types;

type
  TWebDriverContexts = class(TInterfacedObject, IWebDriverContexts)
  private
    [weak]
    FDriver: IWebDriver;
  public
    constructor Create(ADriver: IWebDriver);
    procedure SwitchToFrameElement(const Element: IWebElement);
    procedure SwitchToFrame(const FrameName: string);
    procedure SwitchToDefaultContent;
    function GetWindowHandle: string;
    function GetWindowHandles: TArray<string>;
    procedure SwitchToWindow(const Handle: string);
    procedure SwitchToMainWindow;
    procedure SwitchToWindowIndex(Index: Integer);
    function GetCurrentWindowIndex: Integer;
    procedure CloseWindow;
    function NewWindow(const WindowType: string = 'tab'): string;
    procedure MaximizeWindow;
    procedure MinimizeWindow;
    procedure FullscreenWindow;
    procedure SetWindowSize(const Width, Height: Integer);
  end;

implementation

{ TWebDriverContexts }

procedure TWebDriverContexts.CloseWindow;
begin
  FDriver.Commands.SendCommand('DELETE', '/session/' + FDriver.Sessions.GetSessionId + '/window').Free;
end;

constructor TWebDriverContexts.Create(ADriver: IWebDriver);
begin
  inherited Create;
  FDriver := ADriver;
end;

procedure TWebDriverContexts.SetWindowSize(const Width, Height: Integer);
var
  Body: TJSONObject;
  R: TJSONValue;
begin
  Body := TJSONObject.Create;
  R := nil;
  try
    Body.AddPair('width', TJSONNumber.Create(Width));
    Body.AddPair('height', TJSONNumber.Create(Height));
    R := FDriver.Commands.SendCommand(
      'POST',
      '/session/' + FDriver.Sessions.GetSessionId + '/window/rect',
      Body
    );
  finally
    Body.Free;
    R.Free;
  end;
end;

procedure TWebDriverContexts.FullscreenWindow;
var
  Body: TJSONObject;
  R: TJSONValue;
begin
  Body := TJSONObject.Create;
  R := nil;
  try
    R := FDriver.Commands.SendCommand('POST', '/session/' + FDriver.Sessions.GetSessionId + '/window/fullscreen', Body);
  finally
    Body.Free;
    R.Free;
  end;
end;

function TWebDriverContexts.GetCurrentWindowIndex: Integer;
var
  Handles: TArray<string>;
  Current: string;
  I: Integer;
begin
  Handles := GetWindowHandles;
  Current := GetWindowHandle;
  for I := 0 to High(Handles) do
    if Handles[I] = Current then
      Exit(I);
  Result := -1;
end;

function TWebDriverContexts.GetWindowHandle: string;
var
  JSON: TJSONValue;
begin
  JSON := FDriver.Commands.SendCommand('GET', '/session/' + FDriver.Sessions.GetSessionId + '/window');
  try
    Result := JSON.GetValue<string>('value');
  finally
    JSON.Free;
  end;
end;

function TWebDriverContexts.GetWindowHandles: TArray<string>;
var
  JSON: TJSONValue;
  Arr: TJSONArray;
  I: Integer;
begin
  JSON := FDriver.Commands.SendCommand('GET', '/session/' + FDriver.Sessions.GetSessionId + '/window/handles');
  try
    Arr := JSON.GetValue<TJSONArray>('value');

    SetLength(Result, Arr.Count);
    for I := 0 to Arr.Count - 1 do
      Result[I] := Arr.Items[I].Value;
  finally
    JSON.Free;
  end;
end;

procedure TWebDriverContexts.MaximizeWindow;
var
  Body: TJSONObject;
  R: TJSONValue;
begin
  Body := TJSONObject.Create;
  R := nil;
  try
    R := FDriver.Commands.SendCommand('POST', '/session/' + FDriver.Sessions.GetSessionId + '/window/maximize', Body);
  finally
    Body.Free;
    R.Free;
  end;
end;

procedure TWebDriverContexts.MinimizeWindow;
var
  Body: TJSONObject;
  R: TJSONValue;
begin
  Body := TJSONObject.Create;
  R := nil;
  try
    R := FDriver.Commands.SendCommand('POST', '/session/' + FDriver.Sessions.GetSessionId + '/window/minimize', Body);
  finally
    Body.Free;
    R.Free;
  end;
end;

function TWebDriverContexts.NewWindow(const WindowType: string): string;
var
  JSON: TJSONValue;
  Body: TJSONObject;
  ValueObj: TJSONObject;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('type', WindowType);

    JSON := FDriver.Commands.SendCommand('POST', '/session/' + FDriver.Sessions.GetSessionId + '/window/new', Body);
    try
      ValueObj := JSON.GetValue<TJSONObject>('value');
      if not Assigned(ValueObj) then
        raise EWebDriverError.Create('NewWindow: no value returned');
      Result := ValueObj.GetValue<string>('handle');
    finally
      JSON.Free;
    end;
  finally
    Body.Free;
  end;
end;

procedure TWebDriverContexts.SwitchToDefaultContent;
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('id', TJSONNull.Create);
    FDriver.Commands.SendCommand('POST', '/session/' + FDriver.Sessions.GetSessionId + '/frame', JSON);
  finally
    JSON.Free;
  end;
end;

procedure TWebDriverContexts.SwitchToFrame(const FrameName: string);
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('id', TJSONString.Create(FrameName));
    FDriver.Commands.SendCommand('POST', '/session/' + FDriver.Sessions.GetSessionId + '/frame', JSON);
  finally
    JSON.Free;
  end;
end;

procedure TWebDriverContexts.SwitchToFrameElement(const Element: IWebElement);
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('id', TJSONObject.Create.AddPair('ELEMENT', Element.ElementId)
      .AddPair('element-6066-11e4-a52e-4f735466cecf', Element.ElementId));
    FDriver.Commands.SendCommand('POST', '/session/' + FDriver.Sessions.GetSessionId + '/frame', JSON);
  finally
    JSON.Free;
  end;
end;

procedure TWebDriverContexts.SwitchToMainWindow;
begin
  if FDriver.Sessions.GetWindowHandle = '' then
    raise Exception.Create('Main window handle not stored.');
  SwitchToWindow(FDriver.Sessions.GetWindowHandle);
end;

procedure TWebDriverContexts.SwitchToWindow(const Handle: string);
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('handle', Handle);
    FDriver.Commands.SendCommand('POST', '/session/' + FDriver.Sessions.GetSessionId + '/window', JSON).Free;
  finally
    JSON.Free;
  end;
end;

procedure TWebDriverContexts.SwitchToWindowIndex(Index: Integer);
var
  Handles: TArray<string>;
  Body: TJSONObject;
  JSON: TJSONValue;
begin
  Handles := GetWindowHandles;
  if (Index < 0) or (Index >= Length(Handles)) then
    raise Exception.CreateFmt('Invalid window index %d', [Index]);
  Body := TJSONObject.Create;
  try
    Body.AddPair('handle', Handles[Index]);
    JSON := FDriver.Commands.SendCommand(
      'POST',
      '/session/' + FDriver.Sessions.GetSessionId + '/window',
      Body
    );
    JSON.Free;
  finally
    Body.Free;
  end;
end;

end.
