//
//  PGCamera.m
//  PinkGoatApp
//
//  Created by Roy Li on 10/25/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGCamera.h"
#import "PGMathUtilities.h"

@implementation PGCamera

- (matrix_float4x4)getViewMatrix
{
    matrix_float4x4 m = matrix_identity_float4x4;
    vector_float3 right = simd_cross(self.up, self.direction);
    m.columns[0] = simd_make_float4(right.x, right.y, right.z, 0.0);
    m.columns[1] = simd_make_float4(self.up.x, self.up.y, self.up.z, 0.0);
    m.columns[2] = simd_make_float4(self.direction.x, self.direction.y, self.direction.z, 0.0);
    m.columns[3] = simd_make_float4(self.position.x, self.position.y, self.position.z, 1.0);
    m = simd_inverse(m);
    matrix_float4x4 rotationX = matrix_float4x4_rotation(right, self.cameraAngles.x);
    matrix_float4x4 rotationY = matrix_float4x4_rotation(self.up, -self.cameraAngles.y);
    m = matrix_multiply(m, matrix_multiply(rotationX, rotationY));
    return m;
}

@end
