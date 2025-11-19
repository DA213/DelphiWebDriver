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
    FBrowserName: string;
    FHeadless: Boolean;
    FArgs: TList<string>;
    function GetBrowserName: string;
    procedure SetBrowserName(const Value: string);
    function GetHeadless: Boolean;
    procedure SetHeadless(const Value: Boolean);
    function GetArgs: TList<string>;
  public
    constructor Create;
    destructor Destroy; override;
    property BrowserName: string read FBrowserName write FBrowserName;
    property Headless: Boolean read FHeadless write FHeadless;
    property Args: TList<string> read FArgs;
    function ToJSON: TJSONObject;
  end;

implementation

{ TWebDriverCapabilities }

constructor TWebDriverCapabilities.Create;
begin
  inherited;
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

function TWebDriverCapabilities.GetBrowserName: string;
begin
  Result := FBrowserName;
end;

procedure TWebDriverCapabilities.SetBrowserName(const Value: string);
begin
  FBrowserName := Value;
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
  if FBrowserName = '' then
    raise Exception.Create('BrowserName cannot be empty');

  FirstMatchArray := TJSONArray.Create;
  FirstMatchArray.Add(TJSONObject.Create);
  AlwaysObj := TJSONObject.Create;
  AlwaysObj.AddPair('browserName', FBrowserName);
  ArgsArray := TJSONArray.Create;

  if FHeadless then
  begin
    if SameText(FBrowserName, TWebDriverBrowser.Chrome.Name) then
      ArgsArray.Add('--headless')
    else if SameText(FBrowserName, TWebDriverBrowser.Firefox.Name) then
      ArgsArray.Add('-headless')
    else if SameText(FBrowserName, TWebDriverBrowser.Edge.Name) then
      ArgsArray.Add('--headless=new');
  end;

  for Arg in FArgs do
    ArgsArray.Add(Arg);

  if ArgsArray.Count > 0 then
    begin
      OptionsObj := TJSONObject.Create;
      OptionsObj.AddPair('args', ArgsArray);
      if SameText(FBrowserName, TWebDriverBrowser.Chrome.Name) then
        AlwaysObj.AddPair('goog:chromeOptions', OptionsObj)
      else if SameText(FBrowserName, TWebDriverBrowser.Firefox.Name) then
        AlwaysObj.AddPair('moz:firefoxOptions', OptionsObj)
      else if SameText(FBrowserName, TWebDriverBrowser.Edge.Name) then
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

