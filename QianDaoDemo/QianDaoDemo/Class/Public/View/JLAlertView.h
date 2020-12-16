//
//  JLAlertView.h
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/12/7.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ButtonClickedCallback)(void);

typedef enum : NSUInteger {
    JLAlertTypeNone,
    JLAlertTypeError,
    JLAlertTypeSuccess,
    JLAlertTypeWarning,
} JLAlertType;

typedef enum : NSUInteger {
    JLAlertButtonTypeNone,
    JLAlertButtonTypeSingle,
    JLAlertButtonTypeDouble,
} JLAlertButtonType;

@interface JLAlertView : UIView

- (void)dismiss;

#pragma mark -
#pragma mark - 有图片
/**成功弹窗-单按钮*/
+ (instancetype)showSuccessAlertWithTitle:(NSString *)title
                                  message:(NSString *)message
                                       ok:(NSString *)ok
                               completion:(ButtonClickedCallback)completion;
/**失败弹窗-单按钮*/
+ (instancetype)showErrorAlertWithTitle:(NSString *)title
                                message:(NSString *)message
                                     ok:(NSString *)ok
                             completion:(ButtonClickedCallback)completion;
/**警告弹窗-单按钮*/
+ (instancetype)showWarningAlertWithTitle:(NSString *)title
                                message:(NSString *)message
                                       ok:(NSString *)ok
                             completion:(ButtonClickedCallback)completion;

#pragma mark -
#pragma mark -  无图片
/**无图片、单按钮的弹窗*/
+ (instancetype)showAlertWithTitle:(NSString *)title
                           message:(NSString *)message
                                ok:(NSString *)ok
                        completion:(ButtonClickedCallback)completion;

/**无图片、单按钮的弹窗-自定义内容对齐方式*/
+ (instancetype)showAlertWithTitle:(NSString *)title
                           message:(NSString *)message
                                ok:(NSString *)ok
                 messageAlignmenti:(NSTextAlignment)alignment
                        completion:(ButtonClickedCallback)completion;


/**无图片、双按钮的弹窗*/
+ (instancetype)showAlertWithTitle:(NSString *)title
                           message:(NSString *)message
                            cancel:(NSString *)cancel
                                ok:(NSString *)ok
                        completion:(ButtonClickedCallback)completion;

/**无图片、双按钮的弹窗-取消按钮有回调*/
+ (instancetype)showAlertWithTitle:(NSString *)title
                           message:(NSString *)message
                            cancel:(NSString *)cancel
                                ok:(NSString *)ok
                        completion:(ButtonClickedCallback)completion
                    cancelCallback:(ButtonClickedCallback)cancelBlock;

/**无图片、双按钮的弹窗-取消按钮有回调-自定义内容对齐方式*/
+ (instancetype)showAlertWithTitle:(NSString *)title
                           message:(NSString *)message
                            cancel:(NSString *)cancel
                                ok:(NSString *)ok
                 messageAlignmenti:(NSTextAlignment)alignment
                  notAutoHideAlert:(BOOL)notAutoHide
                        completion:(ButtonClickedCallback)completion
                    cancelCallback:(ButtonClickedCallback)cancelBlock;

#pragma mark -
#pragma mark -  2021年会抽奖主题弹窗
+ (instancetype)show2021ThemeAlertWithTitle:(NSString *)title
                                    message:(NSString *)message
                                     cancel:(NSString *)cancel
                                         ok:(NSString *)ok
                                 completion:(ButtonClickedCallback)completion
                             cancelCallback:(ButtonClickedCallback)cancelBlock;

@end
