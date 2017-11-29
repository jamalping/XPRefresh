//
//  ViewController.swift
//  XPRefresh
//
//  Created by jamalping on 16/6/17.
//  Copyright © 2016年 jamalping. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource {
    
    var tableView: UITableView!
    var numbers = 10
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView = UITableView.init(frame: self.view.bounds)
        tableView.rowHeight = 100
        self.view.addSubview(tableView)
        tableView.dataSource = self
//        tableView.xp_header = Header.init {
//            print("正在刷新")
//            self.perform(#selector(ViewController.test), with: nil, afterDelay: 2)
//        }
        
//        tableView.xp.setHeader(refreshing: {
//            print("d")
//            self.numbers = 10
//            self.perform(#selector(ViewController.test), with: nil, afterDelay: 2)
//        })
        
        tableView.xp.setHeader({
            print("刷新之前做什么")
        }, refreshing: {
            print("正在刷新")
            self.numbers = 10
            self.perform(#selector(ViewController.test), with: nil, afterDelay: 2)
        }) {
            print("刷新结束之后做什么")
        }
        
        tableView.xp.setFooter(refreshing: {
            self.tableView.xp_footer?.state = .noMoreData
//            print("上拉正在刷新")
//            self.numbers+=5
//            self.tableView.reloadData()
//            self.perform(#selector(ViewController.test), with: nil, afterDelay: 2)
        })
    }
    
    @objc func test() -> Void {
        
        
        tableView.xp_header?.endRefresh()
        tableView.xp_footer?.endRefresh()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return numbers
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ii = "dsdf"
        var cell = tableView.dequeueReusableCell(withIdentifier: ii)
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: ii)
        }
        cell?.textLabel?.text = "\(indexPath.row)"
        cell?.contentView.backgroundColor = .red
        return cell!
    }
}

