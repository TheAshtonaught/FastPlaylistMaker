//
//  AMSearchVC.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/30/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit
import MediaPlayer
import StoreKit

class AMSearchVC: UIViewController, UISearchBarDelegate {

    var songResults = [Any]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var appleMusicClient = AppleMusicConvience.sharedClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkAppleMusicAccess()
        // Do any additional setup after loading the view.
    }
    
    func checkAppleMusicAccess() {
        SKCloudServiceController.requestAuthorization { (status) in
            if status == .authorized {
               let controller = SKCloudServiceController()
                controller.requestCapabilities(completionHandler: { (capabilities, err) in
                    if err != nil {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Error", error: "You must be an Apple Music member to use this feature")
                        }
                    }
                })
            } else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Denied", error: "User has Denied access to Apple Music")
                }
            }
            
            
        }
        
        
        
        
        
    }
    
    func searchAM(searchTerm: String) {
        appleMusicClient.getSongs(searchTerm: searchTerm) { (songDict, error) in
          
            guard error == nil else {
                DispatchQueue.main.async {
                  self.showAlert(title: "Error", error: error?.localizedDescription ?? "")
                }
                return
            }
           
            if let dict = songDict {
                self.songResults = dict
                self.tableView.reloadData()
            }
            
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil {
            let search = searchBar.text!.replacingOccurrences(of: " ", with: "+")
            searchAM(searchTerm: search)
            searchBar.resignFirstResponder()
        }
    }
    
    
    
}
extension AMSearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableCell", for: indexPath) as! SongTableCell
        if let songRow = self.songResults[indexPath.row] as? [String:AnyObject],let urlString = songRow["artworkUrl60"] as? String,
            let imgUrl = URL(string: urlString),
            let imgData = NSData(contentsOf: imgUrl){
            cell.albumImageView.image = UIImage(data: imgData as Data)
            cell.songTitleLbl.text = songRow["trackName"] as? String
            cell.albumTitleLbl.text = songRow["artistName"] as? String
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if songResults.count < 10 {
            return songResults.count
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension AMSearchVC {
    func showAlert(title: String, error: String) {
        let alertController = UIAlertController(title: title, message: error, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion:nil)
    }
}














