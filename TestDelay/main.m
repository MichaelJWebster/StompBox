//
//  main.m
//  TestDelay
//
//  Created by Michael Webster on 15/03/2015.
//  Copyright (c) 2015 Mike Webster Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalcDelay.h"

static NSTimeInterval* getSamples(double numSeconds);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        NSTimeInterval *samples = getSamples(1.0);
        CalcDelay *cd = [[CalcDelay alloc]init: samples[0]];
        for (int i = 1; i < 10; i++)
        {
            NSLog(@"Adding interval = %f\n", samples[i]);
            [cd addInterval:samples[i]];
            NSLog(@"Current Delay is: %d", [cd fCurrentDelay] );
            NSLog(@"Current BPM is: %d", [cd getBpm]);
        }
    }
    return 0;
}

NSTimeInterval* getSamples(double numSeconds)
{
    static NSTimeInterval samples[10];
        //NSMutableArray* samples = [NSMutableArray arrayWithCapacity:numSamples];
    
    NSTimeInterval tStart = 1.0;
    for (int i = 0; i < 10; i++)
    {
        samples[i] = tStart + i * numSeconds;

    }
    return samples;
    
}