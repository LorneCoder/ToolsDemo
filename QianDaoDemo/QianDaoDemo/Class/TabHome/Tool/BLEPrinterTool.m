//
//  BLEPrinterTool.m
//  QianDaoDemo
//
//  Created by 高建龙 on 2020/12/29.
//  Copyright © 2020 gaojianlong. All rights reserved.
//

#import "BLEPrinterTool.h"

@implementation BLEPrinterTool

#pragma mark -
#pragma mark - Public

#pragma mark - 配置蓝牙打印机秘钥

///配置秘钥
+ (NSArray<CBUUID *> *)configSecretKey:(NSString *)deviceSN
{
    //加密随机数
    int ran1 = rand()%255;
    int ran2 = rand()%255;
    NSLog(@"ran1 : %d, ran2 : %d", ran1, ran2);
    NSString *ranStr1 = [JLDataConvertUtil intToHex:ran1];
    NSString *ranStr2 = [JLDataConvertUtil intToHex:ran2];
    NSLog(@"ranStr1 : %@, ranStr2 : %@", ranStr1, ranStr2);
    NSString *byte2 = [ranStr2 stringByAppendingString:ranStr1];
    NSLog(@"随机数UUID：%@", byte2);
    
    NSString *sn1 = [self reverseString:[deviceSN substringWithRange:NSMakeRange(0, 4)]];
    NSString *sn2 = [self reverseString:[deviceSN substringWithRange:NSMakeRange(4, 4)]];
    NSString *sn3 = [self reverseString:[deviceSN substringWithRange:NSMakeRange(8, 4)]];
    
    //16字节的秘钥，自定义
    //{0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06}，

    //加密随机数后边的数据
    NSArray *array = @[[CBUUID UUIDWithString:sn1],
                       [CBUUID UUIDWithString:sn2],
                       [CBUUID UUIDWithString:sn3],
                       [CBUUID UUIDWithString:@"0201"],
                       [CBUUID UUIDWithString:@"0403"],
                       [CBUUID UUIDWithString:@"0605"],
                       [CBUUID UUIDWithString:@"0807"],
                       [CBUUID UUIDWithString:@"0A09"],
                       [CBUUID UUIDWithString:@"0201"],
                       [CBUUID UUIDWithString:@"0403"],
                       [CBUUID UUIDWithString:@"0605"]];
    NSLog(@"加密前的数据：%@", array);

    //加密
    NSString *str = [self cyn_setSecretKeyEncryptWithRandom1:ranStr1 random2:ranStr2 byteArray:array];
    NSLog(@"加密后的数据：%@", str);
    
    NSString *uuid1 = [str substringWithRange:NSMakeRange(0, 4)];
    NSString *uuid2 = [str substringWithRange:NSMakeRange(4, 4)];
    NSString *uuid3 = [str substringWithRange:NSMakeRange(8, 4)];
    
    NSString *uuid4 = [str substringWithRange:NSMakeRange(12, 4)];
    NSString *uuid5 = [str substringWithRange:NSMakeRange(16, 4)];
    NSString *uuid6 = [str substringWithRange:NSMakeRange(20, 4)];
    NSString *uuid7 = [str substringWithRange:NSMakeRange(24, 4)];
    NSString *uuid8 = [str substringWithRange:NSMakeRange(28, 4)];
    NSString *uuid9 = [str substringWithRange:NSMakeRange(32, 4)];
    NSString *uuid10 = [str substringWithRange:NSMakeRange(36, 4)];
    NSString *uuid11 = [str substringWithRange:NSMakeRange(40, 4)];
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:@[uuid1, uuid2, uuid3, uuid4, uuid5, uuid6, uuid7, uuid8, uuid9, uuid10, uuid11]];
    NSMutableArray *resultArr = [NSMutableArray array];
    [resultArr addObject:[CBUUID UUIDWithString:@"615A"]];
    [resultArr addObject:[CBUUID UUIDWithString:byte2]];
    
    for (int i = 0; i < tempArr.count; i ++) {
        NSString *tempStr = tempArr[i];
        NSString *temp1 = [tempStr substringWithRange:NSMakeRange(2, 2)];
        NSString *temp2 = [tempStr substringWithRange:NSMakeRange(0, 2)];
        NSString *result = [temp1 stringByAppendingString:temp2];
        [resultArr addObject:[CBUUID UUIDWithString:result]];
    }
    
    NSLog(@"发送给打印机的最终数据：%@", resultArr);
    return resultArr;
}

