//
//  ZSDRouterExtension+Jack.m
//  ZhuShiDaMobile
//
//  Created by Kevin_han on 21/12/17.
//  Copyright © 2021年 Kevin_han. All rights reserved.
//

#import "ZSDRouterExtension+Jack.h"

@implementation ZSDRouterExtension (Jack)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

+ (NSString *)privateWebVCClassName
{
    return @"ZSDJSBridgeWebViewController";
}

+ (NSString *)openWebVCClassName
{
    return @"ZSDJSBridgeWebViewController";
}

+ (NSString *)zsdWebURLKey
{
    return @"urlString";
}

+ (NSArray *)urlSchemes{
    
    return @[@"http",@"https",@"openzsd",@"file",
             @"itms-apps"];
}

+ (NSArray *)specialSchemes {
    return @[@"socket"];
}

#pragma clang diagnostic pop
@end
