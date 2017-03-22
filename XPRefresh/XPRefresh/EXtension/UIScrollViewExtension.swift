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
private var loadDataCallBack = "loadDataCallBack"
// MARK -- 和刷新相关的拓展  
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
    
    // 获取tableView 或者 CollectionView 的row的总个数
    public var totalDataCount: Int {
        get {
            var result = 0
            if let tableView = self as? UITableView {
                for section in 0 ..< tableView.numberOfSections {
                    result += tableView.numberOfRows(inSection: section)
                }
            }else if let collectionView = self as? UICollectionView {
                for section in 0 ..< collectionView.numberOfSections {
                    result += collectionView.numberOfItems(inSection: section)
                }
            }
            return result
        }
    }
    
    public func endRefresh() {
        self.xp_header?.endRefresh()
        self.xp_footer?.endRefresh()
    }
}

// TableView CollectionView 加载数据时的协议，
protocol LoadDataProtocol {
    func loadDataCallBack(_ totalCount: Int) -> Void
}

extension UITableView {
    public func xp_loadData() {
        self.xp_loadData()
        if let loadDataer = self as? LoadDataProtocol {
            loadDataer.loadDataCallBack(self.totalDataCount)
        }
    }
    
    open override class func initialize() {
        struct Static {
            static var token: Int = 0
        }
        
        // make sure this isn't a subclass
        if self !== UITableView.self {
            return
        }
        if Static.token == 0 {
            
            let originalSelector = #selector(UITableView.reloadData)
            let swizzledSelector = #selector(UITableView.xp_loadData)
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
            Static.token += 1
        }
    }
}

extension UICollectionView {
    public func xp_loadData() {
        self.xp_loadData()
        if let loadDataer = self as? LoadDataProtocol {
            loadDataer.loadDataCallBack(self.totalDataCount)
        }
    }
    
    open override class func initialize() {
        struct Static {
            static var token: Int = 0
        }
        
        // make sure this isn't a subclass
        if self !== UICollectionView.self {
            return
        }
        if Static.token == 0 {
            let originalSelector = #selector(UICollectionView.reloadData)
            let swizzledSelector = #selector(UICollectionView.xp_loadData)
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
            Static.token += 1
        }
    }
}
