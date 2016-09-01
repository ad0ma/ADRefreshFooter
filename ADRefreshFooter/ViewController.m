//
//  ViewController.m
//  ADRefreshFooter
//
//  Created by adoma on 16/8/31.
//  Copyright © 2016年 adoma. All rights reserved.
//

#import "ViewController.h"
#import "ADRefreshFooter.h"

@interface ViewController ()
{
    NSInteger offset;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    offset = 1;
    
    self.tableView.ad_footer = [ADRefreshFooter ad_footerWithRefreshBlock:^{
        NSLog(@"开始刷新");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            NSLog(@"结束刷新");
            offset ++;
            
            if (offset == 3) {
                self.tableView.ad_footer.noMoreData = YES;
            }
            
            [self.tableView reloadData];
            
            [self.tableView.ad_footer endRefresh];
        });
    
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ideifer = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ideifer];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:ideifer];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"adoma%@",indexPath];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return offset * 20;
}


@end
