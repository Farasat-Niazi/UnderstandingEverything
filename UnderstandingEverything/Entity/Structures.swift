//
//  Structures.swift
//  UnderstandingEverything
//
//  Created by Farasat's_MacBook_Pro on 14/04/2025.
//

import Foundation

// MARK: - UNSPLASH Model

struct UnsplashTopic: Codable {
    let id: String
    let title: String
    let slug: String
    let description: String?
    let cover_photo: UnsplashImage?
}

struct UnsplashImage: Codable {
    let urls: ImageURLs?
}

struct ImageURLs: Codable {
    let regular: String?
}
