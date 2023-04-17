//
//  HomeViewController.m
//  HomeModule
//
//  Created by MacBook Pro on 2023/4/6.
//

#import "HomeViewController.h"
#import "UIView+Frame.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    UIImageView *imageView = [[UIImageView alloc] init];
//    imageView.image = [UIImage imageNamed:@"dt_bg_top"];
    imageView.frame = CGRectMake(0, 60, self.view.width, 300);
    [self.view addSubview:imageView];
    
    NSString *path = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"/HomeModule.bundle"];
    NSBundle *customBundle = [NSBundle bundleWithPath:path];
    UIImage *image = [UIImage imageNamed:@"dt_bg_top" inBundle:customBundle compatibleWithTraitCollection:nil];
    imageView.image = image;
    
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColor.systemPinkColor;
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(imageView.mas_bottom).offset(8);
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-20);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
