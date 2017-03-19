//
//  ApiConvience.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/30/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation

class ApiConvenience {
    
    var session: URLSession! = nil
    var apiConstants = ApiConstants()
    
    init(apiConstants: ApiConstants) {
        newSession(apiConstants: apiConstants)
    }
    
    func newSession(apiConstants: ApiConstants) {
        self.session = URLSession(configuration: URLSessionConfiguration.default)
        self.apiConstants.scheme = apiConstants.scheme
        self.apiConstants.host = apiConstants.host
        self.apiConstants.path = apiConstants.path
        self.apiConstants.domain = apiConstants.domain
    }
    
    func apiUrlForMethod(method: String?, PathExt: String? = nil, parameters: [String:AnyObject]? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = apiConstants.scheme
        components.host = apiConstants.host
        components.path = apiConstants.path + (method ?? "") + (PathExt ?? "")
        
        if let parameters = parameters {
            components.queryItems = [NSURLQueryItem]() as [URLQueryItem]?
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem as URLQueryItem)
            }
        }
        return components.url! as NSURL
    }
    
    func apiRequest(url: NSURL, method: String, completionHandler: @escaping (Data?, NSError?) -> Void) {
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = method
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let error = error {
                completionHandler(nil, error as NSError?)
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if (statusCode < 200 && statusCode > 299) {
                    let userInfo = [
                        NSLocalizedDescriptionKey: "Bad Response"
                    ]
                    let error = NSError(domain: "API", code: statusCode, userInfo: userInfo)
                    completionHandler(nil, error)
                    return
                }
            }
            completionHandler(data, nil)
        }
        task.resume()
    }
    
    func dropAllTask(apiConstants: ApiConstants) {
        session.invalidateAndCancel()
        newSession(apiConstants: apiConstants)
    }
    
    // helper function to return errors
    
    func errorReturn(code: Int, description: String, domain: String)-> NSError {
        let userInfo = [NSLocalizedDescriptionKey: description]
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
}
