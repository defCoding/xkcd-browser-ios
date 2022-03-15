//
//  XKCDButton.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/14/22.
//

import UIKit

class XKCDButton: UIButton {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        configuration = .filled()
        tintColor = UIColor(named: "Charcoal")
        layer.cornerRadius = 5
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        guard let title = title else {
            return
        }
        setAttributedTitle(NSAttributedString(string: title,
                                              attributes: [.font: UIFont(name: "xkcdScript", size: 18)!,
                                                           .foregroundColor: UIColor.white]), for: .normal)
    }
}
