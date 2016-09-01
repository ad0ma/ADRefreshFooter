//
//  UIScrollView+ADRefreshFooter.m
//  ADRefreshFooter
//
//  Created by adoma on 16/8/31.
//  Copyright © 2016年 adoma. All rights reserved.
//

#import "ADRefreshFooter.h"
#import <objc/runtime.h>

#define ADFreshHeight 35
#define AnimationDurationTime 0.3
#define ADMainScreenWidth [UIScreen mainScreen].bounds.size.width

@interface ADRefreshFooter ()

@property (nonatomic,weak) UIScrollView *parentScroll;

@property (nonatomic,copy) void((^ad_RefreshBlock)());

@property (nonatomic,assign) ADRefreshStatus status;

@property (nonatomic,assign) UIEdgeInsets lastScrollInsets;

@property (nonatomic,assign) BOOL isRefreshing;

@property (nonatomic,weak) UILabel *statusLabel;

@property (nonatomic,weak) UIActivityIndicatorView *indicator;

@end

@implementation ADRefreshFooter

- (instancetype)init
{
    if (self = [super init]) {
        
        self.status = ADRefreshStatusNormal;
        
        [self configSubview];
        
        [self configNoMoreData];
    }
    return self;
}

- (void)configSubview
{
    //end
    UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ADMainScreenWidth, ADFreshHeight)];
    endLabel.textAlignment = NSTextAlignmentCenter;
    endLabel.text = @"-- END --";
    endLabel.font = [UIFont fontWithName:@"Herculanum" size:13];
    endLabel.textColor = [UIColor darkGrayColor];
    [self addSubview:self.statusLabel = endLabel];
    
    CGFloat widthHeight = ADFreshHeight;
    CGFloat x = (ADMainScreenWidth - widthHeight) / 2;
    CGFloat y = (ADFreshHeight - widthHeight) / 2;
    
    //菊花
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(x, y, widthHeight, widthHeight)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self addSubview:self.indicator = indicator];
}

- (void)setNoMoreData:(BOOL)noMoreData
{
    _noMoreData = noMoreData;
    
    [self configNoMoreData];
}

- (void)setStatus:(ADRefreshStatus)status
{
    ADRefreshStatus oldStatu = self.status;
    if (status == oldStatu) return;
    _status = status;
    switch (status) {
        case ADRefreshStatusNormal:
        {
            
            self.isRefreshing = NO;
        }
            break;
            
        case ADRefreshStatusRefreshing:
        {
            
            self.isRefreshing = YES;
            
            !self.ad_RefreshBlock?:self.ad_RefreshBlock();
        }
            break;
    }
}

+ (UIView *)ad_footerWithRefreshBlock:(void (^)())refreshBlock
{
    ADRefreshFooter *cmd = [[self alloc] init];
    cmd.ad_RefreshBlock = refreshBlock;
    return cmd;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    // 遇到这些情况就直接返回
    if (!self.userInteractionEnabled) return;
    
    // 这个就算看不见也需要处理
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self scrollViewContentSizeDidChange:change];
    }
    
    // 看不见
    if (self.hidden) return;
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self scrollViewContentOffsetDidChange:change];
    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    
    if (self.parentScroll.contentOffset.y + self.parentScroll.frame.size.height >= self.parentScroll.contentSize.height) {
        if (self.status == ADRefreshStatusNormal) {
            [self beginRefreshing];
        }
    }
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change {
    // 设置位置
    CGRect newRect = self.frame;
    newRect.origin.y = self.parentScroll.contentSize.height;
    self.frame = newRect;
}

//开始刷新
- (void)beginRefreshing
{
    if (self.noMoreData) {
        return;
    }
    
    [self.indicator startAnimating];
    
    self.status = ADRefreshStatusRefreshing;
	//设置scroll contentInset
    self.lastScrollInsets = self.parentScroll.contentInset;
    
    UIEdgeInsets newInsets = self.parentScroll.contentInset;
    
    newInsets.bottom = ADFreshHeight;
    
    self.parentScroll.contentInset = newInsets;
}

//结束刷新
- (void)endRefresh
{
    self.status = ADRefreshStatusNormal;
    
    [self.indicator stopAnimating];
    
	[UIView animateWithDuration:AnimationDurationTime animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.parentScroll.contentInset = self.lastScrollInsets;
        self.alpha = 1;
        
        [self configNoMoreData];
    }];
}

- (void)configNoMoreData
{
    if (self.noMoreData) {
        self.indicator.hidden = YES;
        self.statusLabel.hidden = NO;
    } else {
        self.indicator.hidden = NO;
        self.statusLabel.hidden = YES;
    }
}

@end

@implementation UIScrollView (ADRefreshFooter)

- (ADRefreshFooter *)ad_footer
{
    return objc_getAssociatedObject(self, @selector(ad_footer));
}

- (void)setAd_footer:(ADRefreshFooter *)ad_footer
{
    ad_footer.parentScroll = self;
    
    UIEdgeInsets edgs = self.contentInset;
    edgs.bottom = ADFreshHeight;
    self.contentInset = edgs;
    
    //footer
    CGRect footerRect = CGRectMake(0, self.contentSize.height, self.frame.size.width, ADFreshHeight);
    
    ad_footer.frame = footerRect;
    
    [self insertSubview:ad_footer atIndex:0];
    
    [self addObserver:ad_footer forKeyPath:@"contentOffset" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
    
    [self addObserver:ad_footer forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
    
    objc_setAssociatedObject(self, @selector(ad_footer), ad_footer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
