//
//  ImageCollectionViewCell.swift
//  Flickr Is Fun
//
//  Created by Christine Jogerst on 4/6/18.
//  Copyright © 2018 Christine Jogerst. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet var imageView : UIImageView!
    
    var image : UIImage?
    var photo : Photo?
    
    public func setup(_ photo : Photo) -> Void
    {
        // todo: caching, loading animation, error handling
        
        let downloadTask = URLSession.shared.dataTask(with: photo.GetThumbnailImageUrl()) {(data, response, error) in
            if (error == nil) {
                OperationQueue.main.addOperation({ () -> Void in
                    self.imageView.image = UIImage(data: data!)
                    
                })
            }
        }
        downloadTask.resume()
    }
}
