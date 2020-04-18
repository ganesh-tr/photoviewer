//
//  PLocalImageManager.swift
//  Photoviewer
//
//  Created by Ganesh TR on 18/04/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import Foundation
import UIKit


class PLocalImageManager : ImageManager {
    private static let fileExtensions : [String] = ["jpeg","jpg","png"]
    
    static let shareInstance = PLocalImageManager()
    
    private init() {}
    
    func copyFilesFromBundleToDocumentsFolderWith(callBack:@escaping ()->()) {
        DispatchQueue.global(qos: .background).async {
            if let resPath = PFileManager.shareInstance.resourcePath() {
                let dirContents = PFileManager.shareInstance.directoryContentAtPath(resPath)
                let documentsURL = PFileManager.shareInstance.documentDirectoryPath()
                let filteredFiles = dirContents.filter{ PLocalImageManager.fileExtensions.contains($0.pathExtension)}
                for fileName in filteredFiles {
                    let documentPath =
                        PFileManager.shareInstance
                            .appendFileNameWithPath(documentsURL, fileName: fileName)?.path
                    if let destURL = documentPath, !FileManager.default.fileExists(atPath: destURL)  {
                        let sourceURL =
                                PFileManager.shareInstance
                                    .appendFileNameWithPath(resPath, fileName: fileName)
                        print("Source: URL \(sourceURL)")
                        print("Dest: URL \(destURL)")
                        do {
                            try FileManager.default.copyItem(atPath: sourceURL, toPath:destURL)
                        }
                        catch {
                            print("Unexpected error: \(error).")
                        }
                    }
                }
            }
            PUserDefaults.sharedInstance.loadedImageFromLocalBundle()
            callBack()
        }
    }
    
    func loadImages(callBack:@escaping ([PImage])->()) {
        if !PUserDefaults.sharedInstance.isImageLoadedFromLocalBundle() {
             self.copyFilesFromBundleToDocumentsFolderWith() {
                DispatchQueue.global(qos: .background).async {
                    if let documentPath =
                                PFileManager.shareInstance.documentDirectoryPath()?.path {
                        let dirContents = PFileManager.shareInstance.directoryContentAtPath(documentPath)
                        let filteredFiles = dirContents.filter{
                            PLocalImageManager.fileExtensions.contains($0.pathExtension)
                        }
                        var localImages = [PImage]()
                        for fileName in filteredFiles {
                            let documentPath =
                                PFileManager.shareInstance
                                    .appendFileNameWithPath(documentPath, fileName: fileName)
                            let pImage = PImage(imagePath: documentPath)
                            localImages.append(pImage)
                        }
                        PUserDefaults.sharedInstance.loadedImageFromLocalBundle()
                        callBack(localImages)
                    }
                }
            }
        } else {
            DispatchQueue.global(qos: .background).async {
                if let documentPath = PFileManager.shareInstance.documentDirectoryPath()?.path {
                    let dirContents = PFileManager.shareInstance.directoryContentAtPath(documentPath)
                    let filteredFiles =
                        dirContents.filter{ PLocalImageManager.fileExtensions.contains($0.pathExtension)}
                    var localImages = [PImage]()
                    for fileName in filteredFiles {
                        let documentPath = PFileManager.shareInstance.appendFileNameWithPath(documentPath, fileName: fileName)
                        let pImage = PImage(imagePath: documentPath)
                        localImages.append(pImage)
                    }
                    callBack(localImages)
                }
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
    
    func refreshImage(callBack:@escaping ([PImage])->()) {
        DispatchQueue.global(qos: .background).async {
            if let resPath = PFileManager.shareInstance.resourcePath() {
                let dirContents = PFileManager.shareInstance.directoryContentAtPath(resPath)
                let documentsURL = PFileManager.shareInstance.documentDirectoryPath()
                let filteredFiles =
                    dirContents.filter{ PLocalImageManager.fileExtensions.contains($0.pathExtension)}
                for fileName in filteredFiles {
                    let documentPath =
                        PFileManager.shareInstance
                            .appendFileNameWithPath(documentsURL, fileName: fileName)?.path
                    if let destURL = documentPath {
                        let sourceURL =
                            PFileManager.shareInstance
                                .appendFileNameWithPath(resPath, fileName: fileName)
                        print("Source: URL \(sourceURL)")
                        print("Dest: URL \(destURL)")
                        do {
                            if FileManager.default.fileExists(atPath: destURL) {
                                try FileManager.default.removeItem(atPath: destURL)
                            }
                            try FileManager.default.copyItem(atPath: sourceURL, toPath:destURL)
                        }
                        catch {
                            print("Unexpected error: \(error).")
                        }
                    }
                }
                self.loadImages { (images) in
                    callBack(images)
                }
            }
        }
    }
    
    func addImage(image:UIImage,callBack:@escaping (PImage)->()) {
        DispatchQueue.global(qos: .background).async {
            let documentsURL = PFileManager.shareInstance.documentDirectoryPath()
            let documentPath =
                PFileManager.shareInstance
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
