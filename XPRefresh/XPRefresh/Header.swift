//
//  component.swift
//  XPRefresh
//
//  Created by jamalping on 16/6/17.
//  Copyright © 2016年 jamalping. All rights reserved.
//

import UIKit

/// 下拉控件：监听用户下拉状态
public class Header: Component {
    
    private var insetTopDelta: CGFloat = 0
    
    private let xp_headerStateLabel = XPHeaderStateLabel()
    
    // 重写_state
    override var _state: State {
        didSet {
            guard _state != oldValue else {
                return
            }
            xp_headerStateLabel.state = _state
            
            switch _state {
            case .Normal:
                if oldValue != .Refreshing { return }
                // 恢复inset和offset
                UIView.animateWithDuration(AnimationDuration, animations: {
                    self._scrollView.contentInsetTop += self.insetTopDelta
                    }, completion: { (finished) in
                        if let EndreshingCallBack = self.EndreshingCallBack {
                            EndreshingCallBack()
                        }
                })
            case .Pull:
                print("松开即可刷新")
            case .WillRefresh:
                print("将要刷新")
            case .Refreshing:
                dispatch_async(dispatch_get_main_queue(), {
                    UIView.animateWithDuration(AnimationDuration, animations: {
                        let top = self._scrollViewOriginalInset.top + self.height
                        self._scrollView.contentInsetTop = top
                        self._scrollView.contentOffset = CGPoint.init(x: 0, y: -top)
                        }, completion: { (finished) in
                            // 刷新回调
                            dispatch_async(dispatch_get_main_queue(), {
                                if let BeginRefreshingCallBack = self.BeginRefreshingCallBack {
                                    BeginRefreshingCallBack()
                                }
                                if let RefreshingCallBack = self.RefreshingCallBack {
                                    RefreshingCallBack()
                                }
                            })
                    })
                })
            case .NoMoreData: break
            }
        }
    }
    /// init
    public init(_ refreshAction: CallBack) {
        super.init(frame: CGRectZero)
        self.RefreshingCallBack = refreshAction
        
        self.addSubview(self.xp_headerStateLabel)
        
        self.autoresizingMask = .FlexibleWidth
        self.backgroundColor = UIColor.clearColor()
    }
    
    deinit {
        removeObservers()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func addObservers() {
        super.addObservers()
        guard let scrollView = self._scrollView else { return }
        scrollView.addObserver(self, forKeyPath: KeyPathContentOffset, options: [.New, .Old], context: nil)
    }
    
    override func removeObservers() {
        super.removeObservers()
        guard let scrollView = self._scrollView else { return }
        scrollView.removeObserver(self, forKeyPath: KeyPathContentOffset)
    }
    
    override public func layoutSubviews() {
        // 基本属性
        super.layoutSubviews()
        self.xp_headerStateLabel.frame = self.bounds
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        // 遇到这些情况，直接返回
        guard self.userInteractionEnabled && !self.hidden else { return }
        scrollViewContentOffsetDidchange(change)
    }
    
    func scrollViewContentOffsetDidchange(change:[String: AnyObject]?) {
        if self._state == .Refreshing {
            guard let _ = self.window else { return }
            // seactionHeader停留解决
            var insetTop = -self._scrollView.contentOffsetY > _scrollViewOriginalInset.top ?  -self._scrollView.contentOffsetY : _scrollViewOriginalInset.top
            insetTop = (insetTop > self.height + _scrollViewOriginalInset.top) ? self.height + _scrollViewOriginalInset.top : insetTop
            self._scrollView.contentInsetTop = insetTop;
            
            self.insetTopDelta = _scrollViewOriginalInset.top - insetTop;
            return
        }
        
        _scrollViewOriginalInset = _scrollView.contentInset
        
        // 当前的contentOffset
        let offsetY = self._scrollView.contentOffsetY
        // 头部空间刚好出现的offset
        let happenOffsetTop = -_scrollViewOriginalInset.top
        // 看不见头部控件，直接返回.
        if offsetY > happenOffsetTop { return }
        
        let normalpullingOffsetY = happenOffsetTop - self.height
        if _scrollView.dragging {
            if self._state == .Normal && offsetY < normalpullingOffsetY {
                self._state = .Pull
            }else if self._state == .Pull && offsetY > normalpullingOffsetY {
                self._state = .Normal
            }
        }else if self._state == .Pull {
            self._state = .Refreshing
        }
    }
}


class XPHeaderStateLabel: UILabel {
    
