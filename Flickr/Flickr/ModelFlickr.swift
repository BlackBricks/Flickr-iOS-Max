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
        static let detailSegueFromSearchView = "Show Detail From SearchView"
        static let detailSegueFromPopulariew = "Show Detail From PopularView"
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
        "extras": "url_s, views, owner_name, icon_server",
        "format": "json",
        "nojsoncallback": "1",
        "safe_search": "0",
        "sort": "relevance",
        "text": "",
        "page": "1",
        "per_page": "100"
    ]
    
    static let popularParams = [
        "method": "flickr.interestingness.getList",
        "api_key": "\(FlickrAPI.key)",
        "extras": "url_s, views, owner_name, icon_server",
        "format": "json",
        "nojsoncallback": "1",
        "safe_search": "0",
        "page": "1",
        "per_page": "100"
    ]
}
/// Mark - necessery comment for later :
//print("\(Alamofire.request(Router.popular(page: pageCalculated)).responseJSON)")
