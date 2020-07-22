//
//  CYNTopView.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/11/14.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import "CYNTopView.h"
#import "CYNTopGifView.h"

@interface CYNTopView ()

@property (nonatomic, strong) UIView *rootView;
@property (nonatomic, strong) UIButton *suspensionBtn;//悬浮按钮
@property (nonatomic, strong) CYNTopGifView *gifView;//动画视图

@end

@implementation CYNTopView

- (instancetype)cyn_initWithFrame:(CGRect)frame toView:(UIView *)rootView
{
    self.rootView = rootView;
    return [self initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.suspensionBtn.frame = self.frame;
        [self.rootView addSubview:self.suspensionBtn];
    }
    return self;
}

//点击悬浮按钮
- (void)topViewClicked
{
    [self.gifView startAnimation1];
}

- (void)setHideSuspensionBtn:(BOOL)hideSuspensionBtn
{
    _hideSuspensionBtn = hideSuspensionBtn;
    self.suspensionBtn.hidden = _hideSuspensionBtn;
}

#pragma mark -
#pragma mark - Private Method

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self){
        return nil;
    }
    return hitView;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    //移动状态
    UIGestureRecognizerState recState = recognizer.state;
    
    switch (recState) {
        case UIGestureRecognizerStateBegan:
            
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [recognizer translationInView:self.rootView];
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint stopPoint = CGPointMake(0, kScreenHeight / 2.0);
            
            if (recognizer.view.center.x < kScreenWidth / 2.0) {
                //左边
                stopPoint = CGPointMake(CGRectGetWidth(self.suspensionBtn.frame) / 2.0, recognizer.view.center.y);
                
                /*
                if (recognizer.view.center.y <= kScreenHeight / 2.0) {
                    //左上
                    if (recognizer.view.center.x >= recognizer.view.center.y) {
                        stopPoint = CGPointMake(recognizer.view.center.x, CGRectGetWidth(self.suspensionBtn.frame) / 2.0);
                    } else {
                        stopPoint = CGPointMake(CGRectGetWidth(self.suspensionBtn.frame) / 2.0, recognizer.view.center.y);
                    }
                } else {
                    //左下
                    if (recognizer.view.center.x  >= kScreenHeight - recognizer.view.center.y) {
                        stopPoint = CGPointMake(recognizer.view.center.x, kScreenHeight - CGRectGetWidth(self.suspensionBtn.frame) / 2.0);
                    } else {
                        stopPoint = CGPointMake(CGRectGetWidth(self.suspensionBtn.frame) / 2.0, recognizer.view.center.y);
                        //stopPoint = CGPointMake(recognizer.view.center.x, SCREEN_HEIGHT - self.spButton.width/2.0);
                    }
                }
                 */
            } else {
                //右边
                stopPoint = CGPointMake(kScreenWidth - CGRectGetWidth(self.suspensionBtn.frame) / 2.0, recognizer.view.center.y);

                /*
                if (recognizer.view.center.y <= kScreenHeight / 2.0) {
                    //右上
                    if (kScreenWidth - recognizer.view.center.x  >= recognizer.view.center.y) {
                        stopPoint = CGPointMake(recognizer.view.center.x, CGRectGetWidth(self.suspensionBtn.frame) / 2.0);
                    } else {
                        stopPoint = CGPointMake(kScreenWidth - CGRectGetWidth(self.suspensionBtn.frame) / 2.0, recognizer.view.center.y);
                    }
                } else {
                    //右下
                    if (kScreenWidth - recognizer.view.center.x  >= kScreenHeight - recognizer.view.center.y) {
                        stopPoint = CGPointMake(recognizer.view.center.x, kScreenHeight - CGRectGetWidth(self.suspensionBtn.frame) / 2.0);
                    } else {
                        stopPoint = CGPointMake(kScreenWidth - CGRectGetWidth(self.suspensionBtn.frame) / 2.0,recognizer.view.center.y);
                    }
                }
                 */
            }
            
            //如果按钮超出屏幕边缘
            if (stopPoint.y + CGRectGetWidth(self.suspensionBtn.frame) + 40 >= kScreenHeight) {
                stopPoint = CGPointMake(stopPoint.x, kScreenHeight - CGRectGetWidth(self.suspensionBtn.frame) / 2.0 - kTabBarHeight);
                NSLog(@"超出屏幕下方了！！"); //这里注意iphoneX的适配。。X的SCREEN高度算法有变化。
            }
            if (stopPoint.x - CGRectGetWidth(self.suspensionBtn.frame) / 2.0 <= 0) {
                stopPoint = CGPointMake(CGRectGetWidth(self.suspensionBtn.frame) / 2.0, stopPoint.y);
            }
            if (stopPoint.x + CGRectGetWidth(self.suspensionBtn.frame) / 2.0 >= kScreenWidth) {
                stopPoint = CGPointMake(kScreenWidth - CGRectGetWidth(self.suspensionBtn.frame) / 2.0, stopPoint.y);
            }
            if (stopPoint.y - CGRectGetWidth(self.suspensionBtn.frame) / 2.0 <= 0) {
                CGFloat statusBarH = [[UIApplication sharedApplication] statusBarFrame].size.height;
                stopPoint = CGPointMake(stopPoint.x, statusBarH + CGRectGetWidth(self.suspensionBtn.frame) / 2.0);
            }
  
            [UIView animateWithDuration:0.5 animations:^{
                recognizer.view.center = stopPoint;
            }];
        }
            break;
            
        default:
            break;
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.rootView];
}

#pragma mark -
#pragma mark - 懒加载

- (UIButton *)suspensionBtn
{
    if (!_suspensionBtn) {
        _suspensionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _suspensionBtn.backgroundColor = [UIColor orangeColor];
        [_suspensionBtn addTarget:self action:@selector(topViewClicked) forControlEvents:UIControlEventTouchUpInside];
        
        //添加手势
        UIPanGestureRecognizer *panRcognize = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [panRcognize setMinimumNumberOfTouches:1];
        [panRcognize setEnabled:YES];
        [panRcognize delaysTouchesEnded];
        [panRcognize cancelsTouchesInView];
        [_suspensionBtn addGestureRecognizer:panRcognize];
    }
    return _suspensionBtn;
}

- (CYNTopGifView *)gifView
{
    if (!_gifView) {
        _gifView = [[CYNTopGifView alloc] cyn_initWithFrame:self.rootView.frame rootView:self.rootView];
    }
    return _gifView;
}

@end
