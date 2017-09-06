//
//  GridViewController.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//

import UIKit

public class GridViewController: UICollectionViewController {
    weak var browser: PhotoBrowser?
    var selectionMode = false
    var initialContentOffset = CGPoint(x: 0.0, y: CGFloat.greatestFiniteMagnitude)
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //MARK: - View

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cv = collectionView {
            cv.register(GridCell.self, forCellWithReuseIdentifier: "GridCell")
            cv.alwaysBounceVertical = true
            cv.backgroundColor = UIColor.white
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        // Cancel outstanding loading
        if let cv = collectionView {
            for cell in cv.visibleCells {
                let c = cell as! GridCell
                
                if let p = c.photo {
                    p.cancelAnyLoading()
                }
            }
        }
        
        super.viewWillDisappear(animated)
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func adjustOffsetsAsRequired() {
        // Move to previous content offset
        if initialContentOffset.y != CGFloat.greatestFiniteMagnitude {
            collectionView!.contentOffset = initialContentOffset
            collectionView!.layoutIfNeeded() // Layout after content offset change
        }
        
        // Check if current item is visible and if not, make it so!
        if let b = browser, b.numberOfPhotos > 0 {
            let currentPhotoIndexPath = NSIndexPath(forItem: b.currentIndex, inSection: 0)
            let visibleIndexPaths = collectionView!.indexPathsForVisibleItems
            
            var currentVisible = false
            
            for indexPath in visibleIndexPaths {
                if indexPath == currentPhotoIndexPath {
                    currentVisible = true
                    break
                }
            }
            
            if !currentVisible {
                collectionView!.scrollToItemAtIndexPath(currentPhotoIndexPath, atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
            }
        }
    }

    //MARK: - Layout

    private var columns: CGFloat {
        return floorcgf(view.bounds.width / 93.0)
    }

    private var margin = CGFloat(5.0)
    private var gutter = CGFloat(5.0)
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in
            if let cv = self.collectionView {
                cv.reloadData()
            }
        }
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    //MARK: - Collection View

    public override func collectionView(_ view: UICollectionView, numberOfItemsInSection section: Int) -> NSInteger {
        if let b = browser {
            return b.numberOfPhotos
        }
        
        return 0
    }

    public override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath as IndexPath) as! GridCell
        
        if let b = browser,
            let photo = b.thumbPhotoAtIndex(index: indexPath.row)
        {
            cell.photo = photo
            cell.gridController = self
            cell.selectionMode = selectionMode
            cell.index = indexPath.row
            cell.selected = b.photoIsSelectedAtIndex(index: indexPath.row)
        
            if let _ = b.imageForPhoto(photo: photo) {
                cell.displayImage()
            }
            else {
                photo.loadUnderlyingImageAndNotify()
            }
        }
        
        return cell
    }

    public override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let b = browser {
            b.currentPhotoIndex = indexPath.row
            b.hideGrid()
        }
    }

    public override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let gridCell = cell as? GridCell {
            if let gcp = gridCell.photo {
                gcp.cancelAnyLoading()
            }
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let value = CGFloat(floorf(Float((view.bounds.size.width - (columns - 1.0) * gutter - 2.0 * margin) / columns)))
        
        return CGSize(width: value, height: value)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return gutter
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return gutter
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let margin = self.margin
        return UIEdgeInsetsMake(margin, margin, margin, margin)
    }
}
