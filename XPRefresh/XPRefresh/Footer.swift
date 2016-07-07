//
//  Foot.swift
//  XPRefresh
//
//  Created by jamalping on 16/6/25.
//  Copyright © 2016年 jamalping. All rights reserved.
//

import UIKit

public class Footer: Component,LoadDataProtocol {
    
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
            case .Refreshing:
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC/2)), dispatch_get_main_queue(), {
                    if let BeginRefreshingCallBack = self.BeginRefreshingCallBack {
                        BeginRefreshingCallBack()
                    }
                    if let RefreshingCallBack = self.RefreshingCallBack {
                        RefreshingCallBack()
                    }
                })
            case .Normal, .NoMoreData:
                if oldValue == .Refreshing {
                    if let XPEndreshingCallBack = self.EndreshingCallBack {
                        XPEndreshingCallBack()
                    }
                }
            default: break
            }
            print(self._scrollView.contentSize,self._scrollView.contentInsetBottom)
        }
    }
    
    
    public init(_ refreshAction: CallBack) {
        super.init(frame: CGRectZero)
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
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        xp_footerStateLabel.frame = self.bounds
    }
    
    override public func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        if let _ = newSuperview {
            if !self.hidden {
                self._scrollView.contentInsetBottom += self.height
            }
            self.top = self._scrollView.contentHeight
        }else { // 被移除了
            if !self.hidden {
                self._scrollView.contentInsetBottom -= self.height
            }
        }
    }
    
    // 实现协议
    func loadDataCallBack(totalCount: Int) {
        if automaticallyHidden {
            self.hidden = totalCount == 0
        }
    }
    
    override public var hidden: Bool {
        set {
            super.hidden = newValue
            if !hidden && newValue {
                self._state = .Normal
                self._scrollView.contentInsetBottom -= self.height
            }else if hidden && !newValue {
                self._scrollView.contentInsetBottom += self.height
                self.top = self._scrollView.contentHeight
            }
        }
        get { return super.hidden }
    }
    
    /// MARK 观察者
    override func addObservers() {
        super.addObservers()
        guard let scrollView = self._scrollView else { return }
        scrollView.addObserver(self, forKeyPath: KeyPathContentOffset, options: [.New, .Old], context: nil)
        scrollView.addObserver(self, forKeyPath: KeyPathContentSize, options: [.New, .Old], context: nil)
    }
    
    override func removeObservers() {
        super.removeObservers()
        guard let scrollView = self._scrollView else { return }
        scrollView.removeObserver(self, forKeyPath: KeyPathContentOffset)
        scrollView.removeObserver(self, forKeyPath: KeyPathContentSize)
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard self.userInteractionEnabled else { return }
        
        if keyPath == KeyPathContentSize {
            scrollViewContentSizeDidChange()
        }
        
        guard !self.hidden else { return }
        
        if keyPath == KeyPathContentOffset {
            scrollViewContentOffsetDidChange(change)
        }
    }
    
    func scrollViewContentSizeDidChange() {
        self.top = self._scrollView.contentHeight
    }
    
    func scrollViewContentOffsetDidChange(change: [String: AnyObject]?) {
        if self._state != .Normal || !self.automaticallyHidden || self.top == 0 {
            return
        }
        if (_scrollView.contentInsetTop + _scrollView.contentHeight > _scrollView.height) { // 内容超过一个屏幕
            if (_scrollView.contentOffsetY >= _scrollView.contentHeight - _scrollView.height + self.height + _scrollView.contentInsetBottom - self.height) {
                // 防止手松开时连续调用
                let old = change!["old"]?.CGPointValue()
                let new = change!["new"]?.CGPointValue()
                if new?.y <= old?.y { return }
                // 当底部刷新控件完全出现时，才刷新
                UIView.animateWithDuration(AnimationDuration, animations: {
                    self.alpha = 1.0
                })
                // 只要正在刷新，就完全显示
                if self.window != nil {
                    self._state = .Refreshing;
                } else {
                    // 预发当前正在刷新中时调用本方法使得header insert回置失败
                    if self._state != .Refreshing {
                        self._state = .WillRefresh;
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
        result.updateValue(BackFooterNomalText, forKey: .Normal)
        result.updateValue(BackFooterRefreshingText, forKey: .Refreshing)
        result.updateValue(BackFooterNoMoreDataText, forKey: .NoMoreData)
        return result
    }()
    
    var state: State = .Normal {
        didSet {
            guard oldValue != state else { return }
            switch state {
            case .Refreshing:
                self.loadingView.startAnimating()
                if refreshingTitleHidden {
                    self.stataLable.text = nil
                }
                self.stataLable.text = stateTitles[state]
            case .Normal, .NoMoreData:
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
