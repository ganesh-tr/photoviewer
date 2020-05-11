//
//  PLocalImageManager.swift
//  Photoviewer
//
//  Created by Ganesh TR on 18/04/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import Foundation
import UIKit

protocol ImageManager {
    func loadImages(callBack:@escaping ([PImage])->())
    func deleteImage(image:PImage, callBack:@escaping ()->())
    func refreshImage(callBack:@escaping ([PImage])->())
    func addImage(image:UIImage,callBack:@escaping (PImage)->())
}

class PLocalImageManager : ImageManager {
    private static let fileExtensions : [String] = ["jpeg","jpg","png"]
    private let userDefaults : UserDefaultsProtocol
    let fileManager : PFileMangerProtocol
    typealias ImageType = PImage
    
    init(fileManager : PFileMangerProtocol = PFileManager(),
         userDefaults : UserDefaultsProtocol = PDocumentDirectoryUserDefaults.sharedInstance) {
        self.fileManager = fileManager
        self.userDefaults = userDefaults
    }
    
    func copyImagesFromLocalBundle(callBack:@escaping ()->()) {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            if let resPath = self.fileManager.resourcePath() {
                let dirContents = self.fileManager.directoryContentAtPath(resPath)
                let documentsURL = self.fileManager.documentDirectoryPath()
                let filteredFiles = dirContents.filter{ PLocalImageManager.fileExtensions.contains($0.pathExtension)}
                for fileName in filteredFiles {
                    let documentPath =
                        self.fileManager
                            .appendFileNameWithPath(documentsURL, fileName: fileName)?.path
                    if let destURL = documentPath  {
                        let sourceURL =
                            self.fileManager
                                    .appendFileNameWithPath(resPath, fileName: fileName)
                        do {
                            if FileManager.default.fileExists(atPath:destURL)  {
                                try?FileManager.default.removeItem(atPath:destURL)
                            }
                            try FileManager.default.copyItem(atPath: sourceURL, toPath:destURL)
                        }
                        catch {
                            print("Unexpected error: \(error).")
                        }
                    }
                }
            }
            self.userDefaults.loadedImageFromLocalBundle()
            callBack()
        }
    }
    
    func loadImages(callBack:@escaping ([PImage])->()) {
        if !self.userDefaults.isImageLoadedFromLocalBundle() {
             self.copyImagesFromLocalBundle() {
                self.loadImageFromDocumentDirectoryPath { (images) in
                    self.userDefaults.loadedImageFromLocalBundle()
                    callBack(images)
                }
            }
        } else {
            self.loadImageFromDocumentDirectoryPath { (images) in
                callBack(images)
            }
        }
    }
    
    func loadImageFromDocumentDirectoryPath(callBack:@escaping ([PImage])->()) {
        DispatchQueue.global(qos: .background).async {[unowned self] in
            if let documentPath =
                        self.fileManager.documentDirectoryPath()?.path {
                let dirContents = self.fileManager.directoryContentAtPath(documentPath)
                let filteredFiles = dirContents.filter{
                    PLocalImageManager.fileExtensions.contains($0.pathExtension)
                }
                var localImages = [PImage]()
                for fileName in filteredFiles {
                    let documentPath =
                        self.fileManager
                            .appendFileNameWithPath(documentPath, fileName: fileName)
                    let pImage = PImage(imagePath: documentPath)
                    localImages.append(pImage)
                }
                self.userDefaults.loadedImageFromLocalBundle()
                callBack(localImages)
            }
        }
    }

    func deleteImage(image:PImage,callBack:@escaping ()->()) {
        DispatchQueue.global(qos: .background).async {
            if FileManager.default.fileExists(atPath: image.imagePath)  {
                try?FileManager.default.removeItem(atPath: image.imagePath)
                callBack()
            }
        }
    }
    
    func refreshImage(callBack: @escaping ([PImage])->()) {
        self.userDefaults.resetLoadedImageFromLocalBundleKey()
        self.loadImages { (images) in
            callBack(images)
        }
    }
    
    func addImage(image:UIImage,callBack:@escaping (PImage)->()) {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            let documentsURL = self.fileManager.documentDirectoryPath()
            let documentPath =
                self.fileManager
                    .appendFileNameWithPath(documentsURL, fileName: String.customImageName())?.path
            if let destURL = documentPath {
                print("Dest: URL \(destURL)")
                do {
                    if FileManager.default.fileExists(atPath: destURL) {
                        try FileManager.default.removeItem(atPath: destURL)
                    }
                    FileManager.default.createFile(atPath: destURL, contents: image.jpegData(compressionQuality: 1), attributes:nil)
                    let pImage = PImage(imagePath: destURL)
                    callBack(pImage)
                }
                catch {
                    print("Unexpected error: \(error).")
                }
            }
        }
    }
}
