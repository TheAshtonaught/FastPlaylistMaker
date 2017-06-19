//
//  TestDynamicLinksViewController.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 6/12/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDynamicLinks
import Foundation
//
// MARK: - Section Data Structure
//
struct Section {
    var name: ParamTypes
    var items: [Params]
    var collapsed: Bool
    
    init(name: ParamTypes, items: [Params], collapsed: Bool = true) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
    }
}

enum Params: String {
    case link = "Link Value"
    case source = "Source"
    case medium = "Medium"
    case campaign = "Campaign"
    case term = "Term"
    case content = "Content"
    case bundleID = "com.algebet.playlistcheetah1Xz"
    case fallbackURL = "https://goo.gl/N3B3gu"
    case minimumAppVersion = "Minimum App Version"
    case customScheme = "Custom Scheme"
    case iPadBundleID = "iPad Bundle ID"
    case iPadFallbackURL = "iPad Fallback URL"
    case appStoreID = "1227601453"
    case affiliateToken = "Affiliate Token"
    case campaignToken = "Campaign Token"
    case providerToken = "Provider Token"
    case packageName = "Package Name"
    case androidFallbackURL = "Android Fallback URL"
    case minimumVersion = "Minimum Version"
    case title = "Title"
    case descriptionText = "Description Text"
    case imageURL = "Image URL"
}

enum ParamTypes: String {
    case googleAnalytics = "Google Analytics"
    case iOS = "iOS"
    case iTunes = "iTunes Connect Analytics"
    case android = "Android"
    case social = "Social Meta Tag"
}

class TestDynamicLinksViewController: UIViewController {
    
    static let DYNAMIC_LINK_DOMAIN = "https://dz7xg.app.goo.gl/"
    
    var sections = [Section]()
    var dictionary = [Params: String]()
    var longLink: URL?
    var shortLink: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        sections = [
            Section(name: .iOS, items: [
                .bundleID,
                .fallbackURL,
                .appStoreID]),
        ]
        
        
    }
    
    @IBAction func button(_ sender: Any) {
        
        
        buildFDLLink()
    }
    
    
    
    func buildFDLLink() {
        // [START buildFDLLink]
        
        let linkString = "https://www.google.com"
        
        guard let link = URL(string: linkString) else {
            print("error")
            return }
        
        let components = DynamicLinkComponents(link: link, domain: DynamicViewController.DYNAMIC_LINK_DOMAIN)
        
        let bid: String?
        bid = "com.algebet.playlistcheetah1Xz"
        
        
        if let bundleID = bid {
            let iOSParams = DynamicLinkIOSParameters(bundleID: bundleID)
            
//            let fallback: String?
//            fallback =  "https://www.google.com"
//            if let fallbackURL = fallback {
//                iOSParams.fallbackURL = URL(string: fallbackURL)
//            }
            
            
            iOSParams.appStoreID = "1227601453"
            components.iOSParameters = iOSParams
            
            longLink = components.url
            
            
            
            print(longLink?.absoluteString ?? "no long link")
            // [END buildFDLLink]
        
        
        
        // [START shortLinkOptions]
        let options = DynamicLinkComponentsOptions()
        options.pathLength = .unguessable
        components.options = options
        // [END shortLinkOptions]
        
        // [START shortenLink]
        components.shorten { (shortURL, warnings, error) in
            // Handle shortURL.
            if let error = error {
                print(error.localizedDescription + "no long link")
                return
            }
            self.shortLink = shortURL
            
            UIApplication.shared.open(self.shortLink!)
            
            print(self.shortLink?.absoluteString ?? "")
            
            
        }
        // [END shortenLink]
    }

    }

}
