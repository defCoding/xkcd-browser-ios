//
//  XKCDButton.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/14/22.
//

import UIKit

class XKCDSwitch: UISwitch {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        onTintColor = UIColor(named: "Marble")
        thumbTintColor = isOn ? UIColor(named: "Charcoal") : .gray
        addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
    }
    
    override func setOn(_ on: Bool, animated: Bool) {
        super.setOn(on, animated: animated)
        thumbTintColor = isOn ? UIColor(named: "Charcoal") : .gray
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        // Update thumb tint color based on switch state.
        thumbTintColor = isOn ? UIColor(named: "Charcoal") : .gray
    }
    
}
