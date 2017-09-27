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
        tableView.backgroundColor = .red
        tableView.rowHeight = 100
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.xp_header = Header.init {
            print("正在刷新")
            self.perform(#selector(ViewController.test), with: nil, afterDelay: 2)
        }
        
        tableView.xp_footer = Footer.init{
            print("上拉正在刷新")
            self.numbers+=5
            self.perform(#selector(ViewController.test), with: nil, afterDelay: 2)
        }
    }
    
    @objc func test() -> Void {
        self.tableView.reloadData()
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
        return cell!
    }
}

