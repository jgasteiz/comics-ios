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

    var comicList: [Comic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set table cells automatic height
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(
            self,
            action: #selector(OfflineComicsVC.getOfflineComics),
            for: UIControlEvents.valueChanged
        )
        if let refreshControl = refreshControl {
            tableView.addSubview(refreshControl)
        }
        
        // Fetch the comics
        refreshControl?.beginRefreshing()
        getOfflineComics()
    }
    
    
    func getOfflineComics () {
        comicList = comicsController.getOfflineComics()
    }
    
    /*
     Shows a dismissable alert with a title and a message.
     */
    func showAlert(_ title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "comicRead" {
            let destination = segue.destination as! ComicReadVC
            destination.comic = sender as? Comic
        }
    }
}

extension OfflineComicsVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comicList.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow as IndexPath! {
            let comic = comicList[indexPath.row]
            performSegue(withIdentifier: "comicRead", sender: comic)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OfflineComicCell", for: indexPath) as! OfflineComicTableViewCell
        
        let comic = comicList[indexPath.row]
        
        cell.setContent(comic: comic)
        
        return cell
    }
}

