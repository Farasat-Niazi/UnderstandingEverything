//
//  cardCell.swift
//  UnderstandingEverything
//
//  Created by Farasat's_MacBook_Pro on 14/04/2025.
//

import UIKit
import SDWebImage

class cardCell: UICollectionViewCell {
    
    
    @IBOutlet weak var backImageVIew: SDAnimatedImageView!
    
    @IBOutlet weak var frontImageView: SDAnimatedImageView!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var frontView: UIView!
    
    private(set) var isFlipped = false

    func flip() {
        let fromView = isFlipped ? backView : frontView
        let toView = isFlipped ? frontView : backView

        UIView.transition(from: fromView!,
                          to: toView!,
                          duration: 0.6,
                          options: [.transitionFlipFromRight, .showHideTransitionViews]) { [weak self] _ in
            self?.isFlipped.toggle()
        }
    }
    func configure(isCurrent: Bool, frontImageUrl: URL, backImageUrl: URL) {
        
        isFlipped = !isCurrent
        
        frontImageView.sd_setImage(with: frontImageUrl)
        backImageVIew.sd_setImage(with: backImageUrl)
    }

      override func prepareForReuse() {
          super.prepareForReuse()
//          frontImageView.image = nil
//          backImageVIew.image = nil
//          frontView.backgroundColor = .clear
      }
}
