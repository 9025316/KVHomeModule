//
//  ZSDRouter.m
//  ZhuShiDaMobile
//
//  Created by Kevin_han on 21/12/16.
//  Copyright © 2021年 Kevin_han. All rights reserved.
//

#import "ZSDRouter.h"
#import "UINavigationController+ZSDRouter.h"
#import "ZSDRouterTool.h"
#import "ZSDRouterExtension.h"
#import <objc/runtime.h>

//**********************************************************************************
//*
//*           ZSDRouter类
//*
//**********************************************************************************

@interface ZSDRouter()
/// 存储路由，moduleID信息，权限配置信息
@property (nonatomic, strong, readwrite) NSMutableSet * modules;
/// 路由配置信息的json文件名数组
@property (nonatomic, copy) NSArray<NSString *> *routerFileNames;
/// 支持的URL协议集合
@property (nonatomic, strong) NSSet *urlSchemes;
/// 从网络上下载的路由配置信息的json文件保存在沙盒中的路径
@property (nonatomic, copy) NSString *remoteFilePath;
@property (nonatomic, strong) NSLock *lock;
/// app的最顶部的控制器
@property (nonatomic, weak, readwrite) UIViewController *topVC;
/// app次顶部的控制器
@property (nonatomic, weak) UIViewController *lastTopVC;
/// 从rootVC到topVC正常情况总共需要open几次
@property (nonatomic, assign) NSUInteger totalSteps;

@end

@implementation ZSDRouter

/**
 初始化单例
 
 @return ZSDRouter 的单例对象
 */
+ (instancetype)sharedRouter
{
    static ZSDRouter *defaultRouter =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultRouter = [[self alloc] init];
        defaultRouter.lock = [[NSLock alloc] init];
    });
    return defaultRouter;
}

- (UIViewController *)topVC
{
    UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarVC = (UITabBarController *)rootVC;
        UIViewController *vc = tabBarVC.selectedViewController;
        return [self _findTopVC:vc];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]) {
        return [self _findTopVC:rootVC];
    }
    return rootVC;
}

- (NSUInteger)totalSteps
{
    NSUInteger totalSteps = 0;
    UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIViewController *tmpVC = rootVC;
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarVC = (UITabBarController *)rootVC;
        UIViewController *tmpVC = tabBarVC.selectedViewController;
        return [self _getTotalStepFromVC:tmpVC originSteps:totalSteps];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]) {
        return [self _getTotalStepFromVC:tmpVC originSteps:totalSteps];
    }
    return totalSteps;
}

- (__kindof UIViewController *)lastTopVC
{
    UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIViewController *lastTopVC = nil;
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarVC = (UITabBarController *)rootVC;
        UIViewController *vc = tabBarVC.selectedViewController;
        return [self _findLastTopVC:vc lastTopVC:lastTopVC];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]) {
        return [self _findLastTopVC:rootVC lastTopVC:lastTopVC];
    }
    return lastTopVC;
}

+ (void)configWithRouterFiles:(__kindof NSArray<NSString *> *)routerFileNames
{
    [ZSDRouter sharedRouter].routerFileNames = routerFileNames;
    NSMutableSet *urlSchemesSet = [NSMutableSet setWithArray:[ZSDRouterExtension urlSchemes]];
    [urlSchemesSet addObjectsFromArray:[ZSDRouterExtension specialSchemes]];
    [ZSDRouter sharedRouter].urlSchemes = [urlSchemesSet copy];
}

+ (void)updateRouterInfoWithFilePath:(__kindof NSString*)filePath
{
    [ZSDRouter sharedRouter].remoteFilePath = filePath;
    [ZSDRouter sharedRouter].modules = nil;
}

- (NSMutableSet *)modules
{
    if (!_modules) {
        [_lock lock];
        _modules = [NSMutableSet new];
        if (!_remoteFilePath) {
            NSArray *moudulesArr = [ZSDJSONHandler getModulesFromJsonFile:[ZSDRouter sharedRouter].routerFileNames];
            [_modules addObjectsFromArray: moudulesArr];
        }else{
            NSData *data = [NSData dataWithContentsOfFile:_remoteFilePath];
            NSArray *modules = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (modules.count>0) {
                [_modules addObjectsFromArray:modules];
            }
        }
        [_lock unlock];
    }
    return _modules;
}

#pragma mark  - - - - the open functions - - - -
+ (BOOL)open:(__kindof NSString *)targetClassName
{
    return [self open:targetClassName params:nil];
}

+ (BOOL)open:(__kindof NSString *)targetClassName
      params:(nullable __kindof NSDictionary *)params
{
    ZSDRouterOptions *options = [ZSDRouterOptions optionsWithDefaultParams:params];
    return [self open:targetClassName options:options];
}

+ (BOOL)open:(__kindof NSString *)targetClassName
     options:(nullable ZSDRouterOptions *)options
{
    return [self open:targetClassName options:options complete:nil];
}

