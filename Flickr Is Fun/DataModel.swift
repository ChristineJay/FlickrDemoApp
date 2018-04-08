//
//  DataModel.swift
//  Flickr Is Fun
//
//  Created by Christine Jogerst on 4/6/18.
//  Copyright © 2018 Christine Jogerst. All rights reserved.
//

import UIKit

public class DataModel: NSObject {
    var images : [Photo] = []
    var filterOption : FilterOption = .none

    var tags : [String] = []//[ "test", "hello", "slalom" ]
    
    func numberOfPhotosToDisplay() -> Int {
        return min(images.count, 20)
    }
    
    func hasPhotoData() -> Bool {
        return images.count > 0
    }
    
    func hasTagData() -> Bool {
        return tags.count > 0
    }
    
    func getFilterDescriptionText() -> String {
        switch filterOption {
        case .none:
            return "sort"
        case .alphabeticalByOwner:
            return "sorted (by owner)"
        case .alphabeticalByTitle:
            return "sorted (by title)"
        }
    }
    
    func updateFilterOption(_ option : FilterOption) {
        self.filterOption = option
        self.sortBy(option)
    }
    
    func sortBy(_ option : FilterOption) {
        switch option {
        case .none:
            self.images.sort(by: { $0.id < $1.id } )
            break
        case .alphabeticalByOwner:
            self.images.sort(by: { $0.owner < $1.owner } )
            break
        case .alphabeticalByTitle:
            self.images.sort(by: { $0.title < $1.title } )
            break
        }
    }
}
