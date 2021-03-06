//
//  BLEPrinterController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/10/15.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import "BLEPrinterController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEPrinterTool.h"

@interface BLEPrinterController () <CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource, CBPeripheralManagerDelegate>

//中心设备，用于扫描蓝牙打印机发送的广播包
@property (nonatomic, strong) CBCentralManager *centralManager;
//外设，用于发送数据到蓝牙打印机
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *UUIDArray;

//第一步获取打印机beacon
//解密后的设备序列号
@property (nonatomic, copy) NSString *deviceSN;

//第三步设备应答
@property (nonatomic, assign) int replyCode;//状态码，1-设备应答成功

@end

@implementation BLEPrinterController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    self.UUIDArray = [NSMutableArray array];
    
    self.title = @"蓝牙打印机";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.table];
    
    // 创建中心设备管理器，会回调centralManagerDidUpdateState
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
    // 创建外设管理器，会回调peripheralManagerDidUpdateState方法
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

- (void)stopScan
{
    [self.centralManager stopScan];
}

#pragma mark -
#pragma mark - tableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[NSString stringWithFormat:@"cellID%ld",(long)indexPath.row]];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"设备序列号：%@", self.dataArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *SN = self.dataArray[indexPath.row];
    
    __weak typeof(BLEPrinterController *) weakSelf = self;
    //点击对应的蓝牙打印机设备，进行授权
    [self showAlertWithMessae:[NSString stringWithFormat:@"确定授权打印机：%@", SN] okTitle:@"确定" cancelTitle:@"取消" okBlock:^{
        //确定授权
        self.replyCode = 0;//每次授权的时候将状态码置零
        NSLog(@"外设发送数据给打印机");
        [weakSelf sendDataToPrinter];
    }];
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
    NSArray *kCBAdvDataServiceUUIDs = (NSArray *)[advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
    NSString *idStr = [kCBAdvDataServiceUUIDs.firstObject UUIDString];
    //反转，转换成正确的格式
    NSString *end = [idStr substringWithRange:NSMakeRange(0, 2)];
    NSString *start = [idStr substringWithRange:NSMakeRange(2, 2)];
    NSString *resultStr = [start stringByAppendingString:end];
    
    //打印机广播包，第一步信息发布
    if ([resultStr isEqualToString:@"5A60"]) {
        //停止扫描
        //[self stopScan];
        
        //过滤，已经扫描到并解析到序列号的设备，就不用再执行解密的一系列操作了
        if (![self.UUIDArray containsObject:peripheral.identifier.UUIDString]) {
            [self.UUIDArray addObject:peripheral.identifier.UUIDString];
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
        
        //获取两个随机数
        NSString *tempStr = [kCBAdvDataServiceUUIDs[1] UUIDString];
        NSString *randomNum1 = [tempStr substringWithRange:NSMakeRange(2, 2)];
        NSString *randomNum2 = [tempStr substringWithRange:NSMakeRange(0, 2)];
        NSLog(@"随机数1：%@ ---- 随机数2：%@", randomNum1, randomNum2);
        
        //随机数1分别与16位原始秘钥异或，得到一次新秘钥
        //随机数2分别与16位一次秘钥异或，得到二次新秘钥

        //取出广播包的后22个字节，剔除前两个元素，取出后11个元素
        NSArray *arr = [kCBAdvDataServiceUUIDs subarrayWithRange:NSMakeRange(2, kCBAdvDataServiceUUIDs.count - 2)];
        [self cyn_firstStepDecryptWithRandom1:randomNum1 random2:randomNum2 byteArray:arr];
    }
    //打印机授权应答，最后一步
    else if ([resultStr isEqualToString:@"5A64"]) {
        //收到打印机的应答，就停止广播数据
        [self.peripheralManager stopAdvertising];
        
        if (self.replyCode == 1) {
            //设备已经应答，授权成功，避免重复授权
            return;
        }
        
        NSLog(@"################################ 打印机授权应答 ##################################################");
        NSLog(@"UUIDString：%@", peripheral.identifier.UUIDString);
        NSLog(@"RSSI：%@", RSSI);
        NSLog(@"services:%@",peripheral.services);
        NSLog(@"外设name：%@", peripheral.name);
        NSLog(@"外设advertisementData：%@", advertisementData);
        
        //获取两个随机数
        NSString *tempStr = [kCBAdvDataServiceUUIDs[1] UUIDString];
        NSString *randomNum1 = [tempStr substringWithRange:NSMakeRange(2, 2)];
        NSString *randomNum2 = [tempStr substringWithRange:NSMakeRange(0, 2)];
        NSLog(@"随机数1：%@ ---- 随机数2：%@", randomNum1, randomNum2);
        
        //取出广播包的后22个字节，剔除前两个元素，取出后11个元素
        NSArray *arr = [kCBAdvDataServiceUUIDs subarrayWithRange:NSMakeRange(2, kCBAdvDataServiceUUIDs.count - 2)];
        [self cyn_thirdStepEncryptWithRandom1:randomNum1 random2:randomNum2 byteArray:arr];
        
    } else {
        
    }
}

#pragma mark -
#pragma mark - 蓝牙数据交互

///第一步，解析打印机beacon
- (void)cyn_firstStepDecryptWithRandom1:(NSString *)random1 random2:(NSString *)random2 byteArray:(NSArray *)array
{
    NSString *SN = [BLEPrinterTool cyn_decryptBeaconWithRandom1:random1 random2:random2 byteArray:array];
    NSLog(@"设备序列号：%@", SN);
    self.deviceSN = SN;

    if (![self.dataArray containsObject:SN]) {
        [self.dataArray addObject:SN];
        [self.table reloadData];
    }
}

///第二步，发送数据到打印机
- (void)sendDataToPrinter
{
    //员工卡号密文，从服务端获取
    NSArray *cardArr = @[@"5B", @"22", @"D2", @"61", @"2D", @"B4", @"4A", @"A6", @"8B", @"85", @"91", @"73", @"36", @"E6", @"5D", @"40"];
    NSArray *arr = [BLEPrinterTool cyn_sendDataToPrinterWithSN:self.deviceSN cardNumber:cardArr];
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:arr}];
}

