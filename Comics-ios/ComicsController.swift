//
//  ComicsController.swift
//  Comics-ios
//
//  Created by Javi Manzano on 24/04/2017.
//  Copyright © 2017 Javi Manzano. All rights reserved.
//

import Alamofire
import AlamofireImage
import Foundation

class ComicsController {
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    var downloads = [String: [String: AnyObject]]()
    
    static let sharedInstance = ComicsController()
    
    let mock = false
    
    func getAllSeriesURL () -> String {
        if mock {
            return "http://localhost:8000/api/series/?token=mock"
        } else {
            return "http://comics.jgasteiz.com/api/series/?token=\(getAPIToken())"
        }
    }
    
    func getSeriesDetailURL (series: Series) -> String {
        if mock {
            return "http://localhost:8000/api/series/\(series.id)/?token=mock"
        } else {
            return "http://comics.jgasteiz.com/api/series/\(series.id)/?token=\(getAPIToken())"
        }
    }
    
    func getAPIToken () -> String {
        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "credentials", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            return dict.value(forKey: "token") as! String
        }
        return ""
    }
    
    
    func getAllSeries (
        onSeriesFetched: @escaping ([Series]) -> Void,
        onError: @escaping () -> Void)
    {
        Alamofire
            .request(
                URL(string: getAllSeriesURL())!,
                method: .get
            )
            .responseJSON(completionHandler: { response in
                if let seriesJSON = response.result.value as? [NSDictionary] {
                    
                    // Get the snippets
                    var seriesList: [Series] = []
                    
                    // Add the fetched stories to the array
                    for seriesDict in seriesJSON {
                        seriesList.append(Series(
                            id: seriesDict["pk"] as! NSNumber,
                            title: seriesDict["title"] as! String,
                            author: seriesDict["author"] as! String,
                            year: seriesDict["year"] as! String
                        ))
                    }
                    
                    onSeriesFetched(seriesList)
                } else {
                    onError()
                }
            })
    }
    
    func getSeriesComics (
        series: Series,
        onComicsFetched: @escaping ([Comic]) -> Void,
        onError: @escaping () -> Void)
    {
        Alamofire
            .request(
                URL(string: getSeriesDetailURL(series: series))!,
                method: .get
            )
            .responseJSON(completionHandler: { response in
                if let seriesDetailJson = response.result.value as? NSDictionary, let comicListJSON = seriesDetailJson["comics"] as? [NSDictionary] {
                    
                    // Get the snippets
                    var comicList: [Comic] = []
                    
                    // Add the fetched stories to the array
                    for comicDict in comicListJSON {
                        comicList.append(Comic(
                            id: comicDict["pk"] as! NSNumber,
                            title: comicDict["title"] as! String,
                            pages: comicDict["pages"] as! [String],
                            series: series
                        ))
                    }
                    
                    onComicsFetched(comicList)
                } else {
                    onError()
                }
            })
    }
    
    func downloadComic (comic: Comic) {
        
        // Initialize the comic download
        downloads[comic.id.toString()] = [
            "numPages": comic.pages.count as AnyObject,
            "pagesDownloaded": 0 as AnyObject,
            "percentage": "0%" as AnyObject
        ]
        
        let downloadsDirectory = ComicsController.getDownloadsDirectory()
        print(downloadsDirectory.path)
        
        // Create a directory for the comic.
        ComicsController.createDirectoryAtPath(path: comic.getSeriesDirectoryURL().path)
        ComicsController.createDirectoryAtPath(path: comic.getComicDirectoryURL().path)
        
        // Remove any existing files/directories in the comic directory.
        comic.getComicDirectoryURL().emptyDirectory()
        
        // Download all comic pages in the comic directory.
        for page in comic.pages {
            if let pageURL = URL(string: page), let fileName = pageURL.getFileName() {

                Alamofire
                    .download(
                        URLRequest(url: pageURL),
                        to: { (destinationURL, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                            
                            return (
                                destinationURL: comic.getComicDirectoryURL().appendingPathComponent(fileName),
                                options: DownloadRequest.DownloadOptions()
                            )
                    })
                    .responseData(completionHandler: { response in
                        if (response.response?.statusCode == 200) {
                            print("Page `\(pageURL)` downloaded successfully.")
                            
                            self.downloads[comic.id.toString()]?["pagesDownloaded"] = self.downloads[comic.id.toString()]?["pagesDownloaded"] as! Int + 1 as AnyObject
                            
                            let totalPages = self.downloads[comic.id.toString()]?["numPages"] as! Int
                            let downloadedPages = self.downloads[comic.id.toString()]?["pagesDownloaded"] as! Int
                            let percentage = "\(100 * downloadedPages / totalPages)%"
                            self.downloads[comic.id.toString()]?["percentage"] = percentage as AnyObject
                            
                            // Check if all the pages have been downloaded
                            if (totalPages == downloadedPages) {
                                self.downloads[comic.id.toString()] = nil
                            }
                            
                        } else {
                            print ("ERROR: Page `\(pageURL)` wasn't downloaded successfully.")
                        }
                    })
            }
        }
    }
    
    func getCurrentPercentage (comic: Comic) -> String? {
        return self.downloads[comic.id.toString()]?["percentage"] as! String?
    }
    
    func getOfflineComics() -> [OfflineComic] {
        var comicList: [OfflineComic] = []
        
        do {
            let seriesURLs = try FileManager.default.contentsOfDirectory(
                at: ComicsController.getDownloadsDirectory(),
                includingPropertiesForKeys: nil,
                options: .skipsPackageDescendants
            )
            for seriesURL in seriesURLs {
                if !seriesURL.path.hasSuffix(".DS_Store") && seriesURL.isDirectory {
                    let comicURLs = try FileManager.default.contentsOfDirectory(
                        at: seriesURL,
                        includingPropertiesForKeys: nil,
                        options: .skipsPackageDescendants
                    )
                    
                    for comicURL in comicURLs {
                        if !comicURL.path.hasSuffix(".DS_Store") && comicURL.isDirectory {
                            let comicPagesURLs = try FileManager.default.contentsOfDirectory(
                                at: comicURL,
                                includingPropertiesForKeys: nil,
                                options: .skipsPackageDescendants
                            )
                            // If the offline comic has no pages, don't add the comic to the list.
                            if comicPagesURLs.count == 0 {
                                continue
                            }
                            
                            var offlineComicTitle = comicURL.path.components(separatedBy: "/").last
                            if offlineComicTitle == nil {
                                offlineComicTitle = "Unnamed comic"
                            }
                            if let offlineComicTitle = offlineComicTitle {
                                comicList.append(
                                    OfflineComic(title: offlineComicTitle, pages: comicPagesURLs)
                                )
                            }
                        }
                    }
                }
            }
        } catch {
            print("Couldn't get the list of offline pages")
        }
        
        return comicList
    }
    
    // Background task functions
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    func reinstateBackgroundTask() {
        if backgroundTask == UIBackgroundTaskInvalid {
            registerBackgroundTask()
        }
    }
    
    ////////////////////////////////////
    // MARK: - Static functions
    ////////////////////////////////////
    
    static func getDownloadsDirectory () -> URL {
        // Returns the URL for the downloads directory.
        let downloadsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Downloads")
        createDirectoryAtPath(path: downloadsDirectoryURL.path)
        return downloadsDirectoryURL
    }
    
    static func createDirectoryAtPath (path: String) -> Void {
        // Create a directory of the given url
        do {
            try FileManager.default.createDirectory(
                atPath: path,
                withIntermediateDirectories: false,
                attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
