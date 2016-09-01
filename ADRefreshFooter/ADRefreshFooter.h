//
//  UIScrollView+ADRefreshFooter.h
//  ADRefreshFooter
//
//  Created by adoma on 16/8/31.
//  Copyright © 2016年 adoma. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ADRefreshStatus) {
    ADRefreshStatusNormal,
    ADRefreshStatusRefreshing,
};

@interface ADRefreshFooter : UIView

+ (instancetype)ad_footerWithRefreshBlock:(void (^)())refreshBlock;

@property (nonatomic,assign,readonly) BOOL isRefreshing;

@property (nonatomic,assign) BOOL noMoreData;

- (void)endRefresh;

@end

@interface UIScrollView (ADRefreshFooter)

@property (nonatomic,strong) ADRefreshFooter *ad_footer;

@end
