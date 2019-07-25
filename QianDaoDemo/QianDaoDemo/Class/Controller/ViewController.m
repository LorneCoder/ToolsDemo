//
//  ViewController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2018/10/9.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "ViewController.h"
#import "SignInController.h"
#import "NFCController.h"
#import "BluetoothController.h"
#import "LoadingController.h"
#import "PhotoKitController.h"
#import "BLEPeripheralsController.h"
#import "KeychainController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIBarButtonItem *rightBarButton;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, copy) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataArray = @[@"NFC", @"蓝牙", @"Loading DIY", @"添加桌面快捷方式", @"PhotoKit", @"蓝牙外设", @"钥匙串"];
    [self initSubviews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.table.frame = self.view.bounds;
}

- (void)initSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"首页";
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    
    [self.view addSubview:self.table];
}

#pragma mark -
#pragma mark - tableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self showNextViewControllerWithIndexPath:indexPath];
}

#pragma mark -
#pragma mark - action

- (void)goSignInViewController
{
    SignInController *vc = [[SignInController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showNextViewControllerWithIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {//NFC
            NFCController *vc = [[NFCController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
            
        case 1:
        {//蓝牙
            BluetoothController *vc = [[BluetoothController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 2:
        {//loading
            LoadingController *vc = [[LoadingController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 3:
        {//快捷方式
            [self addTest];
            break;
        }
        case 4:
        {//PhotoKit
            PhotoKitController * vc = [[PhotoKitController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 5:
        {//蓝牙外设
            BLEPeripheralsController * vc = [[BLEPeripheralsController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 6:
        {//钥匙串
            KeychainController * vc = [[KeychainController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }

        default:
            break;
    }
}

- (void)addTest
{
    NSArray *arr = @[@"1", @"2", @"3", @"4"];
    
    NSString *str = [arr componentsJoinedByString:@","];
    
    
    
    NSLog(@"str = %@", str);
    
    
    
//    NSString *openURL = @"http://www.baidu.com/";
//    NSURL *URL = [NSURL URLWithString:openURL];
//
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
//        if (@available(iOS 10.0, *)) {
//            [[UIApplication sharedApplication]openURL:URL options:@{} completionHandler:^(BOOL success) {
//
//            }];
//        } else {
//            // Fallback on earlier versions
//        }
//    } else {
//        [[UIApplication sharedApplication] openURL:URL];
//    }
}


#pragma mark -
#pragma mark - 懒加载

- (UIBarButtonItem *)rightBarButton
{
    if (!_rightBarButton) {
        _rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"签到" style:UIBarButtonItemStyleDone target:self action:@selector(goSignInViewController)];
    }
    return _rightBarButton;
}

- (UITableView *)table
{
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _table.delegate = self;
        _table.dataSource = self;
        
        UIView *footer = [[UIView alloc] init];
        footer.backgroundColor = [UIColor whiteColor];
        _table.tableFooterView = footer;
    }
    return _table;
}

@end
