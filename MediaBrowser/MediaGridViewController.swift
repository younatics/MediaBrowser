//
//  MediaGridViewController.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//

import UIKit

class MediaGridViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    weak var browser: MediaBrowser?
    var selectionMode = false
    var initialContentOffset = CGPoint(x: 0.0, y: CGFloat.greatestFiniteMagnitude)
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cv = collectionView {
            cv.register(MediaGridCell.self, forCellWithReuseIdentifier: "MediaGridCell")
            cv.alwaysBounceVertical = true
            cv.backgroundColor = UIColor.black
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Cancel outstanding loading
        if let cv = collectionView {
            for cell in cv.visibleCells {
                let c = cell as! MediaGridCell
                
                if let p = c.photo {
                    p.cancelAnyLoading()
                }
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func adjustOffsetsAsRequired() {
        // Move to previous content offset
        if initialContentOffset.y != CGFloat.greatestFiniteMagnitude {
            collectionView!.contentOffset = initialContentOffset
            collectionView!.layoutIfNeeded() // Layout after content offset change
        }
        
        // Check if current item is visible and if not, make it so!
        if let b = browser, b.numberOfMedias > 0 {
            let currentPhotoIndexPath = IndexPath(item: b.currentIndex, section: 0)
            let visibleIndexPaths = collectionView!.indexPathsForVisibleItems
            
            var currentVisible = false
            
            for indexPath in visibleIndexPaths {
                if indexPath == currentPhotoIndexPath {
                    currentVisible = true
                    break
                }
            }
            
            if !currentVisible {
                collectionView!.scrollToItem(at: currentPhotoIndexPath, at: UICollectionView.ScrollPosition.left, animated: false)
            }
        }
    }
    
    //MARK: - Layout
    
    var columns: CGFloat {
        return floorcgf(x: view.bounds.width / 93.0)
    }
    
    var margin = CGFloat(1.0)
    var gutter = CGFloat(1.0)
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in
            if let cv = self.collectionView {
                cv.reloadData()
            }
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    //MARK: - Collection View
    
    override func collectionView(_ view: UICollectionView, numberOfItemsInSection section: Int) -> NSInteger {
        if let b = browser {
            return b.numberOfMedias
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaGridCell", for: indexPath as IndexPath) as! MediaGridCell
        if let b = browser, let photo = b.thumbPhotoAtIndex(index: indexPath.row) {
            cell.photo = photo
            cell.gridController = self
            cell.selectionMode = selectionMode
            cell.index = indexPath.row
            cell.isSelected = b.photoIsSelectedAtIndex(index: indexPath.row)
            if let placeholder = self.browser?.placeholderImage {
                cell.placeholderImage = placeholder.image
                cell.imageView.image = placeholder.image
            }
            
            if let _ = b.image(for: photo) {
                cell.displayImage()
            } else {
                photo.loadUnderlyingImageAndNotify()
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let b = browser {
            b.currentPhotoIndex = indexPath.row
            b.hideGrid()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let gridCell = cell as? MediaGridCell, let gcp = gridCell.photo {
            gcp.cancelAnyLoading()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let delegateSize = self.browser?.delegate?.gridCellSize() {
            return delegateSize
        }
        
        let value = CGFloat(floorf(Float((view.bounds.size.width - (columns - 1.0) * gutter - 2.0 * margin) / columns)))
        
        return CGSize(width: value, height: value)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return gutter
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return gutter
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let margin = self.margin
        return UIEdgeInsets.init(top: margin, left: margin, bottom: margin, right: margin)
    }
}
