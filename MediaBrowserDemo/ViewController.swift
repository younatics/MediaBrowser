//
//  ViewController.swift
//  MediaBrowserDemo
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//

import UIKit
import Photos

class ViewController: UITableViewController {
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var selections = NSMutableArray()
    var photos = NSMutableArray()
    var thumbs = NSMutableArray()
    var assets = NSMutableArray()
//    var ALAssetsLibrary = ALAssetsLibrary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let font = UIFont.systemFont(ofSize: 12)
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: font],
                                                for: .normal)

        loadAssets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadAssets() {
        let status = PHAuthorizationStatus.authorized
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == PHAuthorizationStatus.authorized {
                    self.performLoadAssets()
                }
            })
        } else if status == .authorized {
            self.performLoadAssets()
        }
    }
//    PHFetchOptions *options = [PHFetchOptions new];
//    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
//    PHFetchResult *fetchResults = [PHAsset fetchAssetsWithOptions:options];
//    [fetchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//    [_assets addObject:obj];
//    }];
//    if (fetchResults.count > 0) {
//    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
//    }

    func performLoadAssets() {
        DispatchQueue.global(qos: .default).async {
            let options = PHFetchOptions.init()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let fetchResults = PHAsset.fetchAssets(with: options)
            fetchResults.enumerateObjects({ (obj, idx, stop) in
                self.assets.add(obj)
            })
            if fetchResults.count > 0 {
                self.tableView.performSelector(onMainThread: #selector(self.tableView.reloadData), with: nil, waitUntilDone: false)
            }
        }
    }

}

