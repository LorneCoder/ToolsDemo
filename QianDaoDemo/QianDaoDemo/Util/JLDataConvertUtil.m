//
//  JLDataConvertUtil.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/10/17.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import "JLDataConvertUtil.h"

@implementation JLDataConvertUtil

///字符串转16进制
+ (NSData *)hexToBytes:(NSString *)str
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

///data转换uint8_t
+ (uint8_t)uint8FromBytes:(NSData *)fData
{
    NSAssert(fData.length == 1, @"uint8FromBytes: (data length != 1)");
    NSData *data = fData;
    uint8_t val = 0;
    [data getBytes:&val length:1];
    return val;
}

/// 字节反转
+ (NSData *)dataWithReverse:(NSData *)srcData
{
    NSUInteger byteCount = srcData.length;
    NSMutableData *dstData = [[NSMutableData alloc] initWithData:srcData];
    NSUInteger halfLength = byteCount / 2;
    for (NSUInteger i=0; i<halfLength; i++) {
        NSRange begin = NSMakeRange(i, 1);
        NSRange end = NSMakeRange(byteCount - i - 1, 1);
        NSData *beginData = [srcData subdataWithRange:begin];
        NSData *endData = [srcData subdataWithRange:end];
        [dstData replaceBytesInRange:begin withBytes:endData.bytes];
        [dstData replaceBytesInRange:end withBytes:beginData.bytes];
    }
    
    return dstData;
}

///HEX转ASCII函数
int HexToAscii(unsigned char *pHexStr,unsigned char *pAscStr,int Len)
{
    char Nibble[2];
    unsigned char Buffer[2048];
    int i = 0;
    int j = 0;

    for(i=0;i<Len;i++)
    {
        Nibble[0]=pHexStr[i] >> 4 & 0X0F;
        Nibble[1]=pHexStr[i] & 0x0F;
        for(j=0;j<2;j++)
        {
            if(Nibble[j]<10)
            {
                Nibble[j]=Nibble[j]+0x30;
            }
            else if(Nibble[j]<16)
            {
                Nibble[j]=Nibble[j]-10+'A';
            }
            else
            {
                return 0;
            }
        }
        memcpy(Buffer+i*2,Nibble,2);
    }
    Buffer[2*Len]=0x00;
    memcpy(pAscStr,Buffer,2*Len);
    pAscStr[2*Len]=0x00;
    return 1;
}

///将十进制转化为十六进制
+ (NSString *)intToHex:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
    }
    return str;
}


@end
