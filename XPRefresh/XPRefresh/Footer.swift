//
//  Foot.swift
//  XPRefresh
//
//  Created by jamalping on 16/6/25.
//  Copyright © 2016年 jamalping. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


open class Footer: Component,LoadDataProtocol {
    
    // 是否自动隐藏。
    var automaticallyHidden = true
    
    let xp_footerStateLabel = XPFooterStateLabel()
    
    override var _state: State  {
        didSet {
            print(self._scrollView.contentSize,self._scrollView.contentInsetBottom)
            guard _state != oldValue else {
                return
            }
            xp_footerStateLabel.state = _state
            switch _state {
            case .refreshing:
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC/2)) / Double(NSEC_PER_SEC), execute: {
                    if let BeginRefreshingCallBack = self.BeginRefreshingCallBack {
                        BeginRefreshingCallBack()
                    }
                    if let RefreshingCallBack = self.RefreshingCallBack {
                        RefreshingCallBack()
                    }
                })
            case .normal, .noMoreData:
                if oldValue == .refreshing {
                    if let XPEndreshingCallBack = self.EndreshingCallBack {
                        XPEndreshingCallBack()
                    }
                }
            default: break
            }
            print(self._scrollView.contentSize,self._scrollView.contentInsetBottom)
        }
    }
    
    
    public init(_ refreshAction: @escaping CallBack) {
        super.init(frame: CGRect.zero)
        self.RefreshingCallBack = refreshAction
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
    
    // 实现协议
    func loadDataCallBack(_ totalCount: Int) {
        if automaticallyHidden {
            self.isHidden = totalCount == 0
        }
    }
    
    override open var isHidden: Bool {
        set {
            super.isHidden = newValue
            if !isHidden && newValue {
                self._state = .normal
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
    
    func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey: Any]?) {
        if self._state != .normal || !self.automaticallyHidden || self.top == 0 {
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
                    self._state = .refreshing;
                } else {
                    // 预发当前正在刷新中时调用本方法使得header insert回置失败
                    if self._state != .refreshing {
                        self._state = .willRefresh;
                    }
                }
                
            }
        }
    }
}

class XPFooterStateLabel: UILabel {
    var loadingView = creatIndicatorViewWithStyle()
    
    var stataLable = creatLabelWithTitle(BackFooterNomalText)
    
    var refreshingTitleHidden = false
    
    let stateTitles: [State: String] = {
        var result = [State: String]()
        result.updateValue(BackFooterNomalText, forKey: .normal)
        result.updateValue(BackFooterRefreshingText, forKey: .refreshing)
        result.updateValue(BackFooterNoMoreDataText, forKey: .noMoreData)
        return result
    }()
    
    var state: State = .normal {
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
