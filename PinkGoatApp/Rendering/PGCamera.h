//
//  PGCamera.h
//  PinkGoatApp
//
//  Created by Roy Li on 10/25/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <simd/simd.h>

@interface PGCamera : NSObject

@property (assign) vector_float3 position;
@property (assign) vector_float3 up;
@property (assign) vector_float3 direction;

- (matrix_float4x4)getViewMatrix;

@end
