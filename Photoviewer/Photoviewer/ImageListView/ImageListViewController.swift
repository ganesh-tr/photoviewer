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
    var coreDataImageManger : PImageFetchController!
    var detailViewController: PreviewViewController? = nil
    var images : Array<PhImage> = []
    private var refreshTableViewControl:UIRefreshControl = UIRefreshControl()


    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController =
                (controllers[controllers.count-1] as! UINavigationController).topViewController
                    as? PreviewViewController
        }
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 60
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func initialSetUp() {
        addRefreshControl()
        setUpNavBarItems()
        coredDataSetup()
        self.tableView.tableFooterView = UIView()
    }
    
    func setUpNavBarItems() {
        navigationItem.leftBarButtonItem = editButtonItem
        let addTitle = PString.a11yTitleTextForAddButton()
        let filterTitle = PString.a11yTextForFilterButton()
        let addButton = UIBarButtonItem(customView: createButtonWithIcon(nil, title:addTitle, action:#selector(insertNewObject(_:))))
        addButton.accessibilityIdentifier = addTitle
        addButton.accessibilityLabel = PString.a11yTextForAddButton()
        let filterButton = UIBarButtonItem(customView:createButtonWithIcon("", title:"Fltr", action: #selector(filterList(_:))))
        filterButton.accessibilityIdentifier = filterTitle
        filterButton.accessibilityLabel = filterTitle
        
        navigationItem.rightBarButtonItems = [addButton,filterButton]
    }
    
    func createButtonWithIcon(_ name:String?, title:String,
                              action:Selector) -> UIButton {
        let button =  UIButton(type: .system)
        if name != nil {
            button.setImage(UIImage(named: name!), for: .normal)
        }
        button.addTarget(self, action:action, for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 53, height: 31)
        button.imageEdgeInsets = UIEdgeInsets(top: -1, left: 32, bottom: 1, right: -32)
        button.addSubview(createLabelWithText(title:title))
        return button
    }
    
    func createLabelWithText(title:String) -> UILabel {
        let label = UILabel(frame: CGRect(x: 3, y: 5, width: 50, height: 20))
        label.text = title
        label.textAlignment = .center
        label.textColor = UIColor.systemBlue
        label.backgroundColor =   UIColor.clear
        return label
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
    
    @objc func filterList(_ sender: UIView) {
        let filterAlertController = UIAlertController(title: PString.a11yTextForFilterButton(), message: nil, preferredStyle: .actionSheet)
            filterAlertController.modalPresentationStyle = .popover
            filterAlertController.popoverPresentationController?.sourceView = sender
            filterAlertController.addAction(
                UIAlertAction(
                    title: NSLocalizedString(PString.a11yTextForFavourite(), comment: ""),
                    style: .default, handler: { [unowned self](_) in
                        self.coreDataImageManger.performFilter(isFavourite:true) {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
            }))
            filterAlertController.addAction(
                UIAlertAction(
                    title: PString.a11yTextForRemoveFilter(),
                    style: .default, handler: { [unowned self](_) in
                        self.coreDataImageManger.performFilter(isFavourite:false) {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
            }))
            filterAlertController.addAction(
                UIAlertAction(title: PString.a11yTextForCancelButton(),
                              style: .cancel, handler: nil))
           self.present(filterAlertController, animated: true, completion: nil)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = self.coreDataImageManger.objectAtIndexPath(indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! PreviewViewController
                controller.imageItem = object
                controller.coredataStack = coreDataStack
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.coreDataImageManger.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coreDataImageManger.numberOfRowsInSection(section:section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView
                .dequeueReusableCell(withIdentifier: "ImageListCell",
                                    for: indexPath) as! ImageListCell
        let phImage = self.coreDataImageManger.objectAtIndexPath(indexPath)
        cell.configureCellForImage(phImage, coreDataStack:self.coreDataStack)
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                self.coreDataImageManger.deleteObjectAtIndexPath(indexPath) {_ in }
            }
    }
    
    @objc func refreshTableViewData(_ sender: Any) {
        coreDataImageManger.deleteAllImages {
            DispatchQueue.main.async {
                self.refreshTableViewControl.endRefreshing()
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
        self.coreDataImageManger.addImage(image: image)
      }
    })
  }
}

// MARK: - CoreData
extension ImageListViewController {
    func coredDataSetup() {
        coreDataImageManger =
            PImageFetchController(managedObjectContext:self.coreDataStack.managedContext,delegate:self)
        coreDataImageManger.preformFetch { (result) in
            if result {
                DispatchQueue.main.async {[unowned self] in
                    self.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ImageListViewController : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                       didChange anObject: Any,at indexPath: IndexPath?,
                       for type: NSFetchedResultsChangeType,
                       newIndexPath: IndexPath?) {
       switch type {
           case .insert:
             tableView.insertRows(at: [newIndexPath!], with:.automatic)
           case .delete:
            if let deleteIndexPath = indexPath {
                tableView.deleteRows(at: [deleteIndexPath], with: .automatic)
            }
           case .update:
               let cell = tableView.cellForRow(at: indexPath!) as! ImageListCell
               let pImage = self.coreDataImageManger.objectAtIndexPath(indexPath!)
               cell.updateCellForImage(pImage)
           case .move:
                 tableView.deleteRows(at: [indexPath!], with: .fade)
                 tableView.insertRows(at: [newIndexPath!], with: .top)
         
            @unknown default: break
        }
     }

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.endUpdates()
    }

}
