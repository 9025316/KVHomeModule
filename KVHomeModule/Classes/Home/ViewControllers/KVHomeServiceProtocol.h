//
//  KVHomeServiceProtocol.h
//  KVHomeModule
//
//  Created by MacBook Pro on 2023/4/19.
//

#import <Foundation/Foundation.h>
#import "BHServiceProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@protocol KVHomeServiceProtocol <NSObject,BHServiceProtocol>

@property (nonatomic, strong) NSString *itemId;

- (UIViewController *)getHomeViewContoller;

@end

NS_ASSUME_NONNULL_END
