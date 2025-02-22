import Foundation
import UIKit

public class SDDLSDKManager {

    public static func fetchDetails(from url: URL? = nil, completion: @escaping (Any?) -> Void) {
        guard let tryDetailsURL = URL(string: "https://sddl.me/api/try/details") else {
            fallbackFetchDetails(from: url, completion: completion)
            return
        }
        
        let task = URLSession.shared.dataTask(with: tryDetailsURL) { data, response, error in
            if let error = error {
                fallbackFetchDetails(from: url, completion: completion)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                fallbackFetchDetails(from: url, completion: completion)
                return
            }
            
            guard let data = data else {
                fallbackFetchDetails(from: url, completion: completion)
                return
            }
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                DispatchQueue.main.async {
                    completion(jsonData)
                }
            } catch {
                fallbackFetchDetails(from: url, completion: completion)
            }
        }
        task.resume()
    }
    
    private static func fallbackFetchDetails(from url: URL?, completion: @escaping (Any?) -> Void) {
        var identifier: String? = nil
        
        if let url = url {
            let path = url.host ?? url.path
            if !path.isEmpty {
                identifier = path.replacingOccurrences(of: "/", with: "")
            }
        }
        
        if identifier == nil, UIPasteboard.general.hasStrings {
            if let clipboardText = UIPasteboard.general.string, !clipboardText.isEmpty {
                identifier = clipboardText.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        guard let id = identifier else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        
        let urlString = "https://sddl.me/api/\(id)/details"
        guard let detailsURL = URL(string: urlString) else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        
        let detailsTask = URLSession.shared.dataTask(with: detailsURL) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                DispatchQueue.main.async {
                    completion(json)
                }
            } catch {
                DispatchQueue.main.async { completion(nil) }
            }
        }
        detailsTask.resume()
    }
}
