{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Core.Capabilities;

interface

uses
  System.SysUtils,
  System.JSON,
  System.Generics.Collections,
  DelphiWebDriver.Interfaces,
  DelphiWebDriver.Types;

type
  TWebDriverCapabilities = class(TInterfacedObject, IWebDriverCapabilities)
  private
    [weak]
    FDriver: IWebDriver;
    FHeadless: Boolean;
    FArgs: TList<string>;
    function GetHeadless: Boolean;
    procedure SetHeadless(const Value: Boolean);
    function GetArgs: TList<string>;
  public
    constructor Create(ADriver: IWebDriver);
    destructor Destroy; override;
    property Headless: Boolean read FHeadless write FHeadless;
    property Arguments: TList<string> read FArgs;
    function ToJSON: TJSONObject;
  end;

implementation

{ TWebDriverCapabilities }

constructor TWebDriverCapabilities.Create(ADriver: IWebDriver);
begin
  inherited Create;
  FDriver := ADriver;
  FHeadless := False;
  FArgs := TList<string>.Create;
end;

destructor TWebDriverCapabilities.Destroy;
begin
  FArgs.Free;
  inherited;
end;

function TWebDriverCapabilities.GetArgs: TList<string>;
begin
  Result := FArgs;
end;

function TWebDriverCapabilities.GetHeadless: Boolean;
begin
  Result := FHeadless;
end;

procedure TWebDriverCapabilities.SetHeadless(const Value: Boolean);
begin
  FHeadless := Value;
end;

function TWebDriverCapabilities.ToJSON: TJSONObject;
var
  FirstMatchArray: TJSONArray;
  AlwaysObj, OptionsObj: TJSONObject;
  ArgsArray: TJSONArray;
  Arg: string;
begin
  if FDriver.Browser = wdbUnknown then
    raise Exception.Create('Browser cannot be Unknown');

  FirstMatchArray := TJSONArray.Create;
  FirstMatchArray.Add(TJSONObject.Create);
  AlwaysObj := TJSONObject.Create;
  AlwaysObj.AddPair('browserName', FDriver.Browser.Name);
  ArgsArray := TJSONArray.Create;

  if FHeadless then
  begin
    if FDriver.Browser = wdbChrome then
      ArgsArray.Add('--headless')
    else if FDriver.Browser = wdbFirefox then
      ArgsArray.Add('-headless')
    else if FDriver.Browser = wdbEdge then
      ArgsArray.Add('--headless=new');
  end;

  for Arg in FArgs do
    ArgsArray.Add(Arg);

  if ArgsArray.Count > 0 then
    begin
      OptionsObj := TJSONObject.Create;
      OptionsObj.AddPair('args', ArgsArray);
      if FDriver.Browser = wdbChrome then
        AlwaysObj.AddPair('goog:chromeOptions', OptionsObj)
      else if FDriver.Browser = wdbFirefox then
        AlwaysObj.AddPair('moz:firefoxOptions', OptionsObj)
      else if FDriver.Browser = wdbEdge then
        AlwaysObj.AddPair('ms:edgeOptions', OptionsObj);
    end
  else
    ArgsArray.Free;

  Result := TJSONObject.Create;
  Result.AddPair('capabilities',
    TJSONObject.Create
      .AddPair('firstMatch', FirstMatchArray)
      .AddPair('alwaysMatch', AlwaysObj)
  );
end;

end.

