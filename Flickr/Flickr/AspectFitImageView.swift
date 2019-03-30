////
////  AspectFitImageView.swift
////  Flickr
////
////  Created by metoSimka on 27/03/2019.
////  Copyright © 2019 metoSimka. All rights reserved.
////
//
//import UIKit
//
//class AspectFitImageView: UIImageView {
//
//    var aspectRatio: NSLayoutConstraint?
//
//    override var image: UIImage? {
//        didSet {
//            self.updateAspectRatioWithImage(image: image)
//        }
//    }
//
//    override func awakeFromNib() {
//    super.awakeFromNib()
//        self.updateAspectRatioWithImage(image: self.image)
//    }
//
//    func updateAspectRatioWithImage(image: UIImage?) {
//    if self.aspectRatio != nil {
//        guard let aspectRatio = self.aspectRatio else {
//            return
//        }
//    self.removeConstraint(aspectRatio)
//    }
//        guard let image = image else {
//            return
//        }
//    if (image.size.width == 0) {
//    return
//    }
//        let aspectRatioValue: CGFloat = image.size.height / image.size.width
//        self.aspectRatio = NSLayoutConstraint(item: self,
//                                              attribute: .height,
//                                              relatedBy: .equal,
//                                              toItem: self,
//                                              attribute: .width,
//                                              multiplier: aspectRatioValue,
//                                              constant: 0)
//        guard let aspectRatio = self.aspectRatio else {
//            return
//        }
//     self.addConstraint(aspectRatio)
//    }
//}
