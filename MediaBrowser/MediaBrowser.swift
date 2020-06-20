//
//  MediaBrowser.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//

import UIKit
import AVKit
import QuartzCore
import SDWebImage

func floorcgf(x: CGFloat) -> CGFloat {
    return CGFloat(floorf(Float(x)))
}

/// MediaBrwoser is based in UIViewController, UIScrollViewDelegate and UIActionSheetDelegate. So you can push, or make modal.
@objcMembers public class MediaBrowser: UIViewController, AVPlayerViewControllerDelegate {
    internal let padding = CGFloat(0.0)

    // Data
    internal var mediaCount = -1
    internal var mediaArray = [Media?]()
    internal var thumbMedias = [Media?]()
    /// Provided via init
	internal var fixedMediasArray: [Media]?
	
	// Views
	internal var pagingScrollView = UIScrollView()
	
	// Paging & layout
	internal var visiblePages = Set<MediaZoomingScrollView>()
    internal var recycledPages = Set<MediaZoomingScrollView>()
	internal var currentPageIndex = 0
    internal var previousPageIndex = Int.max
    internal var previousLayoutBounds = CGRect.zero
	internal var pageIndexBeforeRotation = 0
	
	// Navigation & controls
	internal var toolbar = UIToolbar()
	internal var controlVisibilityTimer: Timer?
	internal var previousButton: UIBarButtonItem?
    internal var nextButton: UIBarButtonItem?
    internal var actionButton: UIBarButtonItem?
    internal var doneButton: UIBarButtonItem?
    
    // Grid
    internal var gridController: MediaGridViewController?
    internal var gridPreviousLeftNavItem: UIBarButtonItem?
    internal var gridPreviousRightNavItem: UIBarButtonItem?
    
    // Appearance
    internal var previousNavigationBarHidden = false
    internal var previousNavigationBarTranslucent = false
    internal var previousNavigationBarStyle = UIBarStyle.default
    internal var previousNavigationBarTextColor: UIColor?
    internal var previousNavigationBarBackgroundColor: UIColor?
    internal var previousNavigationBarTintColor: UIColor?
    internal var previousViewControllerBackButton: UIBarButtonItem?
    internal var previousStatusBarStyle: UIStatusBarStyle = .lightContent

