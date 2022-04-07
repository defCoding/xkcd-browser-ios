//
//  XKCDClient.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/11/22.
//

import Foundation
import UIKit

enum XKCDError: Error {
    case badURL
    case imageNotFound
}

/// An XKCD Comic constructed from the JSON reply of an API response
class XKCDComic: NSObject, NSSecureCoding, Codable {
    static var supportsSecureCoding: Bool = true
    
    init(num: Int, month: String, day: String, year: String, title: String, transcript: String, alt: String, img: String, imgData: Data?) {
        self.num = num
        self.month = month
        self.day = day
        self.year = year
        self.title = title
        self.transcript = transcript
        self.alt = alt
        self.img = img
        self.imgData = imgData
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(NSInteger(num), forKey: "num")
        coder.encode(month as NSString, forKey: "month")
        coder.encode(day as NSString, forKey: "day")
        coder.encode(year as NSString, forKey: "year")
        coder.encode(title as NSString, forKey: "title")
        coder.encode(transcript as NSString, forKey: "transcript")
        coder.encode(alt as NSString, forKey: "alt")
        coder.encode(img as NSString, forKey: "img")
        if let imgData = imgData {
            coder.encode(NSData(data: imgData), forKey: "imgData")
        }
    }
    
    required convenience init?(coder: NSCoder) {
        let num = coder.decodeInteger(forKey: "num")
        let imgData = coder.decodeObject(of: NSData.self, forKey: "imgData")
        
        guard let month = coder.decodeObject(of: NSString.self, forKey: "month"),
              let day = coder.decodeObject(of: NSString.self, forKey: "day"),
              let year = coder.decodeObject(of: NSString.self, forKey: "year"),
              let title = coder.decodeObject(of: NSString.self, forKey: "title"),
              let transcript = coder.decodeObject(of: NSString.self, forKey: "transcript"),
              let alt = coder.decodeObject(of: NSString.self, forKey: "alt"),
              let img = coder.decodeObject(of: NSString.self, forKey: "img") else {
                  return nil
              }
        
        self.init(num: num,
                  month: month as String,
                  day: day as String,
                  year: year as String,
                  title: title as String,
                  transcript: transcript as String,
                  alt: alt as String,
                  img: img as String,
                  imgData: imgData as Data?)
    }
    
    let num: Int
    let month: String
    let day: String
    let year: String
    let title: String
    let transcript: String
    let alt: String
    let img: String
    var imgData: Data?
}

extension XKCDComic: Comparable {
    static func <(lhs: XKCDComic, rhs: XKCDComic) -> Bool {
        return lhs.num < rhs.num
    }
    
    static func ==(lhs: XKCDComic, rhs: XKCDComic) -> Bool {
        return lhs.num == rhs.num
    }
}

