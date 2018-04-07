//
//  PopupViewController.swift
//  Flickr Is Fun
//
//  Created by Christine Jogerst on 4/6/18.
//  Copyright © 2018 Christine Jogerst. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {

    @IBOutlet var imageView : UIImageView!
    @IBOutlet var closeButton : UIButton!
    
    var photoData : Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapScreen)))
        // Do any additional setup after loading the view.
        
        let downloadTask = URLSession.shared.dataTask(with: photoData!.GetFullsizedImageUrl()) {(data, response, error) in
            if (error == nil) {
                OperationQueue.main.addOperation({ () -> Void in
                    self.imageView.image = UIImage(data: data!)
                    
                })
            }
        }
        downloadTask.resume()
    }
    
    @IBAction func didSelectClosePopup()
    {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PopupViewController : UIGestureRecognizerDelegate
{
    @objc func didTapScreen(sender : Any) -> Void
    {
        // toggle show/hide close button
        self.closeButton.isHidden = !self.closeButton.isHidden
    }
}
