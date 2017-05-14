//
//  Comic.swift
//  Comics-ios
//
//  Created by Javi Manzano on 24/04/2017.
//  Copyright © 2017 Javi Manzano. All rights reserved.
//

import Foundation

class Comic {
    let id: NSNumber
    let title: String
    let pages: [String]
    let series: Series
    
    init(id: NSNumber, title: String, pages: [String], series: Series) {
        self.id = id
        self.title = title
        self.pages = pages
        self.series = series
    }
    
    func getPageURL(pageNum: Int) -> URL? {
        // If the comic is offline, return the offline url for the page,
        // otherwise return the external page url.
        
        if isOffline() {
            return getOfflinePagesURLs()[pageNum]
        }
        return URL(string: self.pages[pageNum])
    }
    
    func getSeriesDirectoryURL () -> URL {
        return ComicsController.getDownloadsDirectory().appendingPathComponent(series.title)
    }
    
    func getComicDirectoryURL () -> URL {
        return ComicsController.getDownloadsDirectory().appendingPathComponent("\(series.title)/\(title)")
    }
    
    func isOffline() -> Bool {
        // Check if the comic is offline by comparing the number of downloaded
        // pages with the number of pages in the pages property.
        
        return getOfflinePagesURLs().count == pages.count
    }
    
    private func getOfflinePagesURLs () -> [URL] {
        // Get a list of URLs for offline pages.
        
        do {
            return try FileManager.default.contentsOfDirectory(
                at: getComicDirectoryURL(),
                includingPropertiesForKeys: nil,
                options: .skipsPackageDescendants
            )
        } catch {
            print("Couldn't get the list of offline pages")
        }
        return []
    }
}
