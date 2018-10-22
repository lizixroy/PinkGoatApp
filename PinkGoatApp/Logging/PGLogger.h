//
//  PGLogger.h
//  PinkGoatApp
//
//  Created by Roy Li on 10/16/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../bullet/LinearMath/btTransform.h"

@interface PGLogger : NSObject

+ (void)logTransform:(btTransform)transform;

@end
