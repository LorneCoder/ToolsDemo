//
//  BLEPeripheralsController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/7/15.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import "BLEPeripheralsController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define SERVICE_UUID            @"CDD1"
#define CHARACTERISTIC_UUID     @"CDD2"

@interface BLEPeripheralsController () <CBPeripheralManagerDelegate>

@property (nonatomic, strong) UIBarButtonItem *rightBarBtn;

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic *characteristic;
@property (nonatomic,strong) CBCentral *central;//中心设备

@end

@implementation BLEPeripheralsController
{
    NSUUID *_lastDeviceUUID;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"蓝牙外设";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.rightBarBtn;
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

- (void)sendData
{
    if (!self.central) {
        [SVProgressHUD showImage:nil status:@"没有中心设备"];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发送数据" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入要发送的数据";
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray *textFields = alert.textFields;
        UITextField *dataTF = textFields.firstObject;
        
        NSLog(@"发送的数据：%@", dataTF.text);
        [self sendToData:dataTF.text];
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)sendToData:(NSString *)data
{
    /** 通过固定的特征发送数据到中心设备 */
    BOOL sendSuccess = [self.peripheralManager updateValue:[data dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.characteristic onSubscribedCentrals:@[self.central]];
    if (sendSuccess) {
        [SVProgressHUD showSuccessWithStatus:@"发送成功"];
    } else {
        [SVProgressHUD showErrorWithStatus:@"发送失败"];
    }
}

#pragma mark -
#pragma mark - CBPeripheralManagerDelegate

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
            NSLog(@"蓝牙可用");
            // 创建Service（服务）和Characteristics（特征）
            [self setupServiceAndCharacteristics];
            
        } else {
            NSLog(@"蓝牙不可用");
        }
    } else {
        // Fallback on earlier versions
    }
}

/** 创建服务和特征 */
- (void)setupServiceAndCharacteristics
{
    // 创建服务
    CBUUID *serviceID = [CBUUID UUIDWithString:SERVICE_UUID];
    CBMutableService *service = [[CBMutableService alloc] initWithType:serviceID primary:YES];
    // 创建服务中的特征
    CBUUID *characteristicID = [CBUUID UUIDWithString:CHARACTERISTIC_UUID];
    CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicID
                                                                                 properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite | CBCharacteristicPropertyNotify
                                                                                      value:nil
                                                                                permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    // 特征添加进服务
    service.characteristics = @[characteristic];
    // 服务加入管理
    [self.peripheralManager addService:service];
    
    // 为了手动给中心设备发送数据
    self.characteristic = characteristic;
}

/// 执行addService方法后执行如下回调
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error != nil) {
        NSLog(@"%s,error = %@",__PRETTY_FUNCTION__, error.localizedDescription);
    } else {
        // 根据服务的UUID开始广播
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:SERVICE_UUID]]}];
    }
}

/// 中心设备读取数据的时候回调
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    // 请求中的数据，这里把文本框中的数据发给中心设备
    //request.value = [self.textField.text dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"----中心设备读取数据----");
    request.value = [@"cyou" dataUsingEncoding:NSUTF8StringEncoding];
    // 成功响应请求
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

/// 中心设备写入数据的时候回调
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    // 写入数据的请求
    CBATTRequest *request = requests.lastObject;
    // 把写入的数据显示在文本框中
    //self.textField.text = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
    
    NSLog(@"写入的数据：%@", [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding]);
}

/// 订阅成功回调
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    //PS：目前测试的结论是，只有当中心设备订阅了该外设的特征，外设发送的数据才能被中心设备读取到；
    NSLog(@"订阅成功：%s",__FUNCTION__);
    [SVProgressHUD showSuccessWithStatus:@"订阅成功"];
    
    self.central = central;
    if (_lastDeviceUUID == central.identifier) {
        return;
    }
    _lastDeviceUUID = central.identifier;
}

/** 取消订阅回调 */
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"取消订阅：%s",__FUNCTION__);
}

#pragma mark -
#pragma mark - 懒加载

- (UIBarButtonItem *)rightBarBtn
{
    if (!_rightBarBtn) {
        _rightBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(sendData)];
    }
    return _rightBarBtn;
}

@end
