# Stargate
Attempting to make deep linking in iOS with Swift, simpler. Work in progress.

## Usage

In `AppDelegate.swift`:

``` swift
func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
  return DeepLinkRouter.handleDeepLink(url: url, sourceApplication: sourceApplication, annotation: annotation)
}
```

Registering for deep link:

``` swift
// Matches myapp://cool/ass/stuff
DeepLinkRouter.setCallback(self.routerCallback, forRoute: "cool/ass/stuff")

func routerCallback(params: DeepLinkParams) -> Bool {
  if self.view.window != nil {
    // View is on screen
    // Do some rad crap
    return true
  } else {
    // Returning false will make DeepLinkRouter call delegate (if there is one, of course)
    return false
  }
}
```

`DeepLinkParams`:
```swift
typealias DeepLinkParams = (url: NSURL, sourceApplication: String?, annotation: AnyObject?)
```
## The delegate

If your ViewController or object that you'd like to handle the deep link does not exist at the time of the deep link being opened, you can have a delegate that will definately be around (AppDelegate for example) catch the deep link and do any setup, like instantiate the ViewController and re-setup its views, for the ViewController or object to handle it.

You can also use the delegate to setup view heriarchy when a ViewController exists but its view is not on the screen. To do this just return `false` in the `RouterCallback`, like in the example above, which will cause the `DeepLinkRouter` to call the delegate. The delegate gets passed the url, therefore it knows which ViewController to get on screen.

## Todo

- [ ] Make delegate pointer, weak (means moving to instance functions)
- [ ] Some kind of regex thing for router string
- 

## Authors

- [Kyle McAlpine](http:kylejm.io)
- [Daniel Tomlinson](http://danie.lt)
