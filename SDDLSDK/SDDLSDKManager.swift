import Foundation
import UIKit

public class SDDLSDKManager {

    public static func fetchDetails(from url: URL? = nil, completion: @escaping (Any?) -> Void) {
        if let url = url {
            // Extract the deep link key from the URL's last path component.
            var identifier = url.lastPathComponent
            if identifier.isEmpty {
                identifier = url.host ?? ""
            }

            let queryParams = url.query ?? ""
            fetchDetails(with: identifier, queryParams: queryParams, completion: completion)
        } else {
            // Check clipboard
            if let clipboardText = UIPasteboard.general.string,
               isValidKey(clipboardText) {
                fetchDetails(with: clipboardText, queryParams: "", completion: completion)
            } else {
                // fallback
                guard let tryDetailsURL = URL(string: "https://sddl.me/api/try/details") else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }

                let task = URLSession.shared.dataTask(with: tryDetailsURL) { data, response, error in
                    if error != nil || data == nil {
                        DispatchQueue.main.async { completion(nil) }
                        return
                    }
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data!, options: [])
                        DispatchQueue.main.async {
                            completion(jsonData)
                        }
                    } catch {
                        DispatchQueue.main.async { completion(nil) }
                    }
                }
                task.resume()
            }
        }
    }

    private static func isValidKey(_ text: String) -> Bool {
        let pattern = "^[a-zA-Z0-9]{3,32}$"
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    private static func fetchDetails(with identifier: String, queryParams: String, completion: @escaping (Any?) -> Void) {
        var urlString = "https://sddl.me/api/\(identifier)/details"
        if !queryParams.isEmpty {
            urlString += "?\(queryParams)"
        }

        guard let detailsURL = URL(string: urlString) else {
            DispatchQueue.main.async { completion(nil) }
            return
        }

        let task = URLSession.shared.dataTask(with: detailsURL) { data, response, error in
            if error != nil || data == nil {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                DispatchQueue.main.async {
                    completion(json)
                }
            } catch {
                DispatchQueue.main.async { completion(nil) }
            }
        }
        task.resume()
    }
}