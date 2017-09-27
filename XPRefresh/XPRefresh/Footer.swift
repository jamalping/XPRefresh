//
//  Foot.swift
//  XPRefresh
//
//  Created by jamalping on 16/6/25.
//  Copyright © 2016年 jamalping. All rights reserved.
//

import UIKit

/// 上拉刷新控件
open class Footer: Component {
    /// 刷新显示的文字label
    let xp_footerStateLabel = XPFooterStateLabel()
    
    /// 当前状态
    override var state: RefreshState  {
        didSet {
            print(self._scrollView.contentSize,self._scrollView.contentInsetBottom)
            guard state != oldValue else {
                return
            }
            xp_footerStateLabel.state = state
            switch state {
            case .refreshing:
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC/2)) / Double(NSEC_PER_SEC), execute: {
                    if let beginRefreshingCallBack = self.beginRefreshingCallBack {
                        beginRefreshingCallBack()
                    }
                    if let RefreshingCallBack = self.refreshingCallBack {
                        RefreshingCallBack()
                    }
                })
            case .normal, .noMoreData:
                if oldValue == .refreshing {
                    if let XPEndreshingCallBack = self.endreshingCallBack {
                        XPEndreshingCallBack()
                    }
                }
            default: break
            }
            print(self._scrollView.contentSize,self._scrollView.contentInsetBottom)
        }
    }
    
    
    /// 初始化方法
    ///
    /// - Parameter refreshAction: 刷新的回调
    public init(_ refreshAction: @escaping callBack) {
        super.init(frame: CGRect.zero)
        self.refreshingCallBack = refreshAction
        self.height = FooterHeight
        
        self.addSubview(xp_footerStateLabel)
    }
    
    deinit {
        removeObservers()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        xp_footerStateLabel.frame = self.bounds
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if let _ = newSuperview {
            if !self.isHidden {
                self._scrollView.contentInsetBottom += self.height
            }
            self.top = self._scrollView.contentHeight
        }else { // 被移除了
            if !self.isHidden {
                self._scrollView.contentInsetBottom -= self.height
            }
        }
    }
    
    override open var isHidden: Bool {
        set {
            super.isHidden = newValue
            if !isHidden && newValue {
                self.state = .normal
                self._scrollView.contentInsetBottom -= self.height
            }else if isHidden && !newValue {
                self._scrollView.contentInsetBottom += self.height
                self.top = self._scrollView.contentHeight
            }
        }
        get { return super.isHidden }
    }
    
    /// MARK 观察者
    override func addObservers() {
        super.addObservers()
        guard let scrollView = self._scrollView else { return }
        scrollView.addObserver(self, forKeyPath: KeyPathContentOffset, options: [.new, .old], context: nil)
        scrollView.addObserver(self, forKeyPath: KeyPathContentSize, options: [.new, .old], context: nil)
    }
    
    override func removeObservers() {
        super.removeObservers()
        guard let scrollView = self._scrollView else { return }
        scrollView.removeObserver(self, forKeyPath: KeyPathContentOffset)
        scrollView.removeObserver(self, forKeyPath: KeyPathContentSize)
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard self.isUserInteractionEnabled else { return }
        
        if keyPath == KeyPathContentSize {
            scrollViewContentSizeDidChange()
        }
        
        guard !self.isHidden else { return }
        
        if keyPath == KeyPathContentOffset {
            scrollViewContentOffsetDidChange(change)
        }
    }
    
    func scrollViewContentSizeDidChange() {
        self.top = self._scrollView.contentHeight
    }
    
    
    /// 监听ScrollView的滚动
    func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey: Any]?) {
        if self.state != .normal || self.top == 0 {
            return
        }
        if (_scrollView.contentInsetTop + _scrollView.contentHeight > _scrollView.height) { // 内容超过一个屏幕
            if (_scrollView.contentOffsetY >= _scrollView.contentHeight - _scrollView.height + self.height + _scrollView.contentInsetBottom - self.height) {
                // 防止手松开时连续调用
                guard let oldPoint = change?[.oldKey] as? CGPoint else {
                    return
                }
                guard let newPoint = change?[.newKey] as? CGPoint else {
                    return
                }
                if newPoint.y <= oldPoint.y { return }
                // 当底部刷新控件完全出现时，才刷新
                UIView.animate(withDuration: AnimationDuration, animations: {
                    self.alpha = 1.0
                })
                // 只要正在刷新，就完全显示
                if self.window != nil {
                    self.state = .refreshing;
                } else {
                    // 预发当前正在刷新中时调用本方法使得header insert回置失败
                    if self.state != .refreshing {
                        self.state = .willRefresh;
                    }
                }
                
            }
        }
    }
}

class XPFooterStateLabel: UILabel {
    
    /// 菊花
    var loadingView: UIActivityIndicatorView = {
        let indicatorView =
            UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        indicatorView.hidesWhenStopped = true
        return indicatorView
    }()
    
    /// 文字
    var stataLable = UILabel.init(BackFooterNomalText)
    
    /// 是否隐藏文字
    var refreshingTitleHidden = false
    
    /// 获取不同状态的刷新文字
    let stateTitles: [RefreshState: String] = {
        var result = [RefreshState: String]()
        result.updateValue(BackFooterNomalText, forKey: .normal)
        result.updateValue(BackFooterRefreshingText, forKey: .refreshing)
        result.updateValue(BackFooterNoMoreDataText, forKey: .noMoreData)
        return result
    }()
    
    /// 刷新状态
    var state: RefreshState = .normal {
        didSet {
            guard oldValue != state else { return }
            switch state {
            case .refreshing:
                self.loadingView.startAnimating()
                if refreshingTitleHidden {
                    self.stataLable.text = nil
                }
                self.stataLable.text = stateTitles[state]
            case .normal, .noMoreData:
                self.loadingView.stopAnimating()
                self.stataLable.text = stateTitles[state]
            default: break
            }
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(loadingView)
        self.addSubview(stataLable)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if stataLable.constraints.count == 0 {
            self.stataLable.frame = self.bounds
        }
        if (self.loadingView.constraints.count == 0) {
            // 菊花
            var loadingCenterX = self.width / 2
            if !refreshingTitleHidden {
                loadingCenterX -= self.stataLable.textWidth/2 + 20
            }
            
            self.loadingView.center = CGPoint.init(x: loadingCenterX, y: self.height/2)
        }
    }
}
