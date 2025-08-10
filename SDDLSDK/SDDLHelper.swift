import Foundation

public enum SDDLHelper {
    public static func resolve(
        _ url: URL? = nil,
        onSuccess: @escaping ([String: Any]) -> Void,
        onError: @escaping (String) -> Void = { _ in }
    ) {
        SDDLSDKManager.fetchDetails(
            from: url,
            onSuccess: { payload in
                onSuccess(payload)
            },
            onError: { message in
                DispatchQueue.main.async { onError(message) }
            }
        )
    }
}