#pragma mark - 客户端与蓝牙打印机交互

///1.1 获取打印机beacon，解析后返回设备序列号
+ (NSString *)cyn_decryptBeaconWithRandom1:(NSString *)random1 random2:(NSString *)random2 byteArray:(NSArray *)array
{
    //16位秘钥
    uint8_t device_beacon_encodeKey[16] = {0xF3, 0x78, 0x6D, 0x3F, 0xA7, 0x56, 0x9B, 0x37, 0x6C, 0x3D, 0x91, 0x8E, 0xE5, 0x98, 0xD3, 0xBC};
    uint8_t temp_key[16] = {0};
    
    //字符串转换成16进制
    NSData *data1 = [JLDataConvertUtil hexToBytes:random1];
    NSData *data2 = [JLDataConvertUtil hexToBytes:random2];
    
    //16进制转换成uint8_t
    uint8_t ran1 = [JLDataConvertUtil uint8FromBytes:data1];
    uint8_t ran2 = [JLDataConvertUtil uint8FromBytes:data2];
    
    //NSLog(@"ran1 : %c --- ran2 : %c" , ran1, ran2);
    
    for (uint8_t j = 0; j < 16; j++)
    {
        temp_key[j] = device_beacon_encodeKey[j];
        temp_key[j] = temp_key[j] ^ ran1;
        temp_key[j] = temp_key[j] ^ ran2;
    }

    //此时的 temp_key[16] 就是二次新秘钥
    //用二次新秘钥对广播包后22字节进行解密
    
    uint8_t p_data[31] = {0};
    uint8_t plen = 0;
    //memset(p_data, 0, 31);
    
    //beacon头，5字节，固定内容
    p_data[plen++] = 0x02;
    p_data[plen++] = 0x01;
    p_data[plen++] = 0x06;
    p_data[plen++] = 0x1B;
    p_data[plen++] = 0x03;
    
    p_data[plen++] = 0x5A;//包头
    p_data[plen++] = 0x60;//功能码
    p_data[plen++] = ran1;//随机数1
    p_data[plen++] = ran2;//随机数2
    
    //NSLog(@"需要解密的22字节：%@", array);
    
    for (int i = 0; i < array.count; i ++) {
        NSString *tempStr = [array[i] UUIDString];
        NSString *temp1 = [tempStr substringWithRange:NSMakeRange(2, 2)];
        NSString *temp2 = [tempStr substringWithRange:NSMakeRange(0, 2)];

        NSData *d1 = [JLDataConvertUtil hexToBytes:temp1];
        NSData *d2 = [JLDataConvertUtil hexToBytes:temp2];
            
        uint8_t byte1 = [JLDataConvertUtil uint8FromBytes:d1];
        uint8_t byte2 = [JLDataConvertUtil uint8FromBytes:d2];
        
        p_data[plen++] = byte1;
        p_data[plen++] = byte2;
    }
    
    //加解密函数
    cyn_beacon_encodeMassage(temp_key, &p_data[9], 22);

    uint8_t temp_data[6] = {0};
    uint8_t ascii_data[6] = {0};//ASCII码值格式的容器

    for (int i = 0; i < 6; i ++) {
        temp_data[i] = p_data[i + 9]; //p_datap[31] 第9~14位字节对应设备序列号，取出备用
    }
    
    //NSLog(@"temp_data:%s", temp_data);
    
    //16进制转换ASCII码值
    HexToAscii(temp_data, ascii_data, 6);
    // ascii_data的值就是设备序列号
    NSString *SN = [NSString stringWithFormat:@"%s", ascii_data];
    return SN;
}

