# PHAssetPickerController
分为ios8以下的ios8以上

一：PHImageCollectionController
  获取的是ios8以上，系统中相册中的照片和视屏
  使用方法：
  PHImageCollectionController * phCL =[[PHImageCollectionController alloc] init];
        [phCL getResultWithType:5 andWithSuccess:^(NSArray *result) {
            
            NSLog(@"%ld",result.count);
            
        }];
        
  UINavigationController * phNvc = [[UINavigationController alloc] initWithRootViewController:phCL];
  [self presentViewController:phNvc animated:YES completion:nil];
  
  二：WBImagePickerController
  获取的是ios8以下，系统相册中的照片和视频
  [self presentViewController:[[WBImagePickerController alloc]initWithMaxCount:20 AndWithSelectType:5 completedBlock:^(NSArray *images) {
            
            NSLog(@"%ld",images.count);
            
  }] animated:YES completion:nil];
