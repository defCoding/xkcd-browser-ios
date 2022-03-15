//
//  ComicsDataManager.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/12/22.
//

import Foundation

class ComicsDataManager {
    static let sharedInstance = ComicsDataManager()
    private var favoritesModified: Bool
    private var favoritesTree: BinTree<XKCDComic>
    private var _favorites: [XKCDComic]
    var favorites: [XKCDComic] {
        if (favoritesModified) {
            _favorites = favoritesTree.reverseOrderTraversal()
            favoritesModified = false
        }
        return _favorites
    }
    var comicsCache: TwoTierCache<XKCDComic>
    var comicImagesCache: TwoTierCache<Data>
    var latestComicNum: Int {
        didSet {
            UserDefaults.standard.set(latestComicNum, forKey: "latestComicNum")
        }
    }
    
    fileprivate init() {
        favoritesModified = false
        let saveToDisk = !UserDefaults.standard.bool(forKey: "disableDiskCaching")
        comicsCache = TwoTierCache<XKCDComic>(useFileSystem: saveToDisk, cacheDir: "comics")
        comicImagesCache = TwoTierCache<Data>(useFileSystem: saveToDisk, cacheDir: "comicImages")
        latestComicNum = UserDefaults.standard.integer(forKey: "latestComicNum")
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
        favoritesModified = true
    }
   
    /**
     Removes a comic from the favorites.
     
     - Parameters comic:                    The comic to remove
    
     - Returns:                Nothing
     */
    func removeFavorite(comic: XKCDComic) {
        favoritesTree.delete(value: comic)
        favoritesModified = true
    }
    
    /**
     Toggles a comic's favorite status.
     
     - Parameters comic:                    The comic to toggle
     
     - Returns:                True if the comic was favorited, false otherwise
     */
    func toggleFavorite(comic: XKCDComic) -> Bool {
        favoritesModified = true
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
   
    /**
     Removes all comics from the favorites list.
     
     - Returns:                Nothing
     */
    func clearFavorites() {
        favoritesTree = BinTree<XKCDComic>()
        _favorites = []
        saveFavorites()
    }
   
    /**
     Clears the comics and comic images cache.
     
     - Returns:               Nothing
     */
    func clearCache() {
        comicsCache.clearCache()
        comicImagesCache.clearCache()
    }
   
    /**
     Disables disk caching.
     
     - Returns:              Nothing
    */
    func disableDiskCaching() {
        comicsCache.disableDiskCaching()
        comicImagesCache.disableDiskCaching()
    }
}

// https://agostini.tech/2017/06/05/two-tier-caching-with-nscache/
public class TwoTierCache<T> {
    private var primaryCache: RAMCache
    private var secondaryCache: FileCache?
    
    init(useFileSystem: Bool, cacheDir: String?) {
        primaryCache = RAMCache()
        if let cacheDir = cacheDir {
            if useFileSystem {
                secondaryCache = FileCache(cacheDir: cacheDir)
            }
        }
    }
    
    subscript(key: Int) -> T? {
        get {
            var data = primaryCache.load(key: key)
            
            if data == nil {
                guard let fileResult = secondaryCache?.load(key: key) else {
                    return nil
                }
                primaryCache.save(key: key, value: fileResult)
                data = fileResult
            }
            
            do {
                return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data!) as? T
            } catch (let err) {
                print("Error, could not convert data into object: \(err)")
                return nil
            }
        }
        
        set {
            guard let comic = newValue as T? else {
                print("Saving wrong type to cache.")
                return
            }
            do {
                primaryCache.save(key: key, value: try NSKeyedArchiver.archivedData(withRootObject: comic, requiringSecureCoding: false))
                secondaryCache?.save(key: key, value: try NSKeyedArchiver.archivedData(withRootObject: comic, requiringSecureCoding: false))
            } catch (let err) {
                print("Error saving data to cache: \(err)")
            }
        }
    }
    
    func clearCache() {
        primaryCache.clearCache()
        secondaryCache?.clearCache()
    }
    
    func disableDiskCaching() {
        secondaryCache?.clearCache()
        secondaryCache = nil
    }
}

private class RAMCache {
    private let cache: NSCache<NSNumber, NSData>
    
    init() {
        cache = NSCache<NSNumber, NSData>()
    }
    
    func load(key: Int) -> Data? {
        return cache.object(forKey: NSNumber(value: key)) as Data?
    }
    
    func save(key: Int, value: Data?) {
        if let value = value {
            cache.setObject(NSData(data: value), forKey: NSNumber(value: key))
        } else {
            cache.removeObject(forKey: NSNumber(value: key))
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

private class FileCache {
    private let cachePath: String
    private lazy var cacheDir: URL? = {
        var cacheDir: URL? = nil
        do {
            cacheDir = try FileManager
                .default
                .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(cachePath, isDirectory: true)
        } catch (let err) {
            print("Error generating cache directory URL: \(err)")
            return nil
        }
        
        guard let cacheDir = cacheDir else {
            return cacheDir
        }
        
        do {
            try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true, attributes: nil)
        } catch (let err) {
            print("Error creating cache directory: \(err)")
            return nil
        }
        
        return cacheDir
    }()
    
    
    init(cacheDir: String) {
        cachePath = cacheDir
    }
    
    func load(key: Int) -> Data? {
        guard let path = fileURL(key: key) else {
            return nil
        }
        
        return try? Data(contentsOf: path)
    }
    
    func save(key: Int, value: Data?) {
        guard let path = fileURL(key: key) else {
            return
        }
        
        if let value = value as Data? {
            do {
                try NSData(data: value).write(to: path, options: .atomic)
            } catch (let err) {
                print("Error writing data to file: \(err)")
            }
        } else {
            try? FileManager.default.removeItem(at: path)
        }
    }
    
    func clearCache() {
        guard let cacheDir = cacheDir else {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: cacheDir)
        } catch (let err) {
            print("Error deleting caches directory: \(err)")
        }
    }
    
    private func fileURL(key: Int) -> URL? {
        guard let cacheDir = cacheDir else {
            return nil
        }
        
        return cacheDir.appendingPathComponent(String(key))
    }
}
