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
    
    
    
    func pointToCenterAfterRotation() -> CGPoint {
        let boundsCenter = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        return self.convert(boundsCenter, to: imageView)
    }
    
    // returns the zoom scale to attempt to restore after rotation.
    func scaleToRestoreAfterRotation() -> CGFloat {
        var contentScale = scrollView.zoomScale
        // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
        // allowable scale when the scale is restored.
        if contentScale <= scrollView.minimumZoomScale + CGFloat.ulpOfOne {
            contentScale = 0
        }
        return contentScale
    }
    
    func maximumContentOffset() -> CGPoint {
        let contentSize = scrollView.contentSize
        let boundSize = scrollView.bounds.size
        return CGPoint(x: contentSize.width - boundSize.width, y: contentSize.height - boundSize.height)
    }
    
    func minimumContentOffset() -> CGPoint {
        return CGPoint.zero
    }
    
    func restoreCenterPoint(to oldCenter: CGPoint, oldScale: CGFloat) {
        // Step 1: restore zoom scale, first making sure it is within the allowable range.
        scrollView.zoomScale = min(scrollView.maximumZoomScale, max(scrollView.minimumZoomScale, oldScale))
        
        // Step 2: restore center point, first making sure it is within the allowable range.
        // 2a: convert our desired center point back to our own coordinate space
        let boundsCenter = scrollView.convert(oldCenter, from: imageView)
        // 2b: calculate the content offset that would yield that center point
        var offset = CGPoint(x: boundsCenter.x - self.bounds.size.width/2.0, y: boundsCenter.y - self.bounds.size.height/2.0)
        // 2c: restore offset, adjusted to be within the allowable range
        let maxOffset = self.maximumContentOffset()
        let minOffset = self.minimumContentOffset()
        offset.x = max(minOffset.x, min(maxOffset.x, offset.x))
        offset.y = max(minOffset.y, min(maxOffset.y, offset.y))
        
        scrollView.contentOffset = offset
    }

    func restoreStatesForRotation(in bounds: CGRect) {
        
        // recalculate contentSize based on current orientation
        let restorePoint = self.pointToCenterAfterRotation()
        let restoreScale = self.scaleToRestoreAfterRotation()
        scrollView.frame = bounds
        self.setMinMaxZoomScaleForCurrentBounds()
        self.restoreCenterPoint(to: restorePoint, oldScale: restoreScale)
    }
    
    func restoreStatesForRotation(in size: CGSize) {
        var bounds = self.bounds
        if bounds.size != size {
            bounds.size = size
            self.restoreStatesForRotation(in: bounds)
        }
    }
    
    var isHided = false

    weak var delegate: imageDetailViewCellDelegate?
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var nickLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var viewText: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var justSpinner: UIActivityIndicatorView!
    
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
    
    func setScrollViewBehavior(for imageSize: CGSize) {   // here lifeCycle = viewWillAppear() for cell
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

        // center the zoom view as it becomes smaller than the size of the screen
        let boundsSize = self.bounds.size
        var frameToCenter = imageView?.frame ?? CGRect.zero
        
        // center horizontally
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width)/2
        } else {
            frameToCenter.origin.x = 0
        }
        
        // center vertically
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
        delegate?.didTapScrollView(self)
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
        
        //1. calculate minimumZoomscale
        let xScale =  boundsSize.width  / imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = boundsSize.height / imageSize.height  // the scale needed to perfectly fit the image height-wise
        let minScale = min(xScale, yScale)                 // use minimum of these to allow the image to become fully visible
        
        //2. calculate maximumZoomscale
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
