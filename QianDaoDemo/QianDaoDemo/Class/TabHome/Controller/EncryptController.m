//
//  EncryptController.m
//  QianDaoDemo
//
//  Created by 高建龙 on 2020/12/22.
//  Copyright © 2020 gaojianlong. All rights reserved.
//

#import "EncryptController.h"
#import "DES3EncryptUtil.h"

@interface EncryptController ()

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *encryptBtn;
@property (nonatomic, strong) UILabel *resultLabel;

@end

@implementation EncryptController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"3DES加解密";
    self.view.backgroundColor = [UIColor whiteColor];
    [self initSubviews];
}

- (void)initSubviews
{
    [self.view addSubview:self.textField];
    [self.view addSubview:self.encryptBtn];
    [self.view addSubview:self.resultLabel];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.textField.frame = CGRectMake(30, 100, kScreenWidth - 60, 30);
    self.encryptBtn.frame = CGRectMake(100, CGRectGetMaxY(self.textField.frame) + 30, kScreenWidth - 200, 40);
    self.resultLabel.frame = CGRectMake(30, CGRectGetMaxY(self.encryptBtn.frame) + 30, kScreenWidth - 60, 30);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.textField endEditing:YES];
}

//测试3des加解密
- (void)encryptTest:(UIButton *)sender
{
//    0 1 0 2 0 3 0 4
//    0 5 0 6 0 7 0 8
//    0 9 0 A 0 1 0 2
    
    char char_keys[24] =
    {
        '0', '1', '0', '2', '0', '3', '0', '4',
        '0', '5', '0', '6', '0', '7', '0', '8',
        '0', '9', '0', 'A', '0', '1', '0', '2'
    };
    uint8_t p_data[24] = {0};
    uint8_t ascii_data[24] = {0};
    
    for (uint8_t i = 0; i < 24; i++) {
        p_data[i] = char_keys[i];
    }
    
    HexToAscii(p_data, ascii_data, 24);
    NSLog(@"ascii_data : %s", ascii_data);
    NSLog(@"--------");
    
    // 0 3 0 4 0 5 0 6
    char iv_chars[8] =
    {
        '0', '3', '0', '4', '0', '5', '0', '6'
    };
    uint8_t iv_data[8] = {0};
    uint8_t iv_ascii[8] = {0};
    
    for (uint8_t i = 0; i < 8; i++) {
        iv_data[i] = iv_chars[i];
    }
    
    HexToAscii(iv_data, iv_ascii, 8);
    NSLog(@"iv_ascii : %s", iv_ascii);
    
    //TestDES();
    
    /*
    NSString *str = self.textField.text;
    if (sender.selected) {
        NSString *result = [DES3EncryptUtil decrypt:str];
        NSLog(@"解密后：%@", result);
        self.textField.text = result;
    } else {
        NSString *result = [DES3EncryptUtil encrypt:str];
        NSLog(@"加密后：%@", result);
        self.textField.text = result;
    }
    
    sender.selected = !sender.selected;
     */
}

#pragma mark -
#pragma mark - getter

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.font = [UIFont systemFontOfSize:13];
        _textField.backgroundColor = [UIColor orangeColor];
        _textField.text = @"1234567890123456";
    }
    return _textField;
}

- (UIButton *)encryptBtn
{
    if (!_encryptBtn) {
        _encryptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_encryptBtn setTitle:@"加密" forState:UIControlStateNormal];
        [_encryptBtn setTitle:@"解密" forState:UIControlStateSelected];
        [_encryptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_encryptBtn setBackgroundColor:[UIColor orangeColor]];
        _encryptBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [_encryptBtn addTarget:self action:@selector(encryptTest:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _encryptBtn;
}

- (UILabel *)resultLabel
{
    if (!_resultLabel) {
        _resultLabel = [[UILabel alloc] init];
        _resultLabel.text = @"结果";
        _resultLabel.font = [UIFont systemFontOfSize:15];
        _resultLabel.textAlignment = NSTextAlignmentCenter;
        _resultLabel.textColor = [UIColor whiteColor];
        _resultLabel.backgroundColor = [UIColor orangeColor];
    }
    return _resultLabel;
}

@end
