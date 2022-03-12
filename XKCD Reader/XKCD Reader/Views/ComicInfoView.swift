//
//  ComicInfoView.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/11/22.
//

import UIKit

class ComicInfoView: UIView {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var altText: UITextView!
    
    func updateComic(comic : XKCDComic) {
        dateLabel.text = "\(comic.month)/\(comic.day)/\(comic.year)"
        altText.text = comic.alt
    }
}
