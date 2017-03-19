//
//  AppleMusicConvience.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/30/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation
import CoreData

class AppleMusicConvenience {
    
    let apiConvenience: ApiConvenience
    
    init() {
        let apiConstants = ApiConstants(scheme: Components.Scheme, host: Components.Host, path: Components.Path, domain: "AppleMusicClient")
        apiConvenience = ApiConvenience(apiConstants: apiConstants)
    }
    
    fileprivate static var sharedInstance = AppleMusicConvenience()
    class func sharedClient() -> AppleMusicConvenience {
        return sharedInstance
    }
    
    fileprivate func appleMusicApiRequest(url: NSURL, method: String, completionHandler: @escaping (_ json: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        apiConvenience.apiRequest(url: url, method: method) { (data, error) in
            
            if let data = data {
                let jsonDict = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                
                completionHandler(jsonDict,nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    func getSongs(searchTerm: String, completionHandler: @escaping (_ songDictArr: [[String : AnyObject]]?, _ error: NSError?) -> Void) {
        
        let parameters: [String:Any] = [parameterKeys.term: "\(searchTerm)",
            parameterKeys.entity: "song"
        ]
        
        let songUrl = apiConvenience.apiUrlForMethod(method: nil, PathExt: nil, parameters: parameters as [String : AnyObject]?)
        
        appleMusicApiRequest(url: songUrl, method: "GET") { (jsonDict, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            if let dict = jsonDict, let songResults = dict["results"] as? [[String:AnyObject]] {
                completionHandler(songResults, nil)
            } else {
                completionHandler(nil, self.apiConvenience.errorReturn(code: 0, description: "No song found", domain: "AMApi"))
            }
        }
        
    }
    
    
}