    // Video
    lazy internal var currentVideoPlayerViewController: AVPlayerViewController = {
        if #available(iOS 9.0, *) {
            $0.delegate = self
        }
        return $0
    }(AVPlayerViewController())
    internal var currentVideoIndex = 0
    internal var currentVideoLoadingIndicator: UIActivityIndicatorView?

    var activityViewController: UIActivityViewController?

    /// Paging Scroll View Background Color for MediaBrowser
    public var scrollViewBackgroundColor = UIColor.black

    /// UINavigationBar Translucent for MediaBrowser
    public var navigationBarTranslucent = true
    
    /// UINavigationBar Text Color for MediaBrowser
    public var navigationBarTextColor = UIColor.white
    
    /// UINavigationBar Background Color for MediaBrowser
    public var navigationBarBackgroundColor = UIColor.black
    
    /// UINavigationBar Tint Color for MediaBrowser
    public var navigationBarTintColor = UIColor.black.withAlphaComponent(0.5)

    /// UINavigationBar Style for MediaBrowser
    public var navigationBarStyle = UIBarStyle.black

    /// UIStatusBarStyle for MediaBrowser
    public var statusBarStyle: UIStatusBarStyle = .lightContent
    
    /// UIToolBar Text Color for MediaBrowser
    public var toolbarTextColor = UIColor.white
    
    /// UIToolBar Tint Color for MediaBrowser
    public var toolbarBarTintColor = UIColor.black.withAlphaComponent(0.5)
    
    /// UIToolBar Tint Background for MediaBrowser
    public var toolbarBackgroundColor = UIColor.black
    
    /// MediaBrowser has belonged to viewcontroller
    public var hasBelongedToViewController = false
    
    /// Check viewcontroller based status bar apperance
    public var isVCBasedStatusBarAppearance = false
    
    /// Hide or show status bar
    public var statusBarShouldBeHidden = false
    
    /// Display action button (share)
    public var displayActionButton = true
    
    /// Make status bar not hide
    public var leaveStatusBarAlone = false
    
    /// Perform layout
	public var performingLayout = false
    
    /// Support rotating
	public var rotating = false
    
    /// Active as in it's in the view heirarchy
    public var viewIsActive = false
    
    /// Save previous status bar style to return when push
    public var didSavePreviousStateOfNavBar = false
    
    /// Stop specific layout being triggered
    public var skipNextPagingScrollViewPositioning = false
    
    /// View has appeared initially
    public var viewHasAppearedInitially = false
    
    /// Make current grid offset
    public var currentGridContentOffset = CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude)
    
    /// Set MediaBrowserDelegate for MediaBrowser
    public weak var delegate: MediaBrowserDelegate?
    
    /// Available zoom photos to fill
    public var zoomPhotosToFill = true
    
    /// Display Media Navigation Arrows
    public var displayMediaNavigationArrows = false
    
    /// Display selection buttons
    public var displaySelectionButtons = false
    
    /// Always show controls
    public var alwaysShowControls = false
    
    /// Enable grid
    public var enableGrid = true
    
    /// Enable swipe to dismiss
    public var enableSwipeToDismiss = true
    
    /// Start on Grid
    public var startOnGrid = false

    /// If you observe flashes to the screen when you move between the grid
    /// and the photos, set this to true to disable the transition animations.
    public var disableGridAnimations = false
    
    /// Auto play video on appear
    public var autoPlayOnAppear = false
    
    /// Hide control when MediaBrowser start
    public var hideControlsOnStartup = false
    
    /// Hide time inerval
    public var delayToHideElements = TimeInterval(5.0)
    
    /// Captionview alpha
    public var captionAlpha = CGFloat(1)
    
    /// Toolbar alpha
    public var toolbarAlpha = CGFloat(1)
    
    /// Loading Indicator Inner Ring Color
    public var loadingIndicatorInnerRingColor = UIColor.white
    
    /// Loading Indicator Outer Ring Color
    public var loadingIndicatorOuterRingColor = UIColor.gray
    
    /// Loading Indicator Inner Ring Width
    public var loadingIndicatorInnerRingWidth:CGFloat = 1.0
    
    /// Loading Indicator Outer Ring Width
    public var loadingIndicatorOuterRingWidth:CGFloat = 1.0
    
    /// Loading Indicator Font
    public var loadingIndicatorFont = UIFont.systemFont(ofSize: 10)
    
    /// Loading Indicator Font Color
    public var loadingIndicatorFontColor = UIColor.white
    
    /// Loading Indicator Show or hide text
    public var loadingIndicatorShouldShowValueText = true
    
    /// Media selected on icon
    public var mediaSelectedOnIcon: UIImage?
    
    /// Media selected off icon
    public var mediaSelectedOffIcon: UIImage?
    
    /// Media selected grid on icon
    public var mediaSelectedGridOnIcon: UIImage?
    
    /// Media selected grid off icon
    public var mediaSelectedGridOffIcon: UIImage?
    
    /// Caching image count both side (e.g. when index 1, caching 0 and 2)
    public var cachingImageCount = 1
    
    /// Caching before MediaBrowser comes up, set
    public var preCachingEnabled = false {
        didSet {
            if preCachingEnabled {
                startPreCaching()
            }
        }
    }

    /**
     Placeholder image
     - image: placeholder image
     - isAppliedForAll: This is indicated whether the placeholder will be showed for all image page or cell.
                         If you want to use the placeholder image only for one special image page or cell, you should set the **currentIndex** variable.
     */
    public var placeholderImage: (image: UIImage, isAppliedForAll: Bool)?

    //MARK: - Init
    
    /**
     init with delegate
     
     - Parameter nibName: nibName
     - Parameter nibBundle: nibBundle
     */
    public override init(nibName: String?, bundle nibBundle: Bundle?) {
        super.init(nibName: nibName, bundle: nibBundle)
        initialisation()
    }
    
    /**
     init with delegate
     
     - Parameter delegate: MediaBrowserDelegate
     */
    public convenience init(delegate: MediaBrowserDelegate) {
        self.init()
        self.delegate = delegate
    }

    /**
     init with media
     
     - Parameter media: Media array
     */
    public convenience init(media: [Media]) {
        self.init()
        fixedMediasArray = media
    }

    /**
     init with coder
     
     - Parameter coder: coder
     */
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialisation()
    }
    
    private func initialisation() {
        // Defaults
        if let vcBasedStatusBarAppearance = Bundle.main.object(forInfoDictionaryKey: "UIViewControllerBasedStatusBarAppearance") as? Bool {
           isVCBasedStatusBarAppearance = vcBasedStatusBarAppearance
        } else {
            isVCBasedStatusBarAppearance = true
        }
        
        
        hidesBottomBarWhenPushed = true
        automaticallyAdjustsScrollViewInsets = false
//        extendedLayoutIncludesOpaqueBars = true
//        navigationController?.view.backgroundColor = UIColor.white
        
        // Listen for Media falsetifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePhotoLoadingDidEndNotification),
            name: NSNotification.Name(rawValue: MEDIA_LOADING_DID_END_NOTIFICATION),
            object: nil)
    }

    deinit {
        clearCurrentVideo()
        pagingScrollView.delegate = nil
        NotificationCenter.default.removeObserver(self)
        releaseAllUnderlyingPhotos(preserveCurrent: false)
        SDImageCache.shared.clearMemory() // clear memory
    }

    private func releaseAllUnderlyingPhotos(preserveCurrent: Bool) {
        // Create a copy in case this array is modified while we are looping through
        // Release photos
        var copy = mediaArray
        for p in copy {
            if let ph = p {
                if let paci = mediaAtIndex(index: currentIndex) {
                    if preserveCurrent && ph.equals(photo: paci) {
                        continue // skip current
                    }
                }
                
                ph.unloadUnderlyingImage()
            }
        }
        
        // Release thumbs
        copy = thumbMedias
        for p in copy {
            if let ph = p {
                ph.unloadUnderlyingImage()
            }
        }
    }
    /// didReceiveMemoryWarning
    open override func didReceiveMemoryWarning() {
        // Release any cached data, images, etc that aren't in use.
        releaseAllUnderlyingPhotos(preserveCurrent: true)
        recycledPages.removeAll(keepingCapacity: false)
        
        // Releases the view if it doesn't have a superview.
        super.didReceiveMemoryWarning()
    }

    //MARK: - View Loading

    /// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
    open override func viewDidLoad() {
        // Validate grid settings
        if startOnGrid {
            enableGrid = true
        }
        
//        if enableGrid {
//            enableGrid = delegate?.thumbPhotoAtIndex(index: <#T##Int#>, MediaBrowser: <#T##MediaBrowser#>)
////            enableGrid = [delegate respondsToSelector:Selector("MediaBrowser:thumbPhotoAtIndex:)]
//        }
        
        if !enableGrid {
            startOnGrid = false
        }
        
        // View
        view.clipsToBounds = true
        
        // Setup paging scrolling view
        let pagingScrollViewFrame = frameForPagingScrollView
        pagingScrollView = UIScrollView(frame: pagingScrollViewFrame)
        pagingScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pagingScrollView.isPagingEnabled = true
        pagingScrollView.delegate = self
        pagingScrollView.showsHorizontalScrollIndicator = false
        pagingScrollView.showsVerticalScrollIndicator = false
        pagingScrollView.backgroundColor = scrollViewBackgroundColor
        pagingScrollView.contentSize = contentSizeForPagingScrollView()
        view.addSubview(pagingScrollView)
        
        // Toolbar
        toolbar = UIToolbar(frame: frameForToolbar)
        toolbar.tintColor = toolbarTextColor
        toolbar.barTintColor = toolbarBarTintColor
        toolbar.backgroundColor = toolbarBackgroundColor
        toolbar.alpha = toolbarAlpha
        toolbar.barStyle = .blackTranslucent
        toolbar.isTranslucent = true
        toolbar.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]


        // Toolbar Items
        if displayMediaNavigationArrows {
            let arrowPathFormat = "UIBarButtonItemArrow"
            
            let previousButtonImage = UIImage.imageForResourcePath(
                name: arrowPathFormat + "Left",
                inBundle: Bundle(for: MediaBrowser.self))
            
            let nextButtonImage = UIImage.imageForResourcePath(
                name: arrowPathFormat + "Right",
                inBundle: Bundle(for: MediaBrowser.self))
            
            previousButton = UIBarButtonItem(
                image: previousButtonImage,
                style: UIBarButtonItem.Style.plain,
                target: self,
                action: #selector(MediaBrowser.gotoPreviousPage))
            
            nextButton = UIBarButtonItem(
                image: nextButtonImage,
                style: UIBarButtonItem.Style.plain,
                target: self,
                action: #selector(MediaBrowser.gotoNextPage))
        }
        
        if displayActionButton {
            actionButton = UIBarButtonItem(
                barButtonSystemItem: UIBarButtonItem.SystemItem.action,
                target: self,
                action: #selector(actionButtonPressed(_:)))
        }
        
        reloadData()
        
        if enableSwipeToDismiss {
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(doneButtonPressed))
            swipeGesture.direction = [.down, .up]
            view.addGestureRecognizer(swipeGesture)
        }
        
        super.viewDidLoad()
    }
    
    /**
     view will transition
     
     - Parameter size: size
     - Parameter coordinator: UIViewControllerTransitionCoordinator
     */
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        // Remember page index before rotation
        pageIndexBeforeRotation = currentPageIndex
        rotating = true

        // In iOS 7 the nav bar gets shown after rotation, but might as well do this for everything!
        if areControlsHidden {
            // Force hidden
            navigationController?.isNavigationBarHidden = true
        }

        coordinator.animate(alongsideTransition: { (context) in
            self.toolbar.frame = self.frameForToolbar

            // Perform layout
            self.currentPageIndex = self.pageIndexBeforeRotation

            // Delay control holding
            self.hideControlsAfterDelay()

            // Layout
            self.layoutVisiblePages()
        }) { (context) in
            self.rotating = false
            // Ensure nav bar isn't re-displayed
            if let navi = self.navigationController, self.areControlsHidden {
                navi.isNavigationBarHidden = true
            }
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    open func performLayout() {
        // Setup
        performingLayout = true
        let photos = numberOfMedias
        
        // Setup pages
        visiblePages.removeAll()
        recycledPages.removeAll()
        
        // Navigation buttons
        if let navi = navigationController {
            if navi.viewControllers.count > 0 && navi.viewControllers[0] == self {
                // We're first on stack so show done button
                doneButton = UIBarButtonItem(
                    title: NSLocalizedString("Done", comment: ""),
                    style: .done,
                    target: self,
                    action: #selector(doneButtonPressed))

                // Set appearance
                if let done = doneButton {
                    done.setBackgroundImage(nil, for: .normal, barMetrics: .default)
                    done.setBackgroundImage(nil, for: .highlighted, barMetrics: .compact)
                    
                    self.navigationItem.rightBarButtonItem = done
                }
            } else {
                // We're not first so show back button
                if let navi = navigationController, let previousViewController = navi.viewControllers[navi.viewControllers.count - 2] as? UINavigationController {
                    let backButtonTitle = previousViewController.navigationItem.backBarButtonItem != nil ?
                        previousViewController.navigationItem.backBarButtonItem!.title :
                        previousViewController.title
                    
                    let newBackButton = UIBarButtonItem(title: backButtonTitle, style: .plain, target: nil, action: nil)
                    
                    // Appearance
                    newBackButton.setBackButtonBackgroundImage(nil, for: .normal, barMetrics: .default)
                    newBackButton.setBackButtonBackgroundImage(nil, for: .highlighted, barMetrics: .compact)
//                    newBackButton.setTitleTextAttributes([String : AnyObject](), for: .normal)
//                    newBackButton.setTitleTextAttributes([String : AnyObject](), for: .highlighted)
                    
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
                image: UIImage.imageForResourcePath(name: "UIBarButtonItemGrid", inBundle: Bundle(for: MediaBrowser.self)),
                style: .plain,
                target: self,
                action: #selector(MediaBrowser.showGridAnimated)))
        } else {
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
        } else {
            items.append(flexSpace)
        }

        // Right - Action
        if actionButton != nil && !(!hasItems && nil == navigationItem.rightBarButtonItem) {
            items.append(actionButton!)
        } else {
            // We're falset showing the toolbar so try and show in top right
            if actionButton != nil {
                // only show Action button on top right if this place is empty (no Done button there)
                if nil == self.navigationItem.rightBarButtonItem {
                	navigationItem.rightBarButtonItem = actionButton!
                }
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
        } else {
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
        } else {
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

    /**
     viewWillAppear
     
     - Parameter animated: Bool
     */
    open override func viewWillAppear(_ animated: Bool) {
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
        
        // Navigation bar appearance
        if !viewIsActive && navigationController?.viewControllers[0] as? MediaBrowser !== self {
            storePreviousNavBarAppearance()
        }
        
        // Set style
        if !leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            previousStatusBarStyle = UIApplication.shared.statusBarStyle
            UIApplication.shared.setStatusBarStyle(statusBarStyle, animated: animated)
        }

        setNavBarAppearance(animated: animated)
        
        // Update UI
        if hideControlsOnStartup {
            hideControls()
        } else {
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
        
        self.view.setNeedsLayout()
    }

    /**
     view Did Appear
     
     - Parameter animated: Bool
     */
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewIsActive = true
        
        // Autoplay if first is video
        if !viewHasAppearedInitially && autoPlayOnAppear {
            if let photo = mediaAtIndex(index: currentPageIndex) {
                if photo.isVideo {
                    playVideoAtIndex(index: currentPageIndex)
                }
            }
        }
        
        viewHasAppearedInitially = true
    }

    /**
     view will disappear
     
     - Parameter animated: Bool
     */
    open override func viewWillDisappear(_ animated: Bool) {
        // Detect if rotation occurs while we're presenting a modal
        pageIndexBeforeRotation = currentPageIndex
        
        // Check that we're being popped for good
        if let viewControllers = navigationController?.viewControllers, viewControllers[0] !== self {
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

    /**
     will move toParentViewController
     
     - Parameter parent: UIViewController
     */
    open override func willMove(toParent parent: UIViewController?) {
        if parent != nil && hasBelongedToViewController {
            fatalError("MediaBrowser Instance Reuse")
        }

        if let navBar = navigationController?.navigationBar, didSavePreviousStateOfNavBar, parent == nil {
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:previousNavigationBarTextColor ?? UIColor.black]
            navBar.backgroundColor = previousNavigationBarBackgroundColor
            if previousNavigationBarTintColor != nil {
                navBar.barTintColor = previousNavigationBarTintColor
            }
            navBar.tintColor = previousNavigationBarTextColor
        }
    }
    
    /**
     did move toParentViewController
     
     - Parameter parent: UIViewController
     */
    open override func didMove(toParent parent: UIViewController?) {
        if nil == parent {
            hasBelongedToViewController = true
        }

    }

    //MARK: - Nav Bar Appearance
    func setNavBarAppearance(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    
        if let navBar = navigationController?.navigationBar {
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:navigationBarTextColor]
            navBar.backgroundColor = navigationBarBackgroundColor
            navBar.tintColor = navigationBarTextColor
            navBar.barTintColor = navigationBarTintColor
            navBar.shadowImage = nil
            navBar.isTranslucent = navigationBarTranslucent
            navBar.barStyle = navigationBarStyle
        }
    }

    func storePreviousNavBarAppearance() {
        didSavePreviousStateOfNavBar = true
        
        if let navi = navigationController {
            previousNavigationBarTintColor = navi.navigationBar.barTintColor
            previousNavigationBarBackgroundColor = navi.navigationBar.backgroundColor
            previousNavigationBarTranslucent = navi.navigationBar.isTranslucent
            previousNavigationBarTextColor = navi.navigationBar.tintColor
            previousNavigationBarHidden = navi.isNavigationBarHidden
            previousNavigationBarStyle = navi.navigationBar.barStyle
        }
    }

    func restorePreviousNavBarAppearance(animated: Bool) {
        if let navi = navigationController, didSavePreviousStateOfNavBar {
            navi.setNavigationBarHidden(previousNavigationBarHidden, animated: animated)
            
            let navBar = navi.navigationBar
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:previousNavigationBarTextColor ?? UIColor.black]
            navBar.backgroundColor = previousNavigationBarBackgroundColor
            navBar.tintColor = previousNavigationBarTextColor
            navBar.isTranslucent = previousNavigationBarTranslucent
            navBar.barTintColor = previousNavigationBarTintColor
            navBar.barStyle = previousNavigationBarStyle

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
    /// viewWillLayoutSubviews
    open override func viewWillLayoutSubviews() {
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
    /// supported interface orientations
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    //MARK: - Data
    var currentIndex: Int {
        return currentPageIndex
    }

    open func reloadData() {
        // Reset
        mediaCount = -1
        
        // Get data
        let mediaNum = numberOfMedias
        releaseAllUnderlyingPhotos(preserveCurrent: true)
        mediaArray.removeAll()
        thumbMedias.removeAll()
        
        if mediaNum < 1 { return }
        
        for _ in 0...(mediaNum - 1) {
            mediaArray.append(nil)
            thumbMedias.append(nil)
        }

        // Update current page index
        if numberOfMedias > 0 {
            currentPageIndex = max(0, min(currentPageIndex, mediaNum - 1))
        } else {
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

    var numberOfMedias: Int {
        if mediaCount == -1 {
            if let d = delegate {
                mediaCount = d.numberOfMedia(in: self)
            }
            
            if let fpa = fixedMediasArray {
                mediaCount = fpa.count
            }
        }
        
        if -1 == mediaCount {
            mediaCount = 0
        }

        return mediaCount
    }

    func mediaAtIndex(index: Int) -> Media? {
        var media: Media? = nil
        
        if index < mediaArray.count && index >= 0 {
            if mediaArray[index] == nil {
                if let d = delegate {
                    media = d.media(for: self, at: index)
                    
                    if nil == media && fixedMediasArray != nil && index < fixedMediasArray!.count {
                        media = fixedMediasArray![index]
                    }
                    media?.placeholderImage = self.placeholderImage?.image
                    
                    if media != nil {
                        mediaArray[index] = media
                    }
                }
            } else {
                media = mediaArray[index]
                media?.placeholderImage = self.placeholderImage?.image
            }
        }
        
        return media
    }

    func thumbPhotoAtIndex(index: Int) -> Media? {
        var media: Media?
        
        if index < thumbMedias.count {
            if nil == thumbMedias[index] {
                if let d = delegate {
                    media = d.thumbnail(for: self, at: index)
                
                    if let p = media {
                        thumbMedias[index] = p
                    }
                }
            } else {
                media = thumbMedias[index]
            }
        }
        
        return media
    }

    func captionViewForPhotoAtIndex(index: Int) -> MediaCaptionView? {
        var captionView: MediaCaptionView?
        
        if let d = delegate {
            captionView = d.captionView(for: self, at: index)
            
            if let p = mediaAtIndex(index: index), nil == captionView {
                if p.caption.count > 0 {
                    captionView = MediaCaptionView(media: p)
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
                value = d.isMediaSelected(at: index, in: self)
            }
        }
        
        return value
    }

    func setPhotoSelected(selected: Bool, atIndex index: Int) {
        if displaySelectionButtons {
            if let d = delegate {
                d.mediaDid(selected: selected, at: index, in: self)
            }
        }
    }

    func image(for media: Media?) -> UIImage? {
        if let p = media {
            // Get image or obtain in background
            if let img = p.underlyingImage {
                return img
            } else {
                p.loadUnderlyingImageAndNotify()
            }
        }
        
        return self.placeholderImage?.image
    }

    func loadAdjacentPhotosIfNecessary(photo: Media) {
        let page = pageDisplayingPhoto(photo: photo)
        if let p = page {
            // If page is current page then initiate loading of previous and next pages
            let pageIndex = p.index
            if currentPageIndex == pageIndex {
                if pageIndex > 0  && mediaArray.count >= cachingImageCount {
                    // Preload index - 1
                    for i in 1...cachingImageCount {
                        if let media = mediaAtIndex(index: pageIndex - i) {
                            if nil == media.underlyingImage {
                                media.loadUnderlyingImageAndNotify()
                                print("Pre-loading image at index \(pageIndex - i)")
                            }
                        }
                    }
                }

                if pageIndex < numberOfMedias - 1 {
                    // Preload index + 1
                    for i in 1...cachingImageCount {
                        if let media = mediaAtIndex(index: pageIndex + i) {
                            if nil == media.underlyingImage {
                                media.loadUnderlyingImageAndNotify()
                                print("Pre-loading image at index \(pageIndex + i)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func startPreCaching() {
        if let d = delegate {
            let media = d.media(for: self, at: currentPageIndex)
            media.loadUnderlyingImageAndNotify()

        } else {
            fatalError("Set delegate first for pre-caching")
        }
    }

    //MARK: - Media Loading falsetification
    @objc func handlePhotoLoadingDidEndNotification(notification: NSNotification) {
        if let photo = notification.object as? Media {
            if let page = pageDisplayingPhoto(photo: photo) {
                if photo.underlyingImage != nil {
                    // Successful load
                    page.displayImage()
                    loadAdjacentPhotosIfNecessary(photo: photo)
                } else {
                    // Failed to load
                    page.displayImageFailure()
                }
                // Update nav
                updateNavigation()
            }
        }
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
        return CGSize(width: bounds.size.width * CGFloat(numberOfMedias), height: bounds.size.height)
    }

    func contentOffsetForPageAtIndex(index: Int) -> CGPoint {
        let pageWidth = pagingScrollView.bounds.size.width
        let newOffset = CGFloat(index) * pageWidth
        return CGPoint(x: newOffset, y: 0)
    }

    var frameForToolbar: CGRect {
        var height: CGFloat = 44.0
        var safeAreaBottomInset: CGFloat = 0
        
        if #available(iOS 11, *) {
            safeAreaBottomInset = view.safeAreaInsets.bottom
        }

        if view.bounds.height < 768.0 && view.bounds.height < view.bounds.width {
            height = 32.0
        }

        let y = view.bounds.size.height - height - safeAreaBottomInset
        let width = view.bounds.size.width

        return CGRect(x: 0.0, y: y, width: width, height: height).integral
    }

    func frameForCaptionView(captionView: MediaCaptionView?, index: Int) -> CGRect {
        if let cw = captionView {
            let pageFrame = frameForPageAtIndex(index: index)
            let captionSize = cw.sizeThatFits(CGSize(width: pageFrame.size.width, height: 0.0))
            
            var safeAreaBottomInset: CGFloat = 0
            if #available(iOS 11.0, *) {
                safeAreaBottomInset = self.view.safeAreaInsets.bottom
            }
            
            let captionFrame = CGRect(
                x: pageFrame.origin.x,
                y: pageFrame.size.height - safeAreaBottomInset - captionSize.height - (toolbar.superview != nil ? toolbar.frame.size.height : 0.0),
                width: pageFrame.size.width,
                height: captionSize.height)
            
            return captionFrame.integral
        }
        
        return CGRect.zero
    }

    func frameForSelectedButton(selectedButton: UIButton, atIndex index: Int) -> CGRect {
        let pageFrame = frameForPageAtIndex(index: index)
        let padding: CGFloat = 20.0
        var yOffset: CGFloat = 0.0
        
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
    
    //MARK: - Navigation
    
    open func updateNavigation() {
        // Title
        let medias = numberOfMedias
        if let gc = gridController {
            if gc.selectionMode {
                self.title = NSLocalizedString("Select Photos", comment: "")
                if let ab = actionButton {
                    // only show Action button on top right if this place is empty (no Done button there)
                    if nil == self.navigationItem.rightBarButtonItem {
                        self.navigationItem.rightBarButtonItem = ab
                    }
                }
            } else {
                let photosText: String
                
                if 1 == medias {
                    photosText = NSLocalizedString("photo", comment: "Used in the context: '1 photo'")
                } else {
                    photosText = NSLocalizedString("photos", comment: "Used in the context: '3 photos'")
                }
                
                title = "\(medias) \(photosText)"
            }
        } else if medias > 1 {
            if let d = delegate {
                title = d.title(for: self, at: currentPageIndex)
            }
            
            if nil == title {
                let str = NSLocalizedString("of", comment: "Used in the context: 'Showing 1 of 3 items'")
                title = "\(currentPageIndex + 1) \(str) \(numberOfMedias)"
            }
        } else {
            title = nil
        }
        
        // Buttons
        if let prev = previousButton {
            prev.isEnabled = (currentPageIndex > 0)
        }
        
        if let next = nextButton {
            next.isEnabled = (currentPageIndex < medias - 1)
        }
        
        // Disable action button if there is false image or it's a video
        if let ab = actionButton {
            let photo = mediaAtIndex(index: currentPageIndex)
            
            if photo != nil && (photo!.underlyingImage == nil || photo!.isVideo) {
                ab.isEnabled = false
                ab.tintColor = UIColor.clear // Tint to hide button
            } else {
                ab.isEnabled = true
                ab.tintColor = nil
            }
        }
    }
    
    func jumpToPageAtIndex(index: Int, animated: Bool) {
        // Change page
        if index < numberOfMedias {
            let pageFrame = frameForPageAtIndex(index: index)
            pagingScrollView.setContentOffset(CGPoint(x: pageFrame.origin.x - padding, y: 0), animated: animated)
            updateNavigation()
        }
        
        // Update timer to give more time
        hideControlsAfterDelay()
    }
    
    @objc func gotoPreviousPage() {
        showPreviousPhotoAnimated(animated: false)
    }
    
    @objc func gotoNextPage() {
        showNextPhotoAnimated(animated: false)
    }
    
    func showPreviousPhotoAnimated(animated: Bool) {
        jumpToPageAtIndex(index: currentPageIndex - 1, animated: animated)
    }
    
    func showNextPhotoAnimated(animated: Bool) {
        jumpToPageAtIndex(index: currentPageIndex + 1, animated: animated)
    }
    
    //MARK: - Interactions
    
    @objc func selectedButtonTapped(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        var index = Int.max
        for page in visiblePages {
            if page.selectedButton == sender {
                index = page.index
                break
            }
        }
        
        if index != Int.max {
            setPhotoSelected(selected: sender.isSelected, atIndex: index)
        }
    }
    
    @objc func playButtonTapped(sender: UIButton) {
        var index = Int.max
        
        for page in visiblePages {
            if page.playButton == sender {
                index = page.index
                break
            }
        }
        
        if index != Int.max {
            if nil == currentVideoPlayerViewController.player {
                playVideoAtIndex(index: index)
            }
        }
    }
    
    //MARK: - Video
    
    func playVideoAtIndex(index: Int) {
        let photo = mediaAtIndex(index: index)
        
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
                } else {
                    self.setVideoLoadingIndicatorVisible(visible: false, atPageIndex: index)
                }
            }
        }
    }
    
    func playVideo(videoURL: URL, atPhotoIndex index: Int) {
        // Setup player
        
        if let accessToken = delegate?.accessToken(for: videoURL) {
            let headerFields: [String: String] = ["Authorization": accessToken]
            let urlAsset = AVURLAsset(url: videoURL, options: ["AVURLAssetHTTPHeaderFieldsKey": headerFields])
            let playerItem = AVPlayerItem(asset: urlAsset)
            currentVideoPlayerViewController.player = AVPlayer(playerItem: playerItem)
        } else {
            currentVideoPlayerViewController.player = AVPlayer(url: videoURL)
        }
        
        if #available(iOS 9.0, *) {
            currentVideoPlayerViewController.allowsPictureInPicturePlayback = false
        } else {
            // Fallback on earlier versions
        }
        
        if let player = currentVideoPlayerViewController.player {
            
            do {
                if #available(iOS 10.0, *) {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                }
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error as NSError {
                print(error)
            }
            
            NotificationCenter.default.removeObserver(
                self,
                name:NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: player.currentItem
            )
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(videoFinishedCallback),
                name:NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: player.currentItem
            )
            
            // Remove the movie player view controller from the "playback did finish" falsetification observers
            // Observe ourselves so we can get it to use the crossfade transition
            //            NotificationCenter.default.removeObserver(
            //                player,
            //                name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish,
            //                object: player.moviePlayer)
            //
            //            NotificationCenter.default.addObserver(
            //                self,
            //                selector: #selector(videoFinishedCallback),
            //                name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish,
            //                object: player.moviePlayer)
            
            // Show
            present(currentVideoPlayerViewController, animated: true, completion: {
                player.play()
            })
        }
    }
    
    @objc func videoFinishedCallback(notification: NSNotification) {
        if let player = currentVideoPlayerViewController.player {
            // Remove observer
            NotificationCenter.default.removeObserver(
                self,
                name:NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: player.currentItem
            )
            
            // Clear up
            clearCurrentVideo()
            
            // Dismiss
            //            if let errorObj = notification.userInfo?[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] {
            //                let error = MPMovieFinishReason(rawValue: errorObj as! Int)
            //
            //                if error == .playbackError {
            //                    // Error occured so dismiss with a delay incase error was immediate and we need to wait to dismiss the VC
            //
            //                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(1.0 * Double(NSEC_PER_SEC)), execute: {
            //                        self.dismiss(animated: true, completion: nil)
            //
            //                    })
            //
            //                    return
            //                }
            //            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func clearCurrentVideo() {
        if let player = currentVideoPlayerViewController.player {
            player.replaceCurrentItem(with: nil)
            currentVideoPlayerViewController.dismiss(animated: true, completion: nil)
            currentVideoLoadingIndicator?.removeFromSuperview()
            currentVideoPlayerViewController.player = nil
            currentVideoLoadingIndicator = nil
            currentVideoIndex = Int.max
        }
    }
    
    func setVideoLoadingIndicatorVisible(visible: Bool, atPageIndex: Int) {
        if currentVideoLoadingIndicator != nil && !visible {
            currentVideoLoadingIndicator?.removeFromSuperview()
            currentVideoLoadingIndicator = nil
        } else if currentVideoLoadingIndicator == nil && visible {
            currentVideoLoadingIndicator = UIActivityIndicatorView(frame: CGRect.zero)
            currentVideoLoadingIndicator?.sizeToFit()
            currentVideoLoadingIndicator?.startAnimating()
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
    
    @objc func showGridAnimated() {
        showGrid(animated: true)
    }
    
    func showGrid(animated: Bool) {
        if gridController != nil {
            return
        }
        
        // Init grid controller
        gridController = MediaGridViewController()
        
        if let gc = gridController {
            let bounds = view.bounds
            
            gc.initialContentOffset = currentGridContentOffset
            gc.browser = self
            gc.selectionMode = displaySelectionButtons
            gc.view.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            gc.view.alpha = 0.0
            
            // Stop specific layout being triggered
            skipNextPagingScrollViewPositioning = true
            
            // Add as a child view controller
            addChild(gc)
            view.addSubview(gc.view)
            
            // Perform any adjustments
            gc.view.layoutIfNeeded()
            gc.adjustOffsetsAsRequired()
            
            // Hide action button on nav bar if it exists
            if navigationItem.rightBarButtonItem == actionButton {
                gridPreviousRightNavItem = actionButton
                navigationItem.setRightBarButton(nil, animated: true)
            } else {
                gridPreviousRightNavItem = nil
            }
            
            // Update
            updateNavigation()
            setControlsHidden(hidden: false, animated: true, permanent: true)
            
            // Animate grid in and photo scroller out
            gc.willMove(toParent: self)
            
            let changes: () -> Void = {
                gc.view.alpha = 1.0
                self.pagingScrollView.alpha = 0.0
            }
            
            let completion: (Bool) -> Void = { _ in
                gc.didMove(toParent: self)
            }
            
            if disableGridAnimations {
                changes()
                completion(true)
            } else {
                UIView.animate(
                    withDuration: animated ? 0.3 : 0,
                    animations: changes,
                    completion: completion)
            }
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
            
            let changes: () -> Void = {
                gc.view.alpha = 0.0
                self.pagingScrollView.alpha = 1.0
            }
            
            let completion: (Bool) -> Void = { _ in
                gc.willMove(toParent: nil)
                gc.view.removeFromSuperview()
                gc.removeFromParent()
                
                self.setControlsHidden(hidden: false, animated: true, permanent: false) // retrigger timer
            }
            
            if disableGridAnimations {
                changes()
                completion(true)
            } else {
                // Animate, hide grid and show paging scroll view
                UIView.animate(
                    withDuration: 0.3,
                    animations: changes,
                    completion: completion)
            }
        }
    }
    
    //MARK: - Control Hiding / Showing
    
    // If permanent then we don't set timers to hide again
    func setControlsHidden( hidden: Bool, animated: Bool, permanent: Bool) {
        // Force visible
        var hidden = hidden
        if 0 == numberOfMedias || gridController != nil || alwaysShowControls {
            hidden = false
        }
        
        // Cancel any timers
        cancelControlHiding()
        
        // Animations & positions
        let animatonOffset = CGFloat(20)
        let animationDuration = CFTimeInterval(animated ? 0.35 : 0.0)
        
        // Navigation bar
        if viewIsActive, !hidden {
            self.navigationController?.setNavigationBarHidden(hidden, animated: true)
        }
        
        // Status bar
        if !leaveStatusBarAlone {
            // Hide status bar
            if !isVCBasedStatusBarAppearance {
                // falsen-view controller based
                statusBarShouldBeHidden = hidden
                UIApplication.shared.setStatusBarHidden(hidden, with: animated ? UIStatusBarAnimation.slide : UIStatusBarAnimation.none)
                
            } else {
                // View controller based so animate away
                statusBarShouldBeHidden = hidden
                UIView.animate(
                    withDuration: hidden ? 0.1 : animationDuration,
                    animations: {
                        self.setNeedsStatusBarAppearanceUpdate()
                })
            }
        }
        
        // Navigation bar
        if viewIsActive, hidden {
            self.navigationController?.setNavigationBarHidden(hidden, animated: true)
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
            
            // Toolbar
            self.toolbar.frame = self.frameForToolbar
            
            if hidden {
                self.toolbar.frame = self.toolbar.frame.offsetBy(dx: 0, dy: animatonOffset)
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
    
    /// prefersStatusBarHidden
    open override var prefersStatusBarHidden: Bool {
        if !leaveStatusBarAlone {
            return statusBarShouldBeHidden
        }
        
        return presentingViewControllerPrefersStatusBarHidden
    }
    
    /// preferredStatusBarUpdateAnimation
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle
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
                selector: #selector(MediaBrowser.hideControls),
                userInfo: nil,
                repeats: false)
        }
    }
    
    var areControlsHidden: Bool {
        return 0.0 == toolbar.alpha
    }
    
    @objc func hideControls() {
        setControlsHidden(hidden: true, animated: true, permanent: false)
    }
    
    func showControls() {
        setControlsHidden(hidden: false, animated: true, permanent: false)
    }
    
    @objc func toggleControls() {
        setControlsHidden(hidden: !areControlsHidden, animated: true, permanent: false)
    }
    
    //MARK: - Properties
    
    var currentPhotoIndex: Int {
        set(i) {
            var index = i
            
            // Validate
            let photoCount = numberOfMedias
            
            if 0 == photoCount {
                index = 0
            } else if index >= photoCount {
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
    
    @objc func doneButtonPressed(sender: AnyObject) {
        // See if we actually just want to show/hide grid
        if enableGrid {
            if startOnGrid && nil == gridController {
                showGrid(animated: true)
                return
            } else if !startOnGrid && gridController != nil {
                hideGrid()
                return
            }
        }
        
        // Dismiss view controller
        // Call delegate method and let them dismiss us
        if let d = delegate {
            d.mediaBrowserDidFinishModalPresentation(mediaBrowser: self)
        }
        // dismissViewControllerAnimated:true completion:nil]
    }
    
    //MARK: - Actions
    
    @objc func actionButtonPressed(_ sender: Any) {
        // Let delegate handle things
        if let d = delegate {
            d.actionButtonPressed(at: currentPageIndex, in: self, sender: sender)
        }
    }
    
    internal func defaultActionForMedia(atIndex index: Int) {
        // Only react when image has loaded
        if let photo = mediaAtIndex(index: index) {
            if numberOfMedias > 0 && photo.underlyingImage != nil {
                // Show activity view controller
                var items: [Any] = [Any]()
                if let image = photo.underlyingImage {
                    items.append(image)
                }
                if photo.caption != "" {
                    items.append(photo.caption)
                }
                activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                
                // Show
                if let vc = self.activityViewController {
                    vc.completionWithItemsHandler = { [weak self] (activityType, completed, returnedItems, activityError) in
                        guard let wself = self else { return }
                        
                        wself.activityViewController = nil
                        wself.hideControlsAfterDelay()
                    }
                    vc.popoverPresentationController?.barButtonItem = actionButton
                    
                    self.present(vc, animated: true, completion: nil)
                }
                
                // Keep controls hidden
                setControlsHidden(hidden: false, animated: true, permanent: true)
            }
        }
    }
}

extension MediaBrowser: UIActionSheetDelegate {

}
