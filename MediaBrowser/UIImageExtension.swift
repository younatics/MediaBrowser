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
    class func imageForResourcePath(name: String, inBundle: Bundle) -> UIImage? {
        return UIImage(named: name, in: inBundle, compatibleWith: nil)
    }

    class func clearImageWithSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let blank = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return blank!
    }
}
