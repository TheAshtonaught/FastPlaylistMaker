//
//  LoginToAppleMusicVC.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 4/11/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//
//  ************************************************
//  Deprecated *************************************
//  ************************************************



import UIKit

class LoginToAppleMusicVC: UIViewController {
    
    var global = Global.sharedClient()

    @IBAction func memberButton(_ sender: Any) {
        global.showExplainer = true
        dismiss(animated: true, completion: nil)
    }
    
    // use open url to test firebase url
    
    @IBAction func signupButton(_ sender: Any) {
        let url = URL(string: "https://www.apple.com/apple-music/membership/")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func skip(_ sender: Any) {
        global.showExplainer = true
        dismiss(animated: true, completion: nil)
    }
    
}
