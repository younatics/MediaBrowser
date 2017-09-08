//
//  PhotoBrowserDelegate.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//

import UIKit

public protocol PhotoBrowserDelegate: class {
    func numberOfPhotosInPhotoBrowser(MediaBrowser: MediaBrowser) -> Int
    
    func photoAtIndex(index: Int, MediaBrowser: MediaBrowser) -> Media
    
    func thumbPhotoAtIndex(index: Int, MediaBrowser: MediaBrowser) -> Media
    
    func captionViewForPhotoAtIndex(index: Int, MediaBrowser: MediaBrowser) -> CaptionView?
    
    func titleForPhotoAtIndex(index: Int, MediaBrowser: MediaBrowser) -> String
    
    func didDisplayPhotoAtIndex(index: Int, MediaBrowser: MediaBrowser)
    
    func actionButtonPressedForPhotoAtIndex(index: Int, MediaBrowser: MediaBrowser)
    
    func isPhotoSelectedAtIndex(index: Int, MediaBrowser: MediaBrowser) -> Bool
    
    func selectedChanged(selected: Bool, index: Int, MediaBrowser: MediaBrowser)
    
    func photoBrowserDidFinishModalPresentation(MediaBrowser: MediaBrowser)
}

public extension PhotoBrowserDelegate {
    func captionViewForPhotoAtIndex(index: Int, MediaBrowser: MediaBrowser) -> CaptionView? {
        return nil
    }
    
    func didDisplayPhotoAtIndex(index: Int, MediaBrowser: MediaBrowser) {
        
    }
    
    func actionButtonPressedForPhotoAtIndex(index: Int, MediaBrowser: MediaBrowser) {
        
    }
    
    func isPhotoSelectedAtIndex(index: Int, MediaBrowser: MediaBrowser) -> Bool {
        return false
    }
    
    func selectedChanged(selected: Bool, index: Int, MediaBrowser: MediaBrowser) {
        
    }
    
    func titleForPhotoAtIndex(index: Int, MediaBrowser: MediaBrowser) -> String {
        return ""
    }
}
