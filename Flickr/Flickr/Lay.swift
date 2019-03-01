//
//  File.swift
//  Flickr
//
//  Created by metoSimka on 01/03/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import Foundation

public protocol Weighable {
    var weight: Int { get }
}

extension Int: Weighable {
    public var weight: Int { return self }
}
