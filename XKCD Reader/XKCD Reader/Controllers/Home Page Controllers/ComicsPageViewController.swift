//
//  ComicsPageViewController.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/11/22.
//

import UIKit

protocol ComicsPageViewControllerDelegate {
    /**
     Called whenever the current ComicViewController being displayed has its comic loaded. Used for when there is a programmatic change to a new page, where
     the comic may not be preloaded ahead of time.
     
     - Parameter viewController:                The ComicsPageViewController containing all the comics
     - Parameter currentComicLoaded:            The comic that was loaded into the current visible view
     
     - Returns:                                 Nothing
     */
    func comicsPageViewControllerDelegate(_ viewController: ComicsPageViewController, currentComicUpdated comic: XKCDComic)
}

class ComicsPageViewController: UIPageViewController {
    var comicsPageViewControllerSet = Set<ComicViewController>()
    var comicDelegate: ComicsPageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        setViewControllers([getUnusedComicViewController(comicNum: XKCDClient.latestComicNum)], direction: .forward, animated: false)
    }
   
    /// Reloads the list of ComicViews to display the latest comics.
    func reloadComicsPageViewControllerList() {
        setViewControllers([getUnusedComicViewController(comicNum: XKCDClient.latestComicNum)], direction: .forward, animated: false)
    }
   
    /**
     Displays the comic with the provided number.
     
     - Parameter comicNum:              The number of the comic to display
     
     - Returns:                         Nothing
     */
    func displayComic(comicNum: Int) {
        guard let currentComicVC = self.viewControllers?.first as! ComicViewController? else {
            setViewControllers([getUnusedComicViewController(comicNum: comicNum)], direction: .forward, animated: false)
            return
        }
       
        // If current comic displayed is desired comic, do nothing.
        if currentComicVC.num == comicNum {
            return
        }
        
        let dir: UIPageViewController.NavigationDirection = currentComicVC.num < comicNum ? .forward : .reverse
        setViewControllers([getUnusedComicViewController(comicNum: comicNum)], direction: dir, animated: true)
    }
   
    /**
     Gets the current comic on display in the view controller.
     
     - Returns:                     The current comic being displayed
     */
    func getCurrentComic() -> XKCDComic? {
        guard let currentComicVC = self.viewControllers?.first as! ComicViewController? else {
            return nil
        }
        
        return currentComicVC.comic
    }
   
    /**
     Fetches an unused comic view controller from the set of generated controllers if one exists. Otherwise, creates a new one.
     
     - Parameter comicNum:              The number of the comic to store in the view controller
     
     - Returns:                         The view controller containing the comic
     */
    func getUnusedComicViewController(comicNum: Int) -> ComicViewController {
        /**
        Note: With this implementation, there is no mechanism for removing unused view controllers from the set. However, with
         how this is implemented, the user cannot physically exceed four view controllers in the set, so the size of the set cannot grow
         indefinitely.
         */
        let unusedComicVC = comicsPageViewControllerSet.first { $0.parent == nil }
        
        if let unusedComicVC = unusedComicVC {
            unusedComicVC.num = comicNum
            return unusedComicVC
        } else {
            let newComicViewController = ComicViewController.getInstance(comicNum: comicNum)
            newComicViewController.delegate = self
            comicsPageViewControllerSet.insert(newComicViewController)
            return newComicViewController
        }
    }
}

extension ComicsPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentComicView = viewController as! ComicViewController
        // There is no previous comic if current comic is comic #1
        if currentComicView.num == 1 {
            return nil
        }
        return getUnusedComicViewController(comicNum: currentComicView.num - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentComicView = viewController as! ComicViewController
        // There is no next comic if we are on the latest comic
        if currentComicView.num == XKCDClient.latestComicNum {
            return nil
        }
        return getUnusedComicViewController(comicNum: currentComicView.num + 1)
    }
}


extension ComicsPageViewController: ComicViewControllerDelegate {
    func comicViewController(_ viewController: ComicViewController, comicUpdated comic: XKCDComic) {
        guard let viewControllers = self.viewControllers else {
            return
        }
        
        let currentComicView = viewControllers[0] as! ComicViewController
        if currentComicView.num == comic.num {
            comicDelegate?.comicsPageViewControllerDelegate(self, currentComicUpdated: comic)
        }
    }
}
