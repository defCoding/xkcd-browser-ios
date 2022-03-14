//
//  FavoritesTableViewController.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/12/22.
//

import UIKit
import CoreAudio

class FavoritesViewController: UIViewController {
    @IBOutlet weak var comicsTableView: UITableView!
    // https://www.swiftjectivec.com/diffable-datasource-tableview/
    lazy var dataSource: ComicsDiffableDataSource = {
        ComicsDiffableDataSource(tableView: self.comicsTableView) { (tableView, indexPath, comic) -> UITableViewCell? in
            if let cell = self.comicsTableView.dequeueReusableCell(withIdentifier: "ComicCell", for: indexPath) as? ComicTableViewCell {
                cell.setup(comic: comic)
                return cell
            }
            
            return UITableViewCell()
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCells()
        comicsTableView.delegate = self
        comicsTableView.sectionFooterHeight = 5
        comicsTableView.rowHeight = 80
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
    
    private func registerTableViewCells() {
        let comicCell = UINib(nibName: "ComicTableViewCell", bundle: nil)
        comicsTableView.register(comicCell, forCellReuseIdentifier: "ComicCell")
    }
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let comicCell = tableView.cellForRow(at: indexPath) as! ComicTableViewCell? else {
            return
        }
        guard let comic = comicCell.comic else {
            return
        }
        guard let tabBarController = tabBarController else {
            return
        }
        let homepageVC = tabBarController.viewControllers?[0] as! HomePageViewController
        homepageVC.currentComic = comic
        tabBarController.selectedIndex = 0
    }
}
