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

@end

@implementation CYNPrizeResultController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
        
    [self.view addSubview:self.bgView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.bgView.frame = self.view.bounds;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImageView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIImageView alloc] init];
        _bgView.image = [UIImage imageNamed:@"prizebg"];
    }
    return _bgView;
}

@end
