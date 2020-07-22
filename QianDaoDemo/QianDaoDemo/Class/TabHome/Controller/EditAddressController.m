//
//  EditAddressController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2018/10/11.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "EditAddressController.h"
#import "AddressCell.h"

#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>/*正/反向地理编码*/
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>

@interface EditAddressController () <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKPoiSearchDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UIBarButtonItem *leftBarButton;
@property (nonatomic, strong) UIBarButtonItem *rightBarButton;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UIView *mapContainer;//地图视图容器
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *tableDataArray;
@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, strong) BMKPointAnnotation *annotation;//大头针

@end

@implementation EditAddressController
{
    BMKMapView * _mapView;
    BMKLocationService *_locService;
    BMKGeoCodeSearch *_searcher;/*正/反向地理编码*/
    BMKPoiSearch *_poiSearch;/*检索地点*/
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _poiSearch.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.definesPresentationContext = YES;
    
    self.tableDataArray = [[NSMutableArray alloc] initWithArray:self.poiList];
    self.searchResults = [[NSMutableArray alloc] init];
    
    [self initSubviews];
    [self initMapUI];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    UIView *searchView = [self.view viewWithTag:1001];
    searchView.frame = CGRectMake(0, 64, kScreenWidth, 60);
    self.searchController.searchBar.frame = CGRectMake(0, 0, kScreenWidth, 60);
    
    CGFloat mapH = (kScreenHeight - CGRectGetMaxY(searchView.frame)) / 2.0;
    self.mapContainer.frame = CGRectMake(0, CGRectGetMaxY(searchView.frame), kScreenWidth, mapH);
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.mapContainer.frame), kScreenWidth, kScreenHeight - CGRectGetMaxY(self.mapContainer.frame));
}

- (void)initSubviews
{
    self.title = @"地点微调";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = self.leftBarButton;
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    
    UIView *searchView = [[UIView alloc] init];
    searchView.tag = 1001;
    [self.view addSubview:searchView];
    
    [searchView addSubview:self.searchController.searchBar];
    [self.view addSubview:self.mapContainer];
    [self.view addSubview:self.tableView];
}

- (void)initMapUI
{
    /*将地图放到头部视图上*/
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 280)];
    [self.mapContainer addSubview:_mapView];
    [_mapView setMapType:BMKMapTypeStandard];
    
    _locService = [[BMKLocationService alloc] init];
    
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
    [_mapView setZoomLevel:18];
    
    //自定义精度圈
    BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
    param.isAccuracyCircleShow = NO;
    param.locationViewImgName = @"icon_center_point.png";//设置隐藏定位的箭头
    [_mapView updateLocationViewWithParam:param];
    
    _searcher = [[BMKGeoCodeSearch alloc] init];
    _searcher.delegate = self;
    
    _poiSearch = [[BMKPoiSearch alloc] init];
    _poiSearch.delegate = self;
}

#pragma mark - action

- (void)cancelClicked
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)determineClicked
{
    CLLocationCoordinate2D coordinate = self.annotation.coordinate;
    if (self.coordinateBlock) {
        self.coordinateBlock(coordinate);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark -
#pragma mark - 代理方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"tableDataArray.count === %ld", self.tableDataArray.count);
    return self.tableDataArray.count;
    
//    if (self.searchController.active) {
//        return self.searchResults.count;
//    } else {
//        return self.tableDataArray.count;
//    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCellIdentifier" forIndexPath:indexPath];
    
    NSString *addressStr = @"";
    NSString *detailStr = @"";
    
    BMKPoiInfo *pointInfo = self.tableDataArray[indexPath.row];
    addressStr = pointInfo.name;
    detailStr = pointInfo.address;

    
    
//    if (self.searchController.active) {
//        BMKPoiInfo *pointInfo = self.searchResults[indexPath.row];
//        addressStr = pointInfo.name;
//        detailStr = pointInfo.address;
//
//    } else {
//        BMKPoiInfo *pointInfo = self.tableDataArray[indexPath.row];
//        addressStr = pointInfo.name;
//        detailStr = pointInfo.address;
//    }
    
    [cell setCellTitle:addressStr detail:detailStr];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BMKPoiInfo *poi = self.tableDataArray[indexPath.row];
    //更改位置的中心点
    _mapView.centerCoordinate = poi.pt;
    //添加大头针
    self.annotation.coordinate = poi.pt;
    [_mapView addAnnotation:self.annotation];

    
    
//    if (self.searchController.active) {
//        BMKPoiInfo *poi = self.searchResults[indexPath.row];
//        //更改位置的中心点
//        _mapView.centerCoordinate = poi.pt;
//        //添加大头针
//        self.annotation.coordinate = poi.pt;
//        [_mapView addAnnotation:self.annotation];
//
//    } else {
//        BMKPoiInfo *poi = self.tableDataArray[indexPath.row];
//        //更改位置的中心点
//        _mapView.centerCoordinate = poi.pt;
//        //添加大头针
//        self.annotation.coordinate = poi.pt;
//        [_mapView addAnnotation:self.annotation];
//    }
    
}

#pragma mark -
#pragma mark - 搜索框相关代理
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchString = searchBar.text;
    NSLog(@"搜索内容：%@", searchString);
    
    if (searchString.length > 0) {
        //发起检索
        BMKPOINearbySearchOption *option = [[BMKPOINearbySearchOption alloc]init];
        option.pageIndex = 0;
        option.keywords = @[searchString];
        //option.tags = @[@"融科创意中心", @"酒店", @"美食广场", searchString];
        
        //设置检索中心点
        [option setLocation:CLLocationCoordinate2DMake(39.9124987741, 116.2312977251)];
        //设置检索半径
        option.radius = 500;
        //设置严格按照指定半径范围搜索
        option.isRadiusLimit = YES;
        
        BOOL flag = [_poiSearch poiSearchNearBy:option];
        
        if(flag) {
            NSLog(@"周边检索发送成功");
        } else {
            NSLog(@"周边检索发送失败");
        }
    }
}

 - (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    
}

