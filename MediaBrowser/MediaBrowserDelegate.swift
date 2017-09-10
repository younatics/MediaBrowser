//
//  MediaBrowserDelegate.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//

import UIKit

public protocol MediaBrowserDelegate: class {
    //MARK: Required methods
    func numberOfMedia(in mediaBrowser: MediaBrowser) -> Int
    
    func media(for mediaBrowser: MediaBrowser, at index: Int) -> Media
    
    //MARK: Optional methods
    func mediaBrowserDidFinishModalPresentation(mediaBrowser: MediaBrowser)

    func thumbnail(for mediaBrowser: MediaBrowser, at index: Int) -> Media

    func captionView(for mediaBrowser: MediaBrowser, at index: Int) -> MediaCaptionView?
    
    func didDisplayMedia(at index: Int, in mediaBrowser: MediaBrowser)
    
    func actionButtonPressed(at photoIndex: Int, in mediaBrowser: MediaBrowser)
    
    func isMediaSelected(at index: Int, in mediaBrowser: MediaBrowser) -> Bool
    
    func mediaDid(selected: Bool, at index: Int, in mediaBrowser: MediaBrowser)
    
    func title(for mediaBrowser: MediaBrowser, at index: Int) -> String
}

public extension MediaBrowserDelegate {
    func mediaBrowserDidFinishModalPresentation(mediaBrowser: MediaBrowser) { }

    func thumbnail(for mediaBrowser: MediaBrowser, at index: Int) -> Media { return Media() }

    func captionView(for mediaBrowser: MediaBrowser, at index: Int) -> MediaCaptionView? { return nil }
    
    func didDisplayMedia(at index: Int, in mediaBrowser: MediaBrowser) { }
    
    func actionButtonPressed(at photoIndex: Int, in mediaBrowser: MediaBrowser) { }
    
    func isMediaSelected(at index: Int, in mediaBrowser: MediaBrowser) -> Bool { return false }
    
    func mediaDid(selected: Bool, at index: Int, in mediaBrowser: MediaBrowser) { }
    
    func title(for mediaBrowser: MediaBrowser, at index: Int) -> String { return "" }
}
