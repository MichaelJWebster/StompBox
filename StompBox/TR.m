//
//  TR.m
//  TimerPool
//
//  Created by Michael Webster on 22/02/2015.
//  Copyright (c) 2015 Mike Webster Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TR.h"

@implementation TR

-(id)init
{
    self = [super init];
    return self;
}

-(void)respondToTick
{
    static int numTicks = 1;
    NSLog(@"Got a tick %d.\n", numTicks++);
}

@end