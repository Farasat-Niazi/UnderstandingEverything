
//
//  ViewController.swift
//  UnderstandingEverything
//
//  Created by Farasat's_MacBook_Pro on 14/04/2025.
//
//
import UIKit
import SDWebImage

protocol IntroViewProtocol: AnyObject {
    func animateLabel(_ colorOfText: UIColor, fontOfText: UIFont, alphaValue: Double)
    func addTapGesture(_ gesture: UITapGestureRecognizer) -> UICollectionView
    func addLongGesture(_ gesture: UILongPressGestureRecognizer)
    func toggleCardSide(at index: Int)
}

protocol UpdateURLProtocol: AnyObject {
    var cardSide: CardSide { get }
    func updateURL(for index: Int, frontUrl: URL, backUrl: URL)
}

class ViewController: UIViewController {

    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    private var currentIndex = 0
    private var timer: Timer?

    private var assignedFrontImageURLs: [Int: URL] = [:]
    private var assignedBackImageURLs: [Int: URL] = [:]
    private var cardSides: [Int: CardSide] = [:]

    var imagePresenter: ImagePresenterProtocol?
    var imageInteractor: Interactor?

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePresenter = ImagePresentor(view: self)
        imageInteractor = Interactor(view: self)

        let tapGesture = UITapGestureRecognizer()
        let longGesture = UILongPressGestureRecognizer()

        imagePresenter?.setTapGesture(tapGesture)
        imagePresenter?.setLongPressGesture(longGesture)

        imageInteractor?.initiateImageAPICall { [weak self] in
            guard let self = self else { return }
            for index in 0..<3 {
                self.loadImageForCard(at: index)
            }

            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }

        startAutoScroll()
    }

    func loadImageForCard(at index: Int) {
        let side = cardSides[index] ?? .front
        imageInteractor?.getUniqueURL(
            currentIndex: index,
            currentSide: side,
            frontImageUrls: &assignedFrontImageURLs,
            backImageUrls: &assignedBackImageURLs
        )
    }

    private func startAutoScroll() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            self.moveToNextCard()
        }
    }

    private func moveToNextCard() {
        let nextIndex = (currentIndex + 1) % 3
        currentIndex = nextIndex
        let indexPath = IndexPath(item: nextIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.collectionView.reloadData()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleIndex = Int(collectionView.contentOffset.x / collectionView.frame.size.width)
        currentIndex = visibleIndex
        collectionView.reloadData()
    }

    deinit {
        timer?.invalidate()
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "card", for: indexPath) as! cardCell
        let isCurrent = indexPath.item == currentIndex

        let frontURL = assignedFrontImageURLs[indexPath.item] ?? URL(string: "https://example.com/fallback.jpg")!
        let backURL = assignedBackImageURLs[indexPath.item] ?? URL(string: "https://example.com/fallback.jpg")!

        cell.configure(isCurrent: isCurrent, frontImageUrl: frontURL, backImageUrl: backURL)
//        cell.frontView.backgroundColor = isCurrent ? .systemBlue : .lightGray

        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected item at \(indexPath)")
    }
}

extension ViewController: IntroViewProtocol {
    func addLongGesture(_ gesture: UILongPressGestureRecognizer) {
        introLabel.isUserInteractionEnabled = true
        introLabel.addGestureRecognizer(gesture)
    }

    func addTapGesture(_ gesture: UITapGestureRecognizer) -> UICollectionView {
        collectionView.addGestureRecognizer(gesture)
        return collectionView
    }

    func toggleCardSide(at index: Int) {
        let current = cardSides[index] ?? .front
        cardSides[index] = current == .front ? .back : .front
        loadImageForCard(at: index)
    }

    func animateLabel(_ colorOfText: UIColor, fontOfText: UIFont, alphaValue: Double) {
        introLabel.textColor = colorOfText
        introLabel.font = fontOfText
        introLabel.alpha = alphaValue
    }
}

extension ViewController: UpdateURLProtocol {
    var cardSide: CardSide {
        return .front
    }

    func updateURL(for index: Int, frontUrl: URL, backUrl: URL) {
        print("Index: \(index)")
        print("Front: \(frontUrl.absoluteString)")
        print("Back: \(backUrl.absoluteString)")

        DispatchQueue.main.async {
            let indexPath = IndexPath(item: index, section: 0)
            if let cell = self.collectionView.cellForItem(at: indexPath) as? cardCell {
                let isCurrent = index == self.currentIndex
                cell.configure(isCurrent: isCurrent, frontImageUrl: frontUrl, backImageUrl: backUrl)
//                cell.frontView.backgroundColor = isCurrent ? .systemBlue : .lightGray
            }
        }
    }
}

