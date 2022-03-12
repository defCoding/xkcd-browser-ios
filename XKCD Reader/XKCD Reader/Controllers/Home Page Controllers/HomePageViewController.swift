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
    
    @IBAction func infoClicked(_ sender: Any) {
        toggleInfoView()
    }
    
    @IBAction func shuffleClicked(_ sender: Any) {
        let randomComicNum = Int.random(in: 1...XKCDClient.latestComicNum)
        let comicsPageVC = self.children[0] as! ComicsPageViewController
        comicsPageVC.displayComic(comicNum: randomComicNum)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
         Fetch the latest comic to get its number and update the page
         controller to show the latest comics.
         */
        XKCDClient.fetchComic(num: nil) { (comic, err) -> Void in
            guard let comic = comic, err == nil else {
                return
            }
           
            XKCDClient.latestComicNum = comic.num
            let comicsPageVC = self.children[0] as! ComicsPageViewController
            comicsPageVC.reloadComicsPageViewControllerList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let comicsPageVC = self.children[0] as! ComicsPageViewController
        comicsPageVC.delegate = self
     
        // Set up info view
        comicInfo.isHidden = true
        comicInfo.layer.shadowColor = UIColor.black.cgColor
        comicInfo.layer.shadowOpacity = 0.4
        comicInfo.layer.shadowOffset = .zero
        comicInfo.layer.shadowRadius = 6
        comicInfo.layer.shadowPath = UIBezierPath(rect: comicInfo.bounds).cgPath
       
        setUpGestures()
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
    }
   
    /**
     Toggles on and off the visibility of the comic info view.
     
     - Returns:                    Nothing
     */
    func toggleInfoView() {
        comicInfo.isHidden = !comicInfo.isHidden
        comicsContainer.isUserInteractionEnabled = comicInfo.isHidden
    }
}

extension HomePageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentComic = (pageViewController.viewControllers?.first as! ComicViewController).comic, completed else {
            return
        }
        
        updateComicInfo(comic: currentComic)
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
