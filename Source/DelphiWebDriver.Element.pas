{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Element;

interface

uses
  System.SysUtils,
  System.JSON,
  System.Types,
  System.Generics.Collections,
  System.StrUtils,
  DelphiWebDriver.Interfaces,
  DelphiWebDriver.Types;

type
  TWebElement = class(TInterfacedObject, IWebElement)
  private
    FDriver: IWebDriver;
    FElementId: string;
  public
    constructor Create(ADriver: IWebDriver; const AElementId: string);
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
    procedure ScrollIntoView(BehaviorSmooth: Boolean = False);
  end;

implementation

{ TWebElement }

constructor TWebElement.Create(ADriver: IWebDriver; const AElementId: string);
begin
  inherited Create;
  FDriver := ADriver;
  FElementId := AElementId;
end;

function TWebElement.GetElementId: string;
begin
  Result := FElementId;
end;

procedure TWebElement.ScrollIntoView(BehaviorSmooth: Boolean);
var
  Script: string;
  Params: TJSONObject;
  ArrayArgs: TJSONArray;
  ElementObj: TJSONObject;
begin
  Script :=
    'arguments[0].scrollIntoView({' +
    'behavior: "' + IfThen(BehaviorSmooth, 'smooth', 'auto') + '",' +
    'block: "center",' +
    'inline: "nearest"' +
    '});';
  Params := TJSONObject.Create;
  ElementObj := TJSONObject.Create;
  ArrayArgs := TJSONArray.Create;
  try
    ElementObj.AddPair('ELEMENT', FElementId);
    ElementObj.AddPair('element-6066-11e4-a52e-4f735466cecf', FElementId);
    ArrayArgs.Add(ElementObj);
    Params.AddPair('script', Script);
    Params.AddPair('args', ArrayArgs);
    FDriver.SendCommand(
      'POST',
      '/session/' + FDriver.GetSessionId + '/execute/sync',
      Params
    ).Free;
  finally
    Params.Free;
  end;
end;

procedure TWebElement.Click;
var
  JSON : TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    FDriver.SendCommand('POST',
      '/session/' + FDriver.GetSessionId + '/element/' + FElementId + '/click',
      JSON
    ).Free;
  finally
    JSON.Free;
  end;
end;

procedure TWebElement.Clear;
var
  JSON : TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    FDriver.SendCommand('POST',
      '/session/' + FDriver.GetSessionId + '/element/' + FElementId + '/clear',
      JSON
    ).Free;
  finally
    JSON.Free;
  end;
end;

procedure TWebElement.SendKeys(const Text: string);
var
  Body: TJSONObject;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('text', Text);
    FDriver.SendCommand('POST',
      '/session/' + FDriver.GetSessionId + '/element/' + FElementId + '/value',
      Body
    ).Free;
  finally
    Body.Free;
  end;
end;

procedure TWebElement.Submit;
var
  JSON : TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    FDriver.SendCommand('POST',
      '/session/' + FDriver.GetSessionId + '/element/' + FElementId + '/submit',
      JSON
    ).Free;
  finally
    JSON.Free;
  end;
end;

function TWebElement.GetText: string;
var
  JSON: TJSONValue;
begin
  JSON := FDriver.SendCommand('GET',
    '/session/' + FDriver.GetSessionId + '/element/' + FElementId + '/text'
  );
  try
    Result := JSON.GetValue<string>('value');
  finally
    JSON.Free;
  end;
end;

function TWebElement.GetAttribute(const Attr: string): string;
var
  JSON: TJSONValue;
begin
  JSON := FDriver.SendCommand('GET',
    '/session/' + FDriver.GetSessionId + '/element/' + FElementId +
    '/attribute/' + Attr
  );
  try
    Result := JSON.GetValue<string>('value');
  finally
    JSON.Free;
  end;
end;

function TWebElement.GetDomAttribute(const Attr: string): string;
var
  JSON: TJSONValue;
begin
  JSON := FDriver.SendCommand('GET',
    '/session/' + FDriver.GetSessionId + '/element/' + FElementId +
    '/attribute/' + Attr
  );
  try
    Result := JSON.GetValue<string>('value');
  finally
    JSON.Free;
  end;
end;

function TWebElement.GetProperty(const Prop: string): string;
var
  JSON: TJSONValue;
begin
  JSON := FDriver.SendCommand('GET',
    '/session/' + FDriver.GetSessionId + '/element/' + FElementId +
    '/property/' + Prop
  );
  try
    Result := JSON.GetValue<string>('value');
  finally
    JSON.Free;
  end;
end;

function TWebElement.GetDomProperty(const Prop: string): string;
var
  JSON: TJSONValue;
begin
  JSON := FDriver.SendCommand('GET',
    '/session/' + FDriver.GetSessionId + '/element/' + FElementId +
    '/property/' + Prop
  );
  try
    Result := JSON.GetValue<string>('value');
  finally
    JSON.Free;
  end;
end;

function TWebElement.GetCssValue(const Name: string): string;
var
  JSON: TJSONValue;
begin
  JSON := FDriver.SendCommand('GET',
    '/session/' + FDriver.GetSessionId + '/element/' + FElementId +
    '/css/' + Name
  );
  try
    Result := JSON.GetValue<string>('value');
  finally
    JSON.Free;
  end;
end;

function TWebElement.IsDisplayed: Boolean;
var
  JSON: TJSONValue;
begin
  JSON := FDriver.SendCommand('GET',
    '/session/' + FDriver.GetSessionId + '/element/' + FElementId +
    '/displayed'
  );
  try
    Result := JSON.GetValue<Boolean>('value');
  finally
    JSON.Free;
  end;
end;

function TWebElement.IsEnabled: Boolean;
var
  JSON: TJSONValue;
begin
  JSON := FDriver.SendCommand('GET',
    '/session/' + FDriver.GetSessionId + '/element/' + FElementId +
    '/enabled'
  );
  try
    Result := JSON.GetValue<Boolean>('value');
  finally
    JSON.Free;
  end;
end;

function TWebElement.IsSelected: Boolean;
var
  JSON: TJSONValue;
begin
  JSON := FDriver.SendCommand('GET',
    '/session/' + FDriver.GetSessionId + '/element/' + FElementId +
    '/selected'
  );
  try
    Result := JSON.GetValue<Boolean>('value');
  finally
    JSON.Free;
  end;
end;

function TWebElement.GetRect: TRect;
var
  JSON: TJSONValue;
  Obj: TJSONObject;
begin
  JSON := FDriver.SendCommand('GET',
    '/session/' + FDriver.GetSessionId + '/element/' + FElementId + '/rect'
  );
  try
    Obj := JSON.GetValue<TJSONObject>('value');
    Result := TRect.Create(
      Obj.GetValue<Integer>('x'),
      Obj.GetValue<Integer>('y'),
      Obj.GetValue<Integer>('x') + Obj.GetValue<Integer>('width'),
      Obj.GetValue<Integer>('y') + Obj.GetValue<Integer>('height')
    );
  finally
    JSON.Free;
  end;
end;

function TWebElement.GetLocation: TPoint;
var
  R: TRect;
begin
  R := GetRect;
  Result := Point(R.Left, R.Top);
end;

function TWebElement.GetSize: TSize;
var
  R: TRect;
begin
  R := GetRect;
  Result := TSize.Create(R.Width, R.Height);
end;

function TWebElement.FindElement(By: TBy): IWebElement;
var
  Body: TJSONObject;
  Json: TJSONValue;
  ElemObj: TJSONObject;
  ElemId: string;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('using', By.Strategy);
    Body.AddPair('value', By.Value);

    Json := FDriver.SendCommand('POST',
      '/session/' + FDriver.GetSessionId +
      '/element/' + FElementId + '/element',
      Body
    );
    try
      ElemObj := Json.GetValue<TJSONObject>('value');
      if not Assigned(ElemObj) then
        raise EWebDriverError.Create('No element object returned');

      if not ElemObj.TryGetValue<string>(
        'element-6066-11e4-a52e-4f735466cecf', ElemId) then
        ElemId := ElemObj.GetValue<string>('ELEMENT');

      Result := TWebElement.Create(FDriver, ElemId);
    finally
      Json.Free;
    end;
  finally
    Body.Free;
  end;
end;

function TWebElement.FindElements(By: TBy): TArray<IWebElement>;
var
  Body: TJSONObject;
  Json, ArrItem: TJSONValue;
  ElementsArray: TJSONArray;
  I: Integer;
  ElementId: string;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('using', By.Strategy);
    Body.AddPair('value', By.Value);

    Json := FDriver.SendCommand(
      'POST',
      '/session/' + FDriver.GetSessionId +
      '/element/' + FElementId + '/elements',
      Body
    );
    try
      ElementsArray := Json.GetValue<TJSONArray>('value');
      SetLength(Result, ElementsArray.Count);
      for I := 0 to ElementsArray.Count - 1 do
      begin
        ArrItem := ElementsArray.Items[I];
        if not (ArrItem as TJSONObject).TryGetValue<string>(
          'element-6066-11e4-a52e-4f735466cecf', ElementId) then
          ElementId := (ArrItem as TJSONObject).GetValue<string>('ELEMENT');
        Result[I] := TWebElement.Create(FDriver, ElementId);
      end;
    finally
      Json.Free;
    end;
  finally
    Body.Free;
  end;
end;

end.

