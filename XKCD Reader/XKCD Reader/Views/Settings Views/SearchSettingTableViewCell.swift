//
//  SearchSettingTableViewCell.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/14/22.
//

import UIKit

class SearchSettingTableViewCell: SettingTableViewCell {
    @objc func switchChanged(_ sender: XKCDSwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "deepSearchDefault")
    }
    
    override func commonInit() {
        super.commonInit()
        label = UILabel()
        secondaryView = XKCDSwitch()
    }
    
    override func setupViews() {
        super.setupViews()
        label!.text = "Default Deep Search"
        
        if let searchSwitch = secondaryView as? XKCDSwitch {
            searchSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        }
    }
    
    override func refreshWithUserDefaults() {
        if let searchSwitch = secondaryView as? XKCDSwitch {
            searchSwitch.setOn(UserDefaults.standard.bool(forKey: "deepSearchDefault"), animated: false)
        }
    }
}
