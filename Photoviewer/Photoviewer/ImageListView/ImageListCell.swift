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
        updateView()
    }
    
    func updateCellForImage(_ phImage:PhImage) {
        self.phImage = phImage
        updateView()
    }

    func updateView() {
        imageNameLabel.text = self.phImage.imageName!
        favouriteButton.isSelected = self.phImage.isFavourite
        phImageView.image = UIImage(data:phImage.image!)
        phImageView.layer.borderWidth = 3.0
        phImageView.layer.borderColor = UIColor.systemBlue.cgColor
        phImageView.layer.cornerRadius = phImageView.frame.size.width/2
    }
    
    @IBAction func onTapFavouriteButton(_ sender: Any) {
        phImage.isFavourite.toggle()
        coreDataStack.saveContext()
    }
    
}