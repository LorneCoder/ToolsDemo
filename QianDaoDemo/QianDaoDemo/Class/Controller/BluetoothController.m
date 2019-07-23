//
//  BluetoothController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2018/10/15.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "BluetoothController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTConnectController.h"

#define SERVICE_UUID        @"F000"
#define DEVICE_INFORMATION  @"Device Information"
#define CHARACTERISTIC_UUID @"FFF1"

@interface BluetoothController () <CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;

@property (nonatomic, strong) UIBarButtonItem *rightBarButton;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *dataArray;//扫描到的外设数组
@property (nonatomic, strong) NSMutableArray *idsArray;//外设对应的唯一标识数组

@property (strong, nonatomic) NSString *hexStr;

@end

@implementation BluetoothController

- (void)dealloc
{
    [self.dataArray removeAllObjects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataArray = [[NSMutableArray alloc] init];
    self.idsArray = [[NSMutableArray alloc] init];
    [self initSubviews];
    
    // 创建中心设备管理器，会回调centralManagerDidUpdateState
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.table.frame = self.view.bounds;
}

- (void)initSubviews
{
    self.title = @"蓝牙";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    [self.view addSubview:self.table];
}

/**写入数据*/
- (void)signIn
{
    
    
    [self writeValue:@""];
}

- (void)stopScan
{
    [self.centralManager stopScan];
}


#pragma mark -
#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // 蓝牙可用，开始扫描外设
    if (@available(iOS 10.0, *)) {
        if (central.state == CBManagerStatePoweredOn) {
            NSLog(@"蓝牙可用");
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
    //&& [peripheral.name hasPrefix:@"Simple"]
    
    if (![self.dataArray containsObject:peripheral] && peripheral.name && [peripheral.name isEqualToString:@"Simple BLE001"]) {
        
        NSLog(@"发现外设：%@", peripheral.name);
        NSLog(@"外设信息：%@", advertisementData);
        NSLog(@"RSSI：%@", RSSI);
        NSLog(@"UUIDString：%@", peripheral.identifier.UUIDString);
        NSLog(@"services:%@",peripheral.services);
        
        NSArray *kCBAdvDataServiceUUIDs = (NSArray *)[advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
        NSLog(@"序列号：%@", kCBAdvDataServiceUUIDs);
        NSString *idStr = [kCBAdvDataServiceUUIDs.lastObject UUIDString];
        //反转，转换成正确的格式
        NSString *end = [idStr substringWithRange:NSMakeRange(0, 2)];
        NSString *start = [idStr substringWithRange:NSMakeRange(2, 2)];
        NSString *resultStr = [start stringByAppendingString:end];
        [self.idsArray addObject:resultStr];
        NSLog(@"************************************************************");
        
        //将扫描到的设备添加到table的数据源中
        [self.dataArray addObject:peripheral];
        [self.table reloadData];
        [self.rightBarButton setEnabled:YES];
    }
}


/** 连接成功 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    // 可以停止扫描
    [self.centralManager stopScan];
    // 设置代理
    peripheral.delegate = self;
    // 搜索匹配我们UUID的服务
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
    //扫描所有服务
    //[peripheral discoverServices:nil];

    self.peripheral = peripheral;
    //[self showAlertWithMessae:@"连接成功"];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];    
    [SVProgressHUD showImage:kInfoImage status:@"连接成功"];
}

/** 连接失败的回调 */
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [SVProgressHUD showImage:kInfoImage status:@"连接失败"];
}

/** 断开连接 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    [SVProgressHUD showImage:kInfoImage status:@"断开连接"];
    // 断开连接可以设置重新连接
    //[central connectPeripheral:peripheral options:nil];
}

#pragma mark -
#pragma mark - CBPeripheralDelegate

/** 发现服务 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"error:%@", error);
        return;
    }
    
    // 遍历出外设中所有的服务
    for (CBService *service in peripheral.services) {
        NSLog(@"服务：%@---UUID：%@", service, service.UUID);
        
        [peripheral discoverCharacteristics:nil forService:service];
        //[peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_UUID]] forService:service];
    }
    
    if (peripheral.services.count > 0) {
    } else {
        NSLog(@"没有发现服务");
    }
}

/** 发现特征回调 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }

    // 遍历出所需要的特征
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"所有特征：%@", characteristic);
        // 从外设开发人员那里拿到不同特征的UUID，不同特征做不同事情，比如有读取数据的特征，也有写入数据的特征
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF1"]]) {
            //可读写的特征
            NSLog(@"发现特征 ========= FFF1");
            
            //self.characteristic = characteristic;
            //[peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            //读取特征的value值
            //[peripheral readValueForCharacteristic:characteristic];

            //搜索特征的描述符Descriptors
            //[peripheral discoverDescriptorsForCharacteristic:characteristic];
            
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF2"]]) {
            NSLog(@"发现特征 ========= FFF2");

        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF3"]]) {
            NSLog(@"发现特征 ========= FFF3");
            
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF4"]]) {
            NSLog(@"发现特征 ========= FFF4");
            
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF5"]]) {
            NSLog(@"发现特征 ========= FFF5");

        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A23"]]) {
            NSLog(@"发现特征 Mac地址 ========= 2A23");
            
        } else {
            
        }
    }
    
    if (service.characteristics.count > 0) {
        NSLog(@"特征数量：%ld", service.characteristics.count);
        
        BTConnectController *vc = [[BTConnectController alloc] init];
        vc.myCharacteristics = service.characteristics;
        
        
        vc.selectBlock = ^(CBCharacteristic *item) {
            
            self.characteristic = item;
            [peripheral setNotifyValue:YES forCharacteristic:item];
            //读取特征的value值
            [peripheral readValueForCharacteristic:item];
            //搜索特征的描述符Descriptors
            [peripheral discoverDescriptorsForCharacteristic:item];
            
            [SVProgressHUD showImage:kInfoImage status:[NSString stringWithFormat:@"选择了特征：%@", item.UUID.UUIDString]];
        };
        
        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        [self showAlertWithMessae:@"该服务没有特征"];
    }
}

/** 订阅状态的改变 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"订阅失败");
        NSLog(@"%@",error);
    }
    if (characteristic.isNotifying) {
        NSLog(@"订阅成功");
    } else {
        NSLog(@"取消订阅");
    }
}

/**更新了特征值,接收到数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"接收到外设发送过来的数据：%@", characteristic.value);
    
    // 拿到外设发送过来的数据
    //NSData *data = characteristic.value;
    //NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"接收到外设发送过来的数据：%@", dataStr);
}

/** 写入数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (error) {
        NSLog(@"写入失败：%@", error);
        return;
    }
    
    NSLog(@"写入成功:%@", characteristic);
}


//搜索到Characteristic的Descriptors
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"获取特征描述符失败：%@", error);
        return;
    }
    
    //打印出Characteristic和他的Descriptors
    NSLog(@"characteristic uuid:%@",characteristic.UUID);
    for (CBDescriptor *d in characteristic.descriptors) {
        NSLog(@"Descriptor uuid:%@",d.UUID);
    }
}

/** 读取数据 */
- (void)readValue
{
    [self.peripheral readValueForCharacteristic:self.characteristic];
}

/** 写入数据 */
- (void)writeValue:(NSString *)text
{
    if ([self.characteristic.UUID.UUIDString isEqualToString:@"FFF1"]) {
        [self configFFF1];
        
    } else if ([self.characteristic.UUID.UUIDString isEqualToString:@"FFF3"]) {
        [self configFFF3];
    }
}

/**写入FFF1对应的特征-刷卡*/
- (void)configFFF1
{
    // 用NSData类型来写入35748531378660600
    NSData *data = [self hexToBytes:@"7F0128873A6DF7"];
    
    //只有 characteristic.properties 有write的权限才可以写
    if(self.characteristic.properties & CBCharacteristicPropertyWrite){
        /*最好一个type参数可以为或type:CBCharacteristicWriteWithResponse,区别是是否会有反馈 */
        [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        
    } else {
        NSLog(@"该字段不可写！");
    }
}

/**写入FFF3对应的特征-自定义序列号*/
- (void)configFFF3
{
    //FFF3对应的序列号写入
    //NSData *data = [self hexToBytes:@"5AA50000000000000000000000000000000001BB"];
    NSData *data = [self hexToBytes:@"5AA51234567812345678123456781234567801B2"];
    
    if(self.characteristic.properties){
        //FFF3对应的属性 必须选择 CBCharacteristicWriteWithoutResponse，否则写入失败
        [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
        
    } else {
        NSLog(@"该字段不可写！");
    }
}


/**字符串转16进制*/
- (NSData *)hexToBytes:(NSString *)str
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

/**解析Mac地址*/
- (void)getMacAddress
{
    NSString *value = [NSString stringWithFormat:@"%@",self.characteristic.value];
    NSMutableString *macString = [[NSMutableString alloc] init];
    [macString appendString:[[value substringWithRange:NSMakeRange(16, 2)] uppercaseString]];
    [macString appendString:@":"];
    [macString appendString:[[value substringWithRange:NSMakeRange(14, 2)] uppercaseString]];
    [macString appendString:@":"];
    [macString appendString:[[value substringWithRange:NSMakeRange(12, 2)] uppercaseString]];
    [macString appendString:@":"];
    [macString appendString:[[value substringWithRange:NSMakeRange(5, 2)] uppercaseString]];
    [macString appendString:@":"];
    [macString appendString:[[value substringWithRange:NSMakeRange(3, 2)] uppercaseString]];
    [macString appendString:@":"];
    [macString appendString:[[value substringWithRange:NSMakeRange(1, 2)] uppercaseString]];
    
    NSLog(@"MAC地址：%@", macString);
}


#pragma mark -
#pragma mark - tableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *peripheral  = self.dataArray[indexPath.row];
    NSString *idStr = self.idsArray[indexPath.row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[NSString stringWithFormat:@"cellID%ld",indexPath.row]];
    }
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"唯一标识：%@", idStr];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CBPeripheral *peripheral  = self.dataArray[indexPath.row];
    
    //连接设备
    [self.centralManager connectPeripheral:peripheral options:nil];
}

/**显示提示框*/
- (void)showAlertWithMessae:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -
#pragma mark - lazy loading

- (UIBarButtonItem *)rightBarButton
{
    if (!_rightBarButton) {
        _rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"写入" style:UIBarButtonItemStyleDone target:self action:@selector(signIn)];
        [_rightBarButton setEnabled:NO];
    }
    return _rightBarButton;
}

- (UITableView *)table
{
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _table.delegate = self;
        _table.dataSource = self;
        _table.rowHeight = 80;
        
        UIView *footer = [[UIView alloc] init];
        footer.backgroundColor = [UIColor whiteColor];
        _table.tableFooterView = footer;
    }
    return _table;
}

@end
