<h1 align="center">Stargate</h1>
<p align="center">
    <a href="https://developer.apple.com/swift/" ><img src="https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat"></a>
    <img src="https://img.shields.io/badge/platform-iOS%208%2B-c775df.svg?style=flat" alt="Platform: iOS 8+">
    <a href="https://github.com/kylejm/Stargate/releases"><img src="https://img.shields.io/github/release/kylejm/Stargate.svg"></a>
    <a href="https://travis-ci.org/kylejm/Stargate"><img src="https://travis-ci.org/kylejm/Stargate.svg?branch=master"></a>
    <a href="https://codecov.io/github/kylejm/Stargate?branch=master"><img src="https://codecov.io/github/kylejm/Stargate/coverage.svg?branch=master"></a>
    <img src="https://img.shields.io/badge/package%20managers-Carthage-yellow.svg">

    <br>
    <br>

    Attempting to make deeplinking and handling push notifications on iOS with Swift simpler. Work in progress.

</p>


## Usage

In your App Delegate:


DeepLink:

```swift
func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    let deepLink = DeepLink(url: url, sourceApplication: sourceApplication, annotation: annotation)
    return Router.handleDeepLink(deepLink)
}
```

PushNotification:

```swift
func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
  // Called when foreground or background but not suspended
  Router.handlePushNotification(userInfo)
  completionHandler(.NoData)
}
```

<br>
### Registering for DeepLink:

``` swift
class MyViewController: UIViewController, DeepLinkCatcher {
	static let deepLinkRegex = "myapp:\\/\\/cool\\/ass\\/stuff" // Matches myapp://cool/ass/stuff

	override func viewDidLoad() {
		super.viewDidLoad()
        Router.setDeepLinkCatcher(self , forRegex: self.dynamicType.deepLinkRegex)
	}

	func catchDeepLink(deepLink: DeepLink) -> Bool {
		if self.view.window != nil {
    		// View is on screen
    		// Do some rad crap
    		return true
  		}

		// Returning false will make DeepLinkRouter call delegate (if there is one, of course)
		return false
    }
}
```

`DeepLink`:
```swift
@objc public class DeepLink: NSObject, Regexable {
    let url: NSURL
    let sourceApplication: String?
    let annotation: AnyObject

    public init(url: NSURL, sourceApplication: String?, annotation: AnyObject) {
        self.url = url
        self.sourceApplication = sourceApplication
        self.annotation = annotation
    }

    public func matchesRegex(regex: Regex) -> Bool {
        let link = self.url.absoluteString
        let regex = try? NSRegularExpression(pattern: regex, options: .CaseInsensitive)
        let numberOfMatches = regex?.numberOfMatchesInString(link, options: [], range: NSMakeRange(0, link.characters.count))
        return numberOfMatches > 0
    }
}
```

<br>
### Registering for a Push Notification:

Pretty much the same as DeepLink.

```swift
class MyViewController: UIViewController, PushNotificationCatcher {
	static let notificationRegex = "myapp:\\/\\/^cool_ass_stuff$" // Matches myapp://cool/ass/stuff

	override func viewDidLoad() {
		super.viewDidLoad()
		Router.setPushNotificationCatcher(self, forRegex: self.dynamicType.notificationRegex)
	}

	func catchPushNotification(pushNotification: PushNotification) {
		// Do stuff
    }
}
```

This would be called for this notification:

```json
{
  "aps": {
    "alert": "message",
    "sound": "default",
    "badge": "1",
    "notification_id": "cool_ass_stuff"
  }
}
```

The regex is compared on a string in the notification payload. By default the key for this string is `"notification_id"`. You can change this by:

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
  PushNotification.setDefaultPushNotificationKey("your_key")
}
```

`PushNotification`:
```swift
public typealias PushNotificationPayload = [NSObject : AnyObject]
@objc public class PushNotification: NSObject, Regexable {
    public let payload: PushNotificationPayload

    public init(payload: PushNotificationPayload) {
        self.payload = payload
    }

    public static func setDefaultPushNotificationKey(key: String) { defaultPushNotificationKey = key }

    public func matchesRegex(regex: Regex) -> Bool {
        if let payload = self.payload["aps"] as? [NSObject : AnyObject], notification = payload[defaultPushNotificationKey] as? String {
            let regex = try? NSRegularExpression(pattern: regex, options: .CaseInsensitive)
            let numberOfMatches = regex?.numberOfMatchesInString(notification, options: [], range: NSMakeRange(0, notification.characters.count))
            return numberOfMatches > 0
        }
        return false
    }
}
```


#### Closure handlers

You can also just provide a closure if you'd prefer, just make sure you manage memory properly (e.g. use `[weak self]`).

```swift
let deepLinkClosure = DeepLinkClosureCatcher(callback: { deepLink -> Bool in [weak self]
    // do some stuff
    return true
})
Router.setDeepLinkCatcher(deepLinkClosure, forRegex: "^cool_ass_stuff$")

let notificationClosure = PushNotificationClosureCatcher(callback: { notification in [weak self]
    // do some stuff
})
Router.setPushNotificationCatcher(notificationClosure, forRegex: "^cool_ass_stuff$")
```

<br>
### :warning: Memory management :warning:

You can decide whether Stargate keeps a strong or a weak reference to your Catcher. With closures you likely want to choose Strong.

Stargate achieves this by using NSMapTable.

<br>
## The delegate

If your ViewController or object that you'd like to handle the `DeepLink` and/or `PushNotification` does not exist at the time of the `DeepLink` or `PushNotification` being opened, you can have a delegate, that will definitely be around (AppDelegate for example), catch the it and do any setup, like, for example, instantiate a ViewController and re-setup its views then call it's `catch` method.

With `DeepLink`s you can also use the delegate to setup the view hierarchy when a ViewController exists but its view is not on screen. To do this just return `false` in the callback, like in the example above, which will cause the `Router` to call its delegate. The delegate gets passed the `DeepLink`, therefore it knows which ViewController to get on screen.

Example:

```swift
func catchDeepLink(deepLink: DeepLink) -> Bool {
    if deepLink.matchesRegex("^some/rad/shit$") {
        // Show a view controller or something
        return true
    }
    return false
}
```

## Todo

- [x] Some kind of regex thing for router string
- [x] Fix delegate pointer strength
- [ ] Replace NSMapTable with Swift implementation and then
- [ ] Refactor code duplication in Router for setting and removing catchers

## Authors

- [Kyle McAlpine](http:kylejm.io)
- [Daniel Tomlinson](http://danie.lt)
