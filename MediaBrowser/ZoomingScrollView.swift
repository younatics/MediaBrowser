//
//  ZoomingScrollView.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//

import UIKit
//import DACircularProgress

public class ZoomingScrollView: UIScrollView, UIScrollViewDelegate, TapDetectingImageViewDelegate, TapDetectingViewDelegate {
    public var index = 0
    public var mwPhoto: Photo?
    public weak var captionView: CaptionView?
    public weak var selectedButton: UIButton?
    public weak var playButton: UIButton?

    private weak var photoBrowser: PhotoBrowser!
	private var tapView = TapDetectingView(frame: .zero) // for background taps
	private var photoImageView = TapDetectingImageView(frame: .zero)
	private var loadingIndicator = DACircularProgressView(frame: CGRectMake(140.0, 30.0, 40.0, 40.0))
    private var loadingError: UIImageView?
    
    public init(photoBrowser: PhotoBrowser) {
        super.init(frame: .zero)
        
        // Setup
        index = Int.max
        self.photoBrowser = photoBrowser
        
        // Tap view for background
        tapView = TapDetectingView(frame: bounds)
        tapView.tapDelegate = self
        tapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tapView.backgroundColor = UIColor.whiteColor()
        addSubview(tapView)
        
        // Image view
        photoImageView.tapDelegate = self
        photoImageView.contentMode = UIViewContentMode.Center
        addSubview(photoImageView)
        
        // Loading indicator
        loadingIndicator.userInteractionEnabled = false
        loadingIndicator.thicknessRatio = 0.1
        loadingIndicator.roundedCorners = 0
        loadingIndicator.autoresizingMask =
            [.FlexibleLeftMargin, .FlexibleTopMargin, .FlexibleBottomMargin, .FlexibleRightMargin]
        
        addSubview(loadingIndicator)

        // Listen progress notifications
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("setProgressFromNotification:"),
            name: MWPHOTO_PROGRESS_NOTIFICATION,
            object: nil)
        
        // Setup
        backgroundColor = UIColor.whiteColor()
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        decelerationRate = UIScrollViewDecelerationRateFast
        autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func prepareForReuse() {
        hideImageFailure()
        photo = nil
        captionView = nil
        selectedButton = nil
        playButton = nil
        photoImageView.hidden = false
        photoImageView.image = nil
        index = Int.max
    }

    func displayingVideo() -> Bool {
        if let p = photo {
            return p.isVideo
        }
        
        return false
    }
    
    public override var backgroundColor: UIColor? {
        set(color) {
            tapView.backgroundColor = color
            super.backgroundColor = color
        }
        
        get {
            return super.backgroundColor
        }
    }

    var imageHidden: Bool {
        set(hidden) {
            photoImageView.hidden = hidden
        }
        
        get {
            return photoImageView.hidden
        }
    }

    //MARK: - Image

    var photo: Photo? {
        set(p) {
            // Cancel any loading on old photo
            if mwPhoto != nil && p == nil {
                mwPhoto!.cancelAnyLoading()
            }
            mwPhoto = p
            if photoBrowser.imageForPhoto(mwPhoto) != nil {
                self.displayImage()
            }
            else {
                // Will be loading so show loading
                self.showLoadingIndicator()
            }
        }
        
        get {
            return mwPhoto
        }
    }

    // Get and display image
    func displayImage() {
        if mwPhoto != nil && photoImageView.image == nil {
            // Reset
            maximumZoomScale = 1.0
            minimumZoomScale = 1.0
            zoomScale = 1.0
            contentSize = CGSizeMake(0.0, 0.0)
            
            // Get image from browser as it handles ordering of fetching
            if let img = photoBrowser.imageForPhoto(photo) {
                // Hide indicator
                hideLoadingIndicator()
                
                // Set image
                photoImageView.image = img
                photoImageView.hidden = false
                
                // Setup photo frame
                var photoImageViewFrame = CGRectZero
                photoImageViewFrame.origin = CGPointZero
                photoImageViewFrame.size = img.size
                photoImageView.frame = photoImageViewFrame
                contentSize = photoImageViewFrame.size

                // Set zoom to minimum zoom
                setMaxMinZoomScalesForCurrentBounds()
                
            }
            else  {
                // Show image failure
                displayImageFailure()
            }
            
            setNeedsLayout()
        }
    }

