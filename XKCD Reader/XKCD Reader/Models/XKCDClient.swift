//
//  XKCDClient.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/11/22.
//

import Foundation
import UIKit

// TODO: come back here to adjust this
enum XKCDError: Error {
    case badURL
    case noComicFound
}

/// An XKCD Comic constructed from the JSON reply of an API response
class XKCDComic: Codable {
    let num : Int
    let month : String
    let day : String
    let year : String
    let title : String
    let safeTitle : String
    let alt : String
    let img : String
}

class XKCDClient {
    static let comicCache = NSCache<NSNumber, XKCDComic>()
    static let comicImageCache = NSCache<NSURL, UIImage>()
    static var latestComicNum = 0
    /**
     Fetches an XKCD comic.
     
     - Parameter num:           The number of the comic to fetch (fetches the most recent one if none is provided)
     - Parameter completion:    The callback function for when the comic is fetched
     
     - Returns:                 Nothing
     */
    static func fetchComic(num: Int?, completion: @escaping (XKCDComic?, Error?) -> Void) {
        var url : NSURL? = nil
        // If no comic number is provided, fetch the latest.
        if let num = num {
            // Look for cached comic to save on API calls.
            if let cachedComic = comicCache.object(forKey: NSNumber(value: num)) {
                DispatchQueue.main.async { completion(cachedComic, nil) }
                return
            }
            url = NSURL(string: "https://xkcd.com/\(num)/info.0.json")
        } else {
            url = NSURL(string: "https://xkcd.com/info.0.json")
        }
        
        guard let url = url else {
            DispatchQueue.main.async { completion(nil, XKCDError.badURL) }
            return
        }
        
        let task = URLSession.shared.dataTask(with: url as URL) { (data, response, error) -> Void in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let comic = try decoder.decode(XKCDComic.self, from: data)
                comicCache.setObject(comic, forKey: NSNumber(value: comic.num))
                DispatchQueue.main.async { completion(comic, nil) }
            } catch (let err) {
                DispatchQueue.main.async { completion(nil, err) }
            }
        }
    
        task.resume()
    }
   
    /**
     Fetches a comic's image as a UIImage.
     
     - Parameter comic:         The comic to fetch the image of
     - Parameter completion:    The callback function for when the image is fetched
     
     - Returns:                 Nothing
     */
    static func fetchComicImage(comic: XKCDComic, completion: @escaping (UIImage?, Error?) -> Void) {
        guard let url = NSURL(string: comic.img) else {
            DispatchQueue.main.async { completion(nil, XKCDError.badURL) }
            return
        }
        
        if let cachedComicImage = comicImageCache.object(forKey: url) {
            DispatchQueue.main.async { completion(cachedComicImage, nil) }
            return
        }
        
        let task = URLSession.shared.dataTask(with: url as URL) { (data, response, error) -> Void in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            
            if let comicImage = UIImage(data: data) {
                comicImageCache.setObject(comicImage, forKey: url)
                DispatchQueue.main.async { completion(comicImage, nil) }
            } else {
                DispatchQueue.main.async { completion(nil, error) }
            }
        }
        
        task.resume()
    }
}
