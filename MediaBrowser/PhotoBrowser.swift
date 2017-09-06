//
//  PhotoBrowser.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//

import UIKit
import MBProgressHUD
import MediaPlayer
import QuartzCore
import MBProgressHUD
import MapleBacon

func floorcgf(x: CGFloat) -> CGFloat {
    return CGFloat(floorf(Float(x)))
}

public class PhotoBrowser: UIViewController, UIScrollViewDelegate, UIActionSheetDelegate {
    private let padding = CGFloat(10.0)

    // Data
    private var photoCount = -1
    private var photos = [Photo?]()
    private var thumbPhotos = [Photo?]()
	private var fixedPhotosArray: [Photo]? // Provided via init
	
	// Views
	private var pagingScrollView = UIScrollView()
	
	// Paging & layout
	private var visiblePages = Set<ZoomingScrollView>()
    private var recycledPages = Set<ZoomingScrollView>()
	private var currentPageIndex = 0
    private var previousPageIndex = Int.max
    private var previousLayoutBounds = CGRect.zero
	private var pageIndexBeforeRotation = 0
	
	// Navigation & controls
	private var toolbar = UIToolbar()
	private var controlVisibilityTimer: Timer?
	private var previousButton: UIBarButtonItem?
    private var nextButton: UIBarButtonItem?
    private var actionButton: UIBarButtonItem?
    private var doneButton: UIBarButtonItem?
    
    // Grid
    private var gridController: GridViewController?
    private var gridPreviousLeftNavItem: UIBarButtonItem?
    private var gridPreviousRightNavItem: UIBarButtonItem?
    
    // Appearance
    public var previousNavBarHidden = false
    public var previousNavBarTranslucent = false
    public var previousNavBarStyle = UIBarStyle.default
    public var previousStatusBarStyle = UIStatusBarStyle.default
    public var previousNavBarTintColor: UIColor?
    public var previousNavBarBarTintColor: UIColor?
    public var previousViewControllerBackButton: UIBarButtonItem?
    public var previousNavigationBarBackgroundImageDefault: UIImage?
    public var previousNavigationBarBackgroundImageLandscapePhone: UIImage?
    
    // Video
    var currentVideoPlayerViewController: MPMoviePlayerViewController?
    var currentVideoIndex = 0
    var currentVideoLoadingIndicator: UIActivityIndicatorView?
    
