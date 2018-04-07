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
    @IBOutlet var sortButton : UIButton!
    @IBOutlet var photoCollection : UICollectionView!
    
    var model : DataModel = DataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // todo
    }

    // Mark: actions
    @IBAction func didSelectSortBy() -> Void
    {
        let vc : FilterViewController = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController)!
        vc.delegate = self
        vc.selectedFilterOption = model.filterOption
        vc.modalPresentationStyle = .formSheet
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension MainViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let searchText = searchField.text {
            
            ApiService.search(searchTerms: searchText,
                              completion: { (result: Photos) in

                self.model.images = result.photo
                self.photoCollection.reloadData()
            })
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

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // show popup

        let vc : PopupViewController = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "PopupViewController") as? PopupViewController)!
        vc.photoData = model.images[indexPath.row]
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.numberOfCells()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrCell", for: indexPath) as! ImageCollectionViewCell
        cell.setup(model.images[indexPath.row])
        return cell
    }
}
