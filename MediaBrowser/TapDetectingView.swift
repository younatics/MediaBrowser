//
//  TapDetectingView.swift
//  MWPhotoBrowserSwift
//
//  Created by Tapani Saarinen on 04/09/15.
//  Original obj-c created by Michael Waterfall 2013
//
//

import Foundation

public class TapDetectingView: UIView {
    public weak var tapDelegate: TapDetectingViewDelegate?
    
    public init() {
        super.init(frame: CGRectZero)
        userInteractionEnabled = true
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
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
            td.singleTapDetectedInView(self, touch: touch)
        }
    }

    private func handleDoubleTap(touch: UITouch) {
        if let td = tapDelegate {
            td.doubleTapDetectedInView(self, touch: touch)
        }
    }

    private func handleTripleTap(touch: UITouch) {
        if let td = tapDelegate {
            td.tripleTapDetectedInView(self, touch: touch)
        }
    }
}

public protocol TapDetectingViewDelegate: class {
    func singleTapDetectedInView(view: UIView, touch: UITouch)
    func doubleTapDetectedInView(view: UIView, touch: UITouch)
    func tripleTapDetectedInView(view: UIView, touch: UITouch)
}
