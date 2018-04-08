//
//  ViewController.swift
//  Flickr Is Fun
//
//  Created by Christine Jogerst on 4/3/18.
//  Copyright © 2018 Christine Jogerst. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // constants
    private let photoSection : Int = 0
    private let tagSection : Int = 1
    
    @IBOutlet var logoImage : UIImageView!
    @IBOutlet var searchField : UITextField!
    @IBOutlet var sortButton : UIButton!
    @IBOutlet var sortDescriptionLabel : UILabel!
    @IBOutlet var clearPhotosButton : UIButton!
    @IBOutlet var photoCollection : UICollectionView!
    
    @IBOutlet var searchFieldToSuperView : NSLayoutConstraint!
    @IBOutlet var searchFieldToButtons : NSLayoutConstraint!
    
    var model : DataModel = DataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "flickr app"
        
        self.logoImage.isHidden = self.traitCollection.horizontalSizeClass == .compact || self.traitCollection.verticalSizeClass == .compact
        
        if !model.hasPhotoData() && !model.hasTagData() {
            ApiService.getSuggestedTopics({ (result: [Tag], error: Error?) in
                DispatchQueue.main.async {
                    self.model.tags = []
                    
                    if error != nil {
                        let alert : UIAlertController = UIAlertController.init(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    for tag in result {
                        self.model.tags.append(tag.content)
                    }
                    self.reloadView()
                }
            })
        }
        
        self.reloadView()
    }
    
    func reloadView() {
        let photoMode : Bool = self.model.hasPhotoData()
        self.sortButton.isHidden = !photoMode
        self.sortDescriptionLabel.isHidden = !photoMode
        self.clearPhotosButton.isHidden = !photoMode
        
        self.searchFieldToSuperView.priority = photoMode ? .defaultLow : .defaultHigh
        self.searchFieldToButtons.priority = photoMode ? .defaultHigh : .defaultLow
        
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
    
    @IBAction func didSelectClearPhotos() {
        self.searchField.text = ""
        self.model.images = []
        self.reloadView()
    }
    
    func makeSearchRequestAndReload(_ searchText : String) {
        if searchText == "" {
            return
        }
        
        self.searchField.isEnabled = false
        ApiService.search(searchTerms: searchText,
                          completion: { (result: Photos?, error: Error?) in
                            DispatchQueue.main.async {
                                self.searchField.isEnabled = true
                                
                                if error != nil {
                                    let alert : UIAlertController = UIAlertController.init(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    return
                            }
                            
                            if let result = result {
                                self.model.images = result.photo
                                self.reloadView()
                            } else {
                                self.model.images = []
                                
                                let alert : UIAlertController = UIAlertController.init(title: "Error", message: "Unable to complete request", preferredStyle: .alert)
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                            }
        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // if we rotate, we need to relayout the tags section so it is the correct size
        if !model.hasPhotoData() {
            photoCollection.collectionViewLayout.invalidateLayout()
        }
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
        self.sortDescriptionLabel.text = self.model.getFilterDescriptionText()
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

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
            return model.images.count
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == tagSection {
            // this implementation is a little weird, but I wanted the suggested tags to be variable size
            let tag : String = model.tags[indexPath.row]
            let width = min(tag.count * 15 + (15 * Int(1 + arc4random_uniform(1))), Int(collectionView.frame.size.width - 32))
            
            return CGSize.init(width: width, height: 45)
        }
        
        return CGSize.init(width: 163, height: 150)
    }
}
