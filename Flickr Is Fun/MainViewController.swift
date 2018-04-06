//
//  ViewController.swift
//  Flickr Is Fun
//
//  Created by Christine Jogerst on 4/3/18.
//  Copyright © 2018 Christine Jogerst. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet var searchField : UITextField!
    @IBOutlet var photoCollection : UICollectionView!
    
    var model : DataModel = DataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photoCollection.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "FlickrCell")
        
        // todo
    }

    // Mark: actions
    @IBAction func search() -> Void {

        let searchText : String = searchField.text!

        let urlComponents : URLComponents = URLComponents(string: "https://api.flickr.com/services/rest")!
        var searchURLComponents = urlComponents
        searchURLComponents.queryItems = [URLQueryItem(name: "method", value: "flickr.photos.search"),
                                          URLQueryItem(name: "api_key", value: "83c35e70e57c347f68243a88985f6c95"),
                                          URLQueryItem(name: "format", value: "json"),
                                          URLQueryItem(name: "nojsoncallback", value: "1"),
                                          URLQueryItem(name: "tags", value: searchText)]
        let searchURL = searchURLComponents.url!
        
        URLSession.shared.dataTask(with: searchURL) { (data, response, error) in
            guard let data = data else { return }

            let gitData = try? JSONDecoder().decode(Search.self, from: data)
            print(gitData ?? "Nothing here")
            //self.processSearchResponse(data: (gitData?.photos)!)
            DispatchQueue.main.async { [unowned self] in
                self.processSearchResponse(data: (gitData?.photos)!)
            }
            }.resume()
    }
    
    func processSearchResponse(data : Photos) -> Void
    {
        self.model.images = data.photo

        self.photoCollection.reloadData()
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // show popup
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.numberOfCells()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrCell", for: indexPath)
    }
    
}
