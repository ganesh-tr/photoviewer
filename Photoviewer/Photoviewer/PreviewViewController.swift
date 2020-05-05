//
//  PreviewViewController.swift
//  Photoviewer
//
//  Created by Ganesh TR on 10/04/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pathLabel: UILabel!
    @IBOutlet weak var imageSizeLabel: UILabel!
    
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

    var imageItem: PhImage? {
        didSet {
            configureView()
        }
    }

    @IBAction func onTapRotateButton(_ sender: Any) {
        let angle =  Double.pi/2
         let tr = CGAffineTransform.identity.rotated(by: CGFloat(angle))
         imageView.transform = tr
    }
}

