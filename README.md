# SDDL iOS SDK

This is the official iOS SDK for SDDL, providing seamless integration with deferred deep links using **Universal Links** and **Custom URI Schemes**.

---

## 🚀 **Integration Steps**

### 📦 **Step 1: Add CocoaPods Dependency**
Add the SDDLSDK dependency to your `Podfile`:

```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
  pod 'SDDLSDK', '~> 1.1.1'
end
```

> Replace `1.1.1` with the latest release version.

Then, run:

```sh
pod install
```

---

## 📲 **App Links Setup**

### 🔍 **1. Configure Associated Domains in Xcode:**

1. Go to **Target > Signing & Capabilities > + Capability**.
2. Add **Associated Domains**.
3. Add the following domain:

```plaintext
applinks:sddl.me
```
###  **Use developer mode while developing**

```plaintext
applinks:sddl.me?mode=developer
```

---

### 🌐 **2. Configure App ID in Apple Developer Console:**

1. Navigate to **Certificates, Identifiers & Profiles** > **Identifiers**.
2. Select the **App ID** associated with your **Bundle Identifier**.
3. Enable **Associated Domains**.
4. Regenerate and download the **Provisioning Profile**.
5. Ensure the profile is updated in **Xcode**.

---

The response should be **HTTP/2 200** with **content-type: application/json**.

---

## 🧑‍💻 **Usage Example** (SwiftUI Only)

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
        .onAppear {
            handleDeepLink(nil) // Check for deferred deep link when app starts
        }
        .padding()
    }

    /// Handles incoming deep links and deferred deep links
    private func handleDeepLink(_ url: URL?) {
        // Fetch deep link details from SDDLSDKManager
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

