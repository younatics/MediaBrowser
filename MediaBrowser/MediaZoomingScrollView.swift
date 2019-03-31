	//
//  MediaZoomingScrollView.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//

import UIKit
import UICircularProgressRing

class MediaZoomingScrollView: UIScrollView, UIScrollViewDelegate, TapDetectingImageViewDelegate, TapDetectingViewDelegate {
    var index = 0
    var media: Media?
    weak var captionView: MediaCaptionView?
    weak var selectedButton: UIButton?
    weak var playButton: UIButton?
    var loadingIndicator = UICircularProgressRing(frame: CGRect(x: 140, y: 30, width: 40, height: 40))
    
    weak var mediaBrowser: MediaBrowser!
    var tapView = MediaTapDetectingView(frame: .zero) // for background taps
    var photoImageView = MediaTapDetectingImageView(frame: .zero)
    var loadingError: UIImageView?
    
    init(mediaBrowser: MediaBrowser) {
        super.init(frame: .zero)
        
        // Setup
        index = Int.max
        self.mediaBrowser = mediaBrowser
        
        // Tap view for background
        tapView = MediaTapDetectingView(frame: bounds)
        tapView.tapDelegate = self
        tapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tapView.backgroundColor = .clear
        addSubview(tapView)
        
        // Image view
        photoImageView.tapDelegate = self
        photoImageView.contentMode = .center
        photoImageView.backgroundColor = .clear
        addSubview(photoImageView)
        
        // Loading indicator
        loadingIndicator.isUserInteractionEnabled = false
        loadingIndicator.autoresizingMask =
            [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        loadingIndicator.style = .ontop
        loadingIndicator.innerRingColor = UIColor.white
        loadingIndicator.outerRingColor = UIColor.gray
        loadingIndicator.innerRingWidth = 1
        loadingIndicator.outerRingWidth = 1

        addSubview(loadingIndicator)
        
        // Listen progress notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setProgressFromNotification),
            name: NSNotification.Name(rawValue: MEDIA_PROGRESS_NOTIFICATION),
            object: nil)
        
        // Setup
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        decelerationRate = UIScrollView.DecelerationRate.fast
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        media?.cancelAnyLoading()
        NotificationCenter.default.removeObserver(self)
    }
    
    func prepareForReuse() {
        hideImageFailure()
//        photo = nil
        captionView = nil
        selectedButton = nil
        playButton = nil
        photoImageView.isHidden = false
        if let placeholder = self.mediaBrowser.placeholderImage, placeholder.isAppliedForAll || (!placeholder.isAppliedForAll && self.index == self.mediaBrowser.currentIndex) {
            photoImageView.image = self.mediaBrowser.placeholderImage?.image
        } else {
            photoImageView.image = nil
        }
        photoImageView.alpha = 0.8
        index = Int.max
    }
    
    func displayingVideo() -> Bool {
        return photo?.isVideo ?? false
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
            photoImageView.isHidden = hidden
        }
        
