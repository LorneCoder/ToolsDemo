//
//  CYNRootViewController.m
//  ChangYouNei
//
//  Created by gaojianlong on 2018/10/24.
//  Copyright © 2018年 cyou. All rights reserved.
//

#import "CYNTabBarController.h"
#import "CYNNavigationController.h"
#import "ViewController.h"

#define kIOS7   [UIDevice currentDevice].systemVersion.doubleValue>=7.0 ? 1 :0

@interface CYNTabBarController ()

@end

@implementation CYNTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addAllChildViewControllers];
    [self configWithGoHome];
}


#pragma mark -
#pragma mark - 添加所有的子控制器
- (void)addAllChildViewControllers
{
    //设置角标
    //self.tabBar.badge
    
    ViewController *mainVC = [[ViewController alloc] init];
    [self addOneChlildVc:mainVC title:@"首页" imageName:@"tab_home_nor" selectedImageName:@"tab_home_sel"];

//    OfficeViewController *officeVC = [[OfficeViewController alloc]init];
//    [self addOneChlildVc:officeVC title:@"移动办公" imageName:@"tab_office_nor" selectedImageName:@"tab_office_sel"];
//
//    TopicsViewController *serviceVC = [[TopicsViewController alloc]init];
//    [self addOneChlildVc:serviceVC title:@"消息" imageName:@"tab_service_nor" selectedImageName:@"tab_service_sel"];
//
//    CYNMineController *mineVC = [[CYNMineController alloc] init];
//    [self addOneChlildVc:mineVC title:@"我的" imageName:@"tab_mine_nor" selectedImageName:@"tab_mine_sel"];
    
}

/**进入首页时的配置*/
- (void)configWithGoHome
{
    
}

#pragma mark -
#pragma mark - Private Method

/**
 *  添加一个子控制器
 *
 *  @param childVc           子控制器对象
 *  @param title             标题
 *  @param imageName         图标
 *  @param selectedImageName 选中的图标
 */
- (void)addOneChlildVc:(UIViewController *)childVc title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName
{
    // 设置标题
    childVc.tabBarItem.title = title;
    // 设置图标
    childVc.tabBarItem.image = [UIImage imageNamed:imageName];

    //设置标题下移
    //[childVc.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0,100)];
    //设置图标下移
    //childVc.tabBarItem.imageInsets = UIEdgeInsetsMake(8, 0, -8, 0);
    
    //tabbar图标大小需要重新设计，按照苹果规范来，否则badge显示会有问题
    //[childVc.tabBarItem setBadgeValue:@"5"];
    
    
    // 设置tabBarItem的未选中和选中状态下的文字颜色
    [childVc.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithHexString:@"#979696"] forKey:NSForegroundColorAttributeName] forState:UIControlStateNormal];
    [childVc.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithHexString:@"#38acff"] forKey:NSForegroundColorAttributeName] forState:UIControlStateSelected];
    
    // 设置选中的图标
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
    
    if (kIOS7) {
        // 声明这张图片用原图(别渲染)
        selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    childVc.tabBarItem.selectedImage = selectedImage;
    
    // 添加为tabbar控制器的子控制器
    CYNNavigationController *navC = [[CYNNavigationController alloc] initWithRootViewController:childVc];
    [self addChildViewController:navC];
}



@end