///1.2 授权打印机，APP下发数据给设备
+ (NSArray<CBUUID *> *)cyn_sendDataToPrinterWithSN:(NSString *)deviceSN
{
    //加密随机数
    int ran1 = rand()%255;
    int ran2 = rand()%255;
    NSLog(@"ran1 : %d, ran2 : %d", ran1, ran2);
    NSString *ranStr1 = [JLDataConvertUtil intToHex:ran1];
    NSString *ranStr2 = [JLDataConvertUtil intToHex:ran2];
    NSLog(@"ranStr1 : %@, ranStr2 : %@", ranStr1, ranStr2);
    NSString *byte2 = [ranStr2 stringByAppendingString:ranStr1];
    NSLog(@"随机数UUID：%@", byte2);
    
    // 2019 0722 0031
    NSString *sn1 = [self reverseString:[deviceSN substringWithRange:NSMakeRange(0, 4)]];
    NSString *sn2 = [self reverseString:[deviceSN substringWithRange:NSMakeRange(4, 4)]];
    NSString *sn3 = [self reverseString:[deviceSN substringWithRange:NSMakeRange(8, 4)]];
    
    // 员工卡号密文
    // 5B 22 D2 61 2D B4 4A A6 8B 85 91 73 36 E6 5D 40
    //加密随机数后边的数据
    NSArray *array = @[[CBUUID UUIDWithString:sn1],
                       [CBUUID UUIDWithString:sn2],
                       [CBUUID UUIDWithString:sn3],
                       [CBUUID UUIDWithString:@"225B"],
                       [CBUUID UUIDWithString:@"61D2"],
                       [CBUUID UUIDWithString:@"B42D"],
                       [CBUUID UUIDWithString:@"A64A"],
                       [CBUUID UUIDWithString:@"858B"],
                       [CBUUID UUIDWithString:@"7391"],
                       [CBUUID UUIDWithString:@"E636"],
                       [CBUUID UUIDWithString:@"405D"]];
    
    NSLog(@"加密前的数据：%@", array);
    //加密
    
    NSString *str = [self cyn_sendDataToPrinterWithRandom1:ranStr1 random2:ranStr2 byteArray:array];
    NSLog(@"加密后的数据：%@", str);
    
    NSString *uuid1 = [str substringWithRange:NSMakeRange(0, 4)];
    NSString *uuid2 = [str substringWithRange:NSMakeRange(4, 4)];
    NSString *uuid3 = [str substringWithRange:NSMakeRange(8, 4)];
    
    NSString *uuid4 = [str substringWithRange:NSMakeRange(12, 4)];
    NSString *uuid5 = [str substringWithRange:NSMakeRange(16, 4)];
    NSString *uuid6 = [str substringWithRange:NSMakeRange(20, 4)];
    NSString *uuid7 = [str substringWithRange:NSMakeRange(24, 4)];
    NSString *uuid8 = [str substringWithRange:NSMakeRange(28, 4)];
    NSString *uuid9 = [str substringWithRange:NSMakeRange(32, 4)];
    NSString *uuid10 = [str substringWithRange:NSMakeRange(36, 4)];
    NSString *uuid11 = [str substringWithRange:NSMakeRange(40, 4)];
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:@[uuid1, uuid2, uuid3, uuid4, uuid5, uuid6, uuid7, uuid8, uuid9, uuid10, uuid11]];
    NSMutableArray *resultArr = [NSMutableArray array];
    [resultArr addObject:[CBUUID UUIDWithString:@"625A"]];
    [resultArr addObject:[CBUUID UUIDWithString:byte2]];
    
    for (int i = 0; i < tempArr.count; i ++) {
        NSString *tempStr = tempArr[i];
        NSString *temp1 = [tempStr substringWithRange:NSMakeRange(2, 2)];
        NSString *temp2 = [tempStr substringWithRange:NSMakeRange(0, 2)];
        NSString *result = [temp1 stringByAppendingString:temp2];
        [resultArr addObject:[CBUUID UUIDWithString:result]];
    }

    return resultArr;
}

