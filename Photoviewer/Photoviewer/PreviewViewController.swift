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


    func configureView() {
        // Update the user interface for the detail item.
        if let imageview = imageView {
            if let image = imageItem {
                imageview.image = image
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var imageItem: UIImage? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    @IBAction func onTapRotateButton(_ sender: Any) {
        let angle =  Double.pi/2
         let tr = CGAffineTransform.identity.rotated(by: CGFloat(angle))
         imageView.transform = tr
    }
}

