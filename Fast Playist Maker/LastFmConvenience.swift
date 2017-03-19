//
//  LastFmConvenience.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 3/18/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation

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
    
    
}






