//
//  RateThisAppView.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/15/22.
//

import UIKit

class RateThisAppView: UIView {
    @IBAction func openAppStore(_ sender: Any) {
        isHidden = true
        UIApplication.shared.open(URL(string: "https://itunes.apple.com")!)
    }
    
    @IBAction func maybeLater(_ sender: Any) {
        isHidden = true
    }
}
