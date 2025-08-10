import Foundation
#if canImport(UIKit)
import UIKit
#endif

public enum SDDLError: Error {
    case invalidJSON(String)
    case http(Int)
    case network(String)
}

public final class SDDLSDKManager {

    // MARK: - Public API
    public static func fetchDetails(
        from url: URL? = nil,
        onSuccess: @escaping ([String: Any]) -> Void,
        onError: @escaping (String) -> Void = { _ in }
    ) {
        // single-flight guard
        lock.sync {
            if resolving { return }
            resolving = true
        }

        // 1) UL/AL
        if let key = extractIdentifier(from: url) {
            getDetails(key: key, query: url?.query, onSuccess: onSuccess, onError: onError)
            return
        }

        // 2) Clipboard fallback
        #if canImport(UIKit)
        if let clip = UIPasteboard.general.string, isValidKey(clip) {
            getDetails(key: clip, query: nil, onSuccess: onSuccess, onError: onError)
            return
        }
        #endif

        getTryDetails(onSuccess: onSuccess, onError: onError)
    }

    // MARK: - Backward compatibility
    public static func fetchDetails(from url: URL? = nil, completion: @escaping (Any?) -> Void) {
        fetchDetails(from: url, onSuccess: { dict in
            completion(dict)
        }, onError: { _ in
            completion(nil)
        })
    }

    // MARK: - Internals

    private static let lock = DispatchQueue(label: "sddl.sdk.lock")
    private static var resolving = false

    private static let session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 5
        cfg.timeoutIntervalForResource = 5
        return URLSession(configuration: cfg)
    }()

    private static func extractIdentifier(from url: URL?) -> String? {
        guard let url = url else { return nil }
        let segments = url.path.split(separator: "/").map(String.init)
        if let first = segments.first, isValidKey(first) {
            return first
        }
        if let host = url.host, isValidKey(host) {
            return host
        }
        return nil
    }

    private static func isValidKey(_ s: String) -> Bool {
        let pattern = "^[A-Za-z0-9_-]{4,64}$"
        return s.range(of: pattern, options: .regularExpression) != nil
    }

    private static func buildDetailsURL(key: String, query: String?) -> URL? {
        var urlString = "https://sddl.me/api/\(key)/details"
        if let q = query, !q.isEmpty {
            urlString += "?\(q)"
        }
        return URL(string: urlString)
    }

    private static func getDetails(
        key: String,
        query: String?,
        onSuccess: @escaping ([String: Any]) -> Void,
        onError: @escaping (String) -> Void
    ) {
        guard let detailsURL = buildDetailsURL(key: key, query: query) else {
            finish(); onError("Invalid details URL"); return
        }

        var req = URLRequest(url: detailsURL)
        req.setValue("SDDLSDK-iOS/1.0", forHTTPHeaderField: "User-Agent")

        session.dataTask(with: req) { data, resp, err in
            defer { finish() }
            if let err = err {
                onError("Network error: \(err.localizedDescription)")
                return
            }
            guard let http = resp as? HTTPURLResponse, let data = data else {
                onError("No response"); return
            }

            switch http.statusCode {
            case 200:
                do {
                    if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        DispatchQueue.main.async { onSuccess(dict) }
                    } else {
                        onError("Parse error: not a JSON object")
                    }
                } catch {
                    onError("Parse error: \(error.localizedDescription)")
                }

            case 404, 410:
                getTryDetails(onSuccess: onSuccess, onError: onError)

            default:
                onError("HTTP \(http.statusCode)")
            }
        }.resume()
    }

    private static func getTryDetails(
        onSuccess: @escaping ([String: Any]) -> Void,
        onError: @escaping (String) -> Void
    ) {
        guard let url = URL(string: "https://sddl.me/api/try/details") else {
            finish(); onError("Invalid try/details URL"); return
        }
        var req = URLRequest(url: url)
        req.setValue("SDDLSDK-iOS/1.0", forHTTPHeaderField: "User-Agent")

        session.dataTask(with: req) { data, resp, err in
            defer { finish() }
            if let err = err {
                onError("Network error: \(err.localizedDescription)")
                return
            }
            guard let http = resp as? HTTPURLResponse, let data = data else {
                onError("No response"); return
            }

            if http.statusCode == 200 {
                do {
                    if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        DispatchQueue.main.async { onSuccess(dict) }
                    } else {
                        onError("Parse error: not a JSON object")
                    }
                } catch {
                    onError("Parse error: \(error.localizedDescription)")
                }
            } else {
                onError("TRY \(http.statusCode)")
            }
        }.resume()
    }

    private static func finish() {
        lock.sync { resolving = false }
    }
}