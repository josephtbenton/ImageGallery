//
//  ImageDetailViewController.swift
//  ImageGallery
//
//  Created by Joseph Benton on 4/25/18.
//  Copyright © 2018 josephtbenton. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UIScrollViewDelegate{
    var image: UIImage?
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let unwrappedImage = image {
            imageView.image = unwrappedImage
        }
        // Do any additional setup after loading the view.
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
