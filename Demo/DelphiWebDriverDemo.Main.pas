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
begin
  var DriverName := '';
  var BrowserName := '';
  if ChromeRadioButton.IsChecked then
    begin
      DriverName  := TBrowser.Chrome.DriverName;
      BrowserName := TBrowser.Chrome.Name;
    end;
  if FirefoxRadioButton.IsChecked then
    begin
      DriverName  := TBrowser.Firefox.DriverName;
      BrowserName := TBrowser.Firefox.Name;
    end;
  if EdgeRadioButton.IsChecked then
    begin
      DriverName  := TBrowser.Edge.DriverName;
      BrowserName := TBrowser.Edge.Name;
    end;

  if DriverName.IsEmpty then
    begin
      LogsMemo.Text := 'You must select driver';
      Exit;
    end;

  Server := TWebDriverServer.Create(DriverName);
  try
    Server.Start;
    Driver := TWebDriver.Create('http://localhost:9515');
    try
      Driver.Capabilities.BrowserName := BrowserName;
      Driver.Capabilities.Headless := HeadlessModeCheckBox.IsChecked;
      // Optional
      // Driver.Capabilities.Args.Add('--disable-gpu');
      // Driver.Capabilities.Args.Add('--window-size=1920,1080');
      Driver.Sessions.StartSession;
      Driver.Navigation.Navigate('https://www.google.com');
      Driver.Wait.WaitUntilPageLoad;
      LogsMemo.Text := Driver.Document.GetPageSource;
      Driver.Screenshot.SaveScreenshotToFile('Screenshot.png');
    finally
      Driver.Sessions.Quit;
    end;
  finally
    Server.Stop;
    Server.Free;
  end;

end;

end.
