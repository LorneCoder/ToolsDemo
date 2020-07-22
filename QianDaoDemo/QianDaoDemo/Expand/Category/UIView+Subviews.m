//
//  UIView+Subviews.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2020/6/23.
//  Copyright © 2020 gaojianlong. All rights reserved.
//

#import "UIView+Subviews.h"

@implementation UIView (Subviews)

- (UIView *)findSubview:(NSString *)name resursion:(BOOL)resursion
{
    Class class = NSClassFromString(name);
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:class]) {
            return subview;
        }
    }
    
    if (resursion) {
        for (UIView *subview in self.subviews) {
            UIView *tempView = [subview findSubview:name resursion:resursion];
            if (tempView) {
                return tempView;
            }
        }
    }
    return nil;
}

@end
