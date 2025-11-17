{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Capabilities;

interface

uses
  System.SysUtils,
  System.JSON,
  DelphiWebDriver.Types;

type
  TWebDriverCapabilities = class
  private
    FBrowserName: string;
    FHeadless: Boolean;
  public
    constructor Create;
    property BrowserName: string read FBrowserName write FBrowserName;
    property Headless: Boolean read FHeadless write FHeadless;
    function ToJSON: TJSONObject;
  end;

implementation

{ TWebDriverCapabilities }

constructor TWebDriverCapabilities.Create;
begin
  inherited;
  FHeadless := False;
end;

function TWebDriverCapabilities.ToJSON: TJSONObject;
var
  FirstMatchArray: TJSONArray;
  AlwaysObj, OptionsObj: TJSONObject;
  ArgsArray: TJSONArray;
begin
  if FBrowserName = '' then
    raise Exception.Create('BrowserName cannot be empty');
  FirstMatchArray := TJSONArray.Create;
  FirstMatchArray.Add(TJSONObject.Create);
  AlwaysObj := TJSONObject.Create;
  AlwaysObj.AddPair('browserName', FBrowserName);
  if FHeadless then
  begin
    ArgsArray := TJSONArray.Create;
    if SameText(FBrowserName, TBrowser.Chrome.Name) then
    begin
      ArgsArray.Add('--headless');
      OptionsObj := TJSONObject.Create;
      OptionsObj.AddPair('args', ArgsArray);
      AlwaysObj.AddPair('goog:chromeOptions', OptionsObj);
    end
    else if SameText(FBrowserName, TBrowser.Firefox.Name) then
    begin
      ArgsArray.Add('-headless');
      OptionsObj := TJSONObject.Create;
      OptionsObj.AddPair('args', ArgsArray);
      AlwaysObj.AddPair('moz:firefoxOptions', OptionsObj);
    end
    else if SameText(FBrowserName, TBrowser.Edge.Name) then
    begin
      ArgsArray.Add('--headless=new');
      OptionsObj := TJSONObject.Create;
      OptionsObj.AddPair('args', ArgsArray);
      AlwaysObj.AddPair('ms:edgeOptions', OptionsObj);
    end;
  end;
  Result := TJSONObject.Create;
  Result.AddPair('capabilities',
    TJSONObject.Create
      .AddPair('firstMatch', FirstMatchArray)
      .AddPair('alwaysMatch', AlwaysObj)
  );
end;

end.

