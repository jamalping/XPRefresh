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
    
    /// 顶部的偏移量
    fileprivate var insetTop: CGFloat = 0
    
    /// 刷新显示的文字label
    fileprivate let xp_headerStateLabel = XPHeaderStateLabel()
    
    // 重写_state
    override var state: RefreshState {
        didSet {
            guard state != oldValue else {
                return
            }
            xp_headerStateLabel.state = state
            
            switch state {
            case .normal:
                if oldValue != .refreshing { return }
                // 恢复inset和offset
                UIView.animate(withDuration: AnimationDuration, animations: {
                    self._scrollView.contentInsetTop += self.insetTop
                    }, completion: { (finished) in
                        if let EndreshingCallBack = self.endreshingCallBack {
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
                        let top = self.scrollViewOriginalInset.top + self.height
                        self._scrollView.contentInsetTop = top
                        self._scrollView.contentOffset = CGPoint.init(x: 0, y: -top)
                        }, completion: { (finished) in
                            // 刷新回调
                            DispatchQueue.main.async(execute: {
                                if let beginRefreshingCallBack = self.beginRefreshingCallBack {
                                    beginRefreshingCallBack()
                                }
                                if let refreshingCallBack = self.refreshingCallBack {
                                    refreshingCallBack()
                                }
                            })
                    })
                })
            case .noMoreData: break
            }
        }
    }
    /// 初始化方法
    public init(_ refreshAction: @escaping callBack) {
        super.init(frame: CGRect.zero)
        self.refreshingCallBack = refreshAction
        
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
    
    
    /// 添加观察者
    override func addObservers() {
        super.addObservers()
        guard let scrollView = self._scrollView else { return }
        scrollView.addObserver(self, forKeyPath: KeyPathContentOffset, options: [.new, .old], context: nil)
    }
    
    /// 移除观察者
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
        if self.state == .refreshing {
            guard let _ = self.window else { return }
            // seactionHeader停留解决
            var insetTop = -self._scrollView.contentOffsetY > scrollViewOriginalInset.top ?  -self._scrollView.contentOffsetY : scrollViewOriginalInset.top
            insetTop = (insetTop > self.height + scrollViewOriginalInset.top) ? self.height + scrollViewOriginalInset.top : insetTop
            self._scrollView.contentInsetTop = insetTop;
            
            self.insetTop = scrollViewOriginalInset.top - insetTop;
            return
        }
        
        scrollViewOriginalInset = _scrollView.contentInset
        
        // 当前的contentOffset
        let offsetY = self._scrollView.contentOffsetY
        // 头部空间刚好出现的offset
        let happenOffsetTop = -scrollViewOriginalInset.top
        // 看不见头部控件，直接返回.
        if offsetY > happenOffsetTop { return }
        
        let normalpullingOffsetY = happenOffsetTop - self.height
        if _scrollView.isDragging {
            if self.state == .normal && offsetY < normalpullingOffsetY {
                self.state = .pull
            }else if self.state == .pull && offsetY > normalpullingOffsetY {
                self.state = .normal
            }
        }else if self.state == .pull {
            self.state = .refreshing
        }
    }
}


// MARK: --- 下拉刷新显示文字的label
class XPHeaderStateLabel: UILabel {
    
    /// 刷新文字
    fileprivate let stateLabel = UILabel.init(HeaderNomalText)

    /// 上次刷新的时间
    fileprivate let lastUpdatedLabel = UILabel.init(getLastUpdateTime())

    /// 下拉箭头
    fileprivate let arrowView: UIImageView = {
        let imageView = UIImageView.init(image: xp_arrowImage())
        return imageView
    }()
    
    /// 菊花
    fileprivate let loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        return view
    }()
    
    /// 获取不同状态的刷新文字
    fileprivate var statesTitles: [RefreshState: String] = {
        var result = [RefreshState: String]()
        result.updateValue(HeaderNomalText, forKey: .normal)
        result.updateValue(HeaderPullingText, forKey: .pull)
        result.updateValue(HeaderRefreshingText, forKey: .refreshing)
        return result
    }()
    
    /// 刷新状态
    fileprivate var state: RefreshState = .normal {
        didSet {
            guard oldValue != state else { return }
            self.stateLabel.text = self.statesTitles[state]
            setArrowViewWithState(oldValue)
            self.lastUpdatedLabel.text = getLastUpdateTime()
            setNeedsLayout()
        }
    }
    
    /// 根据刷新状态设置菊花状态
    ///
    /// - Parameter oldState: 之前的状态
    fileprivate func setArrowViewWithState(_ oldState: RefreshState) {
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
                self.arrowView.transform = CGAffineTransform(rotationAngle: 0.000001 - CGFloat(Double.pi))
                
            })
        case .refreshing:
            self.loadingView.alpha = 1
            self.loadingView.startAnimating()
            self.arrowView.isHidden = true
        default:
            break
        }
    }
    
    /// 初始化
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
    
    
    /// 布局
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






