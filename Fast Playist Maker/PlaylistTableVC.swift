//
//  PlaylistTableVC.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/15/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit
import CoreData

class PlaylistTableVC: CoreDataTableVC {
// MARK: Properties
    var stack: CoreDataStack!
// MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDel = UIApplication.shared.delegate as! AppDelegate
        stack = appDel.stack
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath) as! SongTableCell
        let playlist = fetchedResultsController?.object(at: indexPath) as! Playlist
        let numberOfSongs = (playlist.savedSong?.allObjects.count)!
        
        let rand = Int(arc4random_uniform(UInt32((numberOfSongs))))
        let randomSong = playlist.savedSong?.allObjects[rand] as! SavedSong
        
        //cell.albumImageView.image = UIImage(data: randomSong.albumImg! as Data)
        cell.songTitleLbl.text = playlist.name
        cell.albumTitleLbl.text = "\(numberOfSongs) Songs"
        let uniqueString = "\(String(describing: randomSong.title))\(String(describing: randomSong.albumTitle))"
        cell.albumImageView.loadImageUsingCacheWithUniqueString(uniqueString, imageData: randomSong.albumImg!)
        
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlist = fetchedResultsController?.object(at: indexPath) as! Playlist
        let songListTableVC = self.storyboard!.instantiateViewController(withIdentifier: "SongListTableVC") as! SongListTableVC
        songListTableVC.playlist = playlist
        songListTableVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(songListTableVC, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            let playlist = fetchedResultsController?.object(at: indexPath) as! Playlist
            stack.mainContext.delete(playlist)
            stack.save()
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
}