+ (BOOL)open:(__kindof NSString *)targetClassName
     options:(nullable ZSDRouterOptions *)options
    complete:(nullable void(^)(id result,NSError *error))completeBlock
{
    if (!targetClassName || ([targetClassName isKindOfClass:[NSString class]] && targetClassName.length == 0)) {
        NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorClassNameIsNil userInfo:@{@"msg":@"targetClassName is nil or targetClassName is not a string"}];
        if (completeBlock) {
            completeBlock(nil,error);
        }
        return NO;
    }
    if (!options) {
        options = [ZSDRouterOptions options];
    }
    
    Class targetClass = nil;
    if (options.module && [options.module isKindOfClass:[NSString class]] && options.module.length > 0) {
        targetClass = NSClassFromString([NSString stringWithFormat:@"%@.%@",options.module,targetClassName]);
    }else{
        targetClass = NSClassFromString(targetClassName);
        if (!targetClass) {
        targetClass = NSClassFromString([NSString stringWithFormat:@"%@.%@",[ZSDRouterExtension appTargetName],targetClassName]);
        }
    }
    if (!targetClass) {
        if (completeBlock) {
            NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorClassNil userInfo:@{@"msg":@"targetClass is nil"}];
            completeBlock(nil,error);
        }
        return NO;
    }
   return [self openWithClass:targetClass options:options complete:completeBlock];
}

+ (BOOL)openWithClass:(Class)targetClass
              options:(nullable ZSDRouterOptions *)options
{
    return [self openWithClass:targetClass options:options complete:nil];
}

+ (BOOL)openWithClass:(Class)targetClass
              options:(nullable ZSDRouterOptions *)options
             complete:(nullable void(^)(id result,NSError *error))completeBlock
{
    if ([targetClass respondsToSelector:@selector(zsdIsTabBarItemVC)] && [targetClass zsdIsTabBarItemVC]) {
        return [ZSDRouterExtension zsdSwitchTabClass:targetClass options:options complete:completeBlock];
    }else{
        //根据配置好的VC，options配置进行跳转
        return [self routerViewControllerWithClass:targetClass options:options complete:completeBlock];
    }
}

+ (BOOL)openSpecifiedVC:(__kindof UIViewController *)vc
                options:(nullable ZSDRouterOptions *)options
               complete:(nullable void(^)(id result,NSError *error))completeBlock
{
    if (!options) {
        options = [ZSDRouterOptions options];
    }
    Class vcClass = [vc class];
    if (![vcClass  validateTheAccessToOpenWithOptions:options]) {//权限不够进行别的操作处理
        //根据具体的权限设置决定是否进行跳转，如果没有权限，跳转中断，进行后续处理
        [vcClass handleNoAccessToOpenWithOptions:options];
        if (completeBlock) {
            NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorNORightToAccess userInfo:@{@"msg":@"do not have  access to open this vc"}];
            completeBlock(nil,error);
        }
        return NO;
    }
    
   return [self _transformVC:vc options:options complete:completeBlock];
}

+ (BOOL)URLOpen:(__kindof NSString *)url
{
     return [self URLOpen:url extra:nil];
}

+ (BOOL)URLOpen:(__kindof NSString *)url
          extra:(nullable NSDictionary *)extra
{
    return [self URLOpen:url extra:extra complete:nil];
}

