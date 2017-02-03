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
    var song: Song!
    var appDel: AppDelegate!
    var songsToAppend = [Song]()
    var global = Global.sharedClient()
    var appleMusicClient = AppleMusicConvience.sharedClient()

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.isHidden = true
        checkAppleMusicAccess()
        
        appDel = UIApplication.shared.delegate as! AppDelegate

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
                DispatchQueue.main.async {
                    self.songResults = dict
                    self.tableView.reloadData()
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
                
            }
            
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != nil {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            let search = searchBar.text!.replacingOccurrences(of: " ", with: "+")
            searchAM(searchTerm: search)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
extension AMSearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        if let songRow = self.songResults[indexPath.row] as? [String:AnyObject] {
            cell.textLabel?.text = songRow["trackName"] as? String
            cell.detailTextLabel?.text = songRow["artistName"] as? String
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
        var title: String!
        var albumTitle: String!
        var artwork: UIImage
        var id: Int!
        
        if let songRow = self.songResults[indexPath.row] as? [String:AnyObject],
            let urlString = songRow["artworkUrl60"] as? String,
            let imgUrl = URL(string: urlString),
            let imgData = NSData(contentsOf: imgUrl) {
            title = songRow["trackName"] as? String
            albumTitle = songRow["collectionName"] as? String
            artwork = UIImage(data: imgData as Data) ?? UIImage(named: "noAlbumArt.png")!
            id = songRow["trackId"] as? Int
            song = Song(artwork: artwork, title: title, album: albumTitle, id: UInt64(id))
            songsToAppend.append(song)
            global.appleMusicPicks = songsToAppend
            showAlert(title: "Added", error: "\(song.title) was added to your playlist")
        }
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














