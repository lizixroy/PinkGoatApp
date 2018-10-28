//
//  PGSimulation.m
//  PinkGoatApp
//
//  Created by Roy Li on 10/24/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGSimulation.h"
#import "../bullet/BulletCollision/CollisionShapes/btCollisionShape.h"
#import "GLInstanceGraphicsShape.h"
#import "PGObjcMathUtilities.h"
#import "PGCollisionShapeGraphicsGenerator.h"
#import "PGMatrixLogger.h"

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
    [self generateGraphicsForCollisionObjectsInWorld:physicsWorld];
    [self setupScene];
    for(id key in self.graphicalShapesRegistery) {
        PGShape *shape = self.graphicalShapesRegistery[key];
        [self.renderer registerShape:shape];
    }
    __weak PGSimulation *weakSelf = self;
    self.renderer.frameCompletion = ^{
        CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
        NSTimeInterval timeDelta = (weakSelf.lastUpdatedTime == 0) ? 0 : currentTime - self.lastUpdatedTime;
        weakSelf.lastUpdatedTime = currentTime;
        [weakSelf syncPhysicsToGraphics];
    };
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

/*!
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

- (void)setupScene
{
    
    
    // create a new scene
    SCNScene *scene = self.scene;
    
    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, -3, 0);
    
    vector_float3 eulerAngles = { M_PI / 2, 0, 0 };
    cameraNode.simdEulerAngles = eulerAngles;
    
    [scene.rootNode addChildNode:cameraNode];
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];

    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = cameraNode.position; //SCNVector3Make(10, -10, 0);
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [NSColor darkGrayColor];
    [scene.rootNode addChildNode:ambientLightNode];
    
    // retrieve the ship node
    NSArray<PGShape *> *shapes = self.graphicalShapesRegistery.allValues;
    for (PGShape *shape in shapes) {
        SCNNode *node = shape.sceneNode; //[scene.rootNode childNodeWithName:@"ship" recursively:YES];
        // animate the 3d object
        [scene.rootNode addChildNode:node];
    }
    
//    // retrieve the SCNView
//    SCNView *scnView = (SCNView *)self.view;
//
//    // set the scene to the view
//    scnView.scene = scene;
//
//    // allows the user to manipulate the camera
//    scnView.allowsCameraControl = YES;
//
//    // show statistics such as fps and timing information
//    scnView.showsStatistics = YES;
//
//    // configure the view
//    scnView.backgroundColor = [NSColor blackColor];
    
    // Add a click gesture recognizer
//    NSClickGestureRecognizer *clickGesture = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//    NSMutableArray *gestureRecognizers = [NSMutableArray array];
//    [gestureRecognizers addObject:clickGesture];
//    [gestureRecognizers addObjectsFromArray:scnView.gestureRecognizers];
//    scnView.gestureRecognizers = gestureRecognizers;
}

@end
