//
//  DarkModeSettingTableViewCell.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/14/22.
//

import UIKit

class DarkModeSettingTableViewCell: SettingTableViewCell {
    @objc func switchedDarkMode(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "darkMode")
        switch sender.selectedSegmentIndex {
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
   
    override func commonInit() {
        super.commonInit()
        label = UILabel()
        secondaryView = UISegmentedControl(items: ["Dark", "Light", "System"])
    }
    
    override func setupViews() {
        super.setupViews()
        label!.text = "Dark Mode"
        
        if let modeOptions = secondaryView as? UISegmentedControl {
            modeOptions.setTitleTextAttributes([.font: UIFont(name: "xkcdScript", size: 18)!], for: .normal)
            modeOptions.selectedSegmentTintColor = UIColor(named: "Marble")
            modeOptions.addTarget(self, action: #selector(switchedDarkMode(_:)), for: .valueChanged)
          
            // Check for overlap between label and segmented control and update font size if needed.
            layoutIfNeeded() // Need to layout subviews first to check for overlap.
            if label!.frame.intersects(modeOptions.frame) {
                modeOptions.setTitleTextAttributes([.font: UIFont(name: "xkcdScript", size: 12)!], for: .normal)
            }
        }
    }
    
    override func refreshWithUserDefaults() {
        if let modeOptions = secondaryView as? UISegmentedControl {
            modeOptions.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "darkMode")
        }
    }
}
