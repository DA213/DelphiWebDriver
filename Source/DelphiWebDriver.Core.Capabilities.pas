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
    property Headless: Boolean read GetHeadless write SetHeadless;
    property Arguments: TList<string> read GetArgs;
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
  CapObj, OptionsObj, OperaOpts: TJSONObject;
  ArgsArray: TJSONArray;
  Arg: string;
begin
  ArgsArray := TJSONArray.Create;

  if FHeadless then
  begin
    case FDriver.BrowserConfig.Browser of
      wdbChrome,
      wdbEdge,
      wdbOpera:
        ArgsArray.Add('--headless=new');
      wdbFirefox:
        ArgsArray.Add('-headless');
    end;
  end;

  for Arg in FArgs do
    ArgsArray.Add(Arg);

  OptionsObj := TJSONObject.Create;
  OptionsObj.AddPair('args', ArgsArray);

  if FDriver.BrowserConfig.BinaryPath <> '' then
    OptionsObj.AddPair('binary', FDriver.BrowserConfig.BinaryPath);

  CapObj := TJSONObject.Create;
  CapObj.AddPair('browserName', FDriver.BrowserConfig.Browser.Name);

  case FDriver.BrowserConfig.Browser of
    wdbChrome:
      CapObj.AddPair('goog:chromeOptions', OptionsObj);

    wdbEdge:
      CapObj.AddPair('ms:edgeOptions', OptionsObj);

    wdbFirefox:
      CapObj.AddPair('moz:firefoxOptions', OptionsObj);

    wdbOpera:
    begin
      CapObj.AddPair('goog:chromeOptions', OptionsObj);
      if FDriver.BrowserConfig.BinaryPath <> '' then
      begin
        OperaOpts := TJSONObject.Create;
        OperaOpts.AddPair('binary', FDriver.BrowserConfig.BinaryPath);
        CapObj.AddPair('operaOptions', OperaOpts);
      end;
    end;
  end;

  Result := CapObj;
end;

end.

