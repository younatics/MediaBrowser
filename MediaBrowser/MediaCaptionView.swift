//
//  MediaCaptionView.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//
//

import UIKit

/// MediaCaptionView is based in UIToolbar
public class MediaCaptionView: UIToolbar {
    private var media: Media?
    private var label = UILabel()
    
    /// labelPadding
    public let labelPadding = CGFloat(10.0)

    /**
     init with Media
     
     - Parameter media: Media
     */
    public init(media: Media?) {
        super.init(frame: CGRect(x: 0, y: 0, width: 320.0, height: 44.0)) // Random initial frame
        self.media = media
        
        setupCaption()
    }

    /**
     init with coder
     
     - Parameter coder: aDecoder
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCaption()
    }
    
    /**
     sizeThatFits
     
     - Parameter size: CGSize
     */
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var maxHeight = CGFloat(9999.0)
        if label.numberOfLines > 0 {
            maxHeight = label.font.leading * CGFloat(label.numberOfLines)
        }
        
        let textSize: CGSize
        
        if let text = label.text {
            textSize = text.boundingRect(
                with: CGSize(width: size.width - labelPadding * 2.0, height: maxHeight),
                options: .usesLineFragmentOrigin,
                attributes: [NSAttributedString.Key.font : label.font as Any],
                context: nil).size
        } else {
            textSize = CGSize(width: 0, height: 0)
        }
        
        return CGSize(width: size.width, height: textSize.height + labelPadding * 2.0)
    }

    private func setupCaption() {
        isUserInteractionEnabled = false
        tintColor = nil
        barTintColor = nil
        backgroundColor = UIColor.clear
//        isOpaque = false
//        isTranslucent = true
//        clipsToBounds = true
        barStyle = .blackTranslucent
        isTranslucent = true

        autoresizingMask =
            [.flexibleWidth, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
        label = UILabel(frame: CGRect(x: labelPadding, y: 0.0, width: self.bounds.size.width - labelPadding * 2.0, height: self.bounds.size.height))
            
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.isOpaque = false
        label.backgroundColor = UIColor.clear
        label.textAlignment = NSTextAlignment.center
        label.lineBreakMode = .byWordWrapping
        label.minimumScaleFactor = 0.6
        label.adjustsFontSizeToFitWidth = true

        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 17.0)
        
        if let p = media {
            label.text = p.caption
        }
        
        self.addSubview(label)
    }
}