#pragma mark -
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
    [_locService stopUserLocationService];
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

#pragma mark - BMKPoiSearchDelegate

/**搜索地点的回调结果*/
//实现PoiSearchDeleage处理回调结果
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPOISearchResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode
{
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        if (poiResult.poiInfoList) {
            //self.searchResults = [NSMutableArray arrayWithArray:poiResult.poiInfoList];
            
            self.tableDataArray = [NSMutableArray arrayWithArray:poiResult.poiInfoList];
            
            [self.tableView reloadData];
        }
        
    } else if (errorCode == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        // result.cityList;
        NSLog(@"起始点有歧义");
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"搜索地点超出范围" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.searchController.searchBar.text = @"";
            self.searchController.active = NO;
        }];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


/**地图选点，回调解析结果*/
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error
{
    self.tableDataArray = [NSMutableArray arrayWithArray:result.poiList];
    [self.tableView reloadData];
}

#pragma mark - 地图交互相关

- (void)mapview:(BMKMapView *)mapView onLongClick:(CLLocationCoordinate2D)coordinate
{
    self.annotation.coordinate = coordinate;
    [_mapView addAnnotation:self.annotation];
    
    [self showAddress:coordinate];
}

/**根据经纬度获取位置信息*/
- (void)showAddress:(CLLocationCoordinate2D)coordinate
{
    //发起逆地理编码检索
    BMKReverseGeoCodeSearchOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc]init];
    reverseGeoCodeSearchOption.location = coordinate;
    BOOL flag = [_searcher reverseGeoCode:reverseGeoCodeSearchOption];
    
    if(flag) {
        NSLog(@"逆geo检索发送成功");
    } else {
        NSLog(@"逆geo检索发送失败");
    }
}

#pragma mark - lazy loading

- (UIBarButtonItem *)leftBarButton
{
    if (!_leftBarButton) {
        _leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelClicked)];
    }
    return _leftBarButton;
}

- (UIBarButtonItem *)rightBarButton
{
    if (!_rightBarButton) {
        _rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(determineClicked)];
    }
    return _rightBarButton;
}

- (UISearchController *)searchController
{
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.dimsBackgroundDuringPresentation = NO;
        _searchController.hidesNavigationBarDuringPresentation = NO;
        _searchController.searchBar.delegate = self;
        
        _searchController.searchBar.placeholder = @"搜索地点";
        _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        
        //[_searchController.searchBar setBarTintColor:RGB(242, 242, 244)];
        //[_searchController.searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_bar"] forState:UIControlStateNormal];
    }
    return _searchController;
}

- (UIView *)mapContainer
{
    if (!_mapContainer) {
        _mapContainer = [[UIView alloc] init];
    }
    return _mapContainer;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 45;
        _tableView.separatorStyle = NO;
        
        [_tableView registerClass:[AddressCell class] forCellReuseIdentifier:@"AddressCellIdentifier"];
    }
    return _tableView;
}

- (BMKPointAnnotation *)annotation
{
    if (!_annotation) {
        _annotation = [[BMKPointAnnotation alloc] init];
    }
    return _annotation;
}

@end
