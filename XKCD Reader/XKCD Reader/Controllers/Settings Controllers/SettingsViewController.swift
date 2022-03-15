//
//  SettingsViewController.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/14/22.
//

import UIKit
import AVFAudio

class SettingsViewController: UIViewController {
    @IBOutlet weak var settingsTable: UITableView!
    private let sectionHeight: CGFloat = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTable.dataSource = self
        settingsTable.delegate = self
        registerTableViewCells()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSettingsFromDefaults), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func reloadSettingsFromDefaults() {
        settingsTable.reloadData()
    }
    
    private func registerTableViewCells() {
        settingsTable.register(DarkModeSettingTableViewCell.self, forCellReuseIdentifier: "DarkModeCell")
        settingsTable.register(SearchSettingTableViewCell.self, forCellReuseIdentifier: "SearchCell")
        settingsTable.register(ClearCacheTableViewCell.self, forCellReuseIdentifier: "ClearCacheCell")
        settingsTable.register(ClearFavoritesTableViewCell.self, forCellReuseIdentifier: "ClearFavoritesCell")
        settingsTable.register(CacheToggleTableViewCell.self, forCellReuseIdentifier: "CacheToggleCell")
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 3
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: "DarkModeCell", for: indexPath)
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: "ClearFavoritesCell", for: indexPath)
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: "ClearCacheCell", for: indexPath)
            case 2:
                cell = tableView.dequeueReusableCell(withIdentifier: "CacheToggleCell", for: indexPath)
            default:
                break
            }
        default:
            break
        }
        if let cell = cell as? SettingTableViewCell {
            cell.refreshWithUserDefaults()
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionLabel = UILabel()
        sectionLabel.font = UIFont(name: "xkcdScript", size: 24)
        // sectionLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: sectionHeight)
        switch section {
        case 0:
            sectionLabel.text = "App Settings"
        case 1:
            sectionLabel.text = "App Data"
        default:
            return nil
        }
        return sectionLabel
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeight
    }
}
