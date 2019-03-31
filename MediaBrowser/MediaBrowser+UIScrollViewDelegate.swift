//
//  MediaBrowser+UIScrollViewDelegate.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 31/03/2019.
//  Copyright © 2019 Seungyoun Yi. All rights reserved.
//

import Foundation

extension MediaBrowser: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !viewIsActive || performingLayout || rotating {
            return
        }
        
        tilePages()
        
        let visibleBounds = pagingScrollView.bounds
        var index = Int(floorf(Float(visibleBounds.midX / visibleBounds.width)))
        if index < 0 {
            index = 0
        }
        
        if index > numberOfMedias - 1 {
            index = numberOfMedias - 1
        }
        
        let previousCurrentPage = currentPageIndex
        currentPageIndex = index
        
        if currentPageIndex != previousCurrentPage {
            didStartViewingPageAtIndex(index: index)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        setControlsHidden(hidden: true, animated: true, permanent: false)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateNavigation()
    }
}
