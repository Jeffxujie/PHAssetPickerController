//
//  CompressedVideo.h
//  IntelligentGateway
//
//  Created by macxu on 16/4/27.
//  Copyright © 2016年 MaiKe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface CompressedVideo : NSObject

///ios8以下调用的回调方法
@property (nonatomic,copy) void (^IsComplatePressBlock)(NSString * url,BOOL isComplate,ALAsset * asset);
///ios8以上调用的回调方法
@property (nonatomic,copy) void(^IsComplatePressBlockPh)(NSString * url,BOOL isComplate,PHAsset * asset);

@property (nonatomic,strong) PHAsset * phasset;

@property (nonatomic,strong) ALAsset * asset;

///进行视屏压缩
-(void)lowQuailtyWithInputURL:(NSURL*)inputURL resultPath:(NSString *)resultPath;

///保存照片到本地 再上传照片
-(void)lowQuailtyWithInputData:(NSData *)imageData andfilepath:(NSString *)path;

@end
