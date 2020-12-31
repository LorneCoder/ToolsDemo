//
//  BLEPrinterTool.h
//  QianDaoDemo
//
//  Created by 高建龙 on 2020/12/29.
//  Copyright © 2020 gaojianlong. All rights reserved.
//  

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLEPrinterTool : NSObject

#pragma mark - 配置蓝牙打印机秘钥

///配置秘钥
+ (NSArray<CBUUID *> *)configSecretKey:(NSString *)deviceSN;


#pragma mark - 客户端与蓝牙打印机交互

///1.1 获取打印机beacon，解析后返回设备序列号
+ (NSString *)cyn_decryptBeaconWithRandom1:(NSString *)random1 random2:(NSString *)random2 byteArray:(NSArray *)array;

///1.2 授权打印机，APP下发数据给设备
+ (NSArray<CBUUID *> *)cyn_sendDataToPrinterWithSN:(NSString *)deviceSN cardNumber:(NSArray *)cardArray;

///1.3 设备收到数据后应答，返回数据包，解析后返回状态码：0-失败，1-成功
+ (int)cyn_deviceReplyDecryptWithRandom1:(NSString *)random1 random2:(NSString *)random2 byteArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
