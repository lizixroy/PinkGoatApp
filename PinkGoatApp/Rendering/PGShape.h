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

@interface PGShape : NSObject

@property (nonatomic, strong) NSArray<PGVertexObject *> *vertices;
@property (nonatomic, strong) NSArray<NSNumber *> *indices;

- (instancetype)initWithVertices:(NSArray<PGVertexObject *> *)vertices
                         indices:(NSArray<NSNumber *> *)indices;

@end