        get {
            return photoImageView.isHidden
        }
    }
    
    //MARK: - Image
    
    var photo: Media? {
        set(p) {
            // Cancel any loading on old photo
            if media != nil && p == nil {
                media!.cancelAnyLoading()
            }
            media = p
            if let image = mediaBrowser.image(for: media), image !== mediaBrowser.placeholderImage?.image {
                self.displayImage()
            } else {
                // Will be loading so show loading
                self.showLoadingIndicator()
            }
        }
        
        get {
            return media
        }
    }
    
    // Get and display image
    func displayImage() {
        if media != nil && (photoImageView.image == nil || photoImageView.image === self.mediaBrowser.placeholderImage?.image) {
            // Reset
            maximumZoomScale = 1.0
            minimumZoomScale = 1.0
            zoomScale = 1.0
            contentSize = CGSize.zero
            
            // Get image from browser as it handles ordering of fetching
            if let img = mediaBrowser.image(for: photo), img !== mediaBrowser.placeholderImage?.image {
                // Hide indicator
                hideLoadingIndicator()
                
                // Set image
                photoImageView.alpha = 1.0
                photoImageView.image = img
                photoImageView.isHidden = false
                
                // Setup photo frame
                let photoImageViewFrame = CGRect(origin: CGPoint.zero, size: img.size)
                photoImageView.frame = photoImageViewFrame
                contentSize = photoImageViewFrame.size
                
                // Set zoom to minimum zoom
                setMaxMinZoomScalesForCurrentBounds()
                
            } else {
                // Show image failure
                displayImageFailure()
            }
            
            setNeedsLayout()
        }
    }
    
    // Image failed so just show grey!
    func displayImageFailure() {
        hideLoadingIndicator()
        if let placeholder = self.mediaBrowser.placeholderImage, placeholder.isAppliedForAll || (!placeholder.isAppliedForAll && self.index == self.mediaBrowser.currentIndex) {
            photoImageView.image = self.mediaBrowser.placeholderImage?.image
        } else {
            photoImageView.image = nil
        }
        photoImageView.alpha = 0.8
        
        // Show if image is not empty
        if let p = photo {
            if p.emptyImage {
                if nil == loadingError {
                    loadingError = UIImageView()
                    loadingError!.image = UIImage.imageForResourcePath(
                        name: "ImageError",
                        inBundle: Bundle(for: MediaZoomingScrollView.self))
                    
                    loadingError!.isUserInteractionEnabled = false
                    loadingError!.autoresizingMask =
                        [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
                    
                    loadingError!.sizeToFit()
                    addSubview(loadingError!)
                }
                
                loadingError!.frame = CGRect(
                    x: floorcgf(x: (bounds.size.width - loadingError!.frame.size.width) / 2.0),
                    y: floorcgf(x: (bounds.size.height - loadingError!.frame.size.height) / 2.0),
                    width: loadingError!.frame.size.width,
                    height: loadingError!.frame.size.height)
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
    
    @objc public func setProgressFromNotification(notification: NSNotification) {
        DispatchQueue.main.async() {
            let dict = notification.object as! [String : AnyObject]
            
            if let photoWithProgress = dict["photo"] as? Media, let progress = dict["progress"] as? CGFloat, let p = self.photo, photoWithProgress.equals(photo: p) {
                self.loadingIndicator.startProgress(to: progress * 100, duration: 0.1)
            }
        }
    }
    
    private func hideLoadingIndicator() {
        loadingIndicator.isHidden = true
    }
    
    private func showLoadingIndicator() {
        zoomScale = 0.0
        minimumZoomScale = 0.0
        maximumZoomScale = 0.0
        loadingIndicator.startProgress(to: 0.0, duration: 0)
        loadingIndicator.isHidden = false
        
        hideImageFailure()
    }
    
    //MARK: - Setup
    
    private func initialZoomScaleWithMinScale() -> CGFloat {
        var zoomScale = minimumZoomScale
        if let pb = mediaBrowser,let image = photoImageView.image, pb.zoomPhotosToFill {
            // Zoom image to fill if the aspect ratios are fairly similar
            let boundsSize = self.bounds.size
            let imageSize = image.size
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
        
        guard let image = photoImageView.image else { return }
        
        // Reset position
        photoImageView.frame = CGRect(x: 0, y: 0, width: photoImageView.frame.size.width, height: photoImageView.frame.size.height)
        
        // Sizes
        let boundsSize = self.bounds.size
        let imageSize = image.size
        
        // Calculate Min
        let xScale = boundsSize.width / imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = boundsSize.height / imageSize.height  // the scale needed to perfectly fit the image height-wise
        var minScale:CGFloat = min(xScale, yScale)                 // use minimum of these to allow the image to become fully visible
        
        // Calculate Max
        var maxScale: CGFloat = 3.0
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            // Let them go a bit bigger on a bigger screen!
            maxScale = 4.0
        }
        
        // Image is smaller than screen so no zooming!
        if xScale >= 1.0 && yScale >= 1.0 {
            minScale = 1.0
        }
        
        // Set min/max zoom
        maximumZoomScale = maxScale
        minimumZoomScale = minScale
        
        // Initial zoom
        zoomScale = initialZoomScaleWithMinScale()
        
        // If we're zooming to fill then centralise
        if zoomScale != minScale {
            // Centralise
            contentOffset = CGPoint(x: (imageSize.width * zoomScale - boundsSize.width) / 2.0, y: (imageSize.height * zoomScale - boundsSize.height) / 2.0)
        }
        
        // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
        isScrollEnabled = false
        
        // If it's a video then disable zooming
        if displayingVideo() {
            maximumZoomScale = zoomScale
            minimumZoomScale = zoomScale
        }
        
        // Layout
        setNeedsLayout()
    }
    
    //MARK: - Layout
    
    override func layoutSubviews() {
        // Update tap view frame
        tapView.frame = bounds
        
        // Position indicators (centre does not seem to work!)
        if !loadingIndicator.isHidden {
            loadingIndicator.frame = CGRect(
                x: floorcgf(x: (bounds.size.width - loadingIndicator.frame.size.width) / 2.0),
                y: floorcgf(x: (bounds.size.height - loadingIndicator.frame.size.height) / 2.0),
                width: loadingIndicator.frame.size.width,
                height: loadingIndicator.frame.size.height)
        }
        
        if let le = loadingError {
            le.frame = CGRect(
                x: floorcgf(x: (bounds.size.width - le.frame.size.width) / 2.0),
                y: floorcgf(x: (bounds.size.height - le.frame.size.height) / 2.0),
                width: le.frame.size.width,
                height: le.frame.size.height)
        }
        
        // Super
        super.layoutSubviews()
        
        self.alignCenterMedia()
    }

    func alignCenterMedia() {

        // Center the image as it becomes smaller than the size of the screen
        let boundsSize = bounds.size
        var frameToCenter = photoImageView.frame

        // Horizontally
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = floorcgf(x: (boundsSize.width - frameToCenter.size.width) / 2.0)
        } else {
            frameToCenter.origin.x = 0.0
        }

        // Vertically
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = floorcgf(x: (boundsSize.height - frameToCenter.size.height) / 2.0)
        } else {
            frameToCenter.origin.y = 0.0
        }

        // Center
        if !photoImageView.frame.equalTo(frameToCenter) {
            photoImageView.frame = frameToCenter
        }
    }
    
    //MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        mediaBrowser.cancelControlHiding()
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        isScrollEnabled = true // reset
        mediaBrowser.cancelControlHiding()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        mediaBrowser.hideControlsAfterDelay()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    //MARK: - Tap Detection
    func handleSingleTap(touchPoint: CGPoint) {
        mediaBrowser.perform(#selector(MediaBrowser.toggleControls), with: nil, afterDelay: 0.2)
    }
    
    func handleDoubleTap(touchPoint: CGPoint) {
        // Dont double tap to zoom if showing a video
        if displayingVideo() {
            return
        }
        
        // Cancel any single tap handling
        NSObject.cancelPreviousPerformRequests(withTarget: mediaBrowser as Any)
        
        // Zoom
        if zoomScale != minimumZoomScale && zoomScale != initialZoomScaleWithMinScale() {
            // Zoom out
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            // Zoom in to twice the size
            let newZoomScale = ((maximumZoomScale + minimumZoomScale) / 2.0)
            let xsize = bounds.size.width / newZoomScale
            let ysize = bounds.size.height / newZoomScale
            zoom(to: CGRect(x: touchPoint.x - xsize / 2.0, y: touchPoint.y - ysize / 2.0, width: xsize, height: ysize), animated: true)
        }
        
        // Delay controls
        mediaBrowser.hideControlsAfterDelay()
    }
    
    // Image View
    func singleTapDetectedInImageView(view: UIImageView, touch: UITouch) {
        handleSingleTap(touchPoint: touch.location(in: view))
    }
    
    func doubleTapDetectedInImageView(view: UIImageView, touch: UITouch) {
        handleDoubleTap(touchPoint: touch.location(in: view))
    }
    
    func tripleTapDetectedInImageView(view: UIImageView, touch: UITouch) {
        
    }
    
    // Background View
    func singleTapDetectedInView(view: UIView, touch: UITouch) {
        // Translate touch location to image view location
        var touchX = touch.location(in: view).x
        var touchY = touch.location(in: view).y
        touchX *= 1.0 / self.zoomScale
        touchY *= 1.0 / self.zoomScale
        touchX += self.contentOffset.x
        touchY += self.contentOffset.y
        
        handleSingleTap(touchPoint: CGPoint(x: touchX, y: touchY))
    }
    
    func doubleTapDetectedInView(view: UIView, touch: UITouch) {
        // Translate touch location to image view location
        var touchX = touch.location(in: view).x
        var touchY = touch.location(in: view).y
        touchX *= 1.0 / self.zoomScale
        touchY *= 1.0 / self.zoomScale
        touchX += self.contentOffset.x
        touchY += self.contentOffset.y
        
        handleDoubleTap(touchPoint: CGPoint(x: touchX, y: touchY))
    }
    
    func tripleTapDetectedInView(view: UIView, touch: UITouch) {
        
    }
}
