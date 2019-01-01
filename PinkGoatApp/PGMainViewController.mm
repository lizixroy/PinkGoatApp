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
#import "PGLogger.h"
#import "PGShapeFactory.h"
#import "PGSimulation.h"
#include "btBulletDynamicsCommon.h"
#import "PGMTKView.h"
#import <SceneKit/SceneKit.h>
#import "bullet/BulletCollision/btBulletCollisionCommon.h"
#include "BulletInverseDynamics/MultiBodyTreeCreator.hpp"
#include "BulletInverseDynamics/btMultiBodyTreeCreator.hpp"
#import "PGRobot.h"
#import "PGTimeSeriesViewController.h"

@interface PGMainViewController () {
    btMultiBodyDynamicsWorld* m_dynamicsWorld;
    btMultiBody* m_multiBody;
    btInverseDynamicsBullet3::MultiBodyTree* m_multiBodyTree;
    
    btAlignedObjectArray<btCollisionShape*>    m_collisionShapes;
    btDefaultCollisionConfiguration* m_collisionConfiguration;
    btCollisionDispatcher*    m_dispatcher;
    btOverlappingPairCache* m_pairCache;
    btBroadphaseInterface*    m_broadphase;
    btMultiBodyConstraintSolver*    m_solver;
    SCNView *_view;
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
    _view = (SCNView *)self.view;
    self.renderer = [[PGRenderer alloc] init];
    
    SCNScene *scene = [[SCNScene alloc] init];
    _view.scene = scene;
    _view.backgroundColor = [NSColor colorWithDeviceRed:0.6980 green:0.6980 blue:0.7922 alpha:1.0];
    _view.delegate = self.renderer;
    _view.allowsCameraControl = YES;
    _view.loops = YES;
    
    _simulation = [[PGSimulation alloc] initWithScene:scene];
    _simulation.renderer = self.renderer;

    [self createEmptyDynamicsWorld];
    self.simulation->physicsWorld = m_dynamicsWorld;
    [self importRobotModel];
    [self.simulation beginSimulation];
    [self showTimeSeriesViewForRobot:self.simulation.robot];
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
    }
    
    // Create multibody tree
    btInverseDynamics::btMultiBodyTreeCreator id_creator;
    if (-1 == id_creator.createFromBtMultiBody(m_multiBody, false))
    {
        b3Error("error creating tree\n");
    }
    else
    {
        m_multiBodyTree = btInverseDynamics::CreateMultiBodyTree(id_creator);
    }
    
    PGRobot *robot = [[PGRobot alloc] initWithMultiBodyTree:m_multiBodyTree multiBody:m_multiBody];
    [robot addJointControllers];
    self.simulation.robot = robot;
    [self.simulation addUpdateSubscription:robot];
}

- (void)createEmptyDynamicsWorld
{
    m_collisionConfiguration = new btDefaultCollisionConfiguration();
    m_dispatcher = new    btCollisionDispatcher(m_collisionConfiguration);
    m_pairCache = new btHashedOverlappingPairCache();
    m_broadphase = new btDbvtBroadphase(m_pairCache);//btSimpleBroadphase();
    m_solver = new btMultiBodyConstraintSolver;
    m_dynamicsWorld = new btMultiBodyDynamicsWorld(m_dispatcher, m_broadphase, m_solver, m_collisionConfiguration);
    m_dynamicsWorld->setGravity(btVector3(0, 0, -10));
}

- (void)showTimeSeriesViewForRobot:(PGRobot *)robot
{
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"PGTimeSeriesViewController" bundle:[NSBundle mainBundle]];
    PGTimeSeriesViewController *viewController = [storyboard instantiateControllerWithIdentifier:@"PGTimeSeriesViewController"];
    if (viewController == nil) {
        return;
    }
    [viewController setupWithJointCount:robot->multiBody->getNumDofs()];
    NSWindow *window = [NSWindow windowWithContentViewController:viewController];
    NSWindowController *wc = [[NSWindowController alloc] initWithWindow:window];
    [wc showWindow:wc];
    [robot addJointVariableSubscriber:viewController];
}
    
 

@end
