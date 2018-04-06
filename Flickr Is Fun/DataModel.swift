//
//  DataModel.swift
//  Flickr Is Fun
//
//  Created by Christine Jogerst on 4/6/18.
//  Copyright © 2018 Christine Jogerst. All rights reserved.
//

import UIKit

class DataModel: NSObject {
    var images : [Photo]?
    
    public func numberOfCells() -> Int
    {
        if let images = self.images {
            return images.count
        }
        return 0;
    }
}
