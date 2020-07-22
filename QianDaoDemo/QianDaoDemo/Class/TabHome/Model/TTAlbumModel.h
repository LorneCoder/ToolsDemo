//
//  TTAlbumModel.h
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/6/24.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTAlbumModel : NSObject

/// 相册
@property (nonatomic, strong) PHAssetCollection *collection;
/// 第一个相片
@property (nonatomic, strong) PHAsset *firstAsset;
/// 该相册中包含的照片集合
@property (nonatomic, strong) PHFetchResult<PHAsset *> *assets;
/// 相册名
@property (nonatomic, copy) NSString *collectionTitle;
/// 总数
@property (nonatomic, copy) NSString *collectionNumber;

@end

NS_ASSUME_NONNULL_END
