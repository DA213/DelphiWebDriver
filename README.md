# DelphiWebDriver

A modern, lightweight Delphi client (No third party) for the W3C WebDriver protocol (the same protocol used by Selenium). This library allows Delphi developers to automate browsers such as Chrome, Firefox, and Edge by communicating with their corresponding WebDriver executables.

---

## ✨ Features

* Create and manage WebDriver sessions
* Navigate to URLs
* Locate elements (`By.Id`, `By.Name`, `By.ClassName`, `By.CSS`, `By.XPath`...)
* Click elements, send keys, submit forms
* Take screenshots and save to file
* Wait for elements to appear or conditions to be true
* Manage cookies, frames
* Interface-based memory management for stability
* Cross-browser support (Chrome, Firefox, Edge) 
* headless mode support (Chrome, Firefox, Edge)
* And more cool stuff is coming...

---

## 📁 Project Structure

```
/DelphiWebDriver
  /Source
    DelphiWebDriver.Core.Capabilities.pas
    DelphiWebDriver.Core.Commands.pas
	DelphiWebDriver.Core.Contexts.pas
	DelphiWebDriver.Core.Cookies.pas
	DelphiWebDriver.Core.Document.pas
	DelphiWebDriver.Core.Elements.pas
	DelphiWebDriver.Core.Navigation.pas
	DelphiWebDriver.Core.pas	
	DelphiWebDriver.Core.Screenshot.pas
	DelphiWebDriver.Core.Sessions.pas
	DelphiWebDriver.Core.Wait.pas
	DelphiWebDriver.Element.pas
	DelphiWebDriver.Interfaces.pas
	DelphiWebDriver.Server.pas
	DelphiWebDriver.Types.pas
  /Demo
    DelphiWebDriverDemo.Main.pas
    DelphiWebDriverDemo.Main.fmx
  README.md
  LICENSE
```

> `Source/` contains the core library units
> `Demo/` contains a small FMX demo showing simple automation

---

## 🚀 Getting Started

### Requirements

* Delphi 10.2+ (or any recent version)
* Corresponding WebDriver binaries:  

  * ChromeDriver - Chrome (download from here https://developer.chrome.com/docs/chromedriver/downloads)
  * GeckoDriver - Firefox (download from here https://github.com/mozilla/geckodriver/releases)
  * MSEdgeDriver - Edge (download from here https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver)

Place the driver executable next to your application.

---

### Example Usage

```delphi
uses
  DelphiWebDriver.Core,
  DelphiWebDriver.Types,
  DelphiWebDriver.Server,
  DelphiWebDriver.Interfaces;

procedure TMainForm.StartDriverButtonClick(Sender: TObject);
var
  Server: TWebDriverServer;
  Driver: IWebDriver;
begin
  var DriverName := '';
  var BrowserName := '';
  if ChromeRadioButton.IsChecked then
    begin
      DriverName  := TWebDriverBrowser.Chrome.DriverName;
      BrowserName := TWebDriverBrowser.Chrome.Name;
    end;
  if FirefoxRadioButton.IsChecked then
    begin
      DriverName  := TWebDriverBrowser.Firefox.DriverName;
      BrowserName := TWebDriverBrowser.Firefox.Name;
    end;
  if EdgeRadioButton.IsChecked then
    begin
      DriverName  := TWebDriverBrowser.Edge.DriverName;
      BrowserName := TWebDriverBrowser.Edge.Name;
    end;

  if DriverName.IsEmpty then
    begin
      LogsMemo.Text := 'You must select driver';
      Exit;
    end;

  // if you have specific path for the driver path then set it with the DriverName
  // for ex : Server := TWebDriverServer.Create('C:\drivers_folder\' + DriverName);

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
```

---

## ⚡ Notes

* Use **interface variables** (`IWebDriver`, `IWebElement`) for safe automatic memory management.
* Avoid keeping element references after quitting the driver.
* `WaitUntilElement` supports **Id, Name, ClassName, CSS Selector, XPath**.
* `TWebDriverServer` helps start/stop ChromeDriver for your tests.

---

## 📜 License

MIT License

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

---

## 🐞 Issues

If you find a bug, please provide:

* Steps to reproduce
* Expected behavior
* Actual behavior
* Delphi version
* WebDriver and browser version

---

## 🗺️ Roadmap

* [x] Minimal viable implementation
* [x] Element location by CSS/XPath
* [x] Wait for elements and conditions
* [x] Click, send keys, submit forms
* [x] Wait for page to load
* [x] Screenshot support  
* [x] Cross-browser (Chrome, Firefox, Edge)
* [x] Cookie management
* [x] Frame 
* [x] JavaScript execution
* [x] handling headless mode
* [ ] Full WebDriver command coverage
