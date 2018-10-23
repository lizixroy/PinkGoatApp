//
//  PGObjcMathUtilities.h
//  PinkGoatApp
//
//  Created by Roy Li on 10/21/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "../bullet/LinearMath/btMatrix3x3.h"
#import "../bullet/LinearMath/btTransform.h"

@interface PGObjcMathUtilities : NSObject

+ (matrix_float4x4)getMatrixFromTransfrom:(btTransform)transform;


@end
