//
//  ComicTableViewCell.swift
//  Comics-ios
//
//  Created by Javi Manzano on 24/04/2017.
//  Copyright © 2017 Javi Manzano. All rights reserved.
//

import UIKit

class ComicTableViewCell: UITableViewCell {
    
    var comic: Comic?
    var timer = Timer()
    var offlineComicIds: [NSNumber] = []
    let comicsController = ComicsController.sharedInstance
    
    @IBOutlet weak var comicTitle: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var downloadProgress: UILabel!
    
    @IBAction func downloadComic(_ sender: Any) {
        if let comic = comic {
            downloadButton.isHidden = true
            removeButton.isHidden = true
            downloadProgress.text = "Downloading"
            downloadProgress.isHidden = false
            
            comicsController.registerBackgroundTask()
            comicsController.downloadComic(comic: comic)
            
            updateDownloadPercentage()
        }
    }
    
    @IBAction func removeComicDownload(_ sender: Any) {
        if let comic = comic {
            comic.getComicDirectoryURL().emptyDirectory()
        }
    }
    
    func setContent (offlineComicIds: [NSNumber], comic: Comic) {
        self.comic = comic
        self.offlineComicIds = offlineComicIds
        comicTitle.text = comic.title
        
        updateDownloadPercentage()
        lookForOfflineComic()
    }
    
    func updateDownloadPercentage () {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateDownload), userInfo: nil, repeats: true)
    }
    
    func lookForOfflineComic () {
        if let comic = comic {
            if offlineComicIds.contains(comic.id) {
                downloadButton.isHidden = true
                removeButton.isHidden = false
                downloadProgress.isHidden = true
            } else {
                removeButton.isHidden = true
                downloadButton.isHidden = false
            }
        }
    }
    
    func updateDownload (){
        if let comic = comic {
            if let percentage = comicsController.getCurrentPercentage(comic: comic) {
                downloadButton.isHidden = true
                removeButton.isHidden = true
                downloadProgress.text = percentage
                downloadProgress.isHidden = false
            } else {
                lookForOfflineComic()
                timer.invalidate()
            }
        }
    }
}
