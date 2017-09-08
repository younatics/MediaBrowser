//
//  PhotoBrowserDelegate.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//

import UIKit

public protocol MediaBrowserDelegate: class {
    func numberOfPhotosInPhotoBrowser(mediaBrowser: MediaBrowser) -> Int
    
    func photoAtIndex(index: Int, mediaBrowser: MediaBrowser) -> Media
    
    func thumbPhotoAtIndex(index: Int, mediaBrowser: MediaBrowser) -> Media
    
    func captionViewForPhotoAtIndex(index: Int, mediaBrowser: MediaBrowser) -> CaptionView?
    
    func titleForPhotoAtIndex(index: Int, mediaBrowser: MediaBrowser) -> String
    
    func didDisplayPhotoAtIndex(index: Int, mediaBrowser: MediaBrowser)
    
    func actionButtonPressedForPhotoAtIndex(index: Int, mediaBrowser: MediaBrowser)
    
    func isPhotoSelectedAtIndex(index: Int, mediaBrowser: MediaBrowser) -> Bool
    
    func selectedChanged(selected: Bool, index: Int, mediaBrowser: MediaBrowser)
    
    func photoBrowserDidFinishModalPresentation(mediaBrowser: MediaBrowser)
}

public extension MediaBrowserDelegate {
    func captionViewForPhotoAtIndex(index: Int, mediaBrowser: MediaBrowser) -> CaptionView? {
        return nil
    }
    
    func didDisplayPhotoAtIndex(index: Int, mediaBrowser: MediaBrowser) {
        
    }
    
    func actionButtonPressedForPhotoAtIndex(index: Int, mediaBrowser: MediaBrowser) {
        
    }
    
    func isPhotoSelectedAtIndex(index: Int, mediaBrowser: MediaBrowser) -> Bool {
        return false
    }
    
    func selectedChanged(selected: Bool, index: Int, mediaBrowser: MediaBrowser) {
        
    }
    
    func titleForPhotoAtIndex(index: Int, mediaBrowser: MediaBrowser) -> String {
        return ""
    }
}