/// An XKCDClient for fetching comic data.
class XKCDClient {
    /**
     Fetches an XKCD comic.
     
     - Parameter num:                       The number of the comic to fetch (fetches the most recent one if none is provided)
     - Parameter completion:                The callback function for when the comic is fetched
     */
    static func fetchComic(num: Int?, completion: ((XKCDComic?, Error?) -> Void)? = nil) {
        var url : NSURL? = nil
        // If no comic number is provided, fetch the latest.
        if let num = num {
            // Look for cached comic to save on API calls.
            if let cachedComic = ComicsDataManager.sharedInstance.comicsCache[num] {
                DispatchQueue.main.async { completion?(cachedComic, nil) }
                return
            }
            url = NSURL(string: "https://xkcd.com/\(num)/info.0.json")
        } else {
            url = NSURL(string: "https://xkcd.com/info.0.json")
        }
        
        guard let url = url else {
            DispatchQueue.main.async { completion?(nil, XKCDError.badURL) }
            return
        }
       
        NSLog("%@", "DEBUG -- fetching comic from \(url)")
        let task = URLSession.shared.dataTask(with: url as URL) { (data, response, error) -> Void in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion?(nil, error) }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let comic = try decoder.decode(XKCDComic.self, from: data)
                fetchComicImage(comic: comic) { (imgData, error) in
                    guard let imgData = imgData, error == nil else {
                        DispatchQueue.main.async { completion?(nil, XKCDError.imageNotFound) }
                        return
                    }
                    comic.imgData = imgData
                    ComicsDataManager.sharedInstance.comicsCache[comic.num] = comic
                    DispatchQueue.main.async { completion?(comic, nil) }
                }
            } catch (let err) {
                DispatchQueue.main.async { completion?(nil, err) }
            }
        }
    
        task.resume()
    }
   
    /**
     Fetches a comic's image as a UIImage.
     
     - Parameter comic:                     The comic to fetch the image of
     - Parameter completion:                The callback function for when the image is fetched
     */
    private static func fetchComicImage(comic: XKCDComic, completion: @escaping (Data?, Error?) -> Void) {
        guard let url = NSURL(string: comic.img) else {
            DispatchQueue.main.async { completion(nil, XKCDError.badURL) }
            return
        }
        
        NSLog("%@", "DEBUG -- fetching comic image from \(url)")
        let task = URLSession.shared.dataTask(with: url as URL) { (data, response, error) -> Void in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            DispatchQueue.main.async { completion(data, nil) }
        }
        
        task.resume()
    }
   
    /**
     Caches all the comics to disk
     
     - Parameter progress:                  Callback function as progress gets updated
     - Parameter completion:                Callback function when all comics are cached
     */
    static func cacheAllComicsToDisk(progress: ((Float) -> Void?)? = nil, completion: (() -> Void)? = nil) {
        let group = DispatchGroup()
        var totalCached: Double = 0
        let totalSemaphore = DispatchSemaphore(value: 1)
        
        for comicNum in (1...ComicsDataManager.sharedInstance.latestComicNum).reversed() {
            group.enter()
            fetchComic(num: comicNum) { (_, _) in
                totalSemaphore.wait()
                totalCached += 1
                progress?(Float(totalCached / Double(ComicsDataManager.sharedInstance.latestComicNum)))
                totalSemaphore.signal()
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion?()
        }
    }
   
    /**
     Returns a list of comics matching a search query.
     
     - Parameter query:                     The query string
     - Parameter deepSearch:                Whether or not to perform a deep search (regular search only checks title and number)
     - Parameter completion:                The callback function for when comics are fetched
     */
    static func fetchSearchComics(query: String, deepSearch: Bool, completion: @escaping ([XKCDComic]?, Error?) -> Void) {
        // https://stackoverflow.com/questions/35906568/wait-until-swift-for-loop-with-asynchronous-network-requests-finishes-executing
        let group = DispatchGroup()
        var comics: [XKCDComic] = []
        let comicsSemaphore = DispatchSemaphore(value: 1)
        var sortRating: [Int: Int] = [:]
        
        for comicNum in (1...ComicsDataManager.sharedInstance.latestComicNum).reversed() {
            group.enter()
            fetchComic(num: comicNum) { (comic, err) in
                guard let comic = comic, err == nil else {
                    group.leave()
                    return
                }
               
                let options: String.CompareOptions = [
                    .diacriticInsensitive,
                    .caseInsensitive,
                ]
               
                /*
                 Ordering of relevancy from most relevant to search query to least:
                 1. Comic number matches
                 2. Comic title contains match
                 3. Comic transcript contains match
                 4. Comic alt text contains match
                 */
                var matched = false
                if String(comic.num) == query {
                    sortRating[comic.num] = 3
                    matched = true
                } else if comic.title.range(of: query, options: options) != nil {
                    sortRating[comic.num] = 2
                    matched = true
                }
                
                if deepSearch && !matched {
                    if comic.transcript.range(of: query, options: options) != nil {
                        sortRating[comic.num] = 1
                        matched = true
                    } else if comic.alt.range(of: query, options: options) != nil {
                        sortRating[comic.num] = 0
                        matched = true
                    }
                }
                
                if matched {
                    comicsSemaphore.wait()
                    comics.append(comic)
                    comicsSemaphore.signal()
                }
                group.leave()
            }
        }
       
        group.notify(queue: .main) {
            completion(comics.sorted(by: {
                return sortRating[$0.num]! > sortRating[$1.num]! || $0.num > $1.num
            }), nil)
        }
    }
}
