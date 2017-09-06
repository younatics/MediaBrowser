//
//  ViewController.swift
//  MediaBrowserDemo
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//

import UIKit
import Photos

class MediaBrowserCell: UITableViewCell {
    
}

class ViewController: UITableViewController {
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var selections = NSMutableArray()
    var photos = NSMutableArray()
    var thumbs = NSMutableArray()
    var assets = NSMutableArray()
//    var ALAssetsLibrary = ALAssetsLibrary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(MediaBrowserCell.self, forCellReuseIdentifier: "Cell")
        let font = UIFont.systemFont(ofSize: 12)
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: font],
                                                for: .normal)

        loadAssets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
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

//MARK: UITableViewDelegate, UITableviewDataSource
extension ViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assets.count > 0 ? 9 : 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellCheck = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        guard let cell = cellCheck else { return UITableViewCell() }
        cell.accessoryType = segmentedControl.selectedSegmentIndex == 0 ? .disclosureIndicator : .none

        switch (indexPath.row) {
        case 0:
            cell.textLabel?.text = "Single photo"
            cell.detailTextLabel?.text = "with caption, no grid button"
            break
        case 1:
            cell.textLabel?.text = "Multiple photos and video"
            cell.detailTextLabel?.text = "with captions"
            break
            
        case 2:
            cell.textLabel?.text = "Multiple photo grid"
            cell.detailTextLabel?.text = "showing grid first, nav arrows enabled"
            break
            
        case 3:
            cell.textLabel?.text = "Photo selections"
            cell.detailTextLabel?.text = "selection enabled"
            break
            
        case 4:
            cell.textLabel?.text = "Photo selection grid"
            cell.detailTextLabel?.text = "selection enabled, start at grid"
            break
            
        case 5:
            cell.textLabel?.text = "Web photos"
            cell.detailTextLabel?.text = "photos from web"
            break
            
        case 6:
            cell.textLabel?.text = "Web photo grid"
            cell.detailTextLabel?.text = "showing grid first"
            break
            
        case 7:
            cell.textLabel?.text = "Single video"
            cell.detailTextLabel?.text = "with auto-play"
            break
            
        case 8:
            cell.textLabel?.text = "Web videos"
            cell.detailTextLabel?.text = "showing grid first"
            break
        
        case 9:
            cell.textLabel?.text = "Library photos and videos"
            cell.detailTextLabel?.text = "media from device library"
            break
            
        default: break
        }
        
        return cell
    }
}

