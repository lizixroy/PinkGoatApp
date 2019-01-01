//
//  PGRobot.h
//  PinkGoatApp
//
//  Created by Roy Li on 12/29/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGEntity.h"
#import "BulletInverseDynamics/MultiBodyTreeCreator.hpp"
#import "BulletDynamics/Featherstone/btMultiBody.h"
#import "PGEventSubscriber.h"
#import "PGRobotSubscriptionProtocols.h"

NS_ASSUME_NONNULL_BEGIN

@interface PGRobot : PGEntity <PGEventSubscriberProtocol>
{
    @public
    btInverseDynamicsBullet3::MultiBodyTree *multiBodyTree;
    btMultiBody* multiBody;
}

//@property (nonatomic, strong, readonly) NSMutableArray<NSNumber *> *jointVariables;

- (instancetype)initWithMultiBodyTree:(btInverseDynamicsBullet3::MultiBodyTree *)multiBodyTree
                            multiBody:(btMultiBody *)multiBody;


/**
 Add PID controllers to robot's joints.
 */
- (void)addJointControllers;


/**
 Add a subscriber to receive updates for joint variables. A subscriber will be added once, subsequent call with the
 same subscriber instance will be ignored.
 
 @param subscriber to be added
 */
- (void)addJointVariableSubscriber:(id<PGRobotJointVariablesSubscriber>)subscriber;

@end

NS_ASSUME_NONNULL_END
