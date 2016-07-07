//
//  UIViewEXtension.swift
//  XPRefresh
//
//  Created by jamalping on 16/6/17.
//  Copyright © 2016年 jamalping. All rights reserved.
//

import UIKit

extension UIView {
    
    public var left: CGFloat {
        set { self.frame.origin.x = newValue }
        get { return self.frame.minX }
    }
    public var top: CGFloat {
        set { self.frame.origin.y = newValue }
        get { return self.frame.minY }
    }
    public var right: CGFloat {
        set { self.frame.origin.x = newValue - self.frame.width }
        get { return self.frame.maxX }
    }
    public var bottom: CGFloat {
        set { self.frame.origin.y = newValue - self.frame.maxY }
        get { return self.frame.maxY }
    }
    
    public var width: CGFloat {
        set { self.frame.size.width = newValue }
        get { return self.frame.width }
    }
    
    public var height: CGFloat {
        set { self.frame.size.height = newValue }
        get { return self.frame.height }
    }
    public var centerX: CGFloat {
        set { self.center = CGPoint.init(x: newValue, y: self.center.y) }
        get { return self.center.x }
    }
    
    public var centerY: CGFloat {
        set { self.center = CGPoint.init(x: self.center.x, y: newValue) }
        get { return self.center.y }
    }
    
    public var size: CGSize {
        set { self.frame = CGRect.init(origin: self.frame.origin, size: newValue) }
        get { return self.frame.size }
    }
    public var origin: CGPoint {
        set { self.frame = CGRect.init(origin: newValue, size: self.frame.size) }
        get { return self.frame.origin }
    }
    
}

