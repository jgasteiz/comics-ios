//
//  OfflineComicTableViewCell.swift
//  Comics-ios
//
//  Created by Javi Manzano on 5/21/17.
//  Copyright © 2017 Javi Manzano. All rights reserved.
//

import UIKit

class OfflineComicTableViewCell: UITableViewCell {
    
    @IBOutlet weak var comicTitle: UILabel!
    
    func setContent (offlineComic: OfflineComic) {
        comicTitle.text = offlineComic.title
    }
}
