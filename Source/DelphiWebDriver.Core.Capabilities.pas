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
  System.IOUtils,
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
    FProxy: TWebDriverProxy;
    function GetHeadless: Boolean;
    procedure SetHeadless(const Value: Boolean);
    function GetArgs: TList<string>;
    function GetProxy: TWebDriverProxy;
    procedure SetProxy(const Value: TWebDriverProxy);
    function CreateChromiumProxyExtensionMV2(const Host, Username, Password: string; Port: Integer): string;
  public
    constructor Create(ADriver: IWebDriver);
    destructor Destroy; override;
    property Headless: Boolean read GetHeadless write SetHeadless;
    property Arguments: TList<string> read GetArgs;
    property Proxy: TWebDriverProxy read GetProxy write SetProxy;
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

function TWebDriverCapabilities.GetProxy: TWebDriverProxy;
begin
  Result := FProxy;
end;

procedure TWebDriverCapabilities.SetHeadless(const Value: Boolean);
begin
  FHeadless := Value;
end;

procedure TWebDriverCapabilities.SetProxy(const Value: TWebDriverProxy);
begin
  FProxy := Value;
end;

function TWebDriverCapabilities.CreateChromiumProxyExtensionMV2(const Host, Username, Password: string; Port: Integer): string;
var
  ExtensionDir, ManifestPath, BgPath: string;
  ManifestText, BgText: string;
begin
  ExtensionDir := ExtractFilePath(ParamStr(0)) + 'DelphiWebDriverProxyExtension\';
  if not TDirectory.Exists(ExtensionDir) then
    TDirectory.CreateDirectory(ExtensionDir);

  ManifestPath := ExtensionDir + 'manifest.json';
  BgPath := ExtensionDir + 'background.js';

  // MV2
  ManifestText :=
    '{' + sLineBreak +
    '  "manifest_version": 2,' + sLineBreak +
    '  "name": "DelphiWebDriver Proxy Extension",' + sLineBreak +
    '  "version": "1.0",' + sLineBreak +
    '  "description": "Sets HTTP proxy and supplies basic auth credentials.",' + sLineBreak +
    '  "permissions": [' + sLineBreak +
    '    "proxy",' + sLineBreak +
    '    "webRequest",' + sLineBreak +
    '    "webRequestBlocking",' + sLineBreak +
    '    "storage",' + sLineBreak +
    '    "<all_urls>"' + sLineBreak +
    '  ],' + sLineBreak +
    '  "background": { "scripts": ["background.js"], "persistent": true },' + sLineBreak +
    '  "minimum_chrome_version": "49"' + sLineBreak +
    '}';

  // background.js
  BgText :=
    'const proxyHost = "' + StringReplace(Host, '"', '\"', [rfReplaceAll]) + '";' + sLineBreak +
    'const proxyPort = ' + IntToStr(Port) + ';' + sLineBreak +
    'const proxyUser = "' + StringReplace(Username, '"', '\"', [rfReplaceAll]) + '";' + sLineBreak +
    'const proxyPass = "' + StringReplace(Password, '"', '\"', [rfReplaceAll]) + '";' + sLineBreak +
    sLineBreak +
    '(function(){' + sLineBreak +
    '  try {' + sLineBreak +
    '    chrome.proxy.settings.set({' + sLineBreak +
    '      value: {' + sLineBreak +
    '        mode: "fixed_servers",' + sLineBreak +
    '        rules: { singleProxy: { scheme: "http", host: proxyHost, port: proxyPort } }' + sLineBreak +
    '      },' + sLineBreak +
    '      scope: "regular"' + sLineBreak +
    '    }, function(){ console.log("proxy configured", proxyHost+":"+proxyPort); });' + sLineBreak +
    sLineBreak +
    '    chrome.webRequest.onAuthRequired.addListener(' + sLineBreak +
    '      function(details) {' + sLineBreak +
    '        if(proxyUser && proxyPass) {' + sLineBreak +
    '          return { authCredentials: { username: proxyUser, password: proxyPass } };' + sLineBreak +
    '        }' + sLineBreak +
    '        return {};' + sLineBreak +
    '      },' + sLineBreak +
    '      { urls: ["<all_urls>"] },' + sLineBreak +
    '      ["blocking"]' + sLineBreak +
    '    );' + sLineBreak +
    '  } catch(e){ console.error("proxy ext err", e); }' + sLineBreak +
    '})();' + sLineBreak;


  TFile.WriteAllText(ManifestPath, ManifestText, TEncoding.UTF8);
  TFile.WriteAllText(BgPath, BgText, TEncoding.UTF8);

  if (not TFile.Exists(ManifestPath)) or (not TFile.Exists(BgPath)) then
    raise Exception.Create('Failed to create proxy extension files in ' + ExtensionDir);

  Result := ExtensionDir;
end;

function TWebDriverCapabilities.ToJSON: TJSONObject;
var
  CapObj, OptionsObj, OperaOpts: TJSONObject;
  ArgsArray: TJSONArray;
  Arg: string;
begin
  ArgsArray := TJSONArray.Create;
  OptionsObj := TJSONObject.Create;

  if FHeadless then
  begin
    case FDriver.BrowserConfig.Browser of
      wdbChrome,
      wdbEdge,
      wdbOpera,
      wdbBrave:
        ArgsArray.Add('--headless=new');
      wdbFirefox:
        ArgsArray.Add('-headless');
    end;
  end;

  if FProxy.EnableProxy then
    begin
      case FDriver.BrowserConfig.Browser of
        wdbChrome, wdbEdge, wdbOpera, wdbBrave:
          begin
            var ExtensionDir := CreateChromiumProxyExtensionMV2(FProxy.Host, FProxy.Username, FProxy.Password, FProxy.Port);
            ArgsArray.Add('--load-extension=' + ExtensionDir);
            ArgsArray.Add('--proxy-server='+FProxy.Host+':'+FProxy.Port.ToString);
          end;
        wdbFirefox:
          begin
            var FFProxyPrefs := TJSONObject.Create;
            FFProxyPrefs.AddPair('network.proxy.type', TJSONNumber.Create(1));
            FFProxyPrefs.AddPair('network.proxy.http', FProxy.Host);
            FFProxyPrefs.AddPair('network.proxy.http_port', TJSONNumber.Create(FProxy.Port));
            FFProxyPrefs.AddPair('network.proxy.ssl', FProxy.Host);
            FFProxyPrefs.AddPair('network.proxy.ssl_port', TJSONNumber.Create(FProxy.Port));
            FFProxyPrefs.AddPair('signon.autologin.proxy', TJSONFalse.Create);
            FFProxyPrefs.AddPair('network.auth.allow-subresource-auth', TJSONFalse.Create);
            OptionsObj.AddPair('prefs', FFProxyPrefs);
          end;
      end;
    end;

  for Arg in FArgs do
    ArgsArray.Add(Arg);

  OptionsObj.AddPair('args', ArgsArray);

  if FDriver.BrowserConfig.BinaryPath <> '' then
    OptionsObj.AddPair('binary', FDriver.BrowserConfig.BinaryPath);

  CapObj := TJSONObject.Create;
  CapObj.AddPair('browserName', FDriver.BrowserConfig.Browser.Name);

  case FDriver.BrowserConfig.Browser of
    wdbChrome, wdbBrave:
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

