//
//  Media.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//
//

import UIKit
import AssetsLibrary
import Photos
import MapleBacon
import Photos

let MWPHOTO_LOADING_DID_END_NOTIFICATION  = "MWPHOTO_LOADING_DID_END_NOTIFICATION"
let MWPHOTO_PROGRESS_NOTIFICATION  = "MWPHOTO_PROGRESS_NOTIFICATION"

var PHInvalidImageRequestID = PHImageRequestID(0)

public class Media: NSObject {
    public var caption = ""
    public var emptyImage = true
    public var isVideo = false
    public var underlyingImage: UIImage?

    private let uuid = NSUUID().uuidString
    private var image: UIImage?
    private var photoURL: URL?
    private var asset: PHAsset?
    private var assetTargetSize = CGSize.zero
    
    private var loadingInProgress = false
    private var operation: ImageDownloadOperation?
    private var assetRequestID = PHInvalidImageRequestID
    
    //MARK: - Init

    public override init() {}

    public convenience init(image: UIImage) {
        self.init()
        self.image = image
    }
    
    public convenience init(image: UIImage, caption: String) {
        self.init()
        self.image = image
        self.caption = caption
    }

    public convenience init(url: URL, caption: String) {
        self.init()
        self.photoURL = url
        self.caption = caption
    }

    public convenience init(url: URL) {
        self.init()
        self.photoURL = url
    }

    public convenience init(asset: PHAsset, targetSize: CGSize) {
        self.init()
        
        self.asset = asset
        assetTargetSize = targetSize
        isVideo = asset.mediaType == PHAssetMediaType.video
    }

    public convenience init(videoURL: URL) {
        self.init()
    
        self.videoURL = videoURL
        isVideo = true
        emptyImage = true
    }

    //MARK: - Video

    private var _videoURL: URL?
    public var videoURL: URL? {
        set {
            setVideoURL(url: newValue)
        }
        get {
            return self._videoURL
        }
    }

    public func setVideoURL(url: URL?) {
        self._videoURL = url
        isVideo = true
    }

    public func getVideoURL(completion: @escaping (URL?) -> ()) {
        if let vurl = videoURL {
            completion(vurl)
        }
        else if let a = asset {
            if a.mediaType == PHAssetMediaType.video {
                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true
                
                PHImageManager.default().requestAVAsset(
                    forVideo: a,
                    options: options,
                    resultHandler: { asset, audioMix, info in
                        if let urlAsset = asset as? AVURLAsset {
                            completion(urlAsset.url)
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
        assert(Thread.current.isMainThread, "This method must be called on the main thread.")
        
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
            if purl.scheme?.lowercased() == "assets-library" {
                // Load from assets library
                performLoadUnderlyingImageAndNotifyWithAssetsLibraryURL(url: purl)
            }
            else
            if purl.isFileURL {
                // Load from local file async
                performLoadUnderlyingImageAndNotifyWithLocalFileURL(url: purl)
            }
            else {
                // Load async from web (using SDWebImage)
                performLoadUnderlyingImageAndNotifyWithWebURL(url: purl)
            }
        }
        else
        if let a = asset {
            // Load from photos asset
            performLoadUnderlyingImageAndNotifyWithAsset(asset: a, targetSize: assetTargetSize)
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
    private func performLoadUnderlyingImageAndNotifyWithWebURL(url: URL) {
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
        operation = ImageManager.sharedManager.downloadImage(atUrl: url, cacheScaled: false, imageView: nil, completion: { [weak self](imageInstance, error) in
            if let strongSelf = self {
                DispatchQueue.main.async() {
                    strongSelf.operation = nil
                    
                    if let ii = imageInstance {
                        strongSelf.underlyingImage = ii.image
                    }
                    
                    DispatchQueue.main.async() {
                        strongSelf.imageLoadingComplete()
                    }
                }
            }
            
        })
    }
    
    // Load from local file
    private func performLoadUnderlyingImageAndNotifyWithLocalFileURL(url: URL) {
        DispatchQueue.global(qos: .default).async {
            let path = url.path
            self.underlyingImage = UIImage(contentsOfFile: path)
            //if nil == underlyingImage {
            //MWLog(@"Error loading photo from path: \(url.path)")
            //}
            //}
            //finally {
            DispatchQueue.main.async() {
                self.imageLoadingComplete()
            }
            //}
            
            
        }
    }
    
    // Load from asset library async
    private func performLoadUnderlyingImageAndNotifyWithAssetsLibraryURL(url: URL) {
        DispatchQueue.global(qos: .default).async {
            //try {
            let assetslibrary = ALAssetsLibrary()
            assetslibrary.asset(
                for: url,
                resultBlock: { asset in
                    let rep = asset?.defaultRepresentation()
                    guard let cgImage = rep?.fullScreenImage().takeUnretainedValue() else { return }
                    self.underlyingImage = UIImage(cgImage: cgImage)
                    
                    DispatchQueue.main.async() {
                        self.imageLoadingComplete()
                    }
            },
                    failureBlock: { error in
                        self.underlyingImage = nil
                        //MWLog(@"Photo from asset library error: %@",error)
                        
                        DispatchQueue.main.async() {
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
        let imageManager = PHImageManager.default()
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        options.progressHandler = { progress, error, stop, info in
            let dict = [
                "progress" : progress,
                "photo" : self
            ] as [String : Any]
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MWPHOTO_PROGRESS_NOTIFICATION), object: dict)
        }
        
        assetRequestID = imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: PHImageContentMode.aspectFit,
            options: options,
                resultHandler: { result, info in
                DispatchQueue.main.async() {
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
        assert(Thread.current.isMainThread, "This method must be called on the main thread.")
        
        // Complete so notify
        loadingInProgress = false
        
        // Notify on next run loop
        DispatchQueue.main.async() {
            self.postCompleteNotification()
        }
    }

    private func postCompleteNotification() {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: MWPHOTO_LOADING_DID_END_NOTIFICATION),
            object: self)
    }

    public func cancelAnyLoading() {
        if let op = operation {
            op.cancel()
            loadingInProgress = false
        }
        else
        if assetRequestID != PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(assetRequestID)
            assetRequestID = PHInvalidImageRequestID
        }
    }
    
    public func equals(photo: Media) -> Bool {
        if let p = photo as? Media {
            return uuid == p.uuid
        }
        
        return false
    }
}
