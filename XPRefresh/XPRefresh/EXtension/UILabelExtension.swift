//
//  UILabelExtension.swift
//  XPRefresh
//
//  Created by jamalping on 16/6/24.
//  Copyright © 2016年 jamalping. All rights reserved.
//

import UIKit

extension UILabel {
    public var textWidth: CGFloat {
        get {
            var stringWidth: CGFloat = 0
            let size = CGSize.init(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT))
            guard let text = self.text else { return 0 }
            if text.length > 0 {
                stringWidth = text.boundingRectWithSize(size, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName : self.font], context: nil).width
            }
            return stringWidth
        }
    }
}
