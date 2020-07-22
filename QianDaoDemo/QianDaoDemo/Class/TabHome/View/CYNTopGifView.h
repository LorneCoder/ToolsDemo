//
//  CYNTopGifView.h
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/11/14.
//  Copyright © 2019 gaojianlong. All rights reserved.
//  年会动画视图

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYNTopGifView : UIView

- (instancetype)cyn_initWithFrame:(CGRect)frame rootView:(UIView *)rootView;

/// 出现动画
- (void)startAnimation1;

@end

NS_ASSUME_NONNULL_END
