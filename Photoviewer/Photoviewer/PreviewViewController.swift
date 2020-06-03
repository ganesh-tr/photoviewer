//
//  PreviewViewController.swift
//  Photoviewer
//
//  Created by Ganesh TR on 10/04/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import UIKit
import CoreData

class PreviewViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pathLabel: UILabel!
    @IBOutlet weak var imageSizeLabel: UILabel!
    
    var coredataStack:CoreDataStack!
    
    var imageItem: PhImage? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let imageV = imageView {
            if let image = imageItem?.image {
                imageV.image = UIImage.init(data:image)
                if let imageSizeLbl = imageSizeLabel {
                    imageSizeLbl.text =
                        "Size: \(imageV.image!.size.width) * \(imageV.image!.size.height)"
                }
                self.title = imageItem?.imageName
            }
        }
        if let imagePathLabel = pathLabel {
            if let imagePath = imageItem?.imagePath {
                imagePathLabel.text = "Path: \(imagePath)"
            } else {
                imagePathLabel.text = ""
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureView()
    }

    @IBAction func onTapRotateButton(_ sender: Any) {
        if let image = imageItem?.image {
            let rotatedImage = UIImage.init(data:image)?.rotate(radians: .pi/2)
            imageItem?.image = rotatedImage?.jpegData(compressionQuality: 1.0)
            self.imageView.image = rotatedImage
            coredataStack.saveContext()
        }
    }
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: CGFloat(radians))
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
