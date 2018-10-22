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

@interface PGSceneNodeBuilder : NSObject

- (PGShape *)buildSceneNodeWithURDFImporter:(BulletURDFImporter&)urdfImporter
                                  linkIndex:(int)linkIndex;

@end
