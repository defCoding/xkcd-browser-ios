//
//  SearchViewController.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/13/22.
//

import UIKit

/// View Controller for searching for comics and displaying searched results
class SearchViewController: ComicsTableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var deepSearchSwitch: UISwitch!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
   
    /**
     Searches the comics for the query and updates the table.
     
     - Parameter query:                 The search query
     */
    private func performSearch(query: String) {
        spinner.startAnimating()
        XKCDClient.sharedInstance.fetchSearchComics(query: query, deepSearch: deepSearchSwitch.isOn) { (comics, err) in
            guard let comics = comics, err == nil else {
                return
            }
            self.displayComics(comics: comics)
            self.spinner.stopAnimating()
        }
    }
   
    /// Sets up subview attributes.
    private func setup() {
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.backgroundColor = UIColor(named: "Marble")
        searchBar.searchTextField.font = UIFont(name: "xkcdScript", size: 18)
        deepSearchSwitch.isOn = UserDefaults.standard.bool(forKey: "deepSearchDefault")
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if let query = searchBar.text {
            if query != "" {
                performSearch(query: query)
            }
        }
    }
}
