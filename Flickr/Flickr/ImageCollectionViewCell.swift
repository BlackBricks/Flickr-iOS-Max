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
        imageView.sd_setImage(with: URL(string: urlLowQuality), placeholderImage: UIImage(named: "placeholder.png")) //{ (image, error, cacheType, url) -> Void in
//            self.imageView.sd_setImage(with: URL(string: urlHightQuality), placeholderImage: UIImage(named: "placeholder.png"))
//
//            SDWebImageManager.shared().loadImage(with: URL(string: urlLowQuality), options: .lowPriority , progress: { (<#Int#>, <#Int#>, <#URL?#>) in
//
//            }, completed: { (imageView, NSData, NSError, SDImageCacheType, Bool, URL?) in
//
//            })
        }
    }

extension UIImageView {
    public func sd_setImageWithURLWithFade(url: URL!, placeholderImage placeholder: UIImage!) {
        self.sd_setImage(with: url, placeholderImage: placeholder) { (image, error, cacheType, url) -> Void in
            if let downLoadedImage = image {
                if cacheType == .none {
                    self.alpha = 0
                    UIView.transition(with: self, duration: 0.3, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        self.image = downLoadedImage
                        self.alpha = 1
                    }, completion: nil)
                }
            } else {
                self.image = placeholder
            }
        }
    }
}
