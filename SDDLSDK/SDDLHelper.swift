import Foundation
#if canImport(UIKit)
import UIKit
#endif

public enum SDDLHelper {
    public static func resolve(
        from url: URL?,
        onSuccess: @escaping ([String: Any]) -> Void,
        onError: @escaping (String) -> Void = { _ in }
    ) {
        SDDLSDKManager.fetchDetails(from: url, onSuccess: onSuccess, onError: onError)
    }

    #if canImport(UIKit)
    public static func resolve(
        from userActivity: NSUserActivity?,
        onSuccess: @escaping ([String: Any]) -> Void,
        onError: @escaping (String) -> Void = { _ in }
    ) {
        let url = (userActivity?.activityType == NSUserActivityTypeBrowsingWeb)
            ? userActivity?.webpageURL
            : nil
        resolve(from: url, onSuccess: onSuccess, onError: onError)
    }
    #endif
}