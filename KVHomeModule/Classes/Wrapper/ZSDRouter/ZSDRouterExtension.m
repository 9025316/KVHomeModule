//
//  ZSDRouterExtension.m
//  ZhuShiDaMobile
//
//  Created by Kevin_han on 21/12/16.
//  Copyright © 2021年 Kevin_han. All rights reserved.
//

#import "ZSDRouterExtension.h"
#import "ZSDRouterHeader.h"
#import "ZSDRouterTool.h"
#import "ZSDJSONHandler.h"
#import <objc/runtime.h>


@implementation ZSDRouterExtension

+ (BOOL)isVerifiedOfWhiteName:(__kindof NSString *)url
{
    return YES;
}

+ (BOOL)isVerifiedOfBlackName:(__kindof NSString *)url
{
    return NO;
}
+ (NSString *)zsdWebURLKey
{
    return @"url";
}

+ (NSString *)privateWebVCClassName
{
    return nil;
}

+ (NSString *)openWebVCClassName
{
    return nil;
}

+ (NSArray *)urlSchemes
{
    return @[@"http",
             @"https",
             @"file",
             @"itms-apps",
             @"app-settings",
             @"tel"];
    
}

+ (NSString *)appTargetName
{
    return nil;
}

+ (NSArray *)specialSchemes
{
    return @[];
}

+ (NSString *)zsdModuleTypeViewControllerKey
{
    return @"ViewController";
}

+ (NSString *)zsdModuleTypeFactoryKey
{
    return @"Factory";
}

+ (NSString *)zsdRouterModuleIDKey
{
    return @"zsdModuleID";
}

+ (NSString *)zsdBrowserOpenKey
{
    return @"browserOpen";
}

+ (UINavigationController *)zsdNaVCInitWithRootVC:(__kindof UIViewController *)vc
{
    UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:vc];
    return naVC;
}

+ (BOOL)openURLWithSpecialSchemes:(NSURL *)url
                            extra:(NSDictionary *)extra
                         complete:(void(^)(id result,NSError *error))completeBlock
{
    if (completeBlock) {
        NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorSystemUnSupportURLScheme userInfo:@{@"msg":@"do not support this scheme of the url"}];
        completeBlock(nil,error);
    }
    return NO;
}

+ (BOOL)otherActionsWithActionType:(__kindof NSString *)actionType
                               URL:(NSURL *)url
                             extra:(__kindof NSDictionary *)extra
                          complete:(void(^)(id result,NSError *error))completeBlock
{
    NSString *moduleID = [url.path substringFromIndex:1];
    NSString *swiftModuleName = [ZSDJSONHandler getSwiftModuleNameWithModuleID:moduleID];
    NSString *targetClassName = [ZSDJSONHandler getTargetWithModuleID:moduleID];
    ZSDRouterOptions *options = [ZSDRouterOptions options];
    options.module = swiftModuleName;
    Class targetClass = nil;
    if (options.module && [options.module isKindOfClass:[NSString class]] && options.module.length > 0) {
        targetClass = NSClassFromString([NSString stringWithFormat:@"%@.%@",options.module,targetClassName]);
    }else{
        targetClass = NSClassFromString(targetClassName);
        if (!targetClass) {
            targetClass = NSClassFromString([NSString stringWithFormat:@"%@.%@",[ZSDRouterExtension appTargetName],targetClassName]);
        }
    }
    
    NSString *funcName = [ZSDJSONHandler getFuncNameWithModuleID:moduleID];
    funcName = [NSString stringWithFormat:@"%@:::",funcName];
    SEL selector = NSSelectorFromString(funcName);
    if (targetClass && [targetClass respondsToSelector:selector]) {
        IMP imp = [targetClass methodForSelector:selector];
        void (*func)(id, SEL, id, id, id) = (void *)imp;
        func(targetClass, selector, url, extra,completeBlock);
        return YES;
    }
    
    if (completeBlock) {
        NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorUnSupportAction userInfo:@{@"msg":@"do not support this action"}];
        completeBlock(nil,error);
    }
    return NO;
}

+ (BOOL)zsdSwitchTabClass:(Class)targetClass
                 options:(ZSDRouterOptions *)options
                complete:(void(^)(id result,NSError *error))completeBlock
{
    UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        NSInteger index = [targetClass zsdTabIndex];
        UITabBarController *tabBarVC = (UITabBarController *)rootVC;
        if ([tabBarVC.selectedViewController isKindOfClass:[UINavigationController class]]) {
            NSArray *vcArray = tabBarVC.viewControllers;
            UINavigationController *naVC = vcArray[index];
            [naVC popToRootViewControllerAnimated:YES];
            tabBarVC.selectedIndex = index;

        }else{
            tabBarVC.selectedIndex = index;
        }
        if (completeBlock) {
            completeBlock(nil,nil);
        }
        return YES;
    }
    if (completeBlock) {
        NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorUnSupportSwitchTabBar userInfo:@{@"msg":@"do not support switch tabbar"}];
        completeBlock(nil,error);
    }
    return NO;
}

@end
