//
//  SearchViewController.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/13/22.
//

import UIKit

class SearchViewController: ComicsTableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var deepSearchSwitch: UISwitch!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
   
    @IBAction func switchToggled(_ sender: Any) {
        // Update thumb tint color based on switch state.
        if deepSearchSwitch.isOn {
            deepSearchSwitch.thumbTintColor = UIColor(named: "Charcoal")
        } else {
            deepSearchSwitch.thumbTintColor = .lightGray
        }
    }
   
    /**
     Searches the comics for the query and updates the table.
     
     - Parameter query:                 The search query
     
     - Returns:                         Nothing
     */
    private func performSearch(query: String) {
        spinner.startAnimating()
        XKCDClient.fetchSearchComics(query: query, deepSearch: deepSearchSwitch.isOn) { (comics, err) in
            guard let comics = comics, err == nil else {
                return
            }
            self.displayComics(comics: comics)
            self.spinner.stopAnimating()
        }
    }
   
    /**
     Sets up subview attributes.
     
     - Returns:                        Nothing
     */
    private func setup() {
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.backgroundColor = UIColor(named: "Marble")
        searchBar.searchTextField.font = UIFont(name: "xkcdScript", size: 18)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text {
            performSearch(query: query)
        }
    }
}
