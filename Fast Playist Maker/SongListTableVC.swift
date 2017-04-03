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
    }

    @IBAction func play(_ sender: Any) {
        let songs = fetchedResultsController?.fetchedObjects as! [SavedSong]
        var arr = [MPMediaItem]()
        
        for song in songs {
            let query = MPMediaQuery.songs()
            let songPredicate = MPMediaPropertyPredicate(value: song.title, forProperty: MPMediaItemPropertyTitle)
            query.addFilterPredicate(songPredicate)
            if let result = query.items?[0] {
                arr.append(result)
            }
            
        }
        let collection = MPMediaItemCollection(items: arr)
        
        controller.setQueue(with: collection)
        controller.prepareToPlay()
        controller.play()
        
        let url = URL(string: "music://")!
        UIApplication.shared.open(url)
        
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddSongsToPlaylistVC" {
            let vc = segue.destination as! AddSongsToPlaylistVC
            vc.playlist = self.playlist
        }
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
        cell.albumImageView.image = UIImage(data: song.albumImg as! Data)

        return cell
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
