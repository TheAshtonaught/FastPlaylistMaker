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
    
    func getSimilarSongs(song: Song, completionHandler: @escaping (_ songArr: [String: AnyObject]?, _ error: NSError?) -> Void) {
        
        let parameters: [String:Any] = [parameterKeys.method: parameterValues.method,
            parameterKeys.artist: song.artist,
            parameterKeys.key: parameterValues.key,
            parameterKeys.track: song.title,
            parameterKeys.format: parameterValues.format,
            parameterKeys.limit: parameterValues.limit]
        
        let url = apiConvenience.apiUrlForMethod(method: nil, PathExt: nil, parameters: parameters as [String : AnyObject]?)
        
        print(url)
        
        lastFmApiRequest(url: url, method: "GET") { (jsonDict, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            if let dict = jsonDict {
                completionHandler(dict, nil)
            }
        }
    }
    
//    func getSongsFromSimilarSongs(songs: [Song], completionHandler: @escaping (_ songs: [Song]?, _ error: NSError?) -> Void) {
//        
//        let similarSongs = [Song]()
//        
//        for song in songs {
//            
//            getSimilarSongs(song: song, completionHandler: { (dict, error) in
//                
//                if let dict = dict, let songResults = dict["similartracks"] as? [String:AnyObject], let similars = songResults["track"] as? [[String: AnyObject]] {
//                    
//                    
//                    
//                }
//                
//            })
//            
//        }
//    
//    
//    }
//    
//    func createSongFromLastFmJson(dictionary: [String: AnyObject]) {
//        
//        var title: String!
//        var albumTitle: String!
//        var artwork: UIImage
//        var id: String!
//        var artist: String!
//        
//        
//        if let songResults = dictionary["similartracks"] as? [String: AnyObject], let similars = songResults["track"] as? [[String: AnyObject]] {
//            
//            for sim in similars {
//                
//            }
//        }
//        
//    }
//    
//    
    
//    lastFmClient.getSimilarSongs(song: songsArr[currentIndex])                  { (dict, error) in
//    DispatchQueue.main.async {
//    
//    if let jdict = dict, let songResults = jdict["similartracks"] as? [String:AnyObject] {
//    
//    if let similars = songResults["track"] as? [[String: AnyObject]] {
//    
//    for sim in similars {
//    
//    //print(sim["name"] ?? 000)
//    if let artist = sim["artist"] as? [String:AnyObject] {
//    print(artist["name"] ?? "can't get name")
//    }
//    
//    }
//
//    
//    
//    } else {
//    print("error getting similar")
//    }
//    }
//    
//    }
//    }
    
    
}






