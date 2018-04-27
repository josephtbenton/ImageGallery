//
//  ImageCollectionViewCell.swift
//  ImageGallery
//
//  Created by Joseph Benton on 4/10/18.
//  Copyright © 2018 josephtbenton. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
