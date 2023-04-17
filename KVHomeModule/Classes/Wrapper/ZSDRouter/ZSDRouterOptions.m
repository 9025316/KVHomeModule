//
//  ZSDRouterOptions.m
//  ZhuShiDaMobile
//
//  Created by Kevin_han on 21/12/16.
//  Copyright © 2021年 Kevin_han. All rights reserved.
//

#import "ZSDRouterOptions.h"

//******************************************************************************
//*
//*           RouterOptions类
//*           配置跳转时的各种设置
//******************************************************************************

@interface ZSDRouterOptions()
//每个页面所对应的moduleID
@property (nonatomic, copy, readwrite) NSString *moduleID;

@end

@implementation ZSDRouterOptions

+ (instancetype)options
{
    ZSDRouterOptions *options = [[self alloc] init];
    options.transformStyle = RouterTransformVCStyleDefault;
    options.presentStyle = UIModalPresentationFullScreen;
    options.animated = YES;
    options.defaultParams = @{};
    return options;
}

+ (instancetype)optionsWithModuleID:(__kindof NSString *)moduleID
{
    ZSDRouterOptions *options = [ZSDRouterOptions options];
    options.moduleID = moduleID;
    return options;
}

+ (instancetype)optionsWithDefaultParams:(__kindof NSDictionary *)params
{
    ZSDRouterOptions *options = [ZSDRouterOptions options];
    options.defaultParams = params;
    return options;
}

+ (instancetype)optionsWithTransformStyle:(RouterTransformVCStyle)tranformStyle
{
    ZSDRouterOptions *options = [ZSDRouterOptions options];
    options.transformStyle = tranformStyle;
    return options;
}

+ (instancetype)optionsWithCreateStyle:(RouterCreateStyle)createStyle
{
    ZSDRouterOptions *options = [ZSDRouterOptions options];
    options.createStyle = createStyle;
    return options;
}

- (instancetype)optionsWithDefaultParams:(__kindof NSDictionary *)params
{
    self.defaultParams = params;
    return self;
}

#pragma mark - - setter - -
- (void)setDefaultParams:(NSDictionary *)defaultParams
{
    if (defaultParams) {
        _defaultParams = defaultParams;
    }
}


@end
