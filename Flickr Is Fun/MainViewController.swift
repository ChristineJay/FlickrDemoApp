//
//  ViewController.swift
//  Flickr Is Fun
//
//  Created by Christine Jogerst on 4/3/18.
//  Copyright © 2018 Christine Jogerst. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    let photoSection : Int = 0
    let tagSection : Int = 1
    
    @IBOutlet var searchField : UITextField!
    @IBOutlet var sortButton : UIButton!
    @IBOutlet var searchHistoryButton : UIButton!
    @IBOutlet var photoCollection : UICollectionView!
    
    var model : DataModel = DataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "flickr app"

        self.reloadView()
    }
    
    func reloadView() {
        
        self.sortButton.isHidden = !self.model.hasPhotoData()
        self.photoCollection.reloadData()
    }

    // Mark: actions
    @IBAction func didSelectSortBy() {
        let vc : FilterViewController = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController)!
        vc.delegate = self
        vc.selectedFilterOption = model.filterOption
        vc.modalPresentationStyle = .formSheet
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didSelectViewHistory() {
        
    }
    
    func makeSearchRequestAndReload(_ searchText : String) {
        ApiService.search(searchTerms: searchText,
                          completion: { (result: Photos) in
                            
                            self.model.images = result.photo
                            self.reloadView()
        })
    }
}

extension MainViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let searchText = searchField.text {
            
            makeSearchRequestAndReload(searchText)
        }
        
        textField.resignFirstResponder()
        return true
    }
}

extension MainViewController: FilterViewControllerDelegate {

    func didSelectFilterOption(_ sortBy: FilterOption) {
        self.model.updateFilterOption(sortBy)
        self.sortButton.setTitle(self.model.getFilterDescriptionText(), for: .normal)
        self.photoCollection.reloadData()
    }
}

extension MainViewController: PopupViewControllerDelegate {
    func canGoBack(index : Int) -> Bool {
        return ((index - 1) >= 0)
    }
    
    func canGoForward(index : Int) -> Bool {
        return ((index + 1) <= model.images.count)
    }

    func getPrevPhoto(index : Int) -> Photo {
        var idx = index - 1
        if idx < 0 {
            idx = 0
        }
        return model.images[idx]
    }
    
    func getNextPhoto(index : Int) -> Photo {
        var idx = index + 1
        if idx >= model.images.count {
            idx = model.images.count - 1
        }
        return model.images[idx]
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == photoSection {
            let vc : PopupViewController = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "PopupViewController") as? PopupViewController)!
            vc.setup(model.images[indexPath.row], photoIndex: indexPath.row, delegate: self)
            vc.modalPresentationStyle = .custom
            self.present(vc, animated: true, completion: nil)
         } else {
            let searchText : String = model.tags[indexPath.row]
            self.searchField.text = searchText
            makeSearchRequestAndReload(searchText)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == photoSection {
            return model.numberOfPhotosToDisplay()
        } else {
            if model.hasPhotoData() {
                return 0
            }
            return model.tags.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case photoSection:
            let cell : ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrCell", for: indexPath) as! ImageCollectionViewCell
            cell.setup(model.images[indexPath.row])
            return cell
        case tagSection:
            let cell : TagCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as! TagCollectionViewCell
            cell.titleView.text = model.tags[indexPath.row]
            return cell
        default:
            break
        }
        
        // shouldn't happen
        return collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrCell", for: indexPath) as! ImageCollectionViewCell
    }
}
