unit DelphiWebDriver.Core;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Net.HttpClient,
  System.JSON,
  System.Generics.Collections,
  System.DateUtils,
  System.NetEncoding,
  DelphiWebDriver.Interfaces,
  DelphiWebDriver.Types,
  DelphiWebDriver.Capabilities,
  DelphiWebDriver.Element,
  DelphiWebDriver.Cookies;

type
  EWebDriverError = class(Exception);

  TWebDriver = class(TInterfacedObject, IWebDriver)
  private
    FHTTP: THTTPClient;
    FSessionId: string;
    FBaseUrl: string;
    FCookies: IWebDriverCookies;
  public
    constructor Create(const ABaseUrl: string); virtual;
    destructor Destroy; override;
    function StartSession(Capabilities: TWebDriverCapabilities): string;
    procedure Quit;
    function FindElement(By: TBy): IWebElement;
    function FindElements(By: TBy): TArray<IWebElement>;
    function SendCommand(const Method, Endpoint: string; Body: TJSONObject = nil): TJSONValue;
    function GetSessionId: string;
    procedure Navigate(const Url: string);
    function GetTitle: string;
    function GetCurrentUrl: string;
    procedure Back;
    procedure Forward;
    procedure Refresh;
    procedure SwitchToFrameElement(const Element: IWebElement);
    procedure SwitchToFrame(const FrameName: string);
    procedure SwitchToDefaultContent;
    function Cookies: IWebDriverCookies;
    function TakeScreenshot: TBytes;
    procedure SaveScreenshotToFile(const FileName: string);
    function WaitUntilElement(By: TBy; TimeoutMS: Integer = 5000; IntervalMS: Integer = 200): IWebElement;
    function ExecuteScript(const Script: string; const Args: array of string): TJSONValue; overload;
    procedure ExecuteScript(const Script: string); overload;
    procedure WaitUntilPageLoad(TimeoutMS: Integer = 10000);
  end;

implementation

{ TWebDriver }

constructor TWebDriver.Create(const ABaseUrl: string);
begin
  inherited Create;
  FBaseUrl := ABaseUrl;
  FHTTP := THTTPClient.Create;
end;

destructor TWebDriver.Destroy;
begin
  FHTTP.Free;
  inherited;
end;

procedure TWebDriver.ExecuteScript(const Script: string);
var
  Resp: TJSONValue;
begin
  Resp := ExecuteScript(Script, []);
  try
    // ignore result
  finally
    Resp.Free;
  end;
end;

function TWebDriver.WaitUntilElement(By: TBy; TimeoutMS, IntervalMS: Integer) : IWebElement;
var
  ElemTemp: IWebElement;
  StartTime: TDateTime;
begin
  ElemTemp := nil;
  StartTime := Now;
  while MilliSecondsBetween(Now, StartTime) < TimeoutMS do
  begin
    try
      ElemTemp := FindElement(By);
      if Assigned(ElemTemp) then
      begin
        Result := ElemTemp;
        Exit;
      end;
    except
      ElemTemp := nil;
    end;
    Sleep(IntervalMS);
  end;
  Result := nil;
end;

function TWebDriver.ExecuteScript(const Script: string; const Args: array of string): TJSONValue;
var
  Body : TJSONObject;
  Arr: TJSONArray;
  S: string;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('script', Script);
    Arr := TJSONArray.Create;
    Body.AddPair('args', Arr);

    for S in Args do
      Arr.Add(S);

    Result := SendCommand('POST',
      '/session/' + FSessionId + '/execute/sync',
      Body
    );
  finally
    Body.Free;
  end;
end;

procedure TWebDriver.WaitUntilPageLoad(TimeoutMS: Integer);
var
  StartTime: TDateTime;
  Resp: TJSONValue;
  ReadyState: string;
begin
  StartTime := Now;
  while MilliSecondsBetween(Now, StartTime) < TimeoutMS do
  begin
    try
      Resp := ExecuteScript('return document.readyState;', []);
      try
        ReadyState := Resp.GetValue<string>('value');
      finally
        Resp.Free;
      end;

      if ReadyState = 'complete' then
        Exit;
    except
    end;
    Sleep(100);
  end;
  raise EWebDriverError.Create('Timeout waiting for page to finish loading.');
end;

procedure TWebDriver.SwitchToFrame(const FrameName: string);
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('id', TJSONString.Create(FrameName));
    SendCommand('POST', '/session/' + FSessionId + '/frame', JSON);
  finally
    JSON.Free;
  end;
end;

procedure TWebDriver.SwitchToDefaultContent;
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('id', TJSONNull.Create);
    SendCommand('POST', '/session/' + FSessionId + '/frame', JSON);
  finally
    JSON.Free;
  end;
end;

procedure TWebDriver.SwitchToFrameElement(const Element: IWebElement);
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('id', TJSONObject.Create.AddPair('ELEMENT', Element.ElementId)
      .AddPair('element-6066-11e4-a52e-4f735466cecf', Element.ElementId));
    SendCommand('POST', '/session/' + FSessionId + '/frame', JSON);
  finally
    JSON.Free;
  end;
end;

function TWebDriver.SendCommand(const Method, Endpoint: string; Body: TJSONObject): TJSONValue;
var
  LUrl: string;
  LResponse: IHTTPResponse;
  Stream: TStringStream;
begin
  LUrl := FBaseUrl + Endpoint;
  Stream := nil;
  try
    if Assigned(Body) then
      Stream := TStringStream.Create(Body.ToJSON, TEncoding.UTF8);

    if Method = 'POST' then
      LResponse := FHTTP.Post(LUrl, Stream)
    else if Method = 'DELETE' then
      LResponse := FHTTP.Delete(LUrl)
    else
      LResponse := FHTTP.Get(LUrl);

    Result := TJSONObject.ParseJSONValue(LResponse.ContentAsString);
    if not Assigned(Result) then
      raise EWebDriverError.Create
        ('Invalid JSON response received from WebDriver');
  finally
    Stream.Free;
  end;
