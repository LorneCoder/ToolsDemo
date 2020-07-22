//
//  SignInController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2018/10/9.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "SignInController.h"
#import "JLDateUtil.h"
#import "EditAddressController.h"

//#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
//#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
//#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
//#import <MapKit/MapKit.h>

#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>/*正/反向地理编码*/

@interface SignInController () <BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>

@property (nonatomic, strong) UILabel *dateLabel;//显示日期
@property (nonatomic, strong) UILabel *addressLabel;//定位地址显示
//@property (nonatomic, strong) UIButton *editBtn;//地址微调
@property (nonatomic, strong) UIView *mapContainer;//地图视图容器
@property (nonatomic, strong) UIButton *signInBtn;//签到
@property (nonatomic, strong) UILabel *signInCount;//签到次数

@property (nonatomic, copy) NSString *latStr;
@property (nonatomic, copy) NSString *lngStr;
@property (nonatomic, copy) NSArray *poiList;

@property (nonatomic, assign) float distance;//签到地点距离公司距离

@end

@implementation SignInController
{
    BMKMapView * _mapView;
    BMKLocationService *_locService;
    BMKGeoCodeSearch *_searcher;/*正/反向地理编码*/
}

#pragma mark -
#pragma mark -  life cycle

- (void)dealloc
{
    if (_mapView) {
        _mapView = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _searcher.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _searcher.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.poiList = [[NSArray alloc] init];
    
    [self initSubviews];
    [self initMapUI];
    
    [self loadData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.dateLabel.frame = CGRectMake(0, 64, kScreenWidth, 60);
    
    UIView *line = [self.view viewWithTag:10001];
    line.frame = CGRectMake(0, CGRectGetMaxY(self.dateLabel.frame), kScreenWidth, 1);
    
    self.addressLabel.frame = CGRectMake(10, CGRectGetMaxY(line.frame), kScreenWidth - 20 - 0, 40);
    //self.editBtn.frame = CGRectMake(CGRectGetMaxX(self.addressLabel.frame), CGRectGetMinY(self.addressLabel.frame), 80, 40);
    self.mapContainer.frame = CGRectMake(0, CGRectGetMaxY(self.addressLabel.frame), kScreenWidth, 200);
    _mapView.frame = CGRectMake(0, 0, kScreenWidth, 200);
    
    UIView *signBottomView = [self.view viewWithTag:10002];
    CGFloat signBottomView_Y = CGRectGetMaxY(self.mapContainer.frame);
    signBottomView.frame = CGRectMake(0, signBottomView_Y, kScreenWidth, kScreenHeight - signBottomView_Y);
    
    self.signInBtn.frame = CGRectMake(0, 0, 100, 100);
    self.signInBtn.center = CGPointMake(CGRectGetWidth(signBottomView.frame) / 2.0, CGRectGetHeight(signBottomView.frame) / 2.0);
    
    self.signInCount.frame = CGRectMake(0, CGRectGetMaxY(self.signInBtn.frame) + 10, kScreenWidth, 30);
}

- (void)initSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"签到";
    
    [self.view addSubview:self.dateLabel];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
    line.tag = 10001;
    line.backgroundColor = RGB(237, 234, 244);
    [self.view addSubview:line];
    
    [self.view addSubview:self.addressLabel];
    //[self.view addSubview:self.editBtn];
    
    [self.view addSubview:self.mapContainer];
    
    //签到的底视图
    UIView *signInBottomView = [[UIView alloc] init];
    signInBottomView.tag = 10002;
    signInBottomView.backgroundColor = RGB(237, 234, 244);
    [self.view addSubview:signInBottomView];
    
    [signInBottomView addSubview:self.signInBtn];
    [signInBottomView addSubview:self.signInCount];
}

- (void)initMapUI
{
    /*将地图放到头部视图上*/
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    [self.mapContainer addSubview:_mapView];
    [_mapView setMapType:BMKMapTypeStandard];
    
    _locService = [[BMKLocationService alloc] init];
    _locService.desiredAccuracy = kCLLocationAccuracyBest;
    [_locService startUserLocationService];
    
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
    [_mapView setZoomLevel:18];
    
    //自定义精度圈
    BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
    param.isAccuracyCircleShow = YES;
    //param.locationViewImgName = @"icon_center_point.png";//设置隐藏定位的箭头
    [_mapView updateLocationViewWithParam:param];
    
    _searcher = [[BMKGeoCodeSearch alloc] init];
    _searcher.delegate = self;
}


- (void)loadData
{
    self.dateLabel.text = [JLDateUtil getCurrentTimes];
    NSString *hourMinutes = [JLDateUtil getCurrentHourMinutes];
    [self.signInBtn setTitle:[NSString stringWithFormat:@"签到\n\n%@", hourMinutes] forState:UIControlStateNormal];
}

#pragma mark - BMKMapViewDelegate

- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
{
    NSLog(@"地图初始化完毕");
}

#pragma mark - BMKLocationServiceDelegate

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
    
    //计算距离
    [self getDistanceWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
    
    [self geoCodeSearch:userLocation.location.coordinate];
}

/**计算两个经纬度之间的距离*/
- (void)getDistanceWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
    CLLocation *orig = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    //畅游大厦的位置
    CLLocation *dist = [[CLLocation alloc] initWithLatitude:39.9158940000 longitude:116.2123840000];
    
    CLLocationDistance metre = [orig distanceFromLocation:dist];
    
    
    
    NSLog(@"距离畅游大厦:%.fm",metre);
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

/**根据坐标获取位置信息*/
- (void)geoCodeSearch:(CLLocationCoordinate2D)coordinate
{
    //地理反编码
    BMKReverseGeoCodeSearchOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc]init];
    reverseGeocodeSearchOption.location = coordinate;
    BOOL flag = [_searcher reverseGeoCode:reverseGeocodeSearchOption];
    
    if(flag) {
        NSLog(@"反geo检索发送成功");
        [_locService stopUserLocationService];
    } else {
        NSLog(@"反geo检索发送失败");
    }
}

