//
//  CaptionView.swift
//  MWPhotoBrowserSwift
//
//  Created by Tapani Saarinen on 04/09/15.
//  Original obj-c created by Michael Waterfall 2013
//
//

import UIKit

public class CaptionView: UIToolbar {
    private var photo: Photo?
    private var label = UILabel()
    public let labelPadding = CGFloat(10.0)

    init(photo: Photo?) {
        super.init(frame: CGRectMake(0, 0, 320.0, 44.0)) // Random initial frame
        self.photo = photo
        
        setupCaption()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCaption()
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        var maxHeight = CGFloat(9999.0)
        if label.numberOfLines > 0 {
            maxHeight = label.font.leading * CGFloat(label.numberOfLines)
        }
        
        let textSize: CGSize
        
        if let text = label.text {
            textSize = text.boundingRectWithSize(
                CGSizeMake(size.width - labelPadding * 2.0, maxHeight),
                options: .UsesLineFragmentOrigin,
                attributes: [NSFontAttributeName : label.font],
                context: nil).size
        }
        else {
            textSize = CGSizeMake(0.0, 0.0)
        }
        
        return CGSizeMake(size.width, textSize.height + labelPadding * 2.0)
    }

    private func setupCaption() {
        userInteractionEnabled = false
        barStyle = .Default
        tintColor = UIColor.clearColor()
        barTintColor = UIColor.whiteColor()
        backgroundColor = UIColor.whiteColor()
        opaque = false
        translucent = true
        clipsToBounds = true
        setBackgroundImage(nil, forToolbarPosition: .Any, barMetrics: .Default)
        autoresizingMask =
            [.FlexibleWidth, .FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin]
        
        label = UILabel(frame: CGRectIntegral(CGRectMake(
            labelPadding,
            0.0,
            self.bounds.size.width - labelPadding * 2.0,
            self.bounds.size.height)))
            
        label.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        label.opaque = false
        label.backgroundColor = UIColor.clearColor()
        label.textAlignment = NSTextAlignment.Center
        label.lineBreakMode = .ByWordWrapping
        label.minimumScaleFactor = 0.6
        label.adjustsFontSizeToFitWidth = true

        label.numberOfLines = 0
        label.textColor = UIColor.blackColor()
        label.font = UIFont.systemFontOfSize(17.0)
        
        if let p = photo {
            label.text = p.caption
        }
        
        self.addSubview(label)
    }
}
