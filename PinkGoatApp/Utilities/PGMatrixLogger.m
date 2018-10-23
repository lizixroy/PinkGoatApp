//
//  PGMatrixLogger.m
//  PinkGoatApp
//
//  Created by Roy Li on 10/23/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGMatrixLogger.h"

@implementation PGMatrixLogger

+ (void)printMatrix4x4:(matrix_float4x4)matrix
{
    NSLog(@"\n[ %f %f %f %f ]\n[ %f %f %f %f ]\n[ %f %f %f %f ]\n[ %f %f %f %f ]",
          matrix.columns[0][0], matrix.columns[1][0], matrix.columns[2][0], matrix.columns[3][0],
          matrix.columns[0][1], matrix.columns[1][1], matrix.columns[2][1], matrix.columns[3][1],
          matrix.columns[0][2], matrix.columns[1][2], matrix.columns[2][2], matrix.columns[3][2],
          matrix.columns[0][3], matrix.columns[1][3], matrix.columns[2][3], matrix.columns[3][3]);
}

@end
