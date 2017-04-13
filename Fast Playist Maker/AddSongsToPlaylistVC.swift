//
//  AddSongsToPlaylistVC.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 3/12/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreData

class AddSongsToPlaylistVC: UIViewController {
    
    //MARK: Properties
    var playlist: Playlist!
    var songsArr = [Song]()
    var userLibrary = [Song]()
    var savedSongs = [SavedSong]()
    var stack: CoreDataStack!
    var addedSongs = [Song]()
    var currentIndex = 0
    var appDel: AppDelegate!
    var global = Global.sharedClient()
    
    //MARK: Outlets
    @IBOutlet weak var AlbumImageView: DraggableImage!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistTitleLabel: UILabel!
    @IBOutlet weak var addedLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        appDel = UIApplication.shared.delegate as! AppDelegate
        stack = appDel.stack
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector( self.drag(gesture:)))
        AlbumImageView.addGestureRecognizer(gesture)
        
        initializeLibrary()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let amsongs = global.appleMusicPicks {
            addedSongs.append(contentsOf: amsongs)
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
                    self.updateSong()
                    self.activityIndicator.stopAnimating()
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
                setAddedLbl(added: false)
            } else if imgView.center.x > self.view.bounds.width - 100 {
                added()
                setAddedLbl(added: true)
            }
            
            rotation = CGAffineTransform(rotationAngle: 0)
            stretch = rotation.scaledBy(x: 1, y: 1)
            imgView.transform = stretch
            
            imgView.center = CGPoint(x: self.view.bounds.width / 2, y: (UIApplication.shared.statusBarFrame.height + 44 + (imgView.frame.height / 2)))
        }
    }
    
    func added() {
        addedSongs.append(songsArr[currentIndex])
        
    }
    
    func setAddedLbl(added: Bool) {
        if added {
            addedLabel.text = "Added"
            addedLabel.backgroundColor = UIColor.green
            addedLabel.isHidden = false
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.dismissAdded), userInfo: nil, repeats: false)
        } else {
            addedLabel.text = "Skip"
            addedLabel.backgroundColor = UIColor.red
            addedLabel.isHidden = false
            
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.dismissAdded), userInfo: nil, repeats: false)
        }
        updateSong()
    }
    
    func updateSong() {
        let randIndex = Int(arc4random_uniform(UInt32((songsArr.count))))
        currentIndex = randIndex
        AlbumImageView.image = songsArr[currentIndex].artwork
        songTitleLabel.text = songsArr[currentIndex].title
        artistTitleLabel.text = songsArr[currentIndex].album
    }
    
    func dismissAdded() {
        addedLabel.isHidden = true
    }

    @IBAction func addSongsToPlaylist(_ sender: Any) {
        if addedSongs.count > 0 {
            for song in addedSongs {
                let savedSong = SavedSong(song: song, context: stack.mainContext)
                savedSong.playlist = playlist
            }
            stack.save()
        }
        DispatchQueue.main.async {
           _ = self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func search(_ sender: Any) {
        
        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "AMSearchVC") as! AMSearchVC
        searchVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(searchVC, animated: true)
    }
}

extension AddSongsToPlaylistVC {
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

    
    
    
    
    





















