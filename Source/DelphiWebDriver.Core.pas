{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Core;

interface

uses
  DelphiWebDriver.Interfaces,
  DelphiWebDriver.Core.Capabilities,
  DelphiWebDriver.Core.Sessions,
  DelphiWebDriver.Core.Navigation,
  DelphiWebDriver.Core.Contexts,
  DelphiWebDriver.Core.Cookies,
  DelphiWebDriver.Core.Elements,
  DelphiWebDriver.Core.Commands,
  DelphiWebDriver.Core.Document,
  DelphiWebDriver.Core.Wait,
  DelphiWebDriver.Core.Screenshot,
  DelphiWebDriver.Core.Alert,
  DelphiWebDriver.Core.Actions,
  DelphiWebDriver.Types;

type
  TWebDriver = class(TInterfacedObject, IWebDriver)
  private
    FBaseUrl: string;
    FBrowser: TWebDriverBrowser;
    FCapabilities : IWebDriverCapabilities;
    FSessions : IWebDriverSessions;
    FNavigation : IWebDriverNavigation;
    FContexts : IWebDriverContexts;
    FElements : IWebDriverElements;
    FCookies: IWebDriverCookies;
    FCommands: IWebDriverCommands;
    FDocument : IWebDriverDocument;
    FWait : IWebDriverWait;
    FScreenshot : IWebDriverScreenshot;
    FAlert : IWebDriverAlert;
    FActions : IWebDriverActions;
  public
    constructor Create(Browser: TWebDriverBrowser; const ABaseUrl: string); virtual;
    function Capabilities: IWebDriverCapabilities;
    function Sessions : IWebDriverSessions;
    function Navigation : IWebDriverNavigation;
    function Contexts : IWebDriverContexts;
    function Elements : IWebDriverElements;
    function Cookies: IWebDriverCookies;
    function Commands: IWebDriverCommands;
    function Document : IWebDriverDocument;
    function Wait : IWebDriverWait;
    function Screenshot : IWebDriverScreenshot;
    function Alert : IWebDriverAlert;
    function Actions : IWebDriverActions;
    function Browser : TWebDriverBrowser;
  end;

implementation

{ TWebDriver }

constructor TWebDriver.Create(Browser: TWebDriverBrowser; const ABaseUrl: string);
begin
  inherited Create;
  FBaseUrl := ABaseUrl;
  FBrowser := Browser;
end;

function TWebDriver.Document: IWebDriverDocument;
begin
  if FDocument = nil then
    FDocument := TWebDriverDocument.Create(Self as IWebDriver);
  Result := FDocument;
end;

function TWebDriver.Actions: IWebDriverActions;
begin
  if FActions = nil then
    FActions := TWebDriverActions.Create(Self as IWebDriver);
  Result := FActions;
end;

function TWebDriver.Alert: IWebDriverAlert;
begin
  if FAlert = nil then
    FAlert := TWebDriverAlert.Create(Self as IWebDriver);
  Result := FAlert;
end;

function TWebDriver.Browser: TWebDriverBrowser;
begin
  Result := FBrowser;
end;

function TWebDriver.Capabilities: IWebDriverCapabilities;
begin
  if FCapabilities = nil then
    FCapabilities := TWebDriverCapabilities.Create(Self as IWebDriver);
  Result := FCapabilities;
end;

function TWebDriver.Elements: IWebDriverElements;
begin
  if FElements = nil then
    FElements := TWebDriverElements.Create(Self as IWebDriver);
  Result := FElements;
end;

function TWebDriver.Wait: IWebDriverWait;
begin
  if FWait = nil then
    FWait := TWebDriverWait.Create(Self as IWebDriver);
  Result := FWait;
end;

function TWebDriver.Sessions: IWebDriverSessions;
begin
  if FSessions = nil then
    FSessions := TWebDriverSessions.Create(Self as IWebDriver);
  Result := FSessions;
end;

function TWebDriver.Navigation: IWebDriverNavigation;
begin
  if FNavigation = nil then
    FNavigation := TWebDriverNavigation.Create(Self as IWebDriver);
  Result := FNavigation;
end;

function TWebDriver.Commands: IWebDriverCommands;
begin
  if FCommands = nil then
    FCommands := TWebDriverCommands.Create(FBaseUrl);
  Result := FCommands;
end;

function TWebDriver.Contexts: IWebDriverContexts;
begin
  if FContexts = nil then
    FContexts := TWebDriverContexts.Create(Self as IWebDriver);
  Result := FContexts;
end;

function TWebDriver.Cookies: IWebDriverCookies;
begin
  if FCookies = nil then
    FCookies := TWebDriverCookies.Create(Self as IWebDriver);
  Result := FCookies;
end;

function TWebDriver.Screenshot: IWebDriverScreenshot;
begin
  if FScreenshot = nil then
    FScreenshot := TWebDriverScreenshot.Create(Self as IWebDriver);
  Result := FScreenshot;
end;

end.
