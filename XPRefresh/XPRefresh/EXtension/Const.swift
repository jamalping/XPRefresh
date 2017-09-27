//
//  Const.swift
//  XPRefreshExample
//
//  Created by xyj on 2017/9/25.
//  Copyright © 2017年 jamalping. All rights reserved.
//

import UIKit

let HeaderHeight: CGFloat = 54.0
let FooterHeight: CGFloat = 44.0;
let AnimationDuration:TimeInterval = 0.35;

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
func xp_refreshBundle() -> Bundle {
    return Bundle.init(path: Bundle.init(for: Component.self).path(forResource: "XPRefresh", ofType: "bundle")!)!
}

// MARK 获取下拉刷新的图
func xp_arrowImage() -> UIImage {
    return UIImage.init(contentsOfFile: xp_refreshBundle().path(forResource: "arrow@2x", ofType: "png")!)!
}


// MAKR 创建一个Label
public func creatLabelWithTitle(_ title: String) -> UILabel {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 14)
    label.textColor = UIColor(red: 90/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1)
    label.text = title
    label.autoresizingMask = .flexibleWidth
    label.textAlignment = .center
    label.backgroundColor = UIColor.clear
    return label
}

extension UILabel {
    convenience init(_ title: String?) {
        self.init()
        self.text = title
        self.font = UIFont.boldSystemFont(ofSize: 14)
        self.textColor = UIColor(red: 90/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1)
        self.autoresizingMask = .flexibleWidth
        self.textAlignment = .center
        self.backgroundColor = UIColor.clear
    }
}

/// 获取上次刷新的时间
///
/// - Returns: 时间字符串
public func getLastUpdateTime() -> String {
    var result: String
    let lastUpdateTime: Date? = UserDefaults.standard.object(forKey: LastUpdatedTimeKey) as? Date
    if let lastTime = lastUpdateTime {
        let calendar = currentCalendar
        let unitFlags: NSCalendar.Unit = [.year, .month, .day, .hour, .minute, .nanosecond]
        let cmp1 = (calendar as NSCalendar).components(unitFlags, from: lastTime)
        let cmp2 = (calendar as NSCalendar).components(unitFlags, from: Date())
        // 2.格式化日期
        let formatter = DateFormatter()
        var isToday = false
        if cmp1.day == cmp2.day {
            formatter.dateFormat = "HH:mm"
            isToday = true
        }else if cmp1.year == cmp2.year {
            formatter.dateFormat = "MM-dd HH:mm"
        }else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        let time = formatter.string(from: lastTime)
        
        result = "最后刷新  " + (isToday ? "今天" + time : time)
    }else {
        result = "最后刷新: 无记录"
    }
    let userDefault = UserDefaults.standard
    userDefault.set(Date(), forKey: LastUpdatedTimeKey)
    userDefault.synchronize()
    return result
}

// MAKR 获取当前日历
var currentCalendar: Calendar {
    get {
        let calender: Calendar? = Calendar.init(identifier: Calendar.Identifier.gregorian)
        if let c = calender {
            return c
        }
        return Calendar.current
    }
}
