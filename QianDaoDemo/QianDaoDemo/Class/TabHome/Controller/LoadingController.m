//
//  LoadingController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2018/12/27.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "LoadingController.h"
#import "SVProgressHUD.h"

@interface LoadingController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, copy) NSArray *dataArray;

@end

@implementation LoadingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"loading";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dataArray = @[@"转圈", @"进度", @"文字", @"纯文字", @"错误"];
    [self.view addSubview:self.table];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
            [SVProgressHUD show];
            break;
        }
        case 1:
        {
            [SVProgressHUD showProgress:0.5];
            break;
        }
        case 2:
        {
            [SVProgressHUD showWithStatus:@"你好啊哈哈哈哈哈啊哈哈哈哈哈啊哈哈哈哈哈啊哈哈哈哈哈啊哈哈哈哈哈"];
            break;
        }
        case 3:
        {
            [SVProgressHUD showImage:nil status:@"你好啊哈哈哈哈哈啊哈哈哈哈哈你好啊哈哈哈哈哈啊哈哈哈哈哈"];
            break;
        }
        case 4:
        {
            [SVProgressHUD showErrorWithStatus:@"错了吧"];
            break;
        }

            
        default:
            break;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    
}

- (UITableView *)table
{
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _table.delegate = self;
        _table.dataSource = self;
    }
    return _table;
}

@end
