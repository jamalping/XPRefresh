//
//  UIScrollViewExtension.swift
//  XPRefresh
//
//  Created by jamalping on 16/6/20.
//  Copyright © 2016年 jamalping. All rights reserved.
//

import UIKit

func largerThan(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version) != ComparisonResult.orderedAscending
}

extension UIScrollView {
    
    public var xpContentInset: UIEdgeInsets {
        get {
            if #available(iOS 11.0, *) {
                return self.adjustedContentInset
            } else {
                return self.contentInset
            }
        }
    }
    
    public var contentInsetTop: CGFloat {
        get {
//            return self.contentInset.top
            if #available(iOS 11.0, *) {
                return self.adjustedContentInset.top
            } else {
                return self.contentInset.top
            }
        }
        set {
//            self.contentInset.top = newValue
            var inset = self.contentInset
            inset.top = newValue
            if #available(iOS 11.0, *) {
                inset.top -= (self.adjustedContentInset.top - self.contentInset.top)
            }
            self.contentInset = inset
        }
    }
    public var contentInsetBottom: CGFloat {
        get {
//            return self.contentInset.bottom
            if #available(iOS 11.0, *) {
                return self.adjustedContentInset.bottom
            } else {
                return self.contentInset.bottom
            }
        }
        set {
            self.contentInset.bottom = newValue
            if #available(iOS 11.0, *) {
                self.contentInset.bottom -= self.adjustedContentInset.bottom - self.contentInset.bottom
            }
        }
    }
    public var contentInsetLeft: CGFloat {
        get {
//            return self.contentInset.left
            if #available(iOS 11.0, *) {
                return self.adjustedContentInset.left
            } else {
                return self.contentInset.left
            }
        }
        set {
            self.contentInset.left = newValue
            if #available(iOS 11.0, *) {
                self.contentInset.left -= self.adjustedContentInset.left - self.contentInset.left
            }
        }
    }
    public var contentInsetRight: CGFloat {
        get {
//            return self.contentInset.right
            if #available(iOS 11.0, *) {
                return self.adjustedContentInset.right
            } else {
                return self.contentInset.right
            }
        }
        set {
            self.contentInset.right = newValue
            if #available(iOS 11.0, *) {
                self.contentInset.right -= self.adjustedContentInset.right - self.contentInset.right
            }
        }
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

extension XPRefresh where Base: UIScrollView {
    
    
    /// 下拉刷新控件
    ///
    /// - Parameters:
    ///   - beginRefresh:刷新之前的回调
    ///   - refreshing: 刷新时的回调
    ///   - endRefresh: 刷新后的回调
    func setHeader(_ beginRefresh: (()->())? = nil, refreshing: @escaping (() -> ()), _ endRefresh: (()->())? = nil) {
        self.base.xp_header = Header.init(refreshing)
        
        self.base.xp_header?.beginRefreshingCallBack = beginRefresh
        self.base.xp_header?.endreshingCallBack = endRefresh
    }
    
    func setFooter(refreshing: @escaping (()->()), _ beginRefresh: (() -> ())? = nil,  _ endRefresh: (() ->())? = nil) {
        self.base.xp_footer = Footer.init(refreshing)
//        self.base.xp_footer?.beginRefreshingCallBack = beginRefresh
//        self.base.xp_footer?.endreshingCallBack = endRefresh
    }
    
    public func endRefresh() {
        self.base.xp_header?.endRefresh()
        self.base.xp_footer?.endRefresh()
    }
}


// MARK: - UIScrollView 遵循 XPRefreshType 协议
extension UIScrollView: XPRefreshType { }

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
