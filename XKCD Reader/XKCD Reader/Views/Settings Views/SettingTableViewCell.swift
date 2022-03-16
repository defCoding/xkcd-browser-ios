//
//  SettingTableViewCell.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/14/22.
//

import UIKit

/// Abstraction for TableViewCells of the Settings table. Displays a label to the left and some secondary view on the right.
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
  
    /// Initializer for initializing label and secondary view. Subclasses should initialize subviews here.
    func commonInit() { }
   
    /// Function called to update controls with UserDefaults values. Subclasses should use this to update their subviews.
    func refreshWithUserDefaults() { }
   
    /// Sets up subviews attributes and constraints
    func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        if let label = label {
            self.contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                // label.topAnchor.constraint(equalTo: self.topAnchor, constant: 3),
                // label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3),
                label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
                label.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
            label.font = UIFont(name: "xkcdScript", size: 18)
        }
        
        if let secondaryView = secondaryView {
            self.contentView.addSubview(secondaryView)
            secondaryView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                secondaryView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
                secondaryView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
        }
       
        refreshWithUserDefaults()
    }
}
