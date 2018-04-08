//
//  search.swift
//  Flickr Is Fun
//
//  Created by Christine Jogerst on 4/4/18.
//  Copyright © 2018 Christine Jogerst. All rights reserved.
//

import UIKit

struct Photo: Codable {
    
    //"id":"27342797718","owner":"156426605@N03","secret":"e11ea1ab5e","server":"890","farm":1,"title":"Hi","ispublic":1,"isfriend":0,"isfamily":0
    
    let id : String
    let owner : String
    let secret : String
    let farm : Int
    let server : String
    let title : String
    let ispublic : Int
    let isfriend : Int
    let isfamily : Int
    
    private enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case farm
        case server
        case title
        case ispublic
        case isfriend
        case isfamily
    }
    
    // Mark - images
    
    func GetThumbnailImageUrl() -> URL
    {
        return URL.init(string: GetUrlForSize(true))!
    }
    
    func GetFullsizedImageUrl() -> URL
    {
        return URL.init(string: GetUrlForSize(false))!
    }
    
    // https://www.flickr.com/services/api/misc.urls.html
    private func GetUrlForSize( _ thumbnail : Bool) -> String {
        let filesize_id : String = (thumbnail ? "m" : "z")
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(filesize_id).jpg"
    }
}

struct Photos: Codable {

    //photos":{"page":1,"pages":2024,"perpage":100,"total":"202377","photo"
    
    let page : Int
    let pages : Int
    let perpage : Int
    let photo : [Photo]
    
    private enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perpage
        case photo
    }
}

struct Search: Codable {

    // {"photos": ..., , "stat":"ok"}
    
    let photos: Photos
    let stat : String

    private enum CodingKeys: String, CodingKey {
        case photos
        case stat
    }
}

struct Tag : Codable {
    
    // {"score":"100","_content":"feb23"}
    
    let content : String
    
    private enum CodingKeys: String, CodingKey {
        case content = "_content"
    }
}

struct TrendingTags : Codable {
    // period":"day","count":20,"tag":[
    
    let period : String
    let count : String
    let tag : [Tag]
    
    private enum CodingKeys: String, CodingKey {
        case period
        case count
        case tag
    }
}

struct GetTrendingTags : Codable
{
    let trendingTags : TrendingTags
    let stat : String
    
    private enum CodingKeys: String, CodingKey {
        case trendingTags = "hottags"
        case stat
    }
}

struct RelatedTags : Codable {

    let tag : [Tag]
    
    private enum CodingKeys: String, CodingKey {
        case tag
    }
}

struct SuggestedTags : Codable {
    
    let tags : RelatedTags
    let stat : String

    private enum CodingKeys: String, CodingKey {
        case tags
        case stat
    }
}