+ (BOOL)URLOpen:(__kindof NSString *)url
          extra:(nullable __kindof NSDictionary *)extra
       complete:(nullable void(^)(id result,NSError *error))completeBlock
{
    if(!url){
        if(completeBlock){
            NSError * error = [NSError errorWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorURLIsNil userInfo:@{@"message":@"url can not be nil"}];
            completeBlock(nil,error);
        }
        return NO;
    }
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *targetURL = [NSURL URLWithString:url];// NSURL必须编码
    NSString *scheme = targetURL.scheme;
    if (![[ZSDRouter sharedRouter].urlSchemes containsObject:scheme]) {
        if(completeBlock){
            NSError * error = [NSError errorWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorSystemUnSupportURLScheme userInfo:@{@"message":@"do not support this scheme of the url"}];
            completeBlock(nil,error);
        }
        return NO;
    }
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        return [self httpOpen:targetURL extra:extra complete:completeBlock];
    }
    if ([scheme isEqualToString:@"file"]) {
        return [self jumpToSandBoxWeb:url extra:extra complete:completeBlock];
    }
    if ([scheme isEqualToString:@"itms-apps"] || [scheme isEqualToString:@"app-settings"] || [scheme isEqualToString:@"tel"]) {
       return [self openExternal:targetURL complete:completeBlock];
        
    }
    if ([[ZSDRouterExtension specialSchemes] containsObject:scheme]) {
       return [ZSDRouterExtension openURLWithSpecialSchemes:targetURL extra:extra complete:completeBlock];
    }
    NSString *moduleID = [targetURL.path substringFromIndex:1];
    NSString *type = [ZSDJSONHandler getTypeWithModuleID:moduleID];
    
    if ([type isEqualToString:[ZSDRouterExtension zsdModuleTypeViewControllerKey]]) {
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
        if (!targetClass) {
            if (completeBlock) {
                NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorClassNil userInfo:@{@"msg":@"targetClass is nil"}];
                completeBlock(nil,error);
            }
            return NO;
        }
        if ([targetClass isSubclassOfClass:[UIViewController class]]) {
            NSString *parameterStr = [[targetURL query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *dic = nil;
            if (parameterStr && [parameterStr isKindOfClass:[NSString class]] && parameterStr.length > 0) {
                dic = [ZSDRouterTool convertUrlStringToDictionary:parameterStr];
                [dic addEntriesFromDictionary:extra];
            }else{
                dic = [NSMutableDictionary dictionaryWithDictionary:extra];
            }
            ZSDRouterOptions *options = [ZSDRouterOptions options];
            options.defaultParams = [dic copy];
            //执行页面的跳转
            return [self openWithClass:targetClass options:options complete:completeBlock];
        }else{//进行特殊路由跳转的操作
            return [ZSDRouterExtension otherActionsWithActionType:type URL:targetURL extra:extra complete:completeBlock];
        }
    }else if ([type isEqualToString:[ZSDRouterExtension zsdModuleTypeFactoryKey]]){
       NSString *factoryClassName = [ZSDJSONHandler getTargetWithModuleID:moduleID];
        NSString *swiftModuleName = [ZSDJSONHandler getSwiftModuleNameWithModuleID:moduleID];
        ZSDRouterOptions *options = [ZSDRouterOptions options];
        options.module = swiftModuleName;
        Class targetClass = nil;
        if (options.module && [options.module isKindOfClass:[NSString class]] && options.module.length > 0) {
            targetClass = NSClassFromString([NSString stringWithFormat:@"%@.%@",options.module,factoryClassName]);
        }else{
            targetClass = NSClassFromString(factoryClassName);
            if (!targetClass) {
                targetClass = NSClassFromString([NSString stringWithFormat:@"%@.%@",[ZSDRouterExtension appTargetName],factoryClassName]);
            }
        }
        if (!targetClass) {
            if (completeBlock) {
                NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorClassNil userInfo:@{@"msg":@"targetClass is nil"}];
                completeBlock(nil,error);
            }
            return NO;
        }
        
        NSString *parameterStr = [[targetURL query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *dic = nil;
        if (parameterStr && [parameterStr isKindOfClass:[NSString class]] && parameterStr.length > 0) {
            dic = [ZSDRouterTool convertUrlStringToDictionary:parameterStr];
            [dic addEntriesFromDictionary:extra];
        }else{
            dic = [NSMutableDictionary dictionaryWithDictionary:extra];
        }
        options.defaultParams = [dic copy];
        if ([targetClass respondsToSelector:@selector(zsdRouterFactoryViewControllerWithJSON:)]) {
            
            return [ZSDRouter routerViewControllerWithClass:targetClass options:options complete:completeBlock];
        }
    }
    else{
        //进行非路由跳转的操作
       return [ZSDRouterExtension otherActionsWithActionType:type URL:targetURL extra:extra complete:completeBlock];
    }
    return NO;
}

+ (BOOL)httpOpen:(NSURL *)url
           extra:(nullable __kindof NSDictionary *)extra
        complete:(nullable void(^)(id result,NSError *error))completeBlock
{
    if ([ZSDRouterExtension isVerifiedOfBlackName:url.absoluteString]) {
        if (completeBlock) {
            NSError * error = [NSError errorWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorBlackNameURL userInfo:@{@"message":@"the url is in blacklist"}];
            completeBlock(nil,error);
        }
        return NO;
    }
    NSString *webContainerName = nil;
    if ([ZSDRouterExtension isVerifiedOfWhiteName:url.absoluteString]) {
        webContainerName = [ZSDRouterExtension privateWebVCClassName];
    }else{
        webContainerName = [ZSDRouterExtension openWebVCClassName];
    }
    NSString *parameterStr = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (parameterStr && parameterStr.length > 0) {
        NSMutableDictionary *dic = [ZSDRouterTool convertUrlStringToDictionary:parameterStr];
        if (dic && [dic isKindOfClass:[NSDictionary class]] && [[dic objectForKey:[ZSDRouterExtension zsdBrowserOpenKey]] isEqualToString:@"1"]) {//在safari打开网页
            [self openExternal:[ZSDRouterTool url:url removeQueryKeys:@[[ZSDRouterExtension zsdBrowserOpenKey]]]];
        } else {
            NSString *key1 = [ZSDRouterExtension zsdBrowserOpenKey];
            url = [ZSDRouterTool url:url removeQueryKeys:@[key1]];
//            NSDictionary *tempParams = @{[ZSDRouterExtension zsdWebURLKey]:url.absoluteString};
            // 因H5中文字符编码会显示编码后字符，此处做了解码处理
            NSDictionary *tempParams = @{[ZSDRouterExtension zsdWebURLKey]:[url.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:tempParams];
            [params addEntriesFromDictionary:extra];
            ZSDRouterOptions *options = [ZSDRouterOptions optionsWithDefaultParams:[params copy]];
            return [self open:webContainerName options:options complete:completeBlock];
        }
    }else{
//        NSDictionary *tempParams = @{[ZSDRouterExtension zsdWebURLKey]:url.absoluteString};
        NSDictionary *tempParams = @{[ZSDRouterExtension zsdWebURLKey]:[url.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:tempParams];
        [params addEntriesFromDictionary:extra];
        ZSDRouterOptions *options = [ZSDRouterOptions optionsWithDefaultParams:[params copy]];
        return [self open:webContainerName options:options complete:completeBlock];
    }
    return NO;
}

+ (BOOL)jumpToSandBoxWeb:(__kindof NSString *)url
                   extra:(nullable __kindof NSDictionary *)extra
                complete:(nullable void(^)(id result,NSError *error))completeBlock
{

    if (!url || (url && ![url isKindOfClass:[NSString class]])) {
        NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorSandBoxPathIsNil userInfo:@{@"msg":@"the sandbox filepath is not exist"}];
        if (completeBlock) {
            completeBlock(nil,error);
        }
        return NO;
    }
    NSDictionary *params = @{[ZSDRouterExtension zsdWebURLKey]:url};
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:params];
    [dic addEntriesFromDictionary:extra];
     ZSDRouterOptions *options = [ZSDRouterOptions optionsWithDefaultParams:[dic copy]];
    NSString *webContainerName = [ZSDRouterExtension privateWebVCClassName];
    return [self open:webContainerName options:options complete:completeBlock];
}

+ (BOOL)openExternal:(NSURL *)targetURL
{
    return [self openExternal:targetURL complete:nil];
}

+ (BOOL)openExternal:(NSURL *)targetURL
            complete:(nullable void(^)(id result,NSError *error))completeBlock
{
    if ([targetURL.scheme isEqualToString:@"http"] ||[targetURL.scheme isEqualToString:@"https"] || [targetURL.scheme isEqualToString:@"itms-apps"] || [targetURL.scheme isEqualToString:@"tel"]) {
        if (@available(iOS 10.0,*)) {
                [[UIApplication sharedApplication] openURL:targetURL options:@{} completionHandler:^(BOOL success) {
                    if (completeBlock) {
                        NSError *error = nil;
                        if (!success) {
                            error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorSystemUnSupportURL userInfo:@{@"msg":@"the  app system can not open this url"}];
                        }
                        completeBlock(nil,error);
                        
                    }
                }];
            return YES;
        }else{
            if ([[UIApplication sharedApplication] canOpenURL:targetURL]) {
                [[UIApplication sharedApplication] openURL:targetURL];
                if (completeBlock) {
                    completeBlock(nil,nil);
                }
                return YES;
            }else{
                
                if (completeBlock) {
                    NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorSystemUnSupportURL userInfo:@{@"msg":@"the  app system can not open this url"}];
                    completeBlock(nil,error);
                }
                return NO;
            }
        }
    }else{
        
        if (completeBlock) {
            NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorSystemUnSupportURLScheme userInfo:@{@"msg":@"do not support this scheme"}];
            completeBlock(nil,error);
        }
        return NO;
        
    }
}

