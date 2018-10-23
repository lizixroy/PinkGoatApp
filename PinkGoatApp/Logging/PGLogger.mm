//
//  PGLogger.mm
//  PinkGoatApp
//
//  Created by Roy Li on 10/16/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGLogger.h"
#import "../bullet/LinearMath/btTransform.h"

@implementation PGLogger

+ (void)logTransform:(btTransform)transform;
{
    btMatrix3x3 rotation = transform.getBasis();
    btVector3 origin = transform.getOrigin();
    NSLog(@"\n\nrotation:\n[ %f %f %f ]\n[ %f %f %f ]\n[ %f %f %f ]\norigin:\n %f %f %f\n\n",
          rotation.getColumn(0).getX(),
          rotation.getColumn(1).getX(),
          rotation.getColumn(2).getX(),
          rotation.getColumn(0).getY(),
          rotation.getColumn(1).getY(),
          rotation.getColumn(2).getY(),
          rotation.getColumn(0).getZ(),
          rotation.getColumn(1).getZ(),
          rotation.getColumn(2).getZ(),
          origin.getX(), origin.getY(), origin.getZ());
}

@end
