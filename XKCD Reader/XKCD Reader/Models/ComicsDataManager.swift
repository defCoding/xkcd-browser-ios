//
//  ComicsDataManager.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/12/22.
//

import Foundation

/// The singleton data manager containing the cached comics and the favorited comics
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
    var latestComicNum: Int {
        didSet {
            UserDefaults.standard.set(latestComicNum, forKey: "latestComicNum")
        }
    }
    
    fileprivate init() {
        favoritesModified = false
        let saveToDisk = !UserDefaults.standard.bool(forKey: "disableDiskCaching")
        comicsCache = TwoTierCache<XKCDComic>(useFileSystem: saveToDisk, cacheDir: "comics")
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
                print("ERROR -- could not load favorites: \(err)")
            }
        }
        favoritesTree = BinTree<XKCDComic>()
        _favorites = []
    }
   
    /// Saves the favorited comics to UserDefaults.
    func saveFavorites() {
        // https://cocoacasts.com/ud-5-how-to-store-a-custom-object-in-user-defaults-in-swift
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(favorites)
            UserDefaults.standard.set(data, forKey: "favorites")
        } catch (let err) {
            print("ERROR -- could not save favorites: \(err)")
        }
    }
   
    /**
     Favorites a comic.
     
     - Parameters comic:                    The comic to favorite
     */
    func addFavorite(comic: XKCDComic) {
        favoritesTree.insert(value: comic)
        favoritesModified = true
    }
   
    /**
     Removes a comic from the favorites.
     
     - Parameters comic:                    The comic to remove
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
   
    /// Removes all comics from the favorites list.
    func clearFavorites() {
        favoritesTree = BinTree<XKCDComic>()
        _favorites = []
        saveFavorites()
    }
   
    /// Clears the comics and comic images cache.
    func clearCache() {
        comicsCache.clearCache()
    }
   
    /// Disables disk caching.
    func disableDiskCaching() {
        comicsCache.disableDiskCaching()
    }
   
    /// Enables disk caching.
    func enableDiskCaching() {
        comicsCache.enableDiskCaching()
    }
}

// https://agostini.tech/2017/06/05/two-tier-caching-with-nscache/
/// A TwoTierCache that caches both in memory and into disk (optional)
class TwoTierCache<T: NSObject & NSCoding> {
    private var cacheDir: String?
    var ramCache: RAMCache
    var diskCache: FileCache?
    
    init(useFileSystem: Bool, cacheDir: String?) {
        ramCache = RAMCache()
        if let cacheDir = cacheDir {
            self.cacheDir = cacheDir
            if useFileSystem {
                diskCache = FileCache(cacheDir: cacheDir)
            }
        }
    }
    
    subscript(key: Int) -> T? {
        get {
            var data = ramCache.load(key: key)
            
            if data == nil {
                guard let fileResult = diskCache?.load(key: key) else {
                    return nil
                }
                ramCache.save(key: key, value: fileResult)
                data = fileResult
            } else {
                print("DEBUG -- fetched comic #\(key) from memory cache")
            }
            
            do {
                return try NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: data!)
            } catch (let err) {
                print("ERROR -- could not convert data into object: \(err)")
                return nil
            }
        }
        
        set {
            guard let comic = newValue as T? else {
                print("ERROR -- saving wrong type to cache.")
                return
            }
            do {
                print("DEBUG -- saving comic #\(key) to cache")
                ramCache.save(key: key, value: try NSKeyedArchiver.archivedData(withRootObject: comic, requiringSecureCoding: false))
                diskCache?.save(key: key, value: try NSKeyedArchiver.archivedData(withRootObject: comic, requiringSecureCoding: false))
            } catch (let err) {
                print("ERROR -- could not save data to cache: \(err)")
            }
        }
    }
   
    /// Clears both caches
    func clearCache() {
        DispatchQueue.main.async {
            self.ramCache.clearCache()
            self.diskCache?.clearCache()
        }
    }
   
    /// Disables the disk cache and clears it
    func disableDiskCaching() {
        diskCache?.clearCache()
        diskCache = nil
    }
   
    /// Enables the disk cache
    func enableDiskCaching() {
        if let cacheDir = cacheDir, diskCache == nil {
            diskCache = FileCache(cacheDir: cacheDir)
        }
    }
}

class RAMCache {
    private let cache: NSCache<NSNumber, NSData>
    
    init() {
        cache = NSCache<NSNumber, NSData>()
    }
   
    /**
     Loads a value from memory given the key
     
     - Parameter key:               The key for the value
     
     - Returns:                     The value matching the key
     */
    func load(key: Int) -> Data? {
        return cache.object(forKey: NSNumber(value: key)) as Data?
    }
   
    /**
     Saves a  value to memory given the key
     
     - Parameter key:               The key for the value
     - Parameter value:             The value for the key
     */
    func save(key: Int, value: Data?) {
        if let value = value {
            cache.setObject(NSData(data: value), forKey: NSNumber(value: key))
        } else {
            cache.removeObject(forKey: NSNumber(value: key))
        }
    }
   
    /// Clears the cache from memory
    func clearCache() {
        cache.removeAllObjects()
    }
}

class FileCache {
    private let cachePath: String
    
    init(cacheDir: String) {
        cachePath = cacheDir
    }
   
    /**
     Loads a value from disk given the key
     
     - Parameter key:               The key for the value
     
     - Returns:                     The value matching the key
     */
    func load(key: Int) -> Data? {
        guard let path = fileURL(key: key) else {
            return nil
        }
        
        print("DEBUG -- fetching comic #\(key) from disk at path \(path)")
        return try? Data(contentsOf: path)
    }
    
    /**
     Saves a  value to disk given the key
     
     - Parameter key:               The key for the value
     - Parameter value:             The value for the key
     */
    func save(key: Int, value: Data?) {
        guard let path = fileURL(key: key) else {
            return
        }
        
        if let value = value as Data? {
            do {
                try NSData(data: value).write(to: path, options: .atomic)
            } catch (let err) {
                print("ERROR -- could not write data to file: \(err)")
            }
        } else {
            try? FileManager.default.removeItem(at: path)
        }
    }
   
    /// Clears the cache from disk
    func clearCache() {
        guard let cacheDir = getCacheDir() else {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: cacheDir)
        } catch (let err) {
            print("ERROR -- could not delete caches directory: \(err)")
        }
    }
   
    /**
     Fetches the corresponding file URL for a key.
     
     - Parameter key:           The key to fetch
     
     - Returns:                 The corresponding URL
     */
    private func fileURL(key: Int) -> URL? {
        guard let cacheDir = getCacheDir() else {
            return nil
        }
        
        return cacheDir.appendingPathComponent(String(key))
    }
   
    /**
     Fetches the cache directory from disk.
     
     - Returns:                 The URL of the disk cache
     */
    private func getCacheDir() -> URL? {
        var cacheDir: URL? = nil
        do {
            cacheDir = try FileManager
                .default
                .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(cachePath, isDirectory: true)
        } catch (let err) {
            print("ERROR -- could not generate cache directory URL: \(err)")
            return nil
        }
        
        guard let cacheDir = cacheDir else {
            return nil
        }
        
        do {
            try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true, attributes: nil)
        } catch (let err) {
            print("ERROR -- could not create cache directory: \(err)")
            return nil
        }
        
        return cacheDir
    }
}