    // Image failed so just show grey!
    func displayImageFailure() {
        hideLoadingIndicator()
        photoImageView.image = nil
        
        // Show if image is not empty
        if let p = photo {
            if p.emptyImage {
                if nil == loadingError {
                    loadingError = UIImageView()
                    loadingError!.image = UIImage.imageForResourcePath(
                        "MWPhotoBrowserSwift.bundle/ImageError",
                        ofType: "png",
                        inBundle: NSBundle(forClass: ZoomingScrollView.self))
                    
                    loadingError!.userInteractionEnabled = false
                    loadingError!.autoresizingMask =
                        [.FlexibleLeftMargin, .FlexibleTopMargin, .FlexibleBottomMargin, .FlexibleRightMargin]
                    
                    loadingError!.sizeToFit()
                    addSubview(loadingError!)
                }
                
                loadingError!.frame = CGRectMake(
                    floorcgf((bounds.size.width - loadingError!.frame.size.width) / 2.0),
                    floorcgf((bounds.size.height - loadingError!.frame.size.height) / 2.0),
                    loadingError!.frame.size.width,
                    loadingError!.frame.size.height)
            }
        }
    }

    private func hideImageFailure() {
        if let e = loadingError {
            e.removeFromSuperview()
            loadingError = nil
        }
    }

    //MARK: - Loading Progress

    public func setProgressFromNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            let dict = notification.object as! [String : AnyObject]
            
