# Stargate

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Version](https://img.shields.io/github/release/kylejm/Stargate.svg)](https://github.com/kylejm/Stargate/releases)

Attempting to make deeplinking and handling notifications (remote and local) on iOS with Swift, simpler. Work in progress.

## Usage

In `AppDelegate.swift`:


DeepLink:

```swift
func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
  return Router.handleDeepLink(url: url, sourceApplication: sourceApplication, annotation: annotation)
}
```

Notification:

```swift
func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
  // Called when foreground or background but not suspended
  Router.handleNotification(userInfo)
  completionHandler(.NoData)
}
```

<br>
<br>
### Registering for DeepLink:

``` swift
// Matches myapp://cool/ass/stuff
Router.setRoute(Route(regex: "cool/ass/stuff", callback: .DeepLink(self.routerCallback)))

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

<br>
<br>
### Registering for a Notification:

Pretty much the same as DeepLink.

```swift
Router.setRoute(Route(regex: "^cool_ass_stuff$", callback: .Notification(self.routerCallback)))
```

This would be called for this notification:

```json
{
  "aps": {
    "alert": "message"
    "sound": "default"
    "badge": "1"
    "notification_id": "cool_ass_stuff"
  }
}
```

The regex is compared on a string in the notification payload. By default the key for this string is `"notification_id"`. You can change this by:

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
  Router.setNotificationKey("your_key")
}
```

Params passed to `routerCallback`:

```swift
public typealias NotificationParams = [NSObject : AnyObject]
```

<br>
<br>
### Warning!

Remember to remove your callback when your object get's `deinit`ed:

```swift
let notificationRouteRegex = "^cool_ass_stuff$"

deinit {
  Router.unsetRoute(self.notificationRouteRegex)
}
```

<br>
## The delegate

If your ViewController or object that you'd like to handle the `Route` does not exist at the time of the deep link being opened, you can have a delegate that will definately be around (AppDelegate for example) catch the `Route` and do any setup, like, for example, instantiate a ViewController and re-setup its views then call it's `RouteCallback`.

You can also use the delegate to setup view heriarchy when a ViewController exists but its view is not on the screen. To do this just return `false` in the `RouterCallback`, like in the example above, which will cause the `DeepLinkRouter` to call the delegate. The delegate gets passed the `Route`, therefore it knows which ViewController to get on screen.

## Todo

- [x] Some kind of regex thing for router string
- [x] Fix delegate pointer strength 

## Authors

- [Kyle McAlpine](http:kylejm.io)
- [Daniel Tomlinson](http://danie.lt)
