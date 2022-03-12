//
//  ComicViewController.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/11/22.
//

import UIKit

class ComicViewController: UIViewController {
    @IBOutlet weak var comicImageView: PanZoomImageView!
    
    var num = 0 {
        didSet {
            XKCDClient.fetchComic(num: num) { (comic, err) -> Void in
                guard let comic = comic, err == nil else {
                    return
                }
                self.comic = comic
            }
        }
    }
    var comic: XKCDComic? = nil {
        didSet {
            if let comic = comic {
                XKCDClient.fetchComicImage(comic: comic) { (image, err) -> Void in
                    guard let image = image, err == nil else {
                        return
                    }
                    self.comicImageView?.image = image
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // When comic leaves the view, reset the zoom.
        comicImageView.zoomScale = 1
    }
   
    /**
     Returns an instance of a ComicViewController with the given comic number.
     
     - Parameter comicNum:              The number of the comic to be stored in the view controller
     
     - Returns:                         A view controller containing the specified comic
     */
    static func getInstance(comicNum : Int) -> ComicViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "comicViewController") as! ComicViewController
        vc.num = comicNum
        return vc
    }
}
