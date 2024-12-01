//
//  URLManager.swift
//  DemoSSAI
//
//  Created by Pham Hai on 02/12/2024.
//

import Foundation

class URLManager {
    static let shared = URLManager()
    
    // Declare the list of URLs as a mutable array
    var urls: [[String: Any]] = []
    
    private init() {}
    
    // Add a new URL to the list
    func addItem(_ item: [String: Any]) {
        urls.append(item)
    }
    
    // Remove a URL from the list
    func removeURL(at index: Int) {
        if index >= 0 && index < urls.count {
            urls.remove(at: index)
        }
    }
    
    // Modify an existing URL in the list
    func modifyURL(at index: Int, with newItem: [String: Any]) {
        if index >= 0 && index < urls.count {
            urls[index] = newItem
        }
    }
}
