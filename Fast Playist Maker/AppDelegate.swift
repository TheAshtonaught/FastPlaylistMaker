//
//  AppDelegate.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/15/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit
import CoreData
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Model")!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        stack.autoSave(90)
        return true
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












