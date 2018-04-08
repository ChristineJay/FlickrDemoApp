//
//  ApiService.swift
//  Flickr Is Fun
//
//  Created by Christine Jogerst on 4/7/18.
//  Copyright © 2018 Christine Jogerst. All rights reserved.
//

import UIKit

public class ApiService: NSObject {

    private static func getBaseURLComponents(method : String) -> URLComponents {
        var urlComponents : URLComponents = URLComponents(string: "https://api.flickr.com/services/rest")!
        
        urlComponents.queryItems = [URLQueryItem(name: "method", value: method),
                                    URLQueryItem(name: "api_key", value: "83c35e70e57c347f68243a88985f6c95"),
                                    URLQueryItem(name: "format", value: "json"),
                                    URLQueryItem(name: "nojsoncallback", value: "1"),
                                    URLQueryItem(name: "safe_search", value: "1")] // enable safe search
        return urlComponents
    }
    
    static func search(searchTerms : String, completion: @escaping (_ result: Photos) -> Void){

        var searchURLComponents = self.getBaseURLComponents(method: "flickr.photos.search")
        searchURLComponents.queryItems?.append(URLQueryItem(name: "text", value: searchTerms))
        let searchURL = searchURLComponents.url!
        
        URLSession.shared.dataTask(with: searchURL) { (data, response, error) in
            guard let data = data else { return }
            
            let gitData = try? JSONDecoder().decode(Search.self, from: data)
            // todo: error handling and throttling
            
            DispatchQueue.main.async {
                completion((gitData?.photos)!)
            }
            }.resume()
    }
    
    private static var cache : NSCache<AnyObject,AnyObject> = NSCache()
    static func downloadOrFetchImage(_ url : URL, completion: @escaping (_ data : Data) -> Void) {
        // todo: error handling
        
        if cache.object(forKey: url as AnyObject) != nil {
            completion(cache.object(forKey: url as AnyObject) as! Data)
            return
        }
        
        let downloadTask = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if error == nil {
                OperationQueue.main.addOperation({ () -> Void in
                    self.cache.setObject(data as AnyObject, forKey: url as AnyObject)
                    completion(data!)
                })
            }
        }
        downloadTask.resume()
    }
}
