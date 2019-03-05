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
    
    func fetchImage(url: String?) {
        guard let url = url else { return }
        imagesView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeholder.png"))       
    }
}
