//
//  MediaTapDetectingView.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//
//

import Foundation

class MediaTapDetectingView: UIView {
    weak var tapDelegate: TapDetectingViewDelegate?
    
    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first  {
            let tapCount = touch.tapCount
            
            switch tapCount {
            case 1: handleSingleTap(touch: touch)
            case 2: handleDoubleTap(touch: touch)
            case 3: handleTripleTap(touch: touch)
            default: break
            }
        }
        
        if let nr = next {
            nr.touchesEnded(touches, with: event)
        }
    }
    
    func handleSingleTap(touch: UITouch) {
        if let td = tapDelegate {
            td.singleTapDetectedInView(view: self, touch: touch)
        }
    }
    
    func handleDoubleTap(touch: UITouch) {
        if let td = tapDelegate {
            td.doubleTapDetectedInView(view: self, touch: touch)
        }
    }
    
    func handleTripleTap(touch: UITouch) {
        if let td = tapDelegate {
            td.tripleTapDetectedInView(view: self, touch: touch)
        }
    }
}

protocol TapDetectingViewDelegate: class {
    func singleTapDetectedInView(view: UIView, touch: UITouch)
    func doubleTapDetectedInView(view: UIView, touch: UITouch)
    func tripleTapDetectedInView(view: UIView, touch: UITouch)
}
