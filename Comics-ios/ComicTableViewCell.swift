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
    let comicsController = ComicsController.sharedInstance
    
    @IBOutlet weak var comicTitle: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBAction func mainAction(_ sender: Any) {
        if let comic = comic {
            if comic.isOffline() {
                removeDownloadedComic()
            } else {
                downloadComic()
            }
        }
    }
    
    func setContent (comic: Comic) {
        self.comic = comic
        comicTitle.text = comic.title
        
        if comic.isOffline() {
            actionButton.titleLabel?.text = "Remove"
        } else {
            actionButton.titleLabel?.text = "Download"
        }
    }
    
    func downloadComic () {
        if let comic = comic {
            comicsController.downloadComic(comic: comic)
        }
    }
    
    func removeDownloadedComic () {
        if let comic = comic {
            comic.getComicDirectoryURL().emptyDirectory()
        }
    }
}