end;

function TWebDriver.StartSession(Capabilities: TWebDriverCapabilities): string;
var
  LCapObj: TJSONObject;
  LRes: TJSONValue;
  LSessionObj: TJSONObject;
begin
  LCapObj := nil;
  try
    LCapObj := Capabilities.ToJSON;
    LRes := SendCommand('POST', '/session', LCapObj);
    try
      LSessionObj := LRes.GetValue<TJSONObject>('value');
      if not Assigned(LSessionObj) then
        raise EWebDriverError.Create('No value object returned from WebDriver');

      if LSessionObj.TryGetValue<string>('sessionId', FSessionId) then
        Result := FSessionId
      else
        raise EWebDriverError.Create('SessionId not found in response: ' +
          LRes.ToString);
    finally
      LRes.Free;
    end;
  finally
    LCapObj.Free;
  end;
end;

procedure TWebDriver.Quit;
begin
  if FSessionId <> '' then
    SendCommand('DELETE', '/session/' + FSessionId).Free;
end;

function TWebDriver.GetSessionId: string;
begin
  Result := FSessionId;
end;

function TWebDriver.FindElement(By: TBy): IWebElement;
var
  Body: TJSONObject;
  LRes: TJSONValue;
  ElemObj: TJSONObject;
  ElemId: string;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('using', By.Strategy);
    Body.AddPair('value', By.Value);

    LRes := SendCommand('POST', '/session/' + FSessionId + '/element', Body);
    try
      ElemObj := LRes.GetValue<TJSONObject>('value');
      if not Assigned(ElemObj) then
        raise EWebDriverError.Create('No element object returned');

      if not ElemObj.TryGetValue<string>('element-6066-11e4-a52e-4f735466cecf',
        ElemId) then
      begin
        ElemId := ElemObj.GetValue<string>('ELEMENT');
      end;

      Result := TWebElement.Create(Self as IWebDriver, ElemId);
    finally
      LRes.Free;
    end;
  finally
    Body.Free;
  end;
end;

function TWebDriver.FindElements(By: TBy): TArray<IWebElement>;
var
  Body: TJSONObject;
  LRes: TJSONValue;
  Arr: TJSONArray;
  Item: TJSONValue;
  ElemObj: TJSONObject;
  ElemId: string;
  List: TList<IWebElement>;
begin
  Body := TJSONObject.Create;
  List := TList<IWebElement>.Create;
  try
    Body.AddPair('using', By.Strategy);
    Body.AddPair('value', By.Value);

    LRes := SendCommand('POST', '/session/' + FSessionId + '/elements', Body);
    try
      Arr := LRes.GetValue<TJSONArray>('value');
      for Item in Arr do
      begin
        ElemObj := Item as TJSONObject;
        if not ElemObj.TryGetValue<string>
          ('element-6066-11e4-a52e-4f735466cecf', ElemId) then
          ElemId := ElemObj.GetValue<string>('ELEMENT');
        List.Add(TWebElement.Create(Self as IWebDriver, ElemId));
      end;
      Result := List.ToArray;
    finally
      LRes.Free;
    end;
  finally
    Body.Free;
    List.Free;
  end;
end;

procedure TWebDriver.Navigate(const Url: string);
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('url', Url);
    SendCommand('POST', '/session/' + FSessionId + '/url', JSON).Free;
  finally
    JSON.Free;
  end;
end;

function TWebDriver.GetTitle: string;
var
  JSON: TJSONValue;
begin
  JSON := SendCommand('GET', '/session/' + FSessionId + '/title');
  try
    Result := JSON.GetValue<string>('value');
  finally
    JSON.Free;
  end;
end;

function TWebDriver.GetCurrentUrl: string;
var
  JSON: TJSONValue;
begin
  JSON := SendCommand('GET', '/session/' + FSessionId + '/url');
  try
    Result := JSON.GetValue<string>('value');
  finally
    JSON.Free;
  end;
end;

procedure TWebDriver.Back;
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    SendCommand('POST', '/session/' + FSessionId + '/back',
      JSON).Free;
  finally
    JSON.Free;
  end;
end;

procedure TWebDriver.Forward;
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    SendCommand('POST', '/session/' + FSessionId + '/forward',
      JSON).Free;
  finally
    JSON.Free;
  end;
end;

procedure TWebDriver.Refresh;
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    SendCommand('POST', '/session/' + FSessionId + '/refresh',
      JSON).Free;
  finally
    JSON.Free;
  end;
end;

function TWebDriver.Cookies: IWebDriverCookies;
begin
  if FCookies = nil then
    FCookies := TWebDriverCookies.Create(Self as IWebDriver);
  Result := FCookies;
end;

function TWebDriver.TakeScreenshot: TBytes;
var
  JSON: TJSONValue;
  Base64Str: string;
begin
  JSON := SendCommand('GET', '/session/' + FSessionId + '/screenshot');
  try
    Base64Str := JSON.GetValue<string>('value');
    Result := TNetEncoding.Base64.DecodeStringToBytes(Base64Str);
  finally
    JSON.Free;
  end;
end;

procedure TWebDriver.SaveScreenshotToFile(const FileName: string);
var
  Bytes: TBytes;
  FS: TFileStream;
begin
  Bytes := TakeScreenshot;
  FS := TFileStream.Create(FileName, fmCreate);
  try
    FS.WriteBuffer(Bytes[0], Length(Bytes));
  finally
    FS.Free;
  end;
end;

end.
