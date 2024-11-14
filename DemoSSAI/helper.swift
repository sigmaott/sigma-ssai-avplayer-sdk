//
//  helper.swift
//  DemoSSAI
//
//  Created by Pham Hai on 15/10/2024.
//

import Foundation

import Foundation

struct Helper {
    
    // Function to format a number to a specific decimal format
    static func formatNumber(_ number: Double, decimalPlaces: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimalPlaces
        formatter.maximumFractionDigits = decimalPlaces
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    // Function to format a string (e.g., trimming whitespace, uppercasing)
    static func formatString(_ string: String, toUpperCase: Bool = false) -> String {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return toUpperCase ? trimmedString.uppercased() : trimmedString
    }
    
    
    static func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
          options = JSONSerialization.WritingOptions.prettyPrinted
        }

        do {
          let data = try JSONSerialization.data(withJSONObject: json, options: options)
          if let string = String(data: data, encoding: String.Encoding.utf8) {
            return string
          }
        } catch {
          print(error)
        }

        return ""
    }
    
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    static func convertToArrayDictionary(text: String) -> [[String: Any]]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    static func showLog(_ logs: Any...) {
        print("log: \(logs)")
    }
    static func isRunningOnSimulator() -> Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    static func getBaseURL(from m3u8Url: String) -> String {
        guard let url = URL(string: m3u8Url) else {
            print("Invalid URL")
            return ""
        }
        
        // Construct the base URL using the scheme, host, and port (if any)
        var baseURL = "\(url.scheme!)://\(url.host ?? "")"
        
        if let port = url.port {
            baseURL += ":\(port)"
        }
        
        // Handle path components, ensuring no double slashes
        let pathComponents = url.pathComponents
        
        // Remove the last component (the M3U8 file itself)
        if pathComponents.count > 1 {
            let basePath = pathComponents.dropLast().joined(separator: "/")
            // Remove leading slash from basePath to avoid double slashes
            var cleanedBasePath = basePath.hasPrefix("/") ? String(basePath.dropFirst()) : basePath
            cleanedBasePath = cleanedBasePath.replacingOccurrences(of: "//", with: "/")
            baseURL += (cleanedBasePath.hasPrefix("/") ? "" : "/") + cleanedBasePath
        }
        
        // Ensure there's a trailing slash at the end of the base URL
        
        return baseURL.hasSuffix("/") ? baseURL : baseURL + "/"
    }
    // Function to fetch and parse .m3u8 content
    
    static func fetchM3U8Content(from url: String) async throws -> String {
        guard let m3u8URL = URL(string: url) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        let (data, response) = try await URLSession.shared.data(from: m3u8URL)

        // Check the HTTP response
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)
        }

        // Convert data to a string
        guard let content = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "Data Error", code: 0, userInfo: nil)
        }

        return content
    }

    // Function to extract playlist URLs from the .m3u8 content
    static func extractPlaylistURLs(from content: String, baseURL: String, videoUrl: String) -> [[String: String]] {
        var urls = [[String: String]]()
        let lines = content.components(separatedBy: "\n")

        for line in lines {
            if line.hasSuffix(".m3u8") {
//                let fullURL = baseURL + line
                let fullURL = URL(string: line, relativeTo: URL(string: baseURL))?.absoluteString ?? line
                if isValidURL(fullURL) {
                    urls.append(["name": line, "url": fullURL])
                }
            }
        }
        if(urls.count > 0) {
            urls.append(["name": "Auto", "url": videoUrl, "isAuto": "true"])
        }
        return urls
    }
    
    static func isValidURL(_ urlString: String) -> Bool {
        // Check if the string can be converted to a URL
        guard let url = URL(string: urlString) else {
            return false
        }
        // Check that the URL has a valid scheme (http or https) and a non-empty host
        if let host = url.host, (url.scheme == "http" || url.scheme == "https"), !host.isEmpty {
            return true
        }
        
        return false
    }
    static func formatPlaybackTime(_ seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter.string(from: seconds) ?? "00:00:00"
    }
}
