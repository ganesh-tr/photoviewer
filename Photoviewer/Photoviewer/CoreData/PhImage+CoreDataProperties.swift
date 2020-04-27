//
//  PhImage+CoreDataProperties.swift
//  Photoviewer
//
//  Created by Ganesh TR on 24/04/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//
//

import Foundation
import CoreData


extension PhImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhImage> {
        return NSFetchRequest<PhImage>(entityName: "PhImage")
    }

    @NSManaged public var image: Data?
    @NSManaged public var imageExtension: String?
    @NSManaged public var imageName: String?
    @NSManaged public var imagePath: String?
    @NSManaged public var isFavourite: Bool

}
