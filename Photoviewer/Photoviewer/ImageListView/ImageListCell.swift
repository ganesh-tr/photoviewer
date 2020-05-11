//
//  ImageListCell.swift
//  Photoviewer
//
//  Created by Ganesh TR on 26/04/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import Foundation
import UIKit

class ImageListCell : UITableViewCell {
    @IBOutlet weak var imageNameLabel:UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var phImageView: UIImageView!
    
    var phImage:PhImage!
    weak var coreDataStack:CoreDataStack!

    func configureCellForImage(_ phImage:PhImage, coreDataStack:CoreDataStack) {
        self.phImage = phImage
        self.coreDataStack = coreDataStack
        favouriteButton.accessibilityIdentifier = PString.a11yTextForFavourite()
        updateView()
    }
    
    func updateCellForImage(_ phImage:PhImage) {
        self.phImage = phImage
        updateView()
    }

    func updateView() {
        if let imageName = self.phImage.imageName {
            imageNameLabel.text = imageName
            imageNameLabel.accessibilityLabel = imageName
        }

        favouriteButton.isSelected = self.phImage.isFavourite
        if let imageObject = phImage.image {
            phImageView.image = UIImage(data:imageObject)
        }
        phImageView.layer.borderWidth = 3.0
        phImageView.layer.borderColor = UIColor.systemBlue.cgColor
        phImageView.layer.cornerRadius = phImageView.frame.size.width/2
        favouriteButton.accessibilityValue =
            PString.a11yTextForFavouriteSelection(selection:self.phImage.isFavourite)
    }
    
    @IBAction func onTapFavouriteButton(_ sender: Any) {
        phImage.isFavourite.toggle()
        coreDataStack.saveContext()
    }
    
}
