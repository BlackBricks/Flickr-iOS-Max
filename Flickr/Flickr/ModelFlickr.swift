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
    struct FlickrURLParams {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
    }
    
    struct FlickrAPIKeys {
        static let SearchMethod = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let ResponseFormat = "format"
        static let DisableJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let Sort = "sort"
    }
    
    struct FlickrAPIValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "e3ef44dd033985def51d4d02f680a870"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let ExtrasValue = "url_m, views"
        static let SafeSearch = "1"
        static let SortValue = "relevance"
    }
}
