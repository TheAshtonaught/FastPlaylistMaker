//
//  SongTableVC.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/24/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit
import CoreData

class SongListTableVC: CoreDataTableVC {

    var playlist: Playlist!
    var playlistTitle: String!
    var appleMusicClient = AppleMusicConvience.sharedClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = playlistTitle
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let stack = appDel.stack
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedSong")
        let pred = NSPredicate(format: "playlist = %@", playlist)
        fr.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fr.predicate = pred
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
    }

    
    @IBAction func play(_ sender: Any) {
        let songs = fetchedResultsController?.fetchedObjects as! [SavedSong]

        appleMusicClient.getIdsFromSavedSongs(savedSongs: songs) {(songids, err) in
            
            guard err == nil else {
                print(err!.localizedDescription)
                return
            }
            
            if let queue = songids {
                print(queue)
                DispatchQueue.main.async {
                  let playMusicVc = self.storyboard?.instantiateViewController(withIdentifier: "PlayMusicVC") as! PlayMusicVC
                    
                    playMusicVc.queue = queue
                    //self.navigationController?.pushViewController(playMusicVc, animated: true)
                }
                
            }
            
        }
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
 
    


    

}
