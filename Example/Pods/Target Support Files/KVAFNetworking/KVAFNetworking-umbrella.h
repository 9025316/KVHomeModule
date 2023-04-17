#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "KVNetworking.h"
#import "KVCacheManager.h"
#import "KVDiskCache.h"
#import "KVLRUManager.h"
#import "KVMemoryCache.h"
#import "KVNetworking+RequestManager.h"

FOUNDATION_EXPORT double KVAFNetworkingVersionNumber;
FOUNDATION_EXPORT const unsigned char KVAFNetworkingVersionString[];

