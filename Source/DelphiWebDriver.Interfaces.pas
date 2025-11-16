unit DelphiWebDriver.Interfaces;

interface

uses
  System.JSON,
  System.SysUtils,
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
    procedure SendKeys(const Text: string);
    procedure Submit;
    function GetText: string;
    function GetAttribute(const Attr: string): string;
    property ElementId: string read GetElementId;
  end;

  IWebDriver = interface
    ['{9A8F0C82-3B1F-4A27-A1F7-9A69F9D243F0}']
    function StartSession(Capabilities: TWebDriverCapabilities): string;
    procedure Quit;
    function FindElement(By: TBy): IWebElement;
    function FindElements(By: TBy): TArray<IWebElement>;
    function SendCommand(const Method, Endpoint: string;
      Body: TJSONObject = nil): TJSONValue;
    function GetSessionId: string;
    procedure Navigate(const Url: string);
    function GetTitle: string;
    function GetCurrentUrl: string;
    procedure Back;
    procedure Forward;
    procedure Refresh;
    function TakeScreenshot: TBytes;
    procedure SaveScreenshotToFile(const FileName: string);
    function WaitUntilElement(By: TBy; TimeoutMS: Integer = 5000;
      IntervalMS: Integer = 200): IWebElement;
    function ExecuteScript(const Script: string; const Args: array of string): TJSONValue; overload;
    procedure ExecuteScript(const Script: string); overload;
    procedure WaitUntilPageLoad(TimeoutMS: Integer = 10000);
  end;

implementation

end.
