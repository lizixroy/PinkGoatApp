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
    for(id key in self.graphicalShapesRegistery) {
        PGShape *shape = self.graphicalShapesRegistery[key];
        [self.renderer registerShape:shape];
    }
    __weak PGSimulation *weakSelf = self;
    self.renderer.frameCompletion = ^{
        CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
        NSTimeInterval timeDelta = (weakSelf.lastUpdatedTime == 0) ? 0 : currentTime - self.lastUpdatedTime;
        weakSelf.lastUpdatedTime = currentTime;
//        NSLog(@"timeDelta: %f", timeDelta);
//        NSLog(@"now update physics...");
        //[weakSelf stepSimulationWithTimeDelta:timeDelta];
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
                shape.transfromInWorldSpace = transfromInWorldSpace;
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

@end