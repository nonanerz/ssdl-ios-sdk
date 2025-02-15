import Foundation
import UIKit

public class SDDLSDKManager {

    public static func fetchDetails(from url: URL? = nil, completion: @escaping (Any?) -> Void) {
        var identifier: String? = nil

        if let url = url {
            let path = url.host ?? url.path
            if !path.isEmpty {
                identifier = path.replacingOccurrences(of: "/", with: "")
            }
        }

        if identifier == nil, let clipboardText = UIPasteboard.general.string, !clipboardText.isEmpty {
            identifier = clipboardText
        }

        guard let id = identifier else {
            completion(nil)
            return
        }

        let urlString = "https://sddl.me/api/\(id)/details"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                    DispatchQueue.main.async {
                        completion(jsonData)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
        task.resume()
    }
}
