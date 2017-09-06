//
//  UIImagePhotoBrowserExtension.swift
//  MWPhotoBrowserSwift
//
//  Created by Tapani Saarinen on 04/09/15.
//  Original obj-c created by Michael Waterfall 2013
//
//

import Foundation

public extension UIImage {
    class func imageForResourcePath(path: String, ofType: String, inBundle: NSBundle) -> UIImage? {
        if let p = inBundle.pathForResource(path, ofType: ofType) {
            return UIImage(contentsOfFile: p)
        }
        
        return nil
    }

    class func clearImageWithSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
        let blank = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return blank
    }
}
