//
//  CMMotionManager+Shared.h
//  KitchenSink
//
//  Created by Jan Timar on 10/27/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

@interface CMMotionManager (Shared)

+(CMMotionManager *)sharedMotionManager;


@end
