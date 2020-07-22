//
//  CYNTopGifView.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/11/14.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import "CYNTopGifView.h"
#import "CYNPrizeResultController.h"
#import "AppDelegate+Visible.h"

#define kImageSize  200

@interface CYNTopGifView ()

@property (nonatomic, strong) UIView *rootView;
@property (nonatomic, strong) UIView *maskView;//蒙层
@property (nonatomic, strong) UIImageView *gifImg;

@end

@implementation CYNTopGifView

- (instancetype)cyn_initWithFrame:(CGRect)frame rootView:(UIView *)rootView
{
    self.rootView = rootView;
    return [self initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.rootView addSubview:self];
        [self addSubview:self.maskView];
        [self.maskView addSubview:self.gifImg];
        
        self.maskView.frame = self.bounds;
        self.gifImg.frame = CGRectMake((kScreenWidth - kImageSize) / 2.0, -kImageSize, kImageSize, kImageSize);
    }
    return self;
}

- (void)gifImgTap
{
    CYNPrizeResultController *vc = [[CYNPrizeResultController alloc] init];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.hidden = YES;
    [[app visibleViewController] presentViewController:vc animated:YES completion:^{
        [self removeFromSuperview];
    }];
}

#pragma mark -
#pragma mark - Public

// 出场动画
- (void)startAnimation1
{
    [UIView animateWithDuration:3.0  delay:1.0 usingSpringWithDamping:0.7 initialSpringVelocity:5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.gifImg.frame = CGRectMake((kScreenWidth - kImageSize) / 2.0, (kScreenHeight - kImageSize) / 2.0, kImageSize, kImageSize);
    } completion:^(BOOL finished) {
        [self shakeView:self.gifImg];
    }];
}

/// 抖动动画
- (void)shakeView:(UIView*)viewToShake
{
    CGFloat t = 4.0;
    CGAffineTransform translateLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, 0);
    CGAffineTransform translateRight = CGAffineTransformTranslate(CGAffineTransformIdentity, t, 0);
    viewToShake.transform = translateLeft;
    
    [UIView animateWithDuration:0.001 delay:0.0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:500];
        viewToShake.transform = translateRight;
    } completion:^(BOOL finished){
        if(finished){
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                viewToShake.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.gifImg.image = [UIImage imageNamed:@"img_nianhui_sel"];
            }];
        }
    }];
}

#pragma mark -
#pragma mark - 懒加载

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    }
    return _maskView;
}

- (UIImageView *)gifImg
{
    if (!_gifImg) {
        _gifImg = [[UIImageView alloc] init];
        _gifImg.userInteractionEnabled = YES;
        _gifImg.image = [UIImage imageNamed:@"img_nianhui_nor"];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gifImgTap)];
        [_gifImg addGestureRecognizer:tap];
    }
    return _gifImg;
}

@end
