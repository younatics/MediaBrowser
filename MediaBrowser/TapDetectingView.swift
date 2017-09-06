//
//  TapDetectingView.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//
//

import Foundation

public class TapDetectingView: UIView {
    public weak var tapDelegate: TapDetectingViewDelegate?
    
    public init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = true
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first  {
            let tapCount = touch.tapCount
        
            switch tapCount {
                case 1: handleSingleTap(touch: touch)
                case 2: handleDoubleTap(touch: touch)
                case 3: handleTripleTap(touch: touch)
                default: break
            }
        }
        
        if let nr = nextResponder {
            nr.touchesEnded(touches, with: event)
        }
    }

    private func handleSingleTap(touch: UITouch) {
        if let td = tapDelegate {
            td.singleTapDetectedInView(view: self, touch: touch)
        }
    }

    private func handleDoubleTap(touch: UITouch) {
        if let td = tapDelegate {
            td.doubleTapDetectedInView(view: self, touch: touch)
        }
    }

    private func handleTripleTap(touch: UITouch) {
        if let td = tapDelegate {
            td.tripleTapDetectedInView(view: self, touch: touch)
        }
    }
}

public protocol TapDetectingViewDelegate: class {
    func singleTapDetectedInView(view: UIView, touch: UITouch)
    func doubleTapDetectedInView(view: UIView, touch: UITouch)
    func tripleTapDetectedInView(view: UIView, touch: UITouch)
}
