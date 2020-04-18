//
//  ImagePicker.swift
//  Photoviewer
//
//  Created by Ganesh TR on 14/04/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public class ImagePicker: NSObject {
  let presenter: UIViewController &
                 UIImagePickerControllerDelegate &
                 UINavigationControllerDelegate
  private let sourceView: UIView
  var canAddRemoveAction = true
  private var cameraIsUserPermitted = false
  public var canPickImage = true

  public init(presenter: UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate, sourceView: UIView) {
    self.presenter = presenter
    self.sourceView = sourceView
    super.init()
  }

  public func pickImage() {
    requestPermission()
  }
}

extension ImagePicker {
  private func requestPermission() {
    var doChooseSource = true
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let cameraMediaType = AVMediaType.video
      let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)

      switch cameraAuthorizationStatus {
      case .denied:
        break
      case .restricted:
        break
      case .authorized:
        cameraIsUserPermitted = true
      case .notDetermined:
        // Prompting user for the permission to use the camera.
        doChooseSource = false
        AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
          if granted {
            self.cameraIsUserPermitted = true
          }
          DispatchQueue.main.async {
            self.chooseSource()
          }
        }

      @unknown default:
        assertionFailure("unhandled future case")
      }
    }

    if doChooseSource {
      chooseSource()
    }
  }

  private func chooseSource() {
    #if targetEnvironment(macCatalyst)
    displayPhotoPicker()
    #else
    let chooser = UIAlertController(title: NSLocalizedString("Image Source", comment: ""), message: nil, preferredStyle: .actionSheet)
    
    chooser.modalPresentationStyle = .popover
    chooser.popoverPresentationController?.sourceView = sourceView

    if canPickImage {
      chooser.addAction(UIAlertAction(title: NSLocalizedString("Photos", comment: ""), style: .default, handler: { (_) in
        self.displayPhotoPicker()
      }))
      if cameraIsUserPermitted {
        chooser.addAction(UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default, handler: { (_) in
          self.displayCameraUI()
        }))
      }
    }
    if canAddRemoveAction {
        chooser.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }

    presenter.present(chooser, animated: true, completion: nil)
    #endif
  }

  private func displayPhotoPicker() {
    let imagePicker =  UIImagePickerController()
    imagePicker.delegate = presenter
    imagePicker.modalPresentationStyle = .popover
    imagePicker.popoverPresentationController?.sourceView = sourceView
    presenter.present(imagePicker, animated: true, completion: nil)
  }

  private func displayCameraUI() {
    let cameraUI =  UIImagePickerController()
    cameraUI.delegate = presenter
    cameraUI.sourceType = .camera
    cameraUI.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? []

    presenter.present(cameraUI, animated: true, completion: nil)
  }

  public static func image(infoDictionary:[UIImagePickerController.InfoKey : Any],
                           completion:(_ image: UIImage?, _ error: Error?) -> ()) {
       if let url = infoDictionary[UIImagePickerController.InfoKey.imageURL] as? URL {
         if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
           completion(image, nil)
           return
         }
       }
       else if let image = infoDictionary[UIImagePickerController.InfoKey.originalImage] as? UIImage {
         completion(image, nil)
         return
       }
       
       if let image = infoDictionary[UIImagePickerController.InfoKey.editedImage] as? UIImage {
         completion(image, nil)
       }
       else {
         completion(nil, nil)
       }
   }
}
