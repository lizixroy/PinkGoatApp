//
//  PGObjcMathUtilities.m
//  PinkGoatApp
//
//  Created by Roy Li on 10/21/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGObjcMathUtilities.h"

@implementation PGObjcMathUtilities

+ (matrix_float4x4)getMatrixFromTransfrom:(btTransform)transform
{
    btMatrix3x3 basis = transform.getBasis();
    btVector3 origin = transform.getOrigin();
    
    vector_float4 column0 = { basis.getColumn(0).getX(), basis.getColumn(0).getY(), basis.getColumn(0).getZ(), 0 };
    vector_float4 column1 = { basis.getColumn(1).getX(), basis.getColumn(1).getY(), basis.getColumn(1).getZ(), 0 };
    vector_float4 column2 = { basis.getColumn(2).getX(), basis.getColumn(2).getY(), basis.getColumn(2).getZ(), 0 };
    vector_float4 column3 = { origin.getX(), origin.getY(), origin.getZ(), 1 };
    matrix_float4x4 matrix = { column0, column1, column2, column3 };
    return matrix;
}

@end
