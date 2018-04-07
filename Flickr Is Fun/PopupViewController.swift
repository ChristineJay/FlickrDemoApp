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
    @IBOutlet var imageTitle : UILabel!
    @IBOutlet var imagePhotographer : UILabel!
    @IBOutlet var closeButton : UIButton!
    
    var photoData : Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapScreen)))
        // Do any additional setup after loading the view.
        setupMetadata()
        
        let downloadTask = URLSession.shared.dataTask(with: photoData!.GetFullsizedImageUrl()) {(data, response, error) in
            if error == nil {
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
    
    var lastScale : CGFloat = 0
    var lastPoint : CGPoint = CGPoint()
    @IBAction func scalePiece(_ gestureRecognizer : UIPinchGestureRecognizer) {

        guard gestureRecognizer.view != nil else { return }
    
        if gestureRecognizer.state == .began {
            lastScale = 1.0
            lastPoint = gestureRecognizer.location(in: self.imageView)
        }
    
        // zoom
        let scale : CGFloat = 1.0 - (lastScale - gestureRecognizer.scale)
        self.imageView.layer.setAffineTransform(self.imageView.layer.affineTransform().scaledBy(x: scale, y: scale))
        lastScale = gestureRecognizer.scale
    
        // center on where interaction was
        let point : CGPoint = gestureRecognizer.location(in: self.imageView)
        self.imageView.layer.setAffineTransform(self.imageView.layer.affineTransform().translatedBy(x: point.x - lastPoint.x, y:  point.y - lastPoint.y))
        lastPoint = gestureRecognizer.location(in: self.imageView)
    }
    
    @IBAction func swipeToClose(_ gestureRecognizer : UISwipeGestureRecognizer) {
        
        guard gestureRecognizer.view != nil else { return }
        
        switch gestureRecognizer.direction {
        case .right:
            // todo: forwards
            break;
        case .left:
            // todo: backwards
            break;
        default:
            // up or down to close
            self.didSelectClosePopup()
            break;
        }
    }
    
    func setupMetadata() -> Void {
        self.imageTitle.text = photoData?.title
        self.imagePhotographer.text = "photo by \(photoData?.owner ?? "unavailable")"
        
        // todo: include metadata of actual image
    }
    
    func toggleMetadataHidden(hidden : Bool) -> Void {
        self.imageTitle.isHidden = hidden
        self.imagePhotographer.isHidden = hidden
    }
}

extension PopupViewController : UIGestureRecognizerDelegate
{
    @objc func didTapScreen(sender : Any) -> Void
    {
        // toggle show/hide close button
        self.closeButton.isHidden = !self.closeButton.isHidden
        self.toggleMetadataHidden(hidden: self.closeButton.isHidden)
    }
}
