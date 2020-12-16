//
//  JLAlertView.m
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/12/7.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "JLAlertView.h"
#define kScreenWidthScale       ([UIScreen mainScreen].bounds.size.width/375.0)
#define kScreenHeightScale      ([UIScreen mainScreen].bounds.size.height/667.0)

@interface JLAlertView()

@property (nonatomic, strong) UIView *coverView;//蒙层
@property (nonatomic, strong) UIView *bottomView;//弹窗底视图
@property (nonatomic, strong) UIImageView *tipImage;
@property (nonatomic, strong) UILabel *title;//标题
@property (nonatomic, strong) UILabel *detail;//内容
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *okBtn;

@property (nonatomic, assign) CGFloat tipImageHeight;
@property (nonatomic, assign) JLAlertButtonType buttonType;

@property (nonatomic, copy) ButtonClickedCallback okBlock;
@property (nonatomic, copy) ButtonClickedCallback cancelBlock;

@property (nonatomic, assign) BOOL notAutoHideAlert;//确定按钮点击后是依然显示弹窗，默认为NO

@end

@implementation JLAlertView

- (instancetype)cyn_init
{
    self.tipImageHeight = 35;
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        self.frame = window.bounds;
        [window addSubview:self];
        
        [self addSubview:self.coverView];
        [self.coverView addSubview:self.bottomView];
        
        [self.bottomView addSubview:self.tipImage];
        [self.bottomView addSubview:self.title];
        [self.bottomView addSubview:self.detail];
        [self.bottomView addSubview:self.cancelBtn];
        [self.bottomView addSubview:self.okBtn];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(0);
        make.right.equalTo(self.mas_right).offset(0);
        make.top.equalTo(self.mas_top).offset(0);
        make.bottom.equalTo(self.mas_bottom).offset(0);
    }];
    
    CGFloat maxH = kScreenHeight - kNavigationBarHeight - kBottomSafeAreaHeight - 50;
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverView.mas_left).offset(50 * kScreenWidthScale);
        make.right.equalTo(self.coverView.mas_right).offset(- 50 * kScreenWidthScale);
        make.center.mas_equalTo(self.coverView.center);
        make.height.lessThanOrEqualTo(@(maxH));
    }];
    
    CGFloat tipImageY = self.tipImageHeight == 0 ? 0 : 20;
    [self.tipImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top).offset(tipImageY);
        make.centerX.mas_equalTo(self.bottomView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(self.tipImageHeight, self.tipImageHeight));
    }];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView.mas_left).offset(10);
        make.right.equalTo(self.bottomView.mas_right).offset(-10);
        make.top.equalTo(self.tipImage.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.bottomView.mas_centerX);
    }];
    
    [self.detail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.title.mas_left);
        make.right.mas_equalTo(self.title.mas_right);
        make.top.equalTo(self.title.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self.bottomView.mas_centerX);
    }];
    
    if (self.buttonType == JLAlertButtonTypeSingle || self.buttonType == JLAlertButtonTypeNone) {
        [self.okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.detail.mas_bottom).offset(20);
            make.bottom.equalTo(self.bottomView.mas_bottom).offset(-20);
            make.centerX.mas_equalTo(self.bottomView.mas_centerX);
            make.height.mas_equalTo(30);
            make.width.greaterThanOrEqualTo(@(90 * kScreenWidthScale));
        }];
        
        
        
    } else if (self.buttonType == JLAlertButtonTypeDouble) {
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bottomView.mas_left).offset(30 * kScreenWidthScale);
            make.top.equalTo(self.detail.mas_bottom).offset(20);
            make.size.mas_equalTo(CGSizeMake(90 * kScreenWidthScale, 30));
            make.bottom.equalTo(self.bottomView.mas_bottom).offset(-20);
        }];
        
        [self.okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bottomView.mas_right).offset(- 30 * kScreenWidthScale);
            make.top.equalTo(self.detail.mas_bottom).offset(20);
            make.size.mas_equalTo(CGSizeMake(90 * kScreenWidthScale, 30));
            make.bottom.equalTo(self.bottomView.mas_bottom).offset(-20);
        }];
    }
}

