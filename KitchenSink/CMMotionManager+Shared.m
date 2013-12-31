//
//  CMMotionManager+Shared.m
//  KitchenSink
//
//  Created by Jan Timar on 10/27/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import "CMMotionManager+Shared.h"

@implementation CMMotionManager (Shared)

+(CMMotionManager *)sharedMotionManager
{
    static CMMotionManager *shared = nil;
    if(!shared){
        // vykona sa iba raz
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[CMMotionManager alloc] init];
        });
    }
    return shared;
}

@end
