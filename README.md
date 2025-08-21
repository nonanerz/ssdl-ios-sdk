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
  pod 'SDDLSDK', '~> 2.0.5' # replace with the latest release version
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

## Clipboard Reading (Optional)

The SDK can optionally read a **key** from the system clipboard on cold start and resolve it. This helps resolve the link more reliably.

- **Enabled by default**.
- Can be disabled at call site with `readClipboard: false`.
- When disabled and no URL is provided, the SDK uses a fallback.


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
                                   onError: handleError(_:)),
                                   readClipboard: false, // URL provided; clipboard not needed

            }
            // 2) Universal Link via NSUserActivity
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                SDDLHelper.resolve(activity.webpageURL,
                                   onSuccess: handlePayload(_:),
                                   onError: handleError(_:)),

            }
            // 3) Cold start (no URL at launch)
            .onAppear {
                // Choose whether to use clipboard on cold start
                SDDLHelper.resolve(nil,
                                   onSuccess: handlePayload(_:),
                                   onError: handleError(_:)),
                                   readClipboard: true,  // set to false to disable clipboard

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
                           onError:   { err in /* handle */ }),
                           readClipboard: false

    }
}

func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    if let url = URLContexts.first?.url {
        SDDLHelper.resolve(url,
                           onSuccess: { payload in /* route */ },
                           onError:   { err in /* handle */ }),
                           readClipboard: false

    }
}

// Cold start (no URL yet)
func sceneDidBecomeActive(_ scene: UIScene) {
    SDDLHelper.resolve(nil,
                       onSuccess: { payload in /* route */ },
                       onError:   { err in /* handle */ }),
                       readClipboard: true  // or false to avoid clipboard access

}
```

---

## Behaviour Summary

| Situation                                  | Parameter               | Result                                                                              |
| ------------------------------------------ | ----------------------- | ----------------------------------------------------------------------------------- |
| Universal Link delivered (URL available)   | `readClipboard` ignored | Resolve `/{key}/details` from URL (if key present); else fallback to `/try/details` |
| Cold start, no URL, clipboard **enabled**  | `readClipboard: true`   | If clipboard has a valid key → `/{key}/details`; else `/try/details`                |
| Cold start, no URL, clipboard **disabled** | `readClipboard: false`  | Directly call `/try/details`                                                        |

---

## Troubleshooting

- If Universal Links do not trigger, re-check Associated Domains and that your AASA file is accessible and valid: [https://app-site-association.cdn-apple.com/a/v1/your.custom.domain](https://app-site-association.cdn-apple.com/a/v1/your.custom.domain)
- Ensure the clipboard contains a **plain key** when relying on clipboard resolution.

---

## License

MIT

Powered by [sddl.me](https://sddl.me) — deep linking API.

