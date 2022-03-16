//
//  ComicInfoView.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/11/22.
//

import UIKit

/// View for displaying comic details (date and alt text)
class ComicInfoView: UIView {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var altText: UITextView!
   
    /**
     Updates the info view with a new comic's details.
     
     - Parameter comic:             The comic to update with
     */
    func updateComic(comic : XKCDComic) {
        dateLabel.text = "\(comic.month)/\(comic.day)/\(comic.year)"
        altText.text = comic.alt
    }
}