#pragma mark  - - - - the pop functions - - - -

+ (void)pop
{
    [self pop:YES];
}

+ (void)pop:(BOOL)animated
{
    ZSDRouterOptions *options = [ZSDRouterOptions options];
    options.animated = animated;
    [self popWithOptions:options];
}

+ (void)popWithOptions:(nullable ZSDRouterOptions *)options
{
    [self popWithOptions:options complete:nil];
}

+ (void)popWithOptions:(nullable ZSDRouterOptions *)options
              complete:(nullable void(^)(id result,NSError *error))completeBlock
{
    if (!options) {
        options = [ZSDRouterOptions options];
    }
    [self popToSpecifiedVC:nil options:options complete:completeBlock];
}

+ (void)popToSpecifiedVC:(nullable __kindof UIViewController *)vc
{
    [self popToSpecifiedVC:vc animated:YES];
}

+ (void)popToSpecifiedVC:(nullable __kindof UIViewController *)vc
                animated:(BOOL)animated
{
    [self popToSpecifiedVC:vc options:nil animated:YES];
}

+ (void)popToSpecifiedVC:(nullable __kindof UIViewController *)vc
                 options:(ZSDRouterOptions *)options
                animated:(BOOL)animated
{
    if (!options) {
        options = [ZSDRouterOptions options];
    }
    options.animated = animated;
    [self popToSpecifiedVC:vc options:options complete:nil];
}

