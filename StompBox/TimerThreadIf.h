//
//  TimerThreadIf.h
//  TimerPool
//
//  Created by Michael Webster on 22/02/2015.
//  Copyright (c) 2015 Mike Webster Ltd. All rights reserved.
//

#ifndef TimerPool_TimerThreadIf_h
#define TimerPool_TimerThreadIf_h
#import <Foundation/Foundation.h>
#import "TickResponder.h"

/**
 * The TimerThreadIf class provides an objective C interface to the
 * TimerThreaded C++ class real time timer class.
 *
 * The interface allows the user to:
 *
 * - Set a delay time in ms
 * - set a TickResponder that is called when a timer tick happends,
 * - A start timer method,
 * - A stop timer method,
 * - A kill timer method.
 *
 * TickResponder is a protocol that must be adopted by any class that wants
 * to receive ticks from the timer.
 */
@interface TimerThreadIf : NSObject

/**
 * The delay in ms that the timer is currently running on.
 */
@property (atomic)uint32_t fDelayMs;

/**
 * Set the delay for the timer.
 */
-(void)setDelay: (uint32_t)delay;

/**
 * Set the object to send the tick message to - the object must adopt the
 * TickResponder protocol.
 */
-(void)setTickResponder: (id<TickResponder>)tr;

/**
 * Initialise
 */
-(id)init;

/**
 * Initialise with a delay and a Tick Responder.
 */
-(id)init: (uint32_t)withDelay andTickResponder:(id<TickResponder>)resp;

/**
 * Setup the delay, and start the timer.
 */
-(void)startTimer;

/**
 * Stop the timer.
 */
-(void)stopTimer;

/**
 * Effectively stop the timer from running.
 *
 * FIXME: Perhaps need to clean up the thread here.
 */
-(void)killTimer;
@end
#endif
