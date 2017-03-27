//
//  CreatePlaylistVC.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/15/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreData

class CreatePlaylistVC: UIViewController {
    
    
// MARK: Properties
    var songsArr = [Song]()
    var userLibrary = [Song]()
    var savedSongs = [SavedSong]()
    var stack: CoreDataStack!
    var addedSongs = [Song]()
    var currentIndex = 0
    var playlistTitle: UITextField!
    var appDel: AppDelegate!
    var global = Global.sharedClient()
    let lastFmClient = LastFmConvenience.sharedClient()

// MARK: Outlets
    @IBOutlet weak var AlbumImgView: DraggableImage!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var albumTitleLbl: UILabel!
    @IBOutlet weak var CreatePlaylistBtn: UIButton!
    @IBOutlet weak var addedLbl: UILabel!
    @IBOutlet weak var addPlaylistBtn: UIBarButtonItem!
    @IBOutlet weak var fetchLibBtn: UILabel!
    @IBOutlet weak var cheetah: UIImageView!

//MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        appDel = UIApplication.shared.delegate as! AppDelegate
        stack = appDel.stack
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector( self.drag(gesture:)))
        AlbumImgView.addGestureRecognizer(gesture)
    
        configUI(createMode: false)
        
        initializeLibrary()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
            if let amsongs = global.appleMusicPicks {
            addedSongs.append(contentsOf: amsongs)
            if addedSongs.count > 0 {
                CreatePlaylistBtn.alpha = 1
                CreatePlaylistBtn.isEnabled = true
            }
            global.appleMusicPicks = nil
        }
    }

    func initializeLibrary() {
        getLibrary { (songArray, error) in
            guard error == nil else {
                self.displayAlert("There was an error", errorMsg: error!.description)
                return
            }
            if let Arr = songArray {
                self.songsArr = Arr
                self.userLibrary = Arr
                print(self.songsArr.count)
                DispatchQueue.main.async {
                    self.configUI(createMode: true)
                    self.updateSong()
                    self.checkIfFirstLaunch()
                }
            }
        }
    }

    func getLibrary(completion:@escaping(_ librarySongs: [Song]?, _ error: NSError?) -> Void) {
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                let songs = MPMediaQuery.songs().items! as [MPMediaItem]
                
                if songs.count < 1 {
                    completion(nil, self.errorReturn(code: 0, description: "Could not get user library", domain: "MPlibrary"))
                } else {
                    completion(Song.newSongFromMPItemArray(itemArr: songs), nil)
                }
            }
        }
    }
    
    // appends the songs the user has picked to add to an array
    
    func added() {
        
        var songTitleArray = [String]()
        
        addedSongs.append(songsArr[currentIndex])
        if addedSongs.count > 4 {
            for song in addedSongs {
                lastFmClient.getSimilarSongs(song: song, completionHandler: { (song, error) in
                    
                    //                for so in self.addedSongs {
                    //                   print(so.title)
                    //                }

                    if let arr = song {
                        songTitleArray.append(contentsOf: arr)
                    }
                    
                    //print(song ?? 000)
                    print("\n")
                    print(songTitleArray)
                })
            }
            
        }
        
        if addedSongs.count > 0 {
            CreatePlaylistBtn.alpha = 1
            CreatePlaylistBtn.isEnabled = true
        }
        songsArr.remove(at: currentIndex)
    }
    
    func resetLib() {
        songsArr = userLibrary
        addedSongs.removeAll(keepingCapacity: true)
        updateSong()
        CreatePlaylistBtn.alpha = 0.3
        CreatePlaylistBtn.isEnabled = false
    }
    
//MARK: Navigation
    // after playlist is created show table with list of songs
    func presentSongTable() {
        let playlist = Playlist(title: playlistTitle.text!, context: stack.mainContext)
        
        for song in addedSongs {
            let savedSong = SavedSong(song: song, context: stack.mainContext)
            savedSong.playlist = playlist
        }
        stack.save()
        resetLib()
        DispatchQueue.main.async {
            let songListTableVC = self.storyboard!.instantiateViewController(withIdentifier: "SongListTableVC") as! SongListTableVC
            songListTableVC.playlist = playlist
            songListTableVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(songListTableVC, animated: true)
        }
        
        
    }
    
