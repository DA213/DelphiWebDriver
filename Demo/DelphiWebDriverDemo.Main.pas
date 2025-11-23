unit DelphiWebDriverDemo.Main;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo;

type
  TMainForm = class(TForm)
    StartDriverButton: TButton;
    DriversRectangle: TRectangle;
    ChromeRadioButton: TRadioButton;
    FirefoxRadioButton: TRadioButton;
    EdgeRadioButton: TRadioButton;
    LogsMemo: TMemo;
    HeadlessModeCheckBox: TCheckBox;
    OperaRadioButton: TRadioButton;
    BraveRadioButton: TRadioButton;
    ProxyCheckBox: TCheckBox;
    procedure StartDriverButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  DelphiWebDriver.Core,
  DelphiWebDriver.Types,
  DelphiWebDriver.Server,
  DelphiWebDriver.Interfaces;

{$R *.fmx}

procedure TMainForm.StartDriverButtonClick(Sender: TObject);
var
  Server: TWebDriverServer;
  Driver: IWebDriver;
  BrowserConfig : TWebDriverBrowserConfig;
begin
  if ChromeRadioButton.IsChecked then
    BrowserConfig.Browser := wdbChrome;
  if FirefoxRadioButton.IsChecked then
    BrowserConfig.Browser := wdbFirefox;
  if EdgeRadioButton.IsChecked then
    BrowserConfig.Browser := wdbEdge;
  if OperaRadioButton.IsChecked then
    begin
      // for opera you have to set the opera binary file path
      BrowserConfig.Browser := wdbOpera;
      BrowserConfig.BinaryPath := 'C:\Users\<YOUR USERNAME>\AppData\Local\Programs\Opera\opera.exe';
    end;
  if BraveRadioButton.IsChecked then
    begin
      // for brave you have to set the brave binary file path + you should use the ChromeDriver binary
      BrowserConfig.Browser := wdbBrave;
      BrowserConfig.BinaryPath := 'C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe';
    end;

  if BrowserConfig.Browser = wdbUnknown then
    begin
      LogsMemo.Text := 'You must select a driver';
      Exit;
    end;

  // if you have specific path for the driver path then set it with the BrowserConfig.Browser.DriverName
  // for ex : Server := TWebDriverServer.Create('C:\drivers_folder\' + BrowserConfig.Browser.DriverName);

  Server := TWebDriverServer.Create(BrowserConfig.Browser.DriverName);
  try
    Server.Start;
    Driver := TWebDriver.Create(BrowserConfig, 'http://localhost:9515');
    try
      Driver.Capabilities.Headless := HeadlessModeCheckBox.IsChecked;

      var Proxy : TWebDriverProxy;
      Proxy.Host := '';
      Proxy.Port := 8080;
      Proxy.Username := '';
      Proxy.Password := '';
      Proxy.EnableProxy := ProxyCheckBox.IsChecked;  // Fill proxy data and set "Proxy.EnableProxy" to True if you want to enable proxy

      Driver.Capabilities.Proxy := Proxy;
      Driver.Sessions.StartSession;
      Driver.Navigation.GoToURL('https://api.myip.com');
      Driver.Wait.UntilPageLoad;

      LogsMemo.Text := Driver.Document.GetBodyElement.GetText;

      ShowMessage('Msg Sent :)');

    finally
      Driver.Sessions.Quit;
    end;
  finally
    Server.Stop;
    Server.Free;
  end;

end;

end.
