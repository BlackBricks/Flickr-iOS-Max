//
//  GalleryCollectionViewCell.swift
//  Flickr
//
//  Created by metoSimka on 28/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit
import SDWebImage

protocol imageDetailViewCellDelegate : class {
    func didTapScrollView(_ sender: ImageDetailViewCell)
}

class ImageDetailViewCell: UICollectionViewCell, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    var isHided = false
    enum DetailConstants {
        static let minZoom: CGFloat = 1.0
        static let maxZoom: CGFloat = 6.0
        static let placeholder = "https://www.flickr.com/images/buddyicon.gif"
    }
    weak var delegate: imageDetailViewCellDelegate?
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var nickLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var viewText: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    func fetchImage(url: String?, icon: String?) {
        guard let url = url else {
            return
        }
        guard let icon = icon else {
            return
        }
        iconView.sd_setImage(with: URL(string: DetailConstants.placeholder)) { (image, error, cache, url) in
            self.iconView.sd_setImage(with: URL(string: icon), placeholderImage: self.iconView.image)
        }
        imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeholder.png"))
    }
    
    func setHeight(height: CGFloat) {
        scrollView.bounds.size.height = height
    }
    
    func setConstraints(heigthImage: CGFloat) {
        print("\(imageView.frame.size.height)")
        print("\(self.contentView.frame.height)")
        print("\(heigthImage)")

    }
        func addZoom() {
            scrollView.clipsToBounds = true
            scrollView.minimumZoomScale = DetailConstants.minZoom
            scrollView.maximumZoomScale = DetailConstants.maxZoom
            scrollView.frame = self.contentView.bounds
//            print("\(self.contentView.bounds.size)")
//            print("\(imageView.frame.size)")
//            print("\(scrollView.frame.height)")
//            print("\(heigthImage)")
//            scrollView.contentSize = self.contentView.bounds.size
        }
    
    func setScrollView() {
        addZoom()
        scrollView.delegate = self
        imageView.contentMode = .scaleAspectFit
        addTap()
    }
    
    func addTap() {
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        singleTap.numberOfTapsRequired = 1
        self.scrollView.addGestureRecognizer(singleTap)
        
        singleTap.require(toFail: doubleTap)
    }
    
    @objc func tapCellAction() {
        delegate?.didTapScrollView(self)
    }
    
    @objc func doubleTapped(touch: UITapGestureRecognizer) {
    let touchPoint = touch.location(in: self.scrollView)
    print("\(touchPoint.x, touchPoint.y)")
        if scrollView.zoomScale == 1 {
            scrollView.zoomToPoint(zoomPoint: touchPoint, withScale: 2, animated: true)
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                    self.scrollView.zoomScale = 1
            })
        }
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension UIScrollView {
    
    func zoomToPoint(zoomPoint: CGPoint, withScale scale: CGFloat, animated: Bool) {
        //Normalize current content size back to content scale of 1.0f
        let contentSize = CGSize(width: (self.contentSize.width / self.zoomScale), height: (self.contentSize.height / self.zoomScale))
        
        //translate the zoom point to relative to the content rect
        let newZoomPoint = CGPoint(x: (zoomPoint.x / self.bounds.size.width) * contentSize.width, y: (zoomPoint.y / self.bounds.size.height) * contentSize.height)
        
        //derive the size of the region to zoom to
        let zoomSize = CGSize(width: self.bounds.size.width / scale, height: self.bounds.size.height / scale)
        
        //offset the zoom rect so the actual zoom point is in the middle of the rectangle
        let zoomRect = CGRect(x: newZoomPoint.x - zoomSize.width / 2.0,
                              y: newZoomPoint.y - zoomSize.height / 2.0,
                              width: zoomSize.width,
                              height: zoomSize.height)
        
        //apply the resize
        self.zoom(to: zoomRect, animated: animated)
    }
}
