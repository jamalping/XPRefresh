//
//  component.swift
//  XPRefresh
//
//  Created by jamalping on 16/6/17.
//  Copyright © 2016年 jamalping. All rights reserved.
//

import UIKit

/// 下拉控件：监听用户下拉状态
open class Header: Component {
    
    fileprivate var insetTopDelta: CGFloat = 0
    
    fileprivate let xp_headerStateLabel = XPHeaderStateLabel()
    
    // 重写_state
    override var _state: State {
        didSet {
            guard _state != oldValue else {
                return
            }
            xp_headerStateLabel.state = _state
            
            switch _state {
            case .normal:
                if oldValue != .refreshing { return }
                // 恢复inset和offset
                UIView.animate(withDuration: AnimationDuration, animations: {
                    self._scrollView.contentInsetTop += self.insetTopDelta
                    }, completion: { (finished) in
                        if let EndreshingCallBack = self.EndreshingCallBack {
                            EndreshingCallBack()
                        }
                })
            case .pull:
                print("松开即可刷新")
            case .willRefresh:
                print("将要刷新")
            case .refreshing:
                DispatchQueue.main.async(execute: {
                    UIView.animate(withDuration: AnimationDuration, animations: {
                        let top = self._scrollViewOriginalInset.top + self.height
                        self._scrollView.contentInsetTop = top
                        self._scrollView.contentOffset = CGPoint.init(x: 0, y: -top)
                        }, completion: { (finished) in
                            // 刷新回调
                            DispatchQueue.main.async(execute: {
                                if let BeginRefreshingCallBack = self.BeginRefreshingCallBack {
                                    BeginRefreshingCallBack()
                                }
                                if let RefreshingCallBack = self.RefreshingCallBack {
                                    RefreshingCallBack()
                                }
                            })
                    })
                })
            case .noMoreData: break
            }
        }
    }
    /// init
    public init(_ refreshAction: @escaping CallBack) {
        super.init(frame: CGRect.zero)
        self.RefreshingCallBack = refreshAction
        
        self.addSubview(self.xp_headerStateLabel)
        
        self.autoresizingMask = .flexibleWidth
        self.backgroundColor = UIColor.clear
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
        scrollView.addObserver(self, forKeyPath: KeyPathContentOffset, options: [.new, .old], context: nil)
    }
    
    override func removeObservers() {
        super.removeObservers()
        guard let scrollView = self._scrollView else { return }
        scrollView.removeObserver(self, forKeyPath: KeyPathContentOffset)
    }
    
    override open func layoutSubviews() {
        // 基本属性
        super.layoutSubviews()
        self.xp_headerStateLabel.frame = self.bounds
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // 遇到这些情况，直接返回
        guard self.isUserInteractionEnabled && !self.isHidden else { return }
        scrollViewContentOffsetDidchange(change)
    }
    
    func scrollViewContentOffsetDidchange(_ change:[NSKeyValueChangeKey: Any]?) {
        if self._state == .refreshing {
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
        if _scrollView.isDragging {
            if self._state == .normal && offsetY < normalpullingOffsetY {
                self._state = .pull
            }else if self._state == .pull && offsetY > normalpullingOffsetY {
                self._state = .normal
            }
        }else if self._state == .pull {
            self._state = .refreshing
        }
    }
}


class XPHeaderStateLabel: UILabel {
    
    fileprivate let stateLabel = creatLabelWithTitle(HeaderNomalText)
    fileprivate let lastUpdatedLabel = creatLabelWithTitle(getLastUpdateTime())
    fileprivate let arrowView: UIImageView = {
        let imageView = UIImageView.init(image: xp_arrowImage())
        return imageView
    }()
    fileprivate let loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        return view
    }()
    
    fileprivate var statesTitles: [State: String] = {
        var result = [State: String]()
        result.updateValue(HeaderNomalText, forKey: .normal)
        result.updateValue(HeaderPullingText, forKey: .pull)
        result.updateValue(HeaderRefreshingText, forKey: .refreshing)
        return result
    }()
    
    fileprivate var state: State = .normal {
        didSet {
            guard oldValue != state else { return }
            self.stateLabel.text = self.statesTitles[state]
            setArrowViewWithState(oldValue)
            self.lastUpdatedLabel.text = getLastUpdateTime()
            setNeedsLayout()
        }
    }
    
    fileprivate func setArrowViewWithState(_ oldState: State) {
        switch state {
        case .normal:
            if oldState == .refreshing {
                arrowView.transform = CGAffineTransform.identity
                UIView.animate(withDuration: AnimationDuration, animations: {
                    self.loadingView.alpha = 0.0
                    }, completion: { (finished) in
                        if self.state != .normal { return }
                        self.loadingView.alpha = 1.0
                        self.loadingView.stopAnimating()
                        self.arrowView.isHidden = false
                })
            }else {
                self.loadingView.stopAnimating()
                self.arrowView.isHidden = false
                UIView.animate(withDuration: AnimationDuration, animations: {
                    self.arrowView.transform = CGAffineTransform.identity
                })
            }
        case .pull:
            self.loadingView.stopAnimating()
            self.arrowView.isHidden = false
            UIView.animate(withDuration: AnimationDuration, animations: {
                self.arrowView.transform = CGAffineTransform(rotationAngle: 0.000001 - CGFloat(M_PI))
            })
        case .refreshing:
            self.loadingView.alpha = 1
            self.loadingView.startAnimating()
            self.arrowView.isHidden = true
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
        if self.stateLabel.isHidden { return }
        
        var arrowCenterX = self.width * 0.5
        let offset: CGFloat = 20
        let stateWidth = self.stateLabel.textWidth
        var timeWidth: CGFloat = 0
        
        let noConstrainsOnStateLabel = stateLabel.constraints.count == 0
        if lastUpdatedLabel.isHidden {
            
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






