//
//  CalcDelay.m
//  StompBox
//
//  Created by Michael Webster on 15/03/2015.
//  Copyright (c) 2015 Mike Webster Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalcDelay.h"

#define MS_Per_S 1000
#define MS_Per_M 60 * 1000

@implementation CalcDelay
{
    // Array of Delays
    NSMutableArray* fSamples;
    NSTimeInterval fLastInterval;
    // The total number of samples we can hold
    int fNumSamples;
    // The current number of samples held.
    //int fCurrentSamples;
    // The index of the next position to place a sample if fCurrentSamples <
    // fNumSamples, or where to remove samples if fCurrentSamples >= fNumSamples.
    int fSampleTail;
}
@synthesize fCurrentDelay;

-(void)updateDelay
{
    double delayMs = 0;
    for (int i = 0; i < fSampleTail; i++)
    {
        delayMs += [fSamples[i] fDelayMs];
    }
    if (fSampleTail > 0)
    {
        NSNumber *del = [NSNumber numberWithDouble: delayMs/(fSampleTail)];
        fCurrentDelay = (uint32_t)[del unsignedIntegerValue];
    }
    else
    {
        fCurrentDelay = 0;
    }
}

-(id)init
{
    if (self = [super init])
    {
        fLastInterval = 0;
        fNumSamples = 0;
        fSampleTail = 0;
        fSamples = nil;
    }
    return self;
}

-(id)init:(NSTimeInterval)withFirstSample
{
    return [self init:withFirstSample andNumSamples:5];
}

-(id)init:(NSTimeInterval)withFirstSample andNumSamples:(int)numSamples
{
    if (self = [self init])
    {
        fLastInterval = withFirstSample;
        fNumSamples = numSamples;
        fSampleTail = 0;
        fSamples = [NSMutableArray arrayWithCapacity:fNumSamples];
    }
    return self;
}

-(void)setNumSamples:(int)numSamples
{
    if (fSamples == nil)
    {
        fNumSamples = numSamples;
        fSamples = [NSMutableArray arrayWithCapacity:fNumSamples];
    }
    else
    {
        if (numSamples > fNumSamples || numSamples > fSampleTail)
        {
            NSMutableArray* newArray = [NSMutableArray arrayWithCapacity:numSamples];
            [newArray addObjectsFromArray:fSamples];
            fSamples = newArray;
            fNumSamples = numSamples;
        }
        else if (numSamples < fNumSamples && numSamples < fSampleTail)
        {
            NSMutableArray* newArray = [NSMutableArray arrayWithCapacity:numSamples];
            NSRange firstRange;
            firstRange.location = 0;
            firstRange.length = fSampleTail;
            NSRange secondRange;
            secondRange.location = fSampleTail - numSamples;
            secondRange.length = numSamples;
            [newArray replaceObjectsInRange:firstRange withObjectsFromArray:fSamples range:secondRange];
            fSamples = newArray;
            fNumSamples = numSamples;
        }
    }
}

-(void)addInterval:(NSTimeInterval)tInterval
{
    if (fLastInterval == 0)
    {
        fLastInterval = tInterval;
        return;
    }
        // If we're 3 times slower than the last delay, assume this is a new delay,
    // empty the fSamples array, and start again.
    NSLog(@"fCurrentDelay * 3 = %d", fCurrentDelay * 3);
    NSLog(@"(tInterval - fLastInterval) * 1000 = %f", (tInterval - fLastInterval) * 1000);

    if (fCurrentDelay > 0 && ((tInterval - fLastInterval) * 1000 > 3 * fCurrentDelay))
    {
        [fSamples removeAllObjects];
        fSampleTail = 0;
        fLastInterval = tInterval;
        fCurrentDelay = 0;
        return;
    }
    
    DelaySample* newDelay = [[DelaySample alloc]init:fLastInterval andSecond: tInterval];
    fLastInterval = tInterval;
    if (fSampleTail <= fNumSamples - 1)
    {
        fSamples[fSampleTail] = newDelay;
        if (fSampleTail < fNumSamples)
        {
            fSampleTail++;
        }
    }
    else
    {
        // Remove the last element
        [fSamples removeLastObject];
        [fSamples insertObject:newDelay atIndex:0];
    }
    [self updateDelay];
}

-(uint32_t)getBpm
{
    if (fCurrentDelay == 0)
    {
        return 0;
    }
    else
    {
        NSNumber *num = [NSNumber numberWithDouble: MS_Per_M/(fCurrentDelay)];
        return (uint32_t)[num unsignedIntegerValue];
    }
    
}

-(void)reset
{
    fLastInterval = 0;
    fSampleTail = 0;
    fCurrentDelay = 0;
    [fSamples removeAllObjects];
}

@end