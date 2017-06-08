//
//  ComicsVC.swift
//  Comics-ios
//
//  Created by Javi Manzano on 24/04/2017.
//  Copyright © 2017 Javi Manzano. All rights reserved.
//

import UIKit

class ComicsVC: UITableViewController {
    let comicsController = ComicsController.sharedInstance
    
    var series: Series?
    var comicList: [Comic] = []
    var offlineComicIds: [NSNumber] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reinstateBackgroundTask),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
        guard let series = series else {
            return
        }
        
        navigationItem.title = series.title
        
        // Set table cells automatic height
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(ComicsVC.getSeriesComics), for: UIControlEvents.valueChanged)
        if let refreshControl = refreshControl {
            tableView.addSubview(refreshControl)
        }
        
        // Fetch the snippets
        refreshControl?.beginRefreshing()
        getSeriesComics()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getSeriesComics () {
        if let series = series {
            comicsController.getSeriesComics(
                series: series,
                onComicsFetched: { (comics) in
                    self.comicList = comics
                    
                    // Fetch offline comic ids.
                    for comic in comics {
                        if comic.isOffline() {
                            self.offlineComicIds.append(comic.id)
                        }
                    }
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
            }, onError: {
                self.showAlert("Error", message: "Couldn't get the comics")
                self.refreshControl?.endRefreshing()
            })
        }
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

extension ComicsVC {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComicCell", for: indexPath) as! ComicTableViewCell
        
        let comic = comicList[indexPath.row]
        
        cell.setContent(offlineComicIds: offlineComicIds, comic: comic)
        
        return cell
    }
}

// Background task
extension ComicsVC {
    func reinstateBackgroundTask() {
        comicsController.reinstateBackgroundTask()
    }
}
