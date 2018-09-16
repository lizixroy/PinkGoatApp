//
//  PGMainViewController.m
//  PinkGoatApp
//
//  Created by Roy Li on 9/4/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGMainViewController.h"
#import "BTMultiBodyDynamicsWorldWrapper.h"
#import "URDF2Bullet.h"
#import "BulletUrdfImporter.h"
#import "MyMultiBodyCreator.h"
#include "BulletDynamics/Featherstone/btMultiBodyDynamicsWorld.h"
#include "BulletDynamics/Featherstone/btMultiBody.h"
#import "BulletDynamics/Featherstone/btMultiBodyConstraintSolver.h"
#include "btDefaultCollisionConfiguration.h"
#import "bullet/BulletCollision/CollisionDispatch/btCollisionDispatcher.h"
#import "bullet/BulletCollision/BroadphaseCollision/btOverlappingPairCache.h"
#import "bullet/BulletCollision/BroadphaseCollision/btDbvtBroadphase.h"

@interface PGMainViewController () {
    btMultiBodyDynamicsWorld* m_dynamicsWorld;
    btMultiBody* m_multiBody;
    btAlignedObjectArray<btCollisionShape*>    m_collisionShapes;
    btDefaultCollisionConfiguration* m_collisionConfiguration;
    btCollisionDispatcher*    m_dispatcher;
    btOverlappingPairCache* m_pairCache;
    btBroadphaseInterface*    m_broadphase;
    btMultiBodyConstraintSolver*    m_solver;
}

@end

@implementation PGMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self importRobotModel];
}

// TODO: move this to model layer.
- (void)importRobotModel {
    
    [self createEmptyDynamicsWorld];
    
    BulletURDFImporter u2b(NULL,0,1,0);
    
    bool loadOk = u2b.loadURDF("/Users/royli/Documents/bullet3/data/kuka_iiwa/model.urdf");// lwr / kuka.urdf");
    if (loadOk)
    {
        int rootLinkIndex = u2b.getRootLinkIndex();
        MyMultiBodyCreator creation;
        btTransform identityTrans;
        identityTrans.setIdentity();
        
        ConvertURDF2Bullet(u2b, creation, identityTrans, m_dynamicsWorld, true,u2b.getPathPrefix());
        for (int i = 0; i < u2b.getNumAllocatedCollisionShapes(); i++)
        {
            m_collisionShapes.push_back(u2b.getAllocatedCollisionShape(i));
        }
        m_multiBody = creation.getBulletMultiBody();
        if (m_multiBody)
        {
            //kuka without joint control/constraints will gain energy explode soon due to timestep/integrator
            //temporarily set some extreme damping factors until we have some joint control or constraints
            m_multiBody->setAngularDamping(0*0.99);
            m_multiBody->setLinearDamping(0*0.99);
            printf("Root link name = %s",u2b.getLinkName(u2b.getRootLinkIndex()).c_str());
        }
    }

}

- (void)createEmptyDynamicsWorld
{
    ///collision configuration contains default setup for memory, collision setup
    m_collisionConfiguration = new btDefaultCollisionConfiguration();
    //m_collisionConfiguration->setConvexConvexMultipointIterations();
//    m_filterCallback = new MyOverlapFilterCallback2();
    
    ///use the default collision dispatcher. For parallel processing you can use a diffent dispatcher (see Extras/BulletMultiThreaded)
    m_dispatcher = new    btCollisionDispatcher(m_collisionConfiguration);
    
    m_pairCache = new btHashedOverlappingPairCache();
    
//    m_pairCache->setOverlapFilterCallback(m_filterCallback);
    
    m_broadphase = new btDbvtBroadphase(m_pairCache);//btSimpleBroadphase();
    
    m_solver = new btMultiBodyConstraintSolver;
    
    m_dynamicsWorld = new btMultiBodyDynamicsWorld(m_dispatcher, m_broadphase, m_solver, m_collisionConfiguration);
    
    m_dynamicsWorld->setGravity(btVector3(0, -10, 0));

}

@end
