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
    var numbers = 17
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView = UITableView.init(frame: self.view.bounds)
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.xp_header = Header.init {
            print("正在刷新")
            self.performSelector(#selector(ViewController.test), withObject: nil, afterDelay: 2)
        }
        
        tableView.xp_footer = Footer.init{
            print("上拉正在刷新")
            self.numbers+=5
            self.performSelector(#selector(ViewController.test), withObject: nil, afterDelay: 2)
        }
    }
    
    
    func test() -> Void {
        self.tableView.reloadData()
        tableView.xp_header?.endRefresh()
        tableView.xp_footer?.endRefresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return numbers
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let ii = "dsdf"
        var cell = tableView.dequeueReusableCellWithIdentifier(ii)
        if cell == nil {
            cell = UITableViewCell.init(style: .Default, reuseIdentifier: ii)
        }
        cell?.textLabel?.text = "\(indexPath.row)"
        return cell!
    }
}