+ (void)popToSpecifiedVC:(nullable __kindof UIViewController *)vc
                 options:(ZSDRouterOptions *)options
                complete:(void(^)(id result,NSError *error))completeBlock
{
    if (!vc) {
        UIViewController *currentVC = [ZSDRouter sharedRouter].topVC;
        UIViewController *lastTopVC = [ZSDRouter sharedRouter].lastTopVC;
        if ([lastTopVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController *naVC = (UINavigationController *)lastTopVC;
            [ZSDRouterTool configTheVC:naVC.topViewController options:options];
        } else {
            [ZSDRouterTool configTheVC:lastTopVC options:options];
        }
        if (currentVC.navigationController && currentVC.navigationController.viewControllers.count > 1) {
            [currentVC.navigationController popViewControllerAnimated:options.animated];
            if (completeBlock) {
                completeBlock(nil,nil);
            }
        }else if (currentVC.navigationController && currentVC.navigationController.isPresented) {
            UINavigationController *naVC = (UINavigationController *)currentVC;
            [naVC dismissViewControllerAnimated:options.animated completion:^{
                if (completeBlock) {
                    completeBlock(nil,nil);
                }
            }];
        }else if (!currentVC.navigationController) {
            [currentVC dismissViewControllerAnimated:options.animated completion:^{
                if (completeBlock) {
                    completeBlock(nil,nil);
                }
            }];
        } else {
            if (completeBlock) {
                NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorUnSupportPopAtcion userInfo:@{@"msg":@"do not support this pop action"}];
                completeBlock(nil,error);
            }
        }
    }
    else {
        if ([self _isRouterContainVC:vc]) {
            [ZSDRouterTool configTheVC:vc options:options];
            UIViewController *currentVC = nil;
            while (![[ZSDRouter sharedRouter].lastTopVC isEqual:vc]) {
                currentVC = [ZSDRouter sharedRouter].topVC;
                [self pop:NO];
            }
            [self popWithOptions:options complete:completeBlock];
        } else {
            if (completeBlock) {
                NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorNoVCInRouter userInfo:@{@"msg":@"no vc is router"}];
                completeBlock(nil,error);
            }
        }
    }
}

+ (void)popWithSpecifiedModuleID:(__kindof NSString *)moduleID
{
    [self popWithSpecifiedModuleID:moduleID :YES];
}

+ (void)popWithSpecifiedModuleID:(__kindof NSString *)moduleID
                                :(BOOL)animated
{
    ZSDRouterOptions *options = [ZSDRouterOptions options];
    options.animated = animated;
    [self popWithSpecifiedModuleID:moduleID options:options complete:nil];
}

+ (void)popWithSpecifiedModuleID:(__kindof NSString *)moduleID
                         options:(ZSDRouterOptions *)options
                        complete:(void(^)(id result,NSError *error))completeBlock
{
    UIViewController *vc = [self _findVCWithModuleID:moduleID];
    if (vc) {
        if (options) {
            options = [ZSDRouterOptions options];
        }
        [self popToSpecifiedVC:vc options:options complete:completeBlock];
    } else {
        if (completeBlock) {
            NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorNoVCInRouter userInfo:@{@"msg":@"no vc is router"}];
            completeBlock(nil,error);
        }
    }
}

+ (void)popWithStep:(NSUInteger)step
{
    [self popWithStep:step :YES];
}

+ (void)popWithStep:(NSUInteger)step :(BOOL)animated
{
    ZSDRouterOptions *options = [ZSDRouterOptions options];
    options.animated = animated;
    [self popWithStep:step options:options complete:nil];
}

+ (void)popWithStep:(NSUInteger)step
            options:(ZSDRouterOptions *)options
           complete:(void(^)(id result,NSError *error))completeBlock
{
    NSUInteger totalSteps = [ZSDRouter sharedRouter].totalSteps;
    if (step > totalSteps) {
        step = totalSteps;
    }
    UIViewController *vc = [self _findVCWithPopStep:step];
    if (vc) {
        if (options) {
            options = [ZSDRouterOptions options];
        }
        [self popToSpecifiedVC:vc options:options animated:options.animated];
    } else {
        if (completeBlock) {
            NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorNoVCInRouter userInfo:@{@"msg":@"no vc is router"}];
            completeBlock(nil,error);
        }
    }
}

#pragma mark --- the tool functions ---

+ (BOOL)replaceCurrentViewControllerWithTargetVC:(__kindof UIViewController *)targetVC
{
    UIViewController *currentVC = [ZSDRouter sharedRouter].topVC;
    if (!currentVC.navigationController) {
        return NO;
    } else {
        UINavigationController *naVC = currentVC.navigationController;
        if ([[NSThread currentThread] isMainThread]) {
            NSArray *viewControllers = naVC.viewControllers;
            NSMutableArray *vcArray = [NSMutableArray arrayWithArray:viewControllers];
            [vcArray replaceObjectAtIndex:viewControllers.count-1 withObject:targetVC];
            [naVC setViewControllers:[vcArray copy] animated:YES];
            [naVC setViewControllers:[vcArray copy] animated:YES];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *viewControllers = naVC.viewControllers;
                NSMutableArray *vcArray = [NSMutableArray arrayWithArray:viewControllers];
                [vcArray replaceObjectAtIndex:viewControllers.count-1 withObject:targetVC];
                [naVC setViewControllers:[vcArray copy] animated:YES];
                [naVC setViewControllers:[vcArray copy] animated:YES];
            });
        }
        return YES;
    }
    
}


