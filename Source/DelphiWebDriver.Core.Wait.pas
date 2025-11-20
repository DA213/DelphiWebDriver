{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Core.Wait;

interface

uses
  System.SysUtils,
  System.JSON,
  System.DateUtils,
  DelphiWebDriver.Interfaces,
  DelphiWebDriver.Types;

type
  TWebDriverWait = class(TInterfacedObject, IWebDriverWait)
  private
    [weak]
    FDriver: IWebDriver;
  public
    constructor Create(ADriver: IWebDriver);
    function UntilElement(By: TBy; TimeoutMS: Integer = 5000; IntervalMS: Integer = 200): IWebElement;
    function UntilElements(By: TBy; TimeoutMS: Integer = 5000; IntervalMS: Integer = 200): TArray<IWebElement>;
    procedure UntilPageLoad(TimeoutMS: Integer = 10000);
    function UntilElementDisappears(By: TBy; TimeoutMS: Integer = 5000; IntervalMS: Integer = 200): Boolean;
  end;

implementation

{ TWebDriverWait }

constructor TWebDriverWait.Create(ADriver: IWebDriver);
begin
  inherited Create;
  FDriver := ADriver;
end;

function TWebDriverWait.UntilElementDisappears(By: TBy; TimeoutMS, IntervalMS: Integer): Boolean;
var
  StartTime: TDateTime;
begin
  StartTime := Now;
  while MilliSecondsBetween(Now, StartTime) < TimeoutMS do
  begin
    try
      if not FDriver.Elements.ElementExists(By) then
      begin
        Result := True;
        Exit;
      end;
    except
    end;
    Sleep(IntervalMS);
  end;
  Result := False;
end;

function TWebDriverWait.UntilElement(By: TBy; TimeoutMS, IntervalMS: Integer): IWebElement;
var
  ElemTemp: IWebElement;
  StartTime: TDateTime;
begin
  ElemTemp := nil;
  StartTime := Now;
  while MilliSecondsBetween(Now, StartTime) < TimeoutMS do
  begin
    try
      ElemTemp := FDriver.Elements.FindElement(By);
      if Assigned(ElemTemp) then
      begin
        Result := ElemTemp;
        Exit;
      end;
    except
      ElemTemp := nil;
    end;
    Sleep(IntervalMS);
  end;
  Result := nil;
end;

function TWebDriverWait.UntilElements(By: TBy; TimeoutMS, IntervalMS: Integer): TArray<IWebElement>;
var
  Found: TArray<IWebElement>;
  StartTime: TDateTime;
begin
  StartTime := Now;
  while MilliSecondsBetween(Now, StartTime) < TimeoutMS do
  begin
    try
      Found := FDriver.Elements.FindElements(By);
      if Length(Found) > 0 then
      begin
        Result := Found;
        Exit;
      end;
    except
      // ignore and retry
    end;
    Sleep(IntervalMS);
  end;
  SetLength(Result, 0);
end;

procedure TWebDriverWait.UntilPageLoad(TimeoutMS: Integer);
var
  StartTime: TDateTime;
  Resp: TJSONValue;
  ReadyState: string;
begin
  StartTime := Now;
  while MilliSecondsBetween(Now, StartTime) < TimeoutMS do
  begin
    try
      Resp := FDriver.Document.ExecuteScript('return document.readyState;', []);
      try
        ReadyState := Resp.GetValue<string>('value');
      finally
        Resp.Free;
      end;

      if ReadyState = 'complete' then
        Exit;
    except
    end;
    Sleep(100);
  end;
  raise EWebDriverError.Create('Timeout waiting for page to finish loading.');
end;

end.
