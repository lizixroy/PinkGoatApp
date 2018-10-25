//
//  PGRenderer.h
//  PinkGoatApp
//
//  Created by Roy Li on 10/3/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGShaderTypes.h"
#import "PGShape.h"
#import <MetalKit/MetalKit.h>

@interface PGRenderer : NSObject <MTKViewDelegate>

// This completion will be invovked after every frame
@property (nonatomic, strong) void (^ _Nullable frameCompletion)(void);

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;
- (void)registerShape:(nonnull PGShape *)shape;

@end
