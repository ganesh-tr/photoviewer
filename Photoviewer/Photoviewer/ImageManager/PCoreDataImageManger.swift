//
//  PCoreDataImageManger.swift
//  Photoviewer
//
//  Created by Ganesh TR on 22/04/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import CoreData
import Foundation
import UIKit

protocol ImageManagerProtocol {
    func loadImages(callBack:@escaping ([PhImage])->())
    func deleteImage(image:PhImage, callBack:@escaping ()->())
    func refreshImage(callBack:@escaping ([PhImage])->())
    func addImage(image:UIImage,callBack:@escaping (PhImage?)->())
}

class PCoreDataImageManger: ImageManagerProtocol {
    private static let fileExtensions : [String] = ["jpeg","jpg","png"]
    private var managedContext: NSManagedObjectContext
    private let fileProtocol : PFileMangerProtocol  = PFileManager.shareInstance
    private let userDefaults : UserDefaultsProtocol = PCoreDataUserDefaults.sharedInstance
    typealias ImageType = PhImage
    
    init(managedContext:NSManagedObjectContext) {
        self.managedContext = managedContext
    }
    
    private func copyImagesFromLocalBundle(callBack: @escaping () -> ()) {
        print(userDefaults.isImageLoadedFromLocalBundle())
        if !userDefaults.isImageLoadedFromLocalBundle(),
            let resPath = PFileManager.shareInstance.resourcePath() {
           let dirContents =
               fileProtocol.directoryContentAtPath(fileProtocol.resourcePath()!)
           let filteredFiles = dirContents.filter{ PCoreDataImageManger.fileExtensions.contains($0.pathExtension)}
           for fileName in filteredFiles {
               let sourceURL =
                   fileProtocol.appendFileNameWithPath(resPath, fileName: fileName)
                self.savePhImageObject(imagePath:sourceURL)
           }
           userDefaults.loadedImageFromLocalBundle()
        }
        print(userDefaults.isImageLoadedFromLocalBundle())
        callBack()
    }
    
    func loadImages(callBack: @escaping ([PhImage]) -> ()) {
        self.copyImagesFromLocalBundle {
            self.fetchImages { (images) in
                callBack(images)
            }
        }
    }
    
    func deleteImage(image: PhImage, callBack: @escaping () -> ()) {
        managedContext.delete(image)
        do {
            try managedContext.save()
           } catch let error as NSError {
              print("Saving error: \(error), description: \(error.userInfo)")
        }
        callBack()
    }
    
    func refreshImage(callBack: @escaping ([PhImage]) -> ()) {
        deleteAllImages()
        userDefaults.resetLoadedImageFromLocalBundleKey()
        self.loadImages(callBack: { (images) in
            callBack(images)
        })
     }
     
     func addImage(image: UIImage, callBack: @escaping (PhImage?) -> ()) {
        let phImage =
            self.savePhImageObject(imagePath:String.customImageName(),image:image)
        callBack(phImage)
     }
    
    @discardableResult
    func createImageObjectFromPath(imagePath:String, image:UIImage? = nil) -> PhImage {
        let phImage = PhImage(context: managedContext)
        phImage.imagePath      = imagePath
        phImage.imageExtension = imagePath.pathExtension
        phImage.imageName      = imagePath.lastPathComponent
        phImage.isFavourite    = false
        if let newImage = image {
            phImage.image = newImage.jpegData(compressionQuality: 1.0)!
        } else {
            if let image = UIImage(contentsOfFile:imagePath) {
               phImage.image      = image.jpegData(compressionQuality: 1.0 )!
            }
        }
        return phImage
    }
    
    @discardableResult
    func savePhImageObject(imagePath:String, image:UIImage? = nil) -> PhImage? {
        do{
            let phImage = createImageObjectFromPath(imagePath: imagePath,image:image)
            try managedContext.save()
            return phImage
        }catch let error as NSError {
          print("Fetch error: \(error) description: \(error.userInfo)")
        }
        return nil
    }
    
    func fetchImages(callBack:([PhImage])->()) {
        let imageFetch : NSFetchRequest<PhImage> = PhImage.fetchRequest()
        do {
            let results = try self.managedContext.fetch(imageFetch)
            callBack(results)
          } catch let error as NSError {
                print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
    
    func deleteAllImages() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: CDPhImageEntityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try managedContext
                .persistentStoreCoordinator?.execute(deleteRequest, with: managedContext)
        } catch let error as NSError {
            print("RefreshImage batch delete error:\(error)")
        }
    }
}
