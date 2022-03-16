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
            // Fetch settings table view and place in center of that
            guard let superview = superview?.superview else {
                return
            }
            
            let warningPopup = PopUpWarningView(text: "This will clear all cached comics and prevent comics from being cached to disk. You will not be able to browse comics offline. Are you sure you want to continue?", onOk: {
                ComicsDataManager.sharedInstance.disableDiskCaching()
            }, onCancel: {
                if let cacheSwitch = self.secondaryView as? XKCDSwitch {
                    cacheSwitch.setOn(false, animated: true)
                }
            }, fontSize: 16)
            superview.addSubview(warningPopup)
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