//MARK: UI
    // allows song to be dragged left to add right to skip
    func drag(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: self.view)
        let imgView = gesture.view!
        
        imgView.center = CGPoint(x: imgView.bounds.width + translation.x, y: imgView.bounds.height + translation.y)
        
        let xFromCenter = imgView.center.x - self.view.bounds.width / 2
        let scale = min(100 / abs(xFromCenter), 1)
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
        var stretch = rotation.scaledBy(x: scale, y: scale)
        
        imgView.transform = stretch
        if gesture.state == UIGestureRecognizerState.ended {
            
            if imgView.center.x < 100 {
                added()
                updateSong()
                setAddedLbl(added: true)
            } else if imgView.center.x > self.view.bounds.width - 100 {
                updateSong()
                setAddedLbl(added: false)
                songsArr.remove(at: currentIndex)
            }
            
            rotation = CGAffineTransform(rotationAngle: 0)
            stretch = rotation.scaledBy(x: 1, y: 1)
            imgView.transform = stretch
            
            imgView.center = CGPoint(x: self.view.bounds.width / 2, y: (UIApplication.shared.statusBarFrame.height + 44 + (imgView.frame.height / 2)))
        }
    }
    // grabs random song an updates UI accordingly
    func updateSong() {
        let randIndex = Int(arc4random_uniform(UInt32((songsArr.count))))
        currentIndex = randIndex
        
        AlbumImgView.image = songsArr[currentIndex].artwork
        songTitleLbl.text = songsArr[currentIndex].title
        albumTitleLbl.text = songsArr[currentIndex].album
    }
    
    func configUI(createMode: Bool) {
        fetchLibBtn.isHidden = createMode
        cheetahAnimation(animate: !createMode)
        cheetah.isHidden = createMode
        
        AlbumImgView.isHidden = !createMode
        songTitleLbl.isHidden = !createMode
        albumTitleLbl.isHidden = !createMode
        CreatePlaylistBtn.isHidden = !createMode
        CreatePlaylistBtn.isEnabled = false
    }
    
    func cheetahAnimation(animate: Bool) {
        var imgArray = [UIImage]()
        for i in 0...7 {
            imgArray.append(UIImage(named: "cheetah\(i)")!)
        }
        if animate {
            cheetah.animationImages = imgArray
            cheetah.animationDuration = 0.4
            cheetah.startAnimating()
        }
    }
    // Temporarily presents a label when a song is added or skiped
    func setAddedLbl(added: Bool) {
        if added {
            addedLbl.text = "Added"
            addedLbl.backgroundColor = UIColor.green
            addedLbl.isHidden = false
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.dismissAdded), userInfo: nil, repeats: false)
        } else {
            addedLbl.text = "Skip"
            addedLbl.backgroundColor = UIColor.red
            addedLbl.isHidden = false
            
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.dismissAdded), userInfo: nil, repeats: false)
        }
        
    }
    
    func dismissAdded() {
        addedLbl.isHidden = true
    }
    
// MARK: Actions
    
    @IBAction func ceatePlaylist(_ sender: Any) {
        
        func configTextField(textField: UITextField) {
            textField.placeholder = "workout"
            playlistTitle = textField
        }
        
        func cancel(alertView: UIAlertAction!){
            resetLib()
        }
      
        let alert = UIAlertController(title: nil, message: "You've just created something EPIC give it a Name", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: configTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (UIAlertAction) in
            if let text = self.playlistTitle.text, !text.isEmpty {
            self.presentSongTable()
            } else {
                self.displayAlert("No Title", errorMsg: "Pleast name your playlist")
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelPlaylist(_ sender: Any) {
        resetLib()
    }
    
    @IBAction func searchAppleMusicButtonPressed(_ sender: Any) {
        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "AMSearchVC") as! AMSearchVC
        searchVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(searchVC, animated: true)
    }
    

}

extension CreatePlaylistVC {
//MARK: Explainers
    
    func checkIfFirstLaunch() {
        if let firstLaunch = UserDefaults.standard.value(forKey: "firstLaunch") {
            if firstLaunch as! Bool {}
        } else {
            showExplainerThenDismiss()
            UserDefaults.standard.set(false, forKey: "firstLaunch")
        }
    }
    
    func showExplainerThenDismiss() {
        let swipeImg = UIImage(named: "swipeExplainer.png")
        let swipeImgView = UIImageView(frame: AlbumImgView.frame)
        swipeImgView.image = swipeImg
        swipeImgView.backgroundColor = UIColor.lightGray
        swipeImgView.alpha = 0.7
        var delayInNanoSeconds = UInt64(1.5) * NSEC_PER_SEC
        var time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.view.addSubview(swipeImgView)
        }
        
        delayInNanoSeconds = UInt64(4.5) * NSEC_PER_SEC
        time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time) {
            swipeImgView.removeFromSuperview()
        }
    }
    
}


extension CreatePlaylistVC {

//MARK: Errors & Alerts
    func errorReturn(code: Int, description: String, domain: String)-> NSError {
        let userInfo = [NSLocalizedDescriptionKey: description]
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
    
    func displayAlert(_ errorTitle: String, errorMsg: String) {
        let alert = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
}


