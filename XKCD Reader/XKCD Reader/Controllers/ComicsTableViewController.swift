//
//  ComicsTableViewController.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/13/22.
//

import UIKit

class ComicsDiffableDataSource: UITableViewDiffableDataSource<Int, XKCDComic> {
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == self.snapshot().numberOfSections - 1 ? "" : " "
    }
}

class ComicsTableViewController: UIViewController {
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
    
    private func registerTableViewCells() {
        let comicCell = UINib(nibName: "ComicTableViewCell", bundle: nil)
        comicsTableView.register(comicCell, forCellReuseIdentifier: "ComicCell")
    }
}

extension ComicsTableViewController: UITableViewDelegate {
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
