//
//  OfflineComic.swift
//  Comics-ios
//
//  Created by Javi Manzano on 5/21/17.
//  Copyright © 2017 Javi Manzano. All rights reserved.
//

import Foundation

class OfflineComic {
    let title: String
    let pages: [URL]
    
    init(title: String, pages: [URL]) {
        self.title = title
        self.pages = pages
    }
    
    func getPageURL(pageNum: Int) -> URL? {
        return pages[pageNum]
    }
    
}
