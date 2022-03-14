//
//  DarkModeSettingTableViewCell.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/14/22.
//

import UIKit

class DarkModeSettingTableViewCell: SettingTableViewCell {
    @IBOutlet weak var darkModeControl: UISegmentedControl!
    @IBAction func switchedDarkMode(_ sender: Any) {
        switch darkModeControl.selectedSegmentIndex {
        case 0:
            window?.overrideUserInterfaceStyle = .dark
        case 1:
            window?.overrideUserInterfaceStyle = .light
        case 2:
            window?.overrideUserInterfaceStyle = .unspecified
        default:
            return
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        darkModeControl.setTitleTextAttributes([.font: UIFont(name: "xkcdScript", size: 18)!], for: .normal)
    }
}
