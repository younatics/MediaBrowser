//
//  MWPhoto.swift
//  MWPhotoBrowserSwift
//
//  Created by Tapani Saarinen on 04/09/15.
//  Original obj-c created by Michael Waterfall 2013
//
//

import UIKit
import AssetsLibrary
import Photos
import MapleBacon
import Photos

var PHInvalidImageRequestID = PHImageRequestID(0)

public class MWPhoto: Photo {
    public var caption = ""
    public var emptyImage = true
    public var isVideo = false
    public var underlyingImage: UIImage?

    private let uuid = NSUUID().UUIDString
    private var image: UIImage?
    private var photoURL: NSURL?
    private var asset: PHAsset?
    private var assetTargetSize = CGSizeMake(0.0, 0.0)
    
    private var loadingInProgress = false
    private var operation: ImageDownloadOperation?
    private var assetRequestID = PHInvalidImageRequestID
    
    //MARK: - Init

    public init() {}

    public convenience init(image: UIImage) {
        self.init()
        self.image = image
    }
    
    public convenience init(url: NSURL, caption: String) {
        self.init()
        self.photoURL = url
        self.caption = caption
    }

    public convenience init(url: NSURL) {
        self.init()
        self.photoURL = url
    }

    public convenience init(asset: PHAsset, targetSize: CGSize) {
        self.init()
        
        self.asset = asset
        assetTargetSize = targetSize
        isVideo = asset.mediaType == PHAssetMediaType.Video
    }

    public convenience init(videoURL: NSURL) {
        self.init()
    
        self.videoURL = videoURL
        isVideo = true
        emptyImage = true
    }

    //MARK: - Video

    private var videoURL: NSURL?

    public func setVideoURL(url: NSURL?) {
        videoURL = url
        isVideo = true
    }

    public func getVideoURL(completion: (NSURL?) -> ()) {
        if let vurl = videoURL {
            completion(vurl)
        }
        else
        if let a = asset {
            if a.mediaType == PHAssetMediaType.Video {
                let options = PHVideoRequestOptions()
                options.networkAccessAllowed = true
                
                PHImageManager.defaultManager().requestAVAssetForVideo(
                    a,
                    options: options,
                    resultHandler: { asset, audioMix, info in
                        if let urlAsset = asset as? AVURLAsset {
                            completion(urlAsset.URL)
                        }
                        else {
                            completion(nil)
                        }
                    })
            }
        }
        
        return completion(nil)
    }

    //MARK: - Photo Protocol Methods

    public func loadUnderlyingImageAndNotify() {
        assert(NSThread.currentThread().isMainThread, "This method must be called on the main thread.")
        
        if loadingInProgress {
            return
        }
        
        loadingInProgress = true
        
        //try {
            if underlyingImage != nil {
                imageLoadingComplete()
            }
            else {
                performLoadUnderlyingImageAndNotify()
            }
        //}
        //catch (NSException exception) {
        //    underlyingImage = nil
        //    loadingInProgress = false
        //    imageLoadingComplete()
        //}
    }

    // Set the underlyingImage
    public func performLoadUnderlyingImageAndNotify() {
        // Get underlying image
        if let img = image {
            // We have UIImage!
            underlyingImage = img
            imageLoadingComplete()
        }
        else
        if let purl = photoURL {
            // Check what type of url it is
            if purl.scheme.lowercaseString == "assets-library" {
                // Load from assets library
                performLoadUnderlyingImageAndNotifyWithAssetsLibraryURL(purl)
            }
            else
            if purl.isFileReferenceURL() {
                // Load from local file async
                performLoadUnderlyingImageAndNotifyWithLocalFileURL(purl)
            }
            else {
                // Load async from web (using SDWebImage)
                performLoadUnderlyingImageAndNotifyWithWebURL(purl)
            }
        }
        else
        if let a = asset {
            // Load from photos asset
            performLoadUnderlyingImageAndNotifyWithAsset(a, targetSize: assetTargetSize)
        }
        else {
            // Image is empty
            imageLoadingComplete()
        }
    }
    
    func cancelDownload() {
        operation?.cancel()
    }

