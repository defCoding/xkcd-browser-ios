//
//  XKCDButton.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/14/22.
//

import UIKit

/// Stylized button for XKCD reader
class XKCDButton: UIButton {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
   
    /// Set up attributes
    func setupView() {
        configuration = .filled()
        tintColor = UIColor(named: "Charcoal")
        layer.cornerRadius = 5
    }
   
    /**
     Sets an attribute title in the XKCD font
     
     - Parameter title:             The new title
     - Parameter fontSize:          The size of the font
     - Parameter for:               The state of the button to set the title for
     */
    func setTitle(_ title: String?, fontSize: CGFloat, for state: UIControl.State) {
        guard let title = title else {
            return
        }
        setAttributedTitle(NSAttributedString(string: title,
                                              attributes: [.font: UIFont(name: "xkcdScript", size: fontSize)!,
                                                           .foregroundColor: UIColor.white]), for: .normal)
    }
}