///1.3 设备收到数据后应答，返回数据包，解析后返回状态码：0-失败，1-成功
+ (int)cyn_deviceReplyDecryptWithRandom1:(NSString *)random1 random2:(NSString *)random2 byteArray:(NSArray *)array
{
    //16位秘钥
    uint8_t device_beacon_encodeKey[16] = {0xF3, 0x78, 0x6D, 0x3F, 0xA7, 0x56, 0x9B, 0x37, 0x6C, 0x3D, 0x91, 0x8E, 0xE5, 0x98, 0xD3, 0xBC};
    uint8_t temp_key[16] = {0};
    
    //字符串转换成16进制
    NSData *data1 = [JLDataConvertUtil hexToBytes:random1];
    NSData *data2 = [JLDataConvertUtil hexToBytes:random2];
    
    //16进制转换成uint8_t
    uint8_t ran1 = [JLDataConvertUtil uint8FromBytes:data1];
    uint8_t ran2 = [JLDataConvertUtil uint8FromBytes:data2];
        
    for (uint8_t j=0; j<16; j++)
    {
        temp_key[j] = device_beacon_encodeKey[j];
        temp_key[j] = temp_key[j] ^ ran1;
        temp_key[j] = temp_key[j] ^ ran2;
    }
    
    //此时的 temp_key[16] 就是二次新秘钥
    //用二次新秘钥对数组中的8个字节进行解密，前6个字节代表设备序列号，倒数第二个字节是状态码

    uint8_t p_data[31] = {0};
    uint8_t plen = 0;
    
    //beacon头，5字节，固定内容
    p_data[plen++] = 0x02;
    p_data[plen++] = 0x01;
    p_data[plen++] = 0x04;
    p_data[plen++] = 0x1B;
    p_data[plen++] = 0xFF;
    
    p_data[plen++] = 0x5A;//包头
    p_data[plen++] = 0x64;//功能码
    p_data[plen++] = ran1;//随机数1
    p_data[plen++] = ran2;//随机数2
    
    NSLog(@"需要解密的22字节：%@", array);
        
    for (int i = 0; i < array.count; i ++) {
        NSString *tempStr = [array[i] UUIDString];
        NSString *temp1 = [tempStr substringWithRange:NSMakeRange(2, 2)];
        NSString *temp2 = [tempStr substringWithRange:NSMakeRange(0, 2)];

        NSData *d1 = [JLDataConvertUtil hexToBytes:temp1];
        NSData *d2 = [JLDataConvertUtil hexToBytes:temp2];
            
        uint8_t byte1 = [JLDataConvertUtil uint8FromBytes:d1];
        uint8_t byte2 = [JLDataConvertUtil uint8FromBytes:d2];
        
        p_data[plen++] = byte1;
        p_data[plen++] = byte2;
    }
    
    //加解密函数
    cyn_beacon_encodeMassage(temp_key, &p_data[9], 22);
    
    uint8_t sn_data[6] = {0};
    uint8_t sn_ascii[6] = {0};//ASCII码值格式的容器

    uint8_t code_data[1] = {0};
    uint8_t code_ascii[1] = {0};
    
    for (int i = 0; i < 6; i ++) {
        sn_data[i] = p_data[i + 9]; //p_datap[31] 第9~14位字节对应设备序列号，取出备用
    }
    
    code_data[0] = p_data[15]; //p_datap[31] 第15位字节对应状态码，0-失败，1-成功
    
    NSLog(@"sn_data:%s", sn_data);
    NSLog(@"code_data:%s", code_data);

    //16进制转换ASCII码值
    HexToAscii(sn_data, sn_ascii, 6);
    // ascii_data的值就是设备序列号
    NSLog(@"转换后的序列号：%s", sn_ascii);
    NSString *SN = [NSString stringWithFormat:@"%s", sn_ascii];
    NSLog(@"设备序列号：%@", SN);
    
    HexToAscii(code_data, code_ascii, 1);
    NSLog(@"转换后的状态码：%s", code_ascii);
    NSString *codeStr = [NSString stringWithFormat:@"%s", code_ascii];
    int code = (int)strtoul([codeStr UTF8String], 0, 16);//16进制转10进制
    NSLog(@"状态码：%d", code);
    
    return code;
}

