//
//  HomePageViewController.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/11/22.
//

import UIKit

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
        let randomComicNum = Int.random(in: 1...XKCDClient.latestComicNum)
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
        
        if let comicSite = NSURL(string: "https://xkcd.com/\(currentComic.num)") {
            let activityVC = UIActivityViewController(activityItems: [comicSite], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        comicsPageVC.delegate = self
        comicsPageVC.comicDelegate = self
        
        /*
         Fetch the latest comic to get its number and update the page
         controller to show the latest comics.
         */
        XKCDClient.fetchComic(num: nil) { (comic, err) -> Void in
            guard let comic = comic, err == nil else {
                return
            }
            
            XKCDClient.latestComicNum = comic.num
            self.currentComic = comic
            self.comicsPageVC.reloadComicsPageViewControllerList()
        }
    
        setUpInfoView()
        setUpGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let currentComic = self.currentComic {
            self.comicsPageVC.displayComic(comicNum: currentComic.num)
        }
    }
   
    /**
     Updates the labels with a new comic.
     
     - Parameter comic:             The comic to update the labels with
     
     - Returns:                     Nothing
     */
    func updateComicInfo(comic: XKCDComic) {
        comicTitleLabel.text = comic.title
        comicNumberLabel.text = "#\(comic.num)"
        comicInfo.updateComic(comic: comic)
        updateFavoritesButtonColor(favorited: ComicsDataManager.sharedInstance.isFavorite(comic: comic))
    }
   
    /**
     Toggles on and off the visibility of the comic info view.
     
     - Returns:                     Nothing
     */
    func toggleInfoView() {
        comicInfo.isHidden = !comicInfo.isHidden
        comicsContainer.isUserInteractionEnabled = comicInfo.isHidden
    }
   
    /**
     Updates the favorites button to match the favorited state.
     
     - Parameter favorited:         Whether or not the current comic is favorited
     
     - Returns:                     Nothing
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
   
    /**
     Initializes the info view properties.
     
     - Returns:                     Nothing
     */
    private func setUpInfoView() {
        comicInfo.isHidden = true
        comicInfo.layer.shadowColor = UIColor.black.cgColor
        comicInfo.layer.shadowOpacity = 0.4
        comicInfo.layer.shadowOffset = CGSize(width: 6, height: 6)
        comicInfo.layer.shadowRadius = 4
        comicInfo.layer.shadowPath = UIBezierPath(rect: comicInfo.bounds).cgPath
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
    func comicsPageViewControllerDelegate(_ viewController: ComicsPageViewController, currentComicUpdated comic: XKCDComic) {
        currentComic = comic
        updateComicInfo(comic: comic)
    }
}

extension HomePageViewController: UIGestureRecognizerDelegate {
    private func setUpGestures() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        // Hide comic info if info is visible and touch is outside of info
        if (!comicInfo.isHidden) {
            let tapLocation = gestureRecognizer.location(in: comicInfo)
            if !comicInfo.bounds.contains(tapLocation) {
                toggleInfoView()
            }
        }
    }
}

