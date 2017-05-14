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
    
    var series: Series?
    
    func setContent (series: Series) {
        self.series = series
        seriesTitle.text = series.title
    }
}
