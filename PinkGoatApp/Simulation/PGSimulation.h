//
//  PGSimulation.h
//  PinkGoatApp
//
//  Created by Roy Li on 10/24/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

/**
    PGSimulation provides abstraction around simulations inside PG, the main responsibilities include
 - Manages the life cycles of simulations (start, pause, terminate, etc.)
 - Encapsulates the physics world from the rest of the application by being a gateway.
 - Encapsulates the graphics.
 */

#import <Foundation/Foundation.h>
#import "PGRenderer.h"
#import "PGShape.h"
#include "BulletDynamics/Featherstone/btMultiBodyDynamicsWorld.h"

@interface PGSimulation : NSObject
{
    @public
    btDiscreteDynamicsWorld *physicsWorld;
}

@property (nonatomic, strong) PGRenderer *renderer;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, PGShape *>  *graphicalShapesRegistery;
@property (assign) BOOL terminated;

- (void)beginSimulation;

/**
 Register shape to the graphical renderer.
 args:
    shape: shape to be registered
 return:
    int: the index in the registery for the shape passed in.
 */
- (int)registerShape:(PGShape *)shape;

@end