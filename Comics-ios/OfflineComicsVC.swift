//
//  OfflineComicsVC.swift
//  Comics-ios
//
//  Created by Javi Manzano on 5/21/17.
//  Copyright © 2017 Javi Manzano. All rights reserved.
//

import Foundation

import UIKit

class OfflineComicsVC: UITableViewController {
    let comicsController = ComicsController.sharedInstance

    var comicList: [OfflineComic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set table cells automatic height
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Fetch the offline comics
        comicList = comicsController.getOfflineComics()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "comicRead" {
            let destination = segue.destination as! ComicReadVC
            destination.offlineComic = sender as? OfflineComic
        }
    }
}

extension OfflineComicsVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comicList.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow as IndexPath! {
            let offlineComic = comicList[indexPath.row]
            performSegue(withIdentifier: "comicRead", sender: offlineComic)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OfflineComicCell", for: indexPath) as! OfflineComicTableViewCell
        
        let offlineComic = comicList[indexPath.row]
        
        cell.setContent(offlineComic: offlineComic)
        
        return cell
    }
}

