//
//  APIRequestHandler.swift
//  UnderstandingEverything
//
//  Created by Farasat's_MacBook_Pro on 14/04/2025.
//

import Foundation

class APIRequestHandler {
    
    private static let shared_Instance = APIRequestHandler()
    
    // MARK: - Singleton
    static func sharedInstance() -> APIRequestHandler {
        return shared_Instance
    }
    
    
    // MARK: - Download UNSPLASH Data
    func fetchUnsplashTopics(completion: @escaping ([UnsplashTopic]) -> Void) {
        let urlString = "\(UNSPLASH_URL)\(UNSPLASH_ACCESS_KEY)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error:", error ?? "Unknown error")
                return
            }
            
            do {
                let topics = try JSONDecoder().decode([UnsplashTopic].self, from: data)
                completion(topics)
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
    //MARK: - Added a method to initiate request
    func initiateTapRequest(){
        
        print("getting updated")

    }
}
extension APIRequestHandler : HandleTaps {
    func tapBtn() {
        print("get started button is been tapped inside API Request handler")
        initiateTapRequest()
    }
}
