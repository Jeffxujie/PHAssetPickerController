//
//  JYAblumTool.m
//  WBImagePickerPH
//
//  Created by macxu on 2016/11/11.
//  Copyright © 2016年 macxu. All rights reserved.
//

#import "JYAblumTool.h"
#import "PHImageModel.h"

@implementation JYAblumList

@end

@interface JYAblumTool ()

@property (nonatomic,assign) NSInteger type;

@property (nonatomic,copy) comPlateBlock complate;

@end

@implementation JYAblumTool

-(instancetype)initWithType:(NSInteger)type
{
    self = [super init];
    if(self)
    {
        self.type = type;
    }
    return self;
}
#pragma mark - 获取所有相册列表
- (NSArray<JYAblumList *> *)getPhotoAblumList
{
    NSMutableArray<JYAblumList *> *photoAblumList = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //获取所有智能相册
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
            //过滤掉视频和最近删除
            if (([collection.localizedTitle isEqualToString:@"Videos"])||([collection.localizedTitle isEqualToString:@"Recently Deleted"])) {
                NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection ascending:NO];
                if (assets.count > 0) {
                    JYAblumList *ablum = [[JYAblumList alloc] init];
                    ablum.title = [self transformAblumTitle:collection.localizedTitle];
                    ablum.count = assets.count;
                    ablum.headImageAsset = assets.firstObject;
                    ablum.assetCollection = collection;
                    [photoAblumList addObject:ablum];
                }
            }
        }];
        
        //获取用户创建的相册
        PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection ascending:NO];
            if (assets.count > 0) {
                JYAblumList *ablum = [[JYAblumList alloc] init];
                ablum.title = collection.localizedTitle;
                ablum.count = assets.count;
                ablum.headImageAsset = assets.firstObject;
                ablum.assetCollection = collection;
                [photoAblumList addObject:ablum];
            }
        }];
    });
   return photoAblumList;
}

- (NSString *)transformAblumTitle:(NSString *)title
{
    if ([title isEqualToString:@"Slo-mo"]) {
        return @"慢动作";
    } else if ([title isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    } else if ([title isEqualToString:@"Favorites"]) {
        return @"最爱";
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    } else if ([title isEqualToString:@"Videos"]) {
        return @"视频";
    } else if ([title isEqualToString:@"All Photos"]) {
        return @"所有照片";
    } else if ([title isEqualToString:@"Selfies"]) {
        return @"自拍";
    } else if ([title isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    } else if ([title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    } else if ([title isEqualToString:@"Panoramas"]) {
        return @"全景照片";
    }
    return nil;
}

- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
}

#pragma mark - 获取相册内所有照片资源
- (void)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending
                             andWithComplate:(void (^)(NSMutableArray *))complate
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
        //没有授权
        if(status== PHAuthorizationStatusRestricted)
        {
            complate([NSMutableArray new]);
        }
        else if (status==PHAuthorizationStatusDenied)
        {
            complate([NSMutableArray new]);
        }
        else
        {
            NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
            
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
            
            PHAssetMediaType type = self.type==5? PHAssetMediaTypeImage:PHAssetMediaTypeVideo;
            
            PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:type options:option];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    PHAsset *asset = (PHAsset *)obj;
                    NSInteger type = asset.mediaType;
                    
                    //照片
                    if(self.type==5&&type==1)
                    {
                        [assets addObject:asset];
                    }
                    //视频
                    else if (self.type==2&&type==2)
                    {
                        [assets addObject:asset];
                    }
                    
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    complate(assets);
                });
            });
        }
    }];
}

//获取所有的资源文件
-(void)getAllAssetInVideoAblumWithAscending:(BOOL)ascending andWithComplate:(void (^)(NSMutableArray *))complate
{
    //请求授权并且验证是否授权
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
        //没有授权
        if(status== PHAuthorizationStatusRestricted)
        {
            complate([NSMutableArray new]);
        }
        else if (status==PHAuthorizationStatusDenied)
        {
            complate([NSMutableArray new]);
        }
        //已经授权
        else
        {
            NSMutableArray * photos = [[NSMutableArray alloc] init];
            
            NSMutableArray<PHAsset *> *assteAry =[[NSMutableArray alloc] init];
            
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
            
            PHAssetMediaType type = self.type==5? PHAssetMediaTypeImage:PHAssetMediaTypeVideo;
            
            PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:type options:option];
            
            PHFetchResult *resulttt =result;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    PHAsset *assets = (PHAsset *)obj;
                    NSInteger type = assets.mediaType;
                    
                    [assteAry addObject:assets];
                    
                    if(type==1)
                    {
                        //获取照片
                        [[PHImageManager defaultManager] requestImageForAsset:assets targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                            
                            //                    NSLog(@"%@",info);
                            PHImageModel * model = [[PHImageModel alloc] init];
                            NSString * fileName= [[info objectForKey:@"PHImageFileURLKey"] lastPathComponent];
                            NSString * url = [info objectForKey:@"PHImageFileURLKey"];
                            model.imageName=fileName;
                            //                    model.URLInPotoes=[NSURL URLWithString:url];
                            model.URLInPotoes=url;
                            model.phasset=assets;
                            [photos addObject:model];
                            if(resulttt.count==photos.count)
                            {
                                complate(photos);
                            }
                        }];
                    }
                    else if (type==2)
                    {
                        //获取视频
                        [[PHImageManager defaultManager] requestAVAssetForVideo:assets options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                            
                            //这里不能够直接获取到url 所以需要手动去拼接
                            PHImageModel * model = [[PHImageModel alloc] init];
                            model.imageName= [[[info objectForKey:@"PHImageFileSandboxExtensionTokenKey"] componentsSeparatedByString:@";"] lastObject].lastPathComponent;;
                            
                            NSString * url = [[[info objectForKey:@"PHImageFileSandboxExtensionTokenKey"]componentsSeparatedByString:@";"] lastObject];
                            url = [@"file://" stringByAppendingString:url];
                            NSURL* videoURL = [NSURL URLWithString:url];
                            model.url=videoURL;
                            
                            model.phasset=assets;
                            [photos addObject:model];
                            if(resulttt.count==photos.count)
                            {
                                complate(photos);
                            }
                        }];
                    }
                }];
            });
        }
    }];
}

#pragma mark - 获取指定相册内的所有图片
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    NSMutableArray<PHAsset *> *arr = [NSMutableArray array];
    
    PHFetchResult *result = [self fetchAssetsInAssetCollection:assetCollection ascending:ascending];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((PHAsset *)obj).mediaType == PHAssetMediaTypeImage) {
            [arr addObject:obj];
        }
    }];
    return arr;
}

#pragma mark - 获取asset对应的图片
- (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    option.resizeMode = resizeMode;//控制照片尺寸
    //option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    //option.synchronous = YES;
    option.networkAccessAllowed = YES;
    //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        completion(image);
    }];
}
@end
