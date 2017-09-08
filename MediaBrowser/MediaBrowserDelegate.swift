//
//  PhotoBrowserDelegate.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//

import UIKit

public protocol MediaBrowserDelegate: class {
    func numberOfMedia(in mediaBrowser: MediaBrowser) -> Int
    
    func media(at index: Int, mediaBrowser: MediaBrowser) -> Media
    
    func thumbnail(at index: Int, mediaBrowser: MediaBrowser) -> Media
    
    func captionViewForMediaAtIndex(index: Int, mediaBrowser: MediaBrowser) -> MediaCaptionView?
    
    func titleForMediaAtIndex(index: Int, mediaBrowser: MediaBrowser) -> String
    
    func didDisplayMediaAtIndex(index: Int, mediaBrowser: MediaBrowser)
    
    func actionButtonPressedForPhotoAtIndex(index: Int, mediaBrowser: MediaBrowser)
    
    func isMediaSelectedAtIndex(index: Int, mediaBrowser: MediaBrowser) -> Bool
    
    func selectedChanged(selected: Bool, index: Int, mediaBrowser: MediaBrowser)
    
    func mediaBrowserDidFinishModalPresentation(mediaBrowser: MediaBrowser)
}

public extension MediaBrowserDelegate {
    func captionViewForMediaAtIndex(index: Int, mediaBrowser: MediaBrowser) -> MediaCaptionView? {
        return nil
    }
    
    func didDisplayMediaAtIndex(index: Int, mediaBrowser: MediaBrowser) {
        
    }
    
    func actionButtonPressedForPhotoAtIndex(index: Int, mediaBrowser: MediaBrowser) {
        
    }
    
    func isMediaSelectedAtIndex(index: Int, mediaBrowser: MediaBrowser) -> Bool {
        return false
    }
    
    func selectedChanged(selected: Bool, index: Int, mediaBrowser: MediaBrowser) {
        
    }
    
    func titleForMediaAtIndex(index: Int, mediaBrowser: MediaBrowser) -> String {
        return ""
    }
}
