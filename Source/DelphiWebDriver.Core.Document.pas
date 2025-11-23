{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Core.Document;

interface

uses
  System.SysUtils,
  System.Classes,
  System.NetEncoding,
  System.JSON,
  DelphiWebDriver.Interfaces,
  DelphiWebDriver.Types;

type
  TWebDriverDocument = class(TInterfacedObject, IWebDriverDocument)
  private
    [weak]
    FDriver: IWebDriver;
  public
    constructor Create(ADriver: IWebDriver);
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
    function GetBodyElement: IWebElement;
  end;

implementation

{ TWebDriverDocument }

constructor TWebDriverDocument.Create(ADriver: IWebDriver);
begin
  inherited Create;
  FDriver := ADriver;
end;

function TWebDriverDocument.GetBodyElement: IWebElement;
begin
  Result := FDriver.Elements.FindElement(TBy.Css('body'));
end;

function TWebDriverDocument.ExecuteAsyncScript(const Script: string; const Args: array of string): TJSONValue;
var
  Body: TJSONObject;
  Arr: TJSONArray;
  S: string;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('script', Script);

    Arr := TJSONArray.Create;
    Body.AddPair('args', Arr);

    for S in Args do
      Arr.AddElement(TJSONString.Create(S));

    Result := FDriver.Commands.SendCommand(
      'POST',
      '/session/' + FDriver.Sessions.GetSessionId + '/execute/async',
      Body
    );
  finally
    Body.Free;
  end;
end;

procedure TWebDriverDocument.ExecuteAsyncScript(const Script: string);
var
  Resp: TJSONValue;
begin
  Resp := ExecuteAsyncScript(Script, []);
  try
    // ignore returned JS value
  finally
    Resp.Free;
  end;
end;

function TWebDriverDocument.ExecuteScript(const Script: string; const Args: array of string): TJSONValue;
var
  Body : TJSONObject;
  Arr: TJSONArray;
  S: string;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('script', Script);
    Arr := TJSONArray.Create;
    Body.AddPair('args', Arr);

    for S in Args do
      Arr.Add(S);

    Result := FDriver.Commands.SendCommand('POST',
      '/session/' + FDriver.Sessions.GetSessionId + '/execute/sync',
      Body
    );
  finally
    Body.Free;
  end;
end;

procedure TWebDriverDocument.ExecuteScript(const Script: string);
var
  Resp: TJSONValue;
begin
  Resp := ExecuteScript(Script, []);
  try
    // ignore result
  finally
    Resp.Free;
  end;
end;

function TWebDriverDocument.GetPageSource: string;
var
  JSON: TJSONValue;
begin
  JSON := FDriver.Commands.SendCommand('GET', '/session/' + FDriver.Sessions.GetSessionId + '/source');
  try
    Result := JSON.GetValue<string>('value');
  finally
    JSON.Free;
  end;
end;

function TWebDriverDocument.SavePrintedPdfPage(const FileName: string): Boolean;
var
  Base64Pdf: string;
  PdfBytes: TBytes;
  FS: TFileStream;
begin
  Result := False;
  Base64Pdf := PrintPdfPage;
  if Base64Pdf = '' then
    Exit;
  PdfBytes := TNetEncoding.Base64.DecodeStringToBytes(Base64Pdf);
  FS := TFileStream.Create(FileName, fmCreate);
  try
    FS.WriteBuffer(PdfBytes, Length(PdfBytes));
    Result := True;
  finally
    FS.Free;
  end;
end;

function TWebDriverDocument.PrintPdfPage: string;
var
  Body: TJSONObject;
  Res: TJSONValue;
begin
  Body := TJSONObject.Create;
  try
    Res := FDriver.Commands.SendCommand(
      'POST',
      '/session/' + FDriver.Sessions.GetSessionId + '/print',
      Body
    );
    try
      Result := Res.GetValue<string>('value');
    finally
      Res.Free;
    end;
  finally
    Body.Free;
  end;
end;

procedure TWebDriverDocument.ScrollBy(X, Y: Integer);
begin
  ExecuteScript(Format('window.scrollBy(%d, %d);', [X, Y]));
end;

procedure TWebDriverDocument.ScrollToBottom;
begin
  ExecuteScript('window.scrollTo(0, document.body.scrollHeight);');
end;

procedure TWebDriverDocument.ScrollToTop;
begin
  ExecuteScript('window.scrollTo(0,0);');
end;

end.
