//
//  Superclass Extensions.swift
//  Flickr
//
//  Created by metoSimka on 01/04/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    func zoomToPoint(zoomPoint: CGPoint, withScale scale: CGFloat, animated: Bool) {
        let contentSize = CGSize(width: (self.contentSize.width / self.zoomScale), height: (self.contentSize.height / self.zoomScale))
        let newZoomPoint = CGPoint(x: (zoomPoint.x / self.bounds.size.width) * contentSize.width, y: (zoomPoint.y / self.bounds.size.height) * contentSize.height)
        let zoomSize = CGSize(width: self.bounds.size.width / scale, height: self.bounds.size.height / scale)
        let zoomRect = CGRect(x: newZoomPoint.x - zoomSize.width / 2.0,
                              y: newZoomPoint.y - zoomSize.height / 2.0,
                              width: zoomSize.width,
                              height: zoomSize.height)
        self.zoom(to: zoomRect, animated: animated)
    }
}


extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

extension UIViewController {
    func setStatusBarStyle(_ style: UIStatusBarStyle) {
        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = style == .lightContent ? UIColor.black : .white
            statusBar.setValue(style == .lightContent ? UIColor.white : .black, forKey: "foregroundColor")
        }
    }
}
