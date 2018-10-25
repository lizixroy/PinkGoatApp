//
//  PGSceneNodeBuilder.h
//  PinkGoatApp
//
//  Created by Roy Li on 10/20/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGShape.h"
#import "BulletUrdfImporter.h"
#import "GLInstanceGraphicsShape.h"

@interface PGShapeFactory : NSObject

- (PGShape *)makeShapeFromVertices:(btAlignedObjectArray<GLInstanceVertex> &)vertices indices:(btAlignedObjectArray<int> &)indices;

@end
