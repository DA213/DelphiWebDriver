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

  TWebDriverActionItemType = (MouseMove, MouseDown, MouseUp, Click, DoubleClick, KeyDown, KeyUp, Pause, ContextClick);

  TWebDriverActionItem = record
    ActionType: TWebDriverActionItemType;
    ElementId: string;
    Key: string;
    X, Y: Integer;
  end;

  TWebDriverBrowser = (wdbUnknown, wdbChrome, wdbFirefox, wdbEdge);
  TWebDriverBrowserHelper = record Helper for TWebDriverBrowser
    function Name : String;
    function DriverName : String;
  end;

  TWebDriverCookie = record
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
    class function TagName(const AValue: string): TBy; static;
    class function LinkText(const AValue: string): TBy; static;
    class function PartialLinkText(const AValue: string): TBy; static;
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
  Result.Strategy := 'css selector';
  Result.Value := '[name="' + AValue.Trim + '"]';
end;

class function TBy.Id(const AValue: string): TBy;
begin
  Result.Strategy := 'css selector';
  Result.Value := '#' + AValue.Trim;
end;

class function TBy.ClassName(const AValue: string): TBy;
var
  Trimmed: string;
  Parts: TArray<string>;
  Part, Selector: string;
begin
  Trimmed := AValue.Trim;
  Parts := Trimmed.Split([' '], TStringSplitOptions.ExcludeEmpty);

  if Length(Parts) = 0 then
    raise EWebDriverError.Create('ClassName cannot be empty.');

  Selector := '';
  for Part in Parts do
    Selector := Selector + '.' + Part;

  Result.Strategy := 'css selector';
  Result.Value := Selector;
end;

class function TBy.TagName(const AValue: string): TBy;
begin
  Result.Strategy := 'tag name';
  Result.Value    := AValue;
end;

class function TBy.LinkText(const AValue: string): TBy;
begin
  Result.Strategy := 'link text';
  Result.Value    := AValue;
end;

class function TBy.PartialLinkText(const AValue: string): TBy;
begin
  Result.Strategy := 'partial link text';
  Result.Value    := AValue;
end;

{ TWebDriverBrowserHelper }

function TWebDriverBrowserHelper.DriverName: String;
begin
  case Self of
    wdbChrome  : Result := 'chromedriver.exe';
    wdbFirefox : Result := 'geckodriver.exe';
    wdbEdge    : Result := 'msedgedriver.exe';
  end;
end;

function TWebDriverBrowserHelper.Name: String;
begin
  case Self of
    wdbChrome  : Result := 'chrome';
    wdbFirefox : Result := 'firefox';
    wdbEdge    : Result := 'MicrosoftEdge';
  end;
end;

end.

