//
//  UIImagePhotoBrowserExtension.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//
//

import Foundation

public extension UIImage {
    class func imageForResourcePath(path: String, ofType: String, inBundle: Bundle) -> UIImage? {
        if let p = inBundle.pathForResource(path, ofType: ofType) {
            return UIImage(contentsOfFile: p)
        }
        
        return nil
    }

    class func clearImageWithSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen.scale)
        let blank = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return blank!
    }
}
