//
//  ImageUtils.swift
//  Flickr Is Fun
//
//  Created by Christine Jogerst on 4/7/18.
//  Copyright © 2018 Christine Jogerst. All rights reserved.
//

import UIKit

public class ImageUtils: NSObject {

    static func getMetadata(_ image : UIImage) -> Void {
        
        let data : Data? = UIImagePNGRepresentation(image)
        
        guard data != nil else { return }
        
        let imageData : CGImageSource = CGImageSourceCreateWithData(data! as CFData, nil)!
        let metadata : NSDictionary =  CGImageSourceCopyPropertiesAtIndex(imageData, 0, nil)!
        print(metadata)
    }
    
}
