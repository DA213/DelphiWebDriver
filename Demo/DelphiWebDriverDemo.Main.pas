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
  var Browser : TWebDriverBrowser;
  if ChromeRadioButton.IsChecked then
    Browser := TWebDriverBrowser.wdbChrome;
  if FirefoxRadioButton.IsChecked then
    Browser := TWebDriverBrowser.wdbFirefox;
  if EdgeRadioButton.IsChecked then
    Browser := TWebDriverBrowser.wdbEdge;

  if Browser = wdbUnknown then
    begin
      LogsMemo.Text := 'You must select driver';
      Exit;
    end;

  // if you have specific path for the driver path then set it with the Browser.DriverName
  // for ex : Server := TWebDriverServer.Create('C:\drivers_folder\' + Browser.DriverName);

  Server := TWebDriverServer.Create(Browser.DriverName);
  try
    Server.Start;
    Driver := TWebDriver.Create(Browser, 'http://localhost:9515');
    try
      Driver.Capabilities.Headless := HeadlessModeCheckBox.IsChecked;
      Driver.Sessions.StartSession;
      Driver.Navigation.GoToURL('https://translate.google.com');
      Driver.Wait.UntilPageLoad;


      Driver.Actions.MoveToElement(TBy.ClassName('er8xn')).Click
                                                          .SendKeys('DelphiWebDriver Is Here')
                                                          .Perform;

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
