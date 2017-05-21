//
//  OfflineComicTableViewCell.swift
//  Comics-ios
//
//  Created by Javi Manzano on 5/21/17.
//  Copyright © 2017 Javi Manzano. All rights reserved.
//

import UIKit

class OfflineComicTableViewCell: UITableViewCell {
    
    var comic: Comic?
    let comicsController = ComicsController.sharedInstance
    
    @IBOutlet weak var comicTitle: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    @IBAction func removeComicDownload(_ sender: Any) {
        if let comic = comic {
            comic.getComicDirectoryURL().emptyDirectory()
        }
    }
    
    func setContent (comic: Comic) {
        self.comic = comic
        comicTitle.text = comic.title
    }
}
