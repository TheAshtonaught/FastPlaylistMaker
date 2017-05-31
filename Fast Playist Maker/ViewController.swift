//
//  ViewController.swift
//  Koloda
//
//  Created by Eugene Andreyev on 4/23/15.
//  Copyright (c) 2015 Eugene Andreyev. All rights reserved.
//

import UIKit
import Koloda
import MediaPlayer
import StoreKit
import CoreData



class ViewController: UIViewController {
    
    var addedSongs = [Song]()
    var similarSongsArray = [SimilarSong]()
    var positionInSongArray = 0
    var savedSongs = [SavedSong]()
    var currentIndex = 0
    let controller = SKCloudServiceController()
    var showingSimilarSong = false
    var userLibrary: [Song]?
    var playlistTitle: UITextField!
    var appDel: AppDelegate!
    var global = Global.sharedClient()
    let appleMusicClient = AppleMusicConvenience.sharedClient()
    let lastFmClient = LastFmConvenience.sharedClient()
    
    var songArray: [Song]? {
        didSet {
            DispatchQueue.main.async {
                self.kolodaView.reloadData()
                self.kolodaView.isHidden = false
            }
            
        }
    }
    
    
    
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var createPlaylistBtn: BorderedButton!
    @IBOutlet weak var discoverSwitch: UISwitch!
    
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLibrary()
        kolodaView.dataSource = self
        kolodaView.delegate = self
        kolodaView.isHidden = true
        
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavBar(isHidden: true)
        
        loadPurgatorySongs()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        setNavBar(isHidden: false)
    }
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBAction func createPlaylist(_ sender: Any) {
        func configTextField(textField: UITextField) {
            textField.placeholder = "workout"
            playlistTitle = textField
        }
        
        func cancel(alertView: UIAlertAction!){
            
        }
        
        let alert = UIAlertController(title: nil, message: "You've just created something EPIC give it a Name", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: configTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (UIAlertAction) in
            if let text = self.playlistTitle.text, !text.isEmpty {
//                self.presentSongTable()
            } else {
                self.displayAlert("No Title", errorMsg: "Pleast name your playlist")
            }
        }))
        
        if addedSongs.count > 0 {
            present(alert, animated: true, completion: nil)
        } else {
            displayAlert("NO SONGS ADDED", errorMsg: "Add songs to a playlist by swiping right on the song you want to add")
        }
        
    }
    @IBAction func discoverSwitchValueChanged(_ sender: Any) {
        
        similarSongsArray = [SimilarSong]()
        
        if discoverSwitch.isOn {
            if addedSongs.count > 0 {
                
                getSimilarSongs()
                
            } else {
                displayAlert("No songs added", errorMsg: "Discover suggest new songs based on songs you've added to your current playlist")
                discoverSwitch.isOn = false
            }
        } else if !discoverSwitch.isOn {
            kolodaView.resetCurrentCardIndex()
 
        }
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        if addedSongs.count > 0 {
            cancelPlaylistWarning()
        }
        
    }
    
    @IBAction func search(_ sender: Any) {
        
        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "AMSearchVC") as! AMSearchVC
        searchVC.hidesBottomBarWhenPushed = true
        
        
        navigationController?.pushViewController(searchVC, animated: true)
        
    }
    
    @IBAction func moreInfo(_ sender: Any) {
        
    }

    
    
    
    func getLibrary() {
        
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                var songs = MPMediaQuery.songs().items! as [MPMediaItem]
                songs.shuffle()

                self.songArray = Song.newSongFromMPItemArray(itemArr: songs)
                self.userLibrary = self.songArray
                print(self.songArray?.count ?? 0)
                
            } else {
               self.displayAlert("Can't Get Songs From Your Library", errorMsg: "Playlist Cheetah does not have access to your music library. Please check your settings and allow Playlist Cheetah to have access to your library if you want to use songs from your library to make playlist")
            }
        }
        
    }
    
    func added(song: Song) {
        addedSongs.append(song)
        print(song.title)
        if addedSongs.count > 0 {
            createPlaylistBtn.alpha = 1
            createPlaylistBtn.isEnabled = true
            discoverSwitch.isEnabled = true
        }

    }
    
    func resetLib() {
        songArray = userLibrary
        addedSongs.removeAll(keepingCapacity: true)

        similarSongsArray = [SimilarSong]()
        createPlaylistBtn.alpha = 0.3
        
        kolodaView.resetCurrentCardIndex()

        
    }
    
    func loadPurgatorySongs() {
        if let amsongs = global.appleMusicPicks {
            addedSongs.append(contentsOf: amsongs)
            if addedSongs.count > 0 {
                createPlaylistBtn.alpha = 1
                createPlaylistBtn.isEnabled = true
                discoverSwitch.isEnabled = true
            }
            global.appleMusicPicks = nil
        }
    }
    
    func getSimilarSongs() {
        let myGroup = DispatchGroup()
        
        //similarSongsArray = [SimilarSong]()
        
        for song in addedSongs {
            myGroup.enter()
            lastFmClient.getSimilarSongs(song: song, completionHandler: { (song, error) in
                
                if let songArray = song {
                    self.similarSongsArray.append(contentsOf: songArray)
                    
                    //print(self.similarSongsArray.count)
                    
                }
                myGroup.leave()
            })
        }
        
        
        myGroup.notify(queue: DispatchQueue.main, execute: {
            print(self.similarSongsArray.count)
            self.similarSongsArray.sort(by: { $0.match > $1.match })
            self.positionInSongArray = self.kolodaView.currentCardIndex
            self.showingSimilarSong = true
            self.kolodaView.reloadData()
            self.kolodaView.resetCurrentCardIndex()
            self.songArray!.removeSubrange(0..<self.positionInSongArray)
        })

    }

    func setNavBar(isHidden: Bool) {
        navigationController?.setNavigationBarHidden(isHidden, animated: !isHidden)
    }
    
}

