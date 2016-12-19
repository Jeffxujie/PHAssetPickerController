//
//  PHImageModel.h
//  WBImagePickerPH
//
//  Created by macxu on 2016/11/10.
//  Copyright © 2016年 macxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@interface PHImageModel : NSObject
@property (nonatomic,strong) NSDate  * date;

@property (nonatomic,strong) UIImage * image;

@property (nonatomic,strong) NSString * imageName;

@property (nonatomic,assign) BOOL isImage;

@property (nonatomic,strong) NSURL * url;

@property (nonatomic,strong) NSData * data;

@property (nonatomic,strong) NSString * URLInPotoes;

@property (nonatomic,strong) PHAsset * phasset;
@end
