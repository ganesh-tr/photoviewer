//
//  PImageManager.swift
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

class PImageManager {
    
    private let imageManager : ImageManager = PLocalImageManager.shareInstance
    static let shareInstance = PImageManager()
    
    private init() {}
    
    func loadImages(callBack: @escaping ([PImage]) -> ()) {
        imageManager.loadImages { (images) in
            callBack(images)
        }
    }
    
    func deleteImage(image: PImage, callBack: @escaping () -> ()) {
        imageManager.deleteImage(image: image) {
            callBack()
        }
    }
    
    func refreshImage(callBack:@escaping ([PImage])->()) {
        imageManager.refreshImage { (images) in
            callBack(images)
        }
    }
    
    func addImage(image:UIImage, callBack:@escaping (PImage)->())  {
        imageManager.addImage(image:image) { (images) in
            callBack(images)
        }
    }
}
