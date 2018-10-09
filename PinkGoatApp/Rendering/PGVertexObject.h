//
//  PGVertexObject.h
//  PinkGoatApp
//
//  Created by Roy Li on 10/3/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <simd/simd.h>

@interface PGVertexObject : NSObject

@property (assign) vector_float3 position;
@property (assign) vector_float3 normal;
@property (assign) vector_float4 color;

- (nonnull instancetype)initWithPosition:(vector_float3)position
                                  normal:(vector_float3)normal
                                   color:(vector_float4)color;

@end
