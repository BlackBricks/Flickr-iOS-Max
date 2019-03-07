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
    var nameOwner: String?
    var icon: String?
    
    class func getUrlFromArray(photosArray: [Photo], index: Int) -> String? {
        let photoItem = photosArray[index]
        guard let urlImage = photoItem.url else {
            return nil
        }
        return urlImage
    }
    
    class func getTitleFromArray(photosArray: [Photo], index: Int) -> String? {
        let photoItem = photosArray[index]
        guard let titleImage = photoItem.title else {
            return nil
        }
        return titleImage
    }
    
    class func getViewsFromArray(photosArray: [Photo], index: Int) -> String? {
        let photoItem = photosArray[index]
        guard let viewsImage = photoItem.views else {
            return nil
        }
        return viewsImage
    }
    
    class func getNameFromArray(photosArray: [Photo], index: Int) -> String? {
        let photoItem = photosArray[index]
        guard let nameOwnerImage = photoItem.nameOwner else {
            return nil
        }
        return nameOwnerImage
    }
    
    class func getPhotos (from photoArray: [[String: AnyObject]]) -> [Photo] {
        let photo = photoArray.map({ (itemArray) -> Photo in
            let interestInfo = Photo()
            interestInfo.url = itemArray["url_m"] as? String
            interestInfo.title = itemArray["title"] as? String
            interestInfo.views = itemArray["views"] as? String
            interestInfo.heightImage = itemArray["height_m"] as? String
            interestInfo.widthImage = itemArray["width_m"] as? String
            interestInfo.nameOwner = itemArray["owner_name"] as? String
            interestInfo.icon = itemArray["icon_server"] as? String
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
}
