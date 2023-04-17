//
//  KVManModel.m
//  KVHomeModule_Example
//
//  Created by MacBook Pro on 2023/4/14.
//  Copyright © 2023 韩问. All rights reserved.
//

#import "KVManModel.h"
#import "KVPresonModel.h"
#import <objc/runtime.h>
#import <malloc/malloc.h>

@implementation KVManModel
// 动态解析
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(test)) {//导入 #import <objc/runtime.h>
        IMP imp = class_getMethodImplementation(self.class, @selector(messageMethod));
        class_addMethod(self.class, sel, imp, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}
- (void)messageMethod {
    NSLog(@"%s",__func__);
}

///慢速转发
- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSLog(@"%s - %@",__func__,NSStringFromSelector(aSelector));
    return [KVPresonModel alloc]; // KVPresonModel实现对aSelector method
}

///慢速转发
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSLog(@"%s - %@",__func__,NSStringFromSelector(sel));
    if (sel == @selector(test)) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    return [super methodSignatureForSelector:sel];
}
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    anInvocation.target = nil;
    [anInvocation invoke];
}

//如果以上流程都不处理，找不到任何消息处理者，就执行这个，但还是会Crash
- (void)doesNotRecognizeSelector:(SEL)aSelector {
    NSLog(@"找不到方法");
}

@end
