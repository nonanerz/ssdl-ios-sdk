# SDDL iOS SDK

Official iOS SDK for SDDL. Integrates deferred deep links via **Universal Links** (and optional custom URL schemes).

---

## Integration Steps

### Add CocoaPods Dependency
Add the `SDDLSDK` dependency to your `Podfile`:

```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
  pod 'SDDLSDK', '~> 2.0.4' # replace with the latest release version
end
```

Then run:

```bash
pod install
```

Open the generated `.xcworkspace`.

---

## App Links Setup

### Configure Associated Domains in Xcode

1. Go to **Target → Signing & Capabilities → + Capability**.
2. Add **Associated Domains**.
3. Add one of the following entries (depending on your setup):

```text
applinks:{YOUR_ID}.sddl.me
```

or

```text
applinks:{your.custom.domain}
```

> Ensure Associated Domains are verified (no capability warnings) and your AASA file is reachable.

---

## Usage (SwiftUI)

Minimal integration covering three entry points:

- `onOpenURL` – Universal Link delivered directly.
- `onContinueUserActivity` – Universal Link delivered via `NSUserActivity`.
- `onAppear` – cold start when no URL is available at launch.

```swift
import SwiftUI
import SDDLSDK

struct ContentView: View {
    var body: some View {
        Color.clear
            // 1) Opened via Universal Link (URL provided by the system)
            .onOpenURL { url in
                SDDLHelper.resolve(url,
                                   onSuccess: handlePayload(_:),
                                   onError: handleError(_:))
            }
            // 2) Universal Link via NSUserActivity
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                SDDLHelper.resolve(activity.webpageURL,
                                   onSuccess: handlePayload(_:),
                                   onError: handleError(_:))
            }
            // 3) Cold start (no URL at launch)
            .onAppear {
                SDDLHelper.resolve(nil,
                                   onSuccess: handlePayload(_:),
                                   onError: handleError(_:))
            }
    }
}

private func handlePayload(_ payload: [String: Any]) {
    // Navigate to the correct screen using values from payload
    print("SDDL payload:", payload)
}

private func handleError(_ error: String) {
    // Optional: log or show a non-blocking message
    print("SDDL error:", error)
}
```

> Import `SDDLSDK` in files where you call `SDDLHelper.resolve(...)`.

---

## Usage (UIKit) – optional

If you use UIKit lifecycle, pass the received URL to the same helper:

```swift
// SceneDelegate.swift
func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let url = userActivity.webpageURL {
        SDDLHelper.resolve(url,
                           onSuccess: { payload in /* route */ },
                           onError:   { err in /* handle */ })
    }
}

func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    if let url = URLContexts.first?.url {
        SDDLHelper.resolve(url,
                           onSuccess: { payload in /* route */ },
                           onError:   { err in /* handle */ })
    }
}

// Cold start (no URL yet)
func sceneDidBecomeActive(_ scene: UIScene) {
    SDDLHelper.resolve(nil,
                       onSuccess: { payload in /* route */ },
                       onError:   { err in /* handle */ })
}
```
---

## Troubleshooting
- If Universal Links do not trigger, re-check Associated Domains and that your AASA file is accessible and valid. https://app-site-association.cdn-apple.com/a/v1/your.custom.domain

---

## License

MIT

Powered by [sddl.me](https://sddl.me) — deep linking API.

