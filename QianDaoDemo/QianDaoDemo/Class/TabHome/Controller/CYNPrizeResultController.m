//
//  CYNPrizeResultController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/11/15.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import "CYNPrizeResultController.h"

@interface CYNPrizeResultController ()

@property (nonatomic, strong) UIImageView *bgView;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) BOOL isTouch;

@end

@implementation CYNPrizeResultController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
        
    [self.view addSubview:self.bgView];
    [self initSubviews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.bgView.frame = self.view.bounds;
}

- (void)initSubviews
{
    // 展示刮出来的效果的view
    UILabel *labelL        = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 280, 200)];
    labelL.text            = @"刮刮乐效果展示";
    labelL.numberOfLines   = 0;
    labelL.backgroundColor = [UIColor brownColor];
    labelL.font            = [UIFont systemFontOfSize:30];
    labelL.textAlignment   = NSTextAlignmentCenter;
    [self.bgView addSubview:labelL];
    
    // 被刮的图片
    self.imageView = [[UIImageView alloc] initWithFrame:labelL.frame];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.image = [UIImage imageNamed:@"mask"];
    [self.bgView addSubview:self.imageView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touchItem in touches) {
        if (touchItem.view == self.imageView) {
            self.isTouch = YES;
        } else {
            self.isTouch = NO;
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.isTouch) {
        NSLog(@"正在刮奖");
        
        // 触摸任意位置
        UITouch *touch = touches.anyObject;
        // 触摸位置在图片上的坐标
        CGPoint cententPoint = [touch locationInView:self.imageView];
        NSLog(@"x = %.f, y = %.f", cententPoint.x, cententPoint.y);
        
        // 设置清除点的大小
        CGRect rect = CGRectMake(cententPoint.x, cententPoint.y, 30, 30);
        // 默认是去创建一个透明的视图
        UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, NO, 0);
        // 获取上下文(画板)
        CGContextRef ref = UIGraphicsGetCurrentContext();
        // 把imageView的layer映射到上下文中
        [self.imageView.layer renderInContext:ref];
        // 清除划过的区域
        CGContextClearRect(ref, rect);
        // 获取图片
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        // 结束图片的画板, (意味着图片在上下文中消失)
        UIGraphicsEndImageContext();
        
        self.imageView.image = image;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.isTouch) {
        //计算刮开面积的百分比
        CGFloat progress = [self getAlphaPixelPercent:self.imageView.image];
        NSLog(@"刮奖面积百分比：%.2f", progress);
        if (progress >= 0.9) {
            [SVProgressHUD show];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self.imageView removeFromSuperview];
                self.isTouch = NO;
            });
        }
    }
}


//获取透明像素占总像素的百分比
- (CGFloat)getAlphaPixelPercent:(UIImage *)img
{
    //计算像素总个数
    NSInteger width = img.size.width;
    NSInteger height = img.size.height;
    NSInteger bitmapByteCount = width * height;
    unsigned char *pixelData = malloc(bitmapByteCount * 4);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(pixelData, width, height, 8, width, colorSpace, kCGImageAlphaOnly);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, img.CGImage);
    //计算透明像素个数
    NSInteger alphaPixelCount = 0;
    for (NSInteger y=0;y < height;y ++) {
        for (NSInteger x=0;x < width;x ++) {
            if (pixelData[y * width + x] == 0) {
                alphaPixelCount += 1;
            }
        }
    }
    
    free(pixelData);
    return ((CGFloat)alphaPixelCount) / ((CGFloat)bitmapByteCount);
}


- (UIImageView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIImageView alloc] init];
        _bgView.image = [UIImage imageNamed:@"prizebg"];
        _bgView.userInteractionEnabled = YES;
    }
    return _bgView;
}

@end
