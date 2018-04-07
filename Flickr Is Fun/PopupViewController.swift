//
//  PopupViewController.swift
//  Flickr Is Fun
//
//  Created by Christine Jogerst on 4/6/18.
//  Copyright © 2018 Christine Jogerst. All rights reserved.
//

import UIKit

protocol PopupViewControllerDelegate {
    func canGoBack(index : Int) -> Bool
    func canGoForward(index : Int) -> Bool
    func getPrevPhoto(index : Int) -> Photo
    func getNextPhoto(index : Int) -> Photo
}

class PopupViewController: UIViewController {

    @IBOutlet var imageView : UIImageView!
    @IBOutlet var imageTitle : UILabel!
    @IBOutlet var imagePhotographer : UILabel!
    @IBOutlet var closeButton : UIButton!
    
    var photoData : Photo?
    var photoIndex : Int = 0
    
    var delegate : PopupViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadView()
    }
    
    public func setup(_ photo : Photo, photoIndex : Int, delegate : PopupViewControllerDelegate) {
        self.photoData = photo
        self.photoIndex = photoIndex
        self.delegate = delegate
    }
    
    func reloadView() {
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
    
    @IBAction func didTapScreen() {
        // toggle show/hide close button
        self.closeButton.isHidden = !self.closeButton.isHidden
        self.toggleMetadataHidden(hidden: self.closeButton.isHidden)
    }
    
    @IBAction func didSelectClosePopup() {
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
    
    @IBAction func didSwipeUpOrDown(_ gestureRecognizer : UISwipeGestureRecognizer) {
        
        guard gestureRecognizer.view != nil else { return }
        
        // up or down to close
        self.didSelectClosePopup()
    }
    
    func setupMetadata() {
        self.imageTitle.text = photoData?.title
        self.imagePhotographer.text = "photo by \(photoData?.owner ?? "unavailable")"
        
        // todo: include metadata of actual image
    }
    
    func toggleMetadataHidden(hidden : Bool) {
        self.imageTitle.isHidden = hidden
        self.imagePhotographer.isHidden = hidden
    }
    
    @IBAction func didSwipeRight() {
        // try and get previous image
        if let delegate = self.delegate {
            if delegate.canGoBack(index: photoIndex) {
                self.photoData = delegate.getPrevPhoto(index: photoIndex)
                self.photoIndex = photoIndex - 1
                self.reloadView()
            }
        }
    }
    
    @IBAction func didSwipeLeft() {
        // try and get the next image
        if let delegate = self.delegate {
            if delegate.canGoForward(index: photoIndex) {
                self.photoData = delegate.getNextPhoto(index: photoIndex)
                self.photoIndex = photoIndex + 1
                self.reloadView()
            }
        }
    }
}
