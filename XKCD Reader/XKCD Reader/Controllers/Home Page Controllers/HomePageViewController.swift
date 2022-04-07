//
//  HomePageViewController.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/11/22.
//

import UIKit
import Photos

/// View Controller for the home page containing the comics
class HomePageViewController: UIViewController {
    @IBOutlet weak var comicsContainer: UIView!
    @IBOutlet weak var comicTitleLabel: UILabel!
    @IBOutlet weak var comicNumberLabel: UILabel!
    @IBOutlet weak var comicInfo: ComicInfoView!
    @IBOutlet weak var favoriteButton: UIButton!
    private var comicsPageVC: ComicsPageViewController {
        self.children[0] as! ComicsPageViewController
    }
    var currentComic: XKCDComic?
  
    @IBAction func infoClicked(_ sender: Any) {
        toggleInfoView()
    }
    
    @IBAction func shuffleClicked(_ sender: Any) {
        // Grab a random comic
        let randomComicNum = Int.random(in: 1...ComicsDataManager.sharedInstance.latestComicNum)
        let comicsPageVC = self.children[0] as! ComicsPageViewController
        comicsPageVC.displayComic(comicNum: randomComicNum)
    }
    
    @IBAction func favoritesClicked(_ sender: Any) {
        guard let currentComic = currentComic else {
            return
        }
        
        let favorited = ComicsDataManager.sharedInstance.toggleFavorite(comic: currentComic)
        updateFavoritesButtonColor(favorited: favorited)
    }
    
    @IBAction func shareClicked(_ sender: UIButton) {
        guard let currentComic = self.currentComic else {
            return
        }
      
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard let comicSite = NSURL(string: "https://xkcd.com/\(currentComic.num)") else { return }
            var items: [Any] = [comicSite]
            if status == .authorized {
                guard let imgData = currentComic.imgData else { return }
                guard let comicImage = UIImage(data: imgData) else { return }
                items.append(comicImage)
            }
            DispatchQueue.main.async {
                let activityVC = UIActivityViewController(activityItems: items,
                                                          applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = sender
                self.present(activityVC, animated: true, completion: nil)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        comicsPageVC.delegate = self
        comicsPageVC.comicDelegate = self
        setupInfoView()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let currentComic = self.currentComic {
            self.comicsPageVC.displayComic(comicNum: currentComic.num)
        }
    }
   
    /// Reloads the homepage to show the latest comics.
    func reloadComics() {
        self.comicsPageVC.reloadComicsPageViewControllerList()
    }
   
    /**
     Updates the labels with a new comic.
     
     - Parameter comic:             The comic to update the labels with
     */
    func updateComicInfo(comic: XKCDComic) {
        comicTitleLabel.text = comic.title
        comicNumberLabel.text = "#\(comic.num)"
        comicInfo.updateComic(comic: comic)
        updateFavoritesButtonColor(favorited: ComicsDataManager.sharedInstance.isFavorite(comic: comic))
    }
   
    /// Toggles on and off the visibility of the comic info view.
    func toggleInfoView() {
        comicInfo.isHidden = !comicInfo.isHidden
        comicsContainer.isUserInteractionEnabled = comicInfo.isHidden
    }
    
    func displayComic(comicNum: Int) {
        comicsPageVC.displayComic(comicNum: comicNum)
    }
   
    /**
     Updates the favorites button to match the favorited state.
     
     - Parameter favorited:         Whether or not the current comic is favorited
     */
    private func updateFavoritesButtonColor(favorited: Bool) {
        let heartImage: UIImage?
        if favorited {
            heartImage = UIImage(systemName: "heart.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        } else {
            heartImage = UIImage(systemName: "heart")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
        favoriteButton.setImage(heartImage, for: .normal)
    }
   
    /// Initializes the info view properties.
    private func setupInfoView() {
        comicInfo.isHidden = true
        comicInfo.layer.borderColor = UIColor(named: "ElectricBlue")?.cgColor
        comicInfo.layer.borderWidth = 2
    }
}

extension HomePageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let comic = (pageViewController.viewControllers?.first as! ComicViewController).comic, completed else {
            return
        }
       
        currentComic = comic
        updateComicInfo(comic: comic)
    }
}

extension HomePageViewController: ComicsPageViewControllerDelegate {
    /**
     Event handler for when the current comic in the contained ComicsPageViewController has loaded.
     
     - Parameter viewController:                    The ComicsPageViewController holding the comic
     - Parameter currentComicUpdated:               The comic that was loaded
     */
    func comicsPageViewControllerDelegate(_ viewController: ComicsPageViewController, currentComicUpdated comic: XKCDComic) {
        currentComic = comic
        updateComicInfo(comic: comic)
    }
}

extension HomePageViewController: UIGestureRecognizerDelegate {
    /// Sets up a tap gesture for the controller
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
  
    /// Handles a tap and hides the info screen accordingly
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        // Hide comic info if info is visible and touch is outside of info
        if !comicInfo.isHidden {
            let tapLocation = gestureRecognizer.location(in: comicInfo)
            if !comicInfo.bounds.contains(tapLocation) {
                toggleInfoView()
            }
        }
    }
}

