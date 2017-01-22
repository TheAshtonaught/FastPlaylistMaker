//
//  CreatePlaylistVC.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/15/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit
import MediaPlayer

class CreatePlaylistVC: UIViewController {

    var songsArr = [Song]()
    var index: Int = 1
    
    @IBOutlet weak var AlbumImgView: DraggableImage!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var albumTitleLbl: UILabel!
    @IBOutlet weak var CreatePlaylistBtn: UIButton!
    @IBOutlet weak var addedLbl: UILabel!
    @IBOutlet weak var appleMusicLbl: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.AlbumImgView.isUserInteractionEnabled = true
                    
                    
                    self.updateSong()
                }
                
            }
            
        }
        
    }

    
    func getLibrary(completion:@escaping(_ librarySongs: [Song]?, _ error: NSError?) -> Void) {
        let songs = MPMediaQuery.songs().items! as [MPMediaItem]
       
        print(songs.count)
        if songs.count < 1 {
           completion(nil, errorReturn(code: 0, description: "Could not get user library", domain: "MPlibrary"))
        } else {
        
           completion(Song.newSongFromMPItemArray(itemArr: songs), nil)
        }
        
    }

    
    func updateSong() {

        print(songsArr.count)
//        let randIndex = Int(arc4random_uniform(UInt32((songsArr.count - 1))))
//        AlbumImgView.image = songsArr[5].artwork
        
        
    }
    
    
    func drag(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: self.view)
        let imgView = gesture.view!
        
        imgView.center = CGPoint(x: imgView.bounds.width + translation.x, y: imgView.bounds.height + translation.y)
        
        let xFromCenter = imgView.center.x - self.view.bounds.width / 2
        let scale = min(100 / abs(xFromCenter), 1)
        var rotation = CGAffineTransform(rotationAngle: -xFromCenter / 200)
        var stretch = rotation.scaledBy(x: scale, y: scale)
        
        imgView.transform = stretch
        if gesture.state == UIGestureRecognizerState.ended {
            
            if imgView.center.x < 100 {
                addedLbl.isHidden = false
                Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.dismissAdded), userInfo: nil, repeats: false)
//                updateImg(accepted: true)
            }
            
            rotation = CGAffineTransform(rotationAngle: 0)
            stretch = rotation.scaledBy(x: 1, y: 1)
            imgView.transform = stretch
            
            imgView.center = CGPoint(x: self.view.bounds.width / 2, y: (UIApplication.shared.statusBarFrame.height + 44 + (imgView.frame.height / 2)))
            
        }
        
    }
    func dismissAdded() {
        addedLbl.isHidden = true
    }

    
    func configUI(createMode: Bool) {
        AlbumImgView.isUserInteractionEnabled = false
        AlbumImgView.isHidden = !createMode
        songTitleLbl.isHidden = !createMode
        albumTitleLbl.isHidden = !createMode
        appleMusicLbl.isHidden = !createMode
        activityIndicator.isHidden = !createMode
        
        if createMode == true {
            CreatePlaylistBtn.isEnabled = false
            CreatePlaylistBtn.alpha = 0.3

            
            
        }
    }
    
    @IBAction func ceatePlaylist(_ sender: Any) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        configUI(createMode: true)
        
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
