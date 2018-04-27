//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by Joseph Benton on 4/13/18.
//  Copyright © 2018 josephtbenton. All rights reserved.
//

import Foundation

class ImageGallery {
    var title = ""
    var urls: [URL] = []
    var aspectRatios: [Double] = []
    var count: Int {
        return urls.count
    }
    
    func url(for indexPath: IndexPath) -> URL {
        return urls[indexPath.item]
    }
    
    func aspectRatio(for indexPath: IndexPath) -> Double {
        return aspectRatios[indexPath.item]
    }
    
    func addImageURL(_ url: URL, with aspectRatio: Double) {
        urls.append(url)
        aspectRatios.append(aspectRatio)
    }
    
    func addImageURL(_ url: URL, with aspectRatio: Double, at indexPath: IndexPath) {
        urls.insert(url, at: indexPath.item)
        aspectRatios.insert(aspectRatio, at: indexPath.item)
    }
    
    func  removeImageURL(at indexPath: IndexPath) {
        urls.remove(at: indexPath.item)
        aspectRatios.remove(at: indexPath.item)
    }
    
    func moveImageURL(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let url = urls[sourceIndexPath.item]
        let aspectRatio = aspectRatios[sourceIndexPath.item]
        removeImageURL(at: sourceIndexPath)
        addImageURL(url, with: aspectRatio, at: destinationIndexPath)
    }
    func swapImageURLs(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        urls.swapAt(sourceIndexPath.item, destinationIndexPath.item)
        aspectRatios.swapAt(sourceIndexPath.item, destinationIndexPath.item)
    }
}
