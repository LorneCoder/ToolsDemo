//
//  NFCController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2018/10/10.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "NFCController.h"
#import <CoreNFC/CoreNFC.h>

@interface NFCController () <NFCNDEFReaderSessionDelegate>

@property (nonatomic, strong) UIButton *startBtn;

@end

@implementation NFCController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"NFC";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.startBtn];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat viewWidth = self.view.frame.size.width;
    self.startBtn.frame = CGRectMake(20, 100, viewWidth - 40, 30);
}

- (void)startScan
{
    NSLog(@"开始扫描");
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
        
        NSLog(@"系统>11.0");
        
        if (@available(iOS 11.0, *)) {
            if ([NFCNDEFReaderSession readingAvailable]) {
                
                // invalidateAfterFirstRead 属性表示是否需要识别多个NFC标签，如果是YES，则会话会在第一次识别成功后终止。否则会话会持续
                // 不过有一种例外情况，就是如果响应了-readerSession:didInvalidateWithError:方法，则是否为YES，会话都会被终止
                
                NFCNDEFReaderSession *session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:nil invalidateAfterFirstRead:YES];
                [session beginSession];
            } else {
                NSLog(@"设备不支持NFC");
            }
        } else {
            NSLog(@"系统版本低于11.0");
        }
    }
}

#pragma mark -
#pragma mark - NFCNDEFReaderSessionDelegate

// 识别出现Error后会话会自动终止，此时就需要程序重新开启会话
- (void)readerSession:(NFCNDEFReaderSession *)session didInvalidateWithError:(NSError *)error
{
    NSLog(@"识别出错：%@", error);
}

- (void)readerSession:(NFCNDEFReaderSession *)session didDetectNDEFs:(NSArray<NFCNDEFMessage *> *)messages
{
    // 数组messages中是NFCNDEFMessage对象
    // NFCNDEFMessage对象中有一个records数组，这个数组中是NFCNDEFPayload对象
    // 参考NFCNDEFMessage、NFCNDEFPayload类
    // 解析数据
    
    for (NFCNDEFMessage *message in messages) {
        for (NFCNDEFPayload *playLoad in message.records) {
            NSLog(@"typeNameFormat : %d", playLoad.typeNameFormat);
            NSLog(@"type : %@", playLoad.type);
            NSLog(@"identifier : %@", playLoad.identifier);
            NSLog(@"playload : %@", playLoad.payload);
        }
    }
}


- (UIButton *)startBtn
{
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_startBtn setTitle:@"开始扫描" forState:UIControlStateNormal];
        [_startBtn addTarget:self action:@selector(startScan) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

@end
