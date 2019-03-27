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
    var url_t: String?
    var url_best: String?
    var size_best: CGSize?
    var height_t: String?
    var width_t: String?
    var title: String?
    var views: String?
    var icon_server: String?
    var icon_farm : String?
    var nsid: String?
    var ownerName: String?
    
    class func getPhotos (from photoArray: [[String: AnyObject]]) -> [Photo] {
        let photo = photoArray.map({ (itemArray) -> Photo in
            let interestInfo = Photo()
            interestInfo.title = itemArray["title"] as? String
            interestInfo.views = itemArray["views"] as? String
            interestInfo.height_t = itemArray["height_t"] as? String
            interestInfo.width_t = itemArray["width_t"] as? String
            interestInfo.idPhoto = itemArray["id"] as? String
            interestInfo.url_best = getBestImageModel(data: itemArray).url
            interestInfo.size_best = getBestImageModel(data: itemArray).size
            interestInfo.url_t = itemArray["url_t"] as? String
            interestInfo.icon_server = itemArray["iconserver"] as? String
            interestInfo.nsid = itemArray["owner"] as? String
            interestInfo.ownerName = itemArray["ownername"] as? String
            let icon_farm_Int = itemArray["iconfarm"] as? Int
            guard let iconFarm = icon_farm_Int else {
                return Photo()
            }
            interestInfo.icon_farm = String(iconFarm)
            return interestInfo
        })
        return photo
    }
    
    class func fromStringToCGFloat(word: String?) -> CGFloat {
        guard let item = word else {
            return CGFloat()
        }
        guard let item_int = Int(item) else {
            return CGFloat()
        }
        let item_float = CGFloat(item_int)
        return item_float
    }
    
    class func getBestImageModel(data: [String : AnyObject]) -> (url: String?,size: CGSize?) {
        for urlSuffix in Constants.listQualitySuffix {
            let url_best: String?
            let width: String?
            var height : Int?
            url_best = data["url" + urlSuffix] as? String
            guard let url = url_best else {
                continue
            }
            width = data["width" + urlSuffix] as? String
            height = data["height" + urlSuffix] as? Int
            if height == nil {
                if let lol_its_not_Int = data["height" + urlSuffix] as? String {
                height = Int(lol_its_not_Int)
                }
            }
            guard let height_forFloat = height else {
                return (nil, nil)
            }
            let height_int = Int(height_forFloat)
            let image_width =  fromStringToCGFloat(word: width)
            let image_height = CGFloat(height_int)
            let size = CGSize(width: image_width, height: image_height)
            return (url, size)
        }
        return (nil, nil)
    }
    
    class func getSizes(from photoArray: [Photo]) -> [CGSize] {
        let photo = photoArray.map({ (itemArray) -> CGSize in
            let itemSize: CGSize?
            guard let height = itemArray.height_t else { return CGSize() }
            guard let width = itemArray.width_t else { return CGSize() }
            guard let intHeight = Double(height) else { return CGSize() }
            guard let intWidth = Double(width) else { return CGSize() }
            itemSize = CGSize(width: CGFloat(intWidth), height: CGFloat(intHeight))
            guard let sizeItem = itemSize else { return CGSize() }
            return sizeItem
        })
        return photo
    }
}
