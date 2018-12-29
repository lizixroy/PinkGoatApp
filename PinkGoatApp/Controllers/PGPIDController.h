//
//  PGPIDController.h
//  PinkGoatApp
//
//  Created by Roy Li on 12/28/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGRobotController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PGPIDController : NSObject <PGRobotController>

@property (nonatomic, assign) float proportionalGain;
@property (nonatomic, assign) float integralGain;
@property (nonatomic, assign) float derivativeGain;

- (instancetype)initWithProportionalGain:(float)proportionalGain
                            integralGain:(float)integralGain
                          derivativeGain:(float)derivativeGain;

- (float)computeControlSignalWithReference:(float)desiredReference
                           currentPosition:(float)currentPosition
                           currentVelocity:(float)currentVelocity;
@end

NS_ASSUME_NONNULL_END
