//
//  UINavigationController+ZSDRouter.m
//  ZhuShiDaMobile
//
//  Created by Kevin_han on 21/12/16.
//  Copyright © 2021年 Kevin_han. All rights reserved.
//

#import "UINavigationController+ZSDRouter.h"
#import <objc/runtime.h>
@implementation UINavigationController (ZSDRouter)
static char isPresentedKey;

- (BOOL)isPresented
{
    return [objc_getAssociatedObject(self, &isPresentedKey) boolValue];
}

- (void)setIsPresented:(BOOL)isPresented
{
objc_setAssociatedObject(self, &isPresentedKey, @(isPresented), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