    private let stateLabel = creatLabelWithTitle(HeaderNomalText)
    private let lastUpdatedLabel = creatLabelWithTitle(getLastUpdateTime())
    private let arrowView: UIImageView = {
        let imageView = UIImageView.init(image: xp_arrowImage())
        return imageView
    }()
    private let loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        return view
    }()
    
    private var statesTitles: [State: String] = {
        var result = [State: String]()
        result.updateValue(HeaderNomalText, forKey: .Normal)
        result.updateValue(HeaderPullingText, forKey: .Pull)
        result.updateValue(HeaderRefreshingText, forKey: .Refreshing)
        return result
    }()
    
    private var state: State = .Normal {
        didSet {
            guard oldValue != state else { return }
            self.stateLabel.text = self.statesTitles[state]
            setArrowViewWithState(oldValue)
            self.lastUpdatedLabel.text = getLastUpdateTime()
            setNeedsLayout()
        }
    }
    
    private func setArrowViewWithState(oldState: State) {
        switch state {
        case .Normal:
            if oldState == .Refreshing {
                arrowView.transform = CGAffineTransformIdentity
                UIView.animateWithDuration(AnimationDuration, animations: {
                    self.loadingView.alpha = 0.0
                    }, completion: { (finished) in
                        if self.state != .Normal { return }
                        self.loadingView.alpha = 1.0
                        self.loadingView.stopAnimating()
                        self.arrowView.hidden = false
                })
            }else {
                self.loadingView.stopAnimating()
                self.arrowView.hidden = false
                UIView.animateWithDuration(AnimationDuration, animations: {
                    self.arrowView.transform = CGAffineTransformIdentity
                })
            }
        case .Pull:
            self.loadingView.stopAnimating()
            self.arrowView.hidden = false
            UIView.animateWithDuration(AnimationDuration, animations: {
                self.arrowView.transform = CGAffineTransformMakeRotation(0.000001 - CGFloat(M_PI))
            })
        case .Refreshing:
            self.loadingView.alpha = 1
            self.loadingView.startAnimating()
            self.arrowView.hidden = true
        default:
            break
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(stateLabel)
        self.addSubview(lastUpdatedLabel)
        self.addSubview(arrowView)
        self.addSubview(loadingView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if self.stateLabel.hidden { return }
        
        var arrowCenterX = self.width * 0.5
        let offset: CGFloat = 20
        let stateWidth = self.stateLabel.textWidth
        var timeWidth: CGFloat = 0
        
        let noConstrainsOnStateLabel = stateLabel.constraints.count == 0
        if lastUpdatedLabel.hidden {
            
            if noConstrainsOnStateLabel { self.stateLabel.frame = self.bounds }
        }else {
            // 箭头
            timeWidth = self.lastUpdatedLabel.textWidth
            let textWidth = max(stateWidth, timeWidth)
            arrowCenterX -= textWidth / 2 + offset
            let arrowCenterY = self.height * 0.5
            if arrowView.constraints.count == 0 {
                arrowView.size = arrowView.image!.size
                arrowView.center = CGPoint(x: arrowCenterX, y: arrowCenterY)
            }
            self.arrowView.tintColor = self.stateLabel.textColor;
            
            // 圈圈
            if loadingView.constraints.count == 0 {
                loadingView.center = CGPoint(x: arrowCenterX, y: arrowCenterY)
            }
            
            // 状态label
            let stateLabelHeight: CGFloat = self.height * 0.5
            if noConstrainsOnStateLabel {
                self.stateLabel.frame = CGRect.init(x: 0, y: 0, width: self.width, height: stateLabelHeight)
                
            }
            // 上次更新时间label
            if lastUpdatedLabel.constraints.count == 0 {
                self.lastUpdatedLabel.frame = CGRect.init(x: 0, y: stateLabelHeight, width: self.width, height: self.height - self.lastUpdatedLabel.top)
            }
        }
        
    }
}






