//
//  DelaySample.h
//  StompBox
//
//  Created by Michael Webster on 14/03/2015.
//  Copyright (c) 2015 Mike Webster Ltd. All rights reserved.
//

#ifndef StompBox_DelaySample_h
#define StompBox_DelaySample_h
#import <Foundation/Foundation.h>

@interface DelaySample : NSObject

@property (atomic)NSTimeInterval fFirstSample;
@property (atomic)NSTimeInterval fSecondSample;
@property (atomic)uint32_t fDelayMs;


-(id)init: (NSTimeInterval)withFirst andSecond:(NSTimeInterval)secondSample;

@end
#endif
