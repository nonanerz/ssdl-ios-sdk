# SDDL iOS SDK

This is the official iOS SDK for SDDL, providing seamless integration with deferred deep links.

## Integration with CocoaPods

### Step 1: Add CocoaPods Dependency
Add the SDDLSDK dependency to your `Podfile`:

```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
  pod 'SDDLSDK', '~> 1.0.16'
end
```

> Replace `1.0.16` with the latest release version.

Then, run:

```sh
pod install
```

## Usage

### Initialize SDK in SwiftUI App
In your `ContentView.swift`:

```swift
import SwiftUI
import SDDLSDK

struct ContentView: View {
    @State private var result: String = "Get data"
    @State private var incomingURL: URL?

    var body: some View {
        VStack {
            Text(result)
                .padding()

            Button("Fetch Data from SDDLSDK") {
                SDDLSDKManager.fetchDetails(from: incomingURL) { data in
                    if let json = data as? [String: Any] {
                        result = "Data: \(json)"
                    } else {
                        result = "Failed to fetch data"
                    }
                }
            }
            .padding()
        }
        .onOpenURL { url in
            incomingURL = url
        }
    }
}

#Preview {
    ContentView()
}
```

### Custom URI Scheme Support
Add your custom URI scheme to your Xcode project:

1. Open `Info.plist`.
2. Add a new `URL types` entry.
3. Set the `URL identifier` and `URL Schemes` to your desired scheme (e.g., `mycustomscheme`).

## License
This SDK is licensed under the MIT License.

---

For more details, visit [GitHub Repository](https://github.com/nonanerz/ssdl-ios-sdk).

