//
//  ModelPhotoData.swift
//  Flickr
//
//  Created by metoSimka on 28/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit

class Photo {
    var url: String?               
    var heightImage: String?
    var widthImage: String?
    var title: String?
    var views: String?
    
    class func getPhotos (data: [[String: AnyObject]]) -> [Photo] {
        let photo = data.map({ (itemArray) -> Photo in
            let interestInfo = Photo()
            interestInfo.url = itemArray["url_m"] as? String
            interestInfo.title = itemArray["title"] as? String
            interestInfo.views = itemArray["views"] as? String
            interestInfo.heightImage = itemArray["height_m"] as? String
            interestInfo.widthImage = itemArray["width_m"] as? String
            return interestInfo
        })
        return photo
    }
    
    class func getSizes(data: [Photo]) -> [CGSize] {
        let photo = data.map({ (itemArray) -> CGSize in
            let itemSize: CGSize?
            guard let height = itemArray.heightImage else { return CGSize() }
            guard let width = itemArray.widthImage else { return CGSize() }
            guard let intHeight = Double(height) else { return CGSize() }
            guard let intWidth = Double(width) else { return CGSize() }
            itemSize = CGSize(width: CGFloat(intWidth), height: CGFloat(intHeight))
            guard let sizeItem = itemSize else { return CGSize() }
            return sizeItem
        })
        return photo
    }
}
