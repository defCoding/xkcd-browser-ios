//
//  FavoritesTableViewController.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/12/22.
//

import UIKit
import CoreAudio

/// View Controller for displaying favorited comics
class FavoritesViewController: ComicsTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayComics(comics: ComicsDataManager.sharedInstance.favorites)
    }
}