#pragma mark -
#pragma mark - Public Method

/**成功弹窗-单按钮*/
+ (instancetype)showSuccessAlertWithTitle:(NSString *)title
                                  message:(NSString *)message
                                       ok:(NSString *)ok
                               completion:(ButtonClickedCallback)completion
{
    return [self showAlertWithTitle:title
                            message:message
                             cancel:nil
                                 ok:ok
                               type:JLAlertTypeSuccess
                         buttonType:JLAlertButtonTypeSingle
                         completion:completion];
}

/**失败弹窗-单按钮*/
+ (instancetype)showErrorAlertWithTitle:(NSString *)title
                                message:(NSString *)message
                                     ok:(NSString *)ok
                             completion:(ButtonClickedCallback)completion
{
    return [self showAlertWithTitle:title
                            message:message
                             cancel:nil
                                 ok:ok
                               type:JLAlertTypeError
                         buttonType:JLAlertButtonTypeSingle
                         completion:completion];
}

/**警告弹窗-单按钮*/
+ (instancetype)showWarningAlertWithTitle:(NSString *)title
                                  message:(NSString *)message
                                       ok:(NSString *)ok
                               completion:(ButtonClickedCallback)completion
{
    return [self showAlertWithTitle:title
                            message:message
                             cancel:nil
                                 ok:ok
                               type:JLAlertTypeWarning
                         buttonType:JLAlertButtonTypeSingle
                         completion:completion];
}

/**无图片、单按钮的弹窗*/
+ (instancetype)showAlertWithTitle:(NSString *)title
                           message:(NSString *)message
                                ok:(NSString *)ok
                        completion:(ButtonClickedCallback)completion
{
    return [self showAlertWithTitle:title
                            message:message
                             cancel:nil
                                 ok:ok
                         completion:completion];
}

/**无图片、单按钮的弹窗-自定义内容对齐方式*/
+ (instancetype)showAlertWithTitle:(NSString *)title
                           message:(NSString *)message
                                ok:(NSString *)ok
                 messageAlignmenti:(NSTextAlignment)alignment
                        completion:(ButtonClickedCallback)completion
{
    return [self showAlertWithTitle:title
                            message:message
                             cancel:nil
                                 ok:ok
                   messageAlignment:alignment
                               type:JLAlertTypeNone
                         buttonType:JLAlertButtonTypeSingle
                         completion:completion
                     cancelCallBack:nil];
}

/**无图片、双按钮的弹窗*/
+ (instancetype)showAlertWithTitle:(NSString *)title
                           message:(NSString *)message
                            cancel:(NSString *)cancel
                                ok:(NSString *)ok
                        completion:(ButtonClickedCallback)completion
{
    JLAlertButtonType buttonType;
    if (cancel) {
        buttonType = JLAlertButtonTypeDouble;
    } else {
        buttonType = JLAlertButtonTypeSingle;
    }
    
    return [self showAlertWithTitle:title
                            message:message
                             cancel:cancel
                                 ok:ok
                               type:JLAlertTypeNone
                         buttonType:buttonType
                         completion:completion];
}

/**无图片、双按钮的弹窗-取消按钮有回调*/
+ (instancetype)showAlertWithTitle:(NSString *)title
                           message:(NSString *)message
                            cancel:(NSString *)cancel
                                ok:(NSString *)ok
                        completion:(ButtonClickedCallback)completion
                    cancelCallback:(ButtonClickedCallback)cancelBlock
{
    JLAlertButtonType buttonType;
    if (cancel) {
        buttonType = JLAlertButtonTypeDouble;
    } else {
        buttonType = JLAlertButtonTypeSingle;
    }
    
    return [self showAlertWithTitle:title
                            message:message
                             cancel:cancel
                                 ok:ok
                   messageAlignment:NSTextAlignmentLeft
                               type:JLAlertTypeNone
                         buttonType:buttonType
                         completion:completion
                     cancelCallBack:cancelBlock];
}

