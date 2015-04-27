//
//  TimerThreadIf.m
//  TimerPool
//
//  Created by Michael Webster on 22/02/2015.
//  Copyright (c) 2015 Mike Webster Ltd. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "TimerThreaded.h"
#import "TimerThreadIf.h"

@implementation TimerThreadIf
{
    id<TickResponder> fTickResponder;
    TimerThreaded* fTimer;
    bool isRunning;
    NSOperationQueue* fOpQueue;
}

@synthesize fDelayMs;

-(id)init
{
    if (self = [super init])
    {
        fTimer = new TimerThreaded();
        isRunning = false;
        fTimer->setTimer();
        fOpQueue = [[NSOperationQueue alloc]init];
        [fOpQueue setQualityOfService:NSOperationQualityOfServiceUserInteractive];
    }
    return self;
}

-(id)init:(uint32_t)withDelay andTickResponder:(id<TickResponder>)resp
{
    if (self = [self init])
    {
        fDelayMs = withDelay;
        fTimer->setWaitTimeMs(fDelayMs);
        fTickResponder = resp;
    }
    return self;
}

-(void)setDelay:(uint32_t)delay
{
    fDelayMs = delay;
    fTimer->setWaitTimeMs(fDelayMs);
}

-(void)setTickResponder:(id<TickResponder>)tr
{
    fTickResponder = tr;
}

-(void)startTimer
{

    isRunning = TRUE;
    fTimer->startTimer();
    [fOpQueue addOperationWithBlock:
     ^{
         while (isRunning)
         {
             fTimer->mutexLock();
             [fTickResponder respondToTick];
         }
     }];

}

-(void)stopTimer
{
    isRunning = FALSE;
    fTimer->stopTimer();
}

-(void)killTimer
{
    fTimer->kill();
}

@end
