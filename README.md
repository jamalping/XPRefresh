#XPRefresh
Swift 版下拉刷新控件

#Use:
####before:
```
tableView.xp_header = Header.init {
	print("正在刷新")
}

tableView.xp_footer = Footer.init{
	print("上拉正在刷新")
	self.numbers+=5
}
```
#### now:
```
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
            print("上拉正在刷新")
            self.numbers+=5
            self.tableView.reloadData()
            self.perform(#selector(ViewController.test), with: nil, afterDelay: 2)
        })
        // 辅助方法，结束刷新
        @objc func test() -> Void {
        self.tableView.reloadData()
        tableView.xp_header?.endRefresh()
        tableView.xp_footer?.endRefresh()
    }
```
![image](http://note.youdao.com/yws/public/resource/d054d387c6ae15767df4bd996eddeedf/xmlnote/WEBRESOURCEa1d9f2e48115947d11b4f82b714be810/505)

#PS:
暂时只提供了简单的刷新，后续会增加其他样式