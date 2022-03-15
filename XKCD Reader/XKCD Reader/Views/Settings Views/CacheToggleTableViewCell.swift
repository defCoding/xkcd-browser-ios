//
//  CacheToggleTableViewCell.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/14/22.
//

import UIKit

class CacheToggleTableViewCell: SettingTableViewCell {
    @objc func switchToggled(_ sender: XKCDSwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "disableDiskCaching")
        ComicsDataManager.sharedInstance.disableDiskCaching()
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
