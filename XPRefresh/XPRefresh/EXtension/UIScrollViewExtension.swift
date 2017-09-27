//
//  UIScrollViewExtension.swift
//  XPRefresh
//
//  Created by jamalping on 16/6/20.
//  Copyright © 2016年 jamalping. All rights reserved.
//

import UIKit

extension UIScrollView {
    public var contentInsetTop: CGFloat {
        get { return self.contentInset.top }
        set { self.contentInset.top = newValue }
    }
    public var contentInsetBottom: CGFloat {
        get { return self.contentInset.bottom }
        set { self.contentInset.bottom = newValue }
    }
    public var contentInsetLeft: CGFloat {
        get { return self.contentInset.left }
        set { self.contentInset.left = newValue }
    }
    public var contentInsetRight: CGFloat {
        get { return self.contentInset.right }
        set { self.contentInset.right = newValue }
    }
    
    public var contentOffsetX: CGFloat {
        get { return self.contentOffset.x }
        set { self.contentOffset.x = newValue }
    }
    public var contentOffsetY: CGFloat {
        get { return self.contentOffset.y }
        set { self.contentOffset.y = newValue }
    }
    
    public var contentWidth: CGFloat {
        get { return self.contentSize.width }
        set { self.contentSize.width = newValue }
    }
    public var contentHeight: CGFloat {
        get { return self.contentSize.height }
        set { self.contentSize.height = newValue }
    }
}

private var HeaderKey = "HeaderKey"
private var FooterKey = "FooterKey"
// MARK: --- 拓展刷新控件
extension UIScrollView {
    public var xp_header: Header? {
        set {
            if xp_header != newValue {
                xp_header?.removeFromSuperview()
                self.insertSubview(newValue!, at: 0)
                
                self.willChangeValue(forKey: "xp_header")
                objc_setAssociatedObject(self, &HeaderKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
                self.didChangeValue(forKey: "xp_header")
            }
        }
        get { return objc_getAssociatedObject(self, &HeaderKey) as? Header }
    }
    
    public var xp_footer: Footer? {
        set {
            if xp_footer != newValue {
                xp_footer?.removeFromSuperview()
            }
            self.insertSubview(newValue!, at: 0)
            self.willChangeValue(forKey: "xp_footer")
            objc_setAssociatedObject(self, &FooterKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            self.didChangeValue(forKey: "xp_footer")
        }
        get { return objc_getAssociatedObject(self, &FooterKey) as? Footer }
    }
    
    public func endRefresh() {
        self.xp_header?.endRefresh()
        self.xp_footer?.endRefresh()
    }
}
