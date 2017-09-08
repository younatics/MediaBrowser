//
//  PhotoBrowserDelegate.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//

import UIKit

public protocol PhotoBrowserDelegate: class {
    func numberOfPhotosInPhotoBrowser(photoBrowser: PhotoBrowser) -> Int
    
    func photoAtIndex(index: Int, photoBrowser: PhotoBrowser) -> Media
    
    func thumbPhotoAtIndex(index: Int, photoBrowser: PhotoBrowser) -> Media
    
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
