//
//  UIImageExtension.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//
//

import Foundation

public extension UIImage {
    /// Get bundle Image or return nil when it is not exist
    class func imageForResourcePath(name: String, inBundle: Bundle) -> UIImage? {
        return UIImage(named: name, in: inBundle, compatibleWith: nil)
    }
}
