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
// MARK: Properties
    var songResults = [Any]()
    var song: Song!
    var appDel: AppDelegate!
    var songsToAppend = [Song]()
    var global = Global.sharedClient()
    var appleMusicClient = AppleMusicConvenience.sharedClient()
    let controller = SKCloudServiceController()

// MARK: Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.isHidden = true
        checkAppleMusicAccess()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.noConnectionCheckLoop(30, vc: self)
        
        searchBar.delegate = self
    }
    
    
// MARK: Determines if the user has access to Apple Music
    func checkAppleMusicAccess() {
        SKCloudServiceController.requestAuthorization { (status) in
            if status == .authorized {
                self.controller.requestCapabilities(completionHandler: { (capabilities, err) in
                    if err != nil {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Error", error: "You must be an Apple Music member to use this feature")
                        }
                    }
                })
            } else if status != .authorized {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", error: "You must be and Apple Music member to use this feature")
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
// MARK: takes a term and searches Apple Music using the Itunes API
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
        if Reachability.isConnectedToNetwork() {
            if searchBar.text != nil {
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = false
                    self.activityIndicator.startAnimating()
                }
                
                
                let search = searchBar.text!.replacingOccurrences(of: " ", with: "+")
                searchAM(searchTerm: search)
            }
        }
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
extension AMSearchVC: UITableViewDelegate, UITableViewDataSource {
// MARK: Table View Data Source
    
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
        searchBar.resignFirstResponder()
        var title: String!
        var albumTitle: String!
        var artwork: UIImage
        var id: String!
        var artist: String!
        
        if let songRow = self.songResults[indexPath.row] as? [String:AnyObject],
            let urlString = songRow[AppleMusicConvenience.jsonResponseKeys.artwork] as? String,
            let imgUrl = URL(string: urlString),
            let imgData = NSData(contentsOf: imgUrl) {
            title = songRow[AppleMusicConvenience.jsonResponseKeys.trackName] as? String
            albumTitle = songRow[AppleMusicConvenience.jsonResponseKeys.albumName] as? String
            artwork = UIImage(data: imgData as Data) ?? UIImage(named: "noAlbumArt.png")!
            id = String(songRow["trackId"] as! Int)
            artist = songRow[AppleMusicConvenience.jsonResponseKeys.artist] as? String
            song = Song(artwork: artwork, title: title, album: albumTitle, id: UInt64(9999), artist: artist)
            songsToAppend.append(song)
            global.appleMusicPicks = songsToAppend
            
            addToPlaylistAlert(id: id)
        }
    }

}

extension AMSearchVC {
// MARK: Errors and Alert
    
    
    // Adds selected songs from apple music to users library
    func addToPlaylistAlert(id: String) {
        let alert = UIAlertController(title: "Would you like to add \(song.title)?", message: "Only songs in your library can be added to a playlist. If \(song.title) is not in your library it will be added", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (UIAlertAction) in
            self.controller.requestCapabilities(completionHandler: { (capability, error) in
                if capability.contains(SKCloudServiceCapability.addToCloudMusicLibrary)  {
                    MPMediaLibrary.default().addItem(withProductID: id, completionHandler: { (arr, err) in
                        guard err == nil else {
                            DispatchQueue.main.async {
                                self.showAlert(title: "error", error: "could not add song")
                            }
                            return
                        }
                        
                    })
                }
            })
            
            
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, error: String) {
        let alertController = UIAlertController(title: title, message: error, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion:nil)
    }
}
