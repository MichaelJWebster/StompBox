//
//  CalcDelay.h
//  StompBox
//
//  Created by Michael Webster on 15/03/2015.
//  Copyright (c) 2015 Mike Webster Ltd. All rights reserved.
//

#ifndef StompBox_CalcDelay_h
#define StompBox_CalcDelay_h
#import "DelaySample.h"

@interface CalcDelay : NSObject
@property (atomic)uint32_t fCurrentDelay;
-(id)init;
-(id)init: (NSTimeInterval)withFirstSample;
-(id)init: (NSTimeInterval)withFirstSample andNumSamples:(int)numSamples;
-(void)setNumSamples: (int)numSamples;
-(void)addInterval: (NSTimeInterval)tInterval;
-(uint32_t)getBpm;
-(void)reset;
@end

#endif