#pragma mark -
#pragma mark - Private

///配置打印机秘钥，按照协议将【序列号和秘钥】加密后发送到蓝牙打印机设备
+ (NSString *)cyn_setSecretKeyEncryptWithRandom1:(NSString *)random1 random2:(NSString *)random2 byteArray:(NSArray *)array
{
    //16位秘钥
    uint8_t device_beacon_encodeKey[16] = {0xF3, 0x78, 0x6D, 0x3F, 0xA7, 0x56, 0x9B, 0x37, 0x6C, 0x3D, 0x91, 0x8E, 0xE5, 0x98, 0xD3, 0xBC};
    uint8_t temp_key[16] = {0};
    
    //字符串转换成16进制
    NSData *data1 = [JLDataConvertUtil hexToBytes:random1];
    NSData *data2 = [JLDataConvertUtil hexToBytes:random2];
    
    //16进制转换成uint8_t
    uint8_t ran1 = [JLDataConvertUtil uint8FromBytes:data1];
    uint8_t ran2 = [JLDataConvertUtil uint8FromBytes:data2];
    NSLog(@"ran1 : %c --- ran2 : %c" , ran1, ran2);
 
    for (uint8_t j = 0; j < 16; j++)
    {
        temp_key[j] = device_beacon_encodeKey[j];
        temp_key[j] = temp_key[j] ^ ran1;
        temp_key[j] = temp_key[j] ^ ran2;
    }
    
    //此时的 temp_key[16] 就是二次新秘钥
    //用二次新秘钥对数组中的8个字节进行解密，前6个字节代表设备序列号，倒数第二个字节是状态码

    uint8_t p_data[31] = {0};
    uint8_t plen = 0;
    
    //beacon头，5字节，固定内容
    p_data[plen++] = 0x02;
    p_data[plen++] = 0x01;
    p_data[plen++] = 0x04;
    p_data[plen++] = 0x1B;
    p_data[plen++] = 0xFF;
    
    p_data[plen++] = 0x5A;//包头
    p_data[plen++] = 0x61;//功能码，秘钥配置
    p_data[plen++] = ran1;//随机数1
    p_data[plen++] = ran2;//随机数2
    
    NSLog(@"需要加密的22字节：%@", array);
    
    for (int i = 0; i < array.count; i ++) {
        NSString *tempStr = [array[i] UUIDString];
        NSString *temp1 = [tempStr substringWithRange:NSMakeRange(2, 2)];
        NSString *temp2 = [tempStr substringWithRange:NSMakeRange(0, 2)];

        NSData *d1 = [JLDataConvertUtil hexToBytes:temp1];
        NSData *d2 = [JLDataConvertUtil hexToBytes:temp2];
            
        uint8_t byte1 = [JLDataConvertUtil uint8FromBytes:d1];
        uint8_t byte2 = [JLDataConvertUtil uint8FromBytes:d2];
        
        p_data[plen++] = byte1;
        p_data[plen++] = byte2;
    }
    
    //加解密函数
    cyn_beacon_encodeMassage(temp_key, &p_data[9], 22);
    
    uint8_t ascii_data[22] = {0};//容器
    uint8_t target_data[22] = {0};
    
    for (int i = 0; i < 22; i ++) {
        target_data[i] = p_data[i + 9]; //p_datap[31] 第9~31位字节对应设备序列号和员工卡号密文
    }
    
    HexToAscii(target_data, ascii_data, 22);
    
    NSLog(@"ascii_data:%s", ascii_data);
    NSString *dataStr = [NSString stringWithFormat:@"%s", ascii_data];
    return dataStr;
}

