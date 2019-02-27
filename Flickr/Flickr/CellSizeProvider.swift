//
//  CellSizeProvider.swift
//  Flickr
//
//  Created by metoSimka on 26/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit

class CellSizeProvider {
    private static let kTagsPadding: CGFloat = 15
    private static let kMinCellSize: UInt32 = 50
    private static let kMaxCellSize: UInt32 = 100
    
    class func provideSizes() -> [CGSize] {
        var cellSizes = [CGSize]()
        var size: CGSize = .zero
        size = CellSizeProvider.provideFlickrCellSize()
        cellSizes.append(size)
        return cellSizes
    }
  
    private class func provideFlickrCellSize() -> CGSize {
        return CellSizeProvider.provideRandomCellSize()
    }
    
    private class func provideRandomCellSize() -> CGSize {
        let width = CGFloat(arc4random_uniform(kMaxCellSize) + kMinCellSize)
        let height = CGFloat(arc4random_uniform(kMaxCellSize) + kMinCellSize)
        
        return CGSize(width: width, height: height)
    }
}
