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
            interestInfo.hieghtImage = itemArray["hieght_m"] as? String
            interestInfo.widthImage = itemArray["width_m"] as? String
            return interestInfo
        })
        return photo
    }
}






