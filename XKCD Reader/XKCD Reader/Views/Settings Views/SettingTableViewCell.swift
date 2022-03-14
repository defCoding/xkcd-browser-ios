//
//  SettingTableViewCell.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/14/22.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    var label: UILabel?
    var actionView: UIView?
    
    func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        label?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        label?.font = UIFont(name: "xkcdScript", size: 18)
        actionView?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8).isActive = true
    }
}
