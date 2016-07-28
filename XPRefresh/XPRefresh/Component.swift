//
//  Compon.swift
//  XPRefresh
//
//  Created by jamalping on 16/6/25.
//  Copyright © 2016年 jamalping. All rights reserved.
//

import UIKit

let HeaderHeight: CGFloat = 54.0
let FooterHeight: CGFloat = 44.0;
let AnimationDuration:NSTimeInterval = 0.35;

/** 观察者监听的属性 */
let KeyPathContentOffset = "contentOffset"
let KeyPathContentSize = "contentSize"

let HeaderNomalText = "下拉可以刷新"
let HeaderPullingText = "松开立即刷新"
let HeaderRefreshingText = "正在刷新数据中..."

let AutoFooterNomalText = "点击或上拉加载更多"
let AutoFooterRefreshingText = "正在加载更多的数据..."
let AutoFooterNoMoreDataText = "已经全部加载完毕"

let BackFooterNomalText = "上拉可以加载更多"
let BackFooterPullingText = "松开立即加载更多"
let BackFooterRefreshingText = "正在加载更多的数据..."
let BackFooterNoMoreDataText = "已经全部加载完毕"
let LastUpdatedTimeKey = "lastUpdatedTimeKey"

// 获取XPRefresh资源包
func xp_refreshBundle() -> NSBundle {
    return NSBundle.init(path: NSBundle.init(forClass: Component.self).pathForResource("XPRefresh", ofType: "bundle")!)!
}

// MARK 获取下拉刷新的图
func xp_arrowImage() -> UIImage {
    return UIImage.init(contentsOfFile: xp_refreshBundle().pathForResource("arrow@2x", ofType: "png")!)!
}


// MAKR 创建一个Label
public func creatLabelWithTitle(title: String) -> UILabel {
    let label = UILabel()
    label.font = UIFont.boldSystemFontOfSize(14)
    label.textColor = UIColor(red: 90/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1)
    label.text = title
    label.autoresizingMask = .FlexibleWidth
    label.textAlignment = .Center
    label.backgroundColor = UIColor.clearColor()
    return label
}

// MAKR 创建一个菊花
public func creatIndicatorViewWithStyle(style: UIActivityIndicatorViewStyle = .Gray) -> UIActivityIndicatorView {
    let indicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: style)
    indicatorView.hidesWhenStopped = true
    return indicatorView
}

// MAKR 获取上次刷新的时间
public func getLastUpdateTime() -> String {
    var result: String
    let lastUpdateTime: NSDate? = NSUserDefaults.standardUserDefaults().objectForKey(LastUpdatedTimeKey) as? NSDate
    if let lastTime = lastUpdateTime {
        let calendar = currentCalendar
        let unitFlags: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute, .Nanosecond]
        let cmp1 = calendar.components(unitFlags, fromDate: lastTime)
        let cmp2 = calendar.components(unitFlags, fromDate: NSDate())
        // 2.格式化日期
        let formatter = NSDateFormatter()
        var isToday = false
        if cmp1.day == cmp2.day {
            formatter.dateFormat = "HH:mm"
            isToday = true
        }else if cmp1.year == cmp2.year {
            formatter.dateFormat = "MM-dd HH:mm"
        }else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        let time = formatter.stringFromDate(lastTime)
        
        result = "最后刷新  " + (isToday ? "今天" + time : time)
    }else {
        result = "最后刷新: 无记录"
    }
    let userDefault = NSUserDefaults.standardUserDefaults()
    userDefault.setObject(NSDate(), forKey: LastUpdatedTimeKey)
    userDefault.synchronize()
    return result
}

// MAKR 获取当前日历
var currentCalendar: NSCalendar {
    get {
        let calender: NSCalendar? = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)
        if let c = calender {
            return c
        }
        return NSCalendar.currentCalendar()
    }
}

/// 刷新控件状态
public enum State {
    case Normal
    case Pull
    case WillRefresh
    case Refreshing
    case NoMoreData
    
}

public class Component: UIView {
    
    public typealias CallBack = () -> ()
    
    /** 记录scrollView刚开始的inset */
    var _scrollViewOriginalInset: UIEdgeInsets = UIEdgeInsetsZero
    /** 父控件 */
    weak var _scrollView: UIScrollView!
    
    var _state = State.Normal
    
    /// 刷新回调
    var BeginRefreshingCallBack: CallBack?
    
    var EndreshingCallBack: CallBack?
    
    var RefreshingCallBack: CallBack?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        // 如果不是scorllView，不做任何处理
        guard let scrollView = newSuperview as? UIScrollView else {
            return
        }
        
        removeObservers()
        _scrollView = scrollView
        self.frame = CGRect.init(x: _scrollView.left, y: -HeaderHeight, width: _scrollView.width, height: HeaderHeight)
        _scrollView.alwaysBounceVertical = true
        _scrollViewOriginalInset = _scrollView.contentInset
        addObservers()
    }
    
    /// MARK -- 观察者的添加和移除，交给子类实现
    func addObservers() { }
    func removeObservers() { }
}


extension Component {
    public func endRefresh() {
        self._state = .Normal
    }
}