//根据相关的options配置，进行跳转
+ (BOOL)routerViewControllerWithClass:(Class)vcClass
                     options:(ZSDRouterOptions *)options
                    complete:(void(^)(id result,NSError *error))completeBlock
{
    UIViewController *vc = nil;
    if (![vcClass isSubclassOfClass:[UIViewController class]]) {
        if ([vcClass respondsToSelector:@selector(zsdRouterFactoryViewControllerWithJSON:)]) {
            vc = [vcClass zsdRouterFactoryViewControllerWithJSON:options.defaultParams];
            [self bindVC:vc receiveMsgBlock:options.zsd_receiveMsgBlock];
            vcClass = [vc class];
        }else{
            NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorUnSupportRouterClass userInfo:@{@"msg":@"do not support the class in ZSDRouter"}];
            completeBlock(nil,error);
            return NO;
        }
    }
    if (![vcClass validateTheAccessToOpenWithOptions:options]) {//权限不够进行别的操作处理
        //根据具体的权限设置决定是否进行跳转，如果没有权限，跳转中断，进行后续处理
        [vcClass handleNoAccessToOpenWithOptions:options];
        if (completeBlock) {
            NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorNORightToAccess userInfo:@{@"msg":@"do not have  access to open vc"}];
            completeBlock(nil,error);
        }
        return NO;
    }
    if (options.createStyle == RouterCreateStyleRefresh) {
        vc = [ZSDRouter sharedRouter].topVC;
        [self bindVC:vc receiveMsgBlock:options.zsd_receiveMsgBlock];
    } else {
        if (!vc) {
            vc = [vcClass zsdRouterViewControllerWithJSON:options.defaultParams];
            [self bindVC:vc receiveMsgBlock:options.zsd_receiveMsgBlock];
        }
    }
    
   return [self _transformVC:vc options:options complete:completeBlock];
}

+ (BOOL)_transformVC:(__kindof UIViewController *)vc
             options:(ZSDRouterOptions *)options
            complete:(void(^)(id result,NSError *error))completeBlock
{
    if (options.transformStyle == RouterTransformVCStyleDefault) {
        options.transformStyle =  [vc zsdRouterTransformStyle];
    }
    switch (options.transformStyle) {
        case RouterTransformVCStylePush:
        {
            return [self _openWithPushStyle:vc options:options complete:completeBlock];
        }
            break;
        case RouterTransformVCStylePresent:
        {
            return [self _openWithPresentStyle:vc options:options complete:completeBlock];
        }
            break;
        case RouterTransformVCStyleOther:
        {
            return [self _openWithOtherStyle:vc options:options complete:completeBlock];
        }
            break;
            
        default:
            break;
    }
    if (completeBlock) {
        NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorUnSupportTransform userInfo:@{@"msg":@"do not support this transformStyle"}];
        completeBlock(nil,error);
    }
    return NO;
}

+ (BOOL)_openWithPushStyle:(__kindof UIViewController *)vc
                   options:(ZSDRouterOptions *)options
                  complete:(void(^)(id result,NSError *error))completeBlock
{
    if (options.createStyle==RouterCreateStyleNew) {
        UIViewController *currentVC = [ZSDRouter sharedRouter].topVC;
        if ([[currentVC class] isKindOfClass:[UINavigationController class]]) {
            UINavigationController *naVC = (UINavigationController *)currentVC;
            [naVC pushViewController:vc animated:options.animated];
            if (completeBlock) {
                completeBlock(nil,nil);
            }
            return YES;
        } else if (currentVC.navigationController) {
            UINavigationController *naVC = (UINavigationController *)currentVC.navigationController;
            [naVC pushViewController:vc animated:options.animated];
            if (completeBlock) {
                completeBlock(nil,nil);
            }
            return YES;
        } else {
            if (currentVC.presentingViewController) {
                [currentVC.presentingViewController dismissViewControllerAnimated:NO completion:^{
                   [self _openWithPushStyle:vc options:options complete:completeBlock];
                }];
            }
        }
        if (completeBlock) {
            NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorUnSupportPushTransform userInfo:@{@"msg":@"do not support push tranform"}];
            completeBlock(nil,error);
        }
        return NO;
        
    }else if (options.createStyle==RouterCreateStyleReplace) {
      BOOL status = [self replaceCurrentViewControllerWithTargetVC:vc];
        if (completeBlock) {
            if (!status) {
                 NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorUnSupportReplaceTransform userInfo:@{@"msg":@"do not support replace tranform"}];
                completeBlock(nil,error);
            }else{
              completeBlock(nil,nil);
            }
        }
        return status;
    }else if (options.createStyle==RouterCreateStyleRefresh) {
        UIViewController *currentVC = [ZSDRouter sharedRouter].topVC;
        if ([currentVC isEqual:vc]) {
            [currentVC zsdRouterRefresh];
            if (completeBlock) {
                completeBlock(nil,nil);
            }
            return YES;
        }else{
            options.transformStyle = RouterTransformVCStyleDefault;
            return [self _transformVC:vc options:options complete:completeBlock];
        }
    }
    if (completeBlock) {
        NSError *error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorUnSupportTransform userInfo:@{@"msg":@"do not support this create style"}];
        completeBlock(nil,error);
    }
    return NO;
}

