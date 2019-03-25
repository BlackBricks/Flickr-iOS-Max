//
//  GalleryCollectionViewCell.swift
//  Flickr
//
//  Created by metoSimka on 28/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit
import SDWebImage

class ImageDetailViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    enum DetailConstants {
        static let minZoom: CGFloat = 1.0
        static let maxZoom: CGFloat = 6.0
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var viewText: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    func fetchImage(url: String?) {
        guard let url = url else { return }
        imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeholder.png"))
    }
    func setScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = DetailConstants.minZoom
        scrollView.maximumZoomScale = DetailConstants.maxZoom
        scrollView.frame = self.contentView.bounds
        scrollView.contentSize = self.contentView.bounds.size
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
}
