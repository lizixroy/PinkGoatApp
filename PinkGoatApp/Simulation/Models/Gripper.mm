//
//  Gripper.m
//  PinkGoatApp
//
//  Created by Roy Li on 3/4/19.
//  Copyright © 2019 Roy Li. All rights reserved.
//

#import "Gripper.h"

@implementation Gripper

// This class simulates an external robot controller that would be running outside TL.

- (void)close;
{
    NSLog(@"Closing");
    
//    motor->setVelocityTarget(desiredVelocity, kd);

}

- (void)open;
{
    NSLog(@"Openning");
}

@end
