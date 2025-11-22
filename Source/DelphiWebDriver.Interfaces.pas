{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Interfaces;

interface

uses
  System.JSON,
  System.SysUtils,
  System.Types,
  System.Generics.Collections,
  DelphiWebDriver.Types;

type
  IWebElement = interface;

  IWebDriverActions = interface
    ['{3F8C0F5A-2B4D-4E92-A8A9-9F4B6D8C3E21}']
    function MoveToElement(By: TBy; X: Integer = 0; Y: Integer = 0): IWebDriverActions;
    function Click: IWebDriverActions;
    function DoubleClick: IWebDriverActions;
    function ClickAndHold: IWebDriverActions;
    function ContextClick(By: TBy): IWebDriverActions;
    function Release: IWebDriverActions;
    function SendKeys(const Keys: string): IWebDriverActions;
    procedure Perform;
  end;

  IWebDriverAlert = interface
    ['{A3F9C2B8-5E41-4D92-8F7A-9C6B1F4E12D3}']
    procedure Accept;
    procedure Dismiss;
    function GetText: string;
    procedure SendKeys(const Text: string);
  end;

  IWebDriverScreenshot = interface
    ['{D7F3A59C-2E41-4B8D-9F6B-1C3A7E5D8B20}']
    function TakeScreenshot: TBytes;
    procedure SaveScreenshotToFile(const FileName: string);
    function TakeElementScreenshot(By: TBy): TBytes;
    procedure SaveElementScreenshotToFile(By: TBy; const FileName: string);
  end;

  IWebDriverWait = interface
    ['{9E4A2C71-6BD3-4F8F-91C5-7A2F4D8E3B10}']
    function UntilElement(By: TBy; TimeoutMS: Integer = 5000; IntervalMS: Integer = 200): IWebElement;
    function UntilElements(By: TBy; TimeoutMS: Integer = 5000; IntervalMS: Integer = 200): TArray<IWebElement>;
    procedure UntilPageLoad(TimeoutMS: Integer = 10000);
    function UntilElementDisappears(By: TBy; TimeoutMS: Integer = 5000; IntervalMS: Integer = 200): Boolean;
    function UntilUrlContains(const Text: string; TimeoutMS: Integer = 5000): Boolean;
    function UntilUrlIs(const Value: string; TimeoutMS: Integer = 5000): Boolean;
    function UntilTitleIs(const Value: string; TimeoutMS: Integer = 5000): Boolean;
    function UntilTitleContains(const Text: string; TimeoutMS: Integer = 5000): Boolean;
  end;

  IWebDriverDocument = interface
    ['{F1C27B3E-9A84-4F3D-8E6A-2B7D4A9150C9}']
    function GetPageSource: string;
    function ExecuteScript(const Script: string; const Args: array of string): TJSONValue; overload;
    procedure ExecuteScript(const Script: string); overload;
    function ExecuteAsyncScript(const Script: string; const Args: array of string): TJSONValue; overload;
    procedure ExecuteAsyncScript(const Script: string); overload;
    procedure ScrollBy(X, Y: Integer);
    procedure ScrollToTop;
    procedure ScrollToBottom;
    function PrintPdfPage: string;
    function SavePrintedPdfPage(const FileName: string): Boolean;
  end;

  IWebDriverCommands = interface
    ['{6D3A9B8E-42F1-4F77-9C84-0B52A1C9D3EF}']
    function SendCommand(const Method, Endpoint: string; Body: TJSONObject = nil): TJSONValue;
  end;

  IWebDriverElements = interface
    ['{A4B8C2E1-7F3D-4E9A-9C62-1D5F8B77E0F4}']
    function FindElement(By: TBy): IWebElement;
    function FindElements(By: TBy): TArray<IWebElement>;
    function GetElementAttribute(By: TBy; const Attr: string): string;
    function ElementExists(By: TBy): Boolean;
    function ElementsExist(By: TBy): Boolean;
  end;

  IWebDriverContexts = interface
    ['{3F8D2A7B-4C91-4A0D-9E1B-7C2BE1F0A6C3}']
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

  IWebDriverNavigation = interface
    ['{A3F7C2B1-9D44-4E89-AB12-7F5C3D9084EF}']
    procedure GoToURL(const Url: string);
    function GetTitle: string;
    function GetCurrentUrl: string;
    procedure GoBack;
    procedure GoForward;
    procedure Refresh;
  end;

  IWebDriverSessions = interface
    ['{9F4A6E1E-38F1-4F2E-8E13-5C71E3C4C9DA}']
    function StartSession: string;
    procedure Quit;
    function GetSessionId: string;
    function GetWindowHandle: string;
  end;

  IWebDriverCapabilities = interface
    ['{F2C8B5C0-B7B4-4D57-9C4B-62F8EDBB6564}']
    function GetHeadless: Boolean;
    procedure SetHeadless(const Value: Boolean);
    function GetProxy: TWebDriverProxy;
    procedure SetProxy(const Value: TWebDriverProxy);
    function GetArgs: TList<string>;
    property Headless: Boolean read GetHeadless write SetHeadless;
    property Proxy: TWebDriverProxy read GetProxy write SetProxy;
    property Arguments: TList<string> read GetArgs;
    function ToJSON: TJSONObject;
  end;

  IWebDriverCookies = interface
    ['{9F8A2A3C-0E6D-4F1E-8C7E-9D3A1B5C2F3A}']
    function GetAll: TArray<TWebDriverCookie>;
    procedure Add(const Cookie: TWebDriverCookie);
    procedure Delete(const Name: string);
    procedure DeleteAll;
    function GetByName(const Name: string): TWebDriverCookie;
    function Exists(const Name: string): Boolean;
  end;

  IWebElement = interface
    ['{F5C6E1F0-6A57-48F3-B7E8-BD3B38ACBB82}']
    function GetElementId: string;
    procedure Click;
    procedure Clear;
    procedure SendKeys(const Text: string);
    procedure Submit;
    function GetText: string;
    function GetAttribute(const Attr: string): string;
    function GetProperty(const Prop: string): string;
    function GetDomAttribute(const Attr: string): string;
    function GetDomProperty(const Prop: string): string;
    function GetCssValue(const Name: string): string;
    function IsDisplayed: Boolean;
    function IsEnabled: Boolean;
    function IsSelected: Boolean;
    function GetLocation: TPoint;
    function GetSize: TSize;
    function GetRect: TRect;
    function FindElement(By: TBy): IWebElement;
    function FindElements(By: TBy): TArray<IWebElement>;
    property ElementId: string read GetElementId;
    procedure ScrollIntoView(BehaviorSmooth: Boolean = False);
  end;

  IWebDriver = interface
    ['{9A8F0C82-3B1F-4A27-A1F7-9A69F9D243F0}']
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
    function BrowserConfig : TWebDriverBrowserConfig;
  end;

implementation

end.
