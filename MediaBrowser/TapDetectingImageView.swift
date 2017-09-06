//
//  TapDetectingImageView.swift
//  MWPhotoBrowserSwift
//
//  Created by Tapani Saarinen on 04/09/15.
//  Original obj-c created by Michael Waterfall 2013
//
//

import Foundation

public class TapDetectingImageView: UIImageView {
    public weak var tapDelegate: TapDetectingImageViewDelegate?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        userInteractionEnabled = true
    }

    public override init(image: UIImage?) {
        super.init(image: image)
        userInteractionEnabled = true
    }

    public override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        userInteractionEnabled = true
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first  {
            let tapCount = touch.tapCount
        
            switch tapCount {
                case 1: handleSingleTap(touch)
                case 2: handleDoubleTap(touch)
                case 3: handleTripleTap(touch)
                default: break
            }
        }
        
        if let nr = nextResponder() {
            nr.touchesEnded(touches, withEvent: event)
        }
    }

    private func handleSingleTap(touch: UITouch) {
        if let td = tapDelegate {
            td.singleTapDetectedInImageView(self, touch: touch)
        }
    }

    private func handleDoubleTap(touch: UITouch) {
        if let td = tapDelegate {
            td.doubleTapDetectedInImageView(self, touch: touch)
        }
    }

    private func handleTripleTap(touch: UITouch) {
        if let td = tapDelegate {
            td.tripleTapDetectedInImageView(self, touch: touch)
        }
    }
}

public protocol TapDetectingImageViewDelegate: class {
    func singleTapDetectedInImageView(view: UIImageView, touch: UITouch)
    func doubleTapDetectedInImageView(view: UIImageView, touch: UITouch)
    func tripleTapDetectedInImageView(view: UIImageView, touch: UITouch)
}