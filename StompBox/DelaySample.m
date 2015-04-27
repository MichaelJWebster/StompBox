//
//  DelaySample.m
//  StompBox
//
//  Created by Michael Webster on 14/03/2015.
//  Copyright (c) 2015 Mike Webster Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DelaySample.h"

@implementation DelaySample
{
}
@synthesize fFirstSample;
@synthesize fSecondSample;
@synthesize fDelayMs;

-(void)calcDelay
{
    NSTimeInterval diff = (fSecondSample - fFirstSample) * 1000;
    NSNumber *del = [NSNumber numberWithDouble:diff];
    fDelayMs = (uint32_t)[del unsignedIntegerValue];
}

-(id)init:(NSTimeInterval)withFirst andSecond:(NSTimeInterval)secondSample
{
    if (self = [self init])
    {
        fFirstSample = withFirst;
        fSecondSample = secondSample;
        [self calcDelay];
    }
    return self;
    
}
@end