#pragma mark - BMKGeoCodeSearchDelegate

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"address:%@----%@",result.addressDetail,result.address);
    
    self.addressLabel.text = result.address;
    self.poiList = result.poiList;    
}

#pragma mark -
#pragma mark - action

- (void)editAddress
{
    EditAddressController *vc = [[EditAddressController alloc] init];
    UINavigationController *navigaC = [[UINavigationController alloc] initWithRootViewController:vc];
    vc.poiList = self.poiList;
    vc.coordinateBlock = ^(CLLocationCoordinate2D coordinate) {
        
        //更改位置的中心点
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_mapView.centerCoordinate = coordinate;
        });
        
        [self geoCodeSearch:coordinate];
    };
    [self presentViewController:navigaC animated:YES completion:nil];
}

- (void)signInAction
{
    NSString *address = self.addressLabel.text;
    NSString *time = [NSString stringWithFormat:@"%@ %@", [JLDateUtil getCurrentTimes], [JLDateUtil getCurrentHourMinutes]];

    NSLog(@"签到地点：%@", address);
    NSLog(@"签到时间：%@", time);
    NSString *message = [NSString stringWithFormat:@"签到地点：%@\n签到时间：%@\n确定签到吗？", address, time];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"签到成功");
        
        UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"提示" message:@"签到成功" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok1 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alert1 addAction:ok1];
        [self presentViewController:alert1 animated:YES completion:nil];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - lazy loading

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.font = [UIFont systemFontOfSize:16];
    }
    return _dateLabel;
}

- (UILabel *)addressLabel
{
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] init];
        _dateLabel.font = [UIFont systemFontOfSize:14];
    }
    return _addressLabel;
}

//- (UIButton *)editBtn
//{
//    if (!_editBtn) {
//        _editBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//        [_editBtn setTitle:@"地址微调" forState:UIControlStateNormal];
//        [_editBtn addTarget:self action:@selector(editAddress) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _editBtn;
//}

- (UIView *)mapContainer
{
    if (!_mapContainer) {
        _mapContainer = [[UIView alloc] init];
    }
    return _mapContainer;
}

- (UIButton *)signInBtn
{
    if (!_signInBtn) {
        _signInBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_signInBtn setBackgroundColor:RGB(26, 145, 231)];
        [_signInBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_signInBtn addTarget:self action:@selector(signInAction) forControlEvents:UIControlEventTouchUpInside];
        [_signInBtn setTitle:@"签到\n\n17:34" forState:UIControlStateNormal];
        
        _signInBtn.titleLabel.numberOfLines = 0;
        _signInBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _signInBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        _signInBtn.layer.cornerRadius = 50;
        _signInBtn.layer.masksToBounds = YES;
    }
    return _signInBtn;
}

- (UILabel *)signInCount
{
    if (!_signInCount) {
        _signInCount = [[UILabel alloc] init];
        _signInCount.font = [UIFont systemFontOfSize:14];
        _signInCount.textAlignment = NSTextAlignmentCenter;
        _signInCount.textColor = RGB(26, 145, 231);
        _signInCount.text = @"你今天已经签到0次";
    }
    return _signInCount;
}

@end
