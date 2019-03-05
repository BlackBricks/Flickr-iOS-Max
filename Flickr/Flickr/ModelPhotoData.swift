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
    var hieghtImage: String?
    var widthImage: String?
    var title: String?
    var views: String?
    
    class func getPhotos (data: [[String: AnyObject]]) -> [Photo] {
        let photo = data.map({ (itemArray) -> Photo in
            let interestInfo = Photo()
            interestInfo.url = itemArray["url_m"] as? String
            interestInfo.title = itemArray["title"] as? String
            interestInfo.views = itemArray["views"] as? String
            interestInfo.hieghtImage = itemArray["height_m"] as? String
            interestInfo.widthImage = itemArray["width_m"] as? String
            return interestInfo
        })
        return photo
    }
    
    class func getSizes(data: [Photo]) -> [CGSize] {
        let photo = data.map({ (itemArray) -> CGSize in
            let itemSize: CGSize?
            guard let hieght = itemArray.hieghtImage else { return CGSize(width: 25, height: 25) }
            guard let width = itemArray.widthImage else { return CGSize(width: 25, height: 25) }
            guard let intHieght = Int(hieght) else { return CGSize(width: 25, height: 25) }
            guard let intWidth = Int(width) else { return CGSize(width: 25, height: 25) }
            
            let h = CGFloat(intHieght)
            let w = CGFloat(intWidth)
            itemSize = CGSize(width: w, height: h)
            guard let sizeItem = itemSize else { return CGSize(width: 25, height: 25) }
            return sizeItem
        })
        return photo
    }
}
