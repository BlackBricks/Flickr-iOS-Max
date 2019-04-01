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
    func imageDetailViewCelldidTapScrollView(_ sender: ImageDetailViewCell)
}

class ImageDetailViewCell: UICollectionViewCell {
    
    weak var delegate: imageDetailViewCellDelegate?
    var isHided = false
    @IBOutlet weak var bottomSubview: UIView!
    @IBOutlet weak var topSubview: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var nickLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var viewText: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var justSpinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        bottomSubview.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        topSubview.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func fetchImage(url: String?, icon: String?) {
        justSpinner.startAnimating()
        guard let url = url else {
            return
        }
        guard let icon = icon else {
            return
        }
        iconView.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "placeholder.png"))
        imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeholder.png"))
    }
    
    func setScrollViewBehavior(for imageSize: CGSize) {
        scrollView.delegate = self
        addTapsGestures()
        resizeImageFrame(imageSize: imageSize)
        centerImage()
        configureFor(imageSize)
    }
    
    func configureFor(_ imageSize: CGSize) {
        self.setMinMaxZoomScaleForCurrentBounds()
        scrollView.zoomScale = scrollView.minimumZoomScale
    }
    
    func resizeImageFrame(imageSize: CGSize) {
        let actualHeight = calcScaledHeight(for: imageSize)
        imageView.frame.size = CGSize(width: scrollView.frame.size.width, height: actualHeight)
    }
    
    func centerImage() {

        let boundsSize = self.bounds.size
        var frameToCenter = imageView?.frame ?? CGRect.zero
        
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width)/2
        } else {
            frameToCenter.origin.x = 0
        }
        
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height)/2
        } else {
            frameToCenter.origin.y = 0
        }
        imageView?.frame = frameToCenter
    }

    /// MARK : - Gestures and Zoom options
    func addTapsGestures() {
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapCellAction))
        singleTap.numberOfTapsRequired = 1
        self.scrollView.addGestureRecognizer(singleTap)
        singleTap.require(toFail: doubleTap)
    }
    
    @objc func tapCellAction() {
        delegate?.imageDetailViewCelldidTapScrollView(self)
    }
    
    @objc func doubleTapped(touch: UITapGestureRecognizer) {
    let touchPoint = touch.location(in: self.scrollView)
        guard let image = imageView.image else {
            return
        }
        let zoomForDoubleTap = calcZoomForDoubleTap(realImageSize: image.size)
        
        if self.scrollView.zoomScale == self.scrollView.minimumZoomScale {
            scrollView.zoomToPoint(zoomPoint: touchPoint, withScale: zoomForDoubleTap, animated: true)
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                    self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            })
        }
    }
    
    func calcZoomForDoubleTap(realImageSize: CGSize) -> CGFloat {
        let scaledHeight = calcScaledHeight(for: realImageSize)
        let zoom = scrollView.frame.size.height/scaledHeight
        let zoomRelatively = zoom*scrollView.minimumZoomScale
        return zoomRelatively
    }
    
    func calcScaledHeight(for realImageSize: CGSize) -> CGFloat {
        let widthCoefficient = realImageSize.width/scrollView.frame.size.width
        let scaledHeight = realImageSize.height/widthCoefficient
        return scaledHeight
    }

    func setMinMaxZoomScaleForCurrentBounds() {
        let boundsSize = self.bounds.size
        let imageSize = imageView.bounds.size
        var maxScale = CGFloat()
        guard let image = imageView.image else {
            return
        }
        
        let xScale =  boundsSize.width  / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        
        if !(image.size.width < scrollView.frame.size.width) {
            let maxScaleX = image.size.width/scrollView.frame.size.width
            let maxScaleY = image.size.height/scrollView.frame.size.height
            maxScale = max(maxScaleX, maxScaleY)
        } else {
            maxScale = minScale + Constants.ForDetailView.magicZoomValue
        }
        scrollView.maximumZoomScale = maxScale
        scrollView.minimumZoomScale = minScale
        print("\(image.size.width)")

    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
   func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerImage()
    }
}


extension ImageDetailViewCell: UIScrollViewDelegate {
    
}

extension ImageDetailViewCell: UIGestureRecognizerDelegate {
    
}
