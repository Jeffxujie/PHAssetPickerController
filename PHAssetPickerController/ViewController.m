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
    //使用最新版本的phasset
    if(sys>=8)
    {
        PHImageCollectionController * phCL =[[PHImageCollectionController alloc] init];
        [phCL getResultWithType:5 andWithSuccess:^(NSArray *result) {
            
            NSLog(@"%ld",result.count);
            
        }];
        
        UINavigationController * phNvc = [[UINavigationController alloc] initWithRootViewController:phCL];
        [self presentViewController:phNvc animated:YES completion:nil];
    }
    //这里就可以调用alasset
    else
    {
        [self presentViewController:[[WBImagePickerController alloc]initWithMaxCount:20 AndWithSelectType:5 completedBlock:^(NSArray *images) {
            
            NSLog(@"%ld",images.count);
            
        }] animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
