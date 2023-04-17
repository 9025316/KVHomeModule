//
//  UIViewController+ZSDRouter.h
//  ZhuShiDaMobile
//
//  Created by Kevin_han on 21/12/16.
//  Copyright © 2021年 Kevin_han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSDRouterHeader.h"
NS_ASSUME_NONNULL_BEGIN

@class ZSDRouterOptions;

@interface UIViewController (ZSDRouter)

//每个VC 所属的moduleID，默认为nil，作为唯一标识使用，存在同属于一个clas但是moduleID的情况
@property (nonatomic, copy ,nullable) NSString *moduleID;

/**
 初始化viewController对象，可以重写该方法的实现，进行viewController的初始化。默认返回不为空

 @return 初始化后的viewController对象
 */
+ (instancetype)zsdRouterViewController;

/**
 初始化viewController对象，默认返回为空，可以重写该方法实现初始化。赋值操作可以通过YYModel，或者别的工具类在内部实现。该方法主要用于h5和native交互跳转时，需要传输大量参数赋值时调用，或者后台接口返回的数据实现页面跳转时使用。

 @param dic json对象。纯数据的，内部不含OC对象
 @return 初始化后，赋值完成的viewController对象
 */
+ (instancetype)zsdRouterViewControllerWithJSON:(__kindof NSDictionary *)dic;


- (void)zsdRouterViewControllerWithJSON:(__kindof NSDictionary *)dic;

/**
 根据权限等级判断是否可以打开，具体通过category重载来实现
 
 @return 是否进行正常的跳转
 */
+ (BOOL)validateTheAccessToOpenWithOptions:(ZSDRouterOptions *)options;

/**
 处理没有权限去打开的情况
 */
+ (void)handleNoAccessToOpenWithOptions:(ZSDRouterOptions *)options;

/**
 用户自定义转场动画
 
 @param topVC 根部导航栏
 @return 是否能够进行自定义的专场动画

 */
- (BOOL)zsdRouterSpecialTransformWithTopVC:(__kindof UIViewController *)topVC;

/**
 自定义的转场方式

 @return 转场方式
 */
- (RouterTransformVCStyle)zsdRouterTransformStyle;

/// 接受ZSDRouter topVC发送的消息
/// @param msg 消息
/// @param complete 回调
- (void)zsdReceiveTopVCMsg:(nullable NSDictionary *)msg
                     complete:(nullable void(^)(id _Nullable result))complete;

/**
 刷新数据
 */
- (void)zsdRouterRefresh;

- (BOOL)zsdNeedRefresh;

/**
 是否是tabbarItem的对应的viewController
defalut is NO
 @return YES or NO
 */
+ (BOOL)zsdIsTabBarItemVC;

/**
 tab的index值
 
 @return index值 default is 0
 */
+ (NSInteger)zsdTabIndex;

/// 向前一个页面传递数据
/// @param msg msg
- (void)zsdSendMsgToPreVC:(nullable NSDictionary *)msg;

@end

NS_ASSUME_NONNULL_END

