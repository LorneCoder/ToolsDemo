//
//  JLDateUtil.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2018/10/10.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "JLDateUtil.h"

@implementation JLDateUtil

/**获取当前日期*/
+ (NSString *)getCurrentTimes
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //[formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    [formatter setDateFormat:@"YYYY年MM月dd日"];

    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    //NSLog(@"currentTimeString =  %@",currentTimeString);
    
    return currentTimeString;
}

/**获取当前时分*/
+ (NSString *)getCurrentHourMinutes
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];

    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    return currentTimeString;
}

@end