+ (BOOL)_openWithPresentStyle:(__kindof UIViewController *)vc
                      options:(ZSDRouterOptions *)options
                     complete:(void(^)(id result,NSError *error))completeBlock
{
    if (options.createStyle == RouterCreateStyleNewWithNaVC) {
        
        UINavigationController *naVC = [ZSDRouterExtension zsdNaVCInitWithRootVC:vc];
        naVC.modalPresentationStyle = options.presentStyle;
        naVC.isPresented = YES;
        [[ZSDRouter sharedRouter].topVC presentViewController:naVC animated:options.animated completion:nil];
        if (completeBlock) {
            completeBlock(nil,nil);
        }
        return YES;
    }else{
        vc.modalPresentationStyle =  options.presentStyle;
      [[ZSDRouter sharedRouter].topVC presentViewController:vc animated:options.animated completion:nil];
        if (completeBlock) {
            completeBlock(nil,nil);
        }
        return YES;
    }
    return NO;
}

+ (BOOL)_openWithOtherStyle:(__kindof UIViewController *)vc
                    options:(ZSDRouterOptions *)options
                   complete:(void(^)(id result,NSError *error))completeBlock
{
    BOOL success = [vc zsdRouterSpecialTransformWithTopVC:[ZSDRouter sharedRouter].topVC];
    if (completeBlock) {
        NSError *error = nil;
        if (!success) {
            error = [[NSError alloc] initWithDomain:ZSDRouterErrorDomain code:ZSDRouterErrorUnSupportTransform userInfo:@{@"msg":@"no specified transform animation"}];
        }
        completeBlock(nil,error);
    }
    return success;
}

//找到topVC
- (__kindof UIViewController *)_findTopVC:(__kindof UIViewController *)vc
{
    UIViewController *tmpVC = vc;
    while ([tmpVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *naVC = (UINavigationController *)tmpVC;
        tmpVC = naVC.topViewController;
    }
    while (tmpVC.presentedViewController) {
        tmpVC = tmpVC.presentedViewController;
        tmpVC = [self _findTopVC:tmpVC];
    }
    return tmpVC;
}

//找到topVC前的一个vc
- (__kindof UIViewController *)_findLastTopVC:(__kindof UIViewController *)vc
                                    lastTopVC:(__kindof UIViewController *)lastTopVC
{
    UIViewController *tmpVC = vc;
    while ([tmpVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *naVC = (UINavigationController *)tmpVC;
        tmpVC = naVC.topViewController;
        if (naVC.viewControllers.count > 1) {
            NSUInteger count = naVC.viewControllers.count;
            lastTopVC = naVC.viewControllers[count -2];
        }
    }
    while (tmpVC.presentedViewController) {
        lastTopVC = tmpVC;
        tmpVC = tmpVC.presentedViewController;
        lastTopVC = [self _findLastTopVC:tmpVC lastTopVC:lastTopVC];
    }
    return lastTopVC;
}

+ (BOOL)_isRouterContainVC:(__kindof UIViewController *)vc
{
    UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIViewController *tmpVC = rootVC;
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarVC = (UITabBarController *)rootVC;
        UIViewController *tmpVC = tabBarVC.selectedViewController;
        return [self _isEqualFromVC:tmpVC targetVC:vc];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]) {
        return [self _isEqualFromVC:tmpVC targetVC:vc];
    }
    return [self _isEqualFromVC:tmpVC targetVC:vc];
}

+ (__kindof UIViewController *)_findVCWithModuleID:(__kindof NSString *)moduleID
{
    UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIViewController *tmpVC = rootVC;
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarVC = (UITabBarController *)rootVC;
        UIViewController *tmpVC = tabBarVC.selectedViewController;
        return [self _getTargetVCFromVC:tmpVC moduleID:moduleID];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]) {
        UIViewController *tmpVC = rootVC;
        return [self _getTargetVCFromVC:tmpVC moduleID:moduleID];
    }
    return [self _getTargetVCFromVC:tmpVC moduleID:moduleID];
}

