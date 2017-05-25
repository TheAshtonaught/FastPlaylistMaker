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

private var numberOfCards: Int = 5

class ViewController: UIViewController {
    
    @IBOutlet weak var kolodaView: KolodaView!
    var songArray: [MPMediaItem]? {
        didSet {
            DispatchQueue.main.async {
                self.kolodaView.reloadData()
                self.kolodaView.isHidden = false
            }
            
        }
    }
    
//    fileprivate var dataSource: [UIImage] = {
//        var array: [UIImage] = []
//        for index in 0..<numberOfCards {
//            array.append(UIImage(named: "Card_like_\(index + 1)")!)
//        }
//    
//        return array
//    }()
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLibrary()
        kolodaView.dataSource = self
        kolodaView.delegate = self
        kolodaView.isHidden = true
        
        
    }
    
    
    
    func getLibrary() {
        
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                let songs = MPMediaQuery.songs().items! as [MPMediaItem]
                self.songArray = songs
                
            }
        }
        
    }
    
    
    // MARK: IBActions

    
}

// MARK: KolodaViewDelegate

extension ViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        
        kolodaView.resetCurrentCardIndex()

    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if direction == .left {
            songArray?.remove(at: index)
            //print(songArray?.count ?? "error")
        }
        
    }

}

// MARK: KolodaViewDataSource

extension ViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        
        if let arr = songArray {
            return arr.count
        } else {
            return 0
        }
        
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        
        let cardContainer = Bundle.main.loadNibNamed("CardContainer", owner: self, options: nil)?.first as! CardContainer
        
        
        cardContainer.layer.cornerRadius = 10
        cardContainer.layer.masksToBounds = true
        
        if let arr = songArray {
            DispatchQueue.main.async {
                let song = arr[index]

                cardContainer.albumImageView.image = song.artwork?.image(at: cardContainer.albumImageView.frame.size) ?? #imageLiteral(resourceName: "noAlbumArt")

                cardContainer.songTitleLabel.text = song.title
                cardContainer.albumTitleLabel.text = song.artist
            }
            
        }
        
        
        
        return cardContainer
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?.first as? OverlayView
    }
}

