//
//  ViewController.swift
//  VLImageUploader
//
//  Created by Kavya Krishna on 01/11/24.
//

import UIKit
import UniformTypeIdentifiers

class ViewController: UIViewController, UIDocumentPickerDelegate {
    
    private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Set up the loader (activity indicator)
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Create and configure the button
        let openZipButton = UIButton(type: .system)
        openZipButton.setTitle("Open Zip File", for: .normal)
        openZipButton.addTarget(self, action: #selector(openZipButtonTapped), for: .touchUpInside)
        
        openZipButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(openZipButton)
        
        NSLayoutConstraint.activate([
            openZipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openZipButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50)
        ])
    }

    @objc func openZipButtonTapped() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.zip])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let zipFileURL = urls.first else { return }
        
        DispatchQueue.main.async {
            self.showLoader(true)
        }
        // Begin accessing security-scoped resource
        guard zipFileURL.startAccessingSecurityScopedResource() else {
            print("Unable to access security-scoped resource.")
            return
        }
        
        defer { zipFileURL.stopAccessingSecurityScopedResource() }  // Ensure we stop accessing the resource after
        
        do {
            // Define a destination path in the app's Caches directory
            let fileManager = FileManager.default
            let destinationURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(zipFileURL.lastPathComponent)
            
            // Copy the ZIP file to the app's Caches directory
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)  // Remove existing file if needed
            }
            try fileManager.copyItem(at: zipFileURL, to: destinationURL)
            
            // Now that the ZIP file is in a writable directory, proceed with unzipping
            FileManagerHelper.unzipAndSaveImages(zipFilePath: destinationURL) { imageURLs, error in
                if let error = error {
                    print("Error unzipping file: \(error)")
                    DispatchQueue.main.async {
                        self.showLoader(false)
                    }
                } else if let imageURLs = imageURLs {
                    print("Unzipped Image Files:")
                    DispatchQueue.main.async {
                        self.showLoader(false)
                    }
                    imageURLs.forEach { imageUrl in
                        print(imageUrl.lastPathComponent)  // Display each image file name
                    }
                    
                    // TODO: Update UI with the images (e.g., reload table view or collection view)
                }
            }
        } catch {
            print("Error copying file to writable directory: \(error)")
        }
    }

    // Show or hide the loader
        private func showLoader(_ show: Bool) {
            if show {
                activityIndicator.startAnimating()
                view.isUserInteractionEnabled = false
            } else {
                activityIndicator.stopAnimating()
                view.isUserInteractionEnabled = true
            }
        }

}

