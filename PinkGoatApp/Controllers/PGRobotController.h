//
//  PGRobotController.h
//  PinkGoatApp
//
//  Created by Roy Li on 11/17/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../bullet/BulletDynamics/btBulletDynamicsCommon.h"
#import "../bullet/BulletDynamics/Featherstone/btMultiBody.h"

NS_ASSUME_NONNULL_BEGIN

@interface PGRobotController : NSObject
{
    @public
    btMultiBody* m_multiBody;
}

/*!
    @brief Let the robot controled by the controller to hold current positions.
 */
- (void)holdPosition;

@end

NS_ASSUME_NONNULL_END
