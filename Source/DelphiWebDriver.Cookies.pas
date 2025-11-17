{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Cookies;

interface

uses
  System.SysUtils,
  System.JSON,
  System.Generics.Collections,
  DelphiWebDriver.Interfaces,
  DelphiWebDriver.Types;

type
  TWebDriverCookies = class(TInterfacedObject, IWebDriverCookies)
  private
    [weak]
    FDriver: IWebDriver;
  public
    constructor Create(ADriver: IWebDriver);
    function GetAll: TArray<TCookie>;
    procedure Add(const Cookie: TCookie);
    procedure Delete(const Name: string);
    procedure DeleteAll;
    function GetByName(const Name: string): TCookie;
    function Exists(const Name: string): Boolean;
  end;

implementation

{ TWebDriverCookies }

constructor TWebDriverCookies.Create(ADriver: IWebDriver);
begin
  inherited Create;
  FDriver := ADriver;
end;

function TWebDriverCookies.GetByName(const Name: string): TCookie;
var
  All: TArray<TCookie>;
  Cookie: TCookie;
begin
  All := GetAll;
  for Cookie in All do
    if SameText(Cookie.Name, Name) then
      Exit(Cookie);
  raise EWebDriverError.Create('Cookie "' + Name + '" not found');
end;

function TWebDriverCookies.Exists(const Name: string): Boolean;
var
  All: TArray<TCookie>;
  Cookie: TCookie;
begin
  All := GetAll;
  for Cookie in All do
    if SameText(Cookie.Name, Name) then
      Exit(True);
  Result := False;
end;

function TWebDriverCookies.GetAll: TArray<TCookie>;
var
  LResp: TJSONValue;
  LArr: TJSONArray;
  Item: TJSONValue;
  CookieObj: TJSONObject;
  Cookie: TCookie;
  List: TList<TCookie>;
begin
  LResp := FDriver.SendCommand('GET', '/session/' + FDriver.GetSessionId +
    '/cookie');
  try
    LArr := LResp.GetValue<TJSONArray>('value');
    List := TList<TCookie>.Create;
    try
      for Item in LArr do
      begin
        CookieObj := Item as TJSONObject;
        Cookie.Name := CookieObj.GetValue<string>('name');
        Cookie.Value := CookieObj.GetValue<string>('value');
        Cookie.Domain := CookieObj.GetValue<string>('domain');
        Cookie.Path := CookieObj.GetValue<string>('path');
        Cookie.Secure := CookieObj.GetValue<Boolean>('secure');
        Cookie.HttpOnly := CookieObj.GetValue<Boolean>('httpOnly');
        if not CookieObj.TryGetValue<Int64>('expiry', Cookie.Expiry) then
          Cookie.Expiry := 0;
        List.Add(Cookie);
      end;
      Result := List.ToArray;
    finally
      List.Free;
    end;
  finally
    LResp.Free;
  end;
end;

procedure TWebDriverCookies.Add(const Cookie: TCookie);
var
  LBody, LObj: TJSONObject;
begin
  LBody := TJSONObject.Create;
  try
    LObj := TJSONObject.Create;
    try
      LObj.AddPair('name', Cookie.Name);
      LObj.AddPair('value', Cookie.Value);
      LObj.AddPair('domain', Cookie.Domain);
      LObj.AddPair('path', Cookie.Path);
      LObj.AddPair('secure', TJSONBool.Create(Cookie.Secure));
      LObj.AddPair('httpOnly', TJSONBool.Create(Cookie.HttpOnly));
      if Cookie.Expiry > 0 then
        LObj.AddPair('expiry', TJSONNumber.Create(Cookie.Expiry));
      LBody.AddPair('cookie', LObj);
      FDriver.SendCommand('POST', '/session/' + FDriver.GetSessionId +
        '/cookie', LBody).Free;
    except
      LObj.Free;
      raise;
    end;
  finally
    LBody.Free;
  end;
end;

procedure TWebDriverCookies.Delete(const Name: string);
begin
  FDriver.SendCommand('DELETE', '/session/' + FDriver.GetSessionId + '/cookie/'
    + Name).Free;
end;

procedure TWebDriverCookies.DeleteAll;
begin
  FDriver.SendCommand('DELETE', '/session/' + FDriver.GetSessionId +
    '/cookie').Free;
end;

end.
