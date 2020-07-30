//
//  AnimationController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2020/7/22.
//  Copyright © 2020 gaojianlong. All rights reserved.
//

#import "AnimationController.h"
#import <Lottie/Lottie.h>

@interface AnimationController ()

@end

@implementation AnimationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"动效";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createAnimation];
}

- (void)createAnimation
{
    LOTAnimationView *animationView = [LOTAnimationView animationNamed:@"coffee"];
    animationView.frame = self.view.bounds;
    animationView.contentMode = UIViewContentModeScaleAspectFit;
    animationView.animationSpeed = 0.5;
    
    [animationView play];
    [self.view addSubview:animationView];
}


@end
