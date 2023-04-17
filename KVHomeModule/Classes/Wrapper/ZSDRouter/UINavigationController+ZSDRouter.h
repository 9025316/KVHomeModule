//
//  UINavigationController+ZSDRouter.h
//  ZhuShiDaMobile
//
//  Created by Kevin_han on 21/12/16.
//  Copyright © 2021年 Kevin_han. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (ZSDRouter)
/// 是否作为一个vc，被别的导航栏presented显示出来
@property (nonatomic, assign) BOOL isPresented;

@end
