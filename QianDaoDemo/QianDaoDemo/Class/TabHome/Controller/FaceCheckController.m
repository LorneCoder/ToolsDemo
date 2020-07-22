//
//  FaceCheckController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/9/20.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import "FaceCheckController.h"

#define WeakSelf(type)      __weak typeof(type) weak##type = type;

@interface FaceCheckController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *rightBarBtn;
@property (nonatomic, strong) UIImageView *avatarImg;
@property (strong, nonatomic) UIImagePickerController *picker;

@end

@implementation FaceCheckController
{
    UIImage *selectImage;
    UIImage *originalImg;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"人脸检测";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = self.rightBarBtn;
    [self.view addSubview:self.avatarImg];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.avatarImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.centerY.mas_equalTo(self.view.mas_centerY);
        make.height.mas_equalTo(self.avatarImg.mas_width);
    }];
}

- (void)showCamera
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    WeakSelf(self);
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself takePhotos];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
    [actionSheet addAction:takePhoto];
    [actionSheet addAction:cancel];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

//拍照
- (void)takePhotos
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    self.picker.sourceType = sourceType;
    [self presentViewController:self.picker animated:YES completion:nil];
}


#pragma mark -
#pragma mark - UIPickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    selectImage = image;
    originalImg = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [SVProgressHUD showWithStatus:@"检测中..."];
    
    [self startCheck];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark - 人脸核对

- (void)startCheck
{    
    UIImage *resultImg = [self judgeInPictureContainImage:selectImage];
    
    if (resultImg) {
        //检测通过
        [SVProgressHUD showWithStatus:@"检测通过，上传中..."];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
        });
        
        self.avatarImg.image = originalImg;
        
        //上传照片到服务器
        //[self uploadImageToServer];

    } else {
        [SVProgressHUD showErrorWithStatus:@"未检测到人脸"];
    }
}

/// 图片中是否包含人脸
- (UIImage *)judgeInPictureContainImage:(UIImage *)thePicture
{
    UIImage *newImg;
    UIImage *aImage = thePicture;
    CIImage *image = [CIImage imageWithCGImage:aImage.CGImage];
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh
                                                      forKey:CIDetectorAccuracy];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:opts];
    //得到面部数据
    NSArray* features = [detector featuresInImage:image];
    
    for (CIFaceFeature *f in features)
    {
        CGRect aRect = f.bounds;
        NSLog(@"%f, %f, %f, %f", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
        
        CGRect newRect = CGRectMake(0, 0, aImage.size.width, aImage.size.height);
        float blFloat = 320/320.0;
        newRect.size.width = aImage.size.width;
        float heiFloat = aImage.size.width/(blFloat);
        newRect.size.height = heiFloat;
        
        float zFloat = (aImage.size.height - newRect.size.height)/2.0;
        newRect.origin.y = zFloat;
        
        newImg = [self imageFromImage:aImage inRect:newRect];
        
        //眼睛和嘴的位置
        if(f.hasLeftEyePosition) NSLog(@"Left eye %g %g\n", f.leftEyePosition.x, f.leftEyePosition.y);
        if(f.hasRightEyePosition) NSLog(@"Right eye %g %g\n", f.rightEyePosition.x, f.rightEyePosition.y);
        if(f.hasMouthPosition) NSLog(@"Mouth %g %g\n", f.mouthPosition.x, f.mouthPosition.y);
    }
    
    if(![self judgeChangePictureHaveFace:newImg]){
        newImg = nil;
    }
    return newImg;
}

- (BOOL)judgeChangePictureHaveFace:(UIImage *)thePicture
{
    BOOL result = NO;
    UIImage *aImage = thePicture;
    CIImage *image = [CIImage imageWithCGImage:aImage.CGImage];
    
    NSDictionary  *opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh
                                                      forKey:CIDetectorAccuracy];
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:opts];
    //得到面部数据
    NSArray* features = [detector featuresInImage:image];
    for (CIFaceFeature *f in features){
        result = YES;
        //CGRect aRect = f.bounds;
    }
    
    return result;
}

// 剪切图片
- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect
{
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}



#pragma mark -
#pragma mark - lazy loading

- (UIBarButtonItem *)rightBarBtn
{
    if (!_rightBarBtn) {
        _rightBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"拍照" style:UIBarButtonItemStyleDone target:self action:@selector(showCamera)];
    }
    return _rightBarBtn;
}

- (UIImageView *)avatarImg
{
    if (!_avatarImg) {
        _avatarImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"face_placeholder"]];
        _avatarImg.userInteractionEnabled = YES;
        _avatarImg.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImg.clipsToBounds = YES;
    }
    return _avatarImg;
}

- (UIImagePickerController *)picker
{
    if (!_picker) {
        _picker = [[UIImagePickerController alloc] init];
        _picker.delegate = self;
        _picker.allowsEditing = YES;
        
        _picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    return _picker;
}


@end
