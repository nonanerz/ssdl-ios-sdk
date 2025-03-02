public class SDDLSDKManager {

    /// Fetches deep link details using the Universal Link flow.
    /// - Parameters:
    ///   - url: The universal link URL passed to the app (if available).
    ///   - completion: A closure called with the fetched details or nil on failure.
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