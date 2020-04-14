//
//  ImageListViewController.swift
//  Photoviewer
//
//  Created by Ganesh TR on 10/04/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//
#if targetEnvironment(macCatalyst)
import AppKit
#endif
import UIKit
import CoreData

class ImageListViewController: UITableViewController, UIImagePickerControllerDelegate,
                               UINavigationControllerDelegate {

    var detailViewController: PreviewViewController? = nil
    var images : Array<UIImage> = []


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        for i in 1...10 {
            let image =  UIImage(named: "\(i).jpeg")
            images.append(image!)
        }
        navigationItem.leftBarButtonItem = editButtonItem

        var addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        let button =  UIButton(type: .system)
        button.setImage(UIImage(named: "icon_right"), for: .normal)
        button.addTarget(self, action: #selector(insertNewObject(_:)), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 53, height: 31)
        button.imageEdgeInsets = UIEdgeInsets(top: -1, left: 32, bottom: 1, right: -32)
        
        let label = UILabel(frame: CGRect(x: 3, y: 5, width: 50, height: 20))
        label.text = "Add"
        label.textAlignment = .center
        label.textColor = UIColor.systemBlue
        label.backgroundColor =   UIColor.clear
        button.addSubview(label)
        
        addButton = UIBarButtonItem(customView: button)

        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? PreviewViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    @objc
    func insertNewObject(_ sender: UIView) {
        let helper = ImagePicker(presenter: self, sourceView: sender)
        helper.pickImage()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = images[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! PreviewViewController
                controller.imageItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
//        return fetchedResultsController.sections?.count ?? 0
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        configureCell(cell, withName: "image \(indexPath.row)")
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withName name: String) {
        cell.textLabel!.text = name
    }
}

extension ImageListViewController {
    
  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true)
  }

  public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    dismiss(animated: true)
    ImagePicker.image(infoDictionary: info, completion: { (image, error) in
      if let error = error {
        print("unable to get image from picker - \(error)")
      } else if let image = image {
        self.images.append(image)
        self.tableView.reloadData()
      }
    })
  }
}
