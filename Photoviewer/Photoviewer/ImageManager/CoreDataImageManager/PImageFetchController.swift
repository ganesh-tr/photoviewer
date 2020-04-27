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

protocol PhImageFetcherProtocol : class {
    var fetchRequest: NSFetchRequest<PhImage>{get set}
    var fetchResultController:NSFetchedResultsController<PhImage> {get set}
    func preformFetch(callback: @escaping (Bool)->())
    func numberOfSections() -> Int
    func numberOfRowsInSection(section:Int) -> Int
    func objectAtIndexPath(_ indexPath:IndexPath) -> PhImage
    func deleteObjectAtIndexPath(_ indexPath:IndexPath)
    func addImage(image:UIImage)
}

class PImageFetchController: PhImageFetcherProtocol {
    private static let fileExtensions : [String] = ["jpeg","jpg","png"]
    private var managedObjectContext: NSManagedObjectContext
    private let fileManager : PFileMangerProtocol  = PFileManager()
    private let userDefaults : UserDefaultsProtocol = PCoreDataUserDefaults.sharedInstance
    var fetchRequest: NSFetchRequest<PhImage>
    var fetchResultController:NSFetchedResultsController<PhImage>

    init(managedObjectContext:NSManagedObjectContext,
         delegate:NSFetchedResultsControllerDelegate) {
        self.managedObjectContext = managedObjectContext
        self.fetchRequest = PhImage.fetchRequest()
        let imageNameSort = NSSortDescriptor(key: #keyPath(PhImage.imageName), ascending: true)
        self.fetchRequest.sortDescriptors = [imageNameSort]
        self.fetchResultController =
           NSFetchedResultsController(fetchRequest: fetchRequest,
                                      managedObjectContext:self.managedObjectContext ,
                                      sectionNameKeyPath:nil,
                                      cacheName:"PhImageCache")
        self.fetchResultController.delegate = delegate
    }
    
    func numberOfSections() -> Int {
        return self.fetchResultController.sections?.count ?? 0
    }

    func numberOfRowsInSection(section:Int) -> Int {
        guard let sectionInfo =
            self.fetchResultController.sections?[section] else {
             return 0
           }
        return sectionInfo.numberOfObjects
    }

    func preformFetch(callback: @escaping (Bool)->()) {
        self.copyImagesFromLocalBundle {
            var success = false
            do {
                try self.fetchResultController.performFetch()
                success = true
            } catch let error as NSError {
                success = false
                print("Fetching error: \(error), \(error.userInfo)")
            }
            callback(success)
        }
    }

    func addImage(image:UIImage) {
        self.savePhImageObject(imagePath:String.customImageName(),image:image)
    }
    
    func objectAtIndexPath(_ indexPath:IndexPath) -> PhImage {
        return self.fetchResultController.object(at: indexPath)
    }
    
    func deleteObjectAtIndexPath(_ indexPath:IndexPath) {
        self.managedObjectContext.delete(self.fetchResultController.object(at: indexPath))
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Saving error: \(error), description: \(error.userInfo)")
        }
    }
    
    func copyImagesFromLocalBundle(callBack: @escaping () -> ()) {
           print(userDefaults.isImageLoadedFromLocalBundle())
           if !userDefaults.isImageLoadedFromLocalBundle(),
               let resPath = fileManager.resourcePath() {
              let dirContents =
                  fileManager.directoryContentAtPath(fileManager.resourcePath()!)
              let filteredFiles = dirContents.filter{ PImageFetchController.fileExtensions.contains($0.pathExtension)}
              for fileName in filteredFiles {
                  let sourceURL =
                      fileManager.appendFileNameWithPath(resPath, fileName: fileName)
                   self.savePhImageObject(imagePath:sourceURL)
              }
              userDefaults.loadedImageFromLocalBundle()
           }
           print(userDefaults.isImageLoadedFromLocalBundle())
           callBack()
    }
    
    @discardableResult
    func createImageObjectFromPath(imagePath:String, image:UIImage? = nil) -> PhImage {
       let phImage = PhImage(context: self.managedObjectContext)
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
           try self.managedObjectContext.save()
           return phImage
       }catch let error as NSError {
         print("Fetch error: \(error) description: \(error.userInfo)")
       }
       return nil
    }
    
    func deleteAllImages(callback: @escaping ()->()) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "PhImage")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = NSBatchDeleteRequestResultType.resultTypeObjectIDs
        do {
            let result = try managedObjectContext
                .persistentStoreCoordinator?.execute(deleteRequest, with: managedObjectContext)
            let objectIDArray = (result as AnyObject).result as? [NSManagedObjectID]
            let changes = [NSDeletedObjectsKey : objectIDArray]
            NSManagedObjectContext
                .mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any],
                              into: [managedObjectContext])
        } catch let error as NSError {
            print("RefreshImage batch delete error:\(error)")
        }
        userDefaults.resetLoadedImageFromLocalBundleKey()
        self.preformFetch { (result) in
            callback()
        }
    }
        
    func performFilter(callback: @escaping ()->()) {
        self.fetchRequest.predicate = nil
        self.fetchRequest.predicate = NSPredicate(format: "isFavourite == %@",NSNumber(value: true))
        self.preformFetch { (result) in
            callback()
        }
    }
        
    
}
