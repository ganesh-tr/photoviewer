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
    lazy var coreDataStack = CoreDataStack(modelName: "Photoviewer")
    lazy var coreDataImageManger : PCoreDataImageManger! = PCoreDataImageManger(managedContext:coreDataStack.managedContext)
    private let imageManager : some ImageManager = PLocalImageManager.shareInstance
    
    var detailViewController: PreviewViewController? = nil
    var images : Array<PhImage> = []
    private var refreshTableViewControl:UIRefreshControl = UIRefreshControl()


    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetuUp()
        fetchAllImages()
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController =
                (controllers[controllers.count-1] as! UINavigationController).topViewController
                    as? PreviewViewController
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
    
    func initialSetuUp() {
        addRefreshControl()
        setUpNavBarItems()
    }
    
    func setUpNavBarItems() {
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
    }
    
    func addRefreshControl() {
        self.tableView.refreshControl = refreshTableViewControl
        self.refreshTableViewControl.addTarget(self,
                                               action: #selector(refreshTableViewData(_:)),
                                               for: .valueChanged)
        self.refreshTableViewControl.attributedTitle =
            NSAttributedString(string: "Refreshing local images....")
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let pImage = images[indexPath.row]
        configureCell(cell, withName:pImage.imageName)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                deleteImage(image: images[indexPath.row]) {
                self.images.remove(at:indexPath.row)
                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withName name: String) {
        cell.textLabel!.text = name
    }
    
    @objc func refreshTableViewData(_ sender: Any) {
        refreshImage {
            DispatchQueue.main.async {
                self.refreshTableViewControl.endRefreshing()
                self.tableView.layoutIfNeeded()
                self.tableView.reloadData()
            }
        }
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
        addImage(image: image) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
      }
    })
  }
}

extension ImageListViewController {
    func fetchAllImages() {
        coreDataImageManger.loadImages { (images) in
            self.images = images
            self.reloadTableView()
        }
    }
    
    func deleteImage(image:PhImage, callback: @escaping ()->()) {
        coreDataImageManger.deleteImage(image: image) {
            callback()
        }
    }
    
    func refreshImage(callback: @escaping ()->()) {
        coreDataImageManger.refreshImage { (images) in
            self.images = images
            callback()
        }
    }
    
    func addImage(image:UIImage,callback: @escaping ()->()) {
        coreDataImageManger.addImage(image: image) { (phImage) in
            if let addImage = phImage {
                self.images.append(addImage)
                callback()
            }
        }
    }

    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
