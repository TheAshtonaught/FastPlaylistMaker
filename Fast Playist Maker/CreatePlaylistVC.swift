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

    var songsArr = [Song]()
    var userLibrary = [Song]()
    var savedSongs = [SavedSong]()
    var stack: CoreDataStack!
    var addedSongs = [Song]()
    var currentIndex = 0
    var playlistTitle: UITextField!

    @IBOutlet weak var AlbumImgView: DraggableImage!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var albumTitleLbl: UILabel!
    @IBOutlet weak var CreatePlaylistBtn: UIButton!
    @IBOutlet weak var addedLbl: UILabel!
    @IBOutlet weak var appleMusicLbl: UIButton!
    @IBOutlet weak var addPlaylistBtn: UIBarButtonItem!
    @IBOutlet weak var fetchLibBtn: UILabel!
    @IBOutlet weak var cheetah: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDel = UIApplication.shared.delegate as! AppDelegate
        stack = appDel.stack
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector( self.drag(gesture:)))
        AlbumImgView.addGestureRecognizer(gesture)
    
        configUI(createMode: false)

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

    func updateSong() {
        let randIndex = Int(arc4random_uniform(UInt32((songsArr.count))))
        currentIndex = randIndex
        AlbumImgView.image = songsArr[currentIndex].artwork
        songTitleLbl.text = songsArr[currentIndex].title
        albumTitleLbl.text = songsArr[currentIndex].album
    }
    
    
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
                setAddedLbl(added: true)
            } else if imgView.center.x > self.view.bounds.width - 100 {
                setAddedLbl(added: false)
            }
            
            rotation = CGAffineTransform(rotationAngle: 0)
            stretch = rotation.scaledBy(x: 1, y: 1)
            imgView.transform = stretch
            
            imgView.center = CGPoint(x: self.view.bounds.width / 2, y: (UIApplication.shared.statusBarFrame.height + 44 + (imgView.frame.height / 2)))
        }
    }
    
    func added() {
        addedSongs.append(songsArr[currentIndex])
        if addedSongs.count > 0 {
            CreatePlaylistBtn.alpha = 1
            CreatePlaylistBtn.isEnabled = true
        }
        songsArr.remove(at: currentIndex)
    }
    
    func dismissAdded() {
        addedLbl.isHidden = true
    }

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
        updateSong()
    }
    func configUI(createMode: Bool) {
        
        fetchLibBtn.isHidden = createMode
        cheetahAnimation(animate: !createMode)
        cheetah.isHidden = createMode
        
        AlbumImgView.isHidden = !createMode
        songTitleLbl.isHidden = !createMode
        albumTitleLbl.isHidden = !createMode
        appleMusicLbl.isHidden = !createMode
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
    
    func configTextField(textField: UITextField) {
        textField.placeholder = "workout"
        playlistTitle = textField
    }
    
    func cancel(alertView: UIAlertAction!){
        resetLib()
    }
    
    @IBAction func ceatePlaylist(_ sender: Any) {
      
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

    @IBAction func searchAppleMusic(_ sender: Any) {
        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "AMSearchVC") as! AMSearchVC
        
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    
    func presentSongTable() {
        let playlist = Playlist(title: playlistTitle.text!, context: stack.mainContext)
        
        for song in addedSongs {
            let savedSong = SavedSong(song: song, context: stack.mainContext)
            savedSong.playlist = playlist
        }
        stack.save()
        resetLib()
        let songListTableVC = self.storyboard!.instantiateViewController(withIdentifier: "SongListTableVC") as! SongListTableVC
        songListTableVC.playlist = playlist
        
        self.navigationController?.pushViewController(songListTableVC, animated: true)
    }
    
    func resetLib() {
        songsArr = userLibrary
        addedSongs.removeAll(keepingCapacity: true)
        updateSong()
        CreatePlaylistBtn.alpha = 0.3
        CreatePlaylistBtn.isEnabled = false
    }
    
    @IBAction func addPlaylist(_ sender: Any) {
        resetLib()
    }

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
