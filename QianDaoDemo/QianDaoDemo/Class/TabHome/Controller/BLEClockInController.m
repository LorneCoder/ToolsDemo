//
//  BLEClockInController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2020/7/21.
//  Copyright © 2020 gaojianlong. All rights reserved.
//

#import "BLEClockInController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEClockInController () <CBCentralManagerDelegate>

//中心设备，用于扫描蓝牙设备发送的广播包
@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, strong) NSMutableArray *UUIDArray;
@property (nonatomic, strong) NSMutableArray *bleDeviceArray;

@end

@implementation BLEClockInController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.UUIDArray = [NSMutableArray array];
    self.bleDeviceArray = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"蓝牙门禁";
    
    [self initCentralManager];
}

- (void)initCentralManager
{
    // 创建中心设备管理器，会回调centralManagerDidUpdateState
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

#pragma mark -
#pragma mark - 中心设备代理方法 CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // 蓝牙可用，开始扫描外设
    if (@available(iOS 10.0, *)) {
        if (central.state == CBManagerStatePoweredOn) {
            NSLog(@"中心设备-蓝牙可用");
            // 根据SERVICE_UUID来扫描外设，如果不设置，则扫描所有蓝牙设备
            //[central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]] options:nil];
            [central scanForPeripheralsWithServices:nil options:nil];
        }
        if(central.state == CBManagerStateUnsupported) {
            [self showAlertWithMessae:@"该设备不支持蓝牙"];
        }
        
        if (central.state == CBManagerStatePoweredOff) {
            [self showAlertWithMessae:@"蓝牙已关闭"];
        }
    } else {
        // Fallback on earlier versions
    }
}

/** 发现符合要求的外设，回调 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if ([peripheral.name hasPrefix:@"XXH"]) {
        //停止扫描
        [self.centralManager stopScan];
        
        //过滤，已经扫描到并解析到序列号的设备，就不用再执行解密的一系列操作了
        if (![self.bleDeviceArray containsObject:peripheral.name]) {
            [self.bleDeviceArray addObject:peripheral.name];
        } else {
            return;
        }

        //蓝牙打印机读卡器
        NSLog(@"##################################################################################");
        NSLog(@"UUIDString：%@", peripheral.identifier.UUIDString);
        NSLog(@"RSSI：%@", RSSI);
        NSLog(@"services:%@",peripheral.services);
        NSLog(@"外设name：%@", peripheral.name);
        NSLog(@"外设advertisementData：%@", advertisementData);
        
        //解析数据
        [self parseBeaconData:advertisementData];
    }
}

/// 解析广播数据
- (void)parseBeaconData:(NSDictionary *)data
{
    NSDictionary *kCBAdvDataServiceData = [data objectForKey:@"kCBAdvDataServiceData"];
    NSLog(@"kCBAdvDataServiceData === %@", kCBAdvDataServiceData);
    
    if (kCBAdvDataServiceData) {
        NSArray *valuesArr = kCBAdvDataServiceData.allValues;
        NSData *byteData = valuesArr.firstObject;
        NSLog(@"byteData == %@", byteData);
        
        NSString *hexStr = [JLDataConvertUtil hexStringWithData:byteData]; // hexStr = "A0E6F82D19A7 4EEA 0001 07041064"
        NSLog(@"hexStr == %@", hexStr);
                
        //Mac地址 1-6字节（一个字节用两个16进制数表示）
        NSString *macStr = [hexStr substringWithRange:NSMakeRange(0, 12)];
        
        //Major
        NSString *major = [hexStr substringWithRange:NSMakeRange(12, 4)];
        int major_int = (int)strtoul([major UTF8String], 0, 16);
        
        //Minor
        NSString *minor = [hexStr substringWithRange:NSMakeRange(16, 4)];
        int minor_int = (int)strtoul([minor UTF8String], 0, 16);
        
        NSLog(@"\n Mac地址 == %@\n Major == %d\n Minor == %d", macStr, major_int, minor_int);
    }
    
    
    /*
    //容器
    uint8_t temp_data[14] = {0};
    
    uint8_t p_data[14] = {0};
    uint8_t plen = 0;
    
    // a0 e6 f8 2d 19 a7 4e ea 00 01 07 04 10 64
    //1-6  mac地址
    p_data[plen++] = 0xa0;  // 160
    p_data[plen++] = 0xe6;  // 230
    p_data[plen++] = 0xf8;  // 248
    p_data[plen++] = 0x2d;  // 45
    p_data[plen++] = 0x19;  // 25
    p_data[plen++] = 0xa7;  // 167
    
    //7-10  【7-8】:Major;【9-10】:Minor
    p_data[plen++] = 0x4e;  // 78
    p_data[plen++] = 0xea;  // 234
    p_data[plen++] = 0x00;  // 0
    p_data[plen++] = 0x01;  // 1
    
    //11-14
    p_data[plen++] = 0x07;  // 7
    p_data[plen++] = 0x04;  // 4
    p_data[plen++] = 0x10;  // 16
    p_data[plen++] = 0x64;  // 100
    
    //HexToAscii(p_data, temp_data, 14);
    //NSLog(@"转换后的：%s", temp_data);
    
    //NSString *major_data = [NSString stringWithFormat:@"%s", temp_data];
    
    // UUID
    // fd a5 06 93 a4 e2 4f b1 af cf c6 eb 07 64 78 00
     */
}

#pragma mark -
#pragma mark - 自定义

/**显示提示框*/
- (void)showAlertWithMessae:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlertWithMessae:(NSString *)message okTitle:(NSString *)okTitle cancelTitle:(NSString *)cancelTitle okBlock:(void(^)(void))okBlock
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (okBlock) {
            okBlock();
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
