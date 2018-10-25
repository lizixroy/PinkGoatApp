//
//  PGCollisionShapeGraphicsGenerator.h
//  PinkGoatApp
//
//  Created by Roy Li on 10/25/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGShape.h"
#import "../bullet/BulletCollision/CollisionShapes/btCollisionShape.h"

@interface PGCollisionShapeGraphicsGenerator : NSObject

- (PGShape *)generateGraphicsForCollisionShape:(btCollisionShape *)collisionShape;

@end