    // Misc
    public var hasBelongedToViewController = false
    public var isVCBasedStatusBarAppearance = false
    public var statusBarShouldBeHidden = false
    public var displayActionButton = true
    public var leaveStatusBarAlone = false
	public var performingLayout = false
	public var rotating = false
    public var viewIsActive = false // active as in it's in the view heirarchy
    public var didSavePreviousStateOfNavBar = false
    public var skipNextPagingScrollViewPositioning = false
    public var viewHasAppearedInitially = false
    public var currentGridContentOffset = CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude)
    
    var activityViewController: UIActivityViewController?
    
    public weak var delegate: PhotoBrowserDelegate?
    public var zoomPhotosToFill = true
    public var displayNavArrows = false
    public var displaySelectionButtons = false
    public var alwaysShowControls = false
    public var enableGrid = true
    public var enableSwipeToDismiss = true
    public var startOnGrid = false
    public var autoPlayOnAppear = false
    public var hideControlsOnStartup = false
    public var delayToHideElements = TimeInterval(5.0)
    
    public var navBarTintColor = UIColor.black
    public var navBarBarTintColor = UIColor.black
    public var navBarTranslucent = true
    public var toolbarTintColor = UIColor.black
    public var toolbarBarTintColor = UIColor.white
    public var toolbarBackgroundColor = UIColor.white
    
    public var captionAlpha = CGFloat(0.5)
    public var toolbarAlpha = CGFloat(0.8)
    
    // Customise image selection icons as they are the only icons with a colour tint
    // Icon should be located in the app's main bundle
    public var customImageSelectedIconName = ""
    public var customImageSelectedSmallIconName = ""
    
    //MARK: - Init
    
    public override init(nibName: String?, bundle nibBundle: Bundle?) {
        super.init(nibName: nibName, bundle: nibBundle)
        initialisation()
    }
    
    public convenience init(delegate: PhotoBrowserDelegate) {
        self.init()
        self.delegate = delegate
        initialisation()
    }

    public convenience init(photos: [Photo]) {
        self.init()
        fixedPhotosArray = photos
        initialisation()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialisation()
    }

    private func initialisation() {
        // Defaults
        if let vcBasedStatusBarAppearance = Bundle.main
            .object(forInfoDictionaryKey: "UIViewControllerBasedStatusBarAppearance") as? Bool
        {
           isVCBasedStatusBarAppearance = vcBasedStatusBarAppearance
        }
        else {
            isVCBasedStatusBarAppearance = true // default
        }
        
        
        hidesBottomBarWhenPushed = true
        automaticallyAdjustsScrollViewInsets = false
        extendedLayoutIncludesOpaqueBars = true
        
        navigationController?.view.backgroundColor = UIColor.white
        
        // Listen for MWPhoto falsetifications
        NotificationCenter.defaultCenter.addObserver(
            self,
            selector: Selector("handlePhotoLoadingDidEndNotification:"),
            name: MWPHOTO_LOADING_DID_END_NOTIFICATION,
            object: nil)
    }

    deinit {
        clearCurrentVideo()
        pagingScrollView.delegate = nil
        NotificationCenter.default.removeObserver(self)
        releaseAllUnderlyingPhotos(preserveCurrent: false)
        MapleBaconStorage.sharedStorage.clearMemoryStorage() // clear memory
    }

    private func releaseAllUnderlyingPhotos(preserveCurrent: Bool) {
        // Create a copy in case this array is modified while we are looping through
        // Release photos
        var copy = photos
        for p in copy {
            if let ph = p {
                if let paci = photoAtIndex(index: currentIndex) {
                    if preserveCurrent && ph.equals(photo: paci) {
                        continue // skip current
                    }
                }
                
                ph.unloadUnderlyingImage()
            }
        }
        
        // Release thumbs
        copy = thumbPhotos
        for p in copy {
            if let ph = p {
                ph.unloadUnderlyingImage()
            }
        }
    }

    public override func didReceiveMemoryWarning() {
        // Release any cached data, images, etc that aren't in use.
        releaseAllUnderlyingPhotos(preserveCurrent: true)
        recycledPages.removeAll(keepingCapacity: false)
        
        // Releases the view if it doesn't have a superview.
        super.didReceiveMemoryWarning()
    }

    //MARK: - View Loading

    // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
    public override dynamic func viewDidLoad() {
        // Validate grid settings
        if startOnGrid {
            enableGrid = true
        }
        
        //if enableGrid {
        //    enableGrid = [delegate respondsToSelector:Selector("photoBrowser:thumbPhotoAtIndex:)]
        //}
        
        if !enableGrid {
            startOnGrid = false
        }
        
        // View
        navigationController?.navigationBar.backgroundColor = UIColor.white
        
        view.backgroundColor = UIColor.white
        view.clipsToBounds = true
        
        // Setup paging scrolling view
        let pagingScrollViewFrame = frameForPagingScrollView
        pagingScrollView = UIScrollView(frame: pagingScrollViewFrame)
        pagingScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pagingScrollView.isPagingEnabled = true
        pagingScrollView.delegate = self
        pagingScrollView.showsHorizontalScrollIndicator = false
        pagingScrollView.showsVerticalScrollIndicator = false
        pagingScrollView.backgroundColor = UIColor.white
        pagingScrollView.contentSize = contentSizeForPagingScrollView()
        view.addSubview(pagingScrollView)
        
        // Toolbar
        toolbar = UIToolbar(frame: frameForToolbar)
        toolbar.tintColor = toolbarTintColor
        toolbar.barTintColor = toolbarBarTintColor
        toolbar.backgroundColor = toolbarBackgroundColor
        toolbar.alpha = 0.8
        toolbar.setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .default)
        toolbar.setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .compact)
        toolbar.barStyle = .default
        toolbar.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        
        // Toolbar Items
        if displayNavArrows {
            let arrowPathFormat = "MWPhotoBrowserSwift.bundle/UIBarButtonItemArrow"
            
            let previousButtonImage = UIImage.imageForResourcePath(
                path: arrowPathFormat + "Left",
                ofType: "png",
                inBundle: Bundle(for: PhotoBrowser.self))
            
            let nextButtonImage = UIImage.imageForResourcePath(
                path: arrowPathFormat + "Right",
                ofType: "png",
                inBundle: Bundle(for: PhotoBrowser.self))
            
            previousButton = UIBarButtonItem(
                image: previousButtonImage,
                style: UIBarButtonItemStyle.plain,
                target: self,
                action: Selector("gotoPreviousPage"))
            
            nextButton = UIBarButtonItem(
                image: nextButtonImage,
                style: UIBarButtonItemStyle.plain,
                target: self,
                action: Selector("gotoNextPage"))
        }
        
        if displayActionButton {
            actionButton = UIBarButtonItem(
                barButtonSystemItem: UIBarButtonSystemItem.action,
                target: self,
                action: Selector("actionButtonPressed:"))
        }
        
        // Update
        reloadData()
        
        // Swipe to dismiss
        if enableSwipeToDismiss {
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: Selector("doneButtonPressed:"))
            swipeGesture.direction = [.down, .up]
            view.addGestureRecognizer(swipeGesture)
        }
        
        // Super
        super.viewDidLoad()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in
            self.toolbar.frame = self.frameForToolbar
        }
        
        super.viewWillTransition(to: size, with: coordinator)

    }
    
    func performLayout() {
        // Setup
        performingLayout = true
        let photos = numberOfPhotos
        
        // Setup pages
        visiblePages.removeAll()
        recycledPages.removeAll()
        
        // Navigation buttons
        if let navi = navigationController {
            if navi.viewControllers.count > 0 &&
               navi.viewControllers[0] == self
            {
                // We're first on stack so show done button
                doneButton = UIBarButtonItem(
                    barButtonSystemItem: UIBarButtonSystemItem.done,
                    target: self,
                    action: Selector("doneButtonPressed:"))
                
                // Set appearance
                if let done = doneButton {
                    done.setBackgroundImage(nil, for: .Normal, barMetrics: .default)
                    done.setBackgroundImage(nil, for: .Normal, barMetrics: .compact)
                    done.setBackgroundImage(nil, for: .highlighted, barMetrics: .default)
                    done.setBackgroundImage(nil, for: .highlighted, barMetrics: .compact)
                    done.setTitleTextAttributes([String : AnyObject](), for: .Normal)
                    done.setTitleTextAttributes([String : AnyObject](), for: .highlighted)
                    
                    self.navigationItem.rightBarButtonItem = done
                }
            }
            else {
                // We're not first so show back button
                if let navi = navigationController,
                    let previousViewController = navi.viewControllers[navi.viewControllers.count - 2] as? UINavigationController
                {
                    let backButtonTitle = previousViewController.navigationItem.backBarButtonItem != nil ?
                        previousViewController.navigationItem.backBarButtonItem!.title :
                        previousViewController.title
                    
                    let newBackButton = UIBarButtonItem(title: backButtonTitle, style: .plain, target: nil, action: nil)
                    
                    // Appearance
                    newBackButton.setBackButtonBackgroundImage(nil, for: .Normal, barMetrics: .default)
                    newBackButton.setBackButtonBackgroundImage(nil, for: .Normal, barMetrics: .compact)
                    newBackButton.setBackButtonBackgroundImage(nil, for: .highlighted, barMetrics: .default)
                    newBackButton.setBackButtonBackgroundImage(nil, for: .highlighted, barMetrics: .compact)
                    newBackButton.setTitleTextAttributes([String : AnyObject](), for: .Normal)
                    newBackButton.setTitleTextAttributes([String : AnyObject](), for: .highlighted)
                    
                    previousViewControllerBackButton = previousViewController.navigationItem.backBarButtonItem // remember previous
                    previousViewController.navigationItem.backBarButtonItem = newBackButton
                }
            }
        }

        // Toolbar items
        var hasItems = false
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        fixedSpace.width = 32.0 // To balance action button
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        var items = [UIBarButtonItem]()

        // Left button - Grid
        if enableGrid {
            hasItems = true
            
            items.append(UIBarButtonItem(
                image: UIImage.imageForResourcePath(path: "MWPhotoBrowserSwift.bundle/UIBarButtonItemGrid",
                    ofType: "png",
                    inBundle: Bundle(for: PhotoBrowser.self)),
                style: .plain,
                target: self,
                action: Selector("showGridAnimated")))
        }
        else {
            items.append(fixedSpace)
        }

        // Middle - Nav
        if previousButton != nil && nextButton != nil && photos > 1 {
            hasItems = true
            
            items.append(flexSpace)
            items.append(previousButton!)
            items.append(flexSpace)
            items.append(nextButton!)
            items.append(flexSpace)
        }
        else {
            items.append(flexSpace)
        }

        // Right - Action
        if actionButton != nil && !(!hasItems && nil == navigationItem.rightBarButtonItem) {
            items.append(actionButton!)
        }
        else {
            // We're falset showing the toolbar so try and show in top right
            if actionButton != nil {
                navigationItem.rightBarButtonItem = actionButton!
            }
            items.append(fixedSpace)
        }

        // Toolbar visibility
        toolbar.setItems(items, animated: false)
        var hideToolbar = true
        
        for item in items {
            if item != fixedSpace && item != flexSpace {
                hideToolbar = false
                break
            }
        }
        
        if hideToolbar {
            toolbar.removeFromSuperview()
        }
        else {
            view.addSubview(toolbar)
        }
        
        // Update nav
        updateNavigation()
        
        // Content offset
        pagingScrollView.contentOffset = contentOffsetForPageAtIndex(index: currentPageIndex)
        tilePages()
        performingLayout = false
    }

    var presentingViewControllerPrefersStatusBarHidden: Bool {
        var presenting = presentingViewController
        if let p = presenting as? UINavigationController {
            presenting = p.topViewController
        }
        else {
            // We're in a navigation controller so get previous one!
            if let navi = navigationController, navi.viewControllers.count > 1 {
                presenting = navi.viewControllers[navi.viewControllers.count - 2]
            }
        }
        
        if let pres = presenting {
            return pres.prefersStatusBarHidden
        }
        
        return false
    }

    //MARK: - Appearance

    public override dynamic func viewWillAppear(_ animated: Bool) {
        // Super
        super.viewWillAppear(animated)
        
        // Status bar
        if !viewHasAppearedInitially {
            leaveStatusBarAlone = presentingViewControllerPrefersStatusBarHidden
            // Check if status bar is hidden on first appear, and if so then ignore it
            if UIApplication.shared.statusBarFrame.equalTo(CGRect.zero) {
                leaveStatusBarAlone = true
            }
        }
        // Set style
        if !leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            previousStatusBarStyle = UIApplication.shared.statusBarStyle
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: animated)
        }
        
        // Navigation bar appearance
        if !viewIsActive && navigationController?.viewControllers[0] as? PhotoBrowser !== self {
            storePreviousNavBarAppearance()
        }
        
        setNavBarAppearance(animated: animated)
        
        // Update UI
        if hideControlsOnStartup {
            hideControls()
        }
        else {
            hideControlsAfterDelay()
        }
        
        // Initial appearance
        if !viewHasAppearedInitially && startOnGrid {
            showGrid(animated: false)
        }
        
        // If rotation occured while we're presenting a modal
        // and the index changed, make sure we show the right one falsew
        if currentPageIndex != pageIndexBeforeRotation {
            jumpToPageAtIndex(index: pageIndexBeforeRotation, animated: false)
        }
    }

    public override dynamic func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewIsActive = true
        
        // Autoplay if first is video
        if !viewHasAppearedInitially && autoPlayOnAppear {
            if let photo = photoAtIndex(index: currentPageIndex) {
                if photo.isVideo {
                    playVideoAtIndex(index: currentPageIndex)
                }
            }
        }
        
        viewHasAppearedInitially = true
    }

    public override dynamic func viewWillDisappear(_ animated: Bool) {
        // Detect if rotation occurs while we're presenting a modal
        pageIndexBeforeRotation = currentPageIndex
        
        // Check that we're being popped for good
        if let viewControllers = navigationController?.viewControllers, viewControllers[0] !== self
        {
            var selfFound = false
        
            for vc in viewControllers {
                if vc === self {
                    selfFound = true
                    break;
                }
            }
            
            if !selfFound {
                // State
                viewIsActive = false
                
                // Bar state / appearance
                restorePreviousNavBarAppearance(animated: animated)
            }
        }
        
        // Controls
        navigationController?.navigationBar.layer.removeAllAnimations() // Stop all animations on nav bar
        
        NSObject.cancelPreviousPerformRequests(withTarget: self) // Cancel any pending toggles from taps
        setControlsHidden(hidden: false, animated: false, permanent: true)
        
        // Status bar
        if !leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            UIApplication.shared.setStatusBarStyle(previousStatusBarStyle, animated: animated)
        }
        
        // Super
        super.viewWillDisappear(animated)
    }

    public override func willMove(toParentViewController parent: UIViewController?) {
        if parent != nil && hasBelongedToViewController {
            fatalError("PhotoBrowser Instance Reuse")
        }
    }

    public override func didMovetoParentViewControllerToParentViewController(_ parent: UIViewController?) {
        if nil == parent {
            hasBelongedToViewController = true
        }
    }

    //MARK: - Nav Bar Appearance

    func setNavBarAppearance(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    
        if let navBar = navigationController?.navigationBar {
            navBar.backgroundColor = navBarBarTintColor
            navBar.tintColor = navBarTintColor
            navBar.barTintColor = navBarBarTintColor
            navBar.shadowImage = nil
            navBar.isTranslucent = navBarTranslucent
            navBar.barStyle = .default
            navBar.setBackgroundImage(nil, for: .default)
            navBar.setBackgroundImage(nil, for: .compact)
        }
    }

    func storePreviousNavBarAppearance() {
        didSavePreviousStateOfNavBar = true
        
        if let navi = navigationController {
            previousNavBarBarTintColor = navi.navigationBar.barTintColor
            previousNavBarTranslucent = navi.navigationBar.isTranslucent
            previousNavBarTintColor = navi.navigationBar.tintColor
            previousNavBarHidden = navi.isNavigationBarHidden
            previousNavBarStyle = navi.navigationBar.barStyle
            previousNavigationBarBackgroundImageDefault = navi.navigationBar.backgroundImage(for: .default)
            previousNavigationBarBackgroundImageLandscapePhone = navi.navigationBar.backgroundImage(for: .compact)
        }
    }

    func restorePreviousNavBarAppearance(animated: Bool) {
        if let navi = navigationController, didSavePreviousStateOfNavBar {
            navi.setNavigationBarHidden(previousNavBarHidden, animated: animated)
            let navBar = navi.navigationBar
            navBar.tintColor = previousNavBarTintColor
            navBar.isTranslucent = previousNavBarTranslucent
            navBar.barTintColor = previousNavBarBarTintColor
            navBar.barStyle = previousNavBarStyle
            navBar.setBackgroundImage(previousNavigationBarBackgroundImageDefault, for: UIBarMetrics.default)
            navBar.setBackgroundImage(previousNavigationBarBackgroundImageLandscapePhone, for: UIBarMetrics.compact)

            // Restore back button if we need to
            if previousViewControllerBackButton != nil {
                if let previousViewController = navi.topViewController { // We've disappeared so previous is falsew top
                    previousViewController.navigationItem.backBarButtonItem = previousViewControllerBackButton
                }
                previousViewControllerBackButton = nil
            }
        }
    }

    //MARK: - Layout

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutVisiblePages()
    }

    func layoutVisiblePages() {
        // Flag
        performingLayout = true
        
        // Toolbar
        toolbar.frame = frameForToolbar
        
        // Remember index
        let indexPriorToLayout = currentPageIndex
        
        // Get paging scroll view frame to determine if anything needs changing
        let pagingScrollViewFrame = frameForPagingScrollView
        
        // Frame needs changing
        if !skipNextPagingScrollViewPositioning {
            pagingScrollView.frame = pagingScrollViewFrame
        }
        
        skipNextPagingScrollViewPositioning = false
        
        // Recalculate contentSize based on current orientation
        pagingScrollView.contentSize = contentSizeForPagingScrollView()
        
        // Adjust frames and configuration of each visible page
        for page in visiblePages {
            let index = page.index
            page.frame = frameForPageAtIndex(index: index)
            
            if let caption = page.captionView {
                caption.frame = frameForCaptionView(captionView: caption, index: index)
            }
            
            if let selected = page.selectedButton {
                selected.frame = frameForSelectedButton(selectedButton: selected, atIndex: index)
            }
            
            if let play = page.playButton {
                play.frame = frameForPlayButton(playButton: play, atIndex: index)
            }
            
            // Adjust scales if bounds has changed since last time
            if !previousLayoutBounds.equalTo(view.bounds) {
                // Update zooms for new bounds
                page.setMaxMinZoomScalesForCurrentBounds()
                previousLayoutBounds = view.bounds
            }
        }
        
        // Adjust video loading indicator if it's visible
        positionVideoLoadingIndicator()
        
        // Adjust contentOffset to preserve page location based on values collected prior to location
        pagingScrollView.contentOffset = contentOffsetForPageAtIndex(index: indexPriorToLayout)
        didStartViewingPageAtIndex(index: currentPageIndex) // initial
        
        // Reset
        currentPageIndex = indexPriorToLayout
        performingLayout = false
        
    }

    //MARK: - Rotation
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    public override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        // Remember page index before rotation
        pageIndexBeforeRotation = currentPageIndex
        rotating = true
        
        // In iOS 7 the nav bar gets shown after rotation, but might as well do this for everything!
        if areControlsHidden {
            // Force hidden
            navigationController?.isNavigationBarHidden = true
        }
    }

    public override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        // Perform layout
        currentPageIndex = pageIndexBeforeRotation
        
        // Delay control holding
        hideControlsAfterDelay()
        
        // Layout
        layoutVisiblePages()
    }

    public override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        rotating = false
        // Ensure nav bar isn't re-displayed
        if let navi = navigationController, areControlsHidden {
            navi.isNavigationBarHidden = false
            navi.navigationBar.alpha = 0
        }
    }

    //MARK: - Data

    var currentIndex: Int {
        return currentPageIndex
    }

    func reloadData() {
        // Reset
        photoCount = -1
        
        // Get data
        let photosNum = numberOfPhotos
        releaseAllUnderlyingPhotos(preserveCurrent: true)
        photos.removeAll()
        thumbPhotos.removeAll()
        
        for _ in 0...(photosNum - 1) {
            photos.append(nil)
            thumbPhotos.append(nil)
        }

        // Update current page index
        if numberOfPhotos > 0 {
            currentPageIndex = max(0, min(currentPageIndex, photosNum - 1))
        }
        else {
            currentPageIndex = 0
        }
        
        // Update layout
        if isViewLoaded {
            while pagingScrollView.subviews.count > 0 {
                pagingScrollView.subviews.last!.removeFromSuperview()
            }
            
            performLayout()
            view.setNeedsLayout()
        }
    }

    var numberOfPhotos: Int {
        if photoCount == -1 {
            if let d = delegate {
                photoCount = d.numberOfPhotosInPhotoBrowser(photoBrowser: self)
            }
            
            if let fpa = fixedPhotosArray {
                photoCount = fpa.count
            }
        }
        
        if -1 == photoCount {
            photoCount = 0
        }

        return photoCount
    }

    func photoAtIndex(index: Int) -> Photo? {
        var photo: Photo? = nil
        
        if index < photos.count {
            if photos[index] == nil {
                if let d = delegate {
                    photo = d.photoAtIndex(index: index, photoBrowser: self)
                    
                    if nil == photo && fixedPhotosArray != nil && index < fixedPhotosArray!.count {
                        photo = fixedPhotosArray![index]
                    }
                    
                    if photo != nil {
                        photos[index] = photo
                    }
                }
            }
            else {
                photo = photos[index]
            }
        }
        
        return photo
    }

    func thumbPhotoAtIndex(index: Int) -> Photo? {
        var photo: Photo?
        
        if index < thumbPhotos.count {
            if nil == thumbPhotos[index] {
                if let d = delegate {
                    photo = d.thumbPhotoAtIndex(index: index, photoBrowser: self)
                
                    if let p = photo {
                        thumbPhotos[index] = p
                    }
                }
            }
            else {
                photo = thumbPhotos[index]
            }
        }
        
        return photo
    }

    func captionViewForPhotoAtIndex(index: Int) -> CaptionView? {
        var captionView: CaptionView?
        
        if let d = delegate {
            captionView = d.captionViewForPhotoAtIndex(index: index, photoBrowser: self)
            
            if let p = photoAtIndex(index: index), nil == captionView {
                if p.caption.characters.count > 0 {
                    captionView = CaptionView(photo: p)
                }
            }
        }
        
        if let cv = captionView {
            cv.alpha = areControlsHidden ? 0.0 : captionAlpha // Initial alpha
        }
        
        return captionView
    }

    func photoIsSelectedAtIndex(index: Int) -> Bool {
        var value = false
        if displaySelectionButtons {
            if let d = delegate {
                value = d.isPhotoSelectedAtIndex(index: index, photoBrowser: self)
            }
        }
        
        return value
    }

    func setPhotoSelected(selected: Bool, atIndex index: Int) {
        if displaySelectionButtons {
            if let d = delegate {
                d.selectedChanged(selected: selected, index: index, photoBrowser: self)
            }
        }
    }

    func imageForPhoto(photo: Photo?) -> UIImage? {
        if let p = photo {
            // Get image or obtain in background
            if let img = p.underlyingImage {
                return img
            }
            else {
                p.loadUnderlyingImageAndNotify()
            }
        }
        
        return nil
    }

    func loadAdjacentPhotosIfNecessary(photo: Photo) {
        let page = pageDisplayingPhoto(photo: photo)
        if let p = page {
            // If page is current page then initiate loading of previous and next pages
            let pageIndex = p.index
            if currentPageIndex == pageIndex {
                if pageIndex > 0 {
                    // Preload index - 1
                    if let photo = photoAtIndex(index: pageIndex - 1) {
                        if nil == photo.underlyingImage {
                            photo.loadUnderlyingImageAndNotify()
                    
                            //MWLog(@"Pre-loading image at index %lu", (unsigned long)pageIndex-1)
                        }
                    }
                }
                
                if pageIndex < numberOfPhotos - 1 {
                    // Preload index + 1
                    if let photo = photoAtIndex(index: pageIndex + 1) {
                        if nil == photo.underlyingImage {
                            photo.loadUnderlyingImageAndNotify()
                    
                            //MWLog(@"Pre-loading image at index %lu", (unsigned long)pageIndex+1)
                        }
                    }
                }
            }
        }
    }

    //MARK: - MWPhoto Loading falsetification

    func handlePhotoLoadingDidEndNotification(notification: NSNotification) {
        if let photo = notification.object as? Photo {
            if let page = pageDisplayingPhoto(photo: photo) {
                if photo.underlyingImage != nil {
                    // Successful load
                    page.displayImage()
                    loadAdjacentPhotosIfNecessary(photo: photo)
                }
                else {
                    // Failed to load
                    page.displayImageFailure()
                }
                // Update nav
                updateNavigation()
            }
        }
    }

    //MARK: - Paging

    func tilePages() {
        // Calculate which pages should be visible
        // Ignore padding as paging bounces encroach on that
        // and lead to false page loads
        let visibleBounds = pagingScrollView.bounds
        var iFirstIndex = Int(floorf(Float((visibleBounds.minX + padding * 2.0) / visibleBounds.widthCGRectGetWidth(visibleBounds))))
        var iLastIndex  = Int(floorf(Float((visibleBounds.maxX - padding * 2.0 - 1.0) / visibleBounds.width)))
        
        if iFirstIndex < 0 {
            iFirstIndex = 0
        }
        
        if iFirstIndex > numberOfPhotos - 1 {
            iFirstIndex = numberOfPhotos - 1
        }
        
        if iLastIndex < 0 {
            iLastIndex = 0
        }
        
        if iLastIndex > numberOfPhotos - 1 {
            iLastIndex = numberOfPhotos - 1
        }
        
        // Recycle false longer needed pages
        var pageIndex = 0
        for page in visiblePages {
            pageIndex = page.index
            
            if pageIndex < iFirstIndex || pageIndex > iLastIndex {
                recycledPages.insert(page)
                
                if let cw = page.captionView {
                    cw.removeFromSuperview()
                }
                
                if let selected = page.selectedButton {
                    selected.removeFromSuperview()
                }
                
                if let play = page.playButton {
                    play.removeFromSuperview()
                }
                
                page.prepareForReuse()
                page.removeFromSuperview()
                
                //MWLog(@"Removed page at index %lu", (unsigned long)pageIndex)
            }
        }
        
        visiblePages = visiblePages.subtract(recycledPages)
        
        while recycledPages.count > 2 { // Only keep 2 recycled pages
            recycledPages.remove(recycledPages.first!)
        }
        
        // Add missing pages
        for index in iFirstIndex...iLastIndex {
            if !isDisplayingPageForIndex(index: index) {
                // Add new page
                var p = dequeueRecycledPage
                if nil == p {
                    p = ZoomingScrollView(photoBrowser: self)
                }
                
                let page = p!
                
                visiblePages.insert(page)
                configurePage(page: page, forIndex: index)

                pagingScrollView.addSubview(page)
                // MWLog(@"Added page at index %lu", (unsigned long)index)
                
                // Add caption
                if let captionView = captionViewForPhotoAtIndex(index: index) {
                    captionView.frame = frameForCaptionView(captionView: captionView, index: index)
                    pagingScrollView.addSubview(captionView)
                    page.captionView = captionView
                }
                
                // Add play button if needed
                if page.displayingVideo() {
                    let playButton = UIButton(type: .custom)
                    playButton.setImage(UIImage.imageForResourcePath(
                        path: "MWPhotoBrowserSwift.bundle/PlayButtonOverlayLarge",
                        ofType: "png",
                        inBundle: Bundle(forClass: PhotoBrowser.self)), for: .Normal)
                    
                    playButton.setImage(UIImage.imageForResourcePath(
                        path: "MWPhotoBrowserSwift.bundle/PlayButtonOverlayLargeTap",
                        ofType: "png",
                        inBundle: Bundle(forClass: PhotoBrowser.self)), for: .Highlighted)
                    
                    playButton.addTarget(self, action: Selector("playButtonTapped:"), for: .touchUpInside)
                    playButton.sizeToFit()
                    playButton.frame = frameForPlayButton(playButton: playButton, atIndex: index)
                    pagingScrollView.addSubview(playButton)
                    page.playButton = playButton
                }
                
                // Add selected button
                if self.displaySelectionButtons {
                    let selectedButton = UIButton(type: .custom)
                    selectedButton.setImage(UIImage.imageForResourcePath(
                        path: "MWPhotoBrowserSwift.bundle/ImageSelectedOff",
                        ofType: "png",
                        inBundle: Bundle(forClass: PhotoBrowser.self)),
                        for: .Normal)
                    
                    let selectedOnImage: UIImage?
                    if customImageSelectedIconName.characters.count > 0 {
                        selectedOnImage = UIImage(named: customImageSelectedIconName)
                    }
                    else {
                        selectedOnImage = UIImage.imageForResourcePath(
                            path: "MWPhotoBrowserSwift.bundle/ImageSelectedOn",
                            ofType: "png",
                            inBundle: Bundle(forClass: PhotoBrowser.self))
                    }
                    
                    selectedButton.setImage(selectedOnImage, for: .selected)
                    selectedButton.sizeToFit()
                    selectedButton.adjustsImageWhenHighlighted = false
                    selectedButton.addTarget(self, action: Selector("selectedButtonTapped:"), for: .touchUpInside)
                    selectedButton.frame = frameForSelectedButton(selectedButton: selectedButton, atIndex: index)
                    pagingScrollView.addSubview(selectedButton)
                    page.selectedButton = selectedButton
                    selectedButton.isSelected = photoIsSelectedAtIndex(index: index)
                }
            }
        }
    }

    func updateVisiblePageStates() {
        let copy = visiblePages
        for page in copy {
            // Update selection
            if let selected = page.selectedButton {
                selected.isSelected = photoIsSelectedAtIndex(index: page.index)
            }
        }
    }

    func isDisplayingPageForIndex(index: Int) -> Bool {
        for page in visiblePages {
            if page.index == index {
                return true
            }
        }
    
        return false
    }

    func pageDisplayedAtIndex(index: Int) -> ZoomingScrollView? {
        var thePage: ZoomingScrollView?
        for page in visiblePages {
            if page.index == index {
                thePage = page
                break
            }
        }
        return thePage
    }

    func pageDisplayingPhoto(photo: Photo) -> ZoomingScrollView? {
        var thePage: ZoomingScrollView?
        for page in visiblePages {
            if page.photo != nil && page.photo!.equals(photo: photo) {
                thePage = page
                break
            }
        }
        return thePage
    }

    func configurePage(page: ZoomingScrollView, forIndex index: Int) {
        page.frame = frameForPageAtIndex(index: index)
        page.index = index
        page.photo = photoAtIndex(index: index)
        page.backgroundColor = areControlsHidden ? UIColor.black : UIColor.white
    }

    var dequeueRecycledPage: ZoomingScrollView? {
        let page = recycledPages.first
        if let p = page {
            recycledPages.remove(p)
        }
        return page
    }

    // Handle page changes
    func didStartViewingPageAtIndex(index: Int) {
        // Handle 0 photos
        if 0 == numberOfPhotos {
            // Show controls
            setControlsHidden(hidden: false, animated: true, permanent: true)
            return
        }
        
        // Handle video on page change
        if !rotating || index != currentVideoIndex {
            clearCurrentVideo()
        }
        
        // Release images further away than +/-1
        if index > 0 {
            // Release anything < index - 1
            if index - 2 >= 0 {
                for i in 0...(index - 2) {
                    if let photo = photos[i] {
                        photo.unloadUnderlyingImage()
                        photos[i] = nil
                        
                        //MWLog.log("Released underlying image at index \(i)")
                    }
                }
            }
        }
        
        if index < numberOfPhotos - 1 {
            // Release anything > index + 1
            if index + 2 <= photos.count - 1 {
                for i in (index + 2)...(photos.count - 1) {
                    if let photo = photos[i] {
                        photo.unloadUnderlyingImage()
                        photos[i] = nil
                    
                        //MWLog.log("Released underlying image at index \(i)")
                    }
                }
            }
        }
        
        // Load adjacent images if needed and the photo is already
        // loaded. Also called after photo has been loaded in background
        let currentPhoto = photoAtIndex(index: index)
        
        if let cp = currentPhoto {
            if cp.underlyingImage != nil {
                // photo loaded so load ajacent falsew
                loadAdjacentPhotosIfNecessary(photo: cp)
            }
        }
        
        // Notify delegate
        if index != previousPageIndex {
            if let d = delegate {
                d.didDisplayPhotoAtIndex(index: index, photoBrowser: self)
            }
            previousPageIndex = index
        }
        
        // Update nav
        updateNavigation()
    }

    //MARK: - Frame Calculations

    var frameForPagingScrollView: CGRect {
        var frame = view.bounds// UIScreen.mainScreen().bounds
        frame.origin.x -= padding
        frame.size.width += (2.0 * padding)
        return frame.integral
    }

    func frameForPageAtIndex(index: Int) -> CGRect {
        // We have to use our paging scroll view's bounds, falset frame, to calculate the page placement. When the device is in
        // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
        // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
        // because it has a rotation transform applied.
        let bounds = pagingScrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= (2.0 * padding)
        pageFrame.origin.x = (bounds.size.width * CGFloat(index)) + padding
        return pageFrame.integral
    }

    func contentSizeForPagingScrollView() -> CGSize {
        // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
        let bounds = pagingScrollView.bounds
        return CGSize(width: bounds.size.width * CGFloat(numberOfPhotos), height: bounds.size.height)
    }

    func contentOffsetForPageAtIndex(index: Int) -> CGPoint {
        let pageWidth = pagingScrollView.bounds.size.width
        let newOffset = CGFloat(index) * pageWidth
        return CGPoint(x: newOffset, y: 0)
    }

    var frameForToolbar: CGRect {
        var height = CGFloat(44.0)
        
        if view.bounds.height < 768.0 && view.bounds.height < view.bounds.width {
            height = 32.0
        }
        
        return CGRect(x: 0.0, y: view.bounds.size.height - height, width: view.bounds.size.width, height: height).integral
    }

    func frameForCaptionView(captionView: CaptionView?, index: Int) -> CGRect {
        if let cw = captionView {
            let pageFrame = frameForPageAtIndex(index: index)
            let captionSize = cw.sizeThatFits(CGSize(width: pageFrame.size.width, height: 0.0))
            let captionFrame = CGRect(
                x: pageFrame.origin.x,
                y: pageFrame.size.height - captionSize.height - (toolbar.superview != nil ? toolbar.frame.size.height : 0.0),
                width: pageFrame.size.width,
                height: captionSize.height)
            
            return captionFrame.integral
        }
        
        return CGRect.zero
    }

    func frameForSelectedButton(selectedButton: UIButton, atIndex index: Int) -> CGRect {
        let pageFrame = frameForPageAtIndex(index: index)
        let padding = CGFloat(20.0)
        var yOffset = CGFloat(0.0)
        
        if !areControlsHidden {
            if let navBar = navigationController?.navigationBar {
                yOffset = navBar.frame.origin.y + navBar.frame.size.height
            }
        }
        
        let selectedButtonFrame = CGRect(
            x: pageFrame.origin.x + pageFrame.size.width - selectedButton.frame.size.width - padding,
            y: padding + yOffset,
            width: selectedButton.frame.size.width,
            height: selectedButton.frame.size.height)
        
        return selectedButtonFrame.integral
    }

    func frameForPlayButton(playButton: UIButton, atIndex index: Int) -> CGRect {
        let pageFrame = frameForPageAtIndex(index: index)
        return CGRect(
            x: CGFloat(floorf(Float(pageFrame.midX - playButton.frame.size.width / 2.0))),
            y: CGFloat(floorf(Float(pageFrame.midY - playButton.frame.size.height / 2.0))),
            width: playButton.frame.size.width,
            height: playButton.frame.size.height)
    }

    //MARK: - UIScrollView Delegate

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Checks
        if !viewIsActive || performingLayout || rotating {
            return
        }
        
        // Tile pages
        tilePages()
        
        // Calculate current page
        let visibleBounds = pagingScrollView.bounds
        var index = Int(floorf(Float(visibleBounds.midX / visibleBounds.width)))
        if index < 0 {
            index = 0
        }
        
        if index > numberOfPhotos - 1 {
            index = numberOfPhotos - 1
        }
        
        let previousCurrentPage = currentPageIndex
        currentPageIndex = index
        
        if currentPageIndex != previousCurrentPage {
            didStartViewingPageAtIndex(index: index)
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Hide controls when dragging begins
        setControlsHidden(hidden: true, animated: true, permanent: false)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Update nav when page changes
        updateNavigation()
    }

    //MARK: - Navigation

    func updateNavigation() {
        // Title
        let photos = numberOfPhotos
        if let gc = gridController {
            if gc.selectionMode {
                self.title = NSLocalizedString("Select Photos", comment: "")
            }
            else {
                let photosText: String
                
                if 1 == photos {
                    photosText = NSLocalizedString("photo", comment: "Used in the context: '1 photo'")
                }
                else {
                    photosText = NSLocalizedString("photos", comment: "Used in the context: '3 photos'")
                }
                
                title = "\(photos) \(photosText)"
            }
        }
        else
        if photos > 1 {
            if let d = delegate {
                title = d.titleForPhotoAtIndex(index: currentPageIndex, photoBrowser: self)
            }
            
            if nil == title {
                let str = NSLocalizedString("of", comment: "Used in the context: 'Showing 1 of 3 items'")
                title = "\(currentPageIndex + 1) \(str) \(numberOfPhotos)"
            }
        }
        else {
            title = nil
        }
        
        // Buttons
        if let prev = previousButton {
            prev.isEnabled = (currentPageIndex > 0)
        }
        
        if let next = nextButton {
            next.isEnabled = (currentPageIndex < photos - 1)
        }
        
        // Disable action button if there is false image or it's a video
        if let ab = actionButton {
            let photo = photoAtIndex(index: currentPageIndex)

            if photo != nil && (photo!.underlyingImage == nil || photo!.isVideo) {
                ab.isEnabled = false
                ab.tintColor = UIColor.clear // Tint to hide button
            }
            else {
                ab.isEnabled = true
                ab.tintColor = nil
            }
        }
    }

    func jumpToPageAtIndex(index: Int, animated: Bool) {
        // Change page
        if index < numberOfPhotos {
            let pageFrame = frameForPageAtIndex(index: index)
            pagingScrollView.setContentOffset(CGPoint(x: pageFrame.origin.x - padding, y: 0), animated: animated)
            updateNavigation()
        }
        
        // Update timer to give more time
        hideControlsAfterDelay()
    }

    func gotoPreviousPage() {
        showPreviousPhotoAnimated(animated: false)
    }
    func gotoNextPage() {
        showNextPhotoAnimated(animated: false)
    }

    func showPreviousPhotoAnimated(animated: Bool) {
        jumpToPageAtIndex(index: currentPageIndex - 1, animated: animated)
    }

    func showNextPhotoAnimated(animated: Bool) {
        jumpToPageAtIndex(index: currentPageIndex + 1, animated: animated)
    }

    //MARK: - Interactions

    func selectedButtonTapped(sender: AnyObject) {
        let selectedButton = sender as! UIButton
        selectedButton.isSelected = !selectedButton.isSelected
    
        var index = Int.max
        for page in visiblePages {
            if page.selectedButton == selectedButton {
                index = page.index
                break
            }
        }
    
        if index != Int.max {
            setPhotoSelected(selected: selectedButton.isSelected, atIndex: index)
        }
    }

    func playButtonTapped(sender: AnyObject) {
        let playButton = sender as! UIButton
        var index = Int.max
    
        for page in visiblePages {
            if page.playButton == playButton {
                index = page.index
                break
            }
        }
        
        if index != Int.max {
            if nil == currentVideoPlayerViewController {
                playVideoAtIndex(index: index)
            }
        }
    }

    //MARK: - Video

    func playVideoAtIndex(index: Int) {
        let photo = photoAtIndex(index: index)
        
        // Valid for playing
        currentVideoIndex = index
        clearCurrentVideo()
        setVideoLoadingIndicatorVisible(visible: true, atPageIndex: index)
        
        // Get video and play
        if let p = photo {
            p.getVideoURL() { url in
                if let u = url {
                    DispatchQueue.main.async() {
                        self.playVideo(videoURL: u, atPhotoIndex: index)
                    }
                }
                else {
                    self.setVideoLoadingIndicatorVisible(visible: false, atPageIndex: index)
                }
            }
        }
    }

    func playVideo(videoURL: NSURL, atPhotoIndex index: Int) {
        // Setup player
        currentVideoPlayerViewController = MPMoviePlayerViewController(contentURL: videoURL as URL!)
        
        if let player = currentVideoPlayerViewController {
            player.moviePlayer.prepareToPlay()
            player.moviePlayer.shouldAutoplay = true
            player.moviePlayer.scalingMode = .aspectFit
            player.modalTransitionStyle = .crossDissolve
        
            // Remove the movie player view controller from the "playback did finish" falsetification observers
            // Observe ourselves so we can get it to use the crossfade transition
            NotificationCenter.default.removeObserver(
                player,
                name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish,
                object: player.moviePlayer)
        
            NotificationCenter.default.addObserver(
                self,
                selector: Selector("videoFinishedCallback:"),
                name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish,
                object: player.moviePlayer)

            // Show
            present(player, animated: true, completion: nil)
        }
    }

    func videoFinishedCallback(notification: NSNotification) {
        if let player = currentVideoPlayerViewController {
            // Remove observer
            NotificationCenter.default.removeObserver(
                self,
                name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish,
                object: player.moviePlayer)
            
            // Clear up
            clearCurrentVideo()
            
            // Dismiss
            if let errorObj: AnyObject? = notification.userInfo?[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as AnyObject {
                let error = MPMovieFinishReason(rawValue: errorObj as! Int)
            
                if error == .playbackError {
                    // Error occured so dismiss with a delay incase error was immediate and we need to wait to dismiss the VC
                    dispatch_after(
                        DispatchTime.now(dispatch_time_t(DispatchTime.now()), Int64(1.0 * Double(NSEC_PER_SEC))),
                        dispatch_get_main_queue())
                    {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    return
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }

    func clearCurrentVideo() {
        if currentVideoPlayerViewController != nil {
            currentVideoLoadingIndicator!.removeFromSuperview()
            currentVideoPlayerViewController = nil
            currentVideoLoadingIndicator = nil
            currentVideoIndex = Int.max
        }
    }

    func setVideoLoadingIndicatorVisible(visible: Bool, atPageIndex: Int) {
        if currentVideoLoadingIndicator != nil && !visible {
            currentVideoLoadingIndicator!.removeFromSuperview()
            currentVideoLoadingIndicator = nil
        }
        else
        if nil == currentVideoLoadingIndicator && visible {
            currentVideoLoadingIndicator = UIActivityIndicatorView(frame: CGRect.zero)
            currentVideoLoadingIndicator!.sizeToFit()
            currentVideoLoadingIndicator!.startAnimating()
            pagingScrollView.addSubview(currentVideoLoadingIndicator!)
            
            positionVideoLoadingIndicator()
        }
    }

    func positionVideoLoadingIndicator() {
        if currentVideoLoadingIndicator != nil && currentVideoIndex != Int.max {
            let frame = frameForPageAtIndex(index: currentVideoIndex)
            currentVideoLoadingIndicator!.center = CGPoint(x: frame.midX, y: frame.midY)
        }
    }

    //MARK: - Grid

    func showGridAnimated() {
        showGrid(animated: true)
    }

    func showGrid(animated: Bool) {
        if gridController != nil {
            return
        }
        
        // Init grid controller
        gridController = GridViewController()
        
        if let gc = gridController,
            let navBar = navigationController?.navigationBar
        {
            let bounds = view.bounds
            let naviHeight = navBar.frame.height + UIApplication.shared.statusBarFrame.height
            
            gc.initialContentOffset = currentGridContentOffset
            gc.browser = self
            gc.selectionMode = displaySelectionButtons
            gc.view.frame = CGRect(x: 0.0, y: naviHeight, width: bounds.width, height: bounds.height - naviHeight)
            gc.view.alpha = 0.0
            
            // Stop specific layout being triggered
            skipNextPagingScrollViewPositioning = true
            
            // Add as a child view controller
            addChildViewController(gc)
            view.addSubview(gc.view)
        
            // Perform any adjustments
            gc.view.layoutIfNeeded()
            gc.adjustOffsetsAsRequired()
        
            // Hide action button on nav bar if it exists
            if navigationItem.rightBarButtonItem == actionButton {
                gridPreviousRightNavItem = actionButton
                navigationItem.setRightBarButton(nil, animated: true)
            }
            else {
                gridPreviousRightNavItem = nil
            }
            
            // Update
            updateNavigation()
            setControlsHidden(hidden: false, animated: true, permanent: true)
            
            // Animate grid in and photo scroller out
            gc.willMove(toParentViewController: self)
            UIView.animate(
                withDuration: animated ? 0.3 : 0,
                animations: {
                    gc.view.alpha = 1.0
                    self.pagingScrollView.alpha = 0.0
                },
                completion: { finished in
                    gc.didMove(toParentViewController: self)
                })
        }
    }

    func hideGrid() {
        if let gc = gridController {
            // Remember previous content offset
            currentGridContentOffset = gc.collectionView!.contentOffset
            
            // Restore action button if it was removed
            if gridPreviousRightNavItem == actionButton && actionButton != nil {
                navigationItem.setRightBarButton(gridPreviousRightNavItem, animated: true)
            }
            
            // Position prior to hide animation
            let pagingFrame = frameForPagingScrollView
            pagingScrollView.frame = pagingFrame.offsetBy(
                dx: 0,
                dy: (self.startOnGrid ? 1 : -1) * pagingFrame.size.height)
            
            // Remember and remove controller now so things can detect a nil grid controller
            gridController = nil
            
            // Update
            updateNavigation()
            updateVisiblePageStates()
            view.layoutIfNeeded()
            view.layoutSubviews()
            
            self.pagingScrollView.frame = self.frameForPagingScrollView
            
            // Animate, hide grid and show paging scroll view
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    gc.view.alpha = 0.0
                    self.pagingScrollView.alpha = 1.0
                },
                completion: { finished in
                    gc.willMove(toParentViewController: nil)
                    gc.view.removeFromSuperview()
                    gc.removeFromParentViewController()
            
                    self.setControlsHidden(hidden: false, animated: true, permanent: false) // retrigger timer
                })
        }
    }

    //MARK: - Control Hiding / Showing

    // If permanent then we don't set timers to hide again
    func setControlsHidden( hidden: Bool, animated: Bool, permanent: Bool) {
        // Force visible
        var hidden = hidden
        if 0 == numberOfPhotos || gridController != nil || alwaysShowControls {
            hidden = false
        }
        
        // Cancel any timers
        cancelControlHiding()
        
        // Animations & positions
        let animatonOffset = CGFloat(20)
        let animationDuration = CFTimeInterval(animated ? 0.35 : 0.0)
        
        // Status bar
        if !leaveStatusBarAlone {
            // Hide status bar
            if !isVCBasedStatusBarAppearance {
                // falsen-view controller based
                UIApplication.shared.setStatusBarHidden(
                    hidden, with:
                    animated ? UIStatusBarAnimation.slide : UIStatusBarAnimation.none)
                
            }
            else {
                // View controller based so animate away
                statusBarShouldBeHidden = hidden
                UIView.animate(
                    withDuration: animationDuration,
                    animations: {
                        self.setNeedsStatusBarAppearanceUpdate()
                    })
            }
        }
        
        // Toolbar, nav bar and captions
        // Pre-appear animation positions for sliding
        if areControlsHidden && !hidden && animated {
            // Toolbar
            toolbar.frame = frameForToolbar.offsetBy(dx: 0, dy: animatonOffset)
            
            // Captions
            for page in visiblePages {
                if let v = page.captionView {
                    // Pass any index, all we're interested in is the Y
                    var captionFrame = frameForCaptionView(captionView: v, index: 0)
                    captionFrame.origin.x = v.frame.origin.x // Reset X
                    v.frame = captionFrame.offsetBy(dx: 0, dy: animatonOffset)
                }
            }
        }
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.navigationController?.setNavigationBarHidden(hidden, animated: true)
            
            // Toolbar
            self.toolbar.frame = self.frameForToolbar
            
            if hidden {
                self.toolbar.frame = self.toolbar.frame.offsetBy(dx: 0, dy: animatonOffset)
                self.view.backgroundColor = UIColor.black
                
                self.pagingScrollView.backgroundColor = UIColor.black
                self.navigationController?.view.backgroundColor = UIColor.black
                
                for page in self.visiblePages {
                    page.backgroundColor = UIColor.black
                }
            }
            else {
                self.view.backgroundColor = UIColor.white
                
                self.pagingScrollView.backgroundColor = UIColor.white
                self.navigationController?.view.backgroundColor = UIColor.white
                
                for page in self.visiblePages {
                    page.backgroundColor = UIColor.white
                }
            }
            
            self.toolbar.alpha = hidden ? 0.0 : self.toolbarAlpha

            // Captions
            for page in self.visiblePages {
                if let v = page.captionView {
                    // Pass any index, all we're interested in is the Y
                    var captionFrame = self.frameForCaptionView(captionView: v, index: 0)
                    captionFrame.origin.x = v.frame.origin.x // Reset X
                    
                    if hidden {
                        captionFrame = captionFrame.offsetBy(dx: 0, dy: animatonOffset)
                    }
                    
                    v.frame = captionFrame
                    v.alpha = hidden ? 0.0 : self.captionAlpha
                }
            }
            
            // Selected buttons
            for page in self.visiblePages {
                if let button = page.selectedButton {
                    let v = button
                    var newFrame = self.frameForSelectedButton(selectedButton: v, atIndex: 0)
                    newFrame.origin.x = v.frame.origin.x
                    v.frame = newFrame
                }
            }
        })
        
        // Controls
        if !permanent {
            hideControlsAfterDelay()
        }
    }
    public override var prefersStatusBarHidden: Bool {
        if !leaveStatusBarAlone {
            return statusBarShouldBeHidden
        }
        
        return presentingViewControllerPrefersStatusBarHidden
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    func cancelControlHiding() {
        // If a timer exists then cancel and release
        if controlVisibilityTimer != nil {
            controlVisibilityTimer!.invalidate()
            controlVisibilityTimer = nil
        }
    }

    // Enable/disable control visiblity timer
    func hideControlsAfterDelay() {
        if !areControlsHidden {
            cancelControlHiding()
            
            controlVisibilityTimer = Timer.scheduledTimer(
                timeInterval: delayToHideElements,
                target: self,
                selector: Selector("hideControls"),
                userInfo: nil,
                repeats: false)
        }
    }

    var areControlsHidden: Bool {
        return 0.0 == toolbar.alpha
    }
    
    func hideControls() {
        setControlsHidden(hidden: true, animated: true, permanent: false)
    }
    
    func showControls() {
        setControlsHidden(hidden: false, animated: true, permanent: false)
    }
    
    func toggleControls() {
        setControlsHidden(hidden: !areControlsHidden, animated: true, permanent: false)
    }

    //MARK: - Properties

    var currentPhotoIndex: Int {
        set(i) {
            var index = i
        
            // Validate
            let photoCount = numberOfPhotos
        
            if 0 == photoCount {
                index = 0
            }
            else
            if index >= photoCount {
                index = photoCount - 1
            }
            
            currentPageIndex = index
        
            if isViewLoaded {
                jumpToPageAtIndex(index: index, animated: false)
                if !viewIsActive {
                    tilePages() // Force tiling if view is falset visible
                }
            }
        }
        
        get {
            return currentPageIndex
        }
    }

    //MARK: - Misc

    func doneButtonPressed(sender: AnyObject) {
        // Only if we're modal and there's a done button
        if doneButton != nil {
            // See if we actually just want to show/hide grid
            if enableGrid {
                if startOnGrid && nil == gridController {
                    showGrid(animated: true)
                    return
                }
                else
                if !startOnGrid && gridController != nil {
                    hideGrid()
                    return
                }
            }
        
            // Dismiss view controller
            // Call delegate method and let them dismiss us
            if let d = delegate {
                d.photoBrowserDidFinishModalPresentation(photoBrowser: self)
            }
            // dismissViewControllerAnimated:true completion:nil]
        }
    }

    //MARK: - Actions

    func actionButtonPressed(sender: AnyObject) {
        // Only react when image has loaded
        if let photo = photoAtIndex(index: currentPageIndex) {
            if numberOfPhotos > 0 && photo.underlyingImage != nil {
                // If they have defined a delegate method then just message them
                // Let delegate handle things
                if let d = delegate {
                    d.actionButtonPressedForPhotoAtIndex(index: currentPageIndex, photoBrowser: self)
                }
                /*
                // Show activity view controller
                var items = NSMutableArray(object: photo.underlyingImage)
                if photo.caption != nil {
                    items.append(photo.caption!)
                }
                activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                
                // Show loading spinner after a couple of seconds
                double delayInSeconds = 2.0
                dispatch_timet popTime = dispatchtime(DISPATCH_TIME_NOW, Int64(delayInSeconds * NSEC_PER_SEC))
                dispatch_after(popTime, dispatch_get_main_queue()) {
                    if self.activityViewController {
                        showProgressHUDWithMessage(nil)
                    }
                }

                // Show
                activityViewController.setCompletionHandler({ [weak self] activityType, completed in
                    self!.activityViewController = nil
                    self!.hideControlsAfterDelay()
                    self!.hideProgressHUD(true)
                })
            
                self.activityViewController.popoverPresentationController.barButtonItem = actionButton
            
                presentViewController(activityViewController, animated: true, completion: nil)
                */
                
                // Keep controls hidden
                setControlsHidden(hidden: false, animated: true, permanent: true)
            }
        }
    }

    //MARK: - Action Progress

    var mwProgressHUD: MBProgressHUD?

    var progressHUD: MBProgressHUD {
        if nil == mwProgressHUD {
            mwProgressHUD = MBProgressHUD(view: self.view)
            mwProgressHUD!.minSize = CGSizeMake(120, 120)
            mwProgressHUD!.minShowTime = 1.0
            
            view.addSubview(mwProgressHUD!)
        }
        return mwProgressHUD!
    }

    private func showProgressHUDWithMessage(message: String) {
        progressHUD.labelText = message
        progressHUD.mode = MBProgressHUDMode.Indeterminate
        progressHUD.show(true)
        
        navigationController?.navigationBar.isUserInteractionEnabled = false
    }

    private func hideProgressHUD(animated: Bool) {
        progressHUD.hide(animated)
        
        navigationController?.navigationBar.isUserInteractionEnabled = true
    }

    private func showProgressHUDCompleteMessage(message: String?) {
        if let msg = message {
            if progressHUD.hidden {
                progressHUD.show(true)
            }
    
            progressHUD.labelText = msg
            progressHUD.mode = MBProgressHUDMode.CustomView
            progressHUD.hide(true, afterDelay: 1.5)
        }
        else {
            progressHUD.hide(true)
        }
    
        navigationController?.navigationBar.isUserInteractionEnabled = true
    }
}

public protocol PhotoBrowserDelegate: class {
    func numberOfPhotosInPhotoBrowser(photoBrowser: PhotoBrowser) -> Int
    func photoAtIndex(index: Int, photoBrowser: PhotoBrowser) -> Photo

    func thumbPhotoAtIndex(index: Int, photoBrowser: PhotoBrowser) -> Photo
    func captionViewForPhotoAtIndex(index: Int, photoBrowser: PhotoBrowser) -> CaptionView?
    func titleForPhotoAtIndex(index: Int, photoBrowser: PhotoBrowser) -> String
    func didDisplayPhotoAtIndex(index: Int, photoBrowser: PhotoBrowser)
    func actionButtonPressedForPhotoAtIndex(index: Int, photoBrowser: PhotoBrowser)
    func isPhotoSelectedAtIndex(index: Int, photoBrowser: PhotoBrowser) -> Bool
    func selectedChanged(selected: Bool, index: Int, photoBrowser: PhotoBrowser)
    func photoBrowserDidFinishModalPresentation(photoBrowser: PhotoBrowser)
}

public extension PhotoBrowserDelegate {
    func captionViewForPhotoAtIndex(index: Int, photoBrowser: PhotoBrowser) -> CaptionView? {
        return nil
    }
    
    func didDisplayPhotoAtIndex(index: Int, photoBrowser: PhotoBrowser) {
    
    }
    
    func actionButtonPressedForPhotoAtIndex(index: Int, photoBrowser: PhotoBrowser) {
        
    }
    
    func isPhotoSelectedAtIndex(index: Int, photoBrowser: PhotoBrowser) -> Bool {
        return false
    }
    
    func selectedChanged(selected: Bool, index: Int, photoBrowser: PhotoBrowser) {
    
    }
    
    func titleForPhotoAtIndex(index: Int, photoBrowser: PhotoBrowser) -> String {
        return ""
    }
}
