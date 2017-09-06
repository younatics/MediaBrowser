//
//  MWLog.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//

import Foundation

class MWLog: NSObject {
    static let queue = dispatch_queue_create("com.mwphotobrowser", nil)
    static let formatter = DateFormatter()
    
    class func log(format: String) {
        formatter.dateStyle = NSDateFormatterStyle.NoStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        formatter.dateFormat = "HH:mm:ss.SSS"
        
        let tid = String(format: "%.05x", pthread_mach_thread_np(pthread_self()))
        let tme = formatter.stringFromDate(NSDate())
        let str = "\(tme) [\(tid)] " + format
        
        dispatch_async(queue) {
            print(str)
        }
    }
}
