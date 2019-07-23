//
//  BTConnectController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/2/26.
//  Copyright © 2019年 gaojianlong. All rights reserved.
//

#import "BTConnectController.h"

@interface BTConnectController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *table;

@end

@implementation BTConnectController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initSubviews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.table.frame = self.view.bounds;
}

- (void)initSubviews
{
    self.title = @"设备特征";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.table];
}


#pragma mark -
#pragma mark - tableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myCharacteristics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBCharacteristic *item  = self.myCharacteristics[indexPath.row];
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = item.UUID.UUIDString;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBCharacteristic *item  = self.myCharacteristics[indexPath.row];
    
    if (self.selectBlock) {
        self.selectBlock(item);
        [self.navigationController popViewControllerAnimated:YES];
    }
}



- (UITableView *)table
{
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _table.delegate = self;
        _table.dataSource = self;
        
        UIView *footer = [[UIView alloc] init];
        footer.backgroundColor = [UIColor whiteColor];
        _table.tableFooterView = footer;
    }
    return _table;
}

@end
