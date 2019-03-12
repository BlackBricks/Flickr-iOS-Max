//
//  CollectionViewCell.swift
//  Flickr
//
//  Created by metoSimka on 26/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit
import SDWebImage

class ImageCollectionViewCell: UICollectionViewCell {
    
    var imageArray: [[String: AnyObject]]?
    @IBOutlet weak var imagesView: UIImageView!
    @IBOutlet weak var popularImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    func fetchImageForSearch(url: String?) {
        spinner.startAnimating()
        guard let url = url else { return }
        imagesView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeholder.png"))
        DispatchQueue.main.async {
             self.spinner.stopAnimating()
        }
        
        
    }
    
    func fetchImageForPopular(url: String?) {
        guard let url = url else { return }
        popularImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeholder.png"))
    }
}
