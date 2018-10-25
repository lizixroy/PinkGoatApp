//
//  PGSimulation.m
//  PinkGoatApp
//
//  Created by Roy Li on 10/24/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGSimulation.h"

@interface PGSimulation()

@property (assign) int lastIndex;

@end

@implementation PGSimulation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lastIndex = -1;
        _graphicalShapesRegistery = [[NSMutableDictionary alloc] init];
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
