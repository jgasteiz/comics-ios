//
//  SeriesTableViewCell.swift
//  Comics-ios
//
//  Created by Javi Manzano on 24/04/2017.
//  Copyright © 2017 Javi Manzano. All rights reserved.
//

import UIKit

class SeriesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var seriesTitle: UILabel!
    @IBOutlet weak var seriesAuthor: UILabel!
    @IBOutlet weak var seriesYear: UILabel!
    
    var series: Series?
    
    func setContent (series: Series) {
        self.series = series
        seriesTitle.text = series.title
        seriesAuthor.text = series.author
        seriesYear.text = series.year
    }
}
