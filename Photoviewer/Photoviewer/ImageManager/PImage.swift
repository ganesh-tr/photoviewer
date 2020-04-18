//
//  PImage.swift
//  Photoviewer
//
//  Created by Ganesh TR on 15/04/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import Foundation
import UIKit

struct PImage {
    var imagePath: String
    var imageName:String?
    var imageExtension:String?
    var image:UIImage?
    var imageScale:String {
        return "\(String(describing: self.image?.size.width)) * \(String(describing: self.image?.size.height))"
    }
    
    init(imagePath: String) {
        self.imagePath      = imagePath
        self.imageExtension = imagePath.pathExtension
        self.imageName      = imagePath.lastPathComponent
        self.image          = UIImage(contentsOfFile: self.imagePath)
        
    }
}
