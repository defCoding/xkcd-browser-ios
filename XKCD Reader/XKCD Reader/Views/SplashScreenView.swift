//
//  SplashScreenView.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/16/22.
//

import UIKit

/// View for splash screen on application launch.
class SplashScreenView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.translatesAutoresizingMaskIntoConstraints = false
        commonInit()
    }
   
    /// Initializes view and subviews
    func commonInit() {
        self.layer.zPosition = 1
        self.backgroundColor = UIColor(named: "ElectricBlue")
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        
        let appLabel = UILabel()
        appLabel.text = "XKCD Browser"
        appLabel.font = UIFont(name: "xkcdScript", size: 36)
        appLabel.sizeToFit()
        // appLabel.translatesAutoresizingMaskIntoConstraints = false
       
        let imageView = UIImageView(image: UIImage(named: "ladder_people"))
        imageView.contentMode = .scaleAspectFit
        
        stack.addArrangedSubview(appLabel)
        stack.addArrangedSubview(imageView)
        
        self.addSubview(appLabel)
        self.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 140),
            self.centerYAnchor.constraint(equalTo: imageView.topAnchor, constant: 30),
            self.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            appLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -10),
            self.centerXAnchor.constraint(equalTo: appLabel.centerXAnchor),
        ])
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = superview else {
            return
        }
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.topAnchor),
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        ])
    }
}
