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
  pod 'SDDLSDK', '~> 2.0.1'
end
```

> Replace `2.0.1` with the latest release version.

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
import SwiftUI
import SDDLSDK

struct ContentView: View {
    var body: some View {
        Color.clear
            .onOpenURL { url in
                SDDLHelper.resolve(from: url,
                                   onSuccess: handlePayload(_:),
                                   onError: handleError(_:))
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                SDDLHelper.resolve(from: activity,
                                   onSuccess: handlePayload(_:),
                                   onError: handleError(_:))
            }
            .onAppear {
                SDDLHelper.resolve(from:nil, onSuccess: handlePayload(_:), onError: handleError(_:))
            }
    }
}

private func handlePayload(_ payload: [String: Any]) {
    print("SDDL payload:", payload)
}
private func handleError(_ error: String) {
    print("SDDL error:", error)
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
