# Delphi WebDriver

A modern, lightweight Delphi client for the W3C WebDriver protocol (the same protocol used by Selenium). This library allows Delphi developers to automate browsers such as Chrome, Firefox, and Edge by communicating with their corresponding WebDriver executables.

## ✨ Features (Planned)

* Create and manage WebDriver sessions
* Navigate to URLs
* Locate elements (By.Id, By.Name, By.CSS, By.XPath...)
* Click elements, send keys, submit forms
* Execute JavaScript
* Take screenshots
* Basic wait utilities
* Cross-browser support (Chrome, Firefox, Edge)

## 📁 Project Structure

```
/DelphiWebDriver
  /src
    WebDriver.Core.pas
    WebDriver.Chrome.pas
    WebDriver.Firefox.pas
    WebDriver.Edge.pas
    WebDriver.Element.pas
    WebDriver.JSON.pas
  /examples
    SimpleGoogleSearch
  README.md
  LICENSE
```

## 🚀 Getting Started

### Requirements

* Delphi 10.2+ (any recent version should work)
* Corresponding WebDriver binaries:

  * ChromeDriver
  * GeckoDriver
  * EdgeDriver

Place the driver executable in your PATH or next to your application.

### Example Usage

```delphi
var
  Driver: TChromeDriver;
  SearchBox: TWebElement;
begin
  Driver := TChromeDriver.Create;
  try
    Driver.Start;
    Driver.Get('https://www.google.com');

    SearchBox := Driver.FindElement(By.Name('q'));
    SearchBox.SendKeys('Delphi WebDriver');
    SearchBox.Submit;

  finally
    Driver.Quit;
    Driver.Free;
  end;
end;
```

## 📜 License

MIT License (recommended)

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

## 🐞 Issues

If you find a bug, please open an issue with:

* Steps to reproduce
* Expected behavior
* Actual behavior
* Delphi version
* WebDriver and browser version

## 🗺️ Roadmap

* [ ] Minimal viable implementation
* [ ] Full WebDriver command coverage
* [ ] Better error handling
* [ ] Async command support
* [ ] Unit testing suite
* [ ] Package for Delphi IDE
