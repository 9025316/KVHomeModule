//
//  ZSDRouterTool.h
//  ZhuShiDaMobile
//
//  Created by Kevin_han on 21/12/16.
//  Copyright © 2021年 Kevin_han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSDRouterOptions.h"
NS_ASSUME_NONNULL_BEGIN
@class ZSDRouter;

@interface ZSDRouterTool : NSObject
//为ViewController 的属性赋值
+ (UIViewController *)configVCWithClass:(Class)vcClass
                                options:(ZSDRouterOptions *)options;

+ (void)configTheVC:(UIViewController *)vc
            options:(ZSDRouterOptions *)options;

/**
 将url的query转换为字典参数
 
 @param urlString url字符串
 @return NSMutableDictionary 对象
 */
+ (NSMutableDictionary *)convertUrlStringToDictionary:(__kindof NSString *)urlString;

/**
 url对象添加参数
 
 @param url url对象
 @param parameter 参数
 @return 处理后的url对象
 */
+ (NSURL *)url:(NSURL *)url
appendParameter:(__kindof NSDictionary *)parameter;
/**
 为url字符串添加参数
 
 @param urlStr url字符串
 @param parameter 参数
 @return url字符串
 */
+ (NSString *)urlStr:(__kindof NSString *)urlStr
     appendParameter:(__kindof NSDictionary *)parameter;

/**
 url对象删除参数
 
 @param url url对象
 @param keys 需要删除的参数的key的数组
 @return 处理后的url对象
 */
+ (NSURL *)url:(NSURL*)url
removeQueryKeys:(__kindof NSArray <NSString *>*)keys;

/**
 url字符串删除参数
 
 @param urlStr url字符串
 @param keys 需要删除的key组成的数组
 @return 处理后的url字符串
 */
+ (NSString *)urlStr:(__kindof NSString *)urlStr
     removeQueryKeys:(__kindof NSArray <NSString *>*)keys;

@end

NS_ASSUME_NONNULL_END
