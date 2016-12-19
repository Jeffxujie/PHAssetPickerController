//
//  PHImageCollectionController.m
//  WBImagePickerPH
//
//  Created by macxu on 2016/11/10.
//  Copyright © 2016年 macxu. All rights reserved.
//

#import "PHImageCollectionController.h"
#import "WBImageCollectionCell.h"
#import "JYAblumTool.h"
#import "PHImageModel.h"

@interface PHImageCollectionController ()<UICollectionViewDelegate, UICollectionViewDataSource,UIAlertViewDelegate> {
    NSMutableArray *assetsArray;
    NSMutableArray *selectAssets;
}
@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) UIActivityIndicatorView *activity;
@property (weak, nonatomic) PHFetchResult *assetsGroup;
//选择是照片 还是视屏
@property (assign,nonatomic) NSInteger type;

@property (nonatomic,strong) CompletedBlock complate;

@end

@implementation PHImageCollectionController


-(void)getResultWithType:(NSInteger)type andWithSuccess:(void (^)(NSArray *))result
{
    self.type = type;
    self.complate = result;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
}

/**
 *  初始化界面
 */
- (void)initView {
    
    NSString * title = self.type==5? @"照片":@"视频";
    
    self.title=title;
    //选择的照片或者视频
    selectAssets = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定(0)" style:UIBarButtonItemStylePlain target:self action:@selector(endSelectPhoto)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    // 每个item大小
    NSInteger space = 3;
    CGFloat itemSize = (CGRectGetWidth([UIScreen mainScreen].bounds)-3*space)/4;
    layout.itemSize  = CGSizeMake(itemSize, itemSize);
    // 间隙
    layout.minimumInteritemSpacing = space;
    layout.minimumLineSpacing      = space;
    //layout.sectionInset            = UIEdgeInsetsMake(space, space, space, space);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-64) collectionViewLayout:layout];
    
    collectionView.backgroundColor   = [UIColor whiteColor];
    collectionView.delegate          = self;
    collectionView.dataSource        = self;
    [collectionView registerNib:[UINib nibWithNibName:@"WBImageCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCollectionCell"];
    [self.view addSubview:collectionView];
    collectionView.hidden = NO;
    self.collectionView = collectionView;
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activity.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    [self.view addSubview:activity];
    self.activity = activity;
    [self.view addSubview:collectionView];
    [self.activity startAnimating];
    
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithRed:0 green:137/256.0f blue:229/256.0f alpha:1]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [self getAllAssetInPhotoAblumWithAscending:NO];
}

-(void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending
{
    JYAblumTool * tool = [[JYAblumTool alloc] initWithType:self.type];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [tool getAllAssetInPhotoAblumWithAscending:NO andWithComplate:^(NSMutableArray *result) {
            
            if(!result.hash)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                    // 获取APP名称
                    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
                    NSString *appName  = [info objectForKey:@"CFBundleDisplayName"];
                    appName            = appName ? appName : [info objectForKey:@"CFBundleName"];
                    
                    NSString *message  = [NSString stringWithFormat:@"请在系统设置中允许“%@”访问照片!", appName];
                    [[[UIAlertView alloc]initWithTitle:@"无法访问照片" message:message delegate:self cancelButtonTitle:@"我知道了!" otherButtonTitles:nil] show];
                    
                });
            }
            else
            dispatch_async(dispatch_get_main_queue(), ^{
                
                assetsArray=result;
                [self.activity stopAnimating];
                
                [self.collectionView reloadData];
                
            });
        }];
    });
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  结束选择照片
 */
- (void)endSelectPhoto {
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self.activity startAnimating];
    NSMutableArray *photos = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (PHAsset *item in selectAssets) {
            
            if(self.type==5)
            {
                //获取照片
                [[PHImageManager defaultManager] requestImageForAsset:item targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    
//                    NSLog(@"%@",info);
                    PHImageModel * model = [[PHImageModel alloc] init];
                    NSString * fileName= [[info objectForKey:@"PHImageFileURLKey"] lastPathComponent];
                    NSString * url = [info objectForKey:@"PHImageFileURLKey"];
                    model.imageName=fileName;
//                    model.URLInPotoes=[NSURL URLWithString:url];
                    model.phasset=item;
                    model.URLInPotoes=url;
                    [photos addObject:model];
                    
                    if(photos.count==selectAssets.count)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.activity stopAnimating];
                            self.complate(photos);
                            //block回调
                            [self dismissViewControllerAnimated:YES completion:nil];
                        });
                    }
                    
                }];
            }
            else if (self.type==2)
            {
                //获取视频
                [[PHImageManager defaultManager] requestAVAssetForVideo:item options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    
                    PHImageModel * model = [[PHImageModel alloc] init];
//                    AVURLAsset *urlAsset = (AVURLAsset *)asset;
                    model.imageName= [[[info objectForKey:@"PHImageFileSandboxExtensionTokenKey"] componentsSeparatedByString:@";"] lastObject].lastPathComponent;;
                   
                    NSString * url = [[[info objectForKey:@"PHImageFileSandboxExtensionTokenKey"]componentsSeparatedByString:@";"] lastObject];
                    url = [@"file://" stringByAppendingString:url];
                    NSURL* videoURL = [NSURL URLWithString:url];
                    model.url=videoURL;
//                    NSLog(@"%@",[model.URLInPotoes absoluteString]);
                    
                    model.phasset=item;
                    [photos addObject:model];
                    if(photos.count==selectAssets.count)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.activity stopAnimating];
                            self.complate(photos);
                            //block回调
                            [self dismissViewControllerAnimated:YES completion:nil];
                        });
                    }
                }];
            }
        }
    });
}


#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSLog(@"%ld",assetsArray.count);
    return assetsArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WBImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionCell" forIndexPath:indexPath];
    
    PHAsset *asset = [assetsArray objectAtIndex:indexPath.row];
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        [self requestImageForAsset:asset size:CGSizeMake((CGRectGetWidth([UIScreen mainScreen].bounds)-3*3)/4, (CGRectGetWidth([UIScreen mainScreen].bounds)-3*3)/4) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage * image) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
               cell.imageView.image=image;
                
            });
        }];
    });
    
    cell.backgroundColor=[UIColor brownColor];
    cell.selectButton.selected = [selectAssets containsObject:asset];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 把选择的加入数组中
    PHAsset *asset = [assetsArray objectAtIndex:indexPath.row];
    
    if ([selectAssets containsObject:asset]) {
        [selectAssets removeObject:asset];
    } else
    {
        [selectAssets addObject:asset];
    }
    
    self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"确定(%ld)", (unsigned long)selectAssets.count];
    self.navigationItem.rightBarButtonItem.enabled = selectAssets.count ? YES : NO;
    
    WBImageCollectionCell * cell = (WBImageCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectButton.selected = [selectAssets containsObject:asset];
}

#pragma mark - 获取asset对应的图片
- (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage * image))completion
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
