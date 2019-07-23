//
//  PhotoKitController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/6/19.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import "PhotoKitController.h"
#import <Photos/Photos.h>
#import "TTAlbumModel.h"

@interface PhotoKitController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) PHFetchOptions *options;
@property (nonatomic, strong) PHImageRequestOptions *thumbnailOpions;

@end

@implementation PhotoKitController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"选择照片";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.table];
    self.dataArray = [NSMutableArray array];

    [self loadPhotoGroups];
}

- (void)loadPhotoGroups
{
    // 获得全部相片
    PHFetchResult<PHAssetCollection *> *cameraRolls = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    // 获得个人收藏相册
    PHFetchResult<PHAssetCollection *> *favoritesCollection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumFavorites options:nil];
    // 获得屏幕快照
    PHFetchResult<PHAssetCollection *> *screenCollection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots options:nil];
    // 获得用户创建的相册
    PHFetchResult<PHAssetCollection *> *topLevelUserCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];

    
    for (PHAssetCollection *collection in cameraRolls) {
        TTAlbumModel *model = [[TTAlbumModel alloc] init];
        model.collection = collection;
        
        [self.dataArray addObject:model];
    }

    for (PHAssetCollection *collection in favoritesCollection) {
        TTAlbumModel *model = [[TTAlbumModel alloc] init];
        model.collection = collection;
        
        [self.dataArray addObject:model];
    }

    for (PHAssetCollection *collection in screenCollection) {
        TTAlbumModel *model = [[TTAlbumModel alloc] init];
        model.collection = collection;
        
        [self.dataArray addObject:model];
    }
    
    for (PHAssetCollection *collection in topLevelUserCollections) {
        TTAlbumModel *model = [[TTAlbumModel alloc] init];
        model.collection = collection;
        
        [self.dataArray addObject:model];
    }
    
    [self.table reloadData];
}

#pragma mark -
#pragma mark - tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"DDAlbumsCellIdentifier";
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    TTAlbumModel *model = self.dataArray[indexPath.row];
    NSString *titleStr = [NSString stringWithFormat:@"%@（%@）", model.collectionTitle, model.collectionNumber];
    cell.textLabel.text = titleStr;
    
    PHAsset *thumbnail = model.firstAsset;
    [[PHImageManager defaultManager] requestImageForAsset:thumbnail targetSize:CGSizeMake(80, 80) contentMode:PHImageContentModeDefault options:self.thumbnailOpions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        NSLog(@"获取的图片：%@", result);
        cell.imageView.image = result;
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark -
#pragma mark - 懒加载

- (UITableView *)table
{
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _table.delegate = self;
        _table.dataSource = self;
        _table.rowHeight = 60;
    }
    return _table;
}


- (PHFetchOptions *)options
{
    if (!_options) {
        _options = [[PHFetchOptions alloc] init];
        _options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    }
    return _options;
}

- (PHImageRequestOptions *)thumbnailOpions
{
    if (!_thumbnailOpions) {
        _thumbnailOpions = [[PHImageRequestOptions alloc] init];
        _thumbnailOpions.resizeMode = PHImageRequestOptionsResizeModeExact;
    }
    return _thumbnailOpions;
}

@end
