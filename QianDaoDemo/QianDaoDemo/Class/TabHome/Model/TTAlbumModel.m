//
//  TTAlbumModel.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/6/24.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import "TTAlbumModel.h"

@implementation TTAlbumModel

- (void)setCollection:(PHAssetCollection *)collection
{
    _collection = collection;
    
    if ([collection.localizedTitle isEqualToString:@"All Photos"]) {
        self.collectionTitle = @"全部相册";
    } else {
        self.collectionTitle = collection.localizedTitle;
    }
    
    self.collectionTitle = collection.localizedTitle;
    
    // 获得某个相簿中的所有PHAsset对象
    self.assets = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    
    if (self.assets.count > 0) {
        self.firstAsset = self.assets.lastObject;
    }
    self.collectionNumber = [NSString stringWithFormat:@"%ld", self.assets.count];
}

@end
