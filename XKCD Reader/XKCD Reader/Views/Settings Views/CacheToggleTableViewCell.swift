//
//  CacheToggleTableViewCell.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/14/22.
//

import UIKit

/// Toggling disk caching table cell
class CacheToggleTableViewCell: SettingTableViewCell {
    @objc func switchToggled(_ sender: XKCDSwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "disableDiskCaching")
        if sender.isOn {
            ComicsDataManager.sharedInstance.disableDiskCaching()
        } else {
            ComicsDataManager.sharedInstance.enableDiskCaching()
        }
    }
    
    override func commonInit() {
        super.commonInit()
        label = UILabel()
        secondaryView = XKCDSwitch()
    }
    
    override func setupViews() {
        super.setupViews()
        label!.text = "Disable Caching to Disk"
        
        if let cacheSwitch = secondaryView as? XKCDSwitch {
            cacheSwitch.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        }
    }
    
    override func refreshWithUserDefaults() {
        if let cacheSwitch = secondaryView as? XKCDSwitch {
            cacheSwitch.setOn(UserDefaults.standard.bool(forKey: "disableDiskCaching"), animated: false)
        }
    }
}
