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

NS_ASSUME_NONNULL_BEGIN

@interface PGRobot : PGEntity <PGEventSubscriberProtocol>
{
    btInverseDynamicsBullet3::MultiBodyTree *multiBodyTree;
    btMultiBody* multiBody;
}

- (instancetype)initWithMultiBodyTree:(btInverseDynamicsBullet3::MultiBodyTree *)multiBodyTree
                            multiBody:(btMultiBody *)multiBody;


/**
 Add PID controllers to robot's joints.
 */
- (void)addJointControllers;

@end

NS_ASSUME_NONNULL_END
