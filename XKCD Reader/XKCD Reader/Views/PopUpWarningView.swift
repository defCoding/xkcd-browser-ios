//
//  PopUpWarning.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/16/22.
//

import UIKit

/// Pop up warning view with custom text and action
class PopUpWarningView: UIView {
    var warningText: String?
    var onOk: () -> Void?
    var onCancel: (() -> Void)?
    
    /// Handler for ok button press
    @objc func onOkPressed(_ sender: Any) {
        removeFromSuperview()
        onOk()
    }
   
    /// Handler for cancel button press
    @objc func onCancelPressed(_ sender: Any) {
        removeFromSuperview()
        onCancel?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) was not implemented")
    }
    
    init(text: String, onOk: @escaping () -> Void, onCancel: (() -> Void)? = nil) {
        self.warningText = text
        self.onOk = onOk
        self.onCancel = onCancel
        super.init(frame: CGRect(x: 0, y: 0, width: 310, height: 202))
        setupView()
    }
    
    override func didMoveToSuperview() {
        guard let superview = superview else {
           return
        }
        
        self.center = superview.center
    }
   
    /// Sets up the view's attributes
    private func setupView() {
        self.layer.borderColor = UIColor(named: "ElectricBlue")?.cgColor
        self.layer.borderWidth = 2
        self.backgroundColor = UIColor(named: "Marble")
        
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
        textLabel.text = self.warningText
        textLabel.font = UIFont(name: "xkcdScript", size: 20)
        addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -65),
        ])
    }
   
    /// Sets up the ok and cancel buttons
    private func setupButtons() {
        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        
        let okButton = XKCDButton()
        okButton.setTitle("Yes", fontSize: 18, for: .normal)
        okButton.addTarget(self, action: #selector(onOkPressed(_:)), for: .touchUpInside)
        
        let cancelButton = XKCDButton()
        cancelButton.setTitle("Cancel", fontSize: 18, for: .normal)
        cancelButton.addTarget(self, action: #selector(onCancelPressed(_:)), for: .touchUpInside)
       
        buttonStack.addArrangedSubview(okButton)
        buttonStack.addArrangedSubview(cancelButton)
        addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            buttonStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15),
            buttonStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            buttonStack.widthAnchor.constraint(equalToConstant: 269),
            buttonStack.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
}
