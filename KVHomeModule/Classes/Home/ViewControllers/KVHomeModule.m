//
//  KVHomeModule.m
//  KVHomeModule
//
//  Created by MacBook Pro on 2023/4/19.
//

#import "KVHomeModule.h"
#import "BHAnnotation.h"

@BeeHiveMod(KVHomeModule)
@interface KVHomeModule()<BHModuleProtocol>

@end

@implementation KVHomeModule

- (id)init{
    if (self = [super init])
    {
        NSLog(@"ShopModule init");
    }
    
    return self;
}

- (NSUInteger)moduleLevel
{
    return 0;
}


- (void)modSetUp:(BHContext *)context
{
    NSLog(@"KVHomeModule setup");
}


-(void)modInit:(BHContext *)context
{

//    [[BeeHive shareInstance] registerService:@protocol(UserTrackServiceProtocol) service:[BHUserTrackViewController class]];
}

@end
