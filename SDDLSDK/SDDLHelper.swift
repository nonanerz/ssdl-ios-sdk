import Foundation

public enum SDDLHelper {
    public static func resolve(
        _ url: URL? = nil,
        onSuccess: @escaping ([String: Any]) -> Void,
        onError: @escaping (String) -> Void = { _ in },
        readClipboard: Bool = true
    ) {
        SDDLSDKManager.fetchDetails(
            from: url,
            readClipboard: readClipboard,
            onSuccess: { payload in
                onSuccess(payload)
            },
            onError: { message in
                DispatchQueue.main.async { onError(message) }
            }
        )
    }
}
