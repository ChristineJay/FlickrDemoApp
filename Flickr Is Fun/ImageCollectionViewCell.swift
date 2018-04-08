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
    @IBOutlet var activityIndicator : UIActivityIndicatorView!
    
    var image : UIImage?
    var photoData : Photo?
    
    override func prepareForReuse() {
        self.image = nil
        self.photoData = nil
    }
    
    public func setup(_ photo : Photo) {
        if self.photoData != nil {
            if self.photoData?.id == photo.id {
                return
            }
        }
        
        self.photoData = photo
        
        self.activityIndicator.startAnimating()
        ApiService.downloadOrFetchImage(photo.GetThumbnailImageUrl(), completion: ({(data) -> Void in
            self.activityIndicator.stopAnimating()
            self.imageView.image = UIImage(data: data)
            }))
    }
}
