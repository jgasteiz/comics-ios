//
//  URL+Extensions.swift
//  Comics-ios
//
//  Created by Javi Manzano on 02/05/2017.
//  Copyright © 2017 Javi Manzano. All rights reserved.
//

import Foundation

enum ContentType {
    case Directory;
    case File;
}

extension URL {
    var isDirectory: Bool {
        var isDir: ObjCBool = false
        if FileManager().fileExists(atPath: path, isDirectory: &isDir) {
            return true
        }
        return false
    }
    
    var subdirectories: [URL] {
        // Return the URLs for all directories in the self url directory.
        
        return self.getContents(contentType: ContentType.Directory)
    }
    
    var files: [URL] {
        // Return the URLs for all files in the self url directory.
        
        return self.getContents(contentType: ContentType.File)
    }
    
    func getContents(contentType: ContentType?) -> [URL] {
        // Get a list of URLs for each of the files/directories (depending on
        // the given content type) in the URL.
        
        if !isDirectory {
            return []
        }
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: self,
                includingPropertiesForKeys: nil,
                options: [])
            // Filter the directory contents by the given contentType.
            return contents.filter({ (url) -> Bool in
                if let contentType = contentType {
                    if contentType == ContentType.Directory {
                        return url.isDirectory
                    } else if contentType == ContentType.File {
                        return url.isFileURL
                    }
                    return false
                }
                
                return true
            })
        } catch let error as NSError {
            // Nothing to return.
            print(error.localizedDescription)
            return []
        }
    }
    
    func emptyDirectory () {
        // Delete all contents from the URL directory.
        
        for fileURL in files {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("Couldn't delete the path \(fileURL.path)")
            }
        }
        for directoryURL in subdirectories {
            do {
                try FileManager.default.removeItem(at: directoryURL)
            } catch {
                print("Couldn't delete the path \(directoryURL.path)")
            }
        }
    }
    
    func getFileName() -> String? {
        // Returns the fileName of the URL.
        
        return self.path.characters.split(separator: "/").map(String.init).last
    }
}