    // Load from local file
    private func performLoadUnderlyingImageAndNotifyWithWebURL(url: NSURL) {
        cancelDownload()
        
        /*
            progress: { receivedSize, expectedSize in
                if expectedSize > 0 {
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        MWPHOTO_PROGRESS_NOTIFICATION,
                        object: [
                            "progress": Float(receivedSize) / Float(expectedSize),
                            "photo": self
                        ])
                }
            },
        */
        
        operation = ImageManager.sharedManager.downloadImageAtURL(url, cacheScaled: false, imageView: nil)
        { [weak self] imageInstance, error in
            if let strongSelf = self {
                dispatch_async(dispatch_get_main_queue()) {
                    strongSelf.operation = nil
                    
                    if let ii = imageInstance {
                        strongSelf.underlyingImage = ii.image
                    }

                    dispatch_async(dispatch_get_main_queue()) {
                        strongSelf.imageLoadingComplete()
                    }
                }
            }
        }
    }

    // Load from local file
    private func performLoadUnderlyingImageAndNotifyWithLocalFileURL(url: NSURL) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            //try {
            if let path = url.path {
                self.underlyingImage = UIImage(contentsOfFile: path)
                //if nil == underlyingImage {
                    //MWLog(@"Error loading photo from path: \(url.path)")
                //}
            //}
            //finally {
                dispatch_async(dispatch_get_main_queue()) {
                    self.imageLoadingComplete()
                }
            //}
            }
        }
    }

    // Load from asset library async
    private func performLoadUnderlyingImageAndNotifyWithAssetsLibraryURL(url: NSURL) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            //try {
                let assetslibrary = ALAssetsLibrary()
                assetslibrary.assetForURL(
                    url,
                    resultBlock: { asset in
                        let rep = asset.defaultRepresentation()
                        self.underlyingImage = UIImage(CGImage: rep.fullScreenImage().takeUnretainedValue())
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.imageLoadingComplete()
                        }
                    },
                    failureBlock: { error in
                        self.underlyingImage = nil
                        //MWLog(@"Photo from asset library error: %@",error)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.imageLoadingComplete()
                        }
                    })
            //}
            //catch (NSException e) {
            //    MWLog(@"Photo from asset library error: \(e)")
            //    self.performSelectorOnMainThread(Selector("imageLoadingComplete"), withObject: nil, waitUntilDone: false)
            //}
        }
    }

    // Load from photos library
    private func performLoadUnderlyingImageAndNotifyWithAsset(asset: PHAsset, targetSize: CGSize) {
        let imageManager = PHImageManager.defaultManager()
        
        let options = PHImageRequestOptions()
        options.networkAccessAllowed = true
        options.resizeMode = .Fast
        options.deliveryMode = .HighQualityFormat
        options.synchronous = false
        options.progressHandler = { progress, error, stop, info in
            let dict = [
                "progress" : progress,
                "photo" : self
            ]
            
            NSNotificationCenter.defaultCenter().postNotificationName(MWPHOTO_PROGRESS_NOTIFICATION, object: dict)
        }
        
        assetRequestID = imageManager.requestImageForAsset(
            asset,
            targetSize: targetSize,
            contentMode: PHImageContentMode.AspectFit,
            options: options,
                resultHandler: { result, info in
                dispatch_async(dispatch_get_main_queue()) {
                    self.underlyingImage = result
                    self.imageLoadingComplete()
                }
            })
    }

    // Release if we can get it again from path or url
    public func unloadUnderlyingImage() {
        loadingInProgress = false
        underlyingImage = nil
    }

    private func imageLoadingComplete() {
        assert(NSThread.currentThread().isMainThread, "This method must be called on the main thread.")
        
        // Complete so notify
        loadingInProgress = false
        
        // Notify on next run loop
        dispatch_async(dispatch_get_main_queue()) {
            self.postCompleteNotification()
        }
    }

    private func postCompleteNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(
            MWPHOTO_LOADING_DID_END_NOTIFICATION,
            object: self)
    }

    public func cancelAnyLoading() {
        if let op = operation {
            op.cancel()
            loadingInProgress = false
        }
        else
        if assetRequestID != PHInvalidImageRequestID {
            PHImageManager.defaultManager().cancelImageRequest(assetRequestID)
            assetRequestID = PHInvalidImageRequestID
        }
    }
    
    public func equals(photo: Photo) -> Bool {
        if let p = photo as? MWPhoto {
            return uuid == p.uuid
        }
        
        return false
    }
}
