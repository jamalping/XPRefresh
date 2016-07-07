//
//  StringExtension.swift
//  XPRefresh
//
//  Created by jamalping on 16/6/24.
//  Copyright © 2016年 jamalping. All rights reserved.
//

import UIKit

extension String {
    var length: Int {
        get { return self.characters.count }
    }
    
    func textWidth(font: UIFont) -> CGFloat {
        var stringWidth: CGFloat = 0
        let size = CGSize.init(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT))
        if self.length > 0 {
            stringWidth = self.boundingRectWithSize(size, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil).width
        }
        return stringWidth
    }
}