//
//  TagCollectionViewCell.swift
//  Flickr Is Fun
//
//  Created by Christine Jogerst on 4/7/18.
//  Copyright © 2018 Christine Jogerst. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    @IBOutlet var titleView : UILabel!
    
    // UX designers are amazing because making things look nice is incredibly difficult
    // I thought having a random background would look fun, but it was just stress-inducing
    /*private let colors = [ UIColor.cyan, UIColor.red, UIColor.clear, UIColor.lightGray, UIColor.white, UIColor.yellow ]
    func selectRandomBackgroundColor() {
        let index = Int(arc4random()) % colors.count
        let color = colors[index]
        self.backgroundColor = color
    }*/
}
