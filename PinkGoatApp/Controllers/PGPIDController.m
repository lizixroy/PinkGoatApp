//
//  PGPIDController.m
//  PinkGoatApp
//
//  Created by Roy Li on 12/28/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGPIDController.h"

@implementation PGPIDController

- (instancetype)initWithProportionalGain:(float)proportionalGain
                            integralGain:(float)integralGain
                          derivativeGain:(float)derivativeGain;
{
    self = [super init];
    if (self) {
        _proportionalGain = proportionalGain;
        _integralGain = integralGain;
        _derivativeGain = derivativeGain;
    }
    return self;
}

- (float)computeControlSignalWithReference:(float)desiredReference
                           currentPosition:(float)currentPosition
                           currentVelocity:(float)currentVelocity
{
    return self.derivativeGain * (0 - currentVelocity) + self.proportionalGain * (desiredReference - currentPosition);
}

@end
