//
//  RateThisAppView.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/15/22.
//

import UIKit

/// View for asking users to rate the app in the app store
class RateThisAppView: UIView {
    @objc func openAppStorePressed(_ sender: Any) {
        isHidden = true
        UIApplication.shared.open(URL(string: "https://apps.apple.com/us/app/xkcd-browser/id1618306887")!)
    }
    
    @objc func maybeLaterPressed(_ sender: Any) {
        isHidden = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 310, height: 202))
        setupView()
    }
   
    /// Sets up the view's attributes
    private func setupView() {
        self.layer.borderColor = UIColor(named: "ElectricBlue")?.cgColor
        self.layer.borderWidth = 2
        self.backgroundColor = UIColor(named: "Marble")
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 310),
            self.heightAnchor.constraint(equalToConstant: 202),
        ])
        
        setupText()
        setupButtons()
    }
   
    /// Sets up the text
    private func setupText() {
        let textLabel = UILabel()
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.text = "If you're enjoying the XKCD Reader, it would help a lot if you could leave a review for us on the App Store!"
        textLabel.font = UIFont(name: "xkcdScript", size: 18)
        textLabel.textColor = .black
        addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -65),
        ])
    }
   
    /// Sets up the go to app store button and maybe later button
    private func setupButtons() {
        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        
        let appStoreButton = XKCDButton()
        appStoreButton.setTitle("Go to App Store", fontSize: 15, for: .normal)
        appStoreButton.addTarget(self, action: #selector(openAppStorePressed(_:)), for: .touchUpInside)
        
        let closeButton = XKCDButton()
        closeButton.setTitle("Maybe Later", fontSize: 15, for: .normal)
        closeButton.addTarget(self, action: #selector(maybeLaterPressed(_:)), for: .touchUpInside)
       
        buttonStack.addArrangedSubview(appStoreButton)
        buttonStack.addArrangedSubview(closeButton)
        addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            buttonStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15),
            buttonStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            buttonStack.widthAnchor.constraint(equalToConstant: 269),
            buttonStack.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
}
