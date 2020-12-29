//
//  DES3EncryptUtil.h
//  Encryption
//
//  Created by gaojianlong on 2018/10/22.
//  Copyright © 2018年 leichuanying. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DES3EncryptUtil : NSObject

/**加密方法*/
+ (NSString*)encrypt:(NSString*)plainText;

/**解密方法*/
+ (NSString*)decrypt:(NSString*)encryptText;

/**C语言3DES加解密*/
void TestDES(void);

@end
