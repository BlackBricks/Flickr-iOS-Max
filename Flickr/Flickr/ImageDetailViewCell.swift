//
//  GalleryCollectionViewCell.swift
//  Flickr
//
//  Created by metoSimka on 28/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit
import SDWebImage

protocol ImageDetailViewCellDelegate : class {
    func didTapBackButton(_ sender: ImageDetailViewCell)
}

class ImageDetailViewCell: UICollectionViewCell {
    
    weak var delegate: ImageDetailViewCellDelegate?
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var viewText: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func backButton(_ sender: UIButton) {
        delegate?.didTapBackButton(self)
    }
    
    func fetchImage(url: String?) {
        guard let url = url else { return }
        imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeholder.png"))
    }
    
}
