//
//  BTMultiBodyDynamicsWorld.m
//  PinkGoatApp
//
//  Created by Roy Li on 9/4/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "BTMultiBodyDynamicsWorld.h"
#include "BulletDynamics/Featherstone/btMultiBodyDynamicsWorld.h"
#include "BulletDynamics/Featherstone/btMultiBodyConstraintSolver.h"
#include "BulletDynamics/Featherstone/btMultiBodyPoint2Point.h"
#include "BulletDynamics/Featherstone/btMultiBodyLinkCollider.h"
#include "BulletCollision/CollisionDispatch/btDefaultCollisionConfiguration.h"
#include "BulletCollision/BroadphaseCollision/btDbvtBroadphase.h"

@interface BTMultiBodyDynamicsWorldWrapper() {
    btMultiBodyDynamicsWorld *_dynamicsWorld;
}
@end

@implementation BTMultiBodyDynamicsWorldWrapper

- (instancetype)init {
    self = [super init];
    if (self) {
        btDefaultCollisionConfiguration *m_collisionConfiguration = new btDefaultCollisionConfiguration();
        btCollisionDispatcher *m_dispatcher = new btCollisionDispatcher(m_collisionConfiguration);
        btDbvtBroadphase *m_broadphase = new btDbvtBroadphase();
        btMultiBodyConstraintSolver *m_solver = new btMultiBodyConstraintSolver();
        btMultiBodyDynamicsWorld *m_dynamicsWorld = new btMultiBodyDynamicsWorld(m_dispatcher, m_broadphase, m_solver, m_collisionConfiguration);
        m_dynamicsWorld->setGravity(btVector3(0, -10, 0));
        _dynamicsWorld = m_dynamicsWorld;
    }
    return self;
}

@end
