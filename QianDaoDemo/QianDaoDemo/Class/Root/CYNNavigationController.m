//
//  CYNNavigationController.m
//  ChangYouNei
//
//  Created by gaojianlong on 2018/10/24.
//  Copyright © 2018年 cyou. All rights reserved.
//

#import "CYNNavigationController.h"

@interface CYNNavigationController ()

@end

@implementation CYNNavigationController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self newVersionNavigationBarConfig];
}

#pragma mark -
#pragma mark - 设置导航栏

/**新版本导航栏配置*/
- (void)newVersionNavigationBarConfig
{
    [self.navigationBar setBackgroundImage:[self createImageWithColor:[UIColor colorWithHexString:@"#353439"]] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = NO;
    //设置导航栏
    self.navigationBar.barTintColor = [UIColor colorWithHexString:@"#353439"];
    self.navigationBar.tintColor = [UIColor whiteColor];//导航栏按钮颜色
    //设置标题字体
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                    NSFontAttributeName:[UIFont systemFontOfSize:17],
                                                                    }];
    
    [self.navigationBar setShadowImage:[UIImage new]];
}

/** 能拦截所有push进来的子控制器 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        // 如果现在push的不是栈底控制器(最先push进来的那个控制器)
        //设置返回按钮
        //UIBarButtonItem *itemleft = [self getNavigationItemBackBarButtonItem];
        //viewController.navigationItem.leftBarButtonItem = itemleft;

        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
    
    //解决iPhoneX push页面时tabbar上移问题
    //CGRect frame = self.tabBarController.tabBar.frame;
    //frame.origin.y = kScreenHeight - frame.size.height;
    //self.tabBarController.tabBar.frame = frame;
}


- (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
