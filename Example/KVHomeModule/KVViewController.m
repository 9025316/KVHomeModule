//
//  KVViewController.m
//  KVHomeModule
//
//  Created by 韩问 on 04/13/2023.
//  Copyright (c) 2023 韩问. All rights reserved.
//

#import "KVViewController.h"
//#import "HomeViewController.h"
//#import <objc/runtime.h>
//#import <malloc/malloc.h>

#import "KVManModel.h"
/*
 ARC模式下，autoreleasePool对象在什么时候释放？
 分两种情况：
 通过__autoreleasing 修饰创建的对象并加到 @autoreleasepool 里面的对象出了自动释放池的作用域就会被释放。和线程runloop没有关系
 
 在每条线程都存在自动释放池，
 在主线程中：系统自动添加到释放池的对象会在线程runloop 进入休眠前进行释放
 在子线程中：1、如果子线程开起了runloop 就和主线程一样会在线程runloop 进入休眠前进行释放。
          2、如果子线和没有开起runloop 就会在子线程消毁的时候释放
 */
// 打印自动释放池里的对象
extern void _objc_autoreleasePoolPrint(void);
//
extern void instrumentObjcMessageSends(BOOL flag);

@interface KVViewController ()

@end

@implementation KVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    for (int i = 0; i < 1000000; i++) {
        @autoreleasepool {
            NSString *string = [NSString stringWithFormat:@"%@",@"KVViewController1231231"];
            __autoreleasing UIImage *object = [UIImage alloc];
            _objc_autoreleasePoolPrint();
        }
    }
    
    KVManModel *object = [[KVManModel alloc] init];
    instrumentObjcMessageSends(YES);
    [object test];
    instrumentObjcMessageSends(NO);
    
    
    dispatch_queue_t  queue_t1 = dispatch_queue_create("k", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t  queue_t2 = dispatch_queue_create("v", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t  queue_t3 = dispatch_queue_create("v", DISPATCH_QUEUE_CONCURRENT_WITH_AUTORELEASE_POOL);
    
    dispatch_sync(queue_t1, ^{
        NSLog(@"111111");
        dispatch_sync(queue_t2, ^{
            usleep(200);
            NSLog(@"33333333");
        });
    });
    NSLog(@"2222222");
}

@end
