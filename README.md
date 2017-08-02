# ADRefreshFooter
一个自动上拉加载更多的控件

![gif](http://i4.buimg.com/567571/db6fb292406c1599.gif)

### 使用方法:
```objc
self.tableView.ad_footer = [ADRefreshFooter ad_footerWithRefreshBlock:^{
        //Refresh 
    }];
    
//设置没有更多数据    
self.tableView.ad_footer.noMoreData = YES;

//结束刷新
[self.tableView.ad_footer endRefresh];
```

##### 喜欢可点击**Star**,谢谢
