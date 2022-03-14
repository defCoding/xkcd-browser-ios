//
//  FavoritesTableViewController.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/12/22.
//

import UIKit
import CoreAudio

class FavoritesViewController: ComicsTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var snapshot = NSDiffableDataSourceSnapshot<Int, XKCDComic>()
        ComicsDataManager.sharedInstance.favorites.enumerated().forEach {
            snapshot.appendSections([$0.0])
            snapshot.appendItems([$0.1], toSection: $0.0)
        }
        dataSource.apply(snapshot)
    }
}
