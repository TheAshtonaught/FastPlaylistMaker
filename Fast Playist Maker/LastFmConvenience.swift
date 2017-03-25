//
//  LastFmConvenience.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 3/18/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation
import UIKit

class LastFmConvenience {
    
    let apiConvenience: ApiConvenience
    var appleMusicClient = AppleMusicConvenience.sharedClient()
    
    init() {
        let apiConstants = ApiConstants(scheme: Components.Scheme, host: Components.Host, path: Components.Path, domain: "LastFmClient")
        apiConvenience = ApiConvenience(apiConstants: apiConstants)
    }
    
    fileprivate static var sharedInstance = LastFmConvenience()
    class func sharedClient() -> LastFmConvenience {
        return sharedInstance
    }
    
    fileprivate func lastFmApiRequest(url: NSURL, method: String, completionHandler: @escaping (_ json: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        apiConvenience.apiRequest(url: url, method: method) { (data, error) in
            
            if let data = data {
                let jsonDict = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                
                completionHandler(jsonDict,nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    func getSimilarSongs(songs: [Song], completionHandler: @escaping (_ songString: [String]?, _ error: NSError?) -> Void) {
        
        var arr = [String]()
        
        for song in songs {
            let parameters: [String:Any] = [
                parameterKeys.method: parameterValues.method,
                parameterKeys.artist: song.artist,
                parameterKeys.key: parameterValues.key,
                parameterKeys.track: song.title,
                parameterKeys.format: parameterValues.format,
                parameterKeys.limit: parameterValues.limit]
            
            let url = apiConvenience.apiUrlForMethod(method: nil, PathExt: nil, parameters: parameters as [String : AnyObject]?)
//            print(url)
            
            lastFmApiRequest(url: url, method: "GET") { (jsonDict, error) in
                
                guard error == nil else {
                    completionHandler(nil, error)
                    return
                }
                
                if let dict = jsonDict, let songResults = dict["similartracks"] as? [String:AnyObject], let similars = songResults["track"] as? [[String: AnyObject]] {
                    for sim in similars {
                        
                        if let name = sim["name"], let artistDict = sim["artist"] as? [String:AnyObject], let artist = artistDict["name"] {
                            
                            let songString = "\(name) \(artist)"
                            arr.append(songString)
                        }
                    }
                    print(arr.count)
                    if arr.count > 0 {
                        print(arr)
                        completionHandler(arr, nil)
                        
                    }
                } else {
                    print("error getting similar")
                }
            }
        }
        
    }
    
    
    func getAppleMusicSongsFromSimilarSongs(songs: [Song], completionHandler: @escaping (_ song: [Song]?, _ error: NSError?) -> Void) {
        
        var songArr = [Song]()
        
        getSimilarSongs(songs: songs) { (searchTerms, error) in
        
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
        
            if let terms = searchTerms {
               
                for term in terms {
                    
                    self.appleMusicClient.getSongs(searchTerm: term) { (songDict, error) in
                        
                        guard error == nil else {
                            print("error getting search results")
                            completionHandler(nil, error)
                            return
                        }
                        
                        if let dict = songDict {
                            
                            var title: String!
                            var albumTitle: String!
                            var artwork: UIImage
                            var artist: String!
                            
                            let songRow = dict[0]
                            
                            if let urlString = songRow[AppleMusicConvenience.jsonResponseKeys.artwork] as? String,
                                let imgUrl = URL(string: urlString),
                                let imgData = NSData(contentsOf: imgUrl) {
                                title = songRow[AppleMusicConvenience.jsonResponseKeys.trackName] as? String
                                albumTitle = songRow[AppleMusicConvenience.jsonResponseKeys.albumName] as? String
                                artwork = UIImage(data: imgData as Data) ?? UIImage(named: "noAlbumArt.png")!
                                artist = songRow[AppleMusicConvenience.jsonResponseKeys.artist] as? String
                                let song = Song(artwork: artwork, title: title, album: albumTitle, id: UInt64(9999), artist: artist)
                                
                                songArr.append(song)
                            }
                        }
                    }
                }
                completionHandler(songArr, nil)
            }
        }
    }
    
    
//    func createSongFromLastFmJson(dictionary: [String: AnyObject]) {
//        
//        var title: String?
//        var albumTitle: String?
//        var artwork: UIImage?
//        let id = UInt64(9999)
//        var artist: String?
//        
//        
//        if let songResults = dictionary["similartracks"] as? [String: AnyObject], let similars = songResults["track"] as? [[String: AnyObject]] {
//            
//            for sim in similars {
//                
//                title = sim["name"] as? String
//                
//                
//                if let imageResults = sim["image"] as? [[String: AnyObject]] {
//                    let largeImageResults = imageResults[3]
//                    if let urlString = largeImageResults["#text"] as? String, let imgUrl = URL(string: urlString), let imgData = NSData(contentsOf: imgUrl) {
//                        
//                        artwork = UIImage(data: imgData as Data) ?? UIImage(named: "noAlbumArt.png")!
//                    }
//                    
//                }
//                
//            }
//        }
//        
//    }
    
    
    
//    lastFmClient.getSimilarSongs(song: songsArr[currentIndex])                  { (dict, error) in
//    DispatchQueue.main.async {
//    
    
    
//    }
//    }
    
    
}






