//
//  PGRobot.mm
//  PinkGoatApp
//
//  Created by Roy Li on 12/29/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGRobot.h"
#import "PGPIDController.h"

@interface PGRobot()

@property (nonatomic, strong) NSMutableArray<id<PGRobotController>> *jointControllers;
@property (nonatomic, strong) NSMutableArray<id<PGRobotJointVariablesSubscriber>> *jointVariableSubscribers;

@end

@implementation PGRobot

- (instancetype)initWithMultiBodyTree:(btInverseDynamicsBullet3::MultiBodyTree *)multiBodyTree
                            multiBody:(btMultiBody *)multiBody
{
    self = [super init];
    if (self) {
        self->multiBody = multiBody;
        self->multiBodyTree = multiBodyTree;
        _jointControllers = [[NSMutableArray alloc] init];
        _jointVariableSubscribers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)update
{
    NSLog(@"Receive update from simulation");
    const int num_dofs = multiBody->getNumDofs();
    btInverseDynamics::vecx nu(num_dofs), qdot(num_dofs), q(num_dofs), joint_force(num_dofs);
    btInverseDynamics::vecx pd_control(num_dofs);
    NSMutableArray<NSNumber *> *jointVariables = [[NSMutableArray alloc] init];
    for (int i = 0; i < num_dofs; i++) {
        q(i) = multiBody->getJointPos(i);
        qdot(i) = multiBody->getJointVel(i);
        [jointVariables addObject: @(q(i))];
        PGPIDController *controller = [self.jointControllers objectAtIndex:i];
        // TODO: need to set the position from user's codebase. For now use 0.
        float reference = 0.0f;
        nu(i) = [controller computeControlSignalWithReference:reference
                                                            currentPosition:q(i)
                                                            currentVelocity:qdot(i)];
    }
    if (self->multiBodyTree->calculateInverseDynamics(q, qdot, nu, &joint_force) != -1) {
        NSLog(@"joint_force:");
        for (int i = 0; i < joint_force.size(); i++) {
            NSLog(@"%f", joint_force[i]);
//            self->multiBody->addJointTorque(i, joint_force(i));
        }
    }
    
    // update subscribers of this robot
    for (id<PGRobotJointVariablesSubscriber> subscriber in self.jointVariableSubscribers) {
        [subscriber updateWithJointVariables:[NSArray arrayWithArray:jointVariables]];
    }
    
}

- (void)addJointControllers
{
    const int num_dofs = multiBody->getNumDofs();
    for (int i = 0; i < num_dofs; i++) {
        // For now, we use a PD controller as shown in Bullet's InverseDynamics example.
        static float kp = 10 * 10;
        static float kd = 2 * 10;
        PGPIDController *pidController = [[PGPIDController alloc] initWithProportionalGain:kp
                                                                              integralGain:0
                                                                            derivativeGain:kd];
        [self.jointControllers addObject:pidController];
    }
}

- (void)addJointVariableSubscriber:(id<PGRobotJointVariablesSubscriber>)subscriber
{
    if ([self.jointVariableSubscribers containsObject:subscriber]) {
        return;
    }
    [self.jointVariableSubscribers addObject:subscriber];
}

@end
