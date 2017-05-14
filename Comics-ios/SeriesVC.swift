//
//  SeriesVC.swift
//  Comics-ios
//
//  Created by Javi Manzano on 24/04/2017.
//  Copyright © 2017 Javi Manzano. All rights reserved.
//

import UIKit

class SeriesVC: UITableViewController {
    
    let comicsController = ComicsController.sharedInstance
    
    var seriesList: [Series] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set table cells automatic height
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(SeriesVC.getAllSeries), for: UIControlEvents.valueChanged)
        if let refreshControl = refreshControl {
            tableView.addSubview(refreshControl)
        }
        
        // Fetch the snippets
        refreshControl?.beginRefreshing()
        getAllSeries()
    }

    
    func getAllSeries () {
        comicsController.getAllSeries(onSeriesFetched: { (series) in
            self.seriesList = series
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }, onError: {
            self.showAlert("Error", message: "Couldn't get the series")
            self.refreshControl?.endRefreshing()
        })
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
        if segue.identifier == "comicList" {
            let destination = segue.destination as! ComicsVC
            destination.series = sender as? Series
        }
    }

}

extension SeriesVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seriesList.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow as IndexPath! {
            let series = seriesList[indexPath.row]
            performSegue(withIdentifier: "comicList", sender: series)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SeriesCell", for: indexPath) as! SeriesTableViewCell
        
        let series = seriesList[indexPath.row]
        
        cell.setContent(series: series)
        
        return cell
    }
}


