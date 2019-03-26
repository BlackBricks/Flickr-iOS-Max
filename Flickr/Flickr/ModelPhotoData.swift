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
    var url_h: String?
    var url_o: String?
    var url_m: String?
    var url_c: String?
    var url_z: String?
    var url_n: String?
    var heightImage: String?
    var widthImage: String?
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
            interestInfo.heightImage = itemArray["height_t"] as? String
            interestInfo.widthImage = itemArray["width_t"] as? String
            interestInfo.idPhoto = itemArray["id"] as? String
            interestInfo.url_o = itemArray["url_o"] as? String
            interestInfo.url_h = itemArray["url_h"] as? String
            interestInfo.url_c = itemArray["url_c"] as? String
            interestInfo.url_z = itemArray["url_z"] as? String
            interestInfo.url_n = itemArray["url_n"] as? String
            interestInfo.url_m = itemArray["url_m"] as? String
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
    
    class func searchBestQualityInFuckingFlickr(from imageData: [Photo], indexPath: IndexPath ) -> (url :String? ,scaleFactor: CGFloat)  {
        var scaleFactor: CGFloat = 7
        var url: String?

        if imageData[indexPath.row].url_o != nil {
            if let url_o = imageData[indexPath.row].url_o {
                url = url_o
                return (url, scaleFactor)
            }
        }
        scaleFactor -= 1
        if imageData[indexPath.row].url_h != nil {
            if let url_h = imageData[indexPath.row].url_h {
                url = url_h
                return (url, scaleFactor)
            }
        }
        scaleFactor -= 1
        if imageData[indexPath.row].url_c != nil {
            if let url_c = imageData[indexPath.row].url_c {
                url = url_c
                return (url, scaleFactor)
            }
        }
        scaleFactor -= 1
        if imageData[indexPath.row].url_z != nil {
            if let url_z = imageData[indexPath.row].url_z {
                url = url_z
                return (url, scaleFactor)
            }
        }
        scaleFactor -= 1
        if imageData[indexPath.row].url_n != nil {
            if let url_n = imageData[indexPath.row].url_n {
                url = url_n
                return (url, scaleFactor)
            }
        }
        scaleFactor -= 1
        if imageData[indexPath.row].url_m != nil {
            if let url_m = imageData[indexPath.row].url_m {
                url = url_m
                return (url, scaleFactor)
            }
        }
        scaleFactor -= 1
        if imageData[indexPath.row].url_t != nil {
            if let url_t = imageData[indexPath.row].url_t {
                url = url_t
                return (url, scaleFactor)
            }
        }
        return (nil, 0)
    }
}
