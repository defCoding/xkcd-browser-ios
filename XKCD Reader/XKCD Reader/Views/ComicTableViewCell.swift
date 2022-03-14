//
//  ComicTableViewCell.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/12/22.
//

import UIKit

class ComicTableViewCell: UITableViewCell {
    @IBOutlet weak var comicPreviewImage: UIImageView!
    @IBOutlet weak var comicTitleLabel: UILabel!
    @IBOutlet weak var comicNumberLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    var comic: XKCDComic?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
    /**
     Sets up the cell with a comic.
     
     - Parameter comic:                 Comic to display in the cell
     
     - Returns:                         Nothing
     */
    func setup(comic: XKCDComic) {
        self.comic = comic
        comicTitleLabel.text = comic.title
        comicNumberLabel.text = "#\(comic.num)"
        XKCDClient.fetchComicImage(comic: comic) { (img, err) in
            self.comicPreviewImage.image = img
        }
        updateFavoritesButtonColor(favorited: ComicsDataManager.sharedInstance.isFavorite(comic: comic))
    }
    
    @IBAction func favoriteClicked(_ sender: Any) {
        guard let comic = self.comic else {
            return
        }
        updateFavoritesButtonColor(favorited: ComicsDataManager.sharedInstance.toggleFavorite(comic: comic))
    }
    
    /**
     Updates the favorites button to match the favorited state.
     
     - Parameter favorited:         Whether or not the comic is favorited
     
     - Returns:                     Nothing
     */
    private func updateFavoritesButtonColor(favorited: Bool) {
        let heartImage: UIImage?
        if favorited {
            heartImage = UIImage(systemName: "heart.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        } else {
            heartImage = UIImage(systemName: "heart")?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
        }
        favoriteButton.setImage(heartImage, for: .normal)
    }
}
