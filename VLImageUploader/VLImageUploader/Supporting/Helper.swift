//
//  Helper.swift
//  VLImageUploader
//
//  Created by Kavya Krishna on 01/11/24.
//

import Foundation
import ZIPFoundation

class FileManagerHelper {
    
    /// Unzips the provided zip file to a dynamically named folder based on the zip file name.
    /// Before unzipping, it removes any existing extracted folder with the same name.
    /// - Parameters:
    ///   - zipFilePath: The URL of the zip file to unzip.
    ///   - completion: Completion handler with the list of extracted image URLs or an error.
    static func unzipAndSaveImages(zipFilePath: URL, completion: @escaping ([URL]?, Error?) -> Void) {
        let fileManager = FileManager.default
        
        // Get the base name of the zip file (without extension) to use as folder name
        let zipFileName = zipFilePath.deletingPathExtension().lastPathComponent
        let destinationURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("ExtractedImages").appendingPathComponent(zipFileName)
        
        DispatchQueue.global(qos: .background).async {
            do {
                // If the directory already exists, remove it before extracting the new files
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                
                // Create the destination directory for the new extraction
                try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
                
                // Open the zip file
                guard let archive = Archive(url: zipFilePath, accessMode: .read) else {
                    throw NSError(domain: "FileManagerHelper", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to read zip file"])
                }
                
                var extractedImageURLs = [URL]()
                
                // Iterate over the entries in the archive and extract files
                for entry in archive {
                    let entryDestination = destinationURL.appendingPathComponent(entry.path)
                    
                    // Check if the entry is a file and ends with .jpg
                    if entry.type == .file && entry.path.hasSuffix(".jpg") {
                        try archive.extract(entry, to: entryDestination)
                        extractedImageURLs.append(entryDestination)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(extractedImageURLs, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
}

//MARK: - This class is for the specific folder name

//class FileManagerHelper {
//    
//    /// Unzips the provided zip file to a dynamically named folder based on the zip file name.
//    /// - Parameters:
//    ///   - zipFilePath: The URL of the zip file to unzip.
//    ///   - completion: Completion handler with the list of extracted image URLs or an error.
//    static func unzipAndSaveImages(zipFilePath: URL, completion: @escaping ([URL]?, Error?) -> Void) {
//        let fileManager = FileManager.default
//        
//        // Get the base name of the zip file (without extension) to use as folder name
//        let zipFileName = zipFilePath.deletingPathExtension().lastPathComponent
//        let destinationURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("ExtractedImages").appendingPathComponent(zipFileName)
//        
//        DispatchQueue.global(qos: .background).async {
//            do {
//                // Create the destination directory if it doesn’t exist
//                if !fileManager.fileExists(atPath: destinationURL.path) {
//                    try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
//                }
//                
//                // Open the zip file
//                guard let archive = Archive(url: zipFilePath, accessMode: .read) else {
//                    throw NSError(domain: "FileManagerHelper", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to read zip file"])
//                }
//                
//                var extractedImageURLs = [URL]()
//                
//                // Iterate over the entries in the archive and extract files
//                for entry in archive {
//                    let entryDestination = destinationURL.appendingPathComponent(entry.path)
//                    
//                    // Check if the entry is a file and ends with .jpg
//                    if entry.type == .file && entry.path.hasSuffix(".jpg") {
//                        try archive.extract(entry, to: entryDestination)
//                        extractedImageURLs.append(entryDestination)
//                    }
//                }
//                
//                DispatchQueue.main.async {
//                    completion(extractedImageURLs, nil)
//                }
//                
//            } catch {
//                DispatchQueue.main.async {
//                    completion(nil, error)
//                }
//            }
//        }
//    }
//}




//import Foundation
//import ZIPFoundation
//
//class FileManagerHelper {
//    
//    /// Unzips the selected ZIP file and saves images to `ExtractedImages` folder.
//    /// - Parameters:
//    ///   - zipFilePath: URL of the selected ZIP file.
//    ///   - completion: Callback with an array of image URLs or an error.
//    static func unzipAndSaveImages(zipFilePath: URL, completion: @escaping ([URL]?, Error?) -> Void) {
//        let fileManager = FileManager.default
//        let extractedImagesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("ExtractedImages")
//        
//        DispatchQueue.global(qos: .background).async {
//            do {
//                // Ensure `ExtractedImages` directory exists
//                if !fileManager.fileExists(atPath: extractedImagesDir.path) {
//                    try fileManager.createDirectory(at: extractedImagesDir, withIntermediateDirectories: true, attributes: nil)
//                }
//                
//                // Unzip the file into `ExtractedImages`
//                try fileManager.unzipItem(at: zipFilePath, to: extractedImagesDir)
//                
//                // Gather image files from "untitled folder" inside `ExtractedImages`
//                let imagesDir = extractedImagesDir.appendingPathComponent("VLProImages")
//                let imageFiles = try collectImages(from: imagesDir)
//                
//                // Callback with the list of image URLs
//                DispatchQueue.main.async {
//                    completion(imageFiles, nil)
//                }
//                
//            } catch {
//                DispatchQueue.main.async {
//                    completion(nil, error)
//                }
//            }
//        }
//    }
//    
//    /// Helper function to collect images in a given directory.
//    private static func collectImages(from directory: URL) throws -> [URL] {
//        let fileManager = FileManager.default
//        var imageFiles: [URL] = []
//        
//        let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
//        
//        for url in contents {
//            if url.lastPathComponent == "__MACOSX" {
//                continue  // Skip the `__MACOSX` folder
//            }
//            
//            if ["jpg", "jpeg", "png"].contains(url.pathExtension.lowercased()) {
//                imageFiles.append(url)  // Add image files to the list
//            }
//        }
//        
//        return imageFiles
//    }
//}
