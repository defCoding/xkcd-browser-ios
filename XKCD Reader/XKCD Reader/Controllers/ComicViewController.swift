//
//  ComicViewController.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/11/22.
//

import UIKit
import AVFoundation

protocol ComicViewControllerDelegate {
    /**
     Event call when a comic in this view has loaded or updated
     
     - Parameter viewController:                The comic view controller
     - Parameter comicLoaded:                   The comic
     
     - Returns:                                 Nothing
     */
    func comicViewController(_ viewController: ComicViewController, comicUpdated comic: XKCDComic)
}

class ComicViewController: UIViewController {
    @IBOutlet weak var comicImageView: PanZoomImageView!
    var delegate: ComicViewControllerDelegate?
    
    var num = 0 {
        didSet {
            XKCDClient.fetchComic(num: num) { (comic, err) -> Void in
                guard let comic = comic, err == nil else {
                    return
                }
                self.comic = comic
                self.delegate?.comicViewController(self, comicUpdated: comic)
            }
        }
    }
    var comic: XKCDComic? = nil {
        didSet {
            if let comic = comic {
                XKCDClient.fetchComicImage(comic: comic) { (image, err) -> Void in
                    guard let image = image, err == nil else {
                        return
                    }
                    self.comicImageView?.image = image
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGestures()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // When comic leaves the view, reset the zoom.
        comicImageView.zoomScale = 1
    }
   
    /**
     Returns an instance of a ComicViewController with the given comic number.
     
     - Parameter comicNum:              The number of the comic to be stored in the view controller
     
     - Returns:                         A view controller containing the specified comic
     */
    static func getInstance(comicNum : Int) -> ComicViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "comicViewController") as! ComicViewController
        vc.num = comicNum
        return vc
    }
}

extension ComicViewController: UIGestureRecognizerDelegate {
    func setUpGestures() {
        let doubleTapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = self
        self.view.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        // Favorite comic if double tap is in comic bounds.
        let location = gestureRecognizer.location(in: comicImageView.imageView)
        guard let comic = comic, let comicImage = comicImageView.image else {
            return
        }
        
        let imageFrame = AVMakeRect(aspectRatio: comicImage.size, insideRect: comicImageView.imageView.bounds)
        if imageFrame.contains(location) {
            let favorited = ComicsDataManager.sharedInstance.toggleFavorite(comic: comic)
            self.delegate?.comicViewController(self, comicUpdated: comic)
            if (favorited) {
                doHeartAnimation()
            }
        }
    }
    
    func doHeartAnimation() {
        guard let heartImage = UIImage(systemName: "heart.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal) else {
            return
        }
        
        let heartImageView = UIImageView(image: heartImage)
        heartImageView.contentMode = .scaleAspectFit
        heartImageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        heartImageView.center = self.comicImageView.center
        self.comicImageView.addSubview(heartImageView)
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseInOut) {
            heartImageView.center = CGPoint(x: heartImageView.center.x,
                                            y: heartImageView.center.y - 150)
            heartImageView.layer.opacity = 0
        } completion: { (_) in
            heartImageView.removeFromSuperview()
        }
    }
}
