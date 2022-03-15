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
class XKCDComic: NSObject, NSCoding, Codable {
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
        coder.encode(num, forKey: "num")
        coder.encode(month, forKey: "month")
        coder.encode(day, forKey: "day")
        coder.encode(year, forKey: "year")
        coder.encode(title, forKey: "title")
        coder.encode(transcript, forKey: "transcript")
        coder.encode(alt, forKey: "alt")
        coder.encode(img, forKey: "img")
    }
    
    required convenience init?(coder: NSCoder) {
        let num = coder.decodeInteger(forKey: "num")
        guard let month = coder.decodeObject(forKey: "month") as? String,
              let day = coder.decodeObject(forKey: "day") as? String,
              let year = coder.decodeObject(forKey: "year") as? String,
              let title = coder.decodeObject(forKey: "title") as? String,
              let transcript = coder.decodeObject(forKey: "transcript") as? String,
              let alt = coder.decodeObject(forKey: "alt") as? String,
              let img = coder.decodeObject(forKey: "img") as? String,
              let imgData = coder.decodeObject(forKey: "imgData") as? Data else {
                  return nil
              }
        
        self.init(num: num,
                  month: month,
                  day: day,
                  year: year,
                  title: title,
                  transcript: transcript,
                  alt: alt,
                  img: img,
                  imgData: imgData)
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

/*
extension XKCDComic: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(num)
    }
}
 */

class XKCDClient {
    /**
     Fetches an XKCD comic.
     
     - Parameter num:                       The number of the comic to fetch (fetches the most recent one if none is provided)
     - Parameter completion:                The callback function for when the comic is fetched
     
     - Returns:                             Nothing
     */
    static func fetchComic(num: Int?, completion: @escaping (XKCDComic?, Error?) -> Void) {
        var url : NSURL? = nil
        // If no comic number is provided, fetch the latest.
        if let num = num {
            // Look for cached comic to save on API calls.
            if let cachedComic = ComicsDataManager.sharedInstance.comicsCache[num] {
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
                ComicsDataManager.sharedInstance.comicsCache[comic.num] = comic
                fetchComicImage(comic: comic) { (imgData, error) in
                    guard let imgData = imgData, error == nil else {
                        DispatchQueue.main.async { completion(nil, XKCDError.imageNotFound) }
                    }
                    comic.imgData = imgData
                    DispatchQueue.main.async { completion(comic, nil) }
                }
            } catch (let err) {
                DispatchQueue.main.async { completion(nil, err) }
            }
        }
    
        task.resume()
    }
   
    /**
     Fetches a comic's image as a UIImage.
     
     - Parameter comic:                     The comic to fetch the image of
     - Parameter completion:                The callback function for when the image is fetched
     
     - Returns:                             Nothing
     */
    static func fetchComicImage(comic: XKCDComic, completion: @escaping (Data?, Error?) -> Void) {
        if let cachedComicImageData = ComicsDataManager.sharedInstance.comicImagesCache[comic.num] {
            DispatchQueue.main.async { completion(data, nil) }
            return
        }
        
        guard let url = NSURL(string: comic.img) else {
            DispatchQueue.main.async { completion(nil, XKCDError.badURL) }
            return
        }
        
        let task = URLSession.shared.dataTask(with: url as URL) { (data, response, error) -> Void in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            
            ComicsDataManager.sharedInstance.comicImagesCache[comic.num] = data
            DispatchQueue.main.async { completion(data, nil) }
        }
        
        task.resume()
    }
   
    /**
     Returns a list of comics matching a search query.
     
     - Parameter query:                     The query string
     - Parameter deepSearch:                Whether or not to perform a deep search (regular search only checks title and number)
     - Parameter completion:                The callback function for when comics are fetched
     
     - Returns:                             Nothing
     */
    static func fetchSearchComics(query: String, deepSearch: Bool, completion: @escaping ([XKCDComic]?, Error?) -> Void) {
        // https://stackoverflow.com/questions/35906568/wait-until-swift-for-loop-with-asynchronous-network-requests-finishes-executing
        let group = DispatchGroup()
        var comics: [XKCDComic] = []
        let comicsSemaphore = DispatchSemaphore(value: 1)
        
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
                var basicMatch = comic.title.range(of: query, options: options) != nil
                basicMatch = basicMatch || String(comic.num) == query
                var indepthMatch = false
                if (deepSearch) {
                    indepthMatch = comic.alt.range(of: query, options: options) != nil
                    indepthMatch = indepthMatch || comic.transcript.range(of: query, options: options) != nil
                }
                
                if basicMatch || indepthMatch {
                    comicsSemaphore.wait()
                    comics.append(comic)
                    comicsSemaphore.signal()
                }
                group.leave()
            }
        }
       
        group.notify(queue: .main) {
            completion(comics.sorted().reversed(), nil)
        }
    }
}
