//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Joseph Benton on 4/18/18.
//  Copyright © 2018 josephtbenton. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ImageCell"

class ImageGalleryCollectionViewController: UICollectionViewController {
    
    var flowLayout: UICollectionViewFlowLayout? {
        return imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    var imageGallery = ImageGallery() {
        didSet {
            self.title = imageGallery.title
            print("setting imageGallery for \(imageGallery.title)")
        }
    }
    
    
    var cellWidth = 200.0
    
    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet {
            imageCollectionView.dataSource = self
            imageCollectionView.delegate = self
            imageCollectionView.dropDelegate = self
            imageCollectionView.dragDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(ImageGalleryCollectionViewController.handlePinch))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(pinchGesture)
    }
    
    @objc func handlePinch(sender: UIPinchGestureRecognizer) {
        self.cellWidth *= Double(sender.scale)
        sender.scale = 1.0
        print(self.cellWidth)
        flowLayout?.invalidateLayout()
        
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "ImageDetailSegue", sender: sender)
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageGallery.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if let imageCell = cell as? ImageCollectionViewCell {
            if let imageView = imageCell.imageView, let spinner = imageCell.spinner {
                spinner.startAnimating()
                imageView.image = nil
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    if let url = self?.imageGallery.url(for: indexPath) {
                        if let urlContents = try? Data(contentsOf: url.imageURL) {
                            DispatchQueue.main.async {
//                                if let cellIndexPath = self?.imageCollectionView.indexPath(for: imageCell) {
//                                    if url == self?.imageGallery.url(for: cellIndexPath) {
                                
                                        if let image = UIImage(data: urlContents) {
                                            imageView.image = image
                                            spinner.stopAnimating()
                                        }
//                                    }
//                                }
                            }
                        }
                    }
                }
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ImageGalleryCollectionViewController.handleTap))
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(tapGesture)
            }
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageDetailSegue" {
            let vc = segue.destination as! ImageDetailViewController
            let gesture = sender as! UITapGestureRecognizer
            let imageView = gesture.view as! UIImageView
            vc.image = imageView.image
        }
    }
}

extension ImageGalleryCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let aspectRatio = imageGallery.aspectRatio(for: indexPath)
        return CGSize(width: cellWidth, height: aspectRatio * cellWidth)
    }
}

extension ImageGalleryCollectionViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate{
    // DROP
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                collectionView.performBatchUpdates({
                    imageGallery.moveImageURL(from: sourceIndexPath, to: destinationIndexPath)
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            } else {
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "ImageCell"))
                var aspectRatio: Double?
                var url: URL?
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (provider, error) in
                    if let image = provider as? UIImage {
                        aspectRatio = Double(image.size.height / image.size.width)
                        DispatchQueue.main.async { [weak self] in
                            if let u = url, let ar = aspectRatio {
                                placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                    self?.imageGallery.addImageURL(u, with: ar, at: destinationIndexPath)
                                })
                            }
                        }
                    } else {
                        placeholderContext.deletePlaceholder()
                    }
                }
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { [weak self] (provider, error) in
                    if let urlFromProvider = provider as? URL {
                        url = urlFromProvider
                        DispatchQueue.main.async { [weak self] in
                            if let u = url, let ar = aspectRatio {
                                placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                    self?.imageGallery.addImageURL(u, with: ar, at: destinationIndexPath)
                                })
                            }
                        }
                    } else {
                        placeholderContext.deletePlaceholder()
                    }
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self) && session.canLoadObjects(ofClass: NSURL.self) || session.localDragSession != nil
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    // DRAG
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let image = (imageCollectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell)?.imageView.image {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
            dragItem.localObject = image
            return [dragItem]
        } else {
            return []
        }
    }
    
    
}
