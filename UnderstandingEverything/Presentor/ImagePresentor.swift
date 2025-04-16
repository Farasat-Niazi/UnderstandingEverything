//
//  ImagePresentor.swift
//  UnderstandingEverything
//
//  Created by Farasat's_MacBook_Pro on 14/04/2025.
//
//

import Foundation
import UIKit

protocol ImagePresenterProtocol {
    func setTapGesture(_ gesture: UITapGestureRecognizer)
    func didTapGesture(_ gesture: UITapGestureRecognizer)
    func setLongPressGesture(_ gesture: UILongPressGestureRecognizer)
    func didPressGesture(_ gesture: UILongPressGestureRecognizer)
}

class ImagePresentor: ImagePresenterProtocol {
    weak var view: IntroViewProtocol?
    var collectionView: UICollectionView!

    init(view: IntroViewProtocol) {
        self.view = view
    }

    func setTapGesture(_ gesture: UITapGestureRecognizer) {
        gesture.addTarget(self, action: #selector(didTapGesture(_:)))
        collectionView = view?.addTapGesture(gesture)
    }

    @objc func didTapGesture(_ gesture: UITapGestureRecognizer) {
        guard let collectionView = collectionView else { return }
        let point = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point),
           let cell = collectionView.cellForItem(at: indexPath) as? cardCell {
            cell.flip()
            view?.toggleCardSide(at: indexPath.item)
        }
    }

    func setLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        gesture.minimumPressDuration = 0
        gesture.allowableMovement = 10
        gesture.addTarget(self, action: #selector(didPressGesture(_:)))
        view?.addLongGesture(gesture)
    }

    @objc func didPressGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            view?.animateLabel(
                UIColor(named: "PrimaryColor") ?? .black,
                fontOfText: UIFont.preferredFont(forTextStyle: .title1),
                alphaValue: 0.7
            )
        case .ended, .cancelled, .failed:
            view?.animateLabel(
                .white,
                fontOfText: UIFont.preferredFont(forTextStyle: .title2),
                alphaValue: 1.0
            )
        default:
            break
        }
    }
}
