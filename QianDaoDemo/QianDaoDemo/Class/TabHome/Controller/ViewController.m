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
#import "CacheWebviewController.h"
#import "FaceCheckController.h"
#import "BLEPrinterController.h"
#import "FontSetController.h"
#import "BLEClockInController.h"
#import "AnimationController.h"
#import "CYNTopView.h"
#import "AppDelegate.h"
#import "PayController.h"
#import "CYNPrizeResultController.h"
#import "JLAlertView.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIBarButtonItem *rightBarButton;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, strong) CYNTopView *topView;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.topView.hideSuspensionBtn = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.topView.hideSuspensionBtn = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if DEVELOP == 0
    self.dataArray = @[@"NFC", @"蓝牙", @"Loading DIY", @"添加桌面快捷方式", @"PhotoKit", @"蓝牙外设", @"钥匙串", @"远程H5加载本地资源", @"人脸检测", @"蓝牙打印机", @"字体设置", @"蓝牙门禁", @"动画效果", @"支付", @"刮奖"];
#elif DEVELOP == 1
    self.dataArray = @[@"NFC"];
#else
#endif
    
    [self initSubviews];
    [self testEncodeURIComponent];
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
    
//    [JLAlertView show2021ThemeAlertWithTitle:nil message:@"\n确认报名本池吗？\n\n" cancel:@"取消" ok:@"确认" completion:^{
//        NSLog(@"确认");
//    } cancelCallback:^{
//        NSLog(@"取消");
//    }];
    
    [JLAlertView show2021ThemeAlertWithTitle:nil message:@"\n确认使用后悔药吗？\n使用后可更改一次奖池\n" cancel:@"取消" ok:@"确认" completion:^{
        NSLog(@"确认");
    } cancelCallback:^{
        NSLog(@"取消");
    }];
    
    
    //SignInController *vc = [[SignInController alloc] init];
    //[self.navigationController pushViewController:vc animated:YES];
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
        case 7:
        {//远程H5加载本地资源
            CacheWebviewController * vc = [[CacheWebviewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 8:
        {//人脸检测
            FaceCheckController * vc = [[FaceCheckController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 9:
        {//蓝牙打印机
            BLEPrinterController * vc = [[BLEPrinterController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 10:
        {//字体设置
            FontSetController * vc = [[FontSetController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 11:
        {//蓝牙门禁
           BLEClockInController * vc = [[BLEClockInController alloc] init];
           [self.navigationController pushViewController:vc animated:YES];
           break;
        }
        case 12:
        {//动画效果
           AnimationController * vc = [[AnimationController alloc] init];
           [self.navigationController pushViewController:vc animated:YES];
           break;
        }
        case 13:
        {//支付
           PayController * vc = [[PayController alloc] init];
           [self.navigationController pushViewController:vc animated:YES];
           break;
        }
        case 14:
        {//刮奖
            CYNPrizeResultController * vc = [[CYNPrizeResultController alloc] init];
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

- (void)testEncodeURIComponent
{
    //NSString *targetStr = @"!*'();:@&=+$,/?%#[]";
    NSString *targetStr = @"http://10.1.8.141:8080____erp____mobile____getCompletingCount.do**xxemail=gaojianlong%40cyou-inc.com";
    
    NSString *str0 = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)targetStr, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    NSLog(@"旧方法str0：%@", str0);

    NSString *str1 = [targetStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"新方法str1：%@", str1);
    
    NSString *str2 = [targetStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLUserAllowedCharacterSet]];
    NSLog(@"新方法str2：%@", str2);

    NSString *str3 = [targetStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPasswordAllowedCharacterSet]];
    NSLog(@"新方法str3：%@", str3);

    NSString *str4 = [targetStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSLog(@"新方法str4：%@", str4);

    NSString *str5 = [targetStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSLog(@"新方法str5：%@", str5);

    NSString *str6 = [targetStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSLog(@"新方法str6：%@", str6);

    NSString *str7 = [targetStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@""]];
    NSLog(@"新方法str7：%@", str7);
    
    NSString *str8 = [targetStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"!"]];
    NSLog(@"新方法str8：%@", str8);
    
    NSString *str9 = [targetStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet symbolCharacterSet]];
    NSLog(@"新方法str9：%@", str9);

        
    // !*'();:@&=+$,/?%#%5B%5D
    // !*'();:@&=+$,/?%#[]
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

- (CYNTopView *)topView
{
    if (!_topView) {
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UIWindow *window = app.window;
        CGFloat centerY = window.center.y;
        _topView = [[CYNTopView alloc] cyn_initWithFrame:CGRectMake(kScreenWidth - 50, centerY - 25, 50, 50) toView:window];
    }
    return _topView;
}

@end
