//
//  Series.swift
//  Comics-ios
//
//  Created by Javi Manzano on 24/04/2017.
//  Copyright © 2017 Javi Manzano. All rights reserved.
//

import Foundation

class Series {
    let id: NSNumber
    let title: String
    let author: String
    let year: String
    
    init(id: NSNumber, title: String, author: String, year: String) {
        self.id = id
        self.title = title
        self.author = author
        self.year = year
    }
}