///第三步，打印机应答数据解析，异或算法
- (void)cyn_thirdStepEncryptWithRandom1:(NSString *)random1 random2:(NSString *)random2 byteArray:(NSArray *)array
{
    int code = [BLEPrinterTool cyn_deviceReplyDecryptWithRandom1:random1 random2:random2 byteArray:array];
    if (code == 1) {
        self.replyCode = 1;
        [self showAlertWithMessae:@"打印机授权成功"];
    }
}

#pragma mark -
#pragma mark - 外设相关代理方法 CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    /** 设备的蓝牙状态
     CBManagerStateUnknown = 0,  未知
     CBManagerStateResetting,    重置中
     CBManagerStateUnsupported,  不支持
     CBManagerStateUnauthorized, 未验证
     CBManagerStatePoweredOff,   未启动
     CBManagerStatePoweredOn,    可用
     */
    
    if (@available(iOS 10.0, *)) {
        if (peripheral.state == CBManagerStatePoweredOn) {
            NSLog(@"外设-蓝牙可用");
            
        } else {
            NSLog(@"外设-蓝牙不可用");
        }
    } else {
        // Fallback on earlier versions
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error
{
    if (error) {
        NSLog(@"外设发送广播失败：%@", error);
    } else {
        NSLog(@"外设发送广播成功");
    }
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

#pragma mark -
#pragma mark - lazy loading

- (UITableView *)table
{
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _table.delegate = self;
        _table.dataSource = self;
        _table.rowHeight = 60;
        
        UIView *footer = [[UIView alloc] init];
        footer.backgroundColor = [UIColor whiteColor];
        _table.tableFooterView = footer;
    }
    return _table;
}

@end
