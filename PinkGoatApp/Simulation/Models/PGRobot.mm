//
//  PGRobot.mm
//  PinkGoatApp
//
//  Created by Roy Li on 12/29/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGRobot.h"
#import "PGPIDController.h"
#import "BulletDynamics/Featherstone/btMultiBodyJointMotor.h"

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
        _desiredJointVariables = [[NSMutableArray alloc] init];
        int numberOfJoints = multiBody->getNumDofs();
        // Set robot to home position by default.
        for (int i = 0; i < numberOfJoints; i++) {
            [_desiredJointVariables addObject:@0];
        }
        _jointControllers = [[NSMutableArray alloc] init];
        _jointVariableSubscribers = [[NSMutableArray alloc] init];
        _jointMotors = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)update
{
    const int num_dofs = multiBody->getNumDofs();
    btInverseDynamics::vecx nu(num_dofs), qdot(num_dofs), q(num_dofs), joint_force(num_dofs);
    btInverseDynamics::vecx pd_control(num_dofs);
    NSMutableArray<NSNumber *> *jointVariables = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < num_dofs; i++) {
        q(i) = multiBody->getJointPos(i);
        qdot(i) = multiBody->getJointVel(i);
        [jointVariables addObject: @(q(i))];
        if (i >= self.jointControllers.count) {
            continue;
        }
        PGPIDController *controller = [self.jointControllers objectAtIndex:i];
        // TODO: need to set the position from user's codebase. For now use 0.
        float reference = self.desiredJointVariables[i].floatValue;
        nu(i) = [controller computeControlSignalWithReference:reference
                                                            currentPosition:q(i)
                                                            currentVelocity:qdot(i)];
    }
    if (self->multiBodyTree->calculateInverseDynamics(q, qdot, nu, &joint_force) != -1) {
        for (int i = 0; i < joint_force.size(); i++) {
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

- (BOOL)supportsJointMotorWithLinkIndex:(int)multiBodyLinkIndex
{
    bool supportMotor = (self->multiBody->getLink(multiBodyLinkIndex).m_jointType == btMultibodyLink::eRevolute || self->multiBody->getLink(multiBodyLinkIndex).m_jointType == btMultibodyLink::ePrismatic);
    return supportMotor;
}

- (void)createJointMotors
{
    int numLinks = self->multiBody->getNumLinks();
    for (int i = 0; i < numLinks; i++)
    {
        int mbLinkIndex = i;
        
        if ([self supportsJointMotorWithLinkIndex:mbLinkIndex])
        {
            float maxMotorImpulse = 1.f;
            int dof = 0;
            btScalar desiredVelocity = 0.f;
            btMultiBodyJointMotor* motor = new btMultiBodyJointMotor(self->multiBody, mbLinkIndex, dof, desiredVelocity, maxMotorImpulse);
            motor->setPositionTarget(0, 0);
            motor->setVelocityTarget(0, 1);
            //motor->setRhsClamp(gRhsClamp);
            //motor->setMaxAppliedImpulse(0);
            self->multiBody->getLink(mbLinkIndex).m_userPtr = motor;
            
            JointMotor *jointMotor = [[JointMotor alloc] init];
            jointMotor->motor = motor;
            [self.jointMotors addObject:jointMotor];
//            m_data->m_dynamicsWorld->addMultiBodyConstraint(motor);
            motor->finalizeMultiDof();
        }
    }
}

@end
