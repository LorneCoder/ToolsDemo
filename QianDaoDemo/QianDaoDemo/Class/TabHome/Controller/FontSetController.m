//
//  FontSetController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/11/12.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import "FontSetController.h"
#import <objc/runtime.h>
#import "UIView+Subviews.h"

@interface FontSetController () <UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) UISearchController *searchControl;
@property (nonatomic, assign) BOOL isFirstCall;

@end

@implementation FontSetController

- (void)dealloc
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"字体设置";
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, kScreenWidth - 40, 40)];
    label.backgroundColor = [UIColor orangeColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"自定义的字体";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"FZLBJW--GB1-0" size:16];
    [self.view addSubview:label];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 180, kScreenWidth - 40, 40);
    btn.backgroundColor = [UIColor orangeColor];
    [btn setTitle:@"这是一个按钮" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:@"FZLBJW--GB1-0" size:16];
    [self.view addSubview:btn];
    
    [self searchFontName];
    
    [self initSearchController];
}

- (void)searchFontName
{
    for (NSString *familyName in [UIFont familyNames]) {
          NSLog(@"Font FamilyName = %@",familyName); //*输出字体族科名字

          for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
              NSLog(@"\t%@",fontName);         //*输出字体族科下字样名字
          }
      }
}

- (void)initSearchController
{
    UISearchController *searchControl = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchControl = searchControl;
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = self.searchControl;
        self.navigationItem.hidesSearchBarWhenScrolling = NO; // 默认是YES
    }
    self.definesPresentationContext = YES;
    
    searchControl.delegate = self;
    searchControl.searchResultsUpdater = self;
    searchControl.searchBar.delegate = self;
    searchControl.obscuresBackgroundDuringPresentation = NO;
    searchControl.dimsBackgroundDuringPresentation = NO;
    searchControl.searchBar.searchBarStyle = UISearchBarStyleDefault;
    searchControl.searchBar.backgroundColor = [UIColor whiteColor];
    searchControl.searchBar.tintColor = [UIColor blackColor];

    if (@available(iOS 13.0, *)) {
        self.isFirstCall = YES;
        searchControl.searchBar.tintColor = [UIColor whiteColor];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DidShowKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    } else {
        [searchControl.searchBar setValue:@"完成" forKey:@"_cancelButtonText"];
    }
    
    
    /*
    if (@available(iOS 13.0, *)) {
        searchControl.searchBar.searchTextField.textColor = [UIColor whiteColor];
    } else {
        //UITextField *textField = (UITextField *)[searchControl.searchBar valueForKey:@"_searchField"];
        //textField.textColor = [UIColor whiteColor];
        //textField.text = @"哈哈哈哈";
        //[textField setValue:[UIColor whiteColor] forKey:@"_textColor"];
        
        for (UIView *view in searchControl.searchBar.subviews.lastObject.subviews) {
            if ([view isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                UITextField *textField = (UITextField *)view;
                textField.placeholder = @"hhahah";
                textField.textColor = [UIColor whiteColor];
            }
        }
    }
     */
}




- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    NSLog(@"搜索：%@", searchString);
}

- (void)willShowKeyboard:(NSNotification *)notify
{
    NSLog(@"即将显示");
}

- (void)DidShowKeyboard:(NSNotification *)notify
{
    if (@available(iOS 13.0, *)) {
        if (self.isFirstCall) {
            for (id view in [[[[[self.searchControl.searchBar subviews] objectAtIndex:0] subviews] lastObject] subviews]) {
                if ([view isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
                    UIButton *searchBtn = (UIButton *)view;
                    [searchBtn setTitle:@"完成" forState:UIControlStateNormal];
                    [searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    self.isFirstCall = NO;
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.searchControl.searchBar.tintColor = [UIColor blackColor];
                    });
                }
            }
        }
    }
}






- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self showPrivateProperties];
    
}

- (void)showPrivateProperties
{
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList([self.searchControl.searchBar class], &outCount);
    
    for (NSInteger i = 0; i < outCount; ++i) {
        // 遍历取出该类成员变量
        Ivar ivar = *(ivars + i);
        
        NSLog(@"\n name = %s  \n type = %s", ivar_getName(ivar),ivar_getTypeEncoding(ivar));
    }
    
    // 根据内存管理原则释放指针
    free(ivars);
}

- (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
