//
//  ZSDRouterHeader.h
//  ZhuShiDaMobile
//
//  Created by Kevin_han on 21/12/16.
//  Copyright © 2021年 Kevin_han. All rights reserved.
//

#ifndef ZSDRouterHeader_h
#define ZSDRouterHeader_h

#ifdef DEBUG
#define ZSDRouterLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define ZSDRouterLog(...)
#endif

static NSString * const ZSDRouterErrorDomain = @"ZSDRouterError";

/// ViewController的转场方式
typedef NS_ENUM(NSInteger,RouterTransformVCStyle){
    /// 不指定转场方式，使用自带的转场方式
    RouterTransformVCStyleDefault = -1,
    /// push方式转场
    RouterTransformVCStylePush,
    /// present方式转场
    RouterTransformVCStylePresent,
    /// 用户自定义方式转场
    RouterTransformVCStyleOther
};

/// ViewController的创建方式
typedef NS_ENUM(NSInteger,RouterCreateStyle) {
    /// 默认创建方式，创建一个新的ViewController对象
    RouterCreateStyleNew,
    /// 创建一个新的ViewController对象，然后替换navigationController当前的viewController
    RouterCreateStyleReplace,
    /// 当前的viewController就是目标viewController就不创建，而是执行相关的刷新操作。如果当前的viewController不是目标viewController就执行创建操作
    RouterCreateStyleRefresh,
    /// 用于present转场时目标present的目标是VC也有导航栏
    RouterCreateStyleNewWithNaVC
    
};

typedef NS_ENUM(NSInteger,ZSDRouterError) {
  /// className is nil
  ZSDRouterErrorClassNameIsNil = 10000,
  /// class is nil
  ZSDRouterErrorClassNil,
  /// url is nil
  ZSDRouterErrorURLIsNil,
  /// sandboxPath is nil
  ZSDRouterErrorSandBoxPathIsNil,
  /// system unsupport this url
  ZSDRouterErrorSystemUnSupportURL,
  /// ZSDRouter unsupport this scheme
  ZSDRouterErrorSystemUnSupportURLScheme,
  /// unsupport this action
  ZSDRouterErrorUnSupportAction,
  /// no right to access
  ZSDRouterErrorNORightToAccess,
  /// unsupport this transform
  ZSDRouterErrorUnSupportTransform,
  /// unsupport switch tabbar
  ZSDRouterErrorUnSupportSwitchTabBar,
  /// url is in blackName list
  ZSDRouterErrorBlackNameURL,
  /// unsupport push transform
  ZSDRouterErrorUnSupportPushTransform,
  /// unsupport replace transform
  ZSDRouterErrorUnSupportReplaceTransform,
  /// unsupport pop action
  ZSDRouterErrorUnSupportPopAtcion,
  /// unsuport class in ZSDRouter
  ZSDRouterErrorUnSupportRouterClass,
  /// the vc is not contained in Router
  ZSDRouterErrorNoVCInRouter,

};



@protocol ZSDRouterDelegate <NSObject>

@optional
/**
 通过工厂方法初始化viewController
 
 @param dic 工厂方法需要的参数
 @return 初始化的viewController
 */
+ (UIViewController *)zsdRouterFactoryViewControllerWithJSON:(NSDictionary *)dic;

@end

#endif /* ZSDRouterHeader_h */
