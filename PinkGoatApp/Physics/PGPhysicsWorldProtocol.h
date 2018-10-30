//
//  PGPhysicsWorldProtocol.h
//  PinkGoatApp
//
//  Created by Roy Li on 10/29/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "../bullet/BulletCollision/btBulletCollisionCommon.h"
#import "../bullet/BulletDynamics/btBulletDynamicsCommon.h"

#ifndef PGPhysicsWorldProtocol_h
#define PGPhysicsWorldProtocol_h

@protocol PGPhysicsWorldProtocol

- (void)addRigidBody:(btRigidBody *)rigidBody;
- (void)stepSimulation:(NSTimeInterval)timeDelta;
- (int)getNumCollisionObjects;
- (btCollisionObjectArray&)getCollisionObjectArray;

@end

#endif /* PGPhysicsWorldProtocol_h */