+ (UIViewController *)_findVCWithPopStep:(NSUInteger)popStep
{
    UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIViewController *tmpVC = rootVC;
    NSUInteger totalSteps = [ZSDRouter sharedRouter].totalSteps;
    NSUInteger step = totalSteps - popStep;
    if (step >= 0) {
        NSUInteger originStep = 0;
        if ([rootVC isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBarVC = (UITabBarController *)rootVC;
            UIViewController *tmpVC = tabBarVC.selectedViewController;
            return [self _getTargetVCFromVC:tmpVC originStep:originStep step:step];
        } else if ([rootVC isKindOfClass:[UINavigationController class]]) {
            UIViewController *tmpVC = rootVC;
            return [self _getTargetVCFromVC:tmpVC originStep:originStep step:step];
        }
        return [self _getTargetVCFromVC:tmpVC originStep:originStep step:step];
    }else {
        return tmpVC;
    }
    
}

//通过递归比较router里面是否存在和targetVC相同的vc，从tmpVC开始递归
+ (BOOL)_isEqualFromVC:(__kindof UIViewController *)tmpVC targetVC:(__kindof UIViewController *)targetVC
{
    if ([tmpVC isEqual:targetVC]) {
        return YES;
    }
    while ([tmpVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *naVC = (UINavigationController *)tmpVC;
        if ([naVC.viewControllers containsObject:targetVC]) {
            return YES;
        }
        tmpVC = naVC.topViewController;
    }
    while (tmpVC.presentedViewController) {
        tmpVC = tmpVC.presentedViewController;
        if ([tmpVC isEqual:targetVC]) {
            return YES;
        }
        return [self _isEqualFromVC:tmpVC targetVC:targetVC];
    }
    return NO;
}

//通过递归从tmpVC开始根据moduleID找到对应的vc
+ (__kindof UIViewController *)_getTargetVCFromVC:(__kindof UIViewController *)tmpVC moduleID:(__kindof NSString *)moduleID
{
    if (tmpVC.moduleID && [tmpVC.moduleID isKindOfClass:[NSString class]] && tmpVC.moduleID.length >0 && [tmpVC.moduleID isEqualToString:moduleID]) {
        return tmpVC;
    }
    while ([tmpVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *naVC = (UINavigationController *)tmpVC;
        tmpVC = naVC.topViewController;
        if (tmpVC.moduleID && [tmpVC.moduleID isKindOfClass:[NSString class]] && tmpVC.moduleID.length >0 && [tmpVC.moduleID isEqualToString:moduleID]) {
            return tmpVC;
        }
    }
    while (tmpVC.presentedViewController) {
        tmpVC = tmpVC.presentedViewController;
        if (tmpVC.moduleID && [tmpVC.moduleID isKindOfClass:[NSString class]] && tmpVC.moduleID.length >0 && [tmpVC.moduleID isEqualToString:moduleID]) {
            return tmpVC;
        }
        return [self _getTargetVCFromVC:tmpVC moduleID:moduleID];
    }
    return nil;
}

+ (__kindof UIViewController *)_getTargetVCFromVC:(__kindof UIViewController *)tmpVC originStep:(NSUInteger)originStep step:(NSUInteger)step
{
    while ([tmpVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *naVC = (UINavigationController *)tmpVC;
        tmpVC = naVC.topViewController;
        NSUInteger count = naVC.viewControllers.count;
        if (originStep + count > step) {
            NSInteger index = step - originStep;
            index = index >0 ?:0;
            UIViewController *targetVC = naVC.viewControllers[index];
            return targetVC;
        }
        originStep +=count;
    }
    while (tmpVC.presentedViewController) {
        tmpVC = tmpVC.presentedViewController;
        originStep++;
        return [self _getTargetVCFromVC:tmpVC originStep:originStep step:step];
    }
    return nil;
}

//获取从tmpVC到当前vc正常open操作需要的次数
- (NSUInteger)_getTotalStepFromVC:(__kindof UIViewController *)tmpVC originSteps:(NSUInteger)originSteps
{
    NSUInteger totalSteps = originSteps;
    while ([tmpVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *naVC = (UINavigationController *)tmpVC;
        tmpVC = naVC.topViewController;
        totalSteps = naVC.viewControllers.count > 1 ? (naVC.viewControllers.count - 1) : 1;
    }
    while (tmpVC.presentedViewController) {
        tmpVC = tmpVC.presentedViewController;
        totalSteps++;
        [self _getTotalStepFromVC:tmpVC originSteps:totalSteps];
    }
    return totalSteps;
}

+ (void)bindVC:(__kindof UIViewController *)vc
receiveMsgBlock:(void(^)(id data))receiveMsgBlock
{
    if (!receiveMsgBlock) {
        return;
    }
    void(^block)(id data) = objc_getAssociatedObject(vc, ZSDRouterViewControllerReceiveMsgBlockKey);
    if (!block) {
        objc_setAssociatedObject(vc, ZSDRouterViewControllerReceiveMsgBlockKey, receiveMsgBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}


@end
