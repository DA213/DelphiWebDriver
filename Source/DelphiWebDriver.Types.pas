{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Types;

interface

uses
  System.SysUtils,
  System.JSON;

type
  EWebDriverError = class(Exception);

  TBrowser = (Chrome, Firefox, Edge);
  TBrowserHelper = record Helper for TBrowser
    function Name : String;
    function DriverName : String;
  end;

  TCookie = record
    Name: string;
    Value: string;
    Domain: string;
    Path: string;
    Secure: Boolean;
    HttpOnly: Boolean;
    Expiry: Int64;
  end;

  TBy = record
    Strategy: string;
    Value: string;
    class function Name(const AValue: string): TBy; static;
    class function Id(const AValue: string): TBy; static;
    class function ClassName(const AValue: string): TBy; static;
    class function CssSelector(const AValue: string): TBy; static;
    class function XPath(const AValue: string): TBy; static;
    class function Css(const AValue: string): TBy; static;
    function ToJson: TJSONObject;
  end;

implementation

{ TBy }

function TBy.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('using', Strategy);
  Result.AddPair('value', Value);
end;

class function TBy.Css(const AValue: string): TBy;
begin
  Result.Strategy := 'css selector';
  Result.Value := AValue;
end;

class function TBy.XPath(const AValue: string): TBy;
begin
  Result.Strategy := 'xpath';
  Result.Value := AValue;
end;

class function TBy.CssSelector(const AValue: string): TBy;
begin
  Result.Strategy := 'css selector';
  Result.Value := AValue;
end;

class function TBy.Name(const AValue: string): TBy;
begin
  Result.Strategy := 'name';
  Result.Value := AValue;
end;

class function TBy.Id(const AValue: string): TBy;
begin
  Result.Strategy := 'id';
  Result.Value := AValue;
end;

class function TBy.ClassName(const AValue: string): TBy;
begin
  Result.Strategy := 'class name';
  Result.Value := AValue;
end;

{ TBrowserHelper }

function TBrowserHelper.DriverName: String;
begin
  case Self of
    Chrome  : Result := 'chromedriver.exe';
    Firefox : Result := 'geckodriver.exe';
    Edge    : Result := 'msedgedriver.exe';
  end;
end;

function TBrowserHelper.Name: String;
begin
  case Self of
    Chrome  : Result := 'chrome';
    Firefox : Result := 'firefox';
    Edge    : Result := 'MicrosoftEdge';
  end;
end;

end.

