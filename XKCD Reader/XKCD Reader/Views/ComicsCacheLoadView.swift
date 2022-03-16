//
//  ComicsCacheLoadView.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/15/22.
//

import UIKit

/// View for showing progress bar when caching all comics
class ComicsCacheLoadView: UIView {
    var progressBar: UIProgressView!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        setupView()
    }
   
    /// Handler for when hide button is pressed
    @objc func hidePressed(_ sender: Any?) {
        isHidden = true
    }
   
    /// Sets up the view's attributes and subviews
    private func setupView() {
        self.layer.borderColor = UIColor(named: "ElectricBlue")?.cgColor
        self.layer.borderWidth = 2
        self.backgroundColor = UIColor(named: "Marble")
        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progressTintColor = UIColor(named: "Charcoal")
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "xkcdScript", size: 18)
        label.textColor = .black
        label.text = "Fetching and caching comics..."
        
        let hideButton = XKCDButton()
        hideButton.setTitle("Hide", fontSize: 16, for: .normal)
        hideButton.addTarget(self, action: #selector(hidePressed(_:)), for: .touchUpInside)
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 5
        
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(progressBar)
        stack.addArrangedSubview(hideButton)
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: 8),
            progressBar.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            stack.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
