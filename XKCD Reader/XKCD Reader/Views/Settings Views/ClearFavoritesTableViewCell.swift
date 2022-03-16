//
//  ClearFavoritesTableViewCell.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/14/22.
//

import UIKit

/// Clearing favorites table cell
class ClearFavoritesTableViewCell: SettingTableViewCell {
    @objc func clearClicked(_ sender: Any?) {
        // Fetch settings table view and place in center of that
        guard let superview = superview?.superview else {
            return
        }
       
        let warningPopup = PopUpWarningView(text: "This will clear all favorited comics. Are you sure you want to continue?") {
            ComicsDataManager.sharedInstance.clearFavorites()
        }
        superview.addSubview(warningPopup)
    }
    
    override func commonInit() {
        super.commonInit()
        label = UILabel()
        secondaryView = XKCDButton()
    }
    
    override func setupViews() {
        super.setupViews()
        label!.text = "Clear Favorites"
        
        if let clearButton = secondaryView as? XKCDButton {
            clearButton.setTitle("Clear", fontSize: 18, for: .normal)
            clearButton.addTarget(self, action: #selector(clearClicked(_:)), for: .touchUpInside)
        }
    }
}
