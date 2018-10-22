//
//  PGVertexObject.m
//  PinkGoatApp
//
//  Created by Roy Li on 10/3/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGVertexObject.h"

@implementation PGVertexObject

- (nonnull instancetype)initWithPosition:(vector_float3)position
                                  normal:(vector_float3)normal
                                   color:(vector_float4)color;
{
    self = [super init];
    if (self) {
        _position = position;
        _normal = normal;
        _color = color;
    }
    return self;
}

- (nonnull instancetype)initWithPosition:(vector_float3)position
                                  normal:(vector_float3)normal
{
    self = [super init];
    if (self) {
        _position = position;
        _normal = normal;
        vector_float4 color = { 1.0, 1.0, 1.0, 1.0 };
        _color = color;
    }
    return self;
}

@end
