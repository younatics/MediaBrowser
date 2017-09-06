//
//  GridCell.swift
//  Pods
//
//  Created by Tapani Saarinen on 04/09/15.
//
//

import UIKit
import DACircularProgress

public class GridCell: UICollectionViewCell {
    let videoIndicatorPadding = CGFloat(10.0)
    
    var index = 0
    var selectionMode = false
    
    private let imageView = UIImageView()
    private let videoIndicator = UIImageView()
    private var loadingError: UIImageView?
	private let loadingIndicator = DACircularProgressView(frame: CGRectMake(0, 0, 40.0, 40.0))
    private let selectedButton = UIButton(type: .Custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        // Grey background
        backgroundColor = UIColor(white: 0.12, alpha: 1.0)
        
        // Image
        imageView.frame = self.bounds
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        imageView.autoresizesSubviews = true
        
        addSubview(imageView)
        
        // Video Image
        videoIndicator.hidden = false
        let videoIndicatorImage = UIImage.imageForResourcePath(
            "MWPhotoBrowserSwift.bundle/VideoOverlay",
            ofType: "png",
            inBundle: NSBundle(forClass: GridCell.self))!
            
        videoIndicator.frame = CGRectMake(
            self.bounds.size.width - videoIndicatorImage.size.width - videoIndicatorPadding,
            self.bounds.size.height - videoIndicatorImage.size.height - videoIndicatorPadding,
            videoIndicatorImage.size.width, videoIndicatorImage.size.height)
        
        videoIndicator.image = videoIndicatorImage
        videoIndicator.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        videoIndicator.autoresizesSubviews = true
        addSubview(videoIndicator)
        
        // Selection button
        selectedButton.contentMode = UIViewContentMode.TopRight
        selectedButton.adjustsImageWhenHighlighted = false

        selectedButton.setImage(
            UIImage.imageForResourcePath(
                "MWPhotoBrowserSwift.bundle/ImageSelectedSmallOff",
                ofType: "png",
                inBundle: NSBundle(forClass: GridCell.self)),
            forState: .Normal)

        selectedButton.setImage(UIImage.imageForResourcePath(
                "MWPhotoBrowserSwift.bundle/ImageSelectedSmallOn",
                ofType: "png",
                inBundle: NSBundle(forClass: GridCell.self)),
            forState: .Selected)

        selectedButton.addTarget(self, action: Selector("selectionButtonPressed"), forControlEvents: .TouchDown)
        selectedButton.hidden = true
        selectedButton.frame = CGRectMake(0, 0, 44, 44)
        addSubview(selectedButton)
    
        // Loading indicator
        loadingIndicator.userInteractionEnabled = false
        loadingIndicator.thicknessRatio = 0.1
        loadingIndicator.roundedCorners = 0
        addSubview(loadingIndicator)
        
        // Listen for photo loading notifications
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("setProgressFromNotification:"),
            name: MWPHOTO_PROGRESS_NOTIFICATION,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("handlePhotoLoadingDidEndNotification:"),
            name: MWPHOTO_LOADING_DID_END_NOTIFICATION,
            object: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    private weak var mwGridController: GridViewController?

    var gridController: GridViewController? {
        set(gridCtl) {
            mwGridController = gridCtl
        
            if let gc = gridCtl {
                // Set custom selection image if required
                if let browser = gc.browser {
                    if browser.customImageSelectedSmallIconName.characters.count > 0 {
                        selectedButton.setImage(UIImage(named: browser.customImageSelectedSmallIconName), forState: .Selected)
                    }
                }
            }
        }
        
        get {
            return mwGridController
        }
    }

    //MARK: - View

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        
        loadingIndicator.frame = CGRectMake(
            CGFloat(floorf(Float(bounds.size.width - loadingIndicator.frame.size.width) / 2.0)),
            CGFloat(floorf(Float(bounds.size.height - loadingIndicator.frame.size.height) / 2.0)),
            loadingIndicator.frame.size.width,
            loadingIndicator.frame.size.height)
            
        selectedButton.frame = CGRectMake(
            bounds.size.width - selectedButton.frame.size.width,
            0.0,
            selectedButton.frame.size.width,
            selectedButton.frame.size.height)
    }

    //MARK: - Cell

