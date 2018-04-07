//
//  FilterViewController.swift
//  Flickr Is Fun
//
//  Created by Christine Jogerst on 4/7/18.
//  Copyright © 2018 Christine Jogerst. All rights reserved.
//

import UIKit

enum FilterOption : Int {
    case none = 0, alphabeticalByTitle, alphabeticalByOwner
}

protocol FilterViewControllerDelegate {
    func didSelectFilterOption(_ sortBy : FilterOption)
}

class FilterViewController: UIViewController {

    @IBOutlet var tableView : UITableView!
    
    var delegate : FilterViewControllerDelegate?
    var selectedFilterOption : FilterOption = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension FilterViewController : UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let delegate = self.delegate {
            delegate.didSelectFilterOption(FilterOption.init(rawValue: indexPath.row)!)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = UITableViewCell()
        cell.selectionStyle = .default
        cell.setSelected((indexPath.row == self.selectedFilterOption.rawValue), animated: false)
        
        switch indexPath.row {
        case FilterOption.none.rawValue:
            cell.textLabel?.text = "Clear Filter"

            break;
        case FilterOption.alphabeticalByTitle.rawValue:
            cell.textLabel?.text = "Alphabetical by Title"
            break;
        case FilterOption.alphabeticalByOwner.rawValue:
            cell.textLabel?.text = "Alphabetical by Owner"
            break;
        default:
            break;
        }
        
        return cell
    }
}

