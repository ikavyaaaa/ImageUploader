//
//  Helper.swift
//  VLImageUploader
//
//  Created by Kavya Krishna on 01/11/24.
//

import Foundation
import ZIPFoundation

class FileManagerHelper {
    
    /// Unzips a zip file and saves extracted images to a specified folder.
    /// - Parameters:
    ///   - zipFilePath: URL of the zip file to unzip.
    ///   - completion: Completion handler with the list of extracted image URLs or an error.
    static func unzipAndSaveImages(zipFilePath: URL, completion: @escaping ([URL]?, Error?) -> Void) {
        let fileManager = FileManager.default
        let destinationURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("ExtractedImages")
        
        DispatchQueue.global(qos: .background).async {
            do {
                // Create the destination directory if it doesn’t exist
                if !fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
                }
                
                // Unzip the file
                try fileManager.unzipItem(at: zipFilePath, to: destinationURL)
                
                // Collect extracted image URLs
                let imageFiles = try fileManager.contentsOfDirectory(at: destinationURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                let jpgFiles = imageFiles.filter { $0.pathExtension.lowercased() == "jpg" }
                
                // Return the list of images to the completion handler on the main thread
                DispatchQueue.main.async {
                    completion(jpgFiles, nil)
                }
                
            } catch {
                // If an error occurs, call completion with the error
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
}
