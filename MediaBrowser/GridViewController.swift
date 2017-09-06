//
//  GridViewController.swift
//  Pods
//
//  Created by Tapani Saarinen on 04/09/15.
//
//

import UIKit

public class GridViewController: UICollectionViewController {
    weak var browser: PhotoBrowser?
    var selectionMode = false
    var initialContentOffset = CGPointMake(0.0, CGFloat.max)
    
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
            cv.registerClass(GridCell.self, forCellWithReuseIdentifier: "GridCell")
            cv.alwaysBounceVertical = true
            cv.backgroundColor = UIColor.whiteColor()
        }
    }

    public override func viewWillDisappear(animated: Bool) {
        // Cancel outstanding loading
        if let cv = collectionView {
            for cell in cv.visibleCells() {
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
        if initialContentOffset.y != CGFloat.max {
            collectionView!.contentOffset = initialContentOffset
            collectionView!.layoutIfNeeded() // Layout after content offset change
        }
        
        // Check if current item is visible and if not, make it so!
        if let b = browser where b.numberOfPhotos > 0 {
            let currentPhotoIndexPath = NSIndexPath(forItem: b.currentIndex, inSection: 0)
            let visibleIndexPaths = collectionView!.indexPathsForVisibleItems()
            
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
        coordinator.animateAlongsideTransition(nil) { _ in
            if let cv = self.collectionView {
                cv.reloadData()
            }
        }
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    //MARK: - Collection View

    public override func collectionView(view: UICollectionView, numberOfItemsInSection section: Int) -> NSInteger {
        if let b = browser {
            return b.numberOfPhotos
        }
        
        return 0
    }

    public override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GridCell", forIndexPath: indexPath) as! GridCell
        
        if let b = browser,
            photo = b.thumbPhotoAtIndex(indexPath.row)
        {
            cell.photo = photo
            cell.gridController = self
            cell.selectionMode = selectionMode
            cell.index = indexPath.row
            cell.selected = b.photoIsSelectedAtIndex(indexPath.row)
        
            if let _ = b.imageForPhoto(photo) {
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
        
        return CGSizeMake(value, value)
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
