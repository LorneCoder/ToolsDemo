//
//  CYNTopView.h
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/11/14.
//  Copyright © 2019 gaojianlong. All rights reserved.
//  悬浮动画类

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYNTopView : UIView

- (instancetype)cyn_initWithFrame:(CGRect)frame toView:(UIView *)rootView;

@property (nonatomic, assign) BOOL hideSuspensionBtn;

//@property (nonatomic, copy) void(^callBack)(void);

@end

NS_ASSUME_NONNULL_END
