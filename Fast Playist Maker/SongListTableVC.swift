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

    var playlist: Playlist!
    var playlistTitle: String!
    var appleMusicClient = AppleMusicConvience.sharedClient()
    let controller = MPMusicPlayerController.systemMusicPlayer()
    var stack: CoreDataStack!
    
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
            let result = query.items?[0]
            if let sult = result{
               arr.append(sult) 
            }
            
        }
        let collection = MPMediaItemCollection(items: arr)
        
        controller.setQueue(with: collection)
        controller.prepareToPlay()
        controller.play()
        
        let url = URL(string: "music://")!
        UIApplication.shared.open(url)
        
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
            
            let song = fetchedResultsController?.object(at: indexPath) as! SavedSong
            stack.mainContext.delete(song)
            stack.save()
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        
    }

    

}






