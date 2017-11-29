//
//  Compon.swift
//  XPRefresh
//
//  Created by jamalping on 16/6/25.
//  Copyright © 2016年 jamalping. All rights reserved.
//

import UIKit
// MARK ---测试分支合并到主干



/// 刷新控件状态
///
/// - normal: 正常状态
/// - pull: 下拉
/// - willRefresh: 将要刷新
/// - refreshing: 刷新
/// - noMoreData: 没有数据
public enum RefreshState {
    case normal
    case pull
    case willRefresh
    case refreshing
    case noMoreData
}


public protocol XPRefreshType {
    associatedtype XPType
    var xp: XPType { get }
}

public extension XPRefreshType {
    public var xp : XPRefresh<Self> {
        get { return XPRefresh.init(base: self) }
    }
}

public struct XPRefresh<Base> {
    public let base: Base
    public init(base: Base) {
        self.base = base
    }
}

// MARK: --- 刷新控件基类
public class Component: UIView {
    
    public typealias callBack = () -> ()
    /// 记录scrollView刚开始的inset
    var scrollViewOriginalInset: UIEdgeInsets = UIEdgeInsets.zero
    /** 父控件 */
    var _scrollView: UIScrollView?
    
    /// 当前的刷新状态
    var state = RefreshState.normal
    
    /// 刷新回调
    var beginRefreshingCallBack: callBack?
    
    var refreshingCallBack: callBack?
    
    var endreshingCallBack: callBack?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 重写将要加载到父视图的方法
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        // 如果不是scorllView，不做任何处理
        guard let scrollView = newSuperview as? UIScrollView else {
            return
        }
        
        removeObservers()
        _scrollView = scrollView
        self.frame = CGRect.init(x: _scrollView!.left, y: -HeaderHeight, width: _scrollView!.width, height: HeaderHeight)
        _scrollView!.alwaysBounceVertical = true
        scrollViewOriginalInset = _scrollView!.xpContentInset
        addObservers()
    }
    
    /// MARK -- 观察者的添加和移除，交给子类实现
    func addObservers() { }
    func removeObservers() { }
}


extension Component {
    public func endRefresh() {
        DispatchQueue.main.async {
            self.state = .normal
        }
    }
}


