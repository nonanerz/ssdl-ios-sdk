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
  pod 'SDDLSDK', '~> 1.2.1'
end
```

> Replace `1.2.1` with the latest release version.

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
###  **Use developer mode while developing**

```plaintext
applinks:{YOUR ID}.sddl.me?mode=developer
```

---

## 🧑‍💻 **Usage Example**

### **ContentView.swift:**

```swift
import SwiftUI
import SDDLSDK

struct ContentView: View {
    @State private var result: String = "Waiting for Universal Link..."

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .font(.largeTitle)

            Text(result)
                .padding()
                .foregroundColor(.blue)
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
            if let incomingURL = userActivity.webpageURL {
                handleDeepLink(incomingURL)
            }
        }
        .onAppear {
            handleDeepLink(nil)
        }
        .padding()
    }

    private func handleDeepLink(_ url: URL?) {

        SDDLSDKManager.fetchDetails(from: url) { data in
            if let json = data as? [String: Any] {
                result = "Data: \(json)"
            } else {
                result = "Failed to fetch data"
            }
        }
    }
}

#Preview {
    ContentView()
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

For more details, visit [GitHub Repository](https://github.com/nonanerz/sddl-ios-sdk).

