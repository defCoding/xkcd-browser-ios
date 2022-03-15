//
//  SettingTableViewCell.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/14/22.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    var label: UILabel?
    var secondaryView: UIView?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        setupViews()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
        setupViews()
    }
   
    func commonInit() {
        self.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    func refreshWithUserDefaults() { }
    
    func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        if let label = label {
            self.contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16).isActive = true
            label.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
            label.font = UIFont(name: "xkcdScript", size: 18)
            
        }
        
        if let secondaryView = secondaryView {
            self.contentView.addSubview(secondaryView)
            secondaryView.translatesAutoresizingMaskIntoConstraints = false
            secondaryView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
            secondaryView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        }
        
        refreshWithUserDefaults()
    }
}
