{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Core.Elements;

interface

uses
  System.JSON,
  System.Generics.Collections,
  DelphiWebDriver.Interfaces,
  DelphiWebDriver.Types,
  DelphiWebDriver.Element;

type
  TWebDriverElements = class(TInterfacedObject, IWebDriverElements)
  private
    [weak]
    FDriver: IWebDriver;
  public
    constructor Create(ADriver: IWebDriver);
    function FindElement(By: TBy): IWebElement;
    function FindElements(By: TBy): TArray<IWebElement>;
    function GetElementAttribute(By: TBy; const Attr: string): string;
    function ElementExists(By: TBy): Boolean;
    function ElementsExist(By: TBy): Boolean;
  end;

implementation

{ TWebDriverElements }

constructor TWebDriverElements.Create(ADriver: IWebDriver);
begin
  inherited Create;
  FDriver := ADriver;
end;

function TWebDriverElements.ElementExists(By: TBy): Boolean;
begin
  try
    Result := Assigned(FindElement(By));
  except
    Result := False;
  end;
end;

function TWebDriverElements.ElementsExist(By: TBy): Boolean;
begin
  try
    Result := Length(FindElements(By)) > 0;
  except
    Result := False;
  end;
end;

function TWebDriverElements.FindElement(By: TBy): IWebElement;
var
  Body: TJSONObject;
  LRes: TJSONValue;
  ValObj: TJSONObject;
  ElemId: string;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('using', By.Strategy);
    Body.AddPair('value', By.Value);

    LRes := FDriver.Commands.SendCommand(
      'POST',
      '/session/' + FDriver.Sessions.GetSessionId + '/element',
      Body
    );

    try
      if LRes.TryGetValue<TJSONObject>('value', ValObj) then
      begin
        if ValObj.TryGetValue<string>(
            'element-6066-11e4-a52e-4f735466cecf', ElemId) then
          Exit(TWebElement.Create(FDriver, ElemId));

        if ValObj.TryGetValue<string>('ELEMENT', ElemId) then
          Exit(TWebElement.Create(FDriver, ElemId));
      end;

      if LRes.TryGetValue<string>('element-6066-11e4-a52e-4f735466cecf', ElemId) then
        Exit(TWebElement.Create(FDriver, ElemId));

      if LRes.TryGetValue<string>('ELEMENT', ElemId) then
        Exit(TWebElement.Create(FDriver, ElemId));

      raise EWebDriverError.Create('Cannot extract element ID: ' + LRes.ToString);
    finally
      LRes.Free;
    end;

  finally
    Body.Free;
  end;
end;

function TWebDriverElements.FindElements(By: TBy): TArray<IWebElement>;
var
  Body: TJSONObject;
  LRes: TJSONValue;
  Arr: TJSONArray;
  Item: TJSONValue;
  ElemObj: TJSONObject;
  ElemId: string;
  List: TList<IWebElement>;
begin
  Body := TJSONObject.Create;
  List := TList<IWebElement>.Create;
  try
    Body.AddPair('using', By.Strategy);
    Body.AddPair('value', By.Value);
    LRes := FDriver.Commands.SendCommand(
      'POST',
      '/session/' + FDriver.Sessions.GetSessionId + '/elements',
      Body
    );
    try
      Arr := LRes.GetValue<TJSONArray>('value');
      if (Arr = nil) or (Arr.Count = 0) then
      begin
        Result := [];
        Exit;
      end;
      for Item in Arr do
      begin
        ElemObj := Item as TJSONObject;
        if not ElemObj.TryGetValue<string>(
            'element-6066-11e4-a52e-4f735466cecf', ElemId) then
          ElemId := ElemObj.GetValue<string>('ELEMENT');
        List.Add(TWebElement.Create(FDriver, ElemId));
      end;
      Result := List.ToArray;
    finally
      LRes.Free;
    end;
  finally
    Body.Free;
    List.Free;
  end;
end;

function TWebDriverElements.GetElementAttribute(By: TBy; const Attr: string): string;
var
  Elem: IWebElement;
begin
  Elem := FindElement(By);
  if Assigned(Elem) then
    Result := Elem.GetAttribute(Attr)
  else
    Result := '';
end;

end.
