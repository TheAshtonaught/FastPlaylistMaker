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

    var stack: CoreDataStack!
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath)
        let playlist = fetchedResultsController?.object(at: indexPath) as! Playlist
        cell.textLabel?.text = playlist.name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlist = fetchedResultsController?.object(at: indexPath) as! Playlist
        let songListTableVC = self.storyboard!.instantiateViewController(withIdentifier: "SongListTableVC") as! SongListTableVC
        songListTableVC.playlist = playlist
        
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
