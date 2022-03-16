//
//  XKCDButton.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/14/22.
//

import UIKit

/// Stylized switch for XKCD Reader
class XKCDSwitch: UISwitch {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
   
    /// Sets up attributes of rswitch
    func setupView() {
        // https://padamthapa.com/blog/how-to-change-color-of-uiswitch-in-off-state/
        // Adjust switch background color.
        let minSide = min(bounds.size.height, bounds.size.width)
        layer.cornerRadius = minSide / 2
        backgroundColor = .darkGray
        
        onTintColor = UIColor(named: "Marble")
        thumbTintColor = isOn ? UIColor(named: "Charcoal") : UIColor(named: "Marble")
        addTarget(self, action: #selector(switchChanged(_:)), for: .touchUpInside)
    }
   
    override func setOn(_ on: Bool, animated: Bool) {
        super.setOn(on, animated: animated)
        thumbTintColor = isOn ? UIColor(named: "Charcoal") : UIColor(named: "Marble")
    }
   
    /// Handler for when switch has changed. Used to change colors
    @objc func switchChanged(_ sender: UISwitch) {
        // Update thumb tint color based on switch state.
        thumbTintColor = isOn ? UIColor(named: "Charcoal") : UIColor(named: "Marble")
    }
    
}
