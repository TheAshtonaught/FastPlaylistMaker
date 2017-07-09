//
//  DynamicPlaylistVC.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 6/30/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit
import Firebase
import MediaPlayer
import StoreKit
import AVKit

class DynamicPlaylistVC: UIViewController {
    
    var playlistID: String?
    var fetchLibraryView: LoadingLibraryUI!
    var songs = [Song]()
    var ref: DatabaseReference!
    var playlistTitle: String?
    let appleMusicClient = AppleMusicConvenience.sharedClient()
    let controller = SKCloudServiceController()
    let mpController = MPMusicPlayerController.systemMusicPlayer()
    var hasAppleMusicAccess: Bool?
    var storeIds = [String]()
    var player = AVPlayer()
    
    @IBOutlet weak var playlistTableView: UITableView!
    @IBOutlet weak var PlaylistTitlelabel: UILabel!
    @IBOutlet weak var playButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        configureUI()
        checkAppleMusicAccess()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //TODO: move to view did load
        if let id = playlistID {
            parsePlaylist(id: id)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func play(_ sender: Any) {
        
        playlistPlayback(songToPrepend: nil)
    }
    
    @IBAction func exit(_ sender: Any) {
        
        showHomeTabBar(shouldAnimateToMusicPlayer: false)
    }
    
    func parsePlaylist(id: String) {
        
        ref.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let value = snapshot.value as? NSDictionary else {
                print("no value from playlist id")
                return
            }
            
            self.setPlaylistTitle(playlistDict: value)
            self.parsePlaylistSongs(playlistDict: value)
            //print(value)
            
            self.setplayButton(isHidden: false)
            
        })
        
    }
    
    func parsePlaylistSongs(playlistDict: NSDictionary) {
        guard let songDict = playlistDict["songs"] as? NSDictionary else {
            print("error getting playlist songs")
            return
        }
        
        for (_, value) in songDict {
            if let valueDict = value as? NSDictionary, let title = valueDict["title"] as? String, let artist = valueDict["albumArtist"] as? String {
                
                let searchString = "\(title) \(artist)"
                appleMusicClient.addSong(searchTerm: searchString, completion: { (song) in
                    
                    guard let song = song else {
                        return
                    }
                    
                    self.songs.append(song)
                    DispatchQueue.main.async {
                        self.playlistTableView.reloadData()
                        self.showTableView()
                    }
                    
                })
                
            }
            
        }
        DispatchQueue.main.async {
           self.removeFetchLibView()
        }
        
        
    }
    
    func setPlaylistTitle(playlistDict: NSDictionary) {
        guard let playlistTitle = playlistDict["PLAYLIST_TITLE"] as? String else {
            DispatchQueue.main.async {
                self.PlaylistTitlelabel.text = "Untitled"
            }
            return
        }
        
        DispatchQueue.main.async {
            self.PlaylistTitlelabel.text = playlistTitle
        }
    }
    
    func playlistPlayback(songToPrepend: Song?) {
        mpController.stop()
        mpController.prepareToPlay()
        
        let hasAppleMusicAccess = self.hasAppleMusicAccess ?? false
        
        if hasAppleMusicAccess {
            
            for song in songs {
                guard let id = song.trackId?.description else{
                    return
                }
                
                storeIds.append(id)
            }
            
            if let selectedSong = songToPrepend, let selectedId = selectedSong.trackId?.description {
                
                storeIds.insert(selectedId, at: 0)
                
                mpController.shuffleMode = .off
            }
            mpController.setQueueWithStoreIDs(storeIds)
            mpController.play()
            showHomeTabBar(shouldAnimateToMusicPlayer: true)
            
        } else {
            if player.currentItem != nil {
                player = AVPlayer()
                playButton.setTitle("PLAY", for: .normal)
            } else {
               playPreviewTracks(song: songToPrepend)
            }
            
        }
    }
    
    func playPreviewTracks(song: Song?) {
       
        var previewSong: Song?
        
        if let sng = song {
            previewSong = sng
        } else {
            previewSong = songs.first
        }
        
        guard let previewUrl = previewSong?.previewUrl else {
            return
        }
        
        guard let streamURL = URL(string: previewUrl) else {
            return
        }
        
        let playerItem:AVPlayerItem = AVPlayerItem(url: streamURL)
        player = AVPlayer(playerItem: playerItem)
        player.play()
        playButton.setTitle("PAUSE", for: .normal)

        displayPreviewMessage()
    }
    
    func showHomeTabBar(shouldAnimateToMusicPlayer: Bool) {
        guard let initialTab = self.storyboard?.instantiateViewController(withIdentifier: "initialTabBar") as? UITabBarController else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        present(initialTab, animated: true, completion: {
            if shouldAnimateToMusicPlayer {
                initialTab.animateToTab(toIndex: 2)
            }
        })
    }
    
    func showTableView() {
        if self.playlistTableView.isHidden {
            self.playlistTableView.isHidden = false
        }
    }
    
    func displayPreviewMessage() {
        let alert = UIAlertController(title: "Playing Preview", message: "You are listening to a preview of this track you must have access to Apple Music or Spotify", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: nil))
//        alert.addAction(UIAlertAction(title: "I'M SURE", style: .default, handler: { (UIAlertAction) in
//            //self.resetLib()
//        }))
        
        alert.view.backgroundColor = .white
        alert.view.layer.cornerRadius = 15
        
        present(alert, animated: true, completion: nil)
    
    }
    
    func configureUI() {
        setFetchLibView()
        configureTableViewStyle()
        configureButton()
        setplayButton(isHidden: true)
        playlistTableView.isHidden = true
    }
    
    func configureTableViewStyle() {
        playlistTableView.layer.cornerRadius = 10
        playlistTableView.layer.masksToBounds = true
    }
    
    func configureButton() {
        
    }

}

extension DynamicPlaylistVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DynamicSongTableCell") as? SongTableCell else {
            return UITableViewCell()
        }
        
        let song = songs[indexPath.row]
        
        cell.songTitleLbl.text = song.title
        cell.albumTitleLbl.text = song.album
        
        DispatchQueue.main.async {
            cell.albumImageView.loadImageUsingUrlString(urlString: song.imageUrl)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let song = songs[indexPath.row]
        
        playlistPlayback(songToPrepend: song)
       // playPreviewTracks(song: song)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
}

extension DynamicPlaylistVC {
    
    func setFetchLibView() {
        let mainView = self.view!
        
        fetchLibraryView = Bundle.main.loadNibNamed("FetchLibrary", owner: self, options: nil)?.first as! LoadingLibraryUI
        
        fetchLibraryView.frame.size = CGSize(width: 350, height: 300)
        fetchLibraryView.center = mainView.center
        
        mainView.addSubview(fetchLibraryView)
        
        fetchLibraryView.cheetahAnimation(animate: true)
    }
    
    func removeFetchLibView() {
        self.fetchLibraryView.cheetahAnimation(animate: false)
        self.fetchLibraryView.removeFromSuperview()
    }
    
    func setplayButton(isHidden: Bool) {
        
        playButton.isHidden = isHidden
        playButton.isUserInteractionEnabled = !isHidden
    }
}

extension DynamicPlaylistVC {
    
    func checkAppleMusicAccess() {
        
        //var access: Bool?
        self.controller.requestCapabilities { (capabilities, error) in
            if error != nil {
                self.hasAppleMusicAccess = false
            } else {
                self.hasAppleMusicAccess = true
                //print("true")
            }
            
        }
        
    }
    
    
    

}









