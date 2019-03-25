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
    var nameOwner: String?
    var icon: String?
    
    class func getPhotos (from photoArray: [[String: AnyObject]]) -> [Photo] {
        let photo = photoArray.map({ (itemArray) -> Photo in
            let interestInfo = Photo()
      
            interestInfo.title = itemArray["title"] as? String
            interestInfo.views = itemArray["views"] as? String
            interestInfo.heightImage = itemArray["height_t"] as? String
            interestInfo.widthImage = itemArray["width_t"] as? String
            interestInfo.nameOwner = itemArray["owner_name"] as? String
            interestInfo.icon = itemArray["icon_server"] as? String
            interestInfo.idPhoto = itemArray["id"] as? String
            interestInfo.url_o = itemArray["url_o"] as? String
            interestInfo.url_h = itemArray["url_h"] as? String
            interestInfo.url_c = itemArray["url_c"] as? String
            interestInfo.url_z = itemArray["url_z"] as? String
            interestInfo.url_n = itemArray["url_n"] as? String
            interestInfo.url_m = itemArray["url_m"] as? String
            interestInfo.url_t = itemArray["url_t"] as? String
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
    
    class func searchBestQualityInFuckingFlickr(from imageData: [Photo], indexPath: IndexPath ) -> String? {

        if imageData[indexPath.row].url_o != nil {
            if let url_o = imageData[indexPath.row].url_o {
                return url_o
            }
        }
        
        if imageData[indexPath.row].url_h != nil {
            if let url_h = imageData[indexPath.row].url_h {
                return url_h
            }
        }

        if imageData[indexPath.row].url_c != nil {
            if let url_c = imageData[indexPath.row].url_c {
                return url_c
            }
        }

        if imageData[indexPath.row].url_z != nil {
            if let url_z = imageData[indexPath.row].url_z {
                return url_z
            }
        }
    
        if imageData[indexPath.row].url_n != nil {
            if let url_n = imageData[indexPath.row].url_n {
                return url_n
            }
        }
    
        if imageData[indexPath.row].url_m != nil {
            if let url_m = imageData[indexPath.row].url_m {
                return url_m
            }
        }
 
        if imageData[indexPath.row].url_t != nil {
            if let url_t = imageData[indexPath.row].url_t {
                return url_t
            }
        }
        return nil
    }
}
