import Foundation
import UIKit

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
        if let url = url {
            beginULArrival()
            guard beginSingleFlightIfPossible() else { return }
            resolveFromURL(url, onSuccess, onError)
            return
        }

        scheduleColdStart(onSuccess, onError)
    }

    // MARK: - Orchestration
    private static func resolveFromURL(
        _ url: URL,
        _ onSuccess: @escaping ([String: Any]) -> Void,
        _ onError: @escaping (String) -> Void
    ) {
        if let key = extractIdentifier(from: url) {
            getDetails(key: key, query: url.query, onSuccess: onSuccess, onError: onError)
        } else {
            getTryDetails(onSuccess: onSuccess, onError: onError)
        }
    }

    private static func scheduleColdStart(
        _ onSuccess: @escaping ([String: Any]) -> Void,
        _ onError: @escaping (String) -> Void
    ) {
        let work = DispatchWorkItem {
            lock.sync {
                if ulArrived || resolving { return }
                resolving = true
            }

            if let clipKey = readClipboardKey() {
                getDetails(key: clipKey, query: nil, onSuccess: onSuccess, onError: onError)
                return
            }
            getTryDetails(onSuccess: onSuccess, onError: onError)
        }

        lock.sync {
            pendingCold?.cancel()
            pendingCold = work
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + coldStartDelay, execute: work)
    }

    // MARK: - Concurrency & state
    private static let lock = DispatchQueue(label: "sddl.sdk.lock")
    private static var resolving = false
    private static var ulArrived = false
    private static var pendingCold: DispatchWorkItem?

    private static let coldStartDelay: TimeInterval = 0.30

    private static func beginULArrival() {
        lock.sync {
            ulArrived = true
            pendingCold?.cancel()
            pendingCold = nil
        }
    }

    private static func beginSingleFlightIfPossible() -> Bool {
        return lock.sync {
            if resolving { return false }
            resolving = true
            return true
        }
    }

    private static func finish() {
        lock.sync {
            resolving = false
            pendingCold = nil
            ulArrived = false
        }
    }

    private static let session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 5
        cfg.timeoutIntervalForResource = 5
        return URLSession(configuration: cfg)
    }()

    // MARK: - Networking

    private static func getDetails(
        key: String,
        query: String?,
        onSuccess: @escaping ([String: Any]) -> Void,
        onError: @escaping (String) -> Void
    ) {
        guard let detailsURL = buildDetailsURL(key: key, query: query) else {
            finish(); deliverError("Invalid details URL", onError); return
        }

        var req = URLRequest(url: detailsURL)
        addCommonHeaders(to: &req)

        session.dataTask(with: req) { data, resp, err in
            defer { finish() }
            if let err = err {
                deliverError("Network error: \(err.localizedDescription)", onError); return
            }
            guard let http = resp as? HTTPURLResponse, let data = data else {
                deliverError("No response", onError); return
            }

            switch http.statusCode {
            case 200:
                do {
                    if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        deliverSuccess(dict, onSuccess)
                    } else {
                        deliverError("Parse error: not a JSON object", onError)
                    }
                } catch {
                    deliverError("Parse error: \(error.localizedDescription)", onError)
                }
            case 404, 410:
                getTryDetails(onSuccess: onSuccess, onError: onError)
            default:
                deliverError("HTTP \(http.statusCode)", onError)
            }
        }.resume()
    }

    private static func getTryDetails(
        onSuccess: @escaping ([String: Any]) -> Void,
        onError: @escaping (String) -> Void
    ) {
        guard let url = URL(string: "https://sddl.me/api/try/details") else {
            finish(); deliverError("Invalid try/details URL", onError); return
        }
        var req = URLRequest(url: url)
        addCommonHeaders(to: &req)

        session.dataTask(with: req) { data, resp, err in
            defer { finish() }
            if let err = err {
                deliverError("Network error: \(err.localizedDescription)", onError); return
            }
            guard let http = resp as? HTTPURLResponse, let data = data else {
                deliverError("No response", onError); return
            }

            if http.statusCode == 200 {
                do {
                    if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        deliverSuccess(dict, onSuccess)
                    } else {
                        deliverError("Parse error: not a JSON object", onError)
                    }
                } catch {
                    deliverError("Parse error: \(error.localizedDescription)", onError)
                }
            } else {
                deliverError("TRY \(http.statusCode)", onError)
            }
        }.resume()
    }

    // MARK: - Common headers

    private static func addCommonHeaders(to req: inout URLRequest) {
        req.setValue("SDDLSDK-iOS/1.0", forHTTPHeaderField: "User-Agent")
        if let bid = Bundle.main.bundleIdentifier, !bid.isEmpty {
            req.setValue(bid, forHTTPHeaderField: "X-App-Identifier")
        }
        req.setValue("iOS", forHTTPHeaderField: "X-Device-Platform")
    }

    // MARK: - Helpers

    private static func extractIdentifier(from url: URL?) -> String? {
        guard let url = url else { return nil }
        let segments = url.path.split(separator: "/").map(String.init)
        if let first = segments.first, isValidKey(first) { return first }
        if let host = url.host, isValidKey(host) { return host }
        return nil
    }

    private static func readClipboardKey() -> String? {
        let s = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return isValidKey(s) ? s : nil
    }

    private static func isValidKey(_ s: String) -> Bool {
        let pattern = "^[A-Za-z0-9_-]{4,64}$"
        return s.range(of: pattern, options: .regularExpression) != nil
    }

    private static func buildDetailsURL(key: String, query: String?) -> URL? {
        var urlString = "https://sddl.me/api/\(key)/details"
        if let q = query, !q.isEmpty { urlString += "?\(q)" }
        return URL(string: urlString)
    }

    private static func deliverSuccess(_ dict: [String: Any], _ onSuccess: @escaping ([String: Any]) -> Void) {
        DispatchQueue.main.async { onSuccess(dict) }
    }

    private static func deliverError(_ msg: String, _ onError: @escaping (String) -> Void) {
        DispatchQueue.main.async { onError(msg) }
    }
}