/**无图片、双按钮的弹窗-取消按钮有回调-自定义内容对齐方式*/
+ (instancetype)showAlertWithTitle:(NSString *)title
                           message:(NSString *)message
                            cancel:(NSString *)cancel
                                ok:(NSString *)ok
                 messageAlignmenti:(NSTextAlignment)alignment
                  notAutoHideAlert:(BOOL)notAutoHide
                        completion:(ButtonClickedCallback)completion
                    cancelCallback:(ButtonClickedCallback)cancelBlock
{
    JLAlertButtonType buttonType;
    if (cancel) {
        buttonType = JLAlertButtonTypeDouble;
    } else {
        buttonType = JLAlertButtonTypeSingle;
    }
    
    JLAlertView *alert = [self showAlertWithTitle:title
                                          message:message
                                           cancel:cancel
                                               ok:ok
                                 messageAlignment:alignment
                                             type:JLAlertTypeNone
                                       buttonType:buttonType
                                       completion:completion
                                   cancelCallBack:cancelBlock];
    
    alert.notAutoHideAlert = notAutoHide;
    return alert;
}

#pragma mark -
#pragma mark -  2021年会抽奖主题弹窗
+ (instancetype)show2021ThemeAlertWithTitle:(NSString *)title
                                    message:(NSString *)message
                                     cancel:(NSString *)cancel
                                         ok:(NSString *)ok
                                 completion:(ButtonClickedCallback)completion
                             cancelCallback:(ButtonClickedCallback)cancelBlock
{
    JLAlertButtonType buttonType;
    if (cancel) {
        buttonType = JLAlertButtonTypeDouble;
    } else {
        buttonType = JLAlertButtonTypeSingle;
    }
    
    
    
    JLAlertView *alert = [self showAlertWithTitle:title
                                          message:message
                                           cancel:ok
                                               ok:cancel
                                 messageAlignment:NSTextAlignmentCenter
                                             type:JLAlertTypeNone
                                       buttonType:buttonType
                                       completion:cancelBlock
                                   cancelCallBack:completion];
    
    alert.bottomView.layer.cornerRadius = 6.0f;
    alert.detail.textColor = [UIColor colorWithHexString:@"#86272d"];
    alert.detail.font = [UIFont systemFontOfSize:16];
    
    alert.cancelBtn.backgroundColor = [UIColor colorWithHexString:@"#86272d"];
    alert.cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [alert.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    alert.okBtn.backgroundColor = [UIColor cyanColor];
    alert.okBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [alert.okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    return alert;
}



#pragma mark -
#pragma mark - Private Method

/**完整的构造方法-内容居中对齐*/
+ (instancetype)showAlertWithTitle:(NSString *)title
                           message:(NSString *)message
                            cancel:(NSString *)cancel
                                ok:(NSString *)ok
                              type:(JLAlertType)type
                        buttonType:(JLAlertButtonType)buttonType
                        completion:(ButtonClickedCallback)completion
{
    
    return [self showAlertWithTitle:title
                            message:message
                             cancel:cancel
                                 ok:ok
                   messageAlignment:NSTextAlignmentCenter
                               type:type
                         buttonType:buttonType
                         completion:completion
                     cancelCallBack:nil];
}

/**完整的构造方法-自定义内容对齐方式-取消按钮回调*/
+ (instancetype)showAlertWithTitle:(NSString *)title
                           message:(NSString *)message
                            cancel:(NSString *)cancel
                                ok:(NSString *)ok
                  messageAlignment:(NSTextAlignment)alignment
                              type:(JLAlertType)type
                        buttonType:(JLAlertButtonType)buttonType
                        completion:(ButtonClickedCallback)completion
                    cancelCallBack:(ButtonClickedCallback)cancelBlock
{
    JLAlertView *alert = [[JLAlertView alloc] cyn_init];
    switch (type) {
        case JLAlertTypeNone:
        {
            alert.tipImageHeight = 0;
            break;
        }
        case JLAlertTypeError:
        {
            alert.tipImage.image = [UIImage imageNamed:@"error"];
            alert.okBtn.backgroundColor = [UIColor colorWithHexString:@"#fa585a"];
            break;
        }
        case JLAlertTypeSuccess:
        {
            alert.tipImage.image = [UIImage imageNamed:@"success"];
            alert.okBtn.backgroundColor = [UIColor colorWithHexString:@"#0f88eb"];
            break;
        }
        case JLAlertTypeWarning:
        {
            alert.tipImage.image = [UIImage imageNamed:@"caution"];
            alert.okBtn.backgroundColor = [UIColor colorWithHexString:@"#f99744"];
            break;
        }
        default:
            break;
    }
    
    alert.buttonType = buttonType;
    alert.title.text = title;
    alert.detail.text = message;
    alert.detail.textAlignment = alignment;
    [alert.cancelBtn setTitle:cancel forState:UIControlStateNormal];
    [alert.okBtn setTitle:ok forState:UIControlStateNormal];
    alert.okBlock = completion;
    alert.cancelBlock = cancelBlock;
    
    [alert show];
    return alert;
}


- (void)show
{
    self.hidden = NO;
    
    self.bottomView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration:0.2 animations:^{
        self.bottomView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.bottomView.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)dismiss
{
    self.bottomView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.2 animations:^{
        self.bottomView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.bottomView.transform = CGAffineTransformMakeScale(0, 0);
            
            self.hidden = YES;
            [self removeFromSuperview];
        }];
    }];
}

