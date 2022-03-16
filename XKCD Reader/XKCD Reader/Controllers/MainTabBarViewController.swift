//
//  MainTabBarViewController.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/15/22.
//

import UIKit

/// ViewController for app TabBarController. This controller's view contains all other views.
class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRatingView()
        syncComics(cacheAll: !UserDefaults.standard.bool(forKey: "disableDiskCaching"))
        showSplash()
    }
   
    /**
     Loads the latest comic and syncs up the homepage to show the latest comic
     
     - Parameter cacheAll:                      Whether or not to cache all comics.
     */
    private func syncComics(cacheAll: Bool) {
        guard let homepageVC = self.viewControllers?[0] as? HomePageViewController else {
            return
        }
       
        XKCDClient.fetchComic(num: nil) { (comic, err) in
            guard let comic = comic, err == nil else {
                homepageVC.reloadComics()
                return
            }
            
            ComicsDataManager.sharedInstance.latestComicNum = comic.num
            homepageVC.currentComic = comic
            homepageVC.reloadComics()
       
            let progressView = ComicsCacheLoadView()
            self.view.addSubview(progressView)
            progressView.center = self.view.center
            progressView.isHidden = false
            if cacheAll {
                XKCDClient.cacheAllComicsToDisk(progress: { progress in
                    progressView.progressBar.progress = progress
                }, completion: {
                    progressView.removeFromSuperview()
                })
            }
        }
    }
    
    /// Loads up the rating view on the user's third launch.
    private func setupRatingView() {
        if UserDefaults.standard.integer(forKey: "launchCount") == 3 {
            let ratingView = RateThisAppView()
            self.view.addSubview(ratingView)
            NSLayoutConstraint.activate([
                ratingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                ratingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
        }
    }
   
    /// Shows the splash screen
    private func showSplash() {
        let splashScreen = SplashScreenView()
        self.view.addSubview(splashScreen)
        UIView.animate(withDuration: 1, delay: 1) {
            splashScreen.layer.opacity = 0
        } completion: { _ in
            splashScreen.removeFromSuperview()
        }
    }
}
