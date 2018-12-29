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
    }
    return self;
}

- (void)update
{
    NSLog(@"Receive update from simulation");
    const int num_dofs = multiBody->getNumDofs();
    for (int i = 0; i < num_dofs; i++) {
        float jointPosition = multiBody->getJointPos(i);
        float jointVelocity = multiBody->getJointVel(i);
        PGPIDController *controller = [self.jointControllers objectAtIndex:i];
        float controlSignal = [controller computeControlSignalWithReference:0
                                                            currentPosition:jointPosition
                                                            currentVelocity:jointVelocity];
//        if (-1 != self->multiBodyTree->calculateInverseDynamics(q, qdot, nu, &joint_force)) {
//
//        }
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

@end
