//
//  CompressedVideo.m
//  IntelligentGateway
//
//  Created by macxu on 16/4/27.
//  Copyright © 2016年 MaiKe. All rights reserved.
//

#import "CompressedVideo.h"

#import <AVFoundation/AVFoundation.h>

@implementation CompressedVideo

//进行视屏压缩 返回存在本地的视屏 resultPath最后一段的
-(void)lowQuailtyWithInputURL:(NSURL*)inputURL resultPath:(NSString *)resultPath
{
     __block NSString * url=nil;
    if(inputURL)
    {
        NSString * filePath = [resultPath.stringByDeletingPathExtension stringByAppendingFormat:@".mp4"];
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
        session.outputURL = [NSURL fileURLWithPath:filePath];

        session.outputFileType = AVFileTypeMPEG4;
        session.shouldOptimizeForNetworkUse = YES;
        
        [session exportAsynchronouslyWithCompletionHandler:^{
            switch (session.status) {
                case AVAssetExportSessionStatusUnknown:
                    [self getResultWithIndex:NO AndWithUrl:filePath];
                    break;
                case AVAssetExportSessionStatusWaiting:
                    [self getResultWithIndex:NO AndWithUrl:filePath];
                    break;
                case AVAssetExportSessionStatusExporting:
                    [self getResultWithIndex:NO AndWithUrl:filePath];
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    url = filePath;
                    [self getResultWithIndex:YES AndWithUrl:filePath];
                    break;
                }
                    break;
                case AVAssetExportSessionStatusFailed:
                    [self getResultWithIndex:NO AndWithUrl:filePath];
                    break;
                case AVAssetExportSessionStatusCancelled:
                    [self getResultWithIndex:NO AndWithUrl:filePath];
                    break;
            }
        }];
    }
}

-(void)getResultWithIndex:(BOOL)flag
               AndWithUrl:(NSString *)url
{

    __weak typeof(self) weakSelf = self;
    __strong typeof(weakSelf) strongSelf=weakSelf;
    if(self.asset)
    {
        strongSelf.IsComplatePressBlock(url,flag,self.asset);
    }
    else
    {
        strongSelf.IsComplatePressBlockPh(url,flag,self.phasset);
    }
}

-(void)lowQuailtyWithInputData:(NSData *)imageData
                   andfilepath:(NSString *)path
{
    if(path&&imageData)
    {
        BOOL isOK=NO;
        
        NSString * savePATH =[[self getNewHomePath] stringByAppendingPathComponent:path.lastPathComponent];
        
        if([imageData writeToFile:[[self getNewHomePath] stringByAppendingPathComponent:path.lastPathComponent] atomically:YES])
        {
            isOK=YES;
        }
        else
        {
            isOK=NO;
        }
        
        __weak typeof(self) weakSelf = self;
        __strong typeof(weakSelf) strongSelf=weakSelf;
        if(strongSelf)
        {
            if(self.phasset)
            {
                strongSelf.IsComplatePressBlockPh(savePATH,isOK,nil);
            }
            else
            {
                strongSelf.IsComplatePressBlock(savePATH,isOK,nil);
            }
        }
    }
}

//保存数据的路径
-(NSString *)getNewHomePath
{
    // 获得此程序的沙盒路径
    NSArray *patchs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString *documentsDirectory = [patchs objectAtIndex:0];
    NSString *fileDirectory = [documentsDirectory stringByAppendingPathComponent:@"cachedata"];
    
    NSFileManager * fileMn = [NSFileManager defaultManager];
    if(![fileMn fileExistsAtPath:fileDirectory])
    {
        if([fileMn createDirectoryAtPath:fileDirectory withIntermediateDirectories:YES attributes:nil error:nil])
        {
            return fileDirectory;
        }
        else
        {
            return @"";
        }
    }
    return fileDirectory;
}

@end
