//
//  AppDelegate+Visible.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/11/15.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import "AppDelegate+Visible.h"

@implementation AppDelegate (Visible)

- (UIWindow *)mainWindow
{
    return self.window;
}

- (UIViewController *)visibleViewController
{
    UIViewController *rootViewController = [self.mainWindow rootViewController];
    return [self getVisibleViewControllerFrom:rootViewController];
}
 
- (UINavigationController *)visibleNavigationController
{
    return [[self visibleViewController] navigationController];
}

- (UIViewController *)getVisibleViewControllerFrom:(UIViewController *)vc
{
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [self getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

@end
