//
//  ZSDRouterTool.m
//  ZhuShiDaMobile
//
//  Created by Kevin_han on 21/12/16.
//  Copyright © 2021年 Kevin_han. All rights reserved.
//

#import "ZSDRouterTool.h"
#import "ZSDRouter.h"
#import "ZSDRouterHeader.h"
#import "ZSDRouterExtension.h"

@implementation ZSDRouterTool
//为ViewController 的属性赋值
+ (UIViewController *)configVCWithClass:(Class)vcClass
                                options:(ZSDRouterOptions *)options
{
    
    Class targetClass = vcClass;
    UIViewController *vc = [targetClass zsdRouterViewController];
    [vc setValue:options.moduleID forKey:[ZSDRouterExtension zsdRouterModuleIDKey]];
    [self configTheVC:vc options:options];
    return vc;
}

/**
 对于已经创建的vc进行赋值操作
 
 @param vc 对象
 @param options 跳转的各种设置
 */
+ (void)configTheVC:(__kindof UIViewController *)vc
            options:(ZSDRouterOptions *)options
{
    if (!options) {
        return;
    }
    if (options.defaultParams && [options.defaultParams isKindOfClass:[NSDictionary class]]) {
        NSArray *propertyNames = [options.defaultParams allKeys];
        for (NSString *key in propertyNames) {
            id value =options.defaultParams[key];
            [vc setValue:value forKey:key];
        }
    }
}

//将url ？后的字符串转换为NSDictionary对象
+ (NSMutableDictionary *)convertUrlStringToDictionary:(__kindof NSString *)urlString
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSArray *parameterArr = [urlString componentsSeparatedByString:@"&"];
    for (NSString *parameter in parameterArr) {
        NSArray *parameterBoby = [parameter componentsSeparatedByString:@"="];
        if (parameterBoby.count == 2) {
            [dic setObject:parameterBoby[1] forKey:parameterBoby[0]];
        }else
        {
            ZSDRouterLog(@"参数不完整");
        }
    }
    return dic;
}

+ (NSURL *)url:(NSURL *)url
appendParameter:(__kindof NSDictionary *)parameter
{
    NSString *urlString = [self urlStr:url.absoluteString appendParameter:parameter];
    return [NSURL URLWithString:urlString];
}

+ (NSString *)urlStr:(__kindof NSString *)urlStr
     appendParameter:(__kindof NSDictionary *)parameter
{
    //[urlStr hasSuffix:@"&"]?[urlStr stringByReplacingOccurrencesOfString:@"&" withString:@""]:urlStr;
    if ([urlStr hasSuffix:@"&"]) {
        urlStr = [urlStr substringToIndex:urlStr.length-1];
    }
    if (!([parameter allKeys].count>0)) {
        return urlStr;
    }
    NSString *firstSeperator = @"";
    if (![urlStr containsString:@"?"]) {
        urlStr = [NSString stringWithFormat:@"%@?",urlStr];
    }else if ([urlStr containsString:@"?"] && ![urlStr hasSuffix:@"?"]){
        firstSeperator = @"&";
    }
    NSString *query = firstSeperator;
    for (NSString *key in parameter.allKeys) {
        id object = [parameter objectForKey:key];
        NSString *value = nil;
        if ([object isKindOfClass:[NSString class]]) {
            value = (NSString *)object;
        } else {
            continue;
        }
        if ([query hasSuffix:@"&"]) {
            query = [NSString stringWithFormat:@"%@%@=%@",query,key,value];
        }else{
            if (query.length>0) {
                query = [NSString stringWithFormat:@"%@&%@=%@",query,key,value];
            }else{
                query = [NSString stringWithFormat:@"%@=%@",key,value];
            }
        }
    }
    
    return [NSString stringWithFormat:@"%@%@",urlStr,query];
}

+ (NSURL *)url:(NSURL*)url
removeQueryKeys:(__kindof NSArray <NSString *>*)keys
{
    NSString *urlString = [self urlStr:url.absoluteString removeQueryKeys:keys];
    return [NSURL URLWithString:urlString];
}

+ (NSString *)urlStr:(__kindof NSString *)urlStr
     removeQueryKeys:(__kindof NSArray <NSString *>*)keys
{
    if (!(keys.count>0)) {
        NSAssert(NO, @"urlStr:removeQueryKeys: keys cannot be nil");
    }
    NSArray *tempArray = [urlStr componentsSeparatedByString:@"?"];
    NSString *query = nil;
    if (tempArray.count==2) {
        query = tempArray.lastObject;
    }
    NSDictionary *tempParameter = [self convertUrlStringToDictionary:query];
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc] initWithDictionary:tempParameter];
    for (NSString *key in keys) {
        [parameter removeObjectForKey:key];
    }
    
    NSString *baseUrl = tempArray.firstObject;
    if (parameter.count == 0) {
        return baseUrl;
    }
    NSString *urlString = [self urlStr:baseUrl appendParameter:parameter];
    return urlString;
}

@end
