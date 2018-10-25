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
#import "bullet/BulletCollision/CollisionDispatch/btCollisionObject.h"
#import "bullet/BulletCollision/BroadphaseCollision/btOverlappingPairCache.h"
#import "bullet/BulletCollision/BroadphaseCollision/btDbvtBroadphase.h"
#import "PGShape.h"
#import "PGVertexObject.h"
#import "PGRenderer.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "PGLogger.h"
#import "PGShapeFactory.h"
#import "PGSimulation.h"
#include "btBulletDynamicsCommon.h"

@interface PGMainViewController () {
    btMultiBodyDynamicsWorld* m_dynamicsWorld;
    btMultiBody* m_multiBody;
    btAlignedObjectArray<btCollisionShape*>    m_collisionShapes;
    btDefaultCollisionConfiguration* m_collisionConfiguration;
    btCollisionDispatcher*    m_dispatcher;
    btOverlappingPairCache* m_pairCache;
    btBroadphaseInterface*    m_broadphase;
    btMultiBodyConstraintSolver*    m_solver;
    MTKView *_view;
}

@property (nonatomic, strong) PGRenderer *renderer;
@property (nonatomic, strong) PGSimulation *simulation;

@end

@implementation PGMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    _view = (MTKView *)self.view;
    _view.device = MTLCreateSystemDefaultDevice();
    self.renderer = [[PGRenderer alloc] initWithMetalKitView:((MTKView *)self.view)];
    [self.renderer mtkView:_view drawableSizeWillChange:_view.drawableSize];
    _view.delegate = self.renderer;
    
    _simulation = [[PGSimulation alloc] init];
    _simulation.renderer = self.renderer;
    
    [self createEmptyDynamicsWorld];
    self.simulation->physicsWorld = m_dynamicsWorld;

    [self setupPhysicalWorld:m_dynamicsWorld];
    [self importRobotModel];
}

// TODO: move this to model layer.
- (void)importRobotModel {
    
    BulletURDFImporter u2b(NULL,0,1,0);
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"cougarbot" ofType:@"urdf"];
//    bool loadOk = u2b.loadURDF(path.UTF8String);// lwr / kuka.urdf");
    bool loadOk = u2b.loadURDF("/Users/royli/Documents/projects/bullet3/data/kuka_iiwa/model.urdf");// lwr / kuka.urdf");
    if (loadOk)
    {
        // Creating physical representation.
        MyMultiBodyCreator creation;
        btTransform identityTrans;
        identityTrans.setIdentity();
        ConvertURDF2Bullet(u2b, creation, identityTrans, m_dynamicsWorld, true,u2b.getPathPrefix(), self.simulation);
        for (int i = 0; i < u2b.getNumAllocatedCollisionShapes(); i++)
        {
            m_collisionShapes.push_back(u2b.getAllocatedCollisionShape(i));
        }
        m_multiBody = creation.getBulletMultiBody();
        [self.simulation beginSimulation];
    }
}

// This is where basic physical objects are placed in the simulation
// This method will be replaced later on with ways to create new simulation in the app directly.
- (void)setupPhysicalWorld:(btMultiBodyDynamicsWorld *)world
{
    // Add a box
    
    btTransform startTransform;
    startTransform.setIdentity();
    // TODO: study the coordinate frame of Metal
    startTransform.setOrigin(btVector3(0, 1, 0));
    btScalar mass(1.f);
    btVector3 localInertia(0, 0, 0);
    btBoxShape *colShape = new btBoxShape(btVector3(0.1, 0.1, 0.1));
    colShape->calculateLocalInertia(mass, localInertia);
    btRigidBody::btRigidBodyConstructionInfo rbInfo(mass, 0, colShape, localInertia);
    rbInfo.m_startWorldTransform = startTransform;
    btRigidBody* body = new btRigidBody(rbInfo);
    body->setRollingFriction(0.03);
    body->setSpinningFriction(0.03);
    body->setFriction(1);
    body->setAnisotropicFriction(colShape->getAnisotropicRollingFrictionDirection(), btCollisionObject::CF_ANISOTROPIC_ROLLING_FRICTION);
    world->addRigidBody(body);
    
    // Add a cynlinder
    
    btTransform startTransform2;
    startTransform2.setIdentity();
    // TODO: study the coordinate frame of Metal
    startTransform2.setOrigin(btVector3(0, 0, 2));
    btScalar mass2(1.f);
    btVector3 localInertia2(0, 0, 0);
    btCylinderShape *colShape2 = new btCylinderShape(btVector3(0.2, 0.2, 0.2));
    colShape2->calculateLocalInertia(mass, localInertia);
    btRigidBody::btRigidBodyConstructionInfo rbInfo2(mass2, 0, colShape2, localInertia);
    rbInfo2.m_startWorldTransform = startTransform2;
    btRigidBody* body2 = new btRigidBody(rbInfo2);
    body2->setRollingFriction(0.03);
    body2->setSpinningFriction(0.03);
    body2->setFriction(1);
    body2->setAnisotropicFriction(colShape2->getAnisotropicRollingFrictionDirection(), btCollisionObject::CF_ANISOTROPIC_ROLLING_FRICTION);
    world->addRigidBody(body2);
}

- (void)createEmptyDynamicsWorld
{
    m_collisionConfiguration = new btDefaultCollisionConfiguration();
    m_dispatcher = new    btCollisionDispatcher(m_collisionConfiguration);
    m_pairCache = new btHashedOverlappingPairCache();
    m_broadphase = new btDbvtBroadphase(m_pairCache);//btSimpleBroadphase();
    m_solver = new btMultiBodyConstraintSolver;
    m_dynamicsWorld = new btMultiBodyDynamicsWorld(m_dispatcher, m_broadphase, m_solver, m_collisionConfiguration);
    m_dynamicsWorld->setGravity(btVector3(0, -10, 0));
}

@end
