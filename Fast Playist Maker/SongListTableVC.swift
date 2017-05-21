//
//  SongTableVC.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/24/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer

class SongListTableVC: CoreDataTableVC {
// MARK: Properties
    var playlist: Playlist!
    var playlistTitle: String!
    var appleMusicClient = AppleMusicConvenience.sharedClient()
    let controller = MPMusicPlayerController.systemMusicPlayer()
    var stack: CoreDataStack!
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var arr = [MPMediaItem]()
    
    
// MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = playlistTitle
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        stack = appDel.stack

        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedSong")
        let pred = NSPredicate(format: "playlist = %@", playlist)
        fr.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fr.predicate = pred
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        querysongs()
    }
    
    func querysongs() {
        
        guard let songs = fetchedResultsController?.fetchedObjects as? [SavedSong] else {
            return
        }
        
        for song in songs {
            let query = MPMediaQuery.songs()
            let songPredicate = MPMediaPropertyPredicate(value: song.title, forProperty: MPMediaItemPropertyTitle)
            query.addFilterPredicate(songPredicate)
            
            if let items = query.items {
                if items.count > 0 {
                    let result = items[0]
                    arr.append(result)
                }
            }
        }
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddSongsToPlaylistVC" {
            let vc = segue.destination as! AddSongsToPlaylistVC
            vc.playlist = self.playlist
        }
    }
    
    func presentMusicPlayer() {
        
        tabBarController?.animateToTab(toIndex: 2)
    }

    @IBAction func play(_ sender: Any) {
        
        playlist.playSongsFromPlaylist(controller: controller)
        
        presentMusicPlayer()
        
    }
    
    
    @IBAction func addSongsBtnPressed(_ sender: Any) {
        //TODO: Add code
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let song = fetchedResultsController?.object(at: indexPath) as! SavedSong
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableCell", for: indexPath) as! SongTableCell

        cell.songTitleLbl.text = song.title
        cell.albumTitleLbl.text = song.albumTitle
        
       let uniqueString = "\(String(describing: song.title))\(String(describing: song.albumTitle))"
        DispatchQueue.main.async {
           cell.albumImageView.loadImageUsingCacheWithUniqueString(uniqueString, imageData: song.albumImg!) 
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSong = fetchedResultsController?.object(at: indexPath) as! SavedSong
        var picked: MPMediaItem?
        
        for song in arr {
            if song.title == selectedSong.title {
                picked = song
            }
        }
        
        controller.stop()
        controller.prepareToPlay()
        let collection = MPMediaItemCollection(items: arr)
        controller.setQueue(with: collection)
        if let pick = picked {
            controller.nowPlayingItem = pick
        }
        controller.repeatMode = .all
        controller.play()
        presentMusicPlayer()
        
    }
 
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            if (fetchedResultsController?.fetchedObjects?.count)! > 1 {
                let song = fetchedResultsController?.object(at: indexPath) as! SavedSong
                stack.mainContext.delete(song)
                stack.save()
                
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            tableView.endUpdates()
        }
    }
    

}