    public override func prepareForReuse() {
        photo = nil
        mwGridController = nil
        imageView.image = nil
        loadingIndicator.progress = 0
        selectedButton.hidden = true
        hideImageFailure()
        
        super.prepareForReuse()
    }

    //MARK: - Image Handling

    private var mwPhoto: Photo?

    var photo: Photo? {
        set(p) {
            mwPhoto = p
            
            if let ph = p {
                videoIndicator.hidden = !ph.isVideo
                
                if nil == ph.underlyingImage {
                    showLoadingIndicator()
                }
                else {
                    hideLoadingIndicator()
                }
            }
            else {
                showImageFailure()
            }
        }
        
        get {
            return mwPhoto
        }
    }

    func displayImage() {
        if let p = mwPhoto {
            imageView.image = p.underlyingImage
            selectedButton.hidden = !selectionMode
            self.hideImageFailure()
        }
    }

    //MARK: - Selection

    public override var selected: Bool {
        set(sel) {
            super.selected = sel
            selectedButton.selected = sel
        }
        
        get {
            return super.selected
        }
    }

    func selectionButtonPressed() {
        selectedButton.selected = !selectedButton.selected
        
        if let gc = gridController {
            if let browser = gc.browser {
                browser.setPhotoSelected(selectedButton.selected, atIndex: index)
            }
        }
    }

    //MARK: - Touches

    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        imageView.alpha = 0.6
        super.touchesBegan(touches, withEvent: event)
    }

    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        imageView.alpha = 1
        super.touchesEnded(touches, withEvent: event)
    }

    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        imageView.alpha = 1
        super.touchesCancelled(touches, withEvent: event)
    }

    //MARK: - Indicators

    private func hideLoadingIndicator() {
        loadingIndicator.hidden = true
    }

    private func showLoadingIndicator() {
        loadingIndicator.progress = 0
        loadingIndicator.hidden = false
        
        hideImageFailure()
    }

    private func showImageFailure() {
        // Only show if image is not empty
        if let p = photo where p.emptyImage {
            if nil == loadingError {
                let error = UIImageView()
                error.image = UIImage.imageForResourcePath(
                    "MWPhotoBrowserSwift.bundle/ImageError",
                    ofType: "png",
                    inBundle: NSBundle(forClass: GridCell.self))
        
                error.userInteractionEnabled = false
                error.sizeToFit()
            
                addSubview(error)
                loadingError = error
            }
            
            if let e = loadingError {
                e.frame = CGRectMake(
                    CGFloat(floorf(Float(bounds.size.width - e.frame.size.width) / 2.0)),
                    CGFloat(floorf(Float(bounds.size.height - e.frame.size.height) / 2.0)),
                    e.frame.size.width,
                    e.frame.size.height)
            }
        }
        
        hideLoadingIndicator()
        imageView.image = nil
    }

    private func hideImageFailure() {
        if loadingError != nil {
            loadingError!.removeFromSuperview()
            loadingError = nil
        }
    }

    //MARK: - Notifications

    public func setProgressFromNotification(notification: NSNotification) {
        if let dict = notification.object as? [String : AnyObject?],
            photoWithProgress = dict["photo"] as? Photo,
            mwp = mwPhoto where photosEqual(photoWithProgress, mwp)
        {
            if let progress = dict["progress"] as? String,
                progressVal =  NSNumberFormatter().numberFromString(progress)
            {
                dispatch_async(dispatch_get_main_queue()) {
                    self.loadingIndicator.progress = CGFloat(max(min(1.0, progressVal.floatValue), 1.0))
                    return
                }
            }
        }
    }

    public func handlePhotoLoadingDidEndNotification(notification: NSNotification) {
        if let p = notification.object as? Photo,
            mwp = mwPhoto where photosEqual(p, mwp)
        {
            if p.underlyingImage != nil {
                // Successful load
                displayImage()
            }
            else {
                // Failed to load
                showImageFailure()
            }
            
            hideLoadingIndicator()
        }
    }
    
    private func photosEqual(p1: Photo, _ p2: Photo) -> Bool {
        return
            p1.underlyingImage == p2.underlyingImage &&
            p1.emptyImage == p2.emptyImage &&
            p1.isVideo == p2.isVideo &&
            p1.caption == p2.caption
    }
}