// MARK: KolodaViewDelegate

extension ViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        
        if discoverSwitch.isOn {
            discoverSwitch.isOn = false
        }
        kolodaView.resetCurrentCardIndex()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        if direction == .right {
            
            if discoverSwitch.isOn && similarSongsArray.count > 0 {
                
                
                //TODO: Add similar song image to avoid downloading on init
                let songToAdd = Song(similarSong: similarSongsArray[index])
                added(song: songToAdd)
            } else if songArray != nil {
                let songToAdd = songArray![index]
                added(song: songToAdd)
            }
        }
        
    }

}

// MARK: KolodaViewDataSource

extension ViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        
        if similarSongsArray.count > 0 {
            return similarSongsArray.count
        } else if songArray != nil {
            return songArray!.count
        } else {
            return 0
        }

    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        let cardContainer = Bundle.main.loadNibNamed("CardContainer", owner: self, options: nil)?.first as! CardContainer
        
        //print(index)
        
        if discoverSwitch.isOn && similarSongsArray.count > 0 {
            
            DispatchQueue.main.async {
                cardContainer.setWithSong(similarSong: self.similarSongsArray[index])
            }
            return cardContainer
        } else if songArray != nil {
            let song = songArray![index]
            
            DispatchQueue.main.async {
                cardContainer.setWithSong(song: song)
            }
            return cardContainer
        }
        
        return UIView()
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?.first as? OverlayView
    }
}

extension ViewController {

    func errorReturn(code: Int, description: String, domain: String)-> NSError {
        let userInfo = [NSLocalizedDescriptionKey: description]
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
    
    func displayAlert(_ errorTitle: String, errorMsg: String) {
        let alert = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    func cancelPlaylistWarning() {
        let alert = UIAlertController(title: "Cancel Playlist", message: "Are you sure you want to cancel making playlist?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "I'M SURE", style: .default, handler: { (UIAlertAction) in
            self.resetLib()
        }))
        
        alert.view.backgroundColor = .white
        alert.view.layer.cornerRadius = 15
        
        present(alert, animated: true, completion: nil)
    }
}















