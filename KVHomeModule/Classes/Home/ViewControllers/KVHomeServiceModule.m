//
//  KVHomeServiceModule.m
//  KVHomeModule
//
//  Created by MacBook Pro on 2023/4/19.
//

#import "KVHomeServiceModule.h"
#import "KVHomeViewController.h"
#import "KVHomeServiceProtocol.h"

@BeeHiveService(KVHomeServiceProtocol,KVHomeServiceModule)
@interface KVHomeServiceModule ()<KVHomeServiceProtocol>

@end

@implementation KVHomeServiceModule
@synthesize itemId = _itemId;

- (void)pringItemId {
    
    NSLog(@"%@",_itemId);
}

- (UIViewController *)getHomeViewContoller {
    [self pringItemId];
    return KVHomeViewController.new;
}

@end
