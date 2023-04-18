//
//  KVHomeViewController.m
//  KVHomeModule
//
//  Created by MacBook Pro on 2023/4/6.
//

#import "KVHomeViewController.h"
#import "UIView+Frame.h"

@interface KVHomeViewController ()

@end

@implementation KVHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 60, self.view.width, 300);
    [self.view addSubview:imageView];
    
    NSString *path = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"/KVHomeModule.bundle"];
    NSBundle *customBundle = [NSBundle bundleWithPath:path];
    UIImage *image = [UIImage imageNamed:@"dt_bg_top" inBundle:customBundle compatibleWithTraitCollection:nil];
    imageView.image = image;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
