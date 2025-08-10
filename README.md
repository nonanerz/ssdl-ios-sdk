# SDDL iOS SDK

This is the official iOS SDK for SDDL, providing seamless integration with deferred deep links using **Universal Links** and **Custom URI Schemes**.

---

## 🚀 **Integration Steps**

### 📦 **Add CocoaPods Dependency**
Add the SDDLSDK dependency to your `Podfile`:

```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
  pod 'SDDLSDK', '~> 2.0.0'
end
```

> Replace `2.0.0` with the latest release version.

Then, run:

```sh
pod install
```

---

## 📲 **App Links Setup**

### 🔍 **Configure Associated Domains in Xcode:**

1. Go to **Target > Signing & Capabilities > + Capability**.
2. Add **Associated Domains**.
3. Add the following domain:

```plaintext
applinks:{YOUR ID}.sddl.me
```
or
```plaintext
applinks:{your.custom.domain}
```

---

## 🧑‍💻 **Usage Example**

### **ContentView.swift:**

```swift
import UIKit
import SDDLSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        let url = connectionOptions.urlContexts.first?.url
            ?? connectionOptions.userActivities.first?.webpageURL

        SDDLHelper.resolve(from: url,
                           onSuccess: route(with:),
                           onError: handleDeepLinkError(_:))
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        SDDLHelper.resolve(from: userActivity,
                           onSuccess: route(with:),
                           onError: handleDeepLinkError(_:))
    }

    private func route(with payload: [String: Any]) {
        // do stuff
    }

    private func handleDeepLinkError(_ error: String) {
        // handle Error
    }
}
```

### Note:
    
#### If no URL is available at launch, pass nil as the argument to handleDeepLink(_:) so that the SDK can handle deferred deep links appropriately.

---

## 🔗 **Custom URI Scheme Support**

1. Open **Info.plist**.
2. Add a new **URL types** entry:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>mycustomscheme</string>
        </array>
    </dict>
</array>
```

---

## 📄 **License**
This SDK is licensed under the MIT License.

Powered by [sddl.me](https://sddl.me) — deep linking API.
