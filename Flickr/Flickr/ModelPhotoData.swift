//
//  ModelPhotoData.swift
//  Flickr
//
//  Created by metoSimka on 28/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit

class Photo {
    var idPhoto: String?
    var url: String?
    var heightImage: String?
    var widthImage: String?
    var title: String?
    var views: String?
    var nameOwner: String?
    var icon: String?
    
    class func getPhotos (from photoArray: [[String: AnyObject]]) -> [Photo] {
        let photo = photoArray.map({ (itemArray) -> Photo in
            let interestInfo = Photo()
            interestInfo.url = itemArray["url_t"] as? String
            interestInfo.title = itemArray["title"] as? String
            interestInfo.views = itemArray["views"] as? String
            interestInfo.heightImage = itemArray["height_t"] as? String
            interestInfo.widthImage = itemArray["width_t"] as? String
            interestInfo.nameOwner = itemArray["owner_name"] as? String
            interestInfo.icon = itemArray["icon_server"] as? String
            interestInfo.idPhoto = itemArray["id"] as? String
            return interestInfo
        })
        return photo
    }
    
    class func getSizes(from photoArray: [Photo]) -> [CGSize] {
        let photo = photoArray.map({ (itemArray) -> CGSize in
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
    
    class func getID(from photoArray: [Photo]) -> [String] {
        let photoID = photoArray.map({ (itemArray) -> String in
            guard let id = itemArray.idPhoto else { return String() }
            return id
        })
        return photoID
    }
    
}