            if let photoWithProgress = dict["photo"] as? Photo,
                let p = self.photo, photoWithProgress.equals(p)
            {
                if let progress = dict["progress"] as? Float {
                    self.loadingIndicator.progress = CGFloat(max(min(1.0, progress), 0.0))
                }
            }
        }
    }

    private func hideLoadingIndicator() {
        loadingIndicator.hidden = true
    }

    private func showLoadingIndicator() {
        zoomScale = 0.1
        minimumZoomScale = 0.1
        maximumZoomScale = 0.1
        loadingIndicator.progress = 0.0
        loadingIndicator.hidden = false
        
        hideImageFailure()
    }

    //MARK: - Setup

    private func initialZoomScaleWithMinScale() -> CGFloat {
        var zoomScale = minimumZoomScale
        if let pb = photoBrowser, pb.zoomPhotosToFill {
            // Zoom image to fill if the aspect ratios are fairly similar
            let boundsSize = self.bounds.size
            let imageSize = photoImageView.image != nil ? photoImageView.image!.size : CGSizeMake(0.0, 0.0)
            let boundsAR = boundsSize.width / boundsSize.height
            let imageAR = imageSize.width / imageSize.height
            let xScale = boundsSize.width / imageSize.width    // the scale needed to perfectly fit the image width-wise
            let yScale = boundsSize.height / imageSize.height  // the scale needed to perfectly fit the image height-wise
            
            // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
            if (abs(boundsAR - imageAR) < 0.17) {
                zoomScale = max(xScale, yScale)
                // Ensure we don't zoom in or out too far, just in case
                zoomScale = min(max(minimumZoomScale, zoomScale), maximumZoomScale)
            }
        }
        
        return zoomScale
    }

    func setMaxMinZoomScalesForCurrentBounds() {
        // Reset
        maximumZoomScale = 1.0
        minimumZoomScale = 1.0
        zoomScale = 1.0
        
        // Bail if no image
        if photoImageView.image == nil {
            return
        }
        
        // Reset position
        photoImageView.frame = CGRectMake(0, 0, photoImageView.frame.size.width, photoImageView.frame.size.height)
        
        // Sizes
        let boundsSize = self.bounds.size
        let imageSize = photoImageView.image!.size
        
        // Calculate Min
        let xScale = boundsSize.width / imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = boundsSize.height / imageSize.height  // the scale needed to perfectly fit the image height-wise
        var minScale = min(xScale, yScale)                 // use minimum of these to allow the image to become fully visible
        
        // Calculate Max
        var maxScale = 3.0
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
            // Let them go a bit bigger on a bigger screen!
            maxScale = 4.0
        }
        
        // Image is smaller than screen so no zooming!
        if xScale >= 1.0 && yScale >= 1.0 {
            minScale = 1.0
        }
        
        // Set min/max zoom
        maximumZoomScale = CGFloat(maxScale)
        minimumZoomScale = CGFloat(minScale)
        
        // Initial zoom
        zoomScale = initialZoomScaleWithMinScale()
        
        // If we're zooming to fill then centralise
        if zoomScale != minScale {
            // Centralise
            contentOffset = CGPointMake((imageSize.width * zoomScale - boundsSize.width) / 2.0,
                                        (imageSize.height * zoomScale - boundsSize.height) / 2.0)
        }
        
        // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
        scrollEnabled = false
        
        // If it's a video then disable zooming
        if displayingVideo() {
            maximumZoomScale = zoomScale
            minimumZoomScale = zoomScale
        }

        // Layout
        setNeedsLayout()
    }

    //MARK: - Layout

    public override func layoutSubviews() {
        // Update tap view frame
        tapView.frame = bounds
        
        // Position indicators (centre does not seem to work!)
        if !loadingIndicator.hidden {
            loadingIndicator.frame = CGRectMake(
                floorcgf((bounds.size.width - loadingIndicator.frame.size.width) / 2.0),
                floorcgf((bounds.size.height - loadingIndicator.frame.size.height) / 2.0),
                loadingIndicator.frame.size.width,
                loadingIndicator.frame.size.height)
        }
        
        if let le = loadingError {
            le.frame = CGRectMake(
                floorcgf((bounds.size.width - le.frame.size.width) / 2.0),
                floorcgf((bounds.size.height - le.frame.size.height) / 2.0),
                le.frame.size.width,
                le.frame.size.height)
        }
    
        // Super
        super.layoutSubviews()
        
        // Center the image as it becomes smaller than the size of the screen
        let boundsSize = bounds.size
        var frameToCenter = photoImageView.frame
        
        // Horizontally
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = floorcgf((boundsSize.width - frameToCenter.size.width) / 2.0)
        }
        else {
            frameToCenter.origin.x = 0.0
        }
        
        // Vertically
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = floorcgf((boundsSize.height - frameToCenter.size.height) / 2.0)
        }
        else {
            frameToCenter.origin.y = 0.0
        }
        
        // Center
        if !CGRectEqualToRect(photoImageView.frame, frameToCenter) {
            photoImageView.frame = frameToCenter
        }
    }
    
    //MARK: - UIScrollViewDelegate

    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }

    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        photoBrowser.cancelControlHiding()
    }

    public func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
        scrollEnabled = true // reset
        photoBrowser.cancelControlHiding()
    }

    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        photoBrowser.hideControlsAfterDelay()
    }

    public func scrollViewDidZoom(scrollView: UIScrollView) {
        setNeedsLayout()
        layoutIfNeeded()
    }

    //MARK: - Tap Detection

    private func handleSingleTap(touchPoint: CGPoint) {
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue())
        {
            self.photoBrowser.toggleControls()
        }
    }

    private func handleDoubleTap(touchPoint: CGPoint) {
        // Dont double tap to zoom if showing a video
        if displayingVideo() {
            return
        }
        
        // Cancel any single tap handling
        NSObject.cancelPreviousPerformRequestsWithTarget(photoBrowser)
        
        // Zoom
        if zoomScale != minimumZoomScale && zoomScale != initialZoomScaleWithMinScale() {
            // Zoom out
            setZoomScale(minimumZoomScale, animated: true)
        }
        else {
            // Zoom in to twice the size
            let newZoomScale = ((maximumZoomScale + minimumZoomScale) / 2.0)
            let xsize = bounds.size.width / newZoomScale
            let ysize = bounds.size.height / newZoomScale
            zoomToRect(CGRectMake(touchPoint.x - xsize / 2.0, touchPoint.y - ysize / 2.0, xsize, ysize), animated: true)
        }
        
        // Delay controls
        photoBrowser.hideControlsAfterDelay()
    }

    // Image View
    public func singleTapDetectedInImageView(view: UIImageView, touch: UITouch) {
        handleSingleTap(touch.locationInView(view))
    }
    
    public func doubleTapDetectedInImageView(view: UIImageView, touch: UITouch) {
        handleDoubleTap(touch.locationInView(view))
    }
    
    public func tripleTapDetectedInImageView(view: UIImageView, touch: UITouch) {
        
    }

    // Background View
    public func singleTapDetectedInView(view: UIView, touch: UITouch) {
        // Translate touch location to image view location
        var touchX = touch.locationInView(view).x
        var touchY = touch.locationInView(view).y
        touchX *= 1.0 / self.zoomScale
        touchY *= 1.0 / self.zoomScale
        touchX += self.contentOffset.x
        touchY += self.contentOffset.y
        
        handleSingleTap(CGPointMake(touchX, touchY))
    }
    
    public func doubleTapDetectedInView(view: UIView, touch: UITouch) {
        // Translate touch location to image view location
        var touchX = touch.locationInView(view).x
        var touchY = touch.locationInView(view).y
        touchX *= 1.0 / self.zoomScale
        touchY *= 1.0 / self.zoomScale
        touchX += self.contentOffset.x
        touchY += self.contentOffset.y
        
        handleDoubleTap(CGPointMake(touchX, touchY))
    }
    
    public func tripleTapDetectedInView(view: UIView, touch: UITouch) {
        
    }
}
