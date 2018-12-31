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
#import <SceneKit/SceneKit.h>
#import "PGRenderer.h"
#import "PGShape.h"
#import "BulletDynamics/Featherstone/btMultiBodyDynamicsWorld.h"
#import "BulletDynamics/btBulletDynamicsCommon.h"
#import "PGPhysicsWorldProtocol.h"
#import "BulletInverseDynamics/MultiBodyTreeCreator.hpp"
#import "PGEventSubscriber.h"
#import "PGRobot.h"

@interface PGSimulation : NSObject
{
    @public
    btDiscreteDynamicsWorld *physicsWorld;
}

@property (nonatomic, strong) PGRenderer *renderer;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, PGShape *>  *graphicalShapesRegistery;
@property (assign) BOOL terminated;
@property (nonatomic, strong) SCNScene *scene;
// For now, let each simulation only have one robot (tree of multiple rigid body).
// Later on this needs to be converted into an array.
@property (nonatomic, strong) PGRobot *robot;

- (instancetype)initWithScene:(SCNScene *)scene;
- (void)beginSimulation;

/**
 Register shape to the graphical renderer.
 args:
    shape: shape to be registered
 return:
    int: the index in the registery for the shape passed in.
 */
- (int)registerShape:(PGShape *)shape;


/**
 Add a subscriber to update subscribers to receive update event for every step of the simulation.
 One subscriber will only be added once. After the first time, subsequent subscriptions calls will be ignored.

 @param subscriber
 */
- (void)addUpdateSubscription:(id<PGEventSubscriberProtocol>)subscriber;

@end
