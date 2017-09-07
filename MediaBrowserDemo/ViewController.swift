//
//  ViewController.swift
//  MediaBrowserDemo
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//

import UIKit
import Photos
import MediaBrowser

class ViewController: UITableViewController {
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var selections = [Bool]()
    var photos = [MWPhoto]()
    var thumbs = [MWPhoto]()
    var assets = NSMutableArray()
//    var ALAssetsLibrary = ALAssetsLibrary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let font = UIFont.systemFont(ofSize: 12)
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: font],
                                                for: .normal)
        segmentedControl.addTarget(self, action: #selector(segmentControlChanged), for: .valueChanged)
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
    
    func segmentControlChanged() {
        self.tableView.reloadData()
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
    
    func localMediaPhoto(imageName: String, caption: String) -> MWPhoto {
        guard let image = UIImage(named: imageName) else {
            fatalError("Image is nil")
        }
        
        let photo = MWPhoto(image: image, caption: caption)
        return photo
    }
}

//MARK: PhotoBrowserDelegate
extension ViewController: PhotoBrowserDelegate {
    func photoBrowserDidFinishModalPresentation(photoBrowser: PhotoBrowser) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func thumbPhotoAtIndex(index: Int, photoBrowser: PhotoBrowser) -> Photo {
        if index < thumbs.count {
            return thumbs[index]
        }
        return localMediaPhoto(imageName: "MotionBookIcon", caption: "ThumbPhoto at index is wrong")
    }
    
    func photoAtIndex(index: Int, photoBrowser: PhotoBrowser) -> Photo {
        if index < photos.count {
            return photos[index]
        }
        return localMediaPhoto(imageName: "MotionBookIcon", caption: "Photo at index is Wrong")

    }
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: PhotoBrowser) -> Int {
        return photos.count
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        photos = [MWPhoto]()
        thumbs = [MWPhoto]()
        
        var displayActionButton = true
        var displaySelectionButtons = false
        var displayNavArrows = false
        var enableGrid = true
        var startOnGrid = false
        var autoPlayOnAppear = false
        
        switch indexPath.row {
        case 0:
            let photo = localMediaPhoto(imageName: "MotionBookIcon", caption: "MotionBookIcon")
            photos.append(photo)
            enableGrid = false
            break
        case 1:
            var photo = localMediaPhoto(imageName: "MotionBookIntro1", caption: "MotionBook Intro 1")
            photos.append(photo)
            
            photo = localMediaPhoto(imageName: "MotionBookIntro2", caption: "MotionBook Intro 2")
            photos.append(photo)
            
            photo = localMediaPhoto(imageName: "Atoms_thumb", caption: "Atom")
            photo.videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "Atoms", ofType: "mp4")!)
            photos.append(photo)

            photo = localMediaPhoto(imageName: "MotionBookIntro3", caption: "MotionBook Intro 3")
            photos.append(photo)

            photo = localMediaPhoto(imageName: "MotionBookIntro4", caption: "MotionBook Intro 4")
            photos.append(photo)
            
            photo = localMediaPhoto(imageName: "MotionBookIntro5", caption: "MotionBook Intro 5")
            photos.append(photo)

            enableGrid = false
            
            break
        case 2:
            var photo = localMediaPhoto(imageName: "MotionBookIntro1", caption: "MotionBook Intro 1")
            photos.append(photo)
            thumbs.append(photo)
            
            photo = localMediaPhoto(imageName: "MotionBookIntro2", caption: "MotionBook Intro 2")
            photos.append(photo)
            thumbs.append(photo)

            photo = localMediaPhoto(imageName: "MotionBookIntro3", caption: "MotionBook Intro 3")
            photos.append(photo)
            thumbs.append(photo)

            photo = localMediaPhoto(imageName: "MotionBookIntro4", caption: "MotionBook Intro 4")
            photos.append(photo)
            thumbs.append(photo)

            photo = localMediaPhoto(imageName: "MotionBookIntro5", caption: "MotionBook Intro 5")
            photos.append(photo)
            thumbs.append(photo)
            
            photo = localMediaPhoto(imageName: "demo1", caption: "Demo Image 1 from Pixabay")
            photos.append(photo)
            thumbs.append(photo)
            
            photo = localMediaPhoto(imageName: "demo2", caption: "Demo Image 2 from Pixabay")
            photos.append(photo)
            thumbs.append(photo)
            
            photo = localMediaPhoto(imageName: "demo3", caption: "Demo Image 3 from Pixabay")
            photos.append(photo)
            thumbs.append(photo)
            
            photo = localMediaPhoto(imageName: "demo4", caption: "Demo Image 4 from Pixabay")
            photos.append(photo)
            thumbs.append(photo)
            
            photo = localMediaPhoto(imageName: "demo5", caption: "Demo Image 5 from Pixabay")
            photos.append(photo)
            thumbs.append(photo)
            
            photo = localMediaPhoto(imageName: "demo6", caption: "Demo Image 6 from Pixabay")
            photos.append(photo)
            thumbs.append(photo)
            
            photo = localMediaPhoto(imageName: "demo7", caption: "Demo Image 7 from Pixabay")
            photos.append(photo)
            thumbs.append(photo)

            startOnGrid = true
            displayNavArrows = true
            
            break

        default:
            break
        }
        
        let browser = PhotoBrowser(delegate: self)
        browser.displayActionButton = displayActionButton
        browser.displayNavArrows = displayNavArrows
        browser.displaySelectionButtons = displaySelectionButtons
        browser.alwaysShowControls = displaySelectionButtons
        browser.zoomPhotosToFill = true
        browser.enableGrid = enableGrid
        browser.startOnGrid = startOnGrid
        browser.enableSwipeToDismiss = false
        browser.autoPlayOnAppear = autoPlayOnAppear
        
        
        if displaySelectionButtons {
            selections.removeAll()
            
            for _ in 0..<photos.count {
                selections.append(false)
            }
        }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            self.navigationController?.pushViewController(browser, animated: true)
        } else {
            let nc = UINavigationController.init(rootViewController: browser)
            nc.modalTransitionStyle = .crossDissolve
            self.present(nc, animated: true, completion: nil)
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
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

