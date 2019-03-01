//
//  PopularCollectionViewCell.swift
//  Flickr
//
//  Created by metoSimka on 01/03/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit
import SDWebImage

class PopularCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet weak var popularImageView: UIImageView!
    var imageArray: [[String: AnyObject]]?
    
    func fetchImage(url: String?) {
        
        guard let url = url else { return }
        popularImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeholder.png"))
        
    }
}
