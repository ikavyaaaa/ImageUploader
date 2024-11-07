//
//  Helper.swift
//  VLImageUploader
//
//  Created by Kavya Krishna on 01/11/24.
//

import Foundation
import ZIPFoundation

class FileManagerHelper {
    
    /// Unzips the selected ZIP file and saves images to `ExtractedImages` folder.
    /// - Parameters:
    ///   - zipFilePath: URL of the selected ZIP file.
    ///   - completion: Callback with an array of image URLs or an error.
    static func unzipAndSaveImages(zipFilePath: URL, completion: @escaping ([URL]?, Error?) -> Void) {
        let fileManager = FileManager.default
        let extractedImagesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("ExtractedImages")
        
        DispatchQueue.global(qos: .background).async {
            do {
                // Ensure `ExtractedImages` directory exists
                if !fileManager.fileExists(atPath: extractedImagesDir.path) {
                    try fileManager.createDirectory(at: extractedImagesDir, withIntermediateDirectories: true, attributes: nil)
                }
                
                // Unzip the file into `ExtractedImages`
                try fileManager.unzipItem(at: zipFilePath, to: extractedImagesDir)
                
                // Gather image files from "untitled folder" inside `ExtractedImages`
                let imagesDir = extractedImagesDir.appendingPathComponent("VLProImages")
                let imageFiles = try collectImages(from: imagesDir)
                
                // Callback with the list of image URLs
                DispatchQueue.main.async {
                    completion(imageFiles, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    /// Helper function to collect images in a given directory.
    private static func collectImages(from directory: URL) throws -> [URL] {
        let fileManager = FileManager.default
        var imageFiles: [URL] = []
        
        let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        for url in contents {
            if url.lastPathComponent == "__MACOSX" {
                continue  // Skip the `__MACOSX` folder
            }
            
            if ["jpg", "jpeg", "png"].contains(url.pathExtension.lowercased()) {
                imageFiles.append(url)  // Add image files to the list
            }
        }
        
        return imageFiles
    }
}
