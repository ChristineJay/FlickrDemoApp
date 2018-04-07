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
}
