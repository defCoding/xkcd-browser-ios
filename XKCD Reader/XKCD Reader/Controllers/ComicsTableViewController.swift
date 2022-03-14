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
    @IBOutlet weak var comicsTableView
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

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
