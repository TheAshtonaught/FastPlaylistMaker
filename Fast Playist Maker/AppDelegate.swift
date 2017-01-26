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

