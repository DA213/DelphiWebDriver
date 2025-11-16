# DelphiWebDriver

A modern, lightweight Delphi client for the W3C WebDriver protocol (the same protocol used by Selenium). This library allows Delphi developers to automate browsers such as Chrome, Firefox, and Edge by communicating with their corresponding WebDriver executables.

---

## ✨ Features

* Create and manage WebDriver sessions
* Navigate to URLs
* Locate elements (`By.Id`, `By.Name`, `By.ClassName`, `By.CSS`, `By.XPath`)
* Click elements, send keys, submit forms
* Take screenshots and save to file
* Wait for elements to appear or conditions to be true
* Manage cookies, frames
* Interface-based memory management for stability
* Cross-browser support (Chrome only for now)
* And more cool stuff is coming...

---

## 📁 Project Structure

```
/DelphiWebDriver
  /Source
    DelphiWebDriver.Core.pas
    DelphiWebDriver.Element.pas
    DelphiWebDriver.Interfaces.pas
    DelphiWebDriver.Types.pas
    DelphiWebDriver.Capabilities.pas
    DelphiWebDriver.Server.pas
    DelphiWebDriver.Cookies.pas
  /Demo
    DelphiWebDriverDemo.Main.pas
    DelphiWebDriverDemo.Main.fmx
  README.md
  LICENSE
```

> `Source/` contains the core library units
> `Demo/` contains a small FMX demo showing Chrome automation

---

## 🚀 Getting Started

### Requirements

* Delphi 10.2+ (or any recent version)
* Corresponding WebDriver binaries:

  * ChromeDriver (download from here https://developer.chrome.com/docs/chromedriver/downloads)

Place the driver executable in your PATH or next to your application.

---

### Example Usage

```delphi
uses
  DelphiWebDriver.Core,
  DelphiWebDriver.Types,
  DelphiWebDriver.Capabilities,
  DelphiWebDriver.Server,
  DelphiWebDriver.Interfaces;

procedure TMainForm.StartChromeButtonClick(Sender: TObject);
var
  Server: TWebDriverServer;
  Driver: IWebDriver;
  Caps: TWebDriverCapabilities;
  TranslateBox: IWebElement;
begin
  Server := TWebDriverServer.Create('chromedriver.exe');
  try
    Server.Start; // launch ChromeDriver

    Driver := TWebDriver.Create('http://localhost:9515');
    try
      Caps := TWebDriverCapabilities.Create;
      try
        Caps.BrowserName := 'chrome';
        Driver.StartSession(Caps);
      finally
        Caps.Free;
      end;

      Driver.Navigate('https://translate.google.com/');

      // Wait for translate box and send text
      TranslateBox := Driver.WaitUntilElement(TBy.XPath('//*[@id="yDmH0d"]/c-wiz/div/div[2]/c-wiz/div[2]/c-wiz/div[1]/div[2]/div[2]/div/c-wiz/span/span/div/textarea'));
      TranslateBox.SendKeys('Hello from DelphiWebDriver!');

      // Take screenshot
      Driver.SaveScreenshotToFile('screenshot.png');

    finally
      Driver.Quit;
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
* [x] Cookie management
* [x] Frame handling
* [x] JavaScript execution
* [ ] Full WebDriver command coverage
