//
//  AppDelegate+Visible.h
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/11/15.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (Visible)

- (UIWindow *)mainWindow;

- (UIViewController *)visibleViewController;

- (UINavigationController *)visibleNavigationController;

@end

NS_ASSUME_NONNULL_END
