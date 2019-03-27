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
    
    var heigthImage: CGFloat?
    var isHided = false
    var zoomFactor: CGFloat?
    var zoomForDoubleTap: CGFloat?
    enum DetailConstants {
        static let magicZoomValue: CGFloat = 1.0001
        static let minZoom: CGFloat = 1.0
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
        
        imageView.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "placeholder.png"))
        
//        iconView.sd_setImage(with: URL(string: DetailConstants.placeholder)) { (image, error, cache, url) in
//            self.iconView.sd_setImage(with: URL(string: icon), placeholderImage: self.iconView.image)
//        }
        print("\(icon)")
        imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeholder.png"))
    }

    func defineMaxZoom(calculatedZoom: CGFloat?) -> CGFloat {
        guard let maxZoom = zoomFactor else {
            return 1
        }
        if maxZoom < 1 {
            return DetailConstants.magicZoomValue
        } else {
            return maxZoom
        }
    }
    
        func addZoom() {
            scrollView.clipsToBounds = true
            scrollView.bouncesZoom = true
            scrollView.minimumZoomScale = DetailConstants.minZoom
            scrollView.maximumZoomScale = defineMaxZoom(calculatedZoom: zoomFactor)
//            print("\(self.contentView.bounds.size)")
//            print("\(imageView.frame.size)")
//            print("\(scrollView.frame.height)")
//            print("\(heigthImage)")
        }
    
    func setScrollView() {
        scrollView.isPagingEnabled = false
        scrollView.delegate = self
        imageView.contentMode = .scaleAspectFit
        addTap()
        addZoom()
    }
    
    func addTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapCellAction))
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
        guard let doubleTapZoom = zoomForDoubleTap else {
            return
        }
        if self.scrollView.zoomScale == 1 {
            scrollView.zoomToPoint(zoomPoint: touchPoint, withScale: doubleTapZoom, animated: true)
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

