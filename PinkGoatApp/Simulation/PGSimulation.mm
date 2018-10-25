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

//void OpenGLGuiHelper::autogenerateGraphicsObjects(btDiscreteDynamicsWorld* rbWorld)
//{
//    //sort the collision objects based on collision shape, the gfx library requires instances that re-use a shape to be added after eachother
//
//    btAlignedObjectArray<btCollisionObject*> sortedObjects;
//    sortedObjects.reserve(rbWorld->getNumCollisionObjects());
//    for (int i=0;i<rbWorld->getNumCollisionObjects();i++)
//    {
//        btCollisionObject* colObj = rbWorld->getCollisionObjectArray()[i];
//        sortedObjects.push_back(colObj);
//    }
//    sortedObjects.quickSort(shapePointerCompareFunc);
//    for (int i=0;i<sortedObjects.size();i++)
//    {
//        btCollisionObject* colObj = sortedObjects[i];
//        //btRigidBody* body = btRigidBody::upcast(colObj);
//        //does this also work for btMultiBody/btMultiBodyLinkCollider?
//        btSoftBody* sb = btSoftBody::upcast(colObj);
//        if (sb)
//        {
//            colObj->getCollisionShape()->setUserPointer(sb);
//        }
//        createCollisionShapeGraphicsObject(colObj->getCollisionShape());
//        int colorIndex = colObj->getBroadphaseHandle()->getUid() & 3;
//
//        btVector4 color;
//        color = sColors[colorIndex];
//        if (colObj->getCollisionShape()->getShapeType()==STATIC_PLANE_PROXYTYPE)
//        {
//            color.setValue(1,1,1,1);
//        }
//        createCollisionObjectGraphicsObject(colObj,color);
//
//    }
//}
@end
