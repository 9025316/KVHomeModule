//
//  ZSDJSONHandler.m
//  ZhuShiDaMobile
//
//  Created by Kevin_han on 21/12/16.
//  Copyright © 2021年 Kevin_han. All rights reserved.
//

#import "ZSDJSONHandler.h"
#import "ZSDRouter.h"

@implementation ZSDJSONHandler
// 解析JSON文件 获取到所有的Modules
+ (NSArray *)getModulesFromJsonFile:(__kindof NSArray <NSString *>*)files
{
    NSMutableArray *mutableArray = [NSMutableArray new];
    for (NSString *fileName in files) {
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSArray *modules = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [mutableArray addObjectsFromArray:modules];
    }
    return [mutableArray copy];
}

+ (NSString *)getTargetWithModuleID:(__kindof NSString *)moduleID
{
    NSString *vcClassName = nil;
    for (NSDictionary *module in [ZSDRouter sharedRouter].modules) {
        NSString *tempModuleID =[NSString stringWithFormat:@"%@",module[@"moduleID"]];
        if ([tempModuleID isEqualToString:moduleID]) {
            vcClassName = module[@"target"];
            break;
        }
    }
    return vcClassName;
}

+ (NSString *)getTypeWithModuleID:(__kindof NSString *)moduleID
{
    NSString *type = nil;
    for (NSDictionary *module in [ZSDRouter sharedRouter].modules) {
        NSString *tempModuleID =[NSString stringWithFormat:@"%@",module[@"moduleID"]];
        if ([tempModuleID isEqualToString:moduleID]) {
            type = module[@"type"];
            break;
        }
    }
    return type;
}

+ (NSString *)getSwiftModuleNameWithModuleID:(__kindof NSString *)moduleID
{
    NSString *moduleName = nil;
    for (NSDictionary *module in [ZSDRouter sharedRouter].modules) {
        NSString *tempModuleID = [NSString stringWithFormat:@"%@",module[@"moduleID"]];
        if ([tempModuleID isEqualToString:moduleID]) {
            moduleName = module[@"module"];
            break;
        }
    }
    return moduleName;

}

+ (NSString *)getFuncNameWithModuleID:(__kindof NSString *)moduleID
{
    NSString *func = nil;
    for (NSDictionary *module in [ZSDRouter sharedRouter].modules) {
        NSString *tempModuleID =[NSString stringWithFormat:@"%@",module[@"moduleID"]];
        if ([tempModuleID isEqualToString:moduleID]) {
            func = module[@"func"];
            break;
        }
    }
    return func;
}

@end
