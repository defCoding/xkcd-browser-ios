//
//  ClearCacheTableViewCell.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/14/22.
//

import UIKit

class ClearCacheTableViewCell: SettingTableViewCell {
    @objc func clearClicked(_ sender: Any?) {
        ComicsDataManager.sharedInstance.clearCache()
    }
    
    override func commonInit() {
        super.commonInit()
        label = UILabel()
        secondaryView = XKCDButton()
    }
    
    override func setupViews() {
        super.setupViews()
        label!.text = "Clear App Cache"
        
        if let clearButton = secondaryView as? XKCDButton {
            clearButton.setTitle("Clear", for: .normal)
            clearButton.addTarget(self, action: #selector(clearClicked(_:)), for: .touchUpInside)
        }
    }
}
