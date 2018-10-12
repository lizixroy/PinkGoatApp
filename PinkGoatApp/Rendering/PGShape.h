//
//  PGShape.h
//  PinkGoatApp
//
//  Created by Roy Li on 10/3/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGShaderTypes.h"
#import "PGVertexObject.h"
#import "PGDataTypes.h"
#import <Metal/Metal.h>

@interface PGShape : NSObject

@property (nonatomic, strong) NSArray<PGVertexObject *> *vertices;
@property (nonatomic, strong) NSArray<NSNumber *> *indices;

- (instancetype)initWithVertices:(NSArray<PGVertexObject *> *)vertices
                         indices:(NSArray<NSNumber *> *)indices;

- (void)makeVertices:(PGVertex *)verticesBuffer indices:(uint16_t *)indices count:(NSUInteger)count;
- (void)makeVertices:(PGVertex *)verticesBuffer count:(NSUInteger)count;
- (void)drawWithCommandEncoder:(nonnull id<MTLRenderCommandEncoder>)commandEncoder
                        device:(nonnull id<MTLDevice>)device;

@end
