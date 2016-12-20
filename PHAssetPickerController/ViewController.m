//
//  ViewController.m
//  PHAssetPickerController
//
//  Created by macxu on 2016/12/19.
//  Copyright © 2016年 macxu. All rights reserved.
//

#import "ViewController.h"

#import "PHImageCollectionController.h"

#import "WBImagePickerController.h"

#import "CompressedVideo.h"

#import "CompressedVideo.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton * btn =[[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.view addSubview:btn];
    [btn setBackgroundColor:[UIColor brownColor]];
    [btn addTarget:self action:@selector(blicked) forControlEvents:UIControlEventTouchUpInside];
}

-(void)blicked
{
    NSInteger sys = [[UIDevice currentDevice].systemVersion integerValue];
    
    NSInteger type=5;
    
    //使用最新版本的phasset
    if(sys>=8)
    {
        PHImageCollectionController * phCL =[[PHImageCollectionController alloc] init];
        [phCL getResultWithType:type andWithSuccess:^(NSArray *result) {
            //这里只获取到第一个选项
            if(result.hash)
            {
                NSLog(@"%ld",result.count);
                
                PHImageModel * model =result[0];
                
                CompressedVideo * compre =[[CompressedVideo alloc] init];
                compre.phasset=model.phasset;
                compre.IsComplatePressBlockPh=^(NSString * url,BOOL isComplate,PHAsset * asset)
                {
                    //转换成功 可以直接上传
                    if(isComplate)
                    {
                        NSLog(@"%@",url);
                    }
                    //失败的原因一般都是本地已经存在了转换完成的文件
                    else
                    {
                        NSLog(@"%@",url);
                    }
                };
                if(model.isImage)
                {
                    //这里就可以直接获取到照片的data（由于我们需要断点续传，所以我才需要将文件存到本地,才上传文件）
                    [[PHImageManager defaultManager] requestImageDataForAsset:model.phasset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                        
                        [compre lowQuailtyWithInputData:imageData andfilepath:model.imageName];
                    }];
                }
                else
                {
                    [compre lowQuailtyWithInputURL:model.url resultPath:model.imageName];
                }
            }
            
        }];
        
        UINavigationController * phNvc = [[UINavigationController alloc] initWithRootViewController:phCL];
        [self presentViewController:phNvc animated:YES completion:nil];
    }
    //这里就可以调用alasset
    else
    {
        [self presentViewController:[[WBImagePickerController alloc]initWithMaxCount:20 AndWithSelectType:type completedBlock:^(NSArray *images) {
            
            if(images.hash)
            {
                NSLog(@"%ld",images.count);
                
                PHImageModel * model =images[0];
                
                CompressedVideo * compre =[[CompressedVideo alloc] init];
                compre.phasset=model.phasset;
                compre.IsComplatePressBlock=^(NSString * url,BOOL isComplate,ALAsset * asset)
                {
                    //转换成功 可以直接上传
                    if(isComplate)
                    {
                        NSLog(@"%@",url);
                    }
                    //失败的原因一般都是本地已经存在了转换完成的文件
                    else
                    {
                        NSLog(@"%@",url);
                    }
                };
                if(model.isImage)
                {
                    //这里就可以直接获取到照片的data（由于我们需要断点续传，所以我才需要将文件存到本地,才上传文件）
                    [[PHImageManager defaultManager] requestImageDataForAsset:model.phasset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                        
                        [compre lowQuailtyWithInputData:imageData andfilepath:model.imageName];
                    }];
                }
                else
                {
                    [compre lowQuailtyWithInputURL:model.url resultPath:model.imageName];
                }
            }
        }] animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
