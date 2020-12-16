//
//  JLDataConvertUtil.h
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/10/17.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLDataConvertUtil : NSObject

/// 字符串转16进制
+ (NSData *)hexToBytes:(NSString *)str;

/// NSData转16进制字符串
+ (NSString *)hexStringWithData:(NSData *)data;

/// NSData转换uint8_t
+ (uint8_t)uint8FromBytes:(NSData *)fData;

/// 字节反转
+ (NSData *)dataWithReverse:(NSData *)srcData;

/// HEX转ASCII函数
int HexToAscii(unsigned char *pHexStr,unsigned char *pAscStr,int Len);

/// 将十进制转化为十六进制
+ (NSString *)intToHex:(long long int)tmpid;

@end

NS_ASSUME_NONNULL_END
