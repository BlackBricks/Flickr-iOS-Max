//
//  Constants.swift
//  Flickr
//
//  Created by metoSimka on 25/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import Foundation

struct Constants {
    
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
    }
    
    struct FlickrAPIValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "e3ef44dd033985def51d4d02f680a870"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let SafeSearch = "1"
    }
}
/*  MARK:  example of photoArray
 ******************
 farm = 8;
 "height_m" = 375;
 id = 46301705245;
 isfamily = 0;
 isfriend = 0;
 ispublic = 1;
 owner = "141001302@N08";
 secret = 73845d6c96;
 server = 7826;
 title = "River, water and stream";
 "url_m" = "https://farm8.staticflickr.com/7826/46301705245_73845d6c96.jpg";
 "width_m" = 500;
 ******************
 */
    
