import Foundation

public enum SDDLHelper {
    public static func resolve(
        url: URL? = nil,
        activity: NSUserActivity? = nil,
        onSuccess: @escaping ([String: Any]) -> Void,
        onError: @escaping (String) -> Void = { _ in }
    ) {
        let ul: URL? = {
            if let u = url { return u }
            if activity?.activityType == NSUserActivityTypeBrowsingWeb {
                return activity?.webpageURL
            }
            return nil
        }()

        SDDLSDKManager.fetchDetails(from: ul, onSuccess: onSuccess, onError: onError)
    }
}