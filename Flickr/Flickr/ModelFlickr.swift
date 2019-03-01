//
//  Constants.swift
//  Flickr
//
//  Created by metoSimka on 25/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    struct SegueIdentifier {
        static let GallerySegue = "Gallery viewing"
    }
    
    struct Paddings {
        static let horizontalContentPadding: CGFloat = 10
        static let verticalContentPadding: CGFloat = 10
        static let horizontalCellPadding: CGFloat = 8
        static let verticalCellPadding: CGFloat = 8
    }

    let keysFlickr = """
Key: e3ef44dd033985def51d4d02f680a870
Secret: 0ccd083217302f35
"""
    struct FlickrAPI {
        static let baseUrl = "https://api.flickr.com"
        static let path = "/services/rest"
        static let key = "e3ef44dd033985def51d4d02f680a870"
    }
    static let searchParams = [
        "method": "flickr.photos.search",
        "api_key": "\(FlickrAPI.key)",
        "extras": "url_m, views",
        "format": "json",
        "nojsoncallback": "1",
        "safe_search": "1",
        "sort": "relevance",
        "text": ""
    ]
    
    static let popularParams = [
        "method": "flickr.photos.getPopular",
        "api_key": "\(FlickrAPI.key)",
        "extras": "url_m, views",
        "format": "json",
        "nojsoncallback": "1",
        "safe_search": "1",
        "text": ""
    ]
    
}
