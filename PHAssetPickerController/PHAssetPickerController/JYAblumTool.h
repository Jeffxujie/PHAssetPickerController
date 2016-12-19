//
//  JYAblumTool.h
//  WBImagePickerPH
//
//  Created by macxu on 2016/11/11.
//  Copyright © 2016年 macxu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^comPlateBlock)(NSMutableArray * result);

//这里要引入系统库
#import <Photos/Photos.h>
//建一个内部类
@interface JYAblumList : NSObject
@property (nonatomic, copy) NSString *title; //相册名字
@property (nonatomic, assign) NSInteger count; //该相册内相片数量
@property (nonatomic, strong) PHAsset *headImageAsset; //相册第一张图片缩略图
@property (nonatomic, strong) PHAssetCollection *assetCollection; //相册集，通过该属性获取该相册集下所有照片
@end

@interface JYAblumTool : NSObject

/**
 * @brief 5表示照片 2表示视屏
 */
-(instancetype)initWithType:(NSInteger)type;

/**
 * @brief 获取用户所有相册列表
 */
- (NSArray<JYAblumList *> *)getPhotoAblumList;


/**
 * @brief 获取相册内所有图片或视频资源
 * @param ascending 是否按创建时间正序排列 YES,创建时间正（升）序排列; NO,创建时间倒（降）序排列
 */
- (void)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending
                             andWithComplate:(void(^)(NSMutableArray * result))complate;

-(void)getAllAssetInVideoAblumWithAscending:(BOOL)ascending andWithComplate:(void (^)(NSMutableArray * result))complate;

/**
 * @brief 获取指定相册内的所有图片
 */
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending;


/**
 * @brief 获取每个Asset对应的图片
 */
- (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *image))completion;

@end
