//
//  ZSDRouterOptions.h
//  ZhuShiDaMobile
//
//  Created by Kevin_han on 21/12/16.
//  Copyright © 2021年 Kevin_han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSDRouterHeader.h"

//***************************************************************
//*
//*           RouterOptions类
//*           配置跳转时的各种设置
//***************************************************************

NS_ASSUME_NONNULL_BEGIN

static const void *ZSDRouterViewControllerReceiveMsgBlockKey = "ZSDRouterViewControllerReceiveMsgBlockKey"; /// viewController 绑定block的key
@interface ZSDRouterOptions : NSObject

/// 转场方式
@property (nonatomic, assign) RouterTransformVCStyle transformStyle;

/// 转场方式为present的时候，present样式
@property (nonatomic, assign) UIModalPresentationStyle presentStyle;

/// vc 的创建方式
@property (nonatomic, assign) RouterCreateStyle  createStyle;

/// 跳转时是否有动画
@property (nonatomic, assign) BOOL animated;

/// 每个页面所对应的moduleID
@property (nonatomic, copy, readonly) NSString *moduleID;
/// swift 页面所在的组件名，主工程的module是target的name
@property (nonatomic,copy) NSString *module;

//这个传入的参数默认传入的值dictionary对象，在+ (void)open:(NSString *)vcClassName optionsWithJSON:(RouterOptions *)options 这个方法使用时defaultParams 是json对象。这个地方要注意哦
/// 跳转时传入的参数，默认为nil
@property (nonatomic,copy,readwrite,nonnull) NSDictionary *defaultParams;

/// 接收后一个viewController传递消息的block
@property (nonatomic, copy, nullable) void(^zsd_receiveMsgBlock)(id data);

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;
/**
 创建默认配置的options对象
 
 @return RouterOptions 实例对象
 */
+ (instancetype)options;

/**
 创建options对象，并配置moduleID
 
 @param moduleID 模块的ID
 @return RouterOptions 实例对象
 */
+ (instancetype)optionsWithModuleID:(__kindof NSString *)moduleID;

/**
 创建单独配置的options对象,其余的是默认配置
 
 @param params 跳转时传入的参数
 @return RouterOptions 实例对象
 */
+ (instancetype)optionsWithDefaultParams:(__kindof NSDictionary *)params;

/**
 创建options对象，并配置转场方式
 
 @param tranformStyle 转场方式
 @return RouterOptions 实例对象
 */
+ (instancetype)optionsWithTransformStyle:(RouterTransformVCStyle)tranformStyle;

/**
 创建options对象，并配置创建方式
 
 @param createStyle 创建方式
 @return RouterOptions 实例对象
 */
+ (instancetype)optionsWithCreateStyle:(RouterCreateStyle)createStyle;

/**
 已经创建的option对象传入参数
 
 @param params 跳转时传入的参数
 @return RouterOptions 实例对象
 */
- (instancetype)optionsWithDefaultParams:(__kindof NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END

