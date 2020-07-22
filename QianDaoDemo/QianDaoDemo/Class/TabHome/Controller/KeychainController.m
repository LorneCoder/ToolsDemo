//
//  KeychainController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/7/25.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import "KeychainController.h"
#import "JLKeychainTool.h"

@interface KeychainController ()

@property (nonatomic, strong) UIBarButtonItem *rightBarBtn;
@property (nonatomic, strong) UILabel *deviceIdLabel;

@end

@implementation KeychainController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"钥匙串存储";
    self.navigationItem.rightBarButtonItem = self.rightBarBtn;
    [self.view addSubview:self.deviceIdLabel];
    
    self.deviceIdLabel.text = [JLKeychainTool UDID];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.deviceIdLabel.frame = CGRectMake(10, 100, kScreenWidth - 20, 50);
}


- (void)getUDID
{
    NSString *UDID = [JLKeychainTool UDID];
    self.deviceIdLabel.text = UDID;
}


- (UIBarButtonItem *)rightBarBtn
{
    if (!_rightBarBtn) {
        _rightBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"获取" style:UIBarButtonItemStyleDone target:self action:@selector(getUDID)];
    }
    return _rightBarBtn;
}

- (UILabel *)deviceIdLabel
{
    if (!_deviceIdLabel) {
        _deviceIdLabel = [[UILabel alloc] init];
        _deviceIdLabel.text = @"设备ID";
        _deviceIdLabel.textColor = [UIColor blackColor];
        _deviceIdLabel.font = [UIFont systemFontOfSize:14];
        _deviceIdLabel.numberOfLines = 0;
        _deviceIdLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _deviceIdLabel;
}

@end
