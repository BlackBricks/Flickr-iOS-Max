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
    @IBOutlet weak var imageView: UIImageView!
    
    func fetchImage(url_Low: String?, url_High: String?) {
        guard let urlLowQuality = url_Low else {
            return
        }
        guard let urlHightQuality = url_High else {
            return
        }
        let url_t = NSURL(string: urlLowQuality) as URL?
        let url_h = NSURL(string: urlHightQuality) as URL?
        imageView.sd_setImage(with: url_t) { (image, error, cache, url) in
            self.imageView.sd_setImage(with: url_h, placeholderImage: self.imageView.image)
        }
    }
}
