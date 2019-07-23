//
//  BTConnectController.h
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/2/26.
//  Copyright © 2019年 gaojianlong. All rights reserved.
//  蓝牙连接成功后的页面

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void(^SelectCallBack)(CBCharacteristic *item);

NS_ASSUME_NONNULL_BEGIN

@interface BTConnectController : UIViewController

@property (nonatomic, copy) NSArray<CBCharacteristic *> *myCharacteristics;

@property (nonatomic, copy) SelectCallBack selectBlock;

@end

NS_ASSUME_NONNULL_END
