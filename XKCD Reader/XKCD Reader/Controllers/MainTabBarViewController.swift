//
//  MainTabBarViewController.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/15/22.
//

import UIKit

/// ViewController for app TabBarController. This controller's view contains all other views.
class MainTabBarViewController: UITabBarController {
    private var progressView: ComicsCacheLoadView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        XKCDClient.sharedInstance.subscribe(self)
        setupRatingView()
        progressView = ComicsCacheLoadView()
        self.view.addSubview(progressView)
        setupProgressView()
        if let homepageVC = self.viewControllers?[0] as? HomePageViewController {
            homepageVC.reloadComics()
        }
        showSplash()
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
    
    /// Sets up the comics cache loading progress view.
    private func setupProgressView() {
        progressView.center = self.view.center
        progressView.isHidden = false
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

extension MainTabBarViewController: XKCDClientSubscriber {
    func cacheStartedListener() {
        progressView.isHidden = false
    }
    
    func cacheProgressListener(_ prog: Float) {
        progressView.progressBar.progress = prog
    }
    
    func cacheCompletedListener() {
        progressView.isHidden = true
    }
}
