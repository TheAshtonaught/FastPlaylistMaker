//
//  AppDelegate.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/15/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseDynamicLinks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Model")!
    let customURLScheme = "com.algebet.playlistcheetah1Xz"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = self.customURLScheme

        FirebaseApp.configure()
        stack.autoSave(90)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return application(app, open: url, sourceApplication: nil, annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let dynamicLink = DynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url)
        if let dynamicLink = dynamicLink {
            
            handleIncomingDynamicLink(dynamicLink: dynamicLink)
            return true
        }
        
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        guard let dynamicLinks = DynamicLinks.dynamicLinks() else {
            print("failed guard let dynamicLinks")
            return false
        }
        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            // [START_EXCLUDE]
            
            self.handleIncomingDynamicLink(dynamicLink: dynamiclink!)
            
            
            // [END_EXCLUDE]
        }
        
        // [START_EXCLUDE silent]
        if !handled {
            // Show the deep link URL from userActivity.
            let message = "continueUserActivity webPageURL:\n\(userActivity.webpageURL?.absoluteString ?? "")"
            showDeepLinkAlertView(withMessage: message)
        }
        // [END_EXCLUDE]
        
        return handled
    }

    func handleIncomingDynamicLink(dynamicLink: DynamicLink) {
        
        showDeepLinkAlertView(withMessage: String(describing: dynamicLink.url))
        
        guard let lastPath = dynamicLink.url?.lastPathComponent else {
            print("error getting path components")
            return
        }
        
        //print(dynamicLink.url?.query ?? "")
        
        print(lastPath)
        
        //print("your incoming link parameter is \(String(describing: dynamicLink.url))")
        
    }
    
    
    func showDeepLinkAlertView(withMessage message: String) {
        let okAction = UIAlertAction.init(title: "OK", style: .default) { (action) -> Void in
            print("OK")
        }
        
        let alertController = UIAlertController.init(title: "Deep-link Data", message: message, preferredStyle: .alert)
        alertController.addAction(okAction)
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
       
        stack.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
       
        stack.save()
    }


}

extension AppDelegate {
    
    func noConnectionCheckLoop(_ delayInSeconds : Int, vc: UIViewController) {
        if delayInSeconds > 0 {
            
            if !Reachability.isConnectedToNetwork() {
                let alert = UIAlertController(title: "No Internet Connection", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
                vc.present(alert, animated: true, completion: nil)
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.noConnectionCheckLoop(delayInSeconds, vc: vc)
            }
        }
    }
    
}
