//
//  ComicsDataManager.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/12/22.
//

import Foundation

class ComicsDataManager {
    static let sharedInstance = ComicsDataManager()
    private var modified: Bool
    private var favoritesTree: BinTree<XKCDComic>
    private var _favorites: [XKCDComic]
    var favorites: [XKCDComic] {
        if (modified) {
            _favorites = favoritesTree.reverseOrderTraversal()
            modified = false
        }
        return _favorites
    }
    
    fileprivate init() {
        modified = false
        // https://cocoacasts.com/ud-5-how-to-store-a-custom-object-in-user-defaults-in-swift
        if let data = UserDefaults.standard.data(forKey: "favorites") {
            do {
                let decoder = JSONDecoder()
                let comics = try decoder.decode([XKCDComic].self, from: data)
                favoritesTree = BinTree<XKCDComic>(sortedData: comics)
                _favorites = favoritesTree.reverseOrderTraversal()
                return
            } catch (let err) {
                print("Error loading favorites: \(err)")
            }
        }
        favoritesTree = BinTree<XKCDComic>()
        _favorites = []
    }
   
    /**
     Saves the favorited comics to UserDefaults.
     */
    func saveFavorites() {
        // https://cocoacasts.com/ud-5-how-to-store-a-custom-object-in-user-defaults-in-swift
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(favorites)
            UserDefaults.standard.set(data, forKey: "favorites")
        } catch (let err) {
            print("Error saving favorites: \(err)")
        }
    }
   
    /**
     Favorites a comic.
     
     - Parameters comic:                    The comic to favorite
     
     - Returns:                Nothing
     */
    func addFavorite(comic: XKCDComic) {
        favoritesTree.insert(value: comic)
        modified = true
    }
   
    /**
     Removes a comic from the favorites.
     
     - Parameters comic:                    The comic to remove
    
     - Returns:                Nothing
     */
    func removeFavorite(comic: XKCDComic) {
        favoritesTree.delete(value: comic)
        modified = true
    }
    
    /**
     Toggles a comic's favorite status.
     
     - Parameters comic:                    The comic to toggle
     
     - Returns:                True if the comic was favorited, false otherwise
     */
    func toggleFavorite(comic: XKCDComic) -> Bool {
        modified = true
        if favoritesTree.contains(value: comic) {
            removeFavorite(comic: comic)
            return false
        } else {
            addFavorite(comic: comic)
            return true
        }
    }
   
    /**
     Checks if a comic is favorited.
     
     - Parameters comic:                    The comic to check
     
     - Returns:                True if the comic is favorited, false otherwise.
     */
    func isFavorite(comic: XKCDComic) -> Bool {
        return favoritesTree.contains(value: comic)
    }
}
