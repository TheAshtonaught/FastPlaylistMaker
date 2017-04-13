//
//  LoginToAppleMusicVC.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 4/11/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit

class LoginToAppleMusicVC: UIViewController {
    
    var global = Global.sharedClient()

    @IBAction func memberButton(_ sender: Any) {
        global.showExplainer = true
        dismiss(animated: true, completion: nil)
    }
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        let alert = UIAlertController(title: nil, message: "Some features of this app requires an Apple Music account", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    

}
