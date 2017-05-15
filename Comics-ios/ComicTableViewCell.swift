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
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    @IBAction func downloadComic(_ sender: Any) {
        if let comic = comic {
            comicsController.downloadComic(comic: comic)
        }
    }
    
    @IBAction func removeComicDownload(_ sender: Any) {
        if let comic = comic {
            comic.getComicDirectoryURL().emptyDirectory()
        }
    }
    
    func setContent (offlineComicIds: [NSNumber], comic: Comic) {
        self.comic = comic
        comicTitle.text = comic.title
        
        if offlineComicIds.contains(comic.id) {
            downloadButton.isHidden = true
            removeButton.isHidden = false
        } else {
            removeButton.isHidden = true
            downloadButton.isHidden = false
        }
    }
}
