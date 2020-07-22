//
//  JLProgressHUD.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2018/12/27.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "JLProgressHUD.h"
#import "Masonry.h"

@interface JLProgressHUD ()

@property (nonatomic, strong) UIImageView *coverView;//蒙层
@property (nonatomic, strong) UIImageView *contentView;//loading底视图
@property (nonatomic, strong) UIImageView *loadingView;//loading动画图
@property (nonatomic, strong) UILabel *statusLabel;//提示信息文本

@end

@implementation JLProgressHUD

+ (instancetype)sharedView
{
    static JLProgressHUD *hud = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hud = [[JLProgressHUD alloc] init];
    });
    return hud;
}

- (void)createUI
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    self.frame = window.bounds;
    [window addSubview:self];
    
    [self addSubview:self.coverView];
    [self.coverView addSubview:self.contentView];
    [self.contentView addSubview:self.loadingView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.top.mas_equalTo(self.mas_top);
        make.size.mas_equalTo(self.frame.size);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.coverView.center);
        make.left.mas_greaterThanOrEqualTo(self.coverView.mas_left).offset(30);
        make.right.mas_greaterThanOrEqualTo(self.coverView.mas_right).offset(-30);
    }];
    
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.contentView.mas_top).offset(5);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}

- (void)setupStatusLabelUI
{
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loadingView.mas_bottom).offset(5);
        make.left.equalTo(self.contentView.mas_left).offset(5);
        make.right.equalTo(self.contentView.mas_right).offset(-5);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-5);
    }];
}

#pragma mark -
#pragma mark - Public Method

+ (void)show
{
    [[self sharedView] showWithStatus:nil type:JLProgressHUDTypeLoading];
}

+ (void)showWithStatus:(NSString *)status
{
    
}





- (void)showWithStatus:(NSString *)status type:(JLProgressHUDType)type
{
    //创建基础视图
    [self createUI];
    
    if (status) {
        [self.contentView addSubview:self.statusLabel];
        self.statusLabel.text = status;
        [self setupStatusLabelUI];
    }
    
    switch (type) {
        case JLProgressHUDTypeLoading:
        {
            

            break;
        }
        case JLProgressHUDTypeSuccess:
        {
            
            break;
        }
        case JLProgressHUDTypeError:
        {
            
            break;
        }
        case JLProgressHUDTypeWarning:
        {
            
            break;
        }
        case JLProgressHUDTypeText:
        {
            
            break;
        }
        default:
            break;
    }
    
}

#pragma mark -
#pragma mark - getter

- (UIImageView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIImageView alloc] init];
        _coverView.userInteractionEnabled = YES;
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    }
    return _coverView;
}

- (UIImageView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIImageView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (UIImageView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[UIImageView alloc] init];
        _loadingView.backgroundColor = [UIColor blueColor];
    }
    return _loadingView;
}

- (UILabel *)statusLabel
{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.numberOfLines = 0;
        _statusLabel.font = [UIFont systemFontOfSize:14];
        _statusLabel.textColor = [UIColor blackColor];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _statusLabel;
}

@end
