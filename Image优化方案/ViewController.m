//
//  ViewController.m
//  Image优化方案
//
//  Created by hoc on 2021/10/14.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self image];
}

- (void)image {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(50, 50, 100, 56);
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSLog(@"step 1");
        
        // 获取CGImage
        CGImageRef cgImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://p5.toutiaoimg.com/origin/pgc-image/8a0573373f904abc9d95dd2f237142f4?from=pc"]]].CGImage;

        NSLog(@"step 2  耗时");
        
        // alphaInfo
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImage) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        
        NSLog(@"step 3");

        // bitmapInfo
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;

        // size
        size_t width = CGImageGetWidth(cgImage);
        size_t height = CGImageGetHeight(cgImage);
        
        // context
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, CGColorSpaceCreateDeviceRGB(), bitmapInfo);

        NSLog(@"step 4");
        
        // draw
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);

        NSLog(@"step 5 耗时");
        
        // get CGImage
        cgImage = CGBitmapContextCreateImage(context);
        // into UIImage
        UIImage *newImage = [UIImage imageWithCGImage:cgImage];
        // release
        CGContextRelease(context);
        CGImageRelease(cgImage);

        // back to the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = newImage;
            self.imageView.frame = CGRectMake(50, 50, width / 3, height/3);
        });
    });
    
}


@end
