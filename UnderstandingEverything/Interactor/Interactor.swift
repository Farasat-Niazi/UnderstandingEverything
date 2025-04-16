//
//  Interprator.swift
//  UnderstandingEverything
//
//  Created by Farasat's_MacBook_Pro on 14/04/2025.
//

import Foundation

enum CardSide {
    case front
    case back
}

protocol ImageInteractorProtocol {
    func getUniqueURL(
        currentIndex: Int,
        currentSide: CardSide,
        frontImageUrls: inout [Int: URL],
        backImageUrls: inout [Int: URL]
    )

    func initiateImageAPICall(completion: @escaping () -> Void)
    func reset()
}

class Interactor: ImageInteractorProtocol {
    private var imageUrls: [URL] = []
    weak var updateUrls: UpdateURLProtocol?

    private let fallbackURL = URL(string: "https://example.com/fallback.jpg")!

    init(imageUrls: [URL] = [], view: UpdateURLProtocol) {
        self.imageUrls = imageUrls
        self.updateUrls = view
    }

    func getUniqueURL(
        currentIndex: Int,
        currentSide: CardSide,
        frontImageUrls: inout [Int: URL],
        backImageUrls: inout [Int: URL]
    ) {
        guard !imageUrls.isEmpty else {
            updateUrls?.updateURL(for: currentIndex, frontUrl: fallbackURL, backUrl: fallbackURL)
            return
        }

        let assignedURLs = currentSide == .front ? frontImageUrls : backImageUrls
        let otherSideURLs = currentSide == .front ? backImageUrls : frontImageUrls
        let otherSideURL = otherSideURLs[currentIndex]

        if let existingURL = assignedURLs[currentIndex] {
            updateUrls?.updateURL(
                for: currentIndex,
                frontUrl: currentSide == .front ? existingURL : otherSideURL ?? fallbackURL,
                backUrl: currentSide == .front ? otherSideURL ?? fallbackURL : existingURL
            )
            return
        }

        let allUsedURLs = Set(frontImageUrls.values).union(backImageUrls.values).subtracting([
            otherSideURL ?? fallbackURL
        ])

        for url in imageUrls {
            if !allUsedURLs.contains(url) {
                assign(url: url, to: currentSide, at: currentIndex, front: &frontImageUrls, back: &backImageUrls)
                updateUrls?.updateURL(
                    for: currentIndex,
                    frontUrl: currentSide == .front ? url : otherSideURL ?? fallbackURL,
                    backUrl: currentSide == .front ? otherSideURL ?? fallbackURL : url
                )
                return
            }
        }


        let fallbackList = imageUrls.filter {
            !allUsedURLs.contains($0) && $0 != otherSideURL
        }

        if let fallback = fallbackList.randomElement() {
            assign(url: fallback, to: currentSide, at: currentIndex, front: &frontImageUrls, back: &backImageUrls)
            updateUrls?.updateURL(
                for: currentIndex,
                frontUrl: currentSide == .front ? fallback : otherSideURL ?? fallbackURL,
                backUrl: currentSide == .front ? otherSideURL ?? fallbackURL : fallback
            )
            return
        }

        assign(url: fallbackURL, to: currentSide, at: currentIndex, front: &frontImageUrls, back: &backImageUrls)
        updateUrls?.updateURL(
            for: currentIndex,
            frontUrl: currentSide == .front ? fallbackURL : otherSideURL ?? fallbackURL,
            backUrl: currentSide == .front ? otherSideURL ?? fallbackURL : fallbackURL
        )
    }

    private func assign(url: URL, to side: CardSide, at index: Int, front: inout [Int: URL], back: inout [Int: URL]) {
        if side == .front {
            front[index] = url
        } else {
            back[index] = url
        }
    }

    func initiateImageAPICall(completion: @escaping () -> Void) {
        APIRequestHandler.sharedInstance().fetchUnsplashTopics { [weak self] topics in
            guard let self = self else { return }
            for topic in topics {
                if let cover = topic.cover_photo,
                   let image = cover.urls,
                   let urlString = image.regular,
                   let url = URL(string: urlString) {
                    self.imageUrls.append(url)
                }
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func reset() {
        imageUrls.removeAll()
    }
}
