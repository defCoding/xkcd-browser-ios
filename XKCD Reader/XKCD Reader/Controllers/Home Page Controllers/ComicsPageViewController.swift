//
//  ComicsPageViewController.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/11/22.
//

import UIKit

class ComicsPageViewController: UIPageViewController {
    var comicsPageViewControllerSet = Set<ComicViewController>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        setComicViewController(getUnusedComicViewController(comicNum: XKCDClient.latestComicNum))
    }
   
    /// Reloads the list of ComicViews to display the latest comics.
    func reloadComicsPageViewControllerList() {
        setComicViewController(getUnusedComicViewController(comicNum: XKCDClient.latestComicNum))
    }
   
    /**
     Displays the comic with the provided number.
     
     - Parameter comicNum:              The number of the comic to display
     
     - Returns:                         Nothing
     */
    func displayComic(comicNum: Int) {
        guard let currentComicVC = self.viewControllers?.first as! ComicViewController? else {
            setComicViewController(getUnusedComicViewController(comicNum: comicNum))
            return
        }
       
        // If current comic displayed is desired comic, do nothing.
        if currentComicVC.num == comicNum {
            return
        }
        
        let dir: UIPageViewController.NavigationDirection = currentComicVC.num < comicNum ? .forward : .reverse
        setComicViewController(getUnusedComicViewController(comicNum: comicNum), direction: dir, animated: true)
    }
   
    /**
     Fetches an unused comic view controller from the set of generated controllers if one exists. Otherwise, creates a new one.
     
     - Parameter comicNum:              The number of the comic to store in the view controller
     
     - Returns:                         The view controller containing the comic
     */
    func getUnusedComicViewController(comicNum: Int) -> ComicViewController {
        /**
        Note: With this implementation, there is no mechanism for removing unused view controllers from the set. However, with
         how this is implemented, the user cannot physically exceed three view controllers in the set, so the size of the set cannot grow
         indefinitely.
         */
        let unusedComicVC = comicsPageViewControllerSet.first { $0.parent == nil }
        
        if let unusedComicVC = unusedComicVC {
            unusedComicVC.num = comicNum
            return unusedComicVC
        } else {
            let newComicViewController = ComicViewController.getInstance(comicNum: comicNum)
            comicsPageViewControllerSet.insert(newComicViewController)
            return newComicViewController
        }
    }
   
    /**
     Sets the current ComicViewController being displayed to the provided view controller.
     
     - Parameter comicVC:               The new comic view controller
     - Parameter direction:             Direction of animation when moving to new comic
     - Parameter animated:              Whether or not to animate transition
     
     - Returns:                         Nothing
     */
    func setComicViewController(_ comicVC: ComicViewController, direction: UIPageViewController.NavigationDirection = .forward, animated: Bool = false) {
        setViewControllers([comicVC], direction: direction, animated: animated) { (finished) in
            self.delegate?.pageViewController?(self,
                                               didFinishAnimating: finished,
                                               previousViewControllers: self.viewControllers ?? [],
                                               transitionCompleted: finished)
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
