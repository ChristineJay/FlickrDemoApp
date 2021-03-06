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
    
    static func search(searchTerms : String, completion: @escaping (_ result: Photos?, _ error: Error?) -> Void) {
        var searchURLComponents = self.getBaseURLComponents(method: "flickr.photos.search")
        searchURLComponents.queryItems?.append(URLQueryItem(name: "text", value: searchTerms))
        let searchURL = searchURLComponents.url!
        
        let reachable = Reachability.init(hostname: searchURL.host!)
        guard reachable?.connection != Reachability.Connection.none else {
            let errorDictionary : NSDictionary = [NSLocalizedDescriptionKey : "No network connection found"]
            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: errorDictionary as? [String : Any])
            completion(nil, error as Error)
            return
        }
        
        URLSession.shared.dataTask(with: searchURL) { (data, response, error) in
            if let error = error {
                completion(nil, error as Error)
            }
            
            guard let data = data else { return }
            
            let gitData = try? JSONDecoder().decode(Search.self, from: data)
            // todo: throttling
            
            completion(gitData?.photos, error)
            }.resume()
    }
    
    static func getSuggestedTopics(_ completion: @escaping (_ result: [Tag], _ error: Error?) -> Void ) {
        var urlComponents = self.getBaseURLComponents(method: "flickr.tags.getRelated")
        urlComponents.queryItems?.append(URLQueryItem(name: "tag", value: "slalom"))
        let url = urlComponents.url!
        
        let reachable = Reachability.init(hostname: url.host!)
        guard reachable?.connection != Reachability.Connection.none else {
            let errorDictionary : NSDictionary = [NSLocalizedDescriptionKey : "No network connection found"]
            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: errorDictionary as? [String : Any])
            completion([], error as Error)
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion([], error as Error)
            }
            
            guard let data = data else { return }
            
            let gitData = try? JSONDecoder().decode(SuggestedTags.self, from: data)
 
            let tags : [Tag]
            if let gitData = gitData {
                tags = gitData.tags.tag
            } else {
                tags = []
            }
            completion(tags, error)
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
