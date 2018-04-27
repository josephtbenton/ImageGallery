//
//  ImageGalleryTableViewCell.swift
//  ImageGallery
//
//  Created by Joseph Benton on 4/24/18.
//  Copyright © 2018 josephtbenton. All rights reserved.
//

import UIKit

class ImageGalleryTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var textField: UITextField!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
