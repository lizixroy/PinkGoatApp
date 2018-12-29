//
//  PGSimulation.m
//  PinkGoatApp
//
//  Created by Roy Li on 10/24/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGSimulation.h"
#import "../bullet/BulletCollision/btBulletCollisionCommon.h"
#import "../bullet/BulletDynamics/btBulletDynamicsCommon.h"
#import "GLInstanceGraphicsShape.h"
#import "PGObjcMathUtilities.h"
#import "PGCollisionShapeGraphicsGenerator.h"
#import "PGMatrixLogger.h"


static NSTimeInterval MIN_SIM_ADVANCE_TIME_DELTA_IN_SECONDS = 0.001; // 1 milliseconds.
static NSTimeInterval MAX_SIM_ADVANCE_TIME_DELTA_IN_SECONDS = 0.1; // 100 millseconds
static NSTimeInterval SIM_SLEEP_IN_SECONDS = 0.0001; // 0.1 milliseconds

@interface PGSimulation()

@property (assign) int lastIndex;
@property (assign) NSTimeInterval lastUpdatedTime;

@end

@implementation PGSimulation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lastIndex = -1;
        _graphicalShapesRegistery = [[NSMutableDictionary alloc] init];
        _terminated = NO;
    }
    return self;
}

- (instancetype)initWithScene:(SCNScene *)scene;
{
    self = [self init];
    if (self) {
        _scene = scene;
    }
    return self;
}

- (int)registerShape:(PGShape *)shape
{
    int index = _lastIndex + 1;
    self.graphicalShapesRegistery[[NSNumber numberWithInt:index]] = shape;
    _lastIndex = index;
    return index;
}

- (void)beginSimulation
{
    [self setup];
    __weak PGSimulation *weakSelf = self;
    self.renderer.frameCompletionAtSystemTime = ^(NSTimeInterval time) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf advanceSimulationWithSystemTime:time];
        });
    };
}

/**
    Advance the simulation loop for timeDelta.
    @param time system time in seconds.
 */
- (void)advanceSimulationWithSystemTime:(NSTimeInterval)time
{
    NSTimeInterval timeDelta = (self.lastUpdatedTime == 0) ? MIN_SIM_ADVANCE_TIME_DELTA_IN_SECONDS : time - self.lastUpdatedTime;
    if (timeDelta > MAX_SIM_ADVANCE_TIME_DELTA_IN_SECONDS) {
        timeDelta = MAX_SIM_ADVANCE_TIME_DELTA_IN_SECONDS;
    }
    if (timeDelta < MIN_SIM_ADVANCE_TIME_DELTA_IN_SECONDS) {
        [NSThread sleepForTimeInterval:SIM_SLEEP_IN_SECONDS];
    } else {
        self.lastUpdatedTime = time;
        [self stepSimulationWithTimeDelta:timeDelta];
        [self syncPhysicsToGraphics];
    }
}

- (void)stepSimulationWithTimeDelta:(NSTimeInterval)timeDelta
{
    self->physicsWorld->stepSimulation(timeDelta);
}

- (void)syncPhysicsToGraphics
{
    int numCollisionObjects = physicsWorld->getNumCollisionObjects();
    {
        for (int i = 0; i < numCollisionObjects; i++)
        {
            btCollisionObject* colObj = physicsWorld->getCollisionObjectArray()[i];
            btCollisionShape* collisionShape = colObj->getCollisionShape();
            int index = collisionShape->getUserIndex();
            if (index >= 0)
            {
                matrix_float4x4 transfromInWorldSpace = [PGObjcMathUtilities getMatrixFromTransfrom:colObj->getWorldTransform()];
                PGShape *shape = self.graphicalShapesRegistery[[NSNumber numberWithInt:index]];
                shape.sceneNode.simdTransform = transfromInWorldSpace;
            }
        }
    }
}

/*!å
 @abstract Generate graphical representation for collision shapes that do not have graphics yet (i.e., not imported from files)
 @param world The Physics world whose shapes we try to generate graphics for.
 */
- (void)generateGraphicsForCollisionObjectsInWorld:(btDiscreteDynamicsWorld *)world
{
    btAlignedObjectArray<btCollisionObject *> collisionObjects = world->getCollisionObjectArray();
    PGCollisionShapeGraphicsGenerator *graphicsGenerator = [[PGCollisionShapeGraphicsGenerator alloc] init];
    for (int i = 0; i < collisionObjects.size(); i++) {
        btCollisionObject *obj = collisionObjects[i];
        btCollisionShape *shape = obj->getCollisionShape();
        if ([self.graphicalShapesRegistery objectForKey:[NSNumber numberWithInt:shape->getUserIndex()]] != nil) {
            continue;
        }
        PGShape *graphicalShape = [graphicsGenerator generateGraphicsForCollisionShape:shape];
        int index = [self registerShape:graphicalShape];
        shape->setUserIndex(index);
    }
}

/**
 This method sets up default settings for each simulation, which includes adding basic world element (ground plane, etc.)
 amd set up scene for rendering.
 */
- (void)setup
{
    [self createGroundPlane];
    [self generateGraphicsForCollisionObjectsInWorld:physicsWorld];
    [self setupScene];
}

- (void)createGroundPlane
{
    btCollisionShape* groundShape = new btBoxShape(btVector3(btScalar(50.), btScalar(50.), btScalar(50.)));
    btTransform groundTransform;
    groundTransform.setIdentity();
    groundTransform.setOrigin(btVector3(0, 0, -50));
    btScalar mass(0.);
    btVector3 localInertia(0, 0, 0);
    btDefaultMotionState* myMotionState = new btDefaultMotionState(groundTransform);
    btRigidBody::btRigidBodyConstructionInfo rbInfo(mass, myMotionState, groundShape, localInertia);
    btRigidBody* body = new btRigidBody(rbInfo);
    body->setFriction(1);
    //add the body to the dynamics world
    self->physicsWorld->addRigidBody(body);
    PGCollisionShapeGraphicsGenerator *graphicsGenerator = [[PGCollisionShapeGraphicsGenerator alloc] init];
    PGShape *graphicalShape = [graphicsGenerator generateGraphicsForCollisionShape:groundShape];
    
    [graphicalShape setColor:[NSColor colorWithDeviceRed:0.1451 green:0.2431 blue:0.6196 alpha:1.0]];
    int index = [self registerShape:graphicalShape];
    groundShape->setUserIndex(index);
}

- (void)setupScene
{
    // create a new scene
    SCNScene *scene = self.scene;
    
    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.camera.zNear = 0.1;
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, -3, 1);
    vector_float3 eulerAngles = { M_PI / 2, 0, 0 };
    cameraNode.simdEulerAngles = eulerAngles;
    
    [scene.rootNode addChildNode:cameraNode];
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];

    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    
    // TODO: Now I'm having a hard time figuring out what each position mean in my current scene. This needs to be sorted out before proceed.
    
    lightNode.position = SCNVector3Make(0, -100, 100); //cameraNode.position;
    
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [NSColor darkGrayColor];
    [scene.rootNode addChildNode:ambientLightNode];
    
    NSArray<PGShape *> *shapes = self.graphicalShapesRegistery.allValues;
    for (PGShape *shape in shapes) {
        SCNNode *node = shape.sceneNode;
        [scene.rootNode addChildNode:node];
    }
}

@end
