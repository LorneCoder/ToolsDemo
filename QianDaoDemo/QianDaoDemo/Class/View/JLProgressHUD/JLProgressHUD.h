//
//  JLProgressHUD.h
//  QianDaoDemo
//
//  Created by gaojianlong on 2018/12/27.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    JLProgressHUDTypeLoading,
    JLProgressHUDTypeSuccess,
    JLProgressHUDTypeError,
    JLProgressHUDTypeWarning,
    JLProgressHUDTypeText,
} JLProgressHUDType;

@interface JLProgressHUD : UIView

+ (void)show;

+ (void)showWithStatus:(NSString *)status;

@end

NS_ASSUME_NONNULL_END
