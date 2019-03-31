//
//  MediaBrowser+Paging.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 31/03/2019.
//  Copyright © 2019 Seungyoun Yi. All rights reserved.
//

import Foundation
extension MediaBrowser {
    /**
     setCurrentIndex to show first.
     When precaching, set this method first.
     
     - Parameter index:  Int
     */
    public func setCurrentIndex(at index: Int) {
        var internalIndex = index
        let mediaCount = self.numberOfMedias
        if mediaCount == 0 {
            internalIndex = 0
        } else {
            if index >= mediaCount {
                internalIndex = self.numberOfMedias - 1
            }
        }
        
        currentPageIndex = internalIndex
        if self.isViewLoaded {
            self.jumpToPageAtIndex(index: internalIndex, animated: false)
            if !viewIsActive {
                self.tilePages() // Force tiling if view is not visible
            }
        }
    }
    
    func tilePages() {
        // Calculate which pages should be visible
        // Ignore padding as paging bounces encroach on that
        // and lead to false page loads
        let visibleBounds = pagingScrollView.bounds
        var iFirstIndex = Int(floorf(Float((visibleBounds.minX + padding * 2.0) / visibleBounds.width)))
        var iLastIndex  = Int(floorf(Float((visibleBounds.maxX - padding * 2.0 - 1.0) / visibleBounds.width)))
        
        if iFirstIndex < 0 {
            iFirstIndex = 0
        }
        
        if iFirstIndex > numberOfMedias - 1 {
            iFirstIndex = numberOfMedias - 1
        }
        
        if iLastIndex < 0 {
            iLastIndex = 0
        }
        
        if iLastIndex > numberOfMedias - 1 {
            iLastIndex = numberOfMedias - 1
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
        // 확인 필요!
        visiblePages = visiblePages.subtracting(recycledPages)
        
        while recycledPages.count > 2 { // Only keep 2 recycled pages
            recycledPages.remove(recycledPages.first!)
        }
        
        // Add missing pages
        for index in iFirstIndex...iLastIndex {
            if !isDisplayingPageForIndex(index: index) {
                // Add new page
                var p = dequeueRecycledPage
                if nil == p {
                    p = MediaZoomingScrollView(mediaBrowser: self)
                }
                
                let page = p!
                
                page.loadingIndicator.innerRingColor = loadingIndicatorInnerRingColor
                page.loadingIndicator.outerRingColor = loadingIndicatorOuterRingColor
                page.loadingIndicator.innerRingWidth = loadingIndicatorInnerRingWidth
                page.loadingIndicator.outerRingWidth = loadingIndicatorOuterRingWidth
                page.loadingIndicator.font = loadingIndicatorFont
                page.loadingIndicator.fontColor = loadingIndicatorFontColor
                page.loadingIndicator.shouldShowValueText = loadingIndicatorShouldShowValueText
                
                visiblePages.insert(page)
                configurePage(page: page, forIndex: index)
                setPlaceholderForPage(page: page, forIndex: index)
                
                pagingScrollView.addSubview(page)
                
                // Add caption
                if let captionView = captionViewForPhotoAtIndex(index: index) {
                    captionView.frame = frameForCaptionView(captionView: captionView, index: index)
                    pagingScrollView.addSubview(captionView)
                    page.captionView = captionView
                }
                
                // Add play button if needed
                if page.displayingVideo() {
                    let playButton = UIButton(type: .custom)
                    playButton.setImage(UIImage(named: "PlayButtonOverlayLarge", in: Bundle(for: MediaBrowser.self), compatibleWith: nil), for: .normal)
                    playButton.setImage(UIImage(named: "PlayButtonOverlayLargeTap", in: Bundle(for: MediaBrowser.self), compatibleWith: nil), for: .highlighted)
                    playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
                    playButton.sizeToFit()
                    playButton.frame = frameForPlayButton(playButton: playButton, atIndex: index)
                    pagingScrollView.addSubview(playButton)
                    page.playButton = playButton
                }
                
                // Add selected button
                if self.displaySelectionButtons {
                    let selectedButton = UIButton(type: .custom)
                    if let selectedOffImage = mediaSelectedOffIcon {
                        selectedButton.setImage(selectedOffImage, for: .normal)
                    } else {
                        selectedButton.setImage(UIImage(named: "ImageSelectedSmallOff", in: Bundle(for: MediaBrowser.self), compatibleWith: nil), for: .normal)
                    }
                    
                    if let selectedOnImage = mediaSelectedOnIcon {
                        selectedButton.setImage(selectedOnImage, for: .selected)
                    } else {
                        selectedButton.setImage(UIImage(named: "ImageSelectedSmallOn", in: Bundle(for: MediaBrowser.self), compatibleWith: nil), for: .selected)
                    }
                    
                    selectedButton.sizeToFit()
                    selectedButton.adjustsImageWhenHighlighted = false
                    selectedButton.addTarget(self, action: #selector(selectedButtonTapped), for: .touchUpInside)
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
    
    func pageDisplayedAtIndex(index: Int) -> MediaZoomingScrollView? {
        var thePage: MediaZoomingScrollView?
        for page in visiblePages {
            if page.index == index {
                thePage = page
                break
            }
        }
        return thePage
    }
    
    func pageDisplayingPhoto(photo: Media) -> MediaZoomingScrollView? {
        var thePage: MediaZoomingScrollView?
        for page in visiblePages {
            if let _media = page.photo, _media.equals(photo: photo) {
                thePage = page
                break
            }
        }
        return thePage
    }
    
    func configurePage(page: MediaZoomingScrollView, forIndex index: Int) {
        page.frame = frameForPageAtIndex(index: index)
        page.index = index
        page.photo = mediaAtIndex(index: index)
        //        page.backgroundColor = areControlsHidden ? UIColor.black : UIColor.white
    }
    
    func setPlaceholderForPage(page: MediaZoomingScrollView, forIndex index: Int) {
        if let placeholder = self.placeholderImage {
            if placeholder.isAppliedForAll || (!placeholder.isAppliedForAll && index == self.currentPageIndex) {
                if page.photoImageView.image == nil || page.photoImageView.image === placeholder.image {
                    page.photoImageView.image = self.placeholderImage?.image
                    page.photoImageView.transform = CGAffineTransform.identity
                    page.photoImageView.alpha = 0.8
                    page.alignCenterMedia()
                    
                    // Set zoom to minimum zoom
                    page.setMaxMinZoomScalesForCurrentBounds()
                }
            }
        }
    }
    
    var dequeueRecycledPage: MediaZoomingScrollView? {
        let page = recycledPages.first
        if let p = page {
            recycledPages.remove(p)
        }
        return page
    }
    
    // Handle page changes
    func didStartViewingPageAtIndex(index: Int) {
        // Handle 0 photos
        if 0 == numberOfMedias {
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
                    if let media = mediaArray[i] {
                        media.unloadUnderlyingImage()
                        mediaArray[i] = nil
                        
                        //MWLog.log("Released underlying image at index \(i)")
                    }
                }
            }
        }
        
        if index < numberOfMedias - 1 {
            // Release anything > index + 1
            if index + 2 <= mediaArray.count - 1 {
                for i in (index + 2)...(mediaArray.count - 1) {
                    if let media = mediaArray[i] {
                        media.unloadUnderlyingImage()
                        mediaArray[i] = nil
                        
                        //MWLog.log("Released underlying image at index \(i)")
                    }
                }
            }
        }
        
        // Load adjacent images if needed and the photo is already
        // loaded. Also called after photo has been loaded in background
        let currentPhoto = mediaAtIndex(index: index)
        
        if let cp = currentPhoto {
            if cp.underlyingImage != nil {
                // photo loaded so load ajacent falsew
                loadAdjacentPhotosIfNecessary(photo: cp)
            }
        }
        
        // Notify delegate
        if index != previousPageIndex {
            if let d = delegate {
                d.didDisplayMedia(at: index, in: self)
            }
            previousPageIndex = index
        }
        
        // Update nav
        updateNavigation()
    }
}
