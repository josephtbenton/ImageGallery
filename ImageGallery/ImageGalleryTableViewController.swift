//
//  ImageGalleryTableViewController.swift
//  ImageGallery
//
//  Created by Joseph Benton on 4/23/18.
//  Copyright © 2018 josephtbenton. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController, UITextFieldDelegate {
    
    var galleries: [ImageGallery] = []
    
    var deletedGalleries: [ImageGallery] = []

    @IBAction func newGallery(_ sender: Any) {
        let gallery = ImageGallery()
        let titles: [String] = galleries.map({return $0.title})
        gallery.title = "New Gallery".madeUnique(withRespectTo: titles)
        galleries.append(gallery)
        tableView.insertRows(at: [IndexPath(row: galleries.count-1, section: 0)], with: .fade)
    }
    
    struct Constants {
        static let gallerySection = 0
        static let galleryTitle = "Galleries"
        
        static let deletedSection = 1
        static let deletedTitle = "Deleted Galleries"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    @objc func doubleTapped() {
        if let selectedIndex = tableView.indexPathForSelectedRow, let selectedRow = tableView.cellForRow(at: selectedIndex) as? ImageGalleryTableViewCell {
            selectedRow.textField.isEnabled = true
            selectedRow.textField.becomeFirstResponder()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Constants.gallerySection {
            return galleries.count
        } else if section == Constants.deletedSection {
            return deletedGalleries.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == Constants.gallerySection && !galleries.isEmpty {
            return Constants.galleryTitle
        } else if section == Constants.deletedSection && !deletedGalleries.isEmpty {
            return Constants.deletedTitle
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageGalleryCell", for: indexPath)
        if let imgViewCell = cell as? ImageGalleryTableViewCell {
            let section = indexPath.section
            let row = indexPath.row
            if section == Constants.gallerySection {
                imgViewCell.textField.text = galleries[row].title
            } else if section == Constants.deletedSection {
                imgViewCell.textField.text = deletedGalleries[row].title
            } else {
                imgViewCell.textLabel?.text = "App is broken!"
            }
            imgViewCell.textField?.delegate = self
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        cell.addGestureRecognizer(tap)
        return cell
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let parentCell = parentCellFor(textField), let indexPath = tableView.indexPath(for: parentCell) {
            if indexPath.section == Constants.gallerySection {
                galleries[indexPath.row].title = textField.text ?? ""
            } else if indexPath.section == Constants.deletedSection {
                deletedGalleries[indexPath.row].title = textField.text ?? ""
            }
        }
        textField.isEnabled = false
    }
    
    func parentCellFor(_ view: UIView?) -> UITableViewCell? {
        if let unwrappedView = view {
            if let tableViewCell = unwrappedView as? UITableViewCell {
                return tableViewCell
            } else {
                return parentCellFor(unwrappedView.superview)
            }
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == Constants.gallerySection {
                tableView.performBatchUpdates({
                    let row = galleries.remove(at: indexPath.row)
                    deletedGalleries.append(row)
                    let deletedIndexPath = IndexPath(row: deletedGalleries.count-1, section: Constants.deletedSection)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.insertRows(at: [deletedIndexPath], with: .fade)
                })
            } else if indexPath.section == Constants.deletedSection {
                deletedGalleries.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
            }
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == Constants.deletedSection {
            let undelete = UIContextualAction(style: .normal, title: "Restore", handler: { [weak self] (action, view, handler) in
                tableView.performBatchUpdates({
                    if let row = self?.deletedGalleries.remove(at: indexPath.row) {
                        self?.galleries.append(row)
                        let galleryIndexPath = IndexPath(row: self!.galleries.count-1, section: Constants.gallerySection)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        tableView.insertRows(at: [galleryIndexPath], with: .fade)
                        handler(true)
                    } else {
                        handler(false)
                    }
                })
                tableView.reloadData()
            })
            undelete.backgroundColor = .blue
            return UISwipeActionsConfiguration(actions: [undelete])
        } else {
            return nil
        }
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectImageGallerySegue" {
            if let cell = sender as? UITableViewCell {
                let indexPath = tableView.indexPath(for: cell)!
                if indexPath.section == Constants.gallerySection {
                    let nc = segue.destination as! UINavigationController
                    let vc = nc.topViewController as! ImageGalleryCollectionViewController
                    vc.imageGallery = self.galleries[indexPath.row]
                }
            }
        }
    }
    

}
