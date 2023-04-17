//
//  UIViewController+ZSDRouter.m
//  ZhuShiDaMobile
//
//  Created by Kevin_han on 21/12/16.
//  Copyright © 2021年 Kevin_han. All rights reserved.
//

#import "UIViewController+ZSDRouter.h"
#import "ZSDRouterTool.h"
#import <objc/runtime.h>

@implementation UIViewController (ZSDRouter)

static const void *moduleIDKey = &moduleIDKey;

- (NSString *)moduleID
{
    return objc_getAssociatedObject(self, moduleIDKey);
}

- (void)setModuleID:(__kindof NSString *)moduleID
{
    objc_setAssociatedObject(self, moduleIDKey, moduleID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


+ (instancetype)zsdRouterViewController
{
    return [[[self class] alloc] init];
}

+ (instancetype)zsdRouterViewControllerWithJSON:(__kindof NSDictionary *)dic
{
    ZSDRouterOptions *options = [ZSDRouterOptions optionsWithDefaultParams:dic];
    return [ZSDRouterTool configVCWithClass:[self class] options:options];
}

- (void)zsdRouterViewControllerWithJSON:(__kindof NSDictionary *)dic
{
    ZSDRouterOptions *options = [ZSDRouterOptions optionsWithDefaultParams:dic];
    return [ZSDRouterTool configTheVC:self options:options];
}

+ (BOOL)validateTheAccessToOpenWithOptions:(ZSDRouterOptions *)options
{
    return YES;
}

+ (void)handleNoAccessToOpenWithOptions:(ZSDRouterOptions *)options
{
    
}

- (BOOL)zsdRouterSpecialTransformWithTopVC:(__kindof UIViewController *)topVC
{
    return NO;
}

- (RouterTransformVCStyle)zsdRouterTransformStyle
{
    return RouterTransformVCStylePush;
}


- (void)zsdReceiveTopVCMsg:(nullable NSDictionary *)msg
                 complete:(nullable void(^)(id _Nullable result))complete
{
    
}

-(void)setValue:(id)value forUndefinedKey:(__kindof NSString *)key
{
    
}

- (void)zsdRouterRefresh
{

}

- (BOOL)zsdNeedRefresh
{
    return NO;
}

+ (BOOL)zsdIsTabBarItemVC
{
    return NO;
}

+ (NSInteger)zsdTabIndex
{
    return 0;
}

- (void)zsdSendMsgToPreVC:(nullable NSDictionary *)msg
{
    void(^receiveMsgBlock)(id data) = objc_getAssociatedObject(self, ZSDRouterViewControllerReceiveMsgBlockKey);
      if (receiveMsgBlock) {
          receiveMsgBlock(msg);
      }
}


@end
