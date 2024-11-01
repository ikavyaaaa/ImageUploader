//
//  ViewController.swift
//  VLImageUploader
//
//  Created by Kavya Krishna on 01/11/24.
//

import UIKit
import UniformTypeIdentifiers

class ViewController: UIViewController, UIDocumentPickerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Create and configure the button
        let openZipButton = UIButton(type: .system)
        openZipButton.setTitle("Open Zip File", for: .normal)
        openZipButton.addTarget(self, action: #selector(openZipButtonTapped), for: .touchUpInside)
        
        // Set up button constraints or frame
        openZipButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(openZipButton)
        
        NSLayoutConstraint.activate([
            openZipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openZipButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
        
        // Use FileManagerHelper to unzip and process the images
        FileManagerHelper.unzipAndSaveImages(zipFilePath: zipFileURL) { imageURLs, error in
            if let error = error {
                print("Error unzipping file: \(error)")
            } else if let imageURLs = imageURLs {
                // Print the names of the unzipped images in the console
                print("Unzipped Image Files:")
                imageURLs.forEach { imageUrl in
                    print(imageUrl.lastPathComponent)  // Print only the file name
                }
            }
        }
    }
}