- (void)cancelClicked:(UIButton *)sender
{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self dismiss];
}

- (void)okClicked:(UIButton *)sender
{
    if (self.okBlock) {
        self.okBlock();
    }
    
    if (!self.notAutoHideAlert) {
        [self dismiss];
    }
}

#pragma mark -
#pragma mark - getter

- (UIView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    }
    return _coverView;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.layer.cornerRadius = 3.0f;
        _bottomView.layer.masksToBounds = YES;
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (UIImageView *)tipImage
{
    if (!_tipImage) {
        _tipImage = [[UIImageView alloc] init];
    }
    return _tipImage;
}

- (UILabel *)title
{
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.font = [UIFont systemFontOfSize:16];
        _title.textColor = [UIColor colorWithHexString:@"#404040"];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.numberOfLines = 0;
    }
    return _title;
}

- (UILabel *)detail
{
    if (!_detail) {
        _detail = [[UILabel alloc] init];
        _detail.font = [UIFont systemFontOfSize:14];
        _detail.textColor = [UIColor colorWithHexString:@"#5e5e5e"];
        _detail.textAlignment = NSTextAlignmentCenter;
        _detail.numberOfLines = 0;
    }
    return _detail;
}

- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.layer.cornerRadius = 3.0f;
        _cancelBtn.layer.masksToBounds = YES;
        _cancelBtn.backgroundColor = [UIColor colorWithHexString:@"#f0f1f3"];
        [_cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)okBtn
{
    if (!_okBtn) {
        _okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _okBtn.layer.cornerRadius = 3.0f;
        _okBtn.layer.masksToBounds = YES;
        _okBtn.backgroundColor = [UIColor colorWithHexString:@"#0f88eb"];
        [_okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _okBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _okBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_okBtn setTitle:@"知道了" forState:UIControlStateNormal];
        [_okBtn addTarget:self action:@selector(okClicked:) forControlEvents:UIControlEventTouchUpInside];
        _okBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    }
    return _okBtn;
}

@end
