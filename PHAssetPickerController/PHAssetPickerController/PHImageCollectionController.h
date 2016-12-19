//
//  PHImageCollectionController.h
//  WBImagePickerPH
//
//  Created by macxu on 2016/11/10.
//  Copyright © 2016年 macxu. All rights reserved.
//



#import <UIKit/UIKit.h>

#import <Photos/Photos.h>

#import <Foundation/Foundation.h>
typedef void (^CompletedBlock)(NSArray *result);

@interface PHImageCollectionController : UIViewController
/*!
 @brief 获取系统相册中的视屏（照片）
        type:选择文件的类型 5代表照片 2代表视频
        result:成功的回调
 */
-(void)getResultWithType:(NSInteger)type andWithSuccess:(void(^)(NSArray * result))result;

@end
