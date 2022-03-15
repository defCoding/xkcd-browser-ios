//
//  RateThisAppView.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/15/22.
//

import UIKit

class RateThisAppView: UIView {
    @IBAction func buttonPressed(_ sender: Any) {
        isHidden = true
        UIApplication.shared.open(URL(string: "itms-app://apple.com")!)
    }
}
