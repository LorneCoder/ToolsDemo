//
//  EditAddressController.h
//  QianDaoDemo
//
//  Created by gaojianlong on 2018/10/11.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface EditAddressController : UIViewController

@property (nonatomic, copy) NSArray *poiList;

/**回传坐标的block*/
@property (nonatomic, copy) void(^coordinateBlock)(CLLocationCoordinate2D coordinate);

@end
