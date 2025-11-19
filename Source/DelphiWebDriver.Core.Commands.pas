{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Core.Commands;

interface

uses
  System.SysUtils,
  System.JSON,
  System.Classes,
  System.Generics.Collections,
  System.Net.HttpClient,
  DelphiWebDriver.Interfaces,
  DelphiWebDriver.Types,
  DelphiWebDriver.Element;

type
  TWebDriverCommands = class(TInterfacedObject, IWebDriverCommands)
  private
    FHTTP: THTTPClient;
    FBaseUrl: string;
  public
    constructor Create(BaseURL : String);
    destructor Destroy; override;
    function SendCommand(const Method, Endpoint: string; Body: TJSONObject): TJSONValue;
  end;

implementation

{ TWebDriverCommands }

constructor TWebDriverCommands.Create(BaseURL: String);
begin
  inherited Create;
  FHTTP := THTTPClient.Create;
  FBaseUrl := BaseURL;
end;

destructor TWebDriverCommands.Destroy;
begin
  FHTTP.Free;
  inherited;
end;

function TWebDriverCommands.SendCommand(const Method, Endpoint: string; Body: TJSONObject): TJSONValue;
var
  LUrl: string;
  LResponse: IHTTPResponse;
  Stream: TStringStream;
begin
  LUrl := FBaseUrl + Endpoint;
  Stream := nil;
  try
    if Assigned(Body) then
      Stream := TStringStream.Create(Body.ToJSON, TEncoding.UTF8)
    else
      Stream := TStringStream.Create('{}', TEncoding.UTF8);

    if Method = 'POST' then
      LResponse := FHTTP.Post(LUrl, Stream)
    else if Method = 'DELETE' then
      LResponse := FHTTP.Delete(LUrl)
    else
      LResponse := FHTTP.Get(LUrl);

    Result := TJSONObject.ParseJSONValue(LResponse.ContentAsString);
    if not Assigned(Result) then
      raise EWebDriverError.Create
        ('Invalid JSON response received from WebDriver');
  finally
    Stream.Free;
  end;
end;

end.
