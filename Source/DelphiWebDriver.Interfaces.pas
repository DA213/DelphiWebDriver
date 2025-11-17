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
  DelphiWebDriver.Capabilities,
  DelphiWebDriver.Types;

type
  IWebDriverCookies = interface
    ['{9F8A2A3C-0E6D-4F1E-8C7E-9D3A1B5C2F3A}']
    function GetAll: TArray<TCookie>;
    procedure Add(const Cookie: TCookie);
    procedure Delete(const Name: string);
    procedure DeleteAll;
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
    function StartSession(Capabilities: TWebDriverCapabilities): string;
    procedure Quit;
    function FindElement(By: TBy): IWebElement;
    function FindElements(By: TBy): TArray<IWebElement>;
    function SendCommand(const Method, Endpoint: string; Body: TJSONObject = nil): TJSONValue;
    function GetSessionId: string;
    procedure Navigate(const Url: string);
    function GetTitle: string;
    function GetCurrentUrl: string;
    procedure GoBack;
    procedure GoForward;
    procedure Refresh;
    procedure SwitchToFrameElement(const Element: IWebElement);
    procedure SwitchToFrame(const FrameName: string);
    procedure SwitchToDefaultContent;
    function Cookies: IWebDriverCookies;
    function TakeScreenshot: TBytes;
    procedure SaveScreenshotToFile(const FileName: string);
    function WaitUntilElement(By: TBy; TimeoutMS: Integer = 5000; IntervalMS: Integer = 200): IWebElement;
    function WaitUntilElements(By: TBy; TimeoutMS: Integer = 5000; IntervalMS: Integer = 200): TArray<IWebElement>;
    function ExecuteScript(const Script: string; const Args: array of string): TJSONValue; overload;
    procedure ExecuteScript(const Script: string); overload;
    function ExecuteAsyncScript(const Script: string; const Args: array of string): TJSONValue; overload;
    procedure ExecuteAsyncScript(const Script: string); overload;
    procedure WaitUntilPageLoad(TimeoutMS: Integer = 10000);
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
    function GetPageSource: string;
    function ElementExists(By: TBy): Boolean;
    function ElementsExist(By: TBy): Boolean;
  end;

implementation

end.
