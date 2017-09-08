//
//  CaptionView.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 6..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//
//

import UIKit

public class CaptionView: UIToolbar {
    private var photo: MWPhoto?
    private var label = UILabel()
    public let labelPadding = CGFloat(10.0)

    init(photo: MWPhoto?) {
        super.init(frame: CGRect(x: 0, y: 0, width: 320.0, height: 44.0)) // Random initial frame
        self.photo = photo
        
        setupCaption()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCaption()
    }
    
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
                attributes: [NSFontAttributeName : label.font],
                context: nil).size
        }
        else {
            textSize = CGSize(width: 0, height: 0)
        }
        
        return CGSize(width: size.width, height: textSize.height + labelPadding * 2.0)
    }

    private func setupCaption() {
        isUserInteractionEnabled = false
        barStyle = .default
        tintColor = UIColor.clear
        barTintColor = UIColor.white
        backgroundColor = UIColor.white
        isOpaque = false
        isTranslucent = true
        clipsToBounds = true
        setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .default)
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
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 17.0)
        
        if let p = photo {
            label.text = p.caption
        }
        
        self.addSubview(label)
    }
}
