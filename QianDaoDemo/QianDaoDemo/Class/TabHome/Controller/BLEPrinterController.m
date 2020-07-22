//
//  BLEPrinterController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/10/15.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import "BLEPrinterController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEPrinterController () <CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource, CBPeripheralManagerDelegate>

//中心设备，用于扫描蓝牙打印机发送的广播包
@property (nonatomic, strong) CBCentralManager *centralManager;
//外设，用于发送数据到蓝牙打印机
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *UUIDArray;

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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[NSString stringWithFormat:@"cellID%ld",indexPath.row]];
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
        [self cyn_encryptWithRandom1:randomNum1 random2:randomNum2 byteArray:arr];
    }
    //打印机授权应答，最后一步
    else if ([resultStr isEqualToString:@"5A64"]) {
        
        NSLog(@"################################ 打印机授权应答 ##################################################");
        NSLog(@"UUIDString：%@", peripheral.identifier.UUIDString);
        NSLog(@"RSSI：%@", RSSI);
        NSLog(@"services:%@",peripheral.services);
        NSLog(@"外设name：%@", peripheral.name);
        NSLog(@"外设advertisementData：%@", advertisementData);
        
        
    } else {
        
    }
    
}

///异或算法
- (void)cyn_encryptWithRandom1:(NSString *)random1 random2:(NSString *)random2 byteArray:(NSArray *)array
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
    
    for (uint8_t j=0; j<16; j++)
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
    beacon_encodeMassage(temp_key, &p_data[9], 22);
    
    uint8_t temp_data[6] = {0};
    uint8_t ascii_data[6] = {0};//ASCII码值格式的容器

    for (int i = 0; i < 6; i ++) {
        temp_data[i] = p_data[i + 9]; //p_datap[31] 第9~14位字节对应设备序列号，取出备用
    }
    
    NSLog(@"temp_data:%s", temp_data);
    
    //16进制转换ASCII码值
    HexToAscii(temp_data, ascii_data, 6);
    // ascii_data的值就是设备序列号
    NSLog(@"转换后的：%s", ascii_data);
    
    NSString *SN = [NSString stringWithFormat:@"%s", ascii_data];
    NSLog(@"设备序列号：%@", SN);
    
    if (![self.dataArray containsObject:SN]) {
        [self.dataArray addObject:SN];
        [self.table reloadData];
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

/// 发送数据到打印机
- (void)sendDataToPrinter
{
    //BOOL sendSuccess = [self.peripheralManager updateValue:[data dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.characteristic onSubscribedCentrals:@[self.central]]
    
    //加密随机数
    int ran1 = rand()%255;
    int ran2 = rand()%255;
    NSLog(@"ran1 : %d, ran2 : %d", ran1, ran2);
    NSString *ranStr1 = [JLDataConvertUtil intToHex:ran1];
    NSString *ranStr2 = [JLDataConvertUtil intToHex:ran2];
    NSLog(@"ranStr1 : %@, ranStr2 : %@", ranStr1, ranStr2);
    NSString *byte2 = [ranStr2 stringByAppendingString:ranStr1];
    NSLog(@"第二个字节：%@", byte2);
    
    // SN：20 19 07 22 00 01
    NSString *sn = @"201907220001";
    NSData *dataSN = [JLDataConvertUtil hexToBytes:sn];
    NSLog(@"dataSN : %@", dataSN);
    
    
    NSArray *data = @[[CBUUID UUIDWithString:@"625A"],
                      [CBUUID UUIDWithString:byte2],
                      [CBUUID UUIDWithString:@"2019"],
                      [CBUUID UUIDWithString:@"0722"],
                      [CBUUID UUIDWithString:@"0001"],
                      
                      [CBUUID UUIDWithString:@"1111"],
                      [CBUUID UUIDWithString:@"2222"],
                      [CBUUID UUIDWithString:@"3333"],
                      [CBUUID UUIDWithString:@"4444"],
                      [CBUUID UUIDWithString:@"5555"],
                      [CBUUID UUIDWithString:@"6666"],
                      [CBUUID UUIDWithString:@"7777"],
                      [CBUUID UUIDWithString:@"8888"]];
    
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:data}];
}

#pragma mark -
#pragma mark - 加解密

/// 加解密调用这个方法
void beacon_encodeMassage(uint8_t *pszKey, uint8_t *ptrMsg, uint16_t nMsglen)
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