///第二步，下发数据给设备，需要加密后再发送
+ (NSString *)cyn_sendDataToPrinterWithRandom1:(NSString *)random1 random2:(NSString *)random2 byteArray:(NSArray *)array
{
    //16位秘钥
    uint8_t device_beacon_encodeKey[16] = {0xF3, 0x78, 0x6D, 0x3F, 0xA7, 0x56, 0x9B, 0x37, 0x6C, 0x3D, 0x91, 0x8E, 0xE5, 0x98, 0xD3, 0xBC};
    uint8_t temp_key[16] = {0};
    
    //字符串转换成16进制
    NSData *data1 = [JLDataConvertUtil hexToBytes:random1];
    NSData *data2 = [JLDataConvertUtil hexToBytes:random2];
    
    //16进制转换成uint8_t
    uint8_t ran1 = [JLDataConvertUtil uint8FromBytes:data1];
    uint8_t ran2 = [JLDataConvertUtil uint8FromBytes:data2];
    //NSLog(@"ran1 : %c --- ran2 : %c" , ran1, ran2);
    
    for (uint8_t j=0; j<16; j++)
    {
        temp_key[j] = device_beacon_encodeKey[j];
        temp_key[j] = temp_key[j] ^ ran1;
        temp_key[j] = temp_key[j] ^ ran2;
    }
    
    //此时的 temp_key[16] 就是二次新秘钥
    //用二次新秘钥对数组中的22个字节进行加密，前6个字节代表设备序列号，后16个字节是员工卡号密文
    
    uint8_t p_data[31] = {0};
    uint8_t plen = 0;
    
    //beacon头，5字节，固定内容
    p_data[plen++] = 0x02;
    p_data[plen++] = 0x01;
    p_data[plen++] = 0x06;
    p_data[plen++] = 0x1B;
    p_data[plen++] = 0xFF;
    
    p_data[plen++] = 0x5A;//包头
    p_data[plen++] = 0x62;//功能码，打印机授权
    p_data[plen++] = ran1;//随机数1
    p_data[plen++] = ran2;//随机数2
    
    for (int i = 0; i < array.count; i ++) {
        NSString *tempStr = [array[i] UUIDString];
        NSString *temp1 = [tempStr substringWithRange:NSMakeRange(2, 2)];
        NSString *temp2 = [tempStr substringWithRange:NSMakeRange(0, 2)];

        NSData *d1 = [JLDataConvertUtil hexToBytes:temp1];
        NSData *d2 = [JLDataConvertUtil hexToBytes:temp2];
            
        uint8_t byte1 = [JLDataConvertUtil uint8FromBytes:d1];
        uint8_t byte2 = [JLDataConvertUtil uint8FromBytes:d2];
        
        p_data[plen++] = byte1;
        p_data[plen++] = byte2;
    }

    //加解密函数
    cyn_beacon_encodeMassage(temp_key, &p_data[9], 22);

    uint8_t ascii_data[22] = {0};//容器
    uint8_t target_data[22] = {0};
    
    for (int i = 0; i < 22; i ++) {
        target_data[i] = p_data[i + 9]; //p_datap[31] 第9~31位字节对应设备序列号和员工卡号密文
    }
    
    HexToAscii(target_data, ascii_data, 22);
    //NSLog(@"ascii_data:%s", ascii_data);
    NSString *dataStr = [NSString stringWithFormat:@"%s", ascii_data];
    return dataStr;
}

/// 加解密调用这个方法
void cyn_beacon_encodeMassage(uint8_t *pszKey, uint8_t *ptrMsg, uint16_t nMsglen)
{
    uint8_t chCode = 0x5A;
    uint8_t nIndex = 0;
    int i = 0;
    
    if (ptrMsg == NULL)
        return;
    
    for (i=0; i<16; i++)
    {
        chCode ^= pszKey[i];
    }
    
    for (i=0; i<nMsglen; i++)
    {
        uint8_t chKey = chCode ^ pszKey[nIndex];
        ptrMsg[i] ^= chKey;
        
        nIndex += 1;
        chCode += 1;
        
        if (nIndex >= 16)
        {
            nIndex = 0;
        }
    }
}

///反转字符串，eg：1234 -> 3412
+ (NSString *)reverseString:(NSString *)str
{
    NSString *result = @"";
    NSString *str1 = [str substringWithRange:NSMakeRange(2, 2)];
    NSString *str2 = [str substringWithRange:NSMakeRange(0, 2)];
    result = [str1 stringByAppendingString:str2];
    return result;
}

@end
