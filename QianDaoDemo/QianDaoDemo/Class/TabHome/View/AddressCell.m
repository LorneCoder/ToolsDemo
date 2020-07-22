//
//  AddressCell.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2018/10/12.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "AddressCell.h"

@interface AddressCell()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *detail;
@property (nonatomic, strong) UIView *line;

@end

@implementation AddressCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.title];
        [self.contentView addSubview:self.detail];
        [self.contentView addSubview:self.line];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.title.frame = CGRectMake(10, 5, kScreenWidth - 20, 15);
    self.detail.frame = CGRectMake(10, CGRectGetMaxY(self.title.frame) + 5, kScreenWidth - 20, 15);
    self.line.frame = CGRectMake(0, CGRectGetMaxY(self.detail.frame) + 4.5, kScreenWidth, 0.5);
}


- (void)setCellTitle:(NSString *)title detail:(NSString *)detail
{
    self.title.text = title;
    self.detail.text = detail;
}


- (UILabel *)title
{
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.font = [UIFont systemFontOfSize:14];
    }
    return _title;
}

- (UILabel *)detail
{
    if (!_detail) {
        _detail = [[UILabel alloc] init];
        _detail.font = [UIFont systemFontOfSize:13];
        _detail.textColor = RGB(153, 153, 153);
    }
    return _detail;
}

- (UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = RGB(153, 153, 153);
    }
    return _line;
}

@